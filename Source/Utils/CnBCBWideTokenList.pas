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

{+--------------------------------------------------------------------------+
 | Unit:        mwBCBTokenList
 | Created:     3.98
 | Author:      Martin Waldenburg
 | Copyright    1997, all rights reserved.
 | Description: TLongIntList is a dynamic array of LongInts.
 |              TmsSearcher is a specialized version of the turbo search engine,
 |              which is based on an article in the German magazine c't (8/97).
 |              TCnBCBWideTokenList scans a PChar for BCB tokens and gives full access.
 | Version:     1.0
 | DISCLAIMER:  This is provided as is, expressly without a warranty of any kind.
 |              You use it at your own risc.
 +--------------------------------------------------------------------------+}

 // Modifications/reformatting by Ales Kahanek and Erik Berry (July 2001)

 // Enhancements by Liu Xiao:
 // 1. to Obtain Token Line/Col (2009.04.10)
 // 2. Fix a crash problem when no crlf at file end in comment (2012.10.16)

unit CnBCBWideTokenList;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�mwBCBTokenList �� Unicode �汾ʵ��
* ��Ԫ���ߣ���Х(LiuXiao) liuxiao@cnpack.org
* ��    ע���˵�Ԫ�� mwBCBTokenList ��ֲ��������Ϊ Unicode/WideString ʵ�֣�����ԭʼ��Ȩ����
* ����ƽ̨��Windows 7 + Delphi XE
* ���ݲ��ԣ�PWin9X/2000/XP/7 + Delphi 2009 ~
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2015.04.25 V1.1
*               ���� WideString ʵ��
*           2015.04.09 V1.0
*               ��ֲ��Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

{$R-}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, mwBCBTokenList;

type
{$IFDEF UNICODE}
  CnIndexChar = Char;
  CnWideString = string;
{$ELSE}
  CnIndexChar = AnsiChar;
  CnWideString = WideString;
{$ENDIF}

  TCnBCBWideTokenList = class;

  TCnSearcher = class(Tobject)
  private
    FBCBTokenList: TCnBCBWideTokenList;
    FSearchOrigin: PWideChar;
    Pat: CnWideString;
    FPos: Integer;
    HalfLen: Integer;
    PatLenPlus: Integer;
    SearchLen: Integer;
    Shift: array[0..255] of Integer;
    FFinished: Boolean;
    FFound: Boolean;
    FPosition: Integer;
    FFoundList: TLongIntList;
    function GetFinished: Boolean;
    function GetItems(Index: integer): Integer;
    function GetCount: Integer;
  protected
  public
    ClassList: TLongIntList;
    ImplementationsList: TLongIntList;
    InterfaceList: TLongIntList;
    MethodList: TLongIntList;
    PatLen: Integer;
    constructor Create(Value: TCnBCBWideTokenList);
    destructor Destroy; override;
    function Next: Integer;
    procedure Add(aPosition: Integer);
    procedure FillClassList;
    procedure Init(const NewPattern: CnWideString);
    procedure Retrive(aToken: CnWideString);
    function GetMethodImplementation(const aClassName, aMethodIdentifier: CnWideString): LongInt;
    procedure FillMethodList;
    procedure FillInterfaceList;
    function GetMethodImpLine(const aClassName, aMethodIdentifier: CnWideString): LongInt;
    property Finished: Boolean read GetFinished;
    property Found: Boolean read FFound;
    property Position: Integer read FPosition write FPos;
    property Items[Index: Integer]: Integer read GetItems; default;
    property Count: Integer read GetCount;
  end; { TCnSearcher }

  TCnBCBWideTokenList = class(TObject)
  private
    FTokenPositionsList: TLongIntList;
    FTokenLineNumberList: TLongIntList;
    FTokenColNumberList: TLongIntList;
    FOrigin: PWideChar;
    FPCharSize: Longint;
    FPCharCapacity: Longint;
    FComment: TCommentState;
    FEndCount: Integer;
    FRun: LongInt;
    FRoundCount: Integer;
    FSquareCount: Integer;
    FBraceCount: Integer;
    FLineNumber: Integer;
    FColNumber: Integer;
    FVisibility: TCTokenKind;
    FDirectivesAsComments: Boolean;
    FSupportUnicodeIdent: Boolean;
    procedure WriteTo(InsPos, DelPos: LongInt; const Item: CnWideString);
    function GetCount: Integer;
    procedure SetCount(value: Integer);
    function GetCapacity: Integer;
    procedure ResetPositionsFrom(Index, Value: LongInt);
    function GetIsJunk: Boolean;
    function IdentKind(Index: LongInt): TCTokenKind;
    function DirKind(StartPos, EndPos: LongInt): TCTokenKind;
    procedure SetRunIndex(NewPos: LongInt);
    function GetTokenID(Index: LongInt): TCTokenKind;
    function GetTokenPosition(Index: integer): Longint;
    function GetRunID: TCTokenKind;
    function GetRunPosition: LongInt;
    function GetLineNumber: LongInt;
    function GetColumnNumber: LongInt;
    function GetRunToken: CnWideString;
    function GetTokenAddr: PWideChar;
    function GetTokenLength: Integer;
  protected
    function GetToken(Index: Integer): CnWideString;
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetToken(Index: Integer; const Item: CnWideString);
  public
    Searcher: TCnSearcher;
    constructor Create(SupportUnicodeIdent: Boolean = False);
    destructor Destroy; override;
    procedure SetOrigin(NewOrigin: PWideChar; NewSize: LongInt);
    {* ���ñ����������ݣ�NewSize ���ַ�����}
    function Add(const Item: CnWideString): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    procedure Exchange(Index1, Index2: Integer);
    function First: CnWideString;
    function IndexOf(const Item: CnWideString): Integer;
    procedure Insert(Index: Integer; const Item: CnWideString);
    function Last: CnWideString;
    procedure Move(CurIndex, NewIndex: Integer);
    function Remove(const Item: CnWideString): Integer;
    property Capacity: Integer read GetCapacity write SetCapacity;
    property Count: Integer read GetCount write SetCount;
    property Token[Index: Integer]: CnWideString read GetToken write SetToken; default;
    property TokenPositionsList: TLongIntList read FTokenPositionsList;
    property Origin: PWideChar read FOrigin;
    property PCharSize: Longint read FPCharSize;
    property PCharCapacity: Longint read FPCharCapacity;
    function GetSubString(StartPos, EndPos: LongInt): CnWideString;
    procedure Next;
    procedure Previous;
    procedure NextID(ID: TCTokenKind);
    procedure NextNonComment;
    procedure NextNonJunk;
    procedure NextNonSpace;
    procedure Tokenize;
    procedure ToLineStart;
    procedure PreviousID(ID: TCTokenKind);
    procedure PreviousNonComment;
    procedure PreviousNonJunk;
    procedure PreviousNonSpace;
    function PositionAtLine(aPosition: LongInt): LongInt;
    function IndexAtLine(anIndex: LongInt): LongInt;
    function PositionToIndex(aPosition: LongInt): LongInt;
    property Comments: TCommentState read FComment write FComment;
    property DirectivesAsComments: Boolean read FDirectivesAsComments write FDirectivesAsComments;
    property EndCount: Integer read FEndCount write FEndCount;
    property IsJunk: Boolean read GetIsJunk;
    property RunIndex: LongInt read FRun write SetRunIndex;
    property BraceCount: Integer read FBraceCount write FBraceCount;
    property RoundCount: Integer read FRoundCount write FRoundCount;
    property SquareCount: Integer read FSquareCount write FSquareCount;
    property Visibility: TCTokenKind read FVisibility write FVisibility;
    property TokenID[Index: LongInt]: TCTokenKind read GetTokenID;
    property TokenPosition[Index: LongInt]: LongInt read GetTokenPosition;

    property RunPosition: LongInt read GetRunPosition;

    property RunID: TCTokenKind read GetRunID;
    {* ��ǰ Token ����}
    property LineNumber: Integer read GetLineNumber;
    {* ��ǰ Token ���ڵ��У�1 ��ʼ}
    property ColumnNumber: Integer read GetColumnNumber;
    {* ��ǰ Token ���ڵ��У�1 ��ʼ}
    property RunToken: CnWideString read GetRunToken;
    {* ��ǰ Token �� Unicode �ַ���}
    property TokenAddr: PWideChar read GetTokenAddr;
    {* ��ǰ Token �� Unicode �ַ�����ַ}
    property TokenLength: Integer read GetTokenLength;
    {* ��ǰ Token �� Unicode �ַ�����}
  end; { TCnBCBWideTokenList }

