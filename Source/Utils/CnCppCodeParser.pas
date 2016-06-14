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

unit CnCppCodeParser;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�C/C++ Դ���������
* ��Ԫ���ߣ���Х liuxiao@cnpack.org
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2016.03.15
*               ���ӽ�������ȡԴ�ļ��� include ���ݵĹ���
*           2012.02.07
*               UTF8��λ��ת��ȥ�����������⣬�ָ�֮
*           2011.11.29
*               XE/XE2 ��λ�ý�������UTF8��λ��ת��
*           2011.05.29
*               ����BDS�¶Ժ���UTF8δ��������½������������
*           2009.04.10
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, Contnrs, CnPasCodeParser, 
  mwBCBTokenList, CnCommon, CnFastList;
  
type

//==============================================================================
// C/C++ ��������װ�࣬Ŀǰֻʵ�ֽ��������Ų������ͨ��ʶ��λ�õĹ���
//==============================================================================

{ TCnCppStructureParser }

  TCnCppToken = class(TCnPasToken)
  {* ����һ Token �Ľṹ������Ϣ}
  private

  public
    constructor Create;
  published

  end;

  TCnCppStructureParser = class(TObject)
  {* ���� CParser �����﷨�����õ����� Token ��λ����Ϣ}
  private
    FBlockCloseToken: TCnCppToken;
    FBlockStartToken: TCnCppToken;
    FChildCloseToken: TCnCppToken;
    FChildStartToken: TCnCppToken;
    FCurrentChildMethod: AnsiString;
    FCurrentMethod: AnsiString;
    FList: TCnList;
    FMethodCloseToken: TCnCppToken;
    FMethodStartToken: TCnCppToken;
    FInnerBlockCloseToken: TCnCppToken;
    FInnerBlockStartToken: TCnCppToken;
    FCurrentClass: AnsiString;
    FSource: AnsiString;
    FBlockIsNamespace: Boolean;
    function GetCount: Integer;
    function GetToken(Index: Integer): TCnCppToken;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure ParseSource(ASource: PAnsiChar; Size: Integer; CurrLine: Integer = 0;
      CurCol: Integer = 0; ParseCurrent: Boolean = False);
    {* ��������ṹ�����о��� 1 ��ʼ}
    function IndexOfToken(Token: TCnCppToken): Integer;
    property Count: Integer read GetCount;
    property Tokens[Index: Integer]: TCnCppToken read GetToken;

    property MethodStartToken: TCnCppToken read FMethodStartToken;
    property MethodCloseToken: TCnCppToken read FMethodCloseToken;
    {* ������δ����}

    property ChildStartToken: TCnCppToken read FChildStartToken;
    property ChildCloseToken: TCnCppToken read FChildCloseToken;
    {* ��ǰ���Ϊ 2 �Ĵ�����}

    property BlockStartToken: TCnCppToken read FBlockStartToken;
    property BlockCloseToken: TCnCppToken read FBlockCloseToken;
    {* ��ǰ���Ϊ 1 �Ĵ�����}
    property BlockIsNamespace: Boolean read FBlockIsNamespace;
    {* ��ǰ���Ϊ 1 �Ĵ������Ƿ��� namespace}

    property InnerBlockStartToken: TCnCppToken read FInnerBlockStartToken;
    property InnerBlockCloseToken: TCnCppToken read FInnerBlockCloseToken;
    {* ��ǰ���ڲ�εĴ�����}

    property CurrentMethod: AnsiString read FCurrentMethod;
    property CurrentClass: AnsiString read FCurrentClass;
    property CurrentChildMethod: AnsiString read FCurrentChildMethod;

    property Source: AnsiString read FSource;
  end;

function ParseCppCodePosInfo(const Source: AnsiString; CurrPos: Integer;
  FullSource: Boolean = True; IsUtf8: Boolean = False): TCodePosInfo;
{* ����Դ�����е�ǰλ�õ���Ϣ}

procedure ParseUnitIncludes(const Source: AnsiString; IncludeList: TStrings);
{* ����Դ���������õ�ͷ�ļ�}

implementation

var
  TokenPool: TCnList;

