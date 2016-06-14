{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2016 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ��������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��http://www.cnpack.org                                   }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnScaners;
{* |<PRE>
================================================================================
* ������ƣ�CnPack �����ʽ��ר��
* ��Ԫ���ƣ�Object Pascal �ʷ�������
* ��Ԫ���ߣ�CnPack������
* ��    ע���õ�Ԫʵ����Object Pascal �ʷ�������
*    ���������ƣ�һ��̶����ȵĻ�����������������ݺ��ҵ����һ�����У��Դ�Ϊ��β��
*    ɨ������β������ ReadBuffer���ѱ������β��������β������������ػ������ף�
*    ���������������������������һ�����в���ǽ�β��
*    ������ļ�������ǣ�����β�ǿ�ע���е���ĩʱ��δ����Ч���� ReadBuffer��
*    ��ʹ�ڴ���ע�Ϳ��ڲ����� #0 ʱ���� ReadBuffer �Ĵ���Ҳ����Ϊ���ܵ�
*    ������������ȫ��ע�͡����� FSourcePtr û�в����Ӷ��޷����������ݵ������
*           Ψһ�취��ʹ���㹻��ĵ��黺������
* ����ƽ̨��Win2003 + Delphi 5.0
* ���ݲ��ԣ�not test yet
* �� �� ����not test hell
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2007-10-13 V1.0
*               ����һЩ����
*           2004-1-14 V0.5
*               �����ǩ(Bookmark)���ܣ����Է������ǰ��N��TOKEN
*           2003-12-16 V0.4
*               ������Ŀǰ�Զ������ո��ע�͡�ע�Ͳ�Ӧ�����������ǻ���Ҫ����
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, Contnrs, CnFormatterIntf,
  CnParseConsts, CnTokens, CnCodeGenerators, CnCodeFormatRules;

type
  TScannerBookmark = class(TObject)
  private
    FOriginBookmark: Longint;
    FTokenBookmark: TPascalToken;
    FTokenPtrBookmark: PChar;
    FSourcePtrBookmark: PChar;
    FSourceLineBookmark: Integer;
    FBlankLinesBeforeBookmark: Integer;
    FBlankLinesAfterBookmark: Integer;
    FPrevBlankLinesBookmark: Boolean;
    FSourceColBookmark: Integer;
    FInIgnoreAreaBookmark: Boolean;
    FNewSourceColBookmark: Integer;
    FOldSourceColPtrBookmark: PChar;
  protected
    property OriginBookmark: Longint read FOriginBookmark write FOriginBookmark;
    property TokenBookmark: TPascalToken read FTokenBookmark write FTokenBookmark;
    property TokenPtrBookmark: PChar read FTokenPtrBookmark write FTokenPtrBookmark;
    property SourcePtrBookmark: PChar read FSourcePtrBookmark write FSourcePtrBookmark;
    property OldSourceColPtrBookmark: PChar read FOldSourceColPtrBookmark write FOldSourceColPtrBookmark;
    property SourceLineBookmark: Integer read FSourceLineBookmark write FSourceLineBookmark;
    property SourceColBookmark: Integer read FSourceColBookmark write FSourceColBookmark;
    property NewSourceColBookmark: Integer read FNewSourceColBookmark write FNewSourceColBookmark;
    property BlankLinesBeforeBookmark: Integer read FBlankLinesBeforeBookmark write FBlankLinesBeforeBookmark;
    property BlankLinesAfterBookmark: Integer read FBlankLinesAfterBookmark write FBlankLinesAfterBookmark;
    property PrevBlankLinesBookmark: Boolean read FPrevBlankLinesBookmark write FPrevBlankLinesBookmark;
    property InIgnoreAreaBookmark: Boolean read FInIgnoreAreaBookmark write FInIgnoreAreaBookmark;
  end;

  TAbstractScaner = class(TObject)
  private
    FStream: TStream;
    FBookmarks: TObjectList;

    // ���������Ƶ������ͷ��ע��
    FOrigin: Longint;  // ��ʾ�������������ݿ�ͷ���������е�����λ��
    FBuffer: PChar;    // һ��̶����ȵĻ������Ŀ�ʼ��ַ
    FBufSize: Cardinal;
    FBufPtr: PChar;
    FBufEnd: PChar;
    FSourcePtr: PChar; // ���ڲ��������ⲿʼ��ָ��ǰ Token β��
    FSourceEnd: PChar; // �������������������� LineStart �ҵ������һ�����У���Ϊ����ɨ��Ľ�β�������ǻ�����β

    FTokenPtr: PChar;  // ���ڲ��������ⲿʼ��ָ��ǰ Token ͷ��
    FOldSourceColPtr: PChar; // ���ڲ��������ⲿʼ��ָ����һ���п�ʼ�����λ��
    FStringPtr: PChar;
    FSourceLine: Integer;
    FSaveChar: Char;
    FToken: TPascalToken;
    FFloatType: Char;
    FWideStr: WideString;
    FBackwardToken: TPascalToken;
    // FBackwardNonBlankToken: TPascalToken;

    FBlankStringBegin: PChar;  // ���ڲ��������ⲿʼ��ָ��ǰ�հ׵�ͷ��
    FBlankStringEnd: PChar;    // ���ڲ��������ⲿʼ��ָ��ǰ�հ׵�β��
    FBlankLines, FBlankLinesAfterComment: Integer;
    FBlankLinesBefore: Integer;
    FBlankLinesAfter: Integer;
    FASMMode: Boolean;
    FFirstCommentInBlock: Boolean;
    FPreviousIsComment: Boolean;
    FInDirectiveNestSearch: Boolean;
    FKeepOneBlankLine: Boolean;
    FPrevBlankLines: Boolean;
    FNewSourceCol: Integer; // ���ڲ�����ָ����һ�� Token ����
    FSourceCol: Integer;
    FInIgnoreArea: Boolean;
    procedure ReadBuffer;
    procedure SetOrigin(AOrigin: Longint);
    procedure SkipBlanks; // Խ���հ׺ͻس�����
    procedure DoBlankLinesWhenSkip(BlankLines: Integer); virtual;
    {* SkipBlanks ʱ������������ʱ������}
    function ErrorTokenString: string;
    procedure NewLine;

{$IFDEF UNICODE}
    procedure FixStreamBom;
{$ENDIF}
  protected
    procedure OnMoreBlankLinesWhenSkip; virtual; abstract;
  public
    constructor Create(Stream: TStream); virtual;
    destructor Destroy; override;
    procedure CheckToken(T: TPascalToken);
    procedure CheckTokenSymbol(const S: string);
    procedure Error(const Ident: Integer);
    procedure ErrorFmt(const Ident: Integer; const Args: array of const);
    procedure ErrorStr(const Message: string);
    procedure HexToBinary(Stream: TStream);

    function NextToken: TPascalToken; virtual; abstract;
    function SourcePos: LongInt;
    // ��ǰ Token ������Դ���е�ƫ������0 ��ʼ
    function BlankStringPos: LongInt;
    // ��ǰ�հ�������Դ���е�ƫ������0 ��ʼ

    function TokenComponentIdent: string;
    function TokenFloat: Extended;
{$IFDEF DELPHI5}
    function TokenInt: Integer;
{$ELSE}
    function TokenInt: Int64;
{$ENDIF}
    function BlankString: string;
    {* ��ǰ�հ�������ַ���ֵ}
    function BlankStringLength: Integer;
    {* ��ǰ�հ�������ַ�����}

    function TokenString: string;
    {* ��ǰ Token ���ַ���ֵ}
    function TokenStringLength: Integer;
    {* ��ǰ Token ���ַ�����}
    function TrimBlank(const Str: string): string;
    {* ���� BlankString������ϴ������������һ���ָ��Ŀ��У��򱾴� BlankString
       ��Ҫȥ��ǰ�����У���ȥ��һ���Ա���ԭ�п��������أ�����ȥ������ǰ������һ�����У�}
    function TokenChar: Char;
    function TokenWideString: WideString;
    function TokenSymbolIs(const S: string): Boolean;

    procedure SaveBookmark(var Bookmark: TScannerBookmark);
    procedure LoadBookmark(var Bookmark: TScannerBookmark; Clear: Boolean = True);
    procedure ClearBookmark(var Bookmark: TScannerBookmark);

    function ForwardToken(Count: Integer = 1): TPascalToken; virtual;

    property FloatType: Char read FFloatType;
    property SourceLine: Integer read FSourceLine;  // �У��� 1 ��ʼ
    property SourceCol: Integer read FSourceCol;    // �У��� 1 ��ʼ

    property Token: TPascalToken read FToken;
    property TokenPtr: PChar read FTokenPtr;

    property ASMMode: Boolean read FASMMode write FASMMode;
    {* ���������Ƿ񽫻س������հ��Լ�����������asm ������Ҫ��ѡ��}

    property BlankLinesBefore: Integer read FBlankLinesBefore write FBlankLinesBefore;
    {* SkipBlank ����һע��ʱ��ע�ͺ�ǰ����Ч���ݸ����������������Ʒ��С�
      0 ��ʾ��ͬһ�У�1 ��ʾע���ڽ��ڵ���һ�У�2 ��ʾע�ͺ�ǰ������ݸ�һ������}
    property BlankLinesAfter: Integer read FBlankLinesAfter write FBlankLinesAfter;
    {* SkipBlank ����һע�ͺ�ע�ͺͺ�����Ч���ݸ����������������Ʒ��С�
      0 ��ʾ��ͬһ�У�1 ��ʾ���������ڽ��ڵ���һ�У�2 ��ʾע�ͺͺ������ݸ�һ������}

    property PrevBlankLines: Boolean read FPrevBlankLines write FPrevBlankLines;
    {* ��¼��һ���Ƿ�������������кϲ��ɵ�һ������}

    property KeepOneBlankLine: Boolean read FKeepOneBlankLine write FKeepOneBlankLine;
    {* ����������Ƿ��ڸ�ʽ���Ĺ����б��ֿ��У������� Bookmark ����}

    property InIgnoreArea: Boolean read FInIgnoreArea write FInIgnoreArea;
    {* ���ڲ�ǰ�� Token ʱ�������õ�ǰ�Ƿ���Ը�ʽ����ǣ������ʹ��}
  end;

  TScaner = class(TAbstractScaner)
  private
    FStream: TStream;
    FCodeGen: TCnCodeGenerator;
    FCompDirectiveMode: TCompDirectiveMode;
  protected
    procedure OnMoreBlankLinesWhenSkip; override;    
  public
    constructor Create(AStream: TStream); overload; override;
    constructor Create(AStream: TStream; ACodeGen: TCnCodeGenerator;
      ACompDirectiveMode: TCompDirectiveMode); reintroduce; overload;
    destructor Destroy; override;
    function NextToken: TPascalToken; override;
    function ForwardToken(Count: Integer = 1): TPascalToken; override;

    property CompDirectiveMode: TCompDirectiveMode read FCompDirectiveMode;
  end;

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  MIN_SCAN_BUF_SIZE = 512 * 1024 {512KB};
  MAX_SCAN_BUF_SIZE = 32 * 1024 * 1024 {32MB};

procedure BinToHex(Buffer, Text: PChar; BufSize: Integer); 
const
  Convert: array[0..15] of Char = '0123456789ABCDEF';
var
  I: Integer;
begin
  for I := 0 to BufSize - 1 do
  begin
    Text[0] := Convert[Byte(Buffer[I]) shr 4];
    Text[1] := Convert[Byte(Buffer[I]) and $F];
    Inc(Text, 2);
  end;
end;
{asm
        PUSH    ESI
        PUSH    EDI
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EDX,0
        JMP     @@1
@@0:    DB      '0123456789ABCDEF'
@@1:    LODSB
        MOV     DL,AL
        AND     DL,0FH
        MOV     AH,@@0.Byte[EDX]
        MOV     DL,AL
        SHR     DL,4
        MOV     AL,@@0.Byte[EDX]
        STOSW
        DEC     ECX
        JNE     @@1
        POP     EDI
        POP     ESI
end;}

function HexToBin(Text, Buffer: PChar; BufSize: Integer): Integer;
const
  Convert: array['0'..'f'] of SmallInt =
    ( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,-1,-1,-1,-1,-1,-1,
     -1,10,11,12,13,14,15,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,
     -1,10,11,12,13,14,15);
var
  I: Integer;
begin
  I := BufSize;
  while I > 0 do
  begin
    if not (Text[0] in ['0'..'f']) or not (Text[1] in ['0'..'f']) then Break;
    Buffer[0] := Char((Convert[Text[0]] shl 4) + Convert[Text[1]]);
    Inc(Buffer);
    Inc(Text, 2);
    Dec(I);
  end;
  Result := BufSize - I;
end;

{asm
        PUSH    ESI
        PUSH    EDI
        PUSH    EBX
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EBX,EDX
        MOV     EDX,0
        JMP     @@1
@@0:    DB       0, 1, 2, 3, 4, 5, 6, 7, 8, 9,-1,-1,-1,-1,-1,-1
        DB      -1,10,11,12,13,14,15,-1,-1,-1,-1,-1,-1,-1,-1,-1
        DB      -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
        DB      -1,10,11,12,13,14,15
@@1:    LODSW
        CMP     AL,'0'
        JB      @@2
        CMP     AL,'f'
        JA      @@2
        MOV     DL,AL
        MOV     AL,@@0.Byte[EDX-'0']
        CMP     AL,-1
        JE      @@2
        SHL     AL,4
        CMP     AH,'0'
        JB      @@2
        CMP     AH,'f'
        JA      @@2
        MOV     DL,AH
        MOV     AH,@@0.Byte[EDX-'0']
        CMP     AH,-1
        JE      @@2
        OR      AL,AH
        STOSB
        DEC     ECX
        JNE     @@1
@@2:    MOV     EAX,EDI
        SUB     EAX,EBX
        POP     EBX
        POP     EDI
        POP     ESI
end;}

{ TAbstractScaner }

constructor TAbstractScaner.Create(Stream: TStream);
begin
  FStream := Stream;
{$IFDEF UNICODE}
  FixStreamBom;
{$ENDIF}
  FBookmarks := TObjectList.Create;

  if Stream.Size < MIN_SCAN_BUF_SIZE then
    FBufSize := MIN_SCAN_BUF_SIZE
  else if Stream.Size > MAX_SCAN_BUF_SIZE then
    FBufSize := MAX_SCAN_BUF_SIZE
  else
    FBufSize := Stream.Size;

  GetMem(FBuffer, FBufSize);
  FBuffer[0] := #0;
  FBufPtr := FBuffer;
  FBufEnd := FBuffer + FBufSize div SizeOf(Char); // PChar ������ Char Ϊ��λ�����Եó��� Char �Ĵ�С
  FSourcePtr := FBuffer;
  FSourceEnd := FBuffer;
  FTokenPtr := FBuffer;
  FOldSourceColPtr := FBuffer;
  FSourceLine := 1;
  FSourceCol := 1;
  FNewSourceCol := 1;
  FBackwardToken := tokNoToken;

  // NextToken;  Let outside call it.
end;

{$IFDEF UNICODE}

procedure TAbstractScaner.FixStreamBom;
var
  Bom: array[0..1] of AnsiChar;
  TS: TMemoryStream;
begin
  if (FStream <> nil) and (FStream.Size > 2) then
  begin
    FStream.Seek(0, soBeginning);
    FStream.Read(Bom, SizeOf(Bom));
    if (Bom[0] = #$FF) and (Bom[1] = #$FE) then
    begin
      // Has Utf16 BOM, remove
      TS := TMemoryStream.Create;
      try
        TS.CopyFrom(FStream, FStream.Size - SizeOf(Bom));
        FStream.Position := 0;
        FStream.Size := 0;
        FStream.CopyFrom(TS, 0);
      finally
        TS.Free;
      end;
    end;
    FStream.Position := 0;
  end;
end;

{$ENDIF}

destructor TAbstractScaner.Destroy;
begin
  if FBuffer <> nil then
  begin
    FStream.Seek(Longint(FTokenPtr) - Longint(FBufPtr), 1);
    FreeMem(FBuffer);
  end;

  FBookmarks.Free;
end;

procedure TAbstractScaner.CheckToken(T: TPascalToken);
begin
  if Token <> T then
    case T of
      tokSymbol:
        Error(CN_ERRCODE_PASCAL_IDENT_EXP);
      tokString, tokWString:
        Error(CN_ERRCODE_PASCAL_STRING_EXP);
      tokInteger, tokFloat:
        Error(CN_ERRCODE_PASCAL_NUMBER_EXP);
    else
      ErrorFmt(CN_ERRCODE_PASCAL_CHAR_EXP, [Integer(T)]);
    end;
end;

procedure TAbstractScaner.CheckTokenSymbol(const S: string);
begin
  if not TokenSymbolIs(S) then ErrorFmt(CN_ERRCODE_PASCAL_SYMBOL_EXP, [S]);
end;

procedure TAbstractScaner.Error(const Ident: Integer);
begin
  // �������
  PascalErrorRec.ErrorCode := Ident;
  PascalErrorRec.SourceLine := FSourceLine;
  PascalErrorRec.SourceCol := FSourceCol;
  PascalErrorRec.SourcePos := SourcePos;
  PascalErrorRec.CurrentToken := ErrorTokenString;

  ErrorStr(RetrieveFormatErrorString(Ident));
end;

procedure TAbstractScaner.ErrorFmt(const Ident: Integer; const Args: array of const);
begin
  // �������
  PascalErrorRec.ErrorCode := Ident;
  PascalErrorRec.SourceLine := FSourceLine;
  PascalErrorRec.SourceCol := FSourceCol;  
  PascalErrorRec.SourcePos := SourcePos;
  PascalErrorRec.CurrentToken := ErrorTokenString;
  
  ErrorStr(Format(RetrieveFormatErrorString(Ident), Args));
end;

procedure TAbstractScaner.ErrorStr(const Message: string);
begin
  raise EParserError.CreateFmt(SParseError, [Message, FSourceLine, SourcePos]);
end;

procedure TAbstractScaner.HexToBinary(Stream: TStream);
var
  Count: Integer;
  Buffer: array[0..255] of Char;
begin
  SkipBlanks;
  while FSourcePtr^ <> '}' do
  begin
    Count := HexToBin(FSourcePtr, Buffer, SizeOf(Buffer));
    if Count = 0 then Error(CN_ERRCODE_PASCAL_INVALID_BIN);
    Stream.Write(Buffer, Count);
    Inc(FSourcePtr, Count * 2);
    SkipBlanks;
  end;
  NextToken;
end;

procedure TAbstractScaner.ReadBuffer;
var
  Count: Integer;
begin
  Inc(FOrigin, Integer(FSourcePtr) - Integer(FBuffer));
  FSourceEnd[0] := FSaveChar;
  Count := Integer(FBufPtr) - Integer(FSourcePtr);
  if Count <> 0 then Move(FSourcePtr[0], FBuffer[0], Count);
  FBufPtr := PChar(Integer(FBuffer) + Count);

  Count := FStream.Read(FBufPtr[0], (Integer(FBufEnd) - Integer(FBufPtr))); // �������� Byte ��
  FBufPtr := PChar(Integer(FBufPtr) + Count);

  FSourcePtr := FBuffer;
  FSourceEnd := FBufPtr;
  if FSourceEnd = FBufEnd then
  begin
    FSourceEnd := LineStart(FBuffer, FSourceEnd - 1);
    if FSourceEnd = FBuffer then Error(CN_ERRCODE_PASCAL_LINE_TOOLONG);
  end;
  FSaveChar := FSourceEnd[0];
  FSourceEnd[0] := #0;
end;

procedure TAbstractScaner.SetOrigin(AOrigin: Integer);
var
  Count: Integer;
begin
  if AOrigin <> FOrigin then
  begin
    FOrigin := AOrigin;
    FSourceEnd[0] := FSaveChar;
    FStream.Seek(AOrigin, soFromBeginning);
    FBufPtr := FBuffer;

    Count := FStream.Read(FBuffer[0], FBufSize);
    FBufPtr := PChar(Integer(FBufPtr) + Count);

    FSourcePtr := FBuffer;
    FSourceEnd := FBufPtr;
    if FSourceEnd = FBufEnd then
    begin
      FSourceEnd := LineStart(FBuffer, FSourceEnd - 1);
      if FSourceEnd = FBuffer then Error(CN_ERRCODE_PASCAL_LINE_TOOLONG);
    end;
    FSaveChar := FSourceEnd[0];
    FSourceEnd[0] := #0;
  end;
end;

procedure TAbstractScaner.SkipBlanks;
var
  EmptyLines: Integer;
begin
  FBlankStringBegin := FSourcePtr;
  FBlankStringEnd := FBlankStringBegin;
  FBlankLines := 0;

  EmptyLines := 0;
  while True do
  begin
    case FSourcePtr^ of
      #0:
        begin
          ReadBuffer;
          if FSourcePtr^ = #0 then
          begin
            DoBlankLinesWhenSkip(EmptyLines);
            Exit;
          end;
          Continue;
        end;
      #10:
        begin
          NewLine;
          FOldSourceColPtr := FSourcePtr;
          Inc(FOldSourceColPtr);
          Inc(FBlankLines);

          if FASMMode then // ��Ҫ���س��ı�־
          begin
            FBlankStringEnd := FSourcePtr;
            DoBlankLinesWhenSkip(EmptyLines);
            Exit; // Do not exit for Inc FSourcePtr?
          end;
          Inc(EmptyLines);
        end;
      #33..#255:
        begin
          FBlankStringEnd := FSourcePtr;
          DoBlankLinesWhenSkip(EmptyLines);

          Exit;
        end;
    end;
    
    Inc(FSourcePtr);
    FBackwardToken := tokBlank;
  end;
end;

function TAbstractScaner.SourcePos: Longint;
begin
  Result := FOrigin + (FTokenPtr - FBuffer);
end;

function TAbstractScaner.BlankStringPos: Longint;
begin
  Result := FOrigin + (FBlankStringBegin - FBuffer);
end;

function TAbstractScaner.TokenFloat: Extended;
begin
  if FFloatType <> #0 then Dec(FSourcePtr);
  Result := StrToFloat(TokenString);
  if FFloatType <> #0 then Inc(FSourcePtr);
end;

{$IFDEF DELPHI5}
function TAbstractScaner.TokenInt: Integer;
begin
  Result := StrToInt(TokenString);
end;
{$ELSE}
function TAbstractScaner.TokenInt: Int64;
begin
  Result := StrToInt64(TokenString);
end;
{$ENDIF}

function TAbstractScaner.TokenString: string;
var
  L: Integer;
begin
  if FToken = tokString then
    L := FStringPtr - FTokenPtr
  else
    L := FSourcePtr - FTokenPtr;
  SetString(Result, FTokenPtr, L);
end;

function TAbstractScaner.TokenWideString: WideString;
begin
  if FToken = tokString then
    Result := TokenString
  else
    Result := FWideStr;
end;

function TAbstractScaner.TokenSymbolIs(const S: string): Boolean;
begin
  Result := SameText(S, TokenString);
end;

function TAbstractScaner.TokenComponentIdent: string;
var
  P: PChar;
begin
  CheckToken(tokSymbol);
  P := FSourcePtr;
  while P^ = '.' do
  begin
    Inc(P);
    if not (P^ in ['A'..'Z', 'a'..'z', '_']) then
      Error(CN_ERRCODE_PASCAL_IDENT_EXP);
    repeat
      Inc(P)
    until not (P^ in ['A'..'Z', 'a'..'z', '0'..'9', '_']);
  end;
  FSourcePtr := P;
  Result := TokenString;
end;

function TAbstractScaner.TokenChar: Char;
begin
  if Length(TokenString) > 0 then
    Result := TokenString[1]
  else
    Result := #0;
end;

procedure TAbstractScaner.LoadBookmark(var Bookmark: TScannerBookmark; Clear:
  Boolean = True);
begin
  if FBookmarks.IndexOf(Bookmark) >= 0 then
  begin
    with Bookmark do
    begin
      if Assigned(SourcePtrBookmark) and Assigned(TokenPtrBookmark) then
      begin
        if OriginBookmark <> FOrigin then
          SetOrigin(OriginBookmark);
        FSourcePtr := SourcePtrBookmark;
        FTokenPtr := TokenPtrBookmark;
        FOldSourceColPtr := OldSourceColPtrBookmark;
        FToken := TokenBookmark;
        FSourceLine := SourceLineBookmark;
        FSourceCol := SourceColBookmark;
        FNewSourceCol := NewSourceColBookmark;
        FBlankLinesBefore := BlankLinesBeforeBookmark;
        FBlankLinesAfter := BlankLinesAfterBookmark;
        FPrevBlankLines := PrevBlankLinesBookmark;
        FInIgnoreArea := InIgnoreAreaBookmark;
      end
      else
        Error(CN_ERRCODE_PASCAL_INVALID_BOOKMARK);
    end;
  end
  else
    Error(CN_ERRCODE_PASCAL_INVALID_BOOKMARK);

  if Clear then
    ClearBookmark(Bookmark);
end;

procedure TAbstractScaner.SaveBookmark(var Bookmark: TScannerBookmark);
begin
  Bookmark := TScannerBookmark.Create;
  with Bookmark do
  begin
    OriginBookmark := FOrigin;
    SourcePtrBookmark := FSourcePtr;
    TokenBookmark := FToken;
    TokenPtrBookmark := FTokenPtr;
    OldSourceColPtrBookmark := FOldSourceColPtr;
    SourceLineBookmark := FSourceLine;
    SourceColBookmark := FSourceCol;
    NewSourceColBookmark := FNewSourceCol;
    BlankLinesBeforeBookmark := FBlankLinesBefore;
    BlankLinesAfterBookmark := FBlankLinesAfter;
    PrevBlankLinesBookmark := FPrevBlankLines;
    InIgnoreAreaBookmark := FInIgnoreArea;
  end;
  FBookmarks.Add(Bookmark);
end;

procedure TAbstractScaner.ClearBookmark(var Bookmark: TScannerBookmark);
begin
  Bookmark := TScannerBookmark(FBookmarks.Extract(Bookmark));
  if Assigned(Bookmark) then
    FreeAndNil(Bookmark);
end;

function TAbstractScaner.ForwardToken(Count: Integer): TPascalToken;
var
  Bookmark: TScannerBookmark;
  I: Integer;
begin
  Result := Token;

  SaveBookmark(Bookmark);

  for I := 0 to Count - 1 do
  begin
    Result := NextToken;
    if Result = tokEOF then
      Exit;
  end;

  LoadBookmark(Bookmark);
end;

function TAbstractScaner.BlankString: string;
var
  L: Integer;
begin
  L := FBlankStringEnd - FBlankStringBegin;
  SetString(Result, FBlankStringBegin, L);
end;

function TAbstractScaner.ErrorTokenString: string;
begin
  Result := TokenToString(Token);
  if Result = '' then
    Result := TokenString;
end;

procedure TAbstractScaner.DoBlankLinesWhenSkip(BlankLines: Integer);
begin
  if FKeepOneBlankLine and (BlankLines > 1) then
  begin
    FPrevBlankLines := True;
    OnMoreBlankLinesWhenSkip;
  end
  else
  begin
    FPrevBlankLines := False;
  end;
end;

function TAbstractScaner.TrimBlank(const Str: string): string;
begin
  Result := Str;
  if PrevBlankLines and (Length(Str) >= 2) then
  begin
    if Str[1] = #10 then
      Delete(Result, 1, 1)
    else if Str[2] = #10 then
      Delete(Result, 1, 2);
  end;
end;

procedure TAbstractScaner.NewLine;
begin
  Inc(FSourceLine);
  FNewSourceCol := 1;
end;

function TAbstractScaner.TokenStringLength: Integer;
begin
  if FToken = tokString then
    Result := FStringPtr - FTokenPtr
  else
    Result := FSourcePtr - FTokenPtr;
end;

function TAbstractScaner.BlankStringLength: Integer;
begin
  Result := FBlankStringEnd - FBlankStringBegin;
end;

{ TScaner }

constructor TScaner.Create(AStream: TStream; ACodeGen: TCnCodeGenerator;
  ACompDirectiveMode: TCompDirectiveMode);
begin
  AStream.Seek(0, soFromBeginning);
  FStream := AStream;
  FCodeGen := ACodeGen;

  FCompDirectiveMode := ACompDirectiveMode; // Set CompDirective Process Mode
  inherited Create(AStream);
end;

constructor TScaner.Create(AStream: TStream);
begin
  Create(AStream, nil, CnPascalCodeForRule.CompDirectiveMode); //TCnCodeGenerator.Create);
end;

destructor TScaner.Destroy;
begin

  inherited;
end;

function TScaner.ForwardToken(Count: Integer): TPascalToken;
begin
  if FCodeGen <> nil then
    FCodeGen.LockOutput;
  try
    Result := inherited ForwardToken(Count);
  finally
    if FCodeGen <> nil then
      FCodeGen.UnLockOutput;
  end;
end;

function TScaner.NextToken: TPascalToken;
var
  BlankStr: string;
  S: string;

  procedure SkipTo(var P: PChar; TargetChar: Char);
  begin
    while (P^ <> TargetChar) do
    begin
      Inc(P);

      if (P^ = #0) then
      begin
        ReadBuffer;
        if FSourcePtr^ = #0 then
          Break;
      end;
    end;
  end;

var
  IsWideStr, FloatStop, IsString: Boolean;
  P, IgnoreP, OldP: PChar;
  Directive: TPascalToken;
  DirectiveNest, FloatCount: Integer;
  TmpToken: string;
begin
  FOldSourceColPtr := FSourcePtr;

  SkipBlanks;
  FSourceCol := FNewSourceCol;

  P := FSourcePtr;
  FTokenPtr := P;
  // FTokenPtr �����˱��β�����ԭʼλ�ã�������Ϻ�P �� FTokenPtr �Ĳ���ǵ�ǰ Token �ĳ���

  // FOldSourceColPtr ���汾�β�����ԭʼ��λ�ã�������Ϻ���δ���ֻ��У�P �� OldColPtr �Ĳ���� NewSourceCol ��Ҫ���ӵĳ���
  // ����ֻ��У����д� SourceCol ���� 1��OldCol ����ֵΪ���д���ĩ����Ȼ�� NewSourceCol += P - OldCol;

  case P^ of
    'A'..'Z', 'a'..'z', '_' {$IFDEF UNICODE}, #$0100..#$FFFF {$ENDIF}:
      begin
        Inc(P);
        while (P^ in ['A'..'Z', 'a'..'z', '0'..'9', '_'])
          {$IFDEF UNICODE} or (P^ >= #$0100) {$ENDIF} do
          Inc(P);
        Result := tokSymbol;
      end;

    '^':
      begin
        OldP := P;

        Inc(P);
        Result := tokNoToken;

        // �������������^֮ǰ����ĸ���ֻ�)]^���ͱ�ʾ�����ַ�������Hat
        if OldP > FBuffer then
        begin
          Dec(OldP);
          if OldP^ in ['A'..'Z', 'a'..'z', '0'..'9', '^', ')', ']'] then
            Result := tokHat;
        end;

        OldP := P;
        IsString := False;
        if Result <> tokHat then // û��ȷ���� Hat ������£����ж��Ƿ����ַ���
        begin
          // Ŀǰֻ���� ^H^J ���ּ�ź󵥸��ַ��ĳ��ϣ���δ������''���ַ���������
          IsString := True;

          repeat // �����ѭ��ʱ��P �ض�ָ�� ^ ���һ���ַ�
            if not (P^ in [#33..#126]) then
            begin // ^ ���ַ��������ʾ�����ַ���������
              IsString := False;
              Break;
            end;

            Inc(P);
            if P^ = '^' then
            begin
              Inc(P);
              Continue;
            end;

            // ^����ַ�֮���������^������Ҫ�˳������ͬʱ���Ǳ�ʶ����˵�������ַ��������ݡ�
            if P^ in ['A'..'Z', 'a'..'z', '0'..'9', '_'] then
              IsString := False;

            Break;
          until False;
        end;

        if IsString then
        begin
          Result := tokString;
          FStringPtr := P;
        end
        else
        begin
          P := OldP;
          Result := tokHat;
        end;
      end;

    '#', '''':
      begin
        IsWideStr := False;
        // parser string like this: 'abc'#10^M#13'def'#10#13
        while True do
          case P^ of
            '#':
              begin
                IsWideStr := True;
                Inc(P);
                while P^ in ['$', '0'..'9', 'a'..'f', 'A'..'F'] do Inc(P);
              end;
            '''':
              begin
                Inc(P);
                while True do
                  case P^ of
                    #0, #10, #13:
                      Error(CN_ERRCODE_PASCAL_INVALID_STRING);
                    '''':
                      begin
                        Inc(P);
                        Break;
                      end;
                  else
                    Inc(P);
                  end;
              end;
            '^':
              begin
                Inc(P);
                if not (P^ in [#33..#126]) then
                  Error(CN_ERRCODE_PASCAL_INVALID_STRING)
                else
                  Inc(P);
              end;
          else
            Break;
          end; // case P^ of

        FStringPtr := P;

        if IsWideStr then
          Result := tokWString
        else
          Result := tokString;
      end; // '#', '''': while True do

    '"':
      begin
        Inc(P);
        while not (P^ in ['"', #0, #10, #13]) do Inc(P);
        Result := tokString;
        if P^ = '"' then  // �͵������ַ���һ���������һ��˫����
          Inc(P);
        FStringPtr := P;
      end;

    '$':
      begin
        Inc(P);
        while P^ in ['0'..'9', 'A'..'F', 'a'..'f'] do
          Inc(P);
        Result := tokInteger;
      end;

    '*':
      begin
        Inc(P);
        Result := tokStar;
      end;

    '{':
      begin
        IgnoreP := P;

        Inc(P);
        { Check Directive sign $}
        if P^ = '$' then
          Result := tokCompDirective
        else
          Result := tokBlockComment;
        while ((P^ <> #0) and (P^ <> '}')) do
        begin
          if P^ = #10 then
          begin
            NewLine;
            FOldSourceColPtr := P;
            Inc(FOldSourceColPtr);
          end;
          Inc(P);
        end;

        if P^ = '}' then
        begin
          // �ж� IgnoreP �� P ֮���Ƿ��� IgnoreFormat ���
          if (Result = tokBlockComment) and (Integer(P) - Integer(IgnoreP) = 3 * SizeOf(Char)) then // 3 means '{(*}'
          begin
            Inc(IgnoreP);
            if IgnoreP^ = '(' then
            begin
              Inc(IgnoreP);
              if IgnoreP^ = '*' then
                InIgnoreArea := True;            // {(*} start to not format
            end
            else if IgnoreP^ = '*' then
            begin
              Inc(IgnoreP);
              if IgnoreP^ = ')' then
                InIgnoreArea := False;           // {*)} end of not format
            end;
          end;

          FBlankLinesAfterComment := 0;
          Inc(P);
          while P^ in [' ', #9] do
            Inc(P);

          if P^ = #13 then
            Inc(P);
          if P^ = #10 then
          begin
            // ASM ģʽ�£�������Ϊ��������������ע���ڴ���������Ҳ����
            if not FASMMode then
            begin
              NewLine;
              Inc(FBlankLinesAfterComment);
              Inc(P);
              FOldSourceColPtr := P;
            end;
          end;
        end
        else
          Error(CN_ERRCODE_PASCAL_ENDCOMMENT_EXP);
      end;

    '/':
      begin
        Inc(P);

        if P^ = '/' then
        begin
          Result := tokLineComment;
          while (P^ <> #0) and (P^ <> #13) and (P^ <> #10) do
            Inc(P); // ����β

          FBlankLinesAfterComment := 0;

          if P^ = #13 then
            Inc(P);
          if P^ = #10 then
          begin
            // ASM ģʽ�£�������Ϊ��������������ע���ڴ���������Ҳ����
            if not FASMMode then
            begin
              NewLine;
              Inc(FBlankLinesAfterComment);
              Inc(P);
              FOldSourceColPtr := P;
            end;
          end
          else
            Error(CN_ERRCODE_PASCAL_ENDCOMMENT_EXP);
        end
        else
          Result := tokDiv;
      end;

    '(':
      begin
        Inc(P);
        Result := tokLB;

        if P^ = '*' then
        begin
          Result := tokBlockComment;

          Inc(P);
          FBlankLinesAfterComment := 0;
          while P^ <> #0 do
          begin
            if P^ = '*' then
            begin
              Inc(P);
              if P^ = ')' then
              begin
                Inc(P);
                while P^ in [' ', #9] do
                  Inc(P);

                if P^ = #13 then
                  Inc(P);
                if P^ = #10 then
                begin
                  // ASM ģʽ�£�������Ϊ��������������ע���ڴ���������Ҳ����
                  if not FASMMode then
                  begin
                    NewLine;
                    Inc(FBlankLinesAfterComment);
                    Inc(P);
                    FOldSourceColPtr := P;
                  end;
                end;

                Break;
              end;
            end
            else
            begin
              if P^ = #10 then
              begin
                NewLine;
                FOldSourceColPtr := P;
                Inc(FOldSourceColPtr);
              end;
              Inc(P);
            end;
          end;
        end;
      end;

    ')':
      begin
        Inc(P);
        Result := tokRB;
      end;

    '[':
      begin
        Inc(P);
        Result := tokSLB;
      end;

    ']':
      begin
        Inc(P);
        Result := tokSRB;
      end;

    '=':
      begin
        Inc(P);
        Result := tokEQUAL;
      end;

    ':':
      begin
        Inc(P);
        if (P^ = '=') then
        begin
          Inc(P);
          Result := tokAssign;
        end else
          Result := tokColon;
      end;
      
    ';':
      begin
        Inc(P);
        Result := tokSemicolon;
      end;

    '.':
      begin
        Inc(P);

        if P^ = '.' then
        begin
          Result := tokRange;
          Inc(P);
        end else
          Result := tokDot;
      end;

    ',':
      begin
        Inc(P);
        Result := tokComma;
      end;

    '>':
      begin
        Inc(P);
        Result := tokGreat;

        // >< ���ǲ����ڣ�ԭ���Ĵ��뽫���жϳɲ������ˣ�ȥ��
        if P^ = '=' then
        begin
          Result := tokGreatOrEqu;
          Inc(P);
        end;
      end;

    '<':
      begin
        Inc(P);
        Result := tokLess;
        
        if P^ = '=' then
        begin
          Result := tokLessOrEqu;
          Inc(P);
        end
        else if P^ = '>' then
        begin
          Result := tokNotEqual;
          Inc(P);
        end;
      end;

    '@':
      begin
        Inc(P);
        Result := tokAtSign;
      end;

    '&':
      begin
        Inc(P);
        Result := tokAmpersand;
      end;
      
    '+', '-':
      begin
        if P^ = '+' then
          Result := tokPlus
        else
          Result := tokMinus;

        Inc(P);
      end;

    '0'..'9':
      begin
        FloatStop := False;
        if FASMMode then
        begin
          Inc(P);
          while P^ in ['0'..'9', 'A'..'F', 'a'..'f', 'H', 'h'] do Inc(P);
          Result := tokAsmHex;
        end
        else
        begin
          Inc(P);
          while P^ in ['0'..'9'] do Inc(P);
          Result := tokInteger;
        end;

        if (P^ = '.') and ((P+1)^ <> '.') then
        begin
          OldP := P;
          Inc(P);
          FloatCount := 0;
          while P^ in ['0'..'9'] do
          begin
            Inc(FloatCount);
            Inc(P);
          end;

          // ��С���㲢��С����������ֲ��� Float
          if FloatCount = 0 then
          begin
            P := OldP;
            FloatStop := True;
          end
          else
            Result := tokFloat;
        end;

        if not FloatStop then // ���� Float �Ͳ��ô�����
        begin
          if P^ in ['e', 'E'] then
          begin
            Inc(P);
            if P^ in ['-', '+'] then
              Inc(P);
            while P^ in ['0'..'9'] do
              Inc(P);
            Result := tokFloat;
          end;

          if (P^ in ['c', 'C', 'd', 'D', 's', 'S']) then
          begin
            Result := tokFloat;
            FFloatType := P^;
            Inc(P);
          end
          else
            FFloatType := #0;
        end;
      end;
    #10:  // ����лس������� #10 Ϊ׼
      begin
        Result := tokCRLF;
        if not FASMMode then // FSourceLine Inc-ed at another place
        begin
          NewLine;
          FOldSourceColPtr := P;
          Inc(FOldSourceColPtr);
        end;
        Inc(P);
      end;
  else
    if P^ = #0 then
      Result := tokEOF
    else
      Result := tokUnknown;

    if Result <> tokEOF then
      Inc(P);
  end;

  FSourcePtr := P;
  FToken := Result;

  Inc(FNewSourceCol, FSourcePtr - FOldSourceColPtr);

{$IFDEF DEBUG}
//  CnDebugger.LogFmt('Line: %5.5d: Col %4.4d. Token: %s. InIgnoreArea %d', [FSourceLine,
//    FSourceCol, TokenString, Integer(InIgnoreArea)]);
{$ENDIF}

  if InIgnoreArea and (FCodeGen <> nil) then
    FCodeGen.WriteBlank(BlankString);

  // FCompDirectiveMode = cdmNone ��ʾ���ԣ��˴�ɶ�����������ͼ�ɨ��ʹ�á�

  if FCompDirectiveMode = cdmAsComment then
  begin
    if Result in [tokBlockComment, tokLineComment, tokCompDirective] then // ��ǰ�� Comment
    begin
      if Assigned(FCodeGen) then
      begin
        if not InIgnoreArea then
        begin
          BlankStr := TrimBlank(BlankString);
          if BlankStr <> '' then
          begin
            FCodeGen.BackSpaceLastSpaces;
            FCodeGen.WriteBlank(BlankStr); // ���ϻ�����β�ͣ�������ע�Ϳ�ͷ�Ŀհײ���д��
          end;
        end;

        S := TokenString;
        // ��дע�ͱ���
        if FASMMode and (Length(S) >= 1) and (S[Length(S)] = #13) then
        begin
          // ע�� ASM �����ע�Ϳ����� #13 ��β����Ҫ����
          Delete(S, Length(S), 1);
          FCodeGen.Write(S);
          FCodeGen.WriteCommentEndln;
        end
        else if (Length(S) >= 2) and (S[Length(S) - 1] = #13) and (S[Length(S)] = #10) then
        begin
          Delete(S, Length(S) - 1, 2);
          FCodeGen.Write(S);
          FCodeGen.WriteCommentEndln;
        end
        else
        begin
          FCodeGen.Write(S);
        end;
      end;

      if not FFirstCommentInBlock then // ��һ������ Comment ʱ�������
      begin
        FFirstCommentInBlock := True;
        FBlankLinesBefore := FBlankLines;
      end;

      FPreviousIsComment := True;
      Result := NextToken;
      // ����ݹ�Ѱ����һ�� Token��
      // ����� FFirstCommentInBlock Ϊ True����˲������¼�¼ FBlankLinesBefore
      FPreviousIsComment := False;
    end
    else
    begin
      // ֻҪ��ǰ���� Comment �����÷ǵ�һ�� Comment �ı��
      FFirstCommentInBlock := False;

      if FPreviousIsComment then // ��һ���� Comment����¼����� ��һ��Comment�Ŀ�����
      begin
        // ���һ��ע�͵��ڵݹ�����㸳ֵ�����FBlankLinesAfter�ᱻ��㸲�ǣ�
        // �������һ��ע�ͺ�Ŀ�����
        FBlankLinesAfter := FBlankLines + FBlankLinesAfterComment;
      end
      else // ��һ������ Comment����ǰҲ���� Comment��ȫ��0
      begin
        FBlankLinesAfter := 0;
        FBlankLinesBefore := 0;
        FBlankLines := 0;
      end;

      if not InIgnoreArea and (FCodeGen <> nil) and
        (FBackwardToken in [tokBlockComment, tokLineComment, tokCompDirective]) then // ��ǰ���� Comment����ǰһ���� Comment
        FCodeGen.Write(BlankString);

      if (Result = tokString) and (Length(TokenString) = 1) then
        Result := tokChar
      else if Result = tokSymbol then
        Result := StringToToken(TokenString);

      FToken := Result;
      FBackwardToken := FToken;
    end;
  end
  else if FCompDirectiveMode = cdmOnlyFirst then
  begin
    if (Result in [tokBlockComment, tokLineComment]) or ((Result = tokCompDirective) and
      (Pos('{$ELSE', UpperCase(TokenString)) = 0) ) then // NOT $ELSE/$ELSEIF
    begin
      if FInDirectiveNestSearch then // In a Nested search for ENDIF/IFEND
        Exit;

      // ��ǰ�� Comment�����ELSE����ָ�����ͨע�ʹ���
      if Assigned(FCodeGen) then
      begin
        if not InIgnoreArea then
        begin
          BlankStr := TrimBlank(BlankString);
          if BlankStr <> '' then
          begin
            FCodeGen.BackSpaceLastSpaces;
            FCodeGen.WriteBlank(BlankStr); // ���ϻ�����β�ͣ�������ע�Ϳ�ͷ�Ŀհײ���д��
          end;
        end;

        S := TokenString;
        // ��дע�ͱ���
        if FASMMode and (Length(S) >= 1) and (S[Length(S)] = #13) then
        begin
          // ע�� ASM �����ע�Ϳ����� #13 ��β����Ҫ����
          Delete(S, Length(S), 1);
          FCodeGen.Write(S);
          FCodeGen.WriteCommentEndln;
        end
        else if (Length(S) >= 2) and (S[Length(S) - 1] = #13) and (S[Length(S)] = #10) then
        begin
          Delete(S, Length(S) - 1, 2);
          FCodeGen.Write(S);
          FCodeGen.WriteCommentEndln;
        end
        else
        begin
          FCodeGen.Write(S);
        end;
      end;

      if not FFirstCommentInBlock then // ��һ������ Comment ʱ�������
      begin
        FFirstCommentInBlock := True;
        FBlankLinesBefore := FBlankLines;
      end;

      FPreviousIsComment := True;
      Result := NextToken;
      // ����ݹ�Ѱ����һ�� Token��
      // ����� FFirstCommentInBlock Ϊ True����˲������¼�¼ FBlankLinesBefore
      FPreviousIsComment := False;
    end
    else if (Result = tokCompDirective) and (Pos('{$ELSE', UpperCase(TokenString)) = 1) then // include ELSEIF
    begin
      // ���������IF/IFEND�����������Բ��ܣ�
      // �����ELSEIF�����Ҷ�Ӧ��IFEND������������֮���
      // ���ҵĹ�����Ҫ�����м�������Ե�IFDEF/IFNDEF/IFOPT��ENDIF�Լ�ͬ����ELSE/ELSEIF

      if FInDirectiveNestSearch then // In a Nested search for ENDIF/IFEND
        Exit;

      if not FFirstCommentInBlock then // ��һ������ Comment ʱ�������
      begin
        FFirstCommentInBlock := True;
        FBlankLinesBefore := FBlankLines;
      end;

      if Assigned(FCodeGen) then
      begin
        if not InIgnoreArea then
          FCodeGen.Write(BlankString);
        FCodeGen.Write(TokenString); // Write ELSE/ELSEIF itself
      end;

      FInDirectiveNestSearch := True;

      DirectiveNest := 1; // 1 means ELSE/ELSEIF itself
      FPreviousIsComment := True;
      Directive := NextToken;
      FPreviousIsComment := False;
      TmpToken := TokenString;

      try
        while Directive <> tokEOF do
        begin
          if Assigned(FCodeGen) then
          begin
            if not InIgnoreArea then
              FCodeGen.Write(BlankString);
            FCodeGen.Write(TmpToken);
          end;

          if Directive = tokCompDirective then
          begin
            if (Pos('{$IFDEF', UpperCase(TmpToken)) = 1) or
              (Pos('{$IFNDEF', UpperCase(TmpToken)) = 1) or
              (Pos('{$IF ', UpperCase(TmpToken)) = 1) or
              (Pos('{$IFOPT', UpperCase(TmpToken)) = 1) then
            begin
              Inc(DirectiveNest);
            end
            else if (Pos('{$ENDIF', UpperCase(TmpToken)) = 1) or
              (Pos('{$IFEND', UpperCase(TmpToken)) = 1) then
            begin
              Dec(DirectiveNest);
              if DirectiveNest = 0 then
              begin
                FInDirectiveNestSearch := False;
                // �Ѿ�˳���ҵ��ˣ�������ԭ�е�����ע�͵Ĺ������һ��Token
                // ������һ������IFDEFʱ�����⡣
                FPreviousIsComment := True;
                Result := NextToken;
                FPreviousIsComment := False;
                Exit;
              end;
            end;
          end;
          FPreviousIsComment := True;
          Directive := NextToken;
          FPreviousIsComment := False;
          TmpToken := TokenString;
        end;
        Result := tokEOF;
        FToken := Result;
      finally
        FInDirectiveNestSearch := False;
      end;
    end
    else
    begin
      // ֻҪ��ǰ���� Comment �����÷ǵ�һ�� Comment �ı��
      FFirstCommentInBlock := False;

      if FPreviousIsComment then // ��һ���� Comment����¼����� ��һ��Comment�Ŀ�����
      begin
        // ���һ��ע�͵��ڵݹ�����㸳ֵ�����FBlankLinesAfter�ᱻ��㸲�ǣ�
        // �������һ��ע�ͺ�Ŀ�����
        FBlankLinesAfter := FBlankLines + FBlankLinesAfterComment;
      end
      else // ��һ������ Comment����ǰҲ���� Comment��ȫ��0
      begin
        FBlankLinesAfter := 0;
        FBlankLinesBefore := 0;
        FBlankLines := 0;
      end;

      if not InIgnoreArea and (FCodeGen <> nil) and
        (FBackwardToken in [tokBlockComment, tokLineComment]) then // ��ǰ���� Comment����ǰһ���� Comment
        FCodeGen.Write(BlankString);

      if (Result = tokString) and (Length(TokenString) = 1) then
        Result := tokChar
      else if Result = tokSymbol then
        Result := StringToToken(TokenString);

      FToken := Result;
      FBackwardToken := FToken;
    end;
  end;
end;

procedure TScaner.OnMoreBlankLinesWhenSkip;
begin
  if FCodeGen <> nil then
    FCodeGen.Writeln;
end;

end.