implementation

type
  TAnsiCharSet = set of AnsiChar;

function _WideCharInSet(C: WideChar; CharSet: TAnsiCharSet): Boolean; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
begin
  if Ord(C) <= $FF then
    Result := AnsiChar(C) in CharSet
  else
    Result := False;
end;

function _AnsiStrIComp(S1, S2: PWideChar): Integer; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
begin
  Result := CompareStringW(LOCALE_USER_DEFAULT, NORM_IGNORECASE, S1, -1,
    S2, -1) - 2;
end;

function _IndexChar(C: WideChar): CnIndexChar; {$IFDEF SUPPORTS_INLINE} inline; {$ENDIF}
begin
{$IFDEF UNICODE}
  Result := C;
{$ELSE}
  Result := CnIndexChar(C);
{$ENDIF}
end;

function _StrEWideCopy(Dest: PWideChar; const Source: PWideChar): PWideChar;
var
  Len: Integer;
{$IFNDEF UNICODE}
  S: CnWideString;
{$ENDIF}
begin
{$IFDEF UNICODE}
  Len := StrLen(Source);
{$ELSE}
  S := Source;
  Len := Length(S);
{$ENDIF}
  Move(Source^, Dest^, (Len + 1) * SizeOf(WideChar));
  Result := Dest + Len;
end;

constructor TCnSearcher.Create(Value: TCnBCBWideTokenList);
begin
  inherited Create;
  FBCBTokenList := Value;
  Pat := '';
  PatLen := 0;
  HalfLen := 0;
  SearchLen := 0;
  FPos := -1;
  FFound := False;
  FFoundList := TLongIntList.Create;
  ClassList := TLongIntList.Create;
  ImplementationsList := TLongIntList.Create;
  InterfaceList := TLongIntList.Create;
  MethodList := TLongIntList.Create;
end; { Create }

destructor TCnSearcher.Destroy;
begin
  FFoundList.Free;
  ClassList.Free;
  ImplementationsList.Free;
  InterfaceList.Free;
  MethodList.Free;
  inherited Destroy;
end; { Destroy }

function TCnSearcher.GetFinished: Boolean;
begin
  FFinished := False;
  if FPos >= SearchLen - 1 then FFinished := True;
  if PatLen > SearchLen then FFinished := True;
  Result := FFinished;
end; { GetFinished }

procedure TCnSearcher.Init(const NewPattern: CnWideString);
var
  I: Byte;
begin
  FFoundList.Clear;
  SearchLen := FBCBTokenList.PCharSize;
  FSearchOrigin := FBCBTokenList.Origin;
  Pat := NewPattern;
  PatLen := Length(Pat);
  PatLenPlus := PatLen + 1;
  HalfLen := PatLen div 2;
  for I := 0 to 255 do Shift[I] := PatLenPlus;
  for I := 1 to PatLen do Shift[ord(Pat[I])] := PatLenPlus - I;
  FPos := -1;
end; { Init }

function TCnSearcher.Next: Integer;
var
  I, J: Integer;
begin
  Result := -1;
  FFound := False;
  Inc(FPos, PatLen);
  FPosition := -1;
  while FPos <= SearchLen do
  begin
    I := PatLen;
    if (Pat[I] <> FSearchOrigin[FPos]) then
      Inc(FPos, Shift[Ord(FSearchOrigin[FPos + 1])])
    else
    begin
      J := FPos;
      repeat
        Dec(I); Dec(J);
      until (I = 0) or (Pat[I] <> FSearchOrigin[J]);
      if I = 0 then
      begin
        FFound := True;
        FPosition := FPos - Patlen + 1;
        Result := FPosition;
        Break;
      end else if I < HalfLen then Inc(FPos, PatLenPlus)
      else Inc(FPos, Shift[ord(FSearchOrigin[J + 1])]);
    end;
  end;
end; { Next }

function TCnSearcher.GetItems(Index: integer): Integer;
begin
  if (Index >= FFoundList.Count) or (Index < 0) then Result := -1 else
    Result := FFoundList[Index];
end; { GetItems }

function TCnSearcher.GetCount: Integer;
begin
  Result := FFoundList.Count;
end; { GetCount }

procedure TCnSearcher.Add(aPosition: Integer);
begin
  FFoundList.Add(aPosition);
end; { Add }

procedure TCnSearcher.FillClassList;
//var
//  RPos: LongInt;
//  RIndex: LongInt;
begin
  Assert(False);
end; { FillClassList }

procedure TCnSearcher.FillInterfaceList;
//var
//  RPos: LongInt;
//  RIndex: LongInt;
begin
  Assert(False);
end; { FillInterfaceList }

procedure TCnSearcher.FillMethodList;
//var
//  RPos: LongInt;
//  RIndex: LongInt;
begin
  Assert(False);
end; { FillMethodList }

procedure TCnSearcher.Retrive(aToken: CnWideString);
var
  RPos: LongInt;
  RIndex: LongInt;
begin
  Init(aToken);
  while not Finished do
  begin
    RPos := Next;
    if RPos <> -1 then
    begin
      RIndex := FBCBTokenList.PositionToIndex(RPos);
      if (RPos = FBCBTokenList.FTokenPositionsList[RIndex]) then
        if _AnsiStrIComp(PWideChar(aToken), PWideChar(FBCBTokenList[RIndex])) = 0 then Add(RIndex);
    end;
  end;
end; { Retrive }

function TCnSearcher.GetMethodImplementation(const aClassName, aMethodIdentifier: CnWideString): LongInt;
//var
//  RPos: LongInt;
//  RIndex: LongInt;
//  ToFind: AnsiString;
//  Found: Boolean;
begin
  Assert(False);
  Result := 0;
end; { GetMethodImplementation }

function TCnSearcher.GetMethodImpLine(const aClassName, aMethodIdentifier: CnWideString): LongInt;
var
  ImpIndex: LongInt;