// �óط�ʽ������ PasTokens ���������
function CreateCppToken: TCnCppToken;
begin
  if TokenPool.Count > 0 then
  begin
    Result := TCnCppToken(TokenPool.Last);
    TokenPool.Delete(TokenPool.Count - 1);
  end
  else
    Result := TCnCppToken.Create;
end;

procedure FreeCppToken(Token: TCnCppToken);
begin
  if Token <> nil then
  begin
    Token.Clear;
    TokenPool.Add(Token);
  end;
end;

procedure ClearTokenPool;
var
  I: Integer;
begin
  for I := 0 to TokenPool.Count - 1 do
    TObject(TokenPool[I]).Free;
end;

//==============================================================================
// C/C++ ��������װ��
//==============================================================================

{ TCnCppStructureParser }

constructor TCnCppStructureParser.Create;
begin
  inherited;
  FList := TCnList.Create;
end;

destructor TCnCppStructureParser.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TCnCppStructureParser.Clear;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    FreeCppToken(TCnCppToken(FList[I]));
  FList.Clear;
  FMethodStartToken := nil;
  FMethodCloseToken := nil;
  FChildStartToken := nil;
  FChildCloseToken := nil;
  FBlockStartToken := nil;
  FBlockCloseToken := nil;
  FCurrentMethod := '';
  FCurrentChildMethod := '';
end;

function TCnCppStructureParser.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TCnCppStructureParser.GetToken(Index: Integer): TCnCppToken;
begin
  Result := TCnCppToken(FList[Index]);
end;

procedure TCnCppStructureParser.ParseSource(ASource: PAnsiChar; Size: Integer;
  CurrLine: Integer; CurCol: Integer; ParseCurrent: Boolean);
const
  IdentToIgnore: array[0..2] of string = ('CATCH', 'CATCH_ALL', 'AND_CATCH_ALL');
var
  CParser: TBCBTokenList;
  Token: TCnCppToken;
  Layer: Integer;
  BraceStack: TStack;
  Brace1Stack: TStack;
  Brace2Stack: TStack;
  BraceStartToken: TCnCppToken;
  BeginBracePosition: Integer;
  FunctionName, OwnerClass: string;
  PrevIsOperator, RunReachedZero: Boolean;

  procedure NewToken;
  var
    Len: Integer;
  begin
    Token := CreateCppToken;
    Token.FTokenPos := CParser.RunPosition;

    Len := CParser.TokenLength;
    if Len > CN_TOKEN_MAX_SIZE then
      Len := CN_TOKEN_MAX_SIZE;
    FillChar(Token.FToken[0], SizeOf(Token.FToken), 0);
    CopyMemory(@Token.FToken[0], CParser.TokenAddr, Len);

    // Token.FToken := AnsiString(CParser.RunToken);

    Token.FLineNumber := CParser.RunLineNumber;
    Token.FCharIndex := CParser.RunColNumber;
    Token.FCppTokenKind := CParser.RunID;
    Token.FItemLayer := Layer;
    Token.FItemIndex := FList.Count;
    FList.Add(Token);
  end;

  function CompareLineCol(Line1, Line2, Col1, Col2: Integer): Integer;
  begin
    if Line1 < Line2 then
      Result := -1
    else if Line1 = Line2 then
    begin
      if Col1 < Col2 then
        Result := -1
      else if Col1 > Col2 then
        Result := 1
      else
        Result := 0;
    end
    else
      Result := 1;
  end;

  // ����()ʱ����Խ��
  procedure SkipProcedureParameters;
  var
    RoundCount: Integer;
  begin
    RoundCount := 0;
    repeat
      CParser.Previous;
      case CParser.RunID of
        ctkroundclose: Inc(RoundCount);
        ctkroundopen: Dec(RoundCount);
        ctknull: Exit;
      end;
    until ((RoundCount <= 0) and ((CParser.RunID = ctkroundopen) or
      (CParser.RunID = ctkroundpair)));
    CParser.PreviousNonJunk; // ��������Բ�����е�����
  end;

  function IdentCanbeIgnore(const Name: string): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := Low(IdentToIgnore) to High(IdentToIgnore) do
    begin
      if Name = IdentToIgnore[I] then
      begin
        Result := True;
        Break;
      end;
    end;
  end;

  // ����<>ʱ����Խ��
  procedure SkipTemplateArgs;
  var
    TemplateCount: Integer;
  begin
    if CParser.RunID <> ctkGreater then Exit;
    TemplateCount := 1;
    repeat
      CParser.Previous;
      case CParser.RunID of
        ctkGreater: Inc(TemplateCount);
        ctklower: Dec(TemplateCount);
        ctknull: Exit;
      end;
    until (((TemplateCount = 0) and (CParser.RunID = ctklower)) or
      (CParser.RunIndex = 0));
    CParser.PreviousNonJunk;
  end;