begin
  ImpIndex := GetMethodImplementation(aClassName, aMethodIdentifier);
  Result := FBCBTokenList.IndexAtLine(ImpIndex);
end; { GetMethodImpLine }

constructor TCnBCBWideTokenList.Create(SupportUnicodeIdent: Boolean);
begin
  inherited Create;
  FTokenPositionsList := TLongIntList.Create;
  FTokenLineNumberList := TLongIntList.Create;
  FTokenColNumberList := TLongIntList.Create;
  FTokenPositionsList.Add(0);
  FTokenLineNumberList.Add(0);
  FTokenColNumberList.Add(0);
  FComment := csNo;
  FEndCount := 0;
  Visibility := ctkUnknown;
  Searcher := TCnSearcher.Create(Self);
  FDirectivesAsComments := True;
  FSupportUnicodeIdent := SupportUnicodeIdent;
end; { Create }

destructor TCnBCBWideTokenList.Destroy;
begin
  FTokenPositionsList.Free;
  FTokenLineNumberList.Free;
  FTokenColNumberList.Free;
  Searcher.Free;
  inherited Destroy;
end; { Destroy }

procedure TCnBCBWideTokenList.SetOrigin(NewOrigin: PWideChar; NewSize: LongInt);
begin
  FOrigin := NewOrigin;
  FRun := 0;
  FPCharSize := NewSize;
  FPCharCapacity := FPCharSize;
  FLineNumber := 0;
  FColNumber := 0;
  Tokenize;
  FRun := 0;
  //Searcher.FillClassList;
  FRoundCount := 0;
  FSquareCount := 0;
end; { SetOrigin }

procedure TCnBCBWideTokenList.WriteTo(InsPos, DelPos: LongInt;
  const Item: CnWideString);
var
  StringCount, NewSize: Longint;
  aString: CnWideString;
begin
  aString := Item + (FOrigin + DelPos);
  StringCount := Length(aString);
  if (InsPos >= 0) and (StringCount >= 0) then
  begin
    NewSize := InsPos + StringCount;
    if NewSize > 0 then
    begin
      if NewSize >= FPCharCapacity then
      begin
        try
          FPCharCapacity := FPCharCapacity + 16384;
          ReAllocMem(FOrigin, PCharCapacity * SizeOf(WideChar));
        except
          raise exception.Create('unable to reallocate PChar');
        end;
      end;
      _StrEWideCopy((FOrigin + InsPos), PWideChar(aString));
      FPCharSize := NewSize;
      FOrigin[FPCharSize] := #0;
      aString := '';
    end;
  end;
end; { WriteTo }

function TCnBCBWideTokenList.GetCount: Integer;
begin
  Result := FTokenPositionsList.Count - 1;
end; { GetCount }

procedure TCnBCBWideTokenList.SetCount(value: Integer);
begin
  FTokenPositionsList.Count := Value + 1;
end; { SetCount }

function TCnBCBWideTokenList.GetCapacity: Integer;
begin
  Result := FTokenPositionsList.Capacity;
end; { GetCapacity }

procedure TCnBCBWideTokenList.ResetPositionsFrom(Index, Value: LongInt);
begin
  while Index < FTokenPositionsList.Count do
  begin
    FTokenPositionsList[Index] := FTokenPositionsList[Index] + Value;
    Inc(Index);
  end
end; { ResetPositionsFrom }

function TCnBCBWideTokenList.GetToken(Index: Integer): CnWideString;
var
  StartPos, EndPos, StringLen: LongInt;
begin
  StartPos := FTokenPositionsList[Index];
  EndPos := FTokenPositionsList[Index + 1];
  StringLen := EndPos - StartPos;
  SetString(Result, (FOrigin + StartPos), StringLen);
end; { GetToken }

function TCnBCBWideTokenList.GetTokenPosition(Index: integer): Longint;
begin
  Result := FTokenPositionsList[Index];
end; { GetTokenPosition }

procedure TCnBCBWideTokenList.SetCapacity(NewCapacity: Integer);
begin
  FTokenPositionsList.Capacity := NewCapacity;
end; { SetCapacity }

procedure TCnBCBWideTokenList.SetToken(Index: Integer; const Item: CnWideString);
var
  StartPos, EndPos, OldLen, NewLen, Diff: LongInt;
begin
  StartPos := FTokenPositionsList[Index];
  EndPos := FTokenPositionsList[Index + 1];
  OldLen := EndPos - StartPos;
  NewLen := Length(Item);
  Diff := NewLen - OldLen;
  WriteTo(StartPos, EndPos, Item);
  ResetPositionsFrom(Index + 1, Diff);
end; { SetItems }

function TCnBCBWideTokenList.Add(const Item: CnWideString): Integer;
var
  StartPos, EndPos: LongInt;
begin
  Result := Count;
  StartPos := FTokenPositionsList[Result];
  EndPos := StartPos + Length(Item);
  FTokenPositionsList.Add(EndPos);
  WriteTo(StartPos, StartPos, Item);
end; { Add }

procedure TCnBCBWideTokenList.Clear;
begin
  SetCount(0);
  FTokenPositionsList.Capacity := 1;
  FRun := 0;
end; { Clear }

procedure TCnBCBWideTokenList.Delete(Index: Integer);
var
  StartPos, EndPos, OldLen: LongInt;
begin
  StartPos := FTokenPositionsList[Index];
  EndPos := FTokenPositionsList[Index + 1];
  OldLen := EndPos - StartPos;
  WriteTo(StartPos, EndPos, '');
  FTokenPositionsList.Delete(Index);
  ResetPositionsFrom(Index, -OldLen);
end; { Delete }

procedure TCnBCBWideTokenList.Exchange(Index1, Index2: Integer);
var
  Item: CnWideString;
begin
  Item := GetToken(Index1);
  SetToken(Index1, GetToken(Index2));
  SetToken(Index2, Item);
end; { Exchange }

function TCnBCBWideTokenList.First: CnWideString;
begin
  Result := GetToken(0);
end; { First }

function TCnBCBWideTokenList.IndexOf(const Item: CnWideString): Integer;
begin
  Result := 0;
  while (Result < Count) and (GetToken(Result) <> Item) do Inc(Result);
  if Result = Count then Result := -1;
end; { IndexOf }

procedure TCnBCBWideTokenList.Insert(Index: Integer; const Item: CnWideString);
var
  StartPos, EndPos, ItemLen: LongInt;
begin
  ItemLen := Length(Item);
  StartPos := FTokenPositionsList[Index];
  EndPos := StartPos + ItemLen;
  WriteTo(StartPos, StartPos, Item);
  ResetPositionsFrom(Index + 1, ItemLen);
  FTokenPositionsList.Insert(Index + 1, EndPos);
end; { Insert }

function TCnBCBWideTokenList.Last: CnWideString;
begin
  Result := GetToken(Count - 1);
end; { Last }

procedure TCnBCBWideTokenList.Move(CurIndex, NewIndex: Integer);
var
  Item: CnWideString;
begin
  if CurIndex <> NewIndex then
  begin
    Item := GetToken(CurIndex);
    Delete(CurIndex);
    Insert(NewIndex, Item);
  end;
end; { Move }

function TCnBCBWideTokenList.Remove(const Item: CnWideString): Integer;
begin
  Result := IndexOf(Item);
  if Result <> -1 then Delete(Result);
end; { Remove }

function TCnBCBWideTokenList.GetSubString(StartPos, EndPos: LongInt): CnWideString;
var
  SubLen: Integer;
begin
  if FOrigin[EndPos] = #10 then Inc(EndPos);
  SubLen := EndPos - StartPos;
  SetString(Result, (FOrigin + StartPos), SubLen);
end; { GetSubString }

procedure TCnBCBWideTokenList.SetRunIndex(NewPos: LongInt);
begin
  FRun := NewPos;
end; { SetRunPos }

function TCnBCBWideTokenList.IdentKind(Index: LongInt): TCTokenKind;
var
  HashKey: Integer;
  aToken: CnWideString;
  StartPos, EndPos, StringLen: LongInt;

  function KeyHash: Integer;
  var
    I: Integer;
  begin
    Result := 0;
    for I := 1 to StringLen do
      Result := Result + Ord(aToken[I]);
  end; { KeyHash }

begin
  Result := ctkIdentifier;
  StartPos := FTokenPositionsList[Index];
  EndPos := FTokenPositionsList[Index + 1];
  StringLen := EndPos - StartPos;
  SetString(aToken, (FOrigin + StartPos), StringLen);
  HashKey := KeyHash;
  case HashKey of
    207: if aToken = 'if' then Result := ctkif;
    211: if aToken = 'do' then Result := ctkdo;
    321: if aToken = 'asm' then Result := ctkasm;
    327: if aToken = 'for' then Result := ctkfor;
    330: if aToken = 'new' then Result := ctknew;
    331: if aToken = 'int' then Result := ctkint;
    351: if aToken = 'try' then Result := ctktry;
    412: if aToken = 'case' then Result := ctkcase;
    414: if aToken = 'char' then Result := ctkchar;
    416: if aToken = '_asm' then Result := ctk_asm;
    425: if aToken = 'else' then Result := ctkelse;
    428: if aToken = 'bool' then Result := ctkbool;
    432: if aToken = 'long' then Result := ctklong;
    434: if aToken = 'void' then Result := ctkvoid;
    437: if aToken = 'enum' then Result := ctkenum;
    440: if aToken = 'this' then Result := ctkthis;
    441:
      begin
        if aToken = 'auto' then Result := ctkauto else
          if aToken = 'goto' then Result := ctkgoto;
      end;
    448: if aToken = 'true' then Result := ctktrue;
    507: if aToken = 'cdecl' then Result := ctkcdecl;
    511: if aToken = '__asm' then Result := ctk__asm;
    515: if aToken = 'catch' then Result := ctkcatch;
    517: if aToken = 'break' then Result := ctkbreak;
    523: if aToken = 'false' then Result := ctkfalse;
    534:
      begin
        if aToken = 'float' then Result := ctkfloat else
          if aToken = 'class' then Result := ctkclass;
      end;
    537: if aToken = 'while' then Result := ctkwhile;
    538: if aToken = '_M_IX86' then Result := ctk_M_IX86;
    541:
      begin
        if aToken = '__MT__' then Result := ctk__MT__ else
          if aToken = '__try' then Result := ctk__try;
      end;
    550: if aToken = 'using' then Result := ctkusing;
    551: if aToken = 'const' then Result := ctkconst;
    553: if aToken = 'union' then Result := ctkunion;
    560: if aToken = 'short' then Result := ctkshort;
    564: if aToken = 'throw' then Result := ctkthrow;
    577: if aToken = '__int8' then Result := ctk__int8;
    600: if aToken = '__DLL__' then Result := ctk__DLL__;
    602: if aToken = '_cdecl' then Result := ctk_cdecl;
    622: if aToken = '__int32' then Result := ctk__int32;
    623: if aToken = '__TLS__' then Result := ctk__TLS__;
    624: if aToken = '__int16' then Result := ctk__int16;
    627:
      begin
        if aToken = 'delete' then Result := ctkdelete else
          if aToken = '__int64' then Result := ctk__int64;
      end;
    628: if aToken = 'pascal' then Result := ctkpascal;
    632: if aToken = 'friend' then Result := ctkfriend;
    634: if aToken = 'signed' then Result := ctksigned;
    635: if aToken = 'double' then Result := ctkdouble;
    639:
      begin
        if aToken = 'public' then Result := ctkpublic else
          if aToken = 'inline' then Result := ctkinline;
      end;
    641: if aToken = '__rtti' then Result := ctk__rtti;
    647: if aToken = '_WCHAR_T' then Result := ctk_WCHAR_T;
    648: if aToken = 'static' then Result := ctkstatic;
    655: if aToken = 'typeid' then Result := ctktypeid;
    656: if aToken = 'sizeof' then Result := ctksizeof;
    658: if aToken = 'switch' then Result := ctkswitch;
    662: if aToken = 'extern' then Result := ctkextern;
    666: if aToken = '__DATE__' then Result := ctk__DATE__;
    668: if aToken = '__FILE__' then Result := ctk__FILE__;
    672: if aToken = 'return' then Result := ctkreturn;
    676: if aToken = '__LINE__' then Result := ctk__LINE__;
    677: if aToken = 'struct' then Result := ctkstruct;
    682: if aToken = '__STDC__' then Result := ctk__STDC__;
    683: if aToken = '__TIME__' then Result := ctk__TIME__;
    697: if aToken = '__cdecl' then Result := ctk__cdecl;
    719: if aToken = '__WIN32__' then Result := ctk__WIN32__;
    723: if aToken = '_pascal' then Result := ctk_pascal;
    727: if aToken = '__CDECL__' then Result := ctk__CDECL__;
    741: if aToken = 'default' then Result := ctkdefault;
    744: if aToken = 'wchar_t' then Result := ctkwchar_t;
    746: if aToken = 'mutable' then Result := ctkmutable;
    753: if aToken = 'typedef' then Result := ctktypedef;
    756: if aToken = '__BCOPT__' then Result := ctk__BCOPT__;
    762: if aToken = '_import' then Result := ctk_import;
    763: if aToken = 'private' then Result := ctkprivate;
    769: if aToken = '_export' then Result := ctk_export;
    770: if aToken = '__MSDOS__' then Result := ctk__MSDOS__;
    775: if aToken = 'virtual' then Result := ctkvirtual;
    791: if aToken = '_CPPUNWIND' then Result := ctk_CPPUNWIND;
    816: if aToken = '__PASCAL__' then Result := ctk__PASCAL__;
    818: if aToken = '__pascal' then Result := ctk__pascal;
    822: if aToken = '__thread' then Result := ctk__thread;
    827: if aToken = '__dispid' then Result := ctk__dispid;
    838: if aToken = '_stdcall' then Result := ctk_stdcall;
    839: if aToken = '__except' then Result := ctk__except;
    842: if aToken = '_Windows' then Result := ctk_Windows;
    843: if aToken = '__TURBOC__' then Result := ctk__TURBOC__;
    857: if aToken = '__import' then Result := ctk__import;
    860: if aToken = 'template' then Result := ctktemplate;
    861: if aToken = 'unsigned' then Result := ctkunsigned;
    864:
      begin
        if aToken = 'volatile' then Result := ctkvolatile else
          if aToken = '__export' then Result := ctk__export;
      end;
    866: if aToken = 'explicit' then Result := ctkexplicit;
    867: if aToken = 'typename' then Result := ctktypename;
    869:
      begin
        if aToken = 'continue' then Result := ctkcontinue else
          if aToken = 'register' then Result := ctkregister;
      end;
    876: if aToken = 'operator' then Result := ctkoperator;
    911: if aToken = '__CONSOLE__' then Result := ctk__CONSOLE__;
    929: if aToken = '__classid' then Result := ctk__classid;
    933: if aToken = '__stdcall' then Result := ctk__stdcall;
    937: if aToken = '_fastcall' then Result := ctk_fastcall;
    941:
      begin
        if aToken = 'namespace' then Result := ctknamespace else
          if aToken = '__finally' then Result := ctk__finally;
      end;
    955: if aToken = '__closure' then Result := ctk__closure;
    961: if aToken = '__BORLANDC__' then Result := ctk__BORLANDC__;
    970: if aToken = 'protected' then Result := ctkprotected;
    1025: if aToken = '__declspec' then Result := ctk__declspec;
    1032: if aToken = '__fastcall' then Result := ctk__fastcall;
    1067: if aToken = '__TEMPLATES__' then Result := ctk__TEMPLATES__;
    1073: if aToken = 'const_cast' then Result := ctkconst_cast;
    1081: if aToken = '_CHAR_UNSIGNED' then Result := ctk_CHAR_UNSIGNED;
    1091: if aToken = '__property' then Result := ctk__property;
    1150: if aToken = '__published' then Result := ctk__published;
    1154: if aToken = '__automated' then Result := ctk__automated;
    1161: if aToken = '__BCPLUSPLUS__' then Result := ctk__BCPLUSPLUS__;
    1170: if aToken = 'static_cast' then Result := ctkstatic_cast;
    1179: if aToken = '__TCPLUSPLUS__' then Result := ctk__TCPLUSPLUS__;
    1193: if aToken = '__cplusplus' then Result := ctk__cplusplus;
    1237: if aToken = '_WCHAR_T_DEFINED' then Result := ctk_WCHAR_T_DEFINED;
    1263: if aToken = 'dynamic_cast' then Result := ctkdynamic_cast;
    1726: if aToken = 'reinterpret_cast' then Result := ctkreinterpret_cast;
  end;