begin
  Clear;
  CParser := nil;
  BraceStack := nil;
  Brace1Stack := nil;
  Brace2Stack := nil;

  FInnerBlockStartToken := nil;
  FInnerBlockCloseToken := nil;
  FBlockStartToken := nil;
  FBlockCloseToken := nil;
  FBlockIsNamespace := False;

  FCurrentClass := '';
  FCurrentMethod := '';

  try
    BraceStack := TStack.Create;
    Brace1Stack := TStack.Create;
    Brace2Stack := TStack.Create;
    FSource := ASource;

    CParser := TBCBTokenList.Create;
    CParser.DirectivesAsComments := False;
    CParser.SetOrigin(ASource, Size);

    Layer := 0; // ��ʼ��Σ������Ϊ 0
    while CParser.RunID <> ctknull do
    begin
      case CParser.RunID of
        ctkbraceopen:
          begin
            Inc(Layer);
            NewToken;

            if CompareLineCol(CParser.RunLineNumber, CurrLine,
              CParser.RunColNumber, CurCol) <= 0 then // �ڹ��ǰ
            begin
              BraceStack.Push(Token);
              if Layer = 1 then // ����ǵ�һ�㣬���� OuterBlock �� Begin
                Brace1Stack.Push(Token)
              else if Layer = 2 then
                Brace2Stack.Push(Token);
            end
            else // һ���ڹ����ˣ��Ϳ����ж�Start��
            begin
              if (FInnerBlockStartToken = nil) and (BraceStack.Count > 0) then
                FInnerBlockStartToken := TCnCppToken(BraceStack.Pop);
              if (FBlockStartToken = nil) and (Brace1Stack.Count > 0) then
                FBlockStartToken := TCnCppToken(Brace1Stack.Pop);
              if (FChildStartToken = nil) and (Brace2Stack.Count > 0) then
                FChildStartToken := TCnCppToken(Brace2Stack.Pop);
            end;
          end;
        ctkbraceclose:
          begin
            NewToken;
            if CompareLineCol(CParser.RunLineNumber, CurrLine,
              CParser.RunColNumber, CurCol) >= 0 then // һ���ڹ����˾Ϳ��ж�
            begin
              if (FInnerBlockStartToken = nil) and (BraceStack.Count > 0) then
                FInnerBlockStartToken := TCnCppToken(BraceStack.Pop);
              if (FBlockStartToken = nil) and (Brace1Stack.Count > 0) then
                FBlockStartToken := TCnCppToken(Brace1Stack.Pop);
              if (FChildStartToken = nil) and (Brace2Stack.Count > 0) then
                FChildStartToken := TCnCppToken(Brace2Stack.Pop);

              if (FInnerBlockCloseToken = nil) and (FInnerBlockStartToken <> nil) then
              begin
                if Layer = FInnerBlockStartToken.ItemLayer then
                  FInnerBlockCloseToken := Token;
              end;

              if Layer = 1  then // ��һ�㣬Ϊ OuterBlock �� End
              begin
                if FBlockCloseToken = nil then
                  FBlockCloseToken := Token;
              end
              else if Layer = 2 then  // �ڶ����Ҳ����
              begin
                if FChildCloseToken = nil then
                  FChildCloseToken := Token;
              end;
            end
            else // �ڹ��ǰ
            begin
              if BraceStack.Count > 0 then
                BraceStack.Pop;
              if (Layer = 1) and (Brace1Stack.Count > 0) then
                Brace1Stack.Pop;
              if (Layer = 2) and (Brace2Stack.Count > 0) then
                Brace2Stack.Pop;
            end;
            Dec(Layer);
          end;
        ctkidentifier,        // Need these for flow control in source highlight
        ctkreturn, ctkgoto, ctkbreak, ctkcontinue:
          begin
            NewToken;
          end;
        ctkdirif, ctkdirifdef, // Need these for conditional compile directive
        ctkdirifndef, ctkdirelif, ctkdirelse, ctkdirendif:
          begin
            NewToken;
          end;
      end;

      CParser.NextNonJunk;
    end;

    if ParseCurrent then
    begin
      // �����һ���ڶ��㣨�����һ���� namespace �Ļ���������
      if FBlockStartToken <> nil then
      begin
        BraceStartToken := FBlockStartToken;

        // �ȵ�����������Ŵ�
        if CParser.RunPosition > FBlockStartToken.TokenPos then
        begin
          while CParser.RunPosition > FBlockStartToken.TokenPos do
            CParser.PreviousNonJunk;
        end
        else if CParser.RunPosition < FBlockStartToken.TokenPos then
          while CParser.RunPosition < FBlockStartToken.TokenPos do
            CParser.NextNonJunk;

        RunReachedZero := False;
        while not (CParser.RunID in [ctkNull, ctkbraceclose, ctksemicolon])
          and (CParser.RunPosition >= 0) do               //  ��ֹ using namespace std; ����
        begin
          if RunReachedZero and (CParser.RunPosition = 0) then
            Break; // ������ 0�����ڻ��� 0����ʾ��������ѭ��
          if CParser.RunPosition = 0 then
            RunReachedZero := True;

          // ��� namespace ���ͷ���� RunPosition ������ 0
          if CParser.RunID in [ctknamespace] then
          begin
            // ������ namespace������ڶ���ȥ
            BraceStartToken := FChildStartToken;
            FBlockIsNamespace := True;
            Break;
          end;
          CParser.PreviousNonJunk;
        end;

        if BraceStartToken = nil then
          Exit;

        // �ص���������Ŵ�
        if CParser.RunPosition > BraceStartToken.TokenPos then
        begin
          while CParser.RunPosition > BraceStartToken.TokenPos do
            CParser.PreviousNonJunk;
        end
        else if CParser.RunPosition < BraceStartToken.TokenPos then
          while CParser.RunPosition < BraceStartToken.TokenPos do
            CParser.NextNonJunk;

        // ���������Ҫ�Ĵ�����֮ǰ���������������
        BeginBracePosition := CParser.RunPosition;
        // ��¼������ŵ�λ��
        CParser.PreviousNonJunk;
        if CParser.RunID = ctkidentifier then // ����������ǰ�Ǳ�ʶ��
        begin
          while not (CParser.RunID in [ctkNull, ctkbraceclose])
            and (CParser.RunPosition > 0) do
          begin
            if CParser.RunID in [ctkclass, ctkstruct] then
            begin
              // �ҵ��� class �� struct����ô�����ǽ��� : �� { ǰ�Ķ���
              while not (CParser.RunID in [ctkcolon, ctkbraceopen, ctknull]) do
              begin
                FCurrentClass := AnsiString(CParser.RunToken); // �ҵ��������߽ṹ��
                CParser.NextNonJunk;
              end;
              if FCurrentClass <> '' then // �ҵ������ˣ����������������ˣ��˳�
                Exit;
            end;
            CParser.PreviousNonJunk;
          end;
        end
        else if CParser.RunID in [ctkroundclose, ctkroundpair, ctkconst,
          ctkvolatile, ctknull] then
        begin
          // �������ǰ���Ǳ�ʶ�������⼸��������ܵ�����һ���������ĩβ�������ſ�ͷ
          // �����ߣ����������
          CParser.Previous;

          // ������Բ���ŵ�
          while not ((CParser.RunID in [ctkSemiColon, ctkbraceclose,
            ctkbraceopen, ctkbracepair]) or (CParser.RunID in IdentDirect) or
            (CParser.RunIndex = 0)) do
          begin
            CParser.PreviousNonJunk;
            // ͬʱ�������е�ð�ţ��� __fastcall TForm1::TForm1(TComponent* Owner) : TForm(Owner)
            if CParser.RunID = ctkcolon then
            begin
              CParser.PreviousNonJunk;
              if CParser.RunID in [ctkroundclose, ctkroundpair] then
                CParser.NextNonJunk
              else
              begin
                CParser.NextNonJunk;
                Break;
              end;
            end;
          end;

          // ���Ӧ��ͣ��Բ���Ŵ�
          if CParser.RunID in [ctkcolon, ctkSemiColon, ctkbraceclose,
            ctkbraceopen, ctkbracepair] then
            CParser.NextNonComment
          else if CParser.RunIndex = 0 then
          begin
            if CParser.IsJunk then
              CParser.NextNonJunk;
          end
          else // Խ������ָ��
          begin
            while CParser.RunID <> ctkcrlf do
            begin
              if (CParser.RunID = ctknull) then
                Exit;
              CParser.Next;
            end;
            CParser.NextNonJunk;
          end;

          // ����һ������ĺ�����ͷ
          while (CParser.RunPosition < BeginBracePosition) and
            (CParser.RunID <> ctkcolon) do
          begin
            if CParser.RunID = ctknull then
              Exit;
            CParser.NextNonComment;
          end;

          FunctionName := '';
          OwnerClass := '';
          SkipProcedureParameters;

          if CParser.RunID = ctknull then
            Exit
          else if CParser.RunID = ctkthrow then
            SkipProcedureParameters;

          CParser.PreviousNonJunk;
          PrevIsOperator := CParser.RunID = ctkoperator;
          CParser.NextNonJunk;

          if ((CParser.RunID = ctkidentifier) or (PrevIsOperator)) and not
            IdentCanbeIgnore(CParser.RunToken) then
          begin
            if PrevIsOperator then
              FunctionName := 'operator ';
            FunctionName := FunctionName + CParser.RunToken;
            CParser.PreviousNonJunk;

            if CParser.RunID = ctkcoloncolon then
            begin
              FCurrentClass := '';
              while CParser.RunID = ctkcoloncolon do
              begin
                CParser.PreviousNonJunk; // ������������������
                if CParser.RunID = ctkGreater then
                  SkipTemplateArgs;

                OwnerClass := CParser.RunToken + OwnerClass;
                CParser.PreviousNonJunk;
                if CParser.RunID = ctkcoloncolon then
                  OwnerClass := CParser.RunToken + OwnerClass;
              end;
              FCurrentClass := AnsiString(OwnerClass);
            end;
            if OwnerClass <> '' then
              FCurrentMethod := AnsiString(OwnerClass + '::' + FunctionName)
            else
              FCurrentMethod := AnsiString(FunctionName);
          end;
        end;
      end;
    end;
  finally
    BraceStack.Free;
    Brace1Stack.Free;
    Brace2Stack.Free;
    CParser.Free;
  end;