end; { IdentKind }

function TCnBCBWideTokenList.DirKind(StartPos, EndPos: LongInt): TCTokenKind;
var
  HashKey: Integer;
  aToken: CnWideString;
  StringLen: LongInt;

  function KeyHash: Integer;
  var
    I: Integer;
  begin
    Result := 0;
    for I := 1 to StringLen do
      Result := Result + Ord(aToken[I]);
  end; { KeyHash }

begin
  Result := ctkunknown;
  StringLen := EndPos - StartPos;
  SetString(aToken, (FOrigin + StartPos), StringLen);
  HashKey := KeyHash;
  case HashKey of
    207: if aToken = 'if' then Result := ctkdirif;
    416: if aToken = 'elif' then Result := ctkdirelif;
    424: if aToken = 'line' then Result := ctkdirline;
    425: if aToken = 'else' then Result := ctkdirelse;
    510: if aToken = 'ifdef' then Result := ctkdirifdef;
    518: if aToken = 'endif' then Result := ctkdirendif;
    530: if aToken = 'undef' then Result := ctkdirundef;
    554: if aToken = 'error' then Result := ctkdirerror;
    619: if aToken = 'define' then Result := ctkdirdefine;
    620: if aToken = 'ifndef' then Result := ctkdirifndef;
    632: if aToken = 'pragma' then Result := ctkdirpragma;
    740: if aToken = 'include' then Result := ctkdirinclude;
  end;
end; { IdentKind }

procedure TCnBCBWideTokenList.Tokenize;
var
  BackSlashCount, LineNum, ColNum: Integer;

  procedure StepRun;
  begin
    if Ord(FOrigin[FRun]) > $900 then // �жϿ��ֽ��ַ���ȣ����ռ����
      Inc(ColNum, 2)
    else // С�Ĳ���ֻռһ��
      Inc(ColNum);
    Inc(FRun);
  end;

  procedure HandleComments;
  begin
    case FComment of
      csAnsi:
        begin
          while FOrigin[FRun] <> #0 do
          begin
            case FOrigin[FRun] of
              '*': if FOrigin[FRun + 1] = '/' then
                begin
                  Inc(FRun); Inc(ColNum);
                  FComment := csNo;
                  Break;
                end;
              #13:
                begin
                  if FOrigin[FRun + 1] = #10 then
                    Inc(FRun);
                  Inc(LineNum);
                  ColNum := 0; // �ú��ĵ� Inc ������ 1
                end;
              #10:
                begin
                  if FOrigin[FRun + 1] = #13 then // #10#13 IDE Ҳ����Ϊ��һ�����з�
                    Inc(FRun);
                  Inc(LineNum);
                  ColNum := 0; // �ú��ĵ� Inc ������ 1
                end;
            end;
            StepRun;
          end;
        end;

      csSlashes:
        begin
          while FOrigin[FRun] <> #0 do
          begin
            Inc(FRun); Inc(ColNum);
            case FOrigin[FRun] of
              #0, #10, #13:
                begin
                  //if FOrigin[Run +1] = #10 then Inc(Run); //do not Inc(Run),it causes skipping the tkcCrlf token at the end of comment line
                  if FOrigin[FRun] = #10 then
                  begin
                    ColNum := 0; // �ú��ı�� 1
                    Inc(LineNum);
                    if FOrigin[FRun + 1] = #13 then
                      Inc(FRun);
                  end
                  else if FOrigin[FRun] = #13 then   // #13, #10, #13#10, #10#13���ᱻ��Ϊ��һ���س�
                  begin
                    if FOrigin[FRun + 1] = #10 then
                      Inc(FRun);
                    ColNum := 0; // �ú��ı�� 1
                    Inc(LineNum);
                  end;
                  FComment := csNo;
                  Break;
                end;
            end;
          end;
        end;
    end;
  end; { HandleComments }

begin
  BackSlashCount := 0;
  Clear;
  LineNum := 1;
  ColNum := 1;
  while FOrigin[FRun] <> #0 do
  begin
    case FOrigin[FRun] of
      #10:
        begin
          if FOrigin[FRun + 1] = #13 then Inc(FRun, 2) else Inc(FRun);
          FTokenPositionsList.Add(FRun);
          Inc(LineNum);
          FTokenLineNumberList.Add(LineNum);
          ColNum := 1;
          FTokenColNumberList.Add(ColNum);
        end;

      #13:
        begin
          if FOrigin[FRun + 1] = #10 then Inc(FRun, 2) else Inc(FRun);
          FTokenPositionsList.Add(FRun);
          Inc(LineNum);
          FTokenLineNumberList.Add(LineNum);
          ColNum := 1;
          FTokenColNumberList.Add(ColNum);
        end;

      #1..#9, #11, #12, #14..#32:
        begin
          Inc(FRun); Inc(ColNum);
          while _WideCharInSet(FOrigin[FRun], [#1..#9, #11, #12, #14..#32]) do
          begin
            Inc(FRun);
            Inc(ColNum);
          end;
          FTokenPositionsList.Add(FRun);
          FTokenLineNumberList.Add(LineNum);
          FTokenColNumberList.Add(ColNum);
        end;

      'A'..'Z', 'a'..'z', '_', '~':
        begin
          Inc(FRun); Inc(ColNum);
          while _WideCharInSet(FOrigin[FRun], ['A'..'Z', 'a'..'z', '0'..'9', '_'])
            or (FSupportUnicodeIdent and (Ord(FOrigin[FRun]) > 127)) do
          begin
            Inc(FRun);
            Inc(ColNum);
          end;
          FTokenPositionsList.Add(FRun);
          FTokenLineNumberList.Add(LineNum);
          FTokenColNumberList.Add(ColNum);
        end;

      '0'..'9':
        begin
          Inc(FRun); Inc(ColNum);
          while _WideCharInSet(FOrigin[FRun], ['0'..'9', '.', 'e', 'E']) do
          begin
            case FOrigin[FRun] of
              '.':
                if FOrigin[FRun + 1] = '.' then Break;
            end;
            Inc(FRun);
            Inc(ColNum);
          end;
          FTokenPositionsList.Add(FRun);
          FTokenLineNumberList.Add(LineNum);
          FTokenColNumberList.Add(ColNum);
        end;

      '!'..'#', '%', '&', '('..'/', ':'..'@', '['..'^', '`', '{'..'}':
        begin
          case FOrigin[FRun] of

            '!':
              case FOrigin[FRun + 1] of
                '=':
                  begin
                    Inc(FRun);
                    Inc(ColNum);
                  end;
              end;

            '"':
              begin
                repeat
                  if FOrigin[FRun] = '\' then
                    Inc(BackSlashCount)
                  else
                    BackSlashCount := 0;
                  case FOrigin[FRun] of
                    #13:
                      begin
                        Inc(FRun);
                        if FOrigin[FRun] = #10 then
                        begin
                          Inc(FRun);
                          Inc(LineNum);
                          ColNum := -1; // �����ļ� 1 ������
                        end;
                      end;
                    #10:
                      begin
                        Inc(FRun);
                        if FOrigin[FRun] = #13 then
                        begin
                          Inc(FRun);
                          Inc(LineNum);
                          ColNum := -1; // �����ļ� 1 ������
                        end;
                      end;
                    #0: Break;
                  end;
                  StepRun;
                until ((FOrigin[FRun] = '"') and not Odd(BackSlashCount));
              end; //do not treat \" or \\\" etc. as the end of string, this is escape sequence

            '#':
              case FOrigin[FRun + 1] of
                '#': begin Inc(FRun); Inc(ColNum); end;
                'A'..'Z', 'a'..'z':
                  if FDirectivesAsComments then
                  begin
                    Inc(FRun);
                    Inc(ColNum);
                    repeat
                      Inc(FRun);
                      Inc(ColNum);
                      if (FOrigin[FRun] = '\') then
                      begin
                        while not _WideCharInSet(FOrigin[FRun + 1], [#10, #13, #0]) do
                        begin
                          Inc(FRun);
                          Inc(ColNum);
                        end;
                        if FOrigin[FRun + 1] = #13 then
                          Inc(FRun);
                        if FOrigin[FRun + 1] = #10 then
                        begin
                          Inc(LineNum);
                          ColNum := -1; // �ú��ļ�һ������
                        end;
                        Inc(FRun);
                        Inc(ColNum);
                      end;
                    until _WideCharInSet(FOrigin[FRun + 1], [#10, #13, #0]);

                    if FOrigin[FRun + 1] = #13 then
                      Inc(FRun);
                    if FOrigin[FRun + 1] = #10 then
                    begin
                      Inc(LineNum);
                      ColNum := -1;
                    end;
                    Inc(FRun);
                    Inc(ColNum, 1);
                  end
                  else
                  begin
                    Inc(FRun);
                    Inc(ColNum);
                    while _WideCharInSet(FOrigin[FRun], ['A'..'Z', 'a'..'z']) do
                    begin
                      Inc(FRun);
                      Inc(ColNum);
                    end;
                    Dec(FRun);
                    Dec(ColNum);
                  end;
              end;

            '%':
              case FOrigin[FRun + 1] of
                '=':
                  begin
                    Inc(FRun);
                    Inc(ColNum);
                  end;
              end;

            '&':
              case FOrigin[FRun + 1] of
                '=', '&': begin Inc(FRun); Inc(ColNum); end;
              end;

            '(':
              case FOrigin[FRun + 1] of
                ')': begin Inc(FRun); Inc(ColNum); end;
              end;

            '*':
              case FOrigin[FRun + 1] of
                '*', '/', '=': begin Inc(FRun); Inc(ColNum); end;
              end;

            '+':
              case FOrigin[FRun + 1] of
                '+', '=': begin Inc(FRun); Inc(ColNum); end;
              end;

            '-':
              case FOrigin[FRun + 1] of
                '-', '=': begin Inc(FRun); Inc(ColNum); end;
                '>':
                  case FOrigin[FRun + 2] of
                    '*': Inc(FRun, 2);
                  else begin Inc(FRun); Inc(ColNum); end;
                  end;
              end;

            '.':
              case FOrigin[FRun + 1] of
                '*': begin Inc(FRun); Inc(ColNum); end;
                '.':
                  case FOrigin[FRun + 2] of
                    '.': begin Inc(FRun, 2); Inc(ColNum, 2); end;
                  else begin Inc(FRun); Inc(ColNum); end;
                  end;
              end;

            '/':
              case FOrigin[FRun + 1] of
                '*':
                  begin
                    FComment := csAnsi;
                    HandleComments;
                  end;
                '/':
                  begin
                    FComment := csSlashes;
                    HandleComments;
                  end;
              end;

            ':':
              case FOrigin[FRun + 1] of
                ':': begin Inc(FRun); Inc(ColNum); end;
              end;

            '<':
              case FOrigin[FRun + 1] of
                '=': begin Inc(FRun); Inc(ColNum); end;
                '<':
                  case FOrigin[FRun + 2] of
                    '=': begin Inc(FRun, 2); Inc(ColNum, 2); end;
                  else begin Inc(FRun); Inc(ColNum); end;
                  end;
              end;

            '=':
              case FOrigin[FRun + 1] of
                '=': begin Inc(FRun); Inc(ColNum); end;
              end;

            '>':
              case FOrigin[FRun + 1] of
                '=': begin Inc(FRun); Inc(ColNum); end;
                '>':
                  case FOrigin[FRun + 2] of
                    '=': begin Inc(FRun, 2); Inc(ColNum, 2); end;
                  else begin Inc(FRun); Inc(ColNum); end;
                  end;
              end;

            '?':
              case FOrigin[FRun + 1] of
                ':': begin Inc(FRun); Inc(ColNum); end;
              end;

            '[':
              case FOrigin[FRun + 1] of
                ']': begin Inc(FRun); Inc(ColNum); end;
              end;

            '^':
              case FOrigin[FRun + 1] of
                '=': begin Inc(FRun);  Inc(ColNum); end;
              end;

            '{':
              case FOrigin[FRun + 1] of
                '}': begin Inc(FRun); Inc(ColNum); end;
              end;

            '|':
              case FOrigin[FRun + 1] of
                '=', '|': begin Inc(FRun); Inc(ColNum); end;
              end;

            '\':
              case FOrigin[FRun + 1] of
                #13:
                  begin
                    Inc(FRun);
                    if FOrigin[FRun + 1] = #10 then
                    begin
                      Inc(FRun);
                      Inc(LineNum);
                      ColNum := 0;
                    end;
                  end;

                #10:
                  begin
                    Inc(FRun);
                    Inc(LineNum);
                    ColNum := 0;
                  end;
              end; // Continuation on the next line

          end;

          if FOrigin[FRun] <> #0 then // Maybe reached end #0 when handlecomments or other
          begin
            Inc(FRun);
            Inc(ColNum);
          end;
          FTokenPositionsList.Add(FRun);
          FTokenLineNumberList.Add(LineNum);
          FTokenColNumberList.Add(ColNum);
        end;

      #39:
        begin
          if (FOrigin[FRun + 2] = #39) and (FOrigin[FRun + 1] <> '\') then // this is char type ... 'a' but do not include '\''
          begin
            Inc(FRun); Inc(ColNum); // ����ʼ������
            StepRun; // ���ݵ��������ַ��� ColNum
            Inc(FRun); Inc(ColNum); // ������������
            FTokenPositionsList.Add(FRun);
            FTokenLineNumberList.Add(LineNum);
            FTokenColNumberList.Add(ColNum);
          end
          else if (FOrigin[FRun + 1] = '\') and (FOrigin[FRun + 3] = #39) then  // this is for example tab escape ... '\t'
          begin
            FRun := FRun + 4;
            Inc(ColNum, 4);
            FTokenPositionsList.Add(FRun);
            FTokenLineNumberList.Add(LineNum);
            FTokenColNumberList.Add(ColNum);
          end
          else
          begin
            Inc(FRun); Inc(ColNum); //this is apostrophe ... #error Can't do something
            FTokenPositionsList.Add(FRun);
            FTokenLineNumberList.Add(LineNum);
            FTokenColNumberList.Add(ColNum);
          end;
        end;
      #127..#255:
        begin
          StepRun; // ��������չ�ַ�
        end;
    else
      begin
        Inc(FRun); Inc(ColNum);
        FTokenPositionsList.Add(FRun);
        FTokenLineNumberList.Add(LineNum);
        FTokenColNumberList.Add(ColNum);
      end;
    end;
  end;
end; {Tokenize}

function TCnBCBWideTokenList.GetTokenID(Index: LongInt): TCTokenKind;
var
  Running, TempRun: LongInt;
begin
  Result := ctkUnknown;
  Running := FTokenPositionsList[Index];
  case FOrigin[Running] of
    #0: Result := ctknull;

    #10: Result := ctkcrlf;

    #13: Result := ctkcrlf;

    #1..#9, #11, #12, #14..#32: Result := ctkspace;

    'A'..'Z', 'a'..'z', '_', '~': Result := IdentKind(Index);

    '0'..'9':
      begin
        Inc(Running);
        Result := ctknumber;
        while _WideCharInSet(FOrigin[Running], ['0'..'9', '.']) do
        begin
          case FOrigin[Running] of
            '.':
              if FOrigin[Running + 1] <> '.' then Result := ctkfloat else Break;
          end;
          Inc(Running);
        end;
      end;

    '{':
      if FOrigin[Running + 1] = '}' then Result := ctkbracepair
      else
      begin
        Result := ctkbraceopen;
        Inc(FBraceCount);
      end;

    '}':
      begin
        Result := ctkbraceclose;
        Dec(FBraceCount);
      end;

    '!'..'#', '%', '&', '('..'/', ':'..'@', '['..'^', '`':
      begin
        case FOrigin[Running] of

          '!':
            case FOrigin[Running + 1] of
              '=': Result := ctknotequal;
            else Result := ctknegation;
            end;

          '"': Result := ctkstring;

          '#':
            case FOrigin[Running + 1] of
              '#': Result := ctkblend;
              'A'..'Z', 'a'..'z':
                begin
                  if FDirectivesAsComments then
                    Result := ctkslashescomment
                  else
                  begin
                    Inc(Running);
                    TempRun := Running;
                    while _WideCharInSet(FOrigin[Running], ['A'..'Z', 'a'..'z']) do Inc(Running);
                    Result := DirKind(TempRun, Running);
                  end;
                end;
            else Result := ctkdirnull;
            end;

          '%':
            case FOrigin[Running + 1] of
              '=': Result := ctkassignmodulus;
            else Result := ctkmodulus;
            end;

          '&':
            case FOrigin[Running + 1] of
              '&': Result := ctklogicand;
              '=': Result := ctkassignbitand;
            else Result := ctkbitand;
            end;

          '(':
            case FOrigin[Running + 1] of
              ')': Result := ctkroundpair;
            else
              begin
                Result := ctkroundopen;
                Inc(fRoundCount);
              end;
            end;

          ')':
            begin
              Result := ctkroundclose;
              Dec(fRoundCount);
            end;

          '*':
            case FOrigin[Running + 1] of
              '*': Result := ctkstatstar;
              '=': Result := ctkassignmultible;
            else Result := ctkstar
            end;

          '+':
            case FOrigin[Running + 1] of
              '+': Result := ctkplusplus;
              '=': Result := ctkassignplus;
            else Result := ctkplus;
            end;

          ',': Result := ctkcomma;

          '-':
            case FOrigin[Running + 1] of
              '-': Result := ctkminusminus;
              '=': Result := ctkassignminus;
              '>':
                case FOrigin[Running + 2] of
                  '*': Result := ctkderefpointerpointer;
                else Result := ctkselectelement;
                end;
            else Result := ctkminus;
            end;

          '.':
            case FOrigin[Running + 1] of
              '*': Result := ctkderefpointer;
              '.':
                case FOrigin[Running + 2] of
                  '.': Result := ctkthreepoint;
                else Result := ctkpointpoint;
                end;
            else Result := ctkpoint;
            end;

          '/':
            case FOrigin[Running + 1] of
              '*': Result := ctkansicomment;
              '/': Result := ctkslashescomment
            else Result := ctkslash;
            end;

          ':':
            case FOrigin[Running + 1] of
              ':': Result := ctkcoloncolon;
            else Result := ctkcolon;
            end;

          ';': Result := ctksemicolon;

          '<':
            case FOrigin[Running + 1] of
              '=': Result := ctklowerequal;
              '<':
                case FOrigin[Running + 2] of
                  '=': Result := ctkassignshiftleft;
                else Result := ctkshiftleft;
                end;
            else Result := ctklower;
            end;

          '=':
            case FOrigin[Running + 1] of
              '=': Result := ctkequal;
            else Result := ctkassignment;
            end;

          '>':
            case FOrigin[Running + 1] of
              '=': Result := ctkgreaterequal;
              '>':
                case FOrigin[Running + 2] of
                  '=': Result := ctkassignshiftright;
                else Result := ctkshiftright;
                end;
            else Result := ctkgreater;
            end;

          '?':
            case FOrigin[Running + 1] of
              ':': Result := ctkconditional;
            else Result := ctksymbol;
            end;

          '[':
            case FOrigin[Running + 1] of
              ']': Result := ctksquarepair;
            else
              begin
                Result := ctksquareopen;
                Inc(fSquareCount);
              end;
            end;

          ']':
            begin
              Result := ctksquareclose;
              Dec(fSquareCount);
            end;

          '^':
            case FOrigin[Running + 1] of
              '=': Result := ctkexcbitor;
            else Result := ctkassignexcbitor;
            end;

          '{':
            case FOrigin[Running + 1] of
              '}': Result := ctkbracepair;
            else
              begin
                Result := ctkbraceopen;
                Inc(FBraceCount)
              end;
            end;

          '}':
            begin
              Result := ctkbraceclose;
              Dec(FBraceCount)
            end;

          '|':
            case FOrigin[Running + 1] of
              '=': Result := ctkassignincbitor;
              '|': Result := ctklogicor;
            else Result := ctkincbitor;
            end;

          '\':
            case FOrigin[Running + 1] of
              #10, #13: Result := ctknextline;
            end; // Continuation on the next line

        else Result := ctksymbol;
        end;
      end;

    #39: if (FOrigin[Running + 2] = #39) or ((FOrigin[Running + 1] = '\') and (FOrigin[Running + 3] = #39)) then
           Result := ctkCharType
         else
           Result := ctkapostrophe;
  else
     Result := ctkUnknown;
  end;
end; { GetTokenID }

procedure TCnBCBWideTokenList.Next;
begin
  if FRun <= Count - 1 then Inc(FRun);
end; { Next }

procedure TCnBCBWideTokenList.Previous;
begin
  if FRun > 0 then Dec(FRun);
end; { Previous }

procedure TCnBCBWideTokenList.NextID(ID: TCTokenKind);
begin
  repeat
    case TokenID[FRun] of
      ctknull: Break;
    else Inc(FRun);
    end;
  until TokenID[FRun] = ID;
end; { NextID }

function TCnBCBWideTokenList.GetIsJunk: Boolean;
begin
  case TokenID[FRun] of
    ctkansicomment, ctkcrlf, ctkslashescomment, ctkspace:
      Result := True;
  else Result := False;
  end;
end;

procedure TCnBCBWideTokenList.NextNonComment;
begin
  repeat
    case TokenID[FRun] of
      ctknull: Break;
    else Inc(FRun);
    end;
  until not (TokenID[FRun] in [ctkansicomment, ctkslashescomment]);
end; { NextNonComCRLF }

procedure TCnBCBWideTokenList.NextNonJunk;
begin
  repeat
    case TokenID[FRun] of
      ctknull: Break;
    else Inc(FRun);
    end;
  until not (TokenID[FRun] in [ctkansicomment, ctkcrlf,
    ctkslashescomment, ctkspace]);
end; { NextNonJunk }

procedure TCnBCBWideTokenList.NextNonSpace;
begin
  repeat
    case TokenID[FRun] of
      ctknull: Break;
    else Inc(FRun);
    end;
  until not (TokenID[FRun] = ctkspace);
end; { NextNonSpace }

procedure TCnBCBWideTokenList.ToLineStart;
begin
  while TokenID[FRun] <> ctkcrlf do
  begin
    if FRun <= 0 then Break;
    Dec(FRun);
  end;
  Inc(FRun);
end; { ToLineStart }

procedure TCnBCBWideTokenList.PreviousID(ID: TCTokenKind);
begin
  repeat
    case FRun of
      0: Break;
    else Dec(FRun);
    end;
  until TokenID[FRun] = ID;
end; { PreviousID }

procedure TCnBCBWideTokenList.PreviousNonComment;
begin
  repeat
    case FRun of
      0: Break;
    else Dec(FRun);
    end;
  until not (TokenID[FRun] in [ctkansicomment, ctkslashescomment]);
end; { PreviousNonComment }


procedure TCnBCBWideTokenList.PreviousNonJunk;
begin
  repeat
    case FRun of
      0: Break;
    else Dec(FRun);
    end;
  until not (TokenID[FRun] in [ctkansicomment, ctkcrlf,
    ctkslashescomment, ctkspace]);
end; { PreviousNonJunk }

procedure TCnBCBWideTokenList.PreviousNonSpace;
begin
  repeat
    case FRun of
      0: Break;
    else Dec(FRun);
    end;
  until not (TokenID[FRun] = ctkspace);
end; { PreviousNonSpace }

function TCnBCBWideTokenList.PositionAtLine(aPosition: LongInt): LongInt;
var
  Running: LongInt;
  LastPos: LongInt;
begin
  LastPos := FTokenPositionsList[FTokenPositionsList.Count - 1];
  if (aPosition < 0) or (aPosition > LastPos) then
    Result := -1
  else
  begin
    Running := 1;
    Result := 1;
    while (Running <= aPosition) and (Running < LastPos) do
    begin
      case FOrigin[Running - 1] of
        #13: if FOrigin[Running] <> #10 then Inc(Result);
        #10: Inc(Result);
      end;
      Inc(Running);
    end;
  end;
end;

function TCnBCBWideTokenList.IndexAtLine(anIndex: LongInt): LongInt;
begin
  Result := PositionAtLine(TokenPosition[anIndex]);
end;

function TCnBCBWideTokenList.GetRunID: TCTokenKind;
begin
  Result := GetTokenID(FRun);
end; { GetRunID }

function TCnBCBWideTokenList.GetRunPosition: LongInt;
begin
  Result := FTokenPositionsList[FRun];
end; { GetRunPosition }

function TCnBCBWideTokenList.GetLineNumber: LongInt;
begin
  Result := FTokenLineNumberList[FRun];
end; { GetRunLineNumber }

function TCnBCBWideTokenList.GetColumnNumber: LongInt;
begin
  Result := FTokenColNumberList[FRun];
end; { GetRunColNumber }

function TCnBCBWideTokenList.GetRunToken: CnWideString;
var
  StartPos, EndPos, StringLen: LongInt;
  OutStr: CnWideString;
begin
  StartPos := FTokenPositionsList[FRun];
  EndPos := FTokenPositionsList[FRun + 1];
  StringLen := EndPos - StartPos;
  SetString(OutStr, (FOrigin + StartPos), StringLen);
  Result := OutStr;
end; { GetRunToken }

function TCnBCBWideTokenList.PositionToIndex(aPosition: LongInt): LongInt;
var
  First, Last, I: LongInt;
begin
  Result := -1;
  I := 0;
  if (aPosition >= 0) and (aPosition <= FPCharSize) then
  begin
    First := 0;
    Last := FTokenPositionsList.Count - 2;
    while First <= Last do
    begin
      I := (First + Last) shr 1;
      if aPosition < FTokenPositionsList[I] then Last := I - 1 else
      begin
        if aPosition < FTokenPositionsList[I + 1] then Break;
        First := I + 1;
      end;
    end;
    Result := I;
  end;
end; { PositionToIndex }

function TCnBCBWideTokenList.GetTokenAddr: PWideChar;
begin
  Result := FOrigin + FTokenPositionsList[FRun];
end;

function TCnBCBWideTokenList.GetTokenLength: Integer;
begin
  Result := FTokenPositionsList[FRun + 1] - FTokenPositionsList[FRun];
end;

end.