end;

function TCnCppStructureParser.IndexOfToken(Token: TCnCppToken): Integer;
begin
  Result := FList.IndexOf(Token);
end;

{ TCnCppToken }

constructor TCnCppToken.Create;
begin
  inherited;
  FUseAsC := True;
end;

// ����Դ�����е�ǰλ�õ���Ϣ
function ParseCppCodePosInfo(const Source: AnsiString; CurrPos: Integer;
  FullSource: Boolean = True; IsUtf8: Boolean = False): TCodePosInfo;
var
  CanExit: Boolean;
  CParser: TBCBTokenList;
  Text: AnsiString;

  procedure DoNext;
  var
    OldPosition: Integer;
  begin
    Result.LineNumber := CParser.RunLineNumber - 1;
    Result.LinePos := CParser.RunColNumber;
    Result.TokenPos := CParser.RunPosition;
    Result.Token := AnsiString(CParser.RunToken);
    Result.CTokenID := CParser.RunID;

    OldPosition := CParser.RunPosition;
    CParser.Next;

    CanExit := CParser.RunPosition = OldPosition;
    // �� Next ��Ҳǰ�����˵�ʱ�򣬾��Ǹó���
    // ��������ԭ���ǣ�CParser �ڽ�βʱ����ʱ�򲻻���е�ctknull����һֱ��ת
  end;
begin
  if CurrPos <= 0 then
    CurrPos := MaxInt;
  CParser := nil;
  Result.IsPascal := False;

  try
    CParser := TBCBTokenList.Create;
    CParser.DirectivesAsComments := False;
{$IFDEF BDS}
    if IsUtf8 then
    begin
      Text := CnUtf8ToAnsi(PAnsiChar(Source));
//{$IFNDEF BDS2009_UP}
      // XE/XE2 �µ�CurrPos �Ѿ��� UTF8 ��λ�ã������ٴ�ת�����������2009 δ֪��
      CurrPos := Length(CnUtf8ToAnsi(Copy(Source, 1, CurrPos)));
      // ��ת���ᵼ�������������ַ����ﵯ���������֣����ǵ�ת��
//{$ENDIF}
    end
    else
      Text := Source;
{$ELSE}
    Text := Source;
{$ENDIF}
    CParser.SetOrigin(PAnsiChar(Text), Length(Text));

    if FullSource then
    begin
      Result.AreaKind := akHead; // δʹ��
      Result.PosKind := pkField; // ����հ�������pkField
    end
    else
    begin

    end;

    while (CParser.RunPosition < CurrPos) and (CParser.RunID <> ctknull) do
    begin
      // ����Ҫ���ֳ��ַ���������ע�͡�->��.�󡢱�ʶ��������ָ���
      case CParser.RunID of
        ctkansicomment, ctkslashescomment:
          begin
            Result.PosKind := pkComment;
          end;
        ctkstring:
          begin
            Result.PosKind := pkString;
          end;
        ctkcrlf:
          begin
            // ��ע����#����ָ��Իس���β
            if (Result.PosKind = pkCompDirect) or (Result.CTokenID = ctkslashescomment) then
              Result.PosKind := pkField;
          end;
//        ctksemicolon, ctkbraceopen, ctkbraceclose, ctkbracepair,
//        ctkint, ctkfloat, ctkdouble, ctkchar,
//        ctkidentifier, ctkcoloncolon,
//        ctkroundopen, ctkroundpair, ctksquareopen, ctksquarepair,
//        ctkcomma, ctkequal, ctknumber:
//          begin
//            Result.PosKind := pkField;
//          end;
        ctkselectelement:
          begin
            Result.PosKind := pkFieldDot; // -> ���� . ����
          end;
        ctkpoint:
          begin
            if Result.CTokenID = ctkidentifier then
              Result.PosKind := pkFieldDot; // ��һ����ʶ����ĵ����
          end;
        ctkdirdefine, ctkdirelif, ctkdirelse, ctkdirendif, ctkdirerror, ctkdirif,
        ctkdirifdef, ctkdirifndef, ctkdirinclude, ctkdirline, ctkdirnull,
        ctkdirpragma, ctkdirundef:
          begin
            Result.PosKind := pkCompDirect;
          end;
        ctkUnknown:
          begin
            // #��ı���ָ��δ���ʱ
            if (Length(CParser.RunToken) >= 1 ) and (CParser.RunToken[1] = '#') then
            begin
              Result.PosKind := pkCompDirect;
            end
            else
              Result.PosKind := pkField;
          end;
      else
        Result.PosKind := pkField;
      end;

      DoNext;
      if CanExit then
        Break;
    end;
  finally
    CParser.Free;
  end;
end;

// ����Դ���������õ�ͷ�ļ�
procedure ParseUnitIncludes(const Source: AnsiString; IncludeList: TStrings);
var
  S: string;
  CParser: TBCBTokenList;
begin
  IncludeList.Clear;

  CParser := TBCBTokenList.Create;
  CParser.DirectivesAsComments := False;

  try
    CParser.SetOrigin(PAnsiChar(Source), Length(Source));

    while CParser.RunID <> ctknull do
    begin
      if CParser.RunID = ctkdirinclude then
      begin
        CParser.NextNonJunk;
        if CParser.RunID = ctkstring then
        begin
          S := CParser.RunToken;
          if S <> '' then
          begin
            // ȥ���ַ������˵�����
            if S[1] = '"' then
              Delete(S, 1, 1);
            if (S <> '') and (S[Length(S)] = '"') then
              Delete(S, Length(S), 1);

            IncludeList.Add(S);
          end;
        end
        else if CParser.RunID = ctklower then
        begin
          CParser.NextNonJunk;
          S := '';
          while CParser.RunID in [ctkidentifier, ctkpoint] do
          begin
            S := S + CParser.RunToken;
            CParser.Next;
          end;
          IncludeList.Add(S);
        end;
      end;

      CParser.NextNonJunk;
    end;
  finally
    CParser.Free;
  end;
end;

initialization
  TokenPool := TCnList.Create;

finalization
  ClearTokenPool;
  FreeAndNil(TokenPool);

end.
