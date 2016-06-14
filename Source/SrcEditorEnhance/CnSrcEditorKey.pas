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

unit CnSrcEditorKey;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�����༭��������չ���ߵ�Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2015.04.25
*             �� D2005 ����ʹ�� Wide Parser ���� Utf8/Unicode ת��Ϊ AnsiString
*                 ����ʱ���ܶ��ַ���Ϣ�����⡣
*           2015.02.03
*             �����ֹ��곬����β�Ĺ��ܣ�Ĭ�Ͻ���
*           2011.06.14
*             ��������β�����Ҽ����еĹ���
*           2008.12.25
*             ���� F2 �޸ĵ�ǰ�������Ĺ���
*           2005.08.30
*             ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, ToolsAPI, IniFiles,
  Forms, Menus, Clipbrd, ActnList, StdCtrls, ComCtrls, Imm, Math, TypInfo,
  CnPasCodeParser, CnCommon, CnConsts, CnWizUtils, CnWizConsts, CnWizOptions,
  CnWizIdeUtils, CnEditControlWrapper, CnWizNotifier, CnWizMethodHook,
  CnWizCompilerConst,
  {$IFDEF IDE_WIDECONTROL}
  CnWidePasParser, CnWideCppParser,
  {$ENDIF}
  CnCppCodeParser, Contnrs;

type
  TCnAutoMatchType = (btNone, btBracket, btSquare, btCurly, btQuote, btDitto); // () [] {} '' ""

  TCnRenameIdentifierType = (ritInvalid, ritUnit, ritCurrentProc, ritInnerProc, ritCppHPair);
  // Pascal�� �����ļ�����ǰ�������̡���ǰ���ڲ����
  // C/C++��  �����ļ�����ǰ���������ţ������namespace�������㣨������namespace)
              // ��ǰ���ڲ�����š����� Cpp �Լ���Ӧ�� H�� ����

//==============================================================================
// ����༭��������չ����
//==============================================================================

{ TCnSrcEditorKey }

  TCnSrcEditorKey = class(TObject)
  private
    FActive: Boolean;
    FOnEnhConfig: TNotifyEvent;
    FAutoMatchEntered: Boolean;
    FAutoMatchType: TCnAutoMatchType;
    FRepaintView: Cardinal; // �������ػ�������

    FSmartCopy: Boolean;
    FSmartPaste: Boolean;
    FShiftEnter: Boolean;
    FAutoIndent: Boolean;
    FAutoIndentList: TStringList;
    FHomeExt: Boolean;
    FHomeFirstChar: Boolean;
    FCursorBeforeEOL: Boolean;
    FLeftRightLineWrap: Boolean;
    FF3Search: Boolean;
    FAutoBracket: Boolean;
    FF2Rename: Boolean;
    FRenameShortCut: TShortCut;
    FRenameKey: Word;
    FRenameShift: TShiftState;
    FSemicolonLastChar: Boolean;
    FAutoEnterEnd: Boolean;
    FKeepSearch: Boolean;
    FCorIdeModule: HModule;
    FSearchWrap: Boolean;
    FUpperFirstLetter: Boolean;

    FCursorMoving: Boolean;
{$IFNDEF DELPHI10_UP}
    FSaveLineNo: Integer;
    FNeedChangeInsert: Boolean;

    procedure IdleDoAutoInput(Sender: TObject);
    procedure IdleDoAutoIndent(Sender: TObject);
    procedure IdleDoCBracketIndent(Sender: TObject);
{$ENDIF}
    procedure SetKeepSearch(const Value: Boolean);
    procedure SetRenameShortCut(const Value: TShortCut);
  protected
    procedure SetActive(Value: Boolean);
    function IsValidRenameIdent(const Ident: string): Boolean;
    procedure DoEnhConfig;
    function DoAutoMatchEnter(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
    function DoSmartCopy(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
    function DoShiftEnter(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
{$IFNDEF DELPHI10_UP}
    function DoAutoIndent(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
{$ENDIF}
    function DoHomeExtend(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
    function DoLeftRightLineWrap(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
    function DoSemicolonLastChar(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
    function DoSearchAgain(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
    function DoRename(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
{$IFDEF IDE_WIDECONTROL}
    // Unicode/Utf8 �汾������ D2005 �����ϣ����ת���� Ansi ��ᶪ�ַ�������
    function DoRenameW(View: IOTAEditView; Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean): Boolean;
    procedure ConvertToUtf8Stream(Stream: TStream);
{$ENDIF}
    procedure EditControlKeyDown(Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean);
    procedure EditControlKeyUp(Key, ScanCode: Word; Shift: TShiftState;
      var Handled: Boolean);
    procedure ExecuteInsertCharOnIdle(Sender: TObject);

    procedure EditorChanged(Editor: TEditorObject; ChangeType: TEditorChangeTypes);
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadSettings(Ini: TCustomIniFile);
    procedure SaveSettings(Ini: TCustomIniFile);
    procedure ResetSettings(Ini: TCustomIniFile);
    procedure LanguageChanged(Sender: TObject);

    property Active: Boolean read FActive write SetActive;
    property SmartCopy: Boolean read FSmartCopy write FSmartCopy;
    property SmartPaste: Boolean read FSmartPaste write FSmartPaste;
    property ShiftEnter: Boolean read FShiftEnter write FShiftEnter;
    property F3Search: Boolean read FF3Search write FF3Search;
    property F2Rename: Boolean read FF2Rename write FF2Rename;
    property RenameShortCut: TShortCut read FRenameShortCut write SetRenameShortCut;
    property KeepSearch: Boolean read FKeepSearch write SetKeepSearch;
    property SearchWrap: Boolean read FSearchWrap write FSearchWrap;
    property AutoIndent: Boolean read FAutoIndent write FAutoIndent;
    property AutoIndentList: TStringList read FAutoIndentList;
    property HomeExt: Boolean read FHomeExt write FHomeExt;
    property HomeFirstChar: Boolean read FHomeFirstChar write FHomeFirstChar;
    property CursorBeforeEOL: Boolean read FCursorBeforeEOL write FCursorBeforeEOL;
    property LeftRightLineWrap: Boolean read FLeftRightLineWrap write FLeftRightLineWrap;
    property AutoBracket: Boolean read FAutoBracket write FAutoBracket;
    property SemicolonLastChar: Boolean read FSemicolonLastChar write FSemicolonLastChar;
    property AutoEnterEnd: Boolean read FAutoEnterEnd write FAutoEnterEnd;
    property UpperFirstLetter: Boolean read FUpperFirstLetter write FUpperFirstLetter;
    property OnEnhConfig: TNotifyEvent read FOnEnhConfig write FOnEnhConfig;

  end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}

implementation

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

uses
  {$IFDEF DEBUG}CnDebug, {$ENDIF}
  CnSourceHighlight, mPasLex, mwBCBTokenList, CnIdentRenameFrm;

{ TCnSrcEditorKey }

type
  TControlHack = class(TControl);
  TClickEventProc = procedure(Self: TObject; Sender: TObject);

const
  SCnAutoIndentFile = 'AutoIndent.dat';

  SCnSrchDialogOKButtonClick = '@Srchdlg@TSrchDialog@OKButtonClick$qqrp14System@TObject';
  SCnSrchDialogComboName = 'SearchText';
  SCnHistoryPropComboBoxClassName = 'THistoryPropComboBox';
  SCnCaseSenseCheckBoxName = 'CaseSense';
  SCnWholeWordsCheckBoxName = 'WholeWords';
  SCnRegExpCheckBoxName = 'RegExp';
  SCnPropCheckBoxClassName = 'TPropCheckBox';

var
  FOldSearchText: string = '';

  FOldSrchDialogOKButtonClick: Pointer = nil;
  FMethodHook: TCnMethodHook;

  // ��¼��ǰ������ѡ��
  FCaseSense: Boolean;
  FWholeWords: Boolean;
  FRegExp: Boolean;

procedure CnSrchDialogOKButtonClick(ASelf, Sender: TObject);
var
  AForm: TCustomForm;
  AComp: TComponent;
  ANotify: TNotifyEvent;
{$IFDEF BDS}
  Len: Integer;
  WideText: WideString;
{$ENDIF}
begin
  if Sender is TButton then
  begin
    if (Sender as TComponent).Owner is TCustomForm then
    begin
      AForm := (Sender as TComponent).Owner as TCustomForm;
      AComp := AForm.FindComponent(SCnSrchDialogComboName);
      if (AComp <> nil) and (AComp.ClassNameIs(SCnHistoryPropComboBoxClassName)) then
      begin
{$IFNDEF BDS}
        if TControlHack(AComp).Text <> '' then // ��¼ IDE �еĲ�����ʷ
          FOldSearchText := TControlHack(AComp).Text;
{$ELSE}
        // BDS �� AComp ������ͨControl���� WideControl���� Text ������ WideString
        // ����ֱ�ӻ�ã���Ҫ��ȡ��ַ��ת��
        Len := TControl(AComp).Perform(WM_GETTEXTLENGTH, 0, 0);
        if Len > 0 then
        begin
          SetLength(WideText, Len);
          TControl(AComp).Perform(WM_GETTEXT, (Len + 1) * SizeOf(Char), Longint(WideText));

          FOldSearchText := string(WideText);
        end;
{$ENDIF}
      end;

      // ��¼��������ѡ�F3Search����ʹ��
      AComp := AForm.FindComponent(SCnCaseSenseCheckBoxName);
      if (AComp <> nil) and (AComp.ClassNameIs(SCnPropCheckBoxClassName)) then
        FCaseSense := TCheckBox(AComp).Checked; // ��¼ IDE �еĲ���ѡ��֮��Сд

      AComp := AForm.FindComponent(SCnWholeWordsCheckBoxName);
      if (AComp <> nil) and (AComp.ClassNameIs(SCnPropCheckBoxClassName)) then
        FWholeWords := TCheckBox(AComp).Checked; // ��¼ IDE �еĲ���ѡ��֮����

      AComp := AForm.FindComponent(SCnRegExpCheckBoxName);
      if (AComp <> nil) and (AComp.ClassNameIs(SCnPropCheckBoxClassName)) then
        FRegExp := TCheckBox(AComp).Checked; // ��¼ IDE �еĲ���ѡ��֮����

{$IFDEF DEBUG}
      CnDebugger.LogFmt('F3 Search: Get Options: Case %d, Word %d, Reg %d. ',
        [Integer(FCaseSense), Integer(FWholeWords), Integer(FRegExp)]);
{$ENDIF}
    end;
  end;

  if FOldSrchDialogOKButtonClick <> nil then
  begin
    if FMethodHook.UseDDteours then
      TClickEventProc(FMethodHook.Trampoline)(ASelf, Sender)
    else
    begin
      FMethodHook.UnhookMethod;
      TMethod(ANotify).Code := FOldSrchDialogOKButtonClick;
      TMethod(ANotify).Data := ASelf;
      ANotify(Sender);
      FMethodHook.HookMethod;
    end;
  end;
end;

constructor TCnSrcEditorKey.Create;
begin
  inherited;
  FActive := True;
  FAutoIndentList := TStringList.Create;
  FRenameShortCut := TextToShortCut('F2');

  FCorIdeModule := LoadLibrary(CorIdeLibName);
  if FCorIdeModule <> 0 then
  begin
    FOldSrchDialogOKButtonClick := GetProcAddress(FCorIdeModule, SCnSrchDialogOKButtonClick);
    if FOldSrchDialogOKButtonClick <> nil then
    begin
      FOldSrchDialogOKButtonClick := GetBplMethodAddress(FOldSrchDialogOKButtonClick);
      if FOldSrchDialogOKButtonClick <> nil then
      begin
        FMethodHook := TCnMethodHook.Create(FOldSrchDialogOKButtonClick, @CnSrchDialogOKButtonClick);
      end;
    end;
  end;

  EditControlWrapper.AddKeyDownNotifier(EditControlKeyDown);
  EditControlWrapper.AddKeyUpNotifier(EditControlKeyUp);
  EditControlWrapper.AddEditorChangeNotifier(EditorChanged);
end;

destructor TCnSrcEditorKey.Destroy;
begin
  EditControlWrapper.RemoveEditorChangeNotifier(EditorChanged);
  EditControlWrapper.RemoveKeyDownNotifier(EditControlKeyDown);
  EditControlWrapper.RemoveKeyUpNotifier(EditControlKeyUp);

  FMethodHook.Free;
  if FCorIdeModule <> 0 then
    FreeLibrary(FCorIdeModule);

  FAutoIndentList.Free;
  inherited;
end;

function CanIgnoreFromIME: Boolean;
var
  Imc: HIMC;
  EditControl: TWinControl;
  Conversion, Sentence: DWORD;
begin
  Result := False;
  if IMMIsActive then // ���뷨����
  begin
    EditControl := CnOtaGetCurrentEditControl;
    if EditControl <> nil then
    begin
      Imc := ImmGetContext(EditControl.Handle);
      if ImmGetConversionStatus(Imc, Conversion, Sentence) then
      begin
        if (((Conversion and IME_CMODE_NATIVE) <> 0) = ((Conversion and  IME_CMODE_SYMBOL) <> 0))
          and ((Conversion and IME_CMODE_NATIVE) <> 0) then
        begin
          Result := True;
          Exit; // ���뷨Ӣ�����벻�������Ҳ���Ӣ�ı��ľͲ�����, ��������ֻ�ܿ���һ��
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
// ��չ���ܷ���
//------------------------------------------------------------------------------

function TCnSrcEditorKey.DoAutoMatchEnter(View: IOTAEditView; Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean): Boolean;
var
  AChar, Char1, Char2: Char;
  Line: string;
  AnsiLine: AnsiString;
  LineNo, CharIndex: Integer;
  NeedAutoMatch: Boolean;
  EditControl: TControl;
  Element, LineFlag: Integer;
begin
  if CnNtaGetCurrLineText(Line, LineNo, CharIndex) then
  begin
    AChar := Char(VK_ScanCodeToAscii(Key, ScanCode));

    // UNICODE ������ CharIndex �� string ��һ�£���Ҫת���� AnsiString ������
    AnsiLine := AnsiString(Line);

    if CharInSet(AChar, ['(', '[', '{', '''', '"']) then
    begin
      if CanIgnoreFromIME then
      begin
        Result := False;
        Exit;
      end;

      NeedAutoMatch := False;
      if Length(AnsiLine) > CharIndex then
      begin
        // ��ǰλ�ú��Ǳ�ʶ���Լ�����������ʱ���Զ���������
        NeedAutoMatch := not CharInSet(Char(AnsiLine[CharIndex + 1]), ['_', 'A'..'Z',
          'a'..'z', '0'..'9', '(', '''', '[']);
      end
      else if Length(AnsiLine) = CharIndex then
        NeedAutoMatch := True; // ��β

      if AChar = '''' then
      begin
        // �ַ����ڲ����Զ����뵥����
        EditControl := CnOtaGetCurrentEditControl;
        if EditControl = nil then
        begin
          Result := False;
          Exit;
        end;
        EditControlWrapper.GetAttributeAtPos(EditControl, View.CursorPos,
          False, Element, LineFlag);
        if Element in [atString] then
          NeedAutoMatch := False;
      end;

      // �Զ������������
      if NeedAutoMatch then
      begin
        case AChar of
          '(': FAutoMatchType := btBracket;
          '[': FAutoMatchType := btSquare;
          '{': FAutoMatchType := btCurly;
          '''':FAutoMatchType := btQuote;
          '"': FAutoMatchType := btDitto;
        else
          FAutoMatchType := btNone;
        end;

        FAutoMatchEntered := True;
        FRepaintView := Cardinal(View);
        CnWizNotifierServices.ExecuteOnApplicationIdle(ExecuteInsertCharOnIdle);
      end;
    end
    else if FAutoMatchEntered and CharInSet(AChar, [')', ']', '}', '''', '"', #9]) then
    begin
      if CanIgnoreFromIME then
      begin
        Result := False;
        Exit;
      end;

      // �������������ţ��������ſ���Ҫʡ�� �����߰� Tab ʱ���������ź�
      if ((FAutoMatchType = btBracket) and (AChar = ')')) or
        ((FAutoMatchType = btSquare) and (AChar = ']')) or
        ((FAutoMatchType = btCurly) and (AChar = '}')) or
        ((FAutoMatchType = btQuote) and (AChar = '''')) or
        ((FAutoMatchType = btDitto) and (AChar = '"')) or (AChar = #9) then
      begin
        // �жϵ�ǰ����ұ��Ƿ�����Ӧ��������
        NeedAutoMatch := False;
        if Length(AnsiLine) > CharIndex then
        begin
          AChar := Char(AnsiLine[CharIndex + 1]); // ����ʹ�� AChar
          case FAutoMatchType of
            btBracket: NeedAutoMatch := AChar = ')';
            btSquare:  NeedAutoMatch := AChar = ']';
            btCurly:   NeedAutoMatch := AChar = '}';
            btQuote:   NeedAutoMatch := AChar = '''';
            btDitto:   NeedAutoMatch := AChar = '"';
          end;
        end;

        if NeedAutoMatch then // ��ƥ��Ķ���
        begin
          CnOtaMovePosInCurSource(ipCur, 0, 1);
          View.Paint;
          FAutoMatchEntered := False;
          Handled := True;
        end;
      end;
    end
    else if FAutoMatchEntered and (AChar = #08) and (CharIndex < Length(AnsiLine)) then
    begin
      // ������˸�������ҹ��������������ұ��������ţ����������Ҳɾ��
      Char1 := Char(AnsiLine[CharIndex]);
      Char2 := Char(AnsiLine[CharIndex + 1]);
      if ( (Char1 = '(') and (Char2 = ')') ) or
        ((Char1 = '[') and (Char2 = ']')) or
        ((Char1 = '{') and (Char2 = '}')) or
        ((Char1 = '''') and (Char2 = '''')) or
        ((Char1 = '"') and (Char2 = '"')) then
      begin
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Should Delete AutoMatched Chars.');
{$ENDIF}
        CnOtaEditDelete(1);
        Handled := False;
      end;
    end;
  end;
  Result := Handled;
end;

function TCnSrcEditorKey.DoSmartCopy(View: IOTAEditView; Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean): Boolean;
var
  Token: string;
  Idx: Integer;
begin
  if (Key in [Ord('C'), Ord('V'), Ord('X')]) and (Shift = [ssCtrl]) then
  begin
    if not View.Block.IsValid then
    begin
      if FSmartCopy and (Key in [Ord('C'), Ord('X')]) then
      begin
        if CnOtaGetCurrPosToken(Token, Idx, True) then
        begin
          Clipboard.AsText := Token;

          if Key = Ord('X') then
          begin
            CnOtaDeleteCurrToken;
            View.Paint;
          end;
          Handled := True;
        end;
      end
      else if FSmartPaste then
      begin
        CnOtaDeleteCurrToken;
        Handled := False;
      end;
    end;
  end;
  Result := Handled;
end;

function TCnSrcEditorKey.DoShiftEnter(View: IOTAEditView; Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean): Boolean;
begin
  Result := False;
  if (Key = VK_RETURN) and (Shift = [ssShift]) and not View.Block.IsValid then
  begin
    View.Buffer.EditPosition.MoveEOL;
    Handled := False;
    Result := True;
  end;
end;

{$IFNDEF DELPHI10_UP}

procedure TCnSrcEditorKey.IdleDoAutoIndent(Sender: TObject);
var
  View: IOTAEditView;
begin
  View := CnOtaGetTopMostEditView;
  if Assigned(View) then
  begin
    if View.CursorPos.Line = FSaveLineNo + 1 then
    begin
      View.Buffer.EditPosition.MoveRelative(0, CnOtaGetBlockIndent);
      View.Paint;
    end;
  end;
end;

procedure TCnSrcEditorKey.IdleDoCBracketIndent(Sender: TObject);
var
  View: IOTAEditView;
begin
  View := CnOtaGetTopMostEditView;
  if Assigned(View) then
  begin
    if View.CursorPos.Line = FSaveLineNo + 1 then
    begin
      CnOtaInsertTextToCurSource(#13#10);
      CnOtaMovePosInCurSource(ipCur, -1, 0);
      View.Buffer.EditPosition.MoveRelative(0, CnOtaGetBlockIndent);
      View.Paint;
    end;
  end;
end;

procedure TCnSrcEditorKey.IdleDoAutoInput(Sender: TObject);
var
  View: IOTAEditView;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  Parser: TCnPasStructureParser;
  NeedInsert: Boolean;
  Text: string;
  ACol: Integer;

  function IsDotAfterTokenEnd(AToken: TCnPasToken): Boolean;
  var
    SavePos, APos: TOTAEditPos;
    Text: string;
    Line, Col: Integer;
  begin
    Result := False;
    if AToken = nil then Exit;

    SavePos := View.CursorPos;
    APos := SavePos;
    APos.Line := AToken.LineNumber + 1; // �����һ
    View.CursorPos := APos;
    CnNtaGetCurrLineText(Text, Line, Col);

    Col := AToken.EditCol + Length(AToken.Token);
    if Length(Text) >= Col then
      Result := (Text[Col] = '.');

    View.CursorPos := SavePos;
  end;

begin
  View := CnOtaGetTopMostEditView;
  if Assigned(View) then
  begin
    if View.CursorPos.Line = FSaveLineNo + 1 then
    begin
      // DONE: ����һЩ���ƣ�����ÿ������ end
      // ������ڵ��ڲ��һ����beginһ����end����������Col����ʱ������Ҫ��end
      // ����������ڲ��ʱҲ�� end���������������ӡ�
      // ���⣬����Ѿ�����ˣ������ end ������ end. �����ĵ�Ԫ��β��
      Stream := TMemoryStream.Create;
      Parser := TCnPasStructureParser.Create;
      try
        CnOtaSaveEditorToStream(View.Buffer, Stream);
        Parser.ParseSource(PAnsiChar(Stream.Memory),
          IsDpr(View.Buffer.FileName), True);

        EditPos := View.CursorPos;
        View.ConvertPos(True, EditPos, CharPos);
        Parser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);

        NeedInsert := False;
        if (Parser.InnerBlockStartToken <> nil) and (Parser.InnerBlockCloseToken <> nil) then
        begin
          if (Parser.InnerBlockStartToken.TokenID = tkBegin) and
            (Parser.InnerBlockCloseToken.TokenID = tkEnd) then
          begin
            // ת���� Col �� Line���� 0 ��ʼ�� CharIndex��ת��Ϊ 1 ��ʼ�� Col
            CharPos := OTACharPos(Parser.InnerBlockStartToken.CharIndex,
              Parser.InnerBlockStartToken.LineNumber);
            View.ConvertPos(False, EditPos, CharPos);
            Parser.InnerBlockStartToken.EditCol := EditPos.Col;
            Parser.InnerBlockStartToken.EditLine := EditPos.Line;

            CharPos := OTACharPos(Parser.InnerBlockCloseToken.CharIndex,
              Parser.InnerBlockCloseToken.LineNumber);
            View.ConvertPos(False, EditPos, CharPos);
            Parser.InnerBlockCloseToken.EditCol := EditPos.Col;
            Parser.InnerBlockCloseToken.EditLine := EditPos.Line;

            // ��ֻ�ж� begin/end ���Ƿ�ƥ�䣬���� if then begin \n end ʱ�����Ӳ���Ҫ�� end
            // Ӧ��Ϊ�ж� end ��λ���� begin ���ڵ��еĵ�һ���ǿ��ַ��Ƿ�Ե��Ϻ�
            Text := CnOtaGetLineText(Parser.InnerBlockStartToken.EditLine + 1, View.Buffer);
            ACol := 0;
            while (ACol < Length(Text)) and CharInSet(Text[ACol + 1], [' ', #9]) do
              Inc(ACol);
            NeedInsert := ACol + 1 <> Parser.InnerBlockCloseToken.EditCol;
            // һ�� 0 ��ʼ��һ�� 1 ��ʼ�������Ҫ��һ�Ƚ�

            // �����Ҫ��Ҳ��������ˣ������ж���� end ������ end. ������Ҫ��
            if not NeedInsert then
              if not IsDpr(View.Buffer.FileName) and
                IsDotAfterTokenEnd(Parser.InnerBlockCloseToken) then
                NeedInsert := True;

            // �����Ȼ��Ҫ�ӣ��򻹵��ж�һ��������Ĳ���Ƿ������ȷ������Ի���Ҫ��
            if not NeedInsert then
            begin
              if (Parser.BlockStartToken <> nil) and (Parser.BlockCloseToken <> nil) then
              begin
                if Parser.BlockStartToken.ItemLayer < Parser.BlockCloseToken.ItemLayer then
                  NeedInsert := True
                else if Parser.BlockStartToken.ItemLayer = Parser.BlockCloseToken.ItemLayer then
                begin
                  // ����������ԵĻ��������ж�һ������ǲ��� end. �ǵ�����Ҫ��
                  if not IsDpr(View.Buffer.FileName) and
                    IsDotAfterTokenEnd(Parser.BlockCloseToken) then
                    NeedInsert := True;
                end;
              end;
            end;
          end;
        end
        else // �����ʱ��Ҳ��
          NeedInsert := True;
      finally
        Stream.Free;
        Parser.Free;
      end;

      if not NeedInsert then Exit;

      CnOtaInsertTextToCurSource(#13#10'end;');
      View.Buffer.EditPosition.MoveRelative(-1, CnOtaGetBlockIndent - 4 );
      // ����״̬�²Ų��룬��4�Ǽ�ȥend; �ĳ���
      View.Paint;

      if FNeedChangeInsert then // ���ԭ���Ǹ�д״̬���ָ���д״̬
      begin
        FNeedChangeInsert := False;
        View.Buffer.BufferOptions.InsertMode := False;
      end;
    end;
  end;
end;

function TCnSrcEditorKey.DoAutoIndent(View: IOTAEditView; Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean): Boolean;
var
  Text: string;
  LineNo: Integer;
  CharIdx: Integer;
  i, Idx: Integer;
  NeedIndent: Boolean;
begin
  Result := False;
  Handled := False;
  if (Key = VK_RETURN) and not (ssCtrl in Shift) and not View.Block.IsValid
    and CurrentIsSource then
  begin
    if CnNtaGetCurrLineText(Text, LineNo, CharIdx) then
    begin
      if CharIdx >= Length(Text) then  // ����ĩβ
      begin
        Text := Trim(Text);
        if Text <> '' then
        begin
          NeedIndent := False;
          if CurrentIsDelphiSource then
          begin
            if FAutoIndent then
            begin
              Idx := 0;
              for i := Length(Text) downto 1 do
              begin
                if not IsValidIdentChar(Text[i]) then
                begin
                  Idx := i;
                  Break;
                end;
              end;

              Text := Copy(Text, Idx + 1, MaxInt);
              if FAutoIndentList.IndexOf(Text) >= 0 then
                NeedIndent := True;
            end;

            // ����һ��С���ܣ��ڲ���״̬ʱ��begin ���Զ� end ���벢����
            if FAutoEnterEnd and (LowerCase(Text) = 'begin') then
            begin
              FSaveLineNo := LineNo;
              FNeedChangeInsert := not View.Buffer.BufferOptions.InsertMode;
              if FNeedChangeInsert then // �ǲ�����ĳɸ�д
                View.Buffer.BufferOptions.InsertMode := True;
              CnWizNotifierServices.ExecuteOnApplicationIdle(IdleDoAutoInput);
            end;
          end
          else if IsCppSourceModule(CnOtaGetCurrentSourceFile) then
          begin
            if Text[Length(Text)] = '{' then
              NeedIndent := True
          end;

          if NeedIndent then
          begin
            FSaveLineNo := LineNo;
            CnWizNotifierServices.ExecuteOnApplicationIdle(IdleDoAutoIndent);
          end;
        end;
      end
      else // ������ĩβ
      begin
        if (CharIdx = Length(Text) - 1) and IsCppSourceModule(CnOtaGetCurrentSourceFile) then
        begin
          if (Text[CharIdx] = '{') and (Text[CharIdx + 1] = '}') then
          begin
            FSaveLineNo := LineNo;
            CnWizNotifierServices.ExecuteOnApplicationIdle(IdleDoCBracketIndent);
          end;
        end;
      end;
    end;
  end;
end;

{$ENDIF}

function TCnSrcEditorKey.DoHomeExtend(View: IOTAEditView; Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean): Boolean;
var
  Text: string;
  LineNo: Integer;
  CharIdx: Integer;
  Idx: Integer;
begin
  Result := False;
  if (Key = VK_HOME) and (Shift = []) then
  begin
    if CnNtaGetCurrLineText(Text, LineNo, CharIdx) and (Trim(Text) <> '') then
    begin
      Idx := 0;
      while Idx < Length(Text) do
      begin
        if Text[Idx + 1] <> ' ' then
          Break
        else
          Inc(Idx);
      end;

      if Idx > 0 then
      begin
        if CharIdx = 0 then
        begin
          View.Buffer.EditPosition.MoveRelative(0, Idx);
        end
        else
        begin
          if FHomeFirstChar and (CharIdx <> Idx) then
            View.Buffer.EditPosition.Move(View.CursorPos.Line, Idx + 1)
          else
            View.Buffer.EditPosition.MoveBOL
        end;
        Handled := True;
        Result := True;
        View.Paint;
      end;
    end;
  end;
end;

function TCnSrcEditorKey.DoLeftRightLineWrap(View: IOTAEditView; Key,
  ScanCode: Word; Shift: TShiftState; var Handled: Boolean): Boolean;
var
  Text: string;
  LineNo: Integer;
  CharIdx: Integer;
  Len: Integer;
begin
  Result := False;
  Handled := False;
  if ((Key = VK_LEFT) or (Key = VK_RIGHT)) and not (ssCtrl in Shift)
    and not View.Block.IsValid and CurrentIsSource then
  begin
    if CnNtaGetCurrLineText(Text, LineNo, CharIdx) then
    begin
      if (CharIdx = 0) and (Key = VK_LEFT) then // ������������һ��β
      begin
        Result := View.Buffer.EditPosition.MoveRelative(-1, 0)
          and View.Buffer.EditPosition.MoveEOL;
        Handled := Result;
      end
      else if Key = VK_RIGHT then  // ��β��������һ��ͷ
      begin
{$IFDEF UNICODE}
        CharIdx := View.CursorPos.Col - 1;
        Len := Length(AnsiString(Text));
{$ELSE}
        Len := Length(Text);
{$ENDIF}
        if CharIdx >= Len then
        begin
          View.Buffer.EditPosition.MoveRelative(1, 0);
          View.Buffer.EditPosition.MoveBOL;
          Result := True;
          Handled := Result;
        end;
      end;
      if Result then
        View.Paint;
    end;
  end;
end;

function TCnSrcEditorKey.DoSemicolonLastChar(View: IOTAEditView; Key,
  ScanCode: Word; Shift: TShiftState; var Handled: Boolean): Boolean;
var
  EditControl: TControl;
  Element, LineFlag: Integer;
  Text: string;
  EditPos: TOTAEditPos;
  AChar: Char;
  Lex: TmwPasLex;
  CParser: TBCBTokenList;
  CanMove: Boolean;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  Stack: TStack;
  IsInProcDeclare: Boolean;
  RoundCount: Integer;
  IsInFor: Boolean;

  procedure MoveToLineEnd;
  begin
{$IFDEF UNICODE}
    // GetAttributeAtPos ��Ҫ���� UTF8 ��Pos����� UNICODE �½��� Col �� UTF8 ת��
    EditPos.Col := Length(CnAnsiToUtf8({$IFDEF UNICODE}AnsiString{$ENDIF}(Text)));
{$ELSE}
    EditPos.Col := Length(Text);
{$ENDIF}
    EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);
    if not (Element in [atComment]) then // �����β��ע�ͣ��Ͳ���ֱ���ƶ�����β
    begin
      View.Buffer.EditPosition.MoveEOL;
      Result := True;
      View.Paint;
    end
    else // TODO: �����һ������ע�͵ĵط�
    begin
      while (Element in [atComment]) and (EditPos.Col > 0) do
      begin
        Dec(EditPos.Col);
        EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);
      end;

      if EditPos.Col > 0 then
      begin
        // �ҵ������һ������ע�͵ĵط�
{$IFDEF UNICODE}
        // �� UTF8 �� Pos��ת���� Ansi ��
        EditPos.Col := Length(CnUtf8ToAnsi({$IFDEF UNICODE}AnsiString{$ENDIF}(Copy(Text, 1, EditPos.Col))));
{$ENDIF}
        View.Buffer.EditPosition.Move(EditPos.Line, EditPos.Col);
        View.Paint;
        Result := True;
      end;
    end;
  end;

begin
  Result := False;
  Handled := False;

  EditControl := CnOtaGetCurrentEditControl;
  if EditControl = nil then
    Exit;

  Text := GetStrProp(EditControl, 'LineText');
  if Trim(Text) = '' then
    Exit;

  if CanIgnoreFromIME then
    Exit;

  AChar := Char(VK_ScanCodeToAscii(Key, ScanCode));

  if (AChar = ';') and (Shift = []) then
  begin
    EditPos := View.CursorPos;
{$IFDEF UNICODE}
    // GetAttributeAtPos ��Ҫ���� UTF8 ��Pos����� D2009 �½��� Col �� UTF8 ת��
    EditPos.Col := Length(CnAnsiToUtf8({$IFDEF UNICODE}AnsiString{$ENDIF}(Copy(Text, 1, EditPos.Col))));
{$ENDIF}

    EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);
    if not (Element in [atString, atComment, atAssembler]) then
    begin
      CanMove := True;
      Stream := TMemoryStream.Create;
      CnOtaSaveEditorToStream(View.Buffer, Stream);
      EditPos := View.CursorPos;
      View.ConvertPos(True, EditPos, CharPos);
      Stack := TStack.Create;
      RoundCount := 0;

      try
        if IsDprOrPas(View.Buffer.FileName) or IsInc(View.Buffer.FileName) then
        begin
          // ���﷨�����ķ�ʽ���жϵ�ǰλ���Ƿ�Ӧ���ƶ�
          // procedure/function ��δ�� begin/asm �䣬�����ƶ���
          // class/interface end֮�䣬�����ƶ���
          Lex := TmwPasLex.Create;
          try
            Lex.Origin := PAnsiChar(Stream.Memory);
            IsInProcDeclare := False;

            // �����ѵ����λ�ü��ɣ��������Ѻ���
            while (Lex.TokenID <> tkNull) and ((Lex.LineNumber < CharPos.Line - 1)
              or ((Lex.LineNumber = CharPos.Line - 1) and (Lex.TokenPos - Lex.LinePos < CharPos.CharIndex))) do
            begin
              case Lex.TokenID of
                tkRoundOpen:
                  if IsInProcDeclare then
                    Inc(RoundCount);
                tkRoundClose:
                  if IsInProcDeclare then
                    Dec(RoundCount);
                tkProcedure, tkFunction, tkConstructor, tkDestructor: // ��������δ�� begin ��������
                  begin
                    Stack.Push(Pointer(CanMove));
                    IsInProcDeclare := True;
                    RoundCount := 0;
                    CanMove := False;
                  end;
                tkBegin, tkAsm: // begin/asm ����������
                  begin
                    if RoundCount = 0 then
                      IsInProcDeclare := False;
                    Stack.Push(Pointer(CanMove));
                    CanMove := True;
                  end;
                tkClass, tkInterface, tkDispinterface, tkRecord, tkObject:
                  begin
                    Stack.Push(Pointer(CanMove));
                    CanMove := False;
                  end;
                tkEnd:
                  begin
                    if Stack.Count > 0 then
                      CanMove := Boolean(Stack.Pop);
                    if RoundCount = 0 then
                      IsInProcDeclare := False;
                  end;
                tkUses: // �ݲ����ǹ����ڲ���const/var���������Ϊ����
                  CanMove := True;
                tkVar, tkConst: // ���ֹ������������� var �� const
                  CanMove := RoundCount = 0;
              end;

              Lex.NextNoJunk;
            end;
          finally
            Lex.Free;
          end;
        end
        else if IsCppSourceModule(View.Buffer.FileName) then
        begin
          CParser := TBCBTokenList.Create;
          try
            // C �ļ���Ŀǰֻ���� for �еķֺŲ���Ҫ�ƶ������������δ������
            CParser.SetOrigin(PAnsiChar(Stream.Memory), Stream.Size);
            IsInFor := False;
            while (CParser.RunID <> ctknull) and ((CParser.RunLineNumber < CharPos.Line)
              or ((CParser.RunLineNumber = CharPos.Line) and (CParser.RunColNumber < CharPos.CharIndex))) do
            begin
              case CParser.RunID of
                ctkfor:
                  begin
                    IsInFor := True;
                    RoundCount := 0;
                  end;
                ctkroundopen:
                  begin
                    if IsInFor then
                      Inc(RoundCount);
                  end;
                ctkroundclose:
                  begin
                    if IsInFor then
                    begin
                      Dec(RoundCount);
                      if RoundCount = 0 then
                        IsInFor := False;
                    end;
                  end;
              end;
              CParser.NextNonJunk;
            end;

            CanMove := not IsInFor or (RoundCount <> 1);
          finally
            CParser.Free;
          end;
        end;
      finally
        Stream.Free;
        Stack.Free;
      end;

      if CanMove then
        MoveToLineEnd;
    end
    else if EditPos.Col > 0 then // ������ǣ�Ҳ�п��ܹ���ڵ����Ż������ǰһ�񣬴�ʱҲӦ���ƶ�
    begin
      // ����м�һ���������
      Dec(EditPos.Col);
      EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);
      // �����һ����Ȼ����ע�ͻ��ַ���������
      if not (Element in [atString, atComment, atAssembler]) then
        MoveToLineEnd;

      // ��Ŀǰ���ڹ�������������Ĵ�����ע��֮��Ҳ���� {}|{} ������������޷�����
    end;
  end;
end;

{$HINTS OFF}

function TCnSrcEditorKey.DoRename(View: IOTAEditView; Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean): Boolean;
var
  Cur, UpperCur, UpperHeadCur, NewName: string;
  CurIndex: Integer;
  EditControl: TControl;
  EditView: IOTAEditView;
  Parser: TCnPasStructureParser;
  CParser: TCnCppStructureParser;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  I, iMaxCursorOffset: Integer;
  Rit: TCnRenameIdentifierType;
  iStart, iOldTokenLen: Integer;
  NewCode: string;
  EditWriter: IOTAEditWriter;
  CurToken, LastToken, StartToken, EndToken, StartCurToken, EndCurToken: TCnPasToken;
  CurFuncStartToken, CurFuncEndToken: TCnCppToken;
  FirstEnter: Boolean;
  LastTokenPos: Integer;
  FrmModalResult: Boolean;
  BookMarkList: TObjectList;
  Element, LineFlag: Integer;
  CurTokens: TList;
  F: string;
  FSrcEditor: IOTASourceEditor;
begin
  Result := False;
  if (Key <> FRenameKey) or (Shift <> FRenameShift) then Exit;

  if (GetIDEActionFromShortCut(ShortCut(VK_F2, [])) <> nil) and
    GetIDEActionFromShortCut(ShortCut(VK_F2, [])).Visible then
    Exit; // ����Ѿ����� F2 �Ŀ�ݼ��� Action���򲻴���

  if not CnOtaGetCurrPosToken(Cur, CurIndex) then
    Exit;
  if Cur = '' then Exit;
  
  // �� F2 ���ĵ�ǰ�������Ķ���
  BookMarkList := nil;
  EditControl := CnOtaGetCurrentEditControl;
  if EditControl = nil then
    Exit;
  try
    EditView := EditControlWrapper.GetEditView(EditControl);
  except
    Exit;
  end;

  if EditView = nil then
    Exit;

  // ����Ǳ���ָ���ڲ������˳�����Ϊ���ڼ�ʹ����Ҳ������ġ�
  EditControlWrapper.GetAttributeAtPos(EditControl, EditView.CursorPos,
    False, Element, LineFlag);
  if Element in [atComment, atPreproc] then
    Exit;

  // ���� Pascal �ļ�
  if IsDprOrPas(EditView.Buffer.FileName) or IsInc(EditView.Buffer.FileName) then
  begin
    Parser := TCnPasStructureParser.Create;
    Stream := TMemoryStream.Create;
    try
      CnOtaSaveEditorToStream(EditView.Buffer, Stream);

      // ������ǰ��ʾ��Դ�ļ�
      Parser.ParseSource(PAnsiChar(Stream.Memory),
        IsDpr(EditView.Buffer.FileName) or IsInc(EditView.Buffer.FileName), False);
    finally
      Stream.Free;
    end;

    // �������ٲ��ҵ�ǰ������ڵĿ�
    EditPos := EditView.CursorPos;
    EditView.ConvertPos(True, EditPos, CharPos);
    Parser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);

    try
      CurToken := nil;
      CurTokens := TList.Create;
      UpperCur := UpperCase(Cur);

      // ��ת�����������������±�ʶ����ͬ�� Token
      for I := 0 to Parser.Count - 1 do
      begin
        CharPos := OTACharPos(Parser.Tokens[I].CharIndex, Parser.Tokens[I].LineNumber + 1);
        EditView.ConvertPos(False, EditPos, CharPos);

        Parser.Tokens[I].EditCol := EditPos.Col;
        Parser.Tokens[I].EditLine := EditPos.Line;

        if (Parser.Tokens[I].TokenID = tkIdentifier) and (UpperCase(string(Parser.Tokens[I].Token)) = UpperCur) then
        begin
          CurTokens.Add(Parser.Tokens[I]);
          if (CurToken = nil) and
            IsCurrentToken(Pointer(EditView), EditControl, Parser.Tokens[I]) then
            CurToken := Parser.Tokens[I];
        end;
      end;
      if CurTokens.Count = 0 then Exit;

      // �����ǰ����µ� Token �� InnerMethod ֮�䣬�������е� Token ����
      // InnerMethod ֮�䣬�� RIT Ϊ InnerProc
      // else �����ǰ����µ� Token �� CurrentMethod ֮�䣬�������е� Token ����
      // CurrentMethod ֮�䣬�� RIT Ϊ CurrentProc
      // else RIT Ϊ Unit

      Rit := ritInvalid;
      if Assigned(Parser.ChildMethodStartToken) and
        Assigned(Parser.ChildMethodCloseToken) then
      begin
        if (TCnPasToken(CurTokens[0]).ItemIndex >= Parser.ChildMethodStartToken.ItemIndex)
          and (TCnPasToken(CurTokens[CurTokens.Count - 1]).ItemIndex
          <= Parser.ChildMethodCloseToken.ItemIndex) then
          Rit := ritInnerProc;
      end;
      if Rit = ritInvalid then
      begin
        if Assigned(Parser.MethodStartToken) and
          Assigned(Parser.MethodCloseToken) then
        begin
          if (TCnPasToken(CurTokens[0]).ItemIndex >= Parser.MethodStartToken.ItemIndex)
            and (TCnPasToken(CurTokens[CurTokens.Count - 1]).ItemIndex
            <= Parser.MethodCloseToken.ItemIndex) then
            Rit := ritCurrentProc;
        end;
      end;
      if Rit = ritInvalid then
        Rit := ritUnit;

      // �����Ի����������滻��Χ���������Ƿ��е�ǰ Method/Child �ȿ��ƽ���ʹ��
      with TCnIdentRenameForm.Create(nil) do
      begin
        try
          lblReplacePromt.Caption := Format(SCnRenameVarHintFmt, [Cur]);
          UpperHeadCur := Cur;
          if FUpperFirstLetter and (Length(UpperHeadCur) >= 1) and
            CharInSet(UpperHeadCur[1], ['a'..'z']) then
            UpperHeadCur[1] := Chr(Ord(UpperHeadCur[1]) - 32);
          edtRename.Text := UpperHeadCur;

          rbCurrentProc.Enabled := Assigned(Parser.MethodStartToken) and
            Assigned(Parser.MethodCloseToken);
          rbCurrentInnerProc.Enabled := Assigned(Parser.ChildMethodStartToken) and
            Assigned(Parser.ChildMethodCloseToken);

          if rbCurrentProc.Enabled then
            rbCurrentProc.Checked := True;
          if rbCurrentInnerProc.Enabled then
            rbCurrentInnerProc.Checked := True;
          if (not rbCurrentProc.Checked) and (not rbCurrentInnerProc.Checked) then
            rbUnit.Checked := True;

          rbCppHPair.Enabled := False;
          rbCppHPair.Checked := False;

          FrmModalResult := ShowModal = mrOk;
          NewName := edtRename.Text;

          if rbCurrentProc.Checked then
            Rit := ritCurrentProc
          else if rbCurrentInnerProc.Checked then
            Rit := ritInnerProc
          else
            Rit := ritUnit;
        finally
          Free;
        end;
      end;

      if FrmModalResult then
      begin
        if not IsValidRenameIdent(NewName) then
        begin
          ErrorDlg(SCnRenameErrorValid);
          Exit;
        end;

        StartToken := nil;
        EndToken := nil;

        // ע�� StartToken �� EndToken δ�������� CurTokens �еġ�
        // StartCurToken �� EndCurToken ���� CurTokens �б��е�ͷβ��
        if Rit = ritUnit then
        begin
          // �滻��ΧΪ���� unit ʱ����ʼ���ս� Token Ϊ�б���ͷβ��
          StartToken := TCnPasToken(CurTokens[0]);
          EndToken := TCnPasToken(CurTokens[CurTokens.Count - 1]);
        end
        else if Rit = ritCurrentProc then
        begin
          StartToken := Parser.MethodStartToken;
          EndToken := Parser. MethodCloseToken;
        end
        else if Rit = ritInnerProc then
        begin
          StartToken := Parser.ChildMethodStartToken;
          EndToken := Parser.ChildMethodCloseToken;
        end;

        if (StartToken = nil) or (EndToken = nil) then Exit;

        // ��¼�� View �� Bookmarks
        BookMarkList := TObjectList.Create(True);
        SaveBookMarksToObjectList(EditView, BookMarkList);

        NewCode := '';
        LastToken := nil;
        FirstEnter := True;
        iStart := 0;
        iMaxCursorOffset := EditView.CursorPos.Col - CurToken.EditCol;
        StartCurToken := nil;
        EndCurToken := nil;
        EditWriter := CnOtaGetEditWriterForSourceEditor;

        // ִ����ѭ����NewCode Ӧ��Ϊ��������Ҫ�滻������ Token ���滻������
        for I := 0 to CurTokens.Count - 1 do
        begin
          if (TCnPasToken(CurTokens[I]).ItemIndex >= StartToken.ItemIndex) and
            (TCnPasToken(CurTokens[I]).ItemIndex <= EndToken.ItemIndex) then
          begin
            // ����Ҫ����֮�С���һ�أ�����ͷ�����ѭ������β
            if FirstEnter then
            begin
              StartCurToken := TCnPasToken(CurTokens[I]); // ��¼��һ�� CurToken
              FirstEnter := False;
            end;

            if LastToken = nil then
              NewCode := NewName
            else
            begin
              // ����һ Token ��β�ͣ������� Token ��ͷ���ټ��滻������֣����� AnsiString ������
              LastTokenPos := LastToken.TokenPos + Length(LastToken.Token);
              NewCode := NewCode + string(Copy(AnsiString(Parser.Source), LastTokenPos + 1,
                TCnPasToken(CurTokens[I]).TokenPos - LastTokenPos)) + NewName;
            end;
  {$IFDEF DEBUG}
            CnDebugger.LogMsg('Pas NewCode: ' + NewCode);
  {$ENDIF}
            // ͬһ��ǰ��Ļ�Ӱ����λ��
            if (TCnPasToken(CurTokens[I]).EditLine = CurToken.EditLine) and
              (TCnPasToken(CurTokens[I]).EditCol < CurToken.EditCol) then
              Inc(iStart);

            LastToken := TCnPasToken(CurTokens[I]);   // ��¼��һ��������� CurToken
            EndCurToken := TCnPasToken(CurTokens[I]); // ��¼���һ�� CurToken
          end;
        end;

        if StartCurToken <> nil then
          EditWriter.CopyTo(StartCurToken.TokenPos);

        if EndCurToken <> nil then
          EditWriter.DeleteTo(EndCurToken.TokenPos + Length(EndCurToken.Token));

        EditWriter.Insert(PAnsiChar(ConvertTextToEditorText(AnsiString(NewCode))));

        // �������λ��
        iOldTokenLen := Length(Cur);
        if iStart > 0 then
          CnOtaMovePosInCurSource(ipCur, 0, iStart * (Length(NewName) - iOldTokenLen))
        else if iStart = 0 then
          CnOtaMovePosInCurSource(ipCur, 0, Max(-iMaxCursorOffset, Length(NewName) - iOldTokenLen));
        EditView.Paint;

        // �ָ��� View �� Bookmarks
        LoadBookMarksFromObjectList(EditView, BookMarkList);
      end;
    finally
      FreeAndNil(CurTokens);
      FreeAndNil(Parser);
      FreeAndNil(BookMarkList);
    end;
  end
  else if IsCppSourceModule(EditView.Buffer.FileName) then // C/C++ �ļ�
  begin
    // �ж�λ�ã�������Ҫ�����������塣
    CParser := TCnCppStructureParser.Create;
    Stream := TMemoryStream.Create;
    try
      CnOtaSaveEditorToStream(EditView.Buffer, Stream);
      // ������ǰ��ʾ��Դ�ļ�
      CParser.ParseSource(PAnsiChar(Stream.Memory), Stream.Size,
        EditView.CursorPos.Line, EditView.CursorPos.Col, True);
    finally
      Stream.Free;
    end;

    try
      CurToken := nil;
      CurTokens := TList.Create;

      // ��ת�����������������±�ʶ����ͬ�� Token�����ִ�Сд
      for I := 0 to CParser.Count - 1 do
      begin
        CharPos := OTACharPos(CParser.Tokens[I].CharIndex - 1, CParser.Tokens[I].LineNumber);
        try
          EditView.ConvertPos(False, EditPos, CharPos);
        except
          Continue; // D5/6 �� ConvertPos ��ֻ��һ�����ں�ʱ�����ֻ������
        end;

        CParser.Tokens[I].EditCol := EditPos.Col;
        CParser.Tokens[I].EditLine := EditPos.Line;

        if (CParser.Tokens[I].CppTokenKind = ctkidentifier) and (string(CParser.Tokens[I].Token) = Cur) then
        begin
          CurTokens.Add(CParser.Tokens[I]);
          if (CurToken = nil) and
            IsCurrentToken(Pointer(EditView), EditControl, CParser.Tokens[I]) then
            CurToken := CParser.Tokens[I];
        end;
      end;
      if CurTokens.Count = 0 then Exit;

      CurFuncStartToken := nil;
      CurFuncEndToken := nil;

      // ���ȣ��ҳ���ȷ�� CurrentFunc�������ķ� namespace�������㣨��������� namespace��
      if not CParser.BlockIsNamespace and (CParser.BlockStartToken <> nil) and
        (CParser.BlockCloseToken <> nil) then
      begin
        CurFuncStartToken := CParser.BlockStartToken;
        CurFuncEndToken := CParser.BlockCloseToken;
      end
      else if CParser.BlockIsNamespace and (CParser.ChildStartToken <> nil) and
        (CParser.ChildCloseToken <> nil) then
      begin
        CurFuncStartToken := CParser.ChildStartToken;
        CurFuncEndToken := CParser.ChildCloseToken;
      end;

      // �����ǰ����µ� Token �� InnerBlock ֮�䣬�������е� Token ����
      // InnerBlock ֮�䣬���� InnerBlock ���� CurFunc���� RIT Ϊ InnerProc
      // �����ǰ����µ� Token �� CurFunc ֮�䣬�������е� Token ����
      // CurFun ֮�䣬�� RIT Ϊ CurrentProc
      // ��������ʱ��RIT Ϊ Unit
      Rit := ritInvalid;
      if (CParser.InnerBlockStartToken <> nil) and (CParser.InnerBlockCloseToken <> nil)
        and (CParser.InnerBlockStartToken <> CurFuncStartToken) and
            (CParser.InnerBlockCloseToken <> CurFuncEndToken) then
      begin
        if (TCnPasToken(CurTokens[0]).ItemIndex >= CParser.InnerBlockStartToken.ItemIndex)
          and (TCnPasToken(CurTokens[CurTokens.Count - 1]).ItemIndex
          <= CParser.InnerBlockCloseToken.ItemIndex) then
          Rit := ritInnerProc;
      end;

      if (Rit = ritInvalid) and (CurFuncStartToken <> nil) and (CurFuncEndToken <> nil) then
      begin
        if (TCnPasToken(CurTokens[0]).ItemIndex >= CurFuncStartToken.ItemIndex)
          and (TCnPasToken(CurTokens[CurTokens.Count - 1]).ItemIndex
          <= CurFuncEndToken.ItemIndex) then
          Rit := ritCurrentProc;
      end;

      if Rit = ritInvalid then
        Rit := ritUnit;

{$IFDEF DEBUG}
      CnDebugger.LogMsg('Cpp F2 Rename. Calc Rit to ' + IntToStr(Ord(Rit)));
{$ENDIF}

      // �����Ի���
      with TCnIdentRenameForm.Create(nil) do
      begin
        try
          lblReplacePromt.Caption := Format(SCnRenameVarHintFmt, [Cur]);
          UpperHeadCur := Cur;
          if FUpperFirstLetter and (Length(UpperHeadCur) >= 1) and
            CharInSet(UpperHeadCur[1], ['a'..'z']) then
            UpperHeadCur[1] := Chr(Ord(UpperHeadCur[1]) - 32);
          edtRename.Text := UpperHeadCur;

          rbCurrentProc.Enabled := Assigned(CurFuncStartToken) and
            Assigned(CurFuncEndToken);
          rbCurrentInnerProc.Enabled := Assigned(CParser.InnerBlockStartToken) and
            Assigned(CParser.InnerBlockCloseToken) and
            (CParser.InnerBlockStartToken <> CurFuncStartToken) and
            (CParser.InnerBlockCloseToken <> CurFuncEndToken);

          if rbCurrentProc.Enabled and (Rit <> ritUnit) then // ��ʶ����Χ���� CurFunc ʱ��Ĭ�ϲ�ѡ����㺯������
            rbCurrentProc.Checked := True;
          if rbCurrentInnerProc.Enabled and (Rit = ritInnerProc) then // ��ʶ��ֻ�����ڲ���ʱ��ѡ�����ڲ�ѡ��
            rbCurrentInnerProc.Checked := True;
          if (not rbCurrentProc.Checked) and (not rbCurrentInnerProc.Checked) then
            rbUnit.Checked := True;

          F := EditView.Buffer.FileName;
          // Cpp/H �ļ����ڴ�״̬���ѡ��ʹ��
          rbCppHPair.Enabled := (IsCpp(F) and CnOtaIsFileOpen(_CnChangeFileExt(F, '.h')))
            or (IsH(F) and CnOtaIsFileOpen(_CnChangeFileExt(F, '.cpp')));

          FrmModalResult := ShowModal = mrOk;
          NewName := edtRename.Text;

          if rbCurrentProc.Checked then
            Rit := ritCurrentProc
          else if rbCurrentInnerProc.Checked then
            Rit := ritInnerProc
          else if rbUnit.Checked then
            Rit := ritUnit
          else
            Rit := ritCppHPair;
        finally
          Free;
        end;
      end;

      if FrmModalResult then
      begin
        if not IsValidRenameIdent(NewName) then
        begin
          ErrorDlg(SCnRenameErrorValid);
          Exit;
        end;

        StartToken := nil;
        EndToken := nil;
        if Rit in [ritUnit, ritCppHPair] then
        begin
          // �滻��ΧΪ���� C ʱ����ʼ���ս� Token Ϊ�б���ͷβ��
          StartToken := TCnPasToken(CurTokens[0]);
          EndToken := TCnPasToken(CurTokens[CurTokens.Count - 1]);
        end
        else if Rit = ritCurrentProc then
        begin
          StartToken := CurFuncStartToken;
          EndToken := CurFuncEndToken;
        end
        else if Rit = ritInnerProc then
        begin
          StartToken := CParser.InnerBlockStartToken;
          EndToken := CParser.InnerBlockCloseToken;
        end;

        if (StartToken = nil) or (EndToken = nil) then Exit;

        // ��¼�� View �� Bookmarks
        BookMarkList := TObjectList.Create(True);
        SaveBookMarksToObjectList(EditView, BookMarkList);

        NewCode := '';
        LastToken := nil;
        FirstEnter := True;
        iStart := 0;
        iMaxCursorOffset := EditView.CursorPos.Col - CurToken.EditCol;

        StartCurToken := nil;
        EndCurToken := nil;
        EditWriter := CnOtaGetEditWriterForSourceEditor;

        // ִ����ѭ����NewCode Ӧ��Ϊ��������Ҫ�滻������ Token ���滻������
        for I := 0 to CurTokens.Count - 1 do
        begin
          if (TCnPasToken(CurTokens[I]).ItemIndex >= StartToken.ItemIndex) and
            (TCnPasToken(CurTokens[I]).ItemIndex <= EndToken.ItemIndex) then
          begin
            // ����Ҫ����֮�С���һ�أ�����ͷ�����ѭ������β
            if FirstEnter then
            begin
              StartCurToken := TCnPasToken(CurTokens[I]); // ��¼��һ�� CurToken
              FirstEnter := False;
            end;

            if LastToken = nil then
              NewCode := NewName
            else
            begin
              // ����һ Token ��β�ͣ������� Token ��ͷ���ټ��滻������֣����� AnsiString ������
              LastTokenPos := LastToken.TokenPos + Length(LastToken.Token);
              NewCode := NewCode + string(Copy(AnsiString(CParser.Source), LastTokenPos + 1,
                TCnPasToken(CurTokens[I]).TokenPos - LastTokenPos)) + NewName;
            end;
  {$IFDEF DEBUG}
            CnDebugger.LogMsg('Cpp NewCode: ' + NewCode);
  {$ENDIF}
            // ͬһ��ǰ��Ļ�Ӱ����λ��
            if (TCnPasToken(CurTokens[I]).EditLine = CurToken.EditLine) and
              (TCnPasToken(CurTokens[I]).EditCol < CurToken.EditCol) then
              Inc(iStart);

            LastToken := TCnPasToken(CurTokens[I]);   // ��¼��һ��������� CurToken
            EndCurToken := TCnPasToken(CurTokens[I]); // ��¼���һ�� CurToken
          end;
        end;

        if StartCurToken <> nil then
          EditWriter.CopyTo(StartCurToken.TokenPos);

        if EndCurToken <> nil then
          EditWriter.DeleteTo(EndCurToken.TokenPos + Length(EndCurToken.Token));

        EditWriter.Insert(PAnsiChar(ConvertTextToEditorText(AnsiString(NewCode))));

        // �������λ��
        iOldTokenLen := Length(Cur);
        if iStart > 0 then
          CnOtaMovePosInCurSource(ipCur, 0, iStart * (Length(NewName) - iOldTokenLen))
        else if iStart = 0 then
          CnOtaMovePosInCurSource(ipCur, 0, Max(-iMaxCursorOffset, Length(NewName) - iOldTokenLen));
        EditView.Paint;

        // �ָ��� View �� Bookmarks
        LoadBookMarksFromObjectList(EditView, BookMarkList);

        // ����һ���ļ�
        if Rit <> ritCppHPair then
          Exit;

        if IsCpp(F) then
          F := _CnChangeFileExt(F, '.h')
        else if IsH(F) then
          F := _CnChangeFileExt(F, '.cpp');
        if not CnOtaIsFileOpen(F) then
          Exit;

        // ��ͷ������һ���ļ��������滻
        FreeAndNil(CParser);
        FreeAndNil(CurTokens);
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Cpp Another Starting: ' + F);
{$ENDIF}

        EditView := CnOtaGetTopOpenedEditViewFromFileName(F);
        if EditView = nil then
          Exit;

{$IFDEF DEBUG}
        CnDebugger.LogMsg('Cpp Another SourceEditor and EditView Got.');
{$ENDIF}
        CurToken := nil;
        CurTokens := TList.Create;

        CParser := TCnCppStructureParser.Create;
        Stream := TMemoryStream.Create;
        try
          CnOtaSaveEditorToStream(FSrcEditor, Stream);
          // ������ǰ��ʾ��Դ�ļ�
          CParser.ParseSource(PAnsiChar(Stream.Memory), Stream.Size,
            1, 1, True);
        finally
          Stream.Free;
        end;

        // ��ת�����������������±�ʶ����ͬ�� Token�����ִ�Сд
        for I := 0 to CParser.Count - 1 do
        begin
          CharPos := OTACharPos(CParser.Tokens[I].CharIndex - 1, CParser.Tokens[I].LineNumber);
          try
            EditView.ConvertPos(False, EditPos, CharPos);
          except
            Continue; // D5/6 �� ConvertPos ��ֻ��һ�����ں�ʱ�����ֻ������
          end;

          CParser.Tokens[I].EditCol := EditPos.Col;
          CParser.Tokens[I].EditLine := EditPos.Line;

          if (CParser.Tokens[I].CppTokenKind = ctkidentifier) and (string(CParser.Tokens[I].Token) = Cur) then
            CurTokens.Add(CParser.Tokens[I]);
        end;
        if CurTokens.Count = 0 then Exit;

        // ��һ���ļ��������жϷ�Χ��ȫ���������Ҳ�������
        // ��¼�� View �� Bookmarks
        FreeAndNil(BookMarkList);
        BookMarkList := TObjectList.Create(True);
        SaveBookMarksToObjectList(EditView, BookMarkList);

        NewCode := '';
        LastToken := nil;
        FirstEnter := True;
        iStart := 0;

        StartCurToken := nil;
        EndCurToken := nil;
        EditWriter := CnOtaGetEditWriterForSourceEditor(FSrcEditor);

        // ִ����ѭ����NewCode Ӧ��Ϊ��������Ҫ�滻������ Token ���滻������
        for I := 0 to CurTokens.Count - 1 do
        begin
          // ����Ҫ����֮�С���һ�أ�����ͷ�����ѭ������β
          if FirstEnter then
          begin
            StartCurToken := TCnPasToken(CurTokens[I]); // ��¼��һ�� CurToken
            FirstEnter := False;
          end;

          if LastToken = nil then
            NewCode := NewName
          else
          begin
            // ����һ Token ��β�ͣ������� Token ��ͷ���ټ��滻������֣����� AnsiString ������
            LastTokenPos := LastToken.TokenPos + Length(LastToken.Token);
            NewCode := NewCode + string(Copy(AnsiString(CParser.Source), LastTokenPos + 1,
              TCnPasToken(CurTokens[I]).TokenPos - LastTokenPos)) + NewName;
          end;
{$IFDEF DEBUG}
          CnDebugger.LogMsg('Cpp Another NewCode: ' + NewCode);
{$ENDIF}
          LastToken := TCnPasToken(CurTokens[I]);   // ��¼��һ��������� CurToken
          EndCurToken := TCnPasToken(CurTokens[I]); // ��¼���һ�� CurToken
        end;

        if StartCurToken <> nil then
          EditWriter.CopyTo(StartCurToken.TokenPos);

        if EndCurToken <> nil then
          EditWriter.DeleteTo(EndCurToken.TokenPos + Length(EndCurToken.Token));

        EditWriter.Insert(PAnsiChar(ConvertTextToEditorText(AnsiString(NewCode))));
        // �ָ��� View �� Bookmarks
        LoadBookMarksFromObjectList(EditView, BookMarkList);
      end;
    finally
      FreeAndNil(CurTokens);
      FreeAndNil(CParser);
      FreeAndNil(BookMarkList);
    end;
  end;

  Handled := True;
end;

{$IFDEF IDE_WIDECONTROL}

procedure TCnSrcEditorKey.ConvertToUtf8Stream(Stream: TStream);
var
  S: AnsiString;
  Res: WideString;
begin
  if Stream = nil then
    Exit;
  SetLength(S, Stream.Size);
  Stream.Position := 0;

  Stream.Read(PAnsiChar(S)^, Stream.Size);
  Res := Utf8Decode(S);
  Stream.Size := 0;
  Stream.Position := 0;

  Stream.Write(PWideChar(Res)^, (Length(Res) + 1) * SizeOf(WideChar));
  Stream.Position := 0;
end;

// ���󲿷ָ����� DoRename����������벿���� Unicode/Utf8������ D2007 �����ϰ汾
function TCnSrcEditorKey.DoRenameW(View: IOTAEditView; Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean): Boolean;
var
  TmpCur: string;
  Cur, UpperCur, UpperHeadCur, NewName: WideString;
  CurIndex: Integer;
  EditControl: TControl;
  EditView: IOTAEditView;
  Parser: TCnWidePasStructParser;
  CParser: TCnWideCppStructParser;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  I, iMaxCursorOffset: Integer;
  Rit: TCnRenameIdentifierType;
  iStart, iOldTokenLen: Integer;
  NewCode: WideString;
  EditWriter: IOTAEditWriter;
  CurToken, LastToken, StartToken, EndToken, StartCurToken, EndCurToken: TCnWidePasToken;
  CurFuncStartToken, CurFuncEndToken: TCnWideCppToken;
  FirstEnter: Boolean;
  LastTokenPos: Integer;
  FrmModalResult: Boolean;
  BookMarkList: TObjectList;
  Element, LineFlag: Integer;
  CurTokens: TList;
  F: string;
  FEditor: IOTAEditor;
  FSrcEditor: IOTASourceEditor;
  SupportUnicode: Boolean;
begin
  Result := False;
  if (Key <> FRenameKey) or (Shift <> FRenameShift) then Exit;

  if (GetIDEActionFromShortCut(ShortCut(VK_F2, [])) <> nil) and
    GetIDEActionFromShortCut(ShortCut(VK_F2, [])).Visible then
    Exit; // ����Ѿ����� F2 �Ŀ�ݼ��� Action���򲻴���

{$IFDEF UNICODE}
  SupportUnicode := True;
  if not CnOtaGetCurrPosTokenW(TmpCur, CurIndex) then
    Exit;
{$ELSE}
  SupportUnicode := False;
  if not CnOtaGetCurrPosToken(TmpCur, CurIndex) then
    Exit;
{$ENDIF}

  if TmpCur = '' then
    Exit;

  Cur := TmpCur;

  // �� F2 ���ĵ�ǰ�������Ķ���
  BookMarkList := nil;
  EditControl := CnOtaGetCurrentEditControl;
  if EditControl = nil then
    Exit;
  try
    EditView := EditControlWrapper.GetEditView(EditControl);
  except
    Exit;
  end;

  if EditView = nil then
    Exit;

  // ����Ǳ���ָ���ڲ������˳�����Ϊ���ڼ�ʹ����Ҳ������ġ�
  EditControlWrapper.GetAttributeAtPos(EditControl, EditView.CursorPos,
    False, Element, LineFlag);
  if Element in [atComment, atPreproc] then
    Exit;

  // ���� Pascal �ļ�
  if IsDprOrPas(EditView.Buffer.FileName) or IsInc(EditView.Buffer.FileName) then
  begin
    Parser := TCnWidePasStructParser.Create(SupportUnicode);
    Stream := TMemoryStream.Create;
    try
{$IFDEF UNICODE}
      CnOtaSaveEditorToStreamW(EditView.Buffer, Stream);
{$ELSE}
      CnOtaSaveEditorToStream(EditView.Buffer, Stream, False, False); // ���� Utf8 ��
      // D2005~2007 ��ת�� WideString ����д�� Stream
      ConvertToUtf8Stream(Stream);
{$ENDIF}
      // ������ǰ��ʾ��Դ�ļ�
      Parser.ParseSource(PWideChar(Stream.Memory),
        IsDpr(EditView.Buffer.FileName) or IsInc(EditView.Buffer.FileName), False);
    finally
      Stream.Free;
    end;

    // �������ٲ��ҵ�ǰ������ڵĿ�
    EditPos := EditView.CursorPos;
    EditView.ConvertPos(True, EditPos, CharPos);
    Parser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);

    try
      CurToken := nil;
      CurTokens := TList.Create;
      UpperCur := UpperCase(Cur);

      // ��ת�����������������±�ʶ����ͬ�� Token
      for I := 0 to Parser.Count - 1 do
      begin
        CharPos := OTACharPos(Parser.Tokens[I].CharIndex, Parser.Tokens[I].LineNumber + 1);
        EditView.ConvertPos(False, EditPos, CharPos);
        // ��������� D2009 �д�����ʱ�������ƫ����ް취��
        // ���ֱ�Ӳ������� CharIndex + 1 �ķ�ʽ��Parser �����Ѷ� Tab ��չ����
        EditPos.Col := Parser.Tokens[I].CharIndex + 1;
        Parser.Tokens[I].EditCol := EditPos.Col;
        Parser.Tokens[I].EditLine := EditPos.Line;

        if (Parser.Tokens[I].TokenID = tkIdentifier) and (UpperCase(string(Parser.Tokens[I].Token)) = UpperCur) then
        begin
          CurTokens.Add(Parser.Tokens[I]);
          if (CurToken = nil) and
            IsCurrentTokenW(Pointer(EditView), EditControl, Parser.Tokens[I]) then
            CurToken := Parser.Tokens[I];
        end;
      end;
      if CurTokens.Count = 0 then Exit;

      // �����ǰ����µ� Token �� InnerMethod ֮�䣬�������е� Token ����
      // InnerMethod ֮�䣬�� RIT Ϊ InnerProc
      // else �����ǰ����µ� Token �� CurrentMethod ֮�䣬�������е� Token ����
      // CurrentMethod ֮�䣬�� RIT Ϊ CurrentProc
      // else RIT Ϊ Unit

      Rit := ritInvalid;
      if Assigned(Parser.ChildMethodStartToken) and
        Assigned(Parser.ChildMethodCloseToken) then
      begin
        if (TCnWidePasToken(CurTokens[0]).ItemIndex >= Parser.ChildMethodStartToken.ItemIndex)
          and (TCnWidePasToken(CurTokens[CurTokens.Count - 1]).ItemIndex
          <= Parser.ChildMethodCloseToken.ItemIndex) then
          Rit := ritInnerProc;
      end;
      if Rit = ritInvalid then
      begin
        if Assigned(Parser.MethodStartToken) and
          Assigned(Parser.MethodCloseToken) then
        begin
          if (TCnWidePasToken(CurTokens[0]).ItemIndex >= Parser.MethodStartToken.ItemIndex)
            and (TCnWidePasToken(CurTokens[CurTokens.Count - 1]).ItemIndex
            <= Parser.MethodCloseToken.ItemIndex) then
            Rit := ritCurrentProc;
        end;
      end;
      if Rit = ritInvalid then
        Rit := ritUnit;

      // �����Ի����������滻��Χ���������Ƿ��е�ǰ Method/Child �ȿ��ƽ���ʹ��
      with TCnIdentRenameForm.Create(nil) do
      begin
        try
          lblReplacePromt.Caption := Format(SCnRenameVarHintFmt, [Cur]);
          UpperHeadCur := Cur;
          if FUpperFirstLetter and (Length(UpperHeadCur) >= 1) and (CharInSet(Char(UpperHeadCur[1]), ['a'..'z'])) then
            UpperHeadCur[1] := WideChar(Chr(Ord(UpperHeadCur[1]) - 32));
          edtRename.Text := UpperHeadCur;

          rbCurrentProc.Enabled := Assigned(Parser.MethodStartToken) and
            Assigned(Parser.MethodCloseToken);
          rbCurrentInnerProc.Enabled := Assigned(Parser.ChildMethodStartToken) and
            Assigned(Parser.ChildMethodCloseToken);

          if rbCurrentProc.Enabled then
            rbCurrentProc.Checked := True;
          if rbCurrentInnerProc.Enabled then
            rbCurrentInnerProc.Checked := True;
          if (not rbCurrentProc.Checked) and (not rbCurrentInnerProc.Checked) then
            rbUnit.Checked := True;

          rbCppHPair.Enabled := False;
          rbCppHPair.Checked := False;

          FrmModalResult := ShowModal = mrOk;
          NewName := edtRename.Text;

          if rbCurrentProc.Checked then
            Rit := ritCurrentProc
          else if rbCurrentInnerProc.Checked then
            Rit := ritInnerProc
          else
            Rit := ritUnit;
        finally
          Free;
        end;
      end;

      if FrmModalResult then
      begin
        if not IsValidRenameIdent(NewName) then
        begin
          ErrorDlg(SCnRenameErrorValid);
          Exit;
        end;

        StartToken := nil;
        EndToken := nil;

        // ע�� StartToken �� EndToken δ�������� CurTokens �еġ�
        // StartCurToken �� EndCurToken ���� CurTokens �б��е�ͷβ��
        if Rit = ritUnit then
        begin
          // �滻��ΧΪ���� unit ʱ����ʼ���ս� Token Ϊ�б���ͷβ��
          StartToken := TCnWidePasToken(CurTokens[0]);
          EndToken := TCnWidePasToken(CurTokens[CurTokens.Count - 1]);
        end
        else if Rit = ritCurrentProc then
        begin
          StartToken := Parser.MethodStartToken;
          EndToken := Parser. MethodCloseToken;
        end
        else if Rit = ritInnerProc then
        begin
          StartToken := Parser.ChildMethodStartToken;
          EndToken := Parser.ChildMethodCloseToken;
        end;

        if (StartToken = nil) or (EndToken = nil) then Exit;

        // ��¼�� View �� Bookmarks
        BookMarkList := TObjectList.Create(True);
        SaveBookMarksToObjectList(EditView, BookMarkList);

        NewCode := '';
        LastToken := nil;
        FirstEnter := True;
        iStart := 0;
        iMaxCursorOffset := EditView.CursorPos.Col - CurToken.EditCol;
        StartCurToken := nil;
        EndCurToken := nil;
        EditWriter := CnOtaGetEditWriterForSourceEditor;

        // ִ����ѭ����NewCode Ӧ��Ϊ��������Ҫ�滻������ Token ���滻������
        for I := 0 to CurTokens.Count - 1 do
        begin
          if (TCnWidePasToken(CurTokens[I]).ItemIndex >= StartToken.ItemIndex) and
            (TCnWidePasToken(CurTokens[I]).ItemIndex <= EndToken.ItemIndex) then
          begin
            // ����Ҫ����֮�С���һ�أ�����ͷ�����ѭ������β
            if FirstEnter then
            begin
              StartCurToken := TCnWidePasToken(CurTokens[I]); // ��¼��һ�� CurToken
              FirstEnter := False;
            end;

            if LastToken = nil then
              NewCode := NewName
            else
            begin
              // ����һ Token ��β�ͣ������� Token ��ͷ���ټ��滻������֣����� AnsiString ������
              LastTokenPos := LastToken.TokenPos + Length(LastToken.Token);
              NewCode := NewCode + Copy(Parser.Source, LastTokenPos + 1,
                TCnWidePasToken(CurTokens[I]).TokenPos - LastTokenPos) + NewName;
            end;
  {$IFDEF DEBUG}
            CnDebugger.LogMsg('Pas NewCode: ' + NewCode);
  {$ENDIF}
            // ͬһ��ǰ��Ļ�Ӱ����λ��
            if (TCnWidePasToken(CurTokens[I]).EditLine = CurToken.EditLine) and
              (TCnWidePasToken(CurTokens[I]).EditCol < CurToken.EditCol) then
              Inc(iStart);

            LastToken := TCnWidePasToken(CurTokens[I]);   // ��¼��һ��������� CurToken
            EndCurToken := TCnWidePasToken(CurTokens[I]); // ��¼���һ�� CurToken
          end;
        end;

        if StartCurToken <> nil then
        begin
          // Ҫ������� UTF8 �ĳ��ȣ��� Paser ����� TokenPos �� Unicode �������Ҫת��
          EditWriter.CopyTo(Length(UTF8Encode(Copy(Parser.Source, 1, StartCurToken.TokenPos))));
        end;

        if EndCurToken <> nil then
        begin
          // Ҫ������� UTF8 �ĳ��ȣ��� Paser ����� TokenPos �� Unicode �������Ҫת��
          EditWriter.DeleteTo(Length(UTF8Encode(Copy(Parser.Source, 1,
            EndCurToken.TokenPos + Length(EndCurToken.Token)))));
        end;
{$IFDEF UNICODE}
        EditWriter.Insert(PAnsiChar(ConvertTextToEditorTextW(NewCode)));
{$ELSE}
        EditWriter.Insert(PAnsiChar(ConvertWTextToEditorText(NewCode)));
{$ENDIF}
        // �������λ��
        iOldTokenLen := Length(Cur);
        if iStart > 0 then
          CnOtaMovePosInCurSource(ipCur, 0, iStart * (Length(NewName) - iOldTokenLen))
        else if iStart = 0 then
          CnOtaMovePosInCurSource(ipCur, 0, Max(-iMaxCursorOffset, Length(NewName) - iOldTokenLen));
        EditView.Paint;

        // �ָ��� View �� Bookmarks
        LoadBookMarksFromObjectList(EditView, BookMarkList);
      end;
    finally
      FreeAndNil(CurTokens);
      FreeAndNil(Parser);
      FreeAndNil(BookMarkList);
    end;
  end
  else if IsCppSourceModule(EditView.Buffer.FileName) then // C/C++ �ļ�
  begin
    // �ж�λ�ã�������Ҫ�����������塣
    CParser := TCnWideCppStructParser.Create(SupportUnicode);
    Stream := TMemoryStream.Create;
    try
{$IFDEF UNICODE}
      CnOtaSaveEditorToStreamW(EditView.Buffer, Stream);
{$ELSE}
      CnOtaSaveEditorToStream(EditView.Buffer, Stream, False, False); // ���� Utf8 ��
      // D2005~2007 ��ת�� WideString ����д�� Stream
      ConvertToUtf8Stream(Stream);
{$ENDIF}
      // ������ǰ��ʾ��Դ�ļ�
      CParser.ParseSource(PWideChar(Stream.Memory), Stream.Size div SizeOf(WideChar),
        EditView.CursorPos.Line, EditView.CursorPos.Col, True);
    finally
      Stream.Free;
    end;

    try
      CurToken := nil;
      CurTokens := TList.Create;

      // ��ת�����������������±�ʶ����ͬ�� Token�����ִ�Сд
      for I := 0 to CParser.Count - 1 do
      begin
        CharPos := OTACharPos(CParser.Tokens[I].CharIndex - 1, CParser.Tokens[I].LineNumber + 1);
        try
          EditView.ConvertPos(False, EditPos, CharPos);
        except
          Continue; // D5/6 �� ConvertPos ��ֻ��һ�����ں�ʱ�����ֻ������
        end;

        // ������� ConvertPos �� D2009 �������д�����ʱ�Ľ�����ܻ���ƫ�
        // ���ֱ�Ӳ������� CharIndex + 1 �ķ�ʽ������ Tab ��չ��ȱ������
        EditPos.Col := CParser.Tokens[I].CharIndex + 1;
        CParser.Tokens[I].EditCol := EditPos.Col;
        CParser.Tokens[I].EditLine := EditPos.Line;

        if (CParser.Tokens[I].CppTokenKind = ctkidentifier) and (string(CParser.Tokens[I].Token) = Cur) then
        begin
          CurTokens.Add(CParser.Tokens[I]);
          if (CurToken = nil) and
            IsCurrentTokenW(Pointer(EditView), EditControl, CParser.Tokens[I]) then
            CurToken := CParser.Tokens[I];
        end;
      end;
      if CurTokens.Count = 0 then Exit;

      CurFuncStartToken := nil;
      CurFuncEndToken := nil;

      // ���ȣ��ҳ���ȷ�� CurrentFunc�������ķ� namespace�������㣨��������� namespace��
      if not CParser.BlockIsNamespace and (CParser.BlockStartToken <> nil) and
        (CParser.BlockCloseToken <> nil) then
      begin
        CurFuncStartToken := CParser.BlockStartToken;
        CurFuncEndToken := CParser.BlockCloseToken;
      end
      else if CParser.BlockIsNamespace and (CParser.ChildStartToken <> nil) and
        (CParser.ChildCloseToken <> nil) then
      begin
        CurFuncStartToken := CParser.ChildStartToken;
        CurFuncEndToken := CParser.ChildCloseToken;
      end;

      // �����ǰ����µ� Token �� InnerBlock ֮�䣬�������е� Token ����
      // InnerBlock ֮�䣬���� InnerBlock ���� CurFunc���� RIT Ϊ InnerProc
      // �����ǰ����µ� Token �� CurFunc ֮�䣬�������е� Token ����
      // CurFun ֮�䣬�� RIT Ϊ CurrentProc
      // ��������ʱ��RIT Ϊ Unit
      Rit := ritInvalid;
      if (CParser.InnerBlockStartToken <> nil) and (CParser.InnerBlockCloseToken <> nil)
        and (CParser.InnerBlockStartToken <> CurFuncStartToken) and
            (CParser.InnerBlockCloseToken <> CurFuncEndToken) then
      begin
        if (TCnWideCppToken(CurTokens[0]).ItemIndex >= CParser.InnerBlockStartToken.ItemIndex)
          and (TCnWideCppToken(CurTokens[CurTokens.Count - 1]).ItemIndex
          <= CParser.InnerBlockCloseToken.ItemIndex) then
          Rit := ritInnerProc;
      end;

      if (Rit = ritInvalid) and (CurFuncStartToken <> nil) and (CurFuncEndToken <> nil) then
      begin
        if (TCnWideCppToken(CurTokens[0]).ItemIndex >= CurFuncStartToken.ItemIndex)
          and (TCnWideCppToken(CurTokens[CurTokens.Count - 1]).ItemIndex
          <= CurFuncEndToken.ItemIndex) then
          Rit := ritCurrentProc;
      end;

      if Rit = ritInvalid then
        Rit := ritUnit;

{$IFDEF DEBUG}
      CnDebugger.LogMsg('Cpp F2 Rename. Calc Rit to ' + IntToStr(Ord(Rit)));
{$ENDIF}

      // �����Ի���
      with TCnIdentRenameForm.Create(nil) do
      begin
        try
          lblReplacePromt.Caption := Format(SCnRenameVarHintFmt, [Cur]);
          UpperHeadCur := Cur;
          if FUpperFirstLetter and (Length(UpperHeadCur) >= 1) and (CharInSet(Char(UpperHeadCur[1]), ['a'..'z'])) then
            UpperHeadCur[1] := WideChar(Chr(Ord(UpperHeadCur[1]) - 32));
          edtRename.Text := UpperHeadCur;

          rbCurrentProc.Enabled := Assigned(CurFuncStartToken) and
            Assigned(CurFuncEndToken);
          rbCurrentInnerProc.Enabled := Assigned(CParser.InnerBlockStartToken) and
            Assigned(CParser.InnerBlockCloseToken) and
            (CParser.InnerBlockStartToken <> CurFuncStartToken) and
            (CParser.InnerBlockCloseToken <> CurFuncEndToken);

          if rbCurrentProc.Enabled and (Rit <> ritUnit) then // ��ʶ����Χ���� CurFunc ʱ��Ĭ�ϲ�ѡ����㺯������
            rbCurrentProc.Checked := True;
          if rbCurrentInnerProc.Enabled and (Rit = ritInnerProc) then // ��ʶ��ֻ�����ڲ���ʱ��ѡ�����ڲ�ѡ��
            rbCurrentInnerProc.Checked := True;
          if (not rbCurrentProc.Checked) and (not rbCurrentInnerProc.Checked) then
            rbUnit.Checked := True;

          F := EditView.Buffer.FileName;
          // Cpp/H �ļ����ڴ�״̬���ѡ��ʹ��
          rbCppHPair.Enabled := (IsCpp(F) and CnOtaIsFileOpen(_CnChangeFileExt(F, '.h')))
            or (IsH(F) and CnOtaIsFileOpen(_CnChangeFileExt(F, '.cpp')));

          FrmModalResult := ShowModal = mrOk;
          NewName := edtRename.Text;

          if rbCurrentProc.Checked then
            Rit := ritCurrentProc
          else if rbCurrentInnerProc.Checked then
            Rit := ritInnerProc
          else if rbUnit.Checked then
            Rit := ritUnit
          else
            Rit := ritCppHPair;
        finally
          Free;
        end;
      end;

      if FrmModalResult then
      begin
        if not IsValidRenameIdent(NewName) then
        begin
          ErrorDlg(SCnRenameErrorValid);
          Exit;
        end;

        StartToken := nil;
        EndToken := nil;
        if Rit in [ritUnit, ritCppHPair] then
        begin
          // �滻��ΧΪ���� C ʱ����ʼ���ս� Token Ϊ�б���ͷβ��
          StartToken := TCnWideCppToken(CurTokens[0]);
          EndToken := TCnWideCppToken(CurTokens[CurTokens.Count - 1]);
        end
        else if Rit = ritCurrentProc then
        begin
          StartToken := CurFuncStartToken;
          EndToken := CurFuncEndToken;
        end
        else if Rit = ritInnerProc then
        begin
          StartToken := CParser.InnerBlockStartToken;
          EndToken := CParser.InnerBlockCloseToken;
        end;

        if (StartToken = nil) or (EndToken = nil) then Exit;

        // ��¼�� View �� Bookmarks
        BookMarkList := TObjectList.Create(True);
        SaveBookMarksToObjectList(EditView, BookMarkList);

        NewCode := '';
        LastToken := nil;
        FirstEnter := True;
        iStart := 0;

        iMaxCursorOffset := EditView.CursorPos.Col - CurToken.EditCol;
        StartCurToken := nil;
        EndCurToken := nil;
        EditWriter := CnOtaGetEditWriterForSourceEditor;

        // ִ����ѭ����NewCode Ӧ��Ϊ��������Ҫ�滻������ Token ���滻������
        for I := 0 to CurTokens.Count - 1 do
        begin
          if (TCnWideCppToken(CurTokens[I]).ItemIndex >= StartToken.ItemIndex) and
            (TCnWideCppToken(CurTokens[I]).ItemIndex <= EndToken.ItemIndex) then
          begin
            // ����Ҫ����֮�С���һ�أ�����ͷ�����ѭ������β
            if FirstEnter then
            begin
              StartCurToken := TCnWideCppToken(CurTokens[I]); // ��¼��һ�� CurToken
              FirstEnter := False;
            end;

            if LastToken = nil then
              NewCode := NewName
            else
            begin
              // ����һ Token ��β�ͣ������� Token ��ͷ���ټ��滻������֣����� AnsiString ������
              LastTokenPos := LastToken.TokenPos + Length(LastToken.Token);
              NewCode := NewCode + string(Copy(AnsiString(CParser.Source), LastTokenPos + 1,
                TCnWideCppToken(CurTokens[I]).TokenPos - LastTokenPos)) + NewName;
            end;
{$IFDEF DEBUG}
            CnDebugger.LogMsg('Cpp NewCode: ' + NewCode);
{$ENDIF}
            // ͬһ��ǰ��Ļ�Ӱ����λ��
            if (TCnWideCppToken(CurTokens[I]).EditLine = CurToken.EditLine) and
              (TCnWideCppToken(CurTokens[I]).EditCol < CurToken.EditCol) then
              Inc(iStart);

            LastToken := TCnWideCppToken(CurTokens[I]);   // ��¼��һ��������� CurToken
            EndCurToken := TCnWideCppToken(CurTokens[I]); // ��¼���һ�� CurToken
          end;
        end;

        if StartCurToken <> nil then
        begin
          // Ҫ������� UTF8 �ĳ��ȣ��� Paser ����� TokenPos �� Unicode �������Ҫת��
          EditWriter.CopyTo(Length(UTF8Encode(Copy(CParser.Source, 1, StartCurToken.TokenPos))));
        end;

        if EndCurToken <> nil then
        begin
          // Ҫ������� UTF8 �ĳ��ȣ��� Paser ����� TokenPos �� Unicode �������Ҫת��
          EditWriter.DeleteTo(Length(UTF8Encode(Copy(CParser.Source, 1,
            EndCurToken.TokenPos + Length(EndCurToken.Token)))));
        end;
{$IFDEF UNICODE}
        EditWriter.Insert(PAnsiChar(ConvertTextToEditorTextW(NewCode)));
{$ELSE}
        EditWriter.Insert(PAnsiChar(ConvertWTextToEditorText(NewCode)));
{$ENDIF}
        // �������λ��
        iOldTokenLen := Length(Cur);
        if iStart > 0 then
          CnOtaMovePosInCurSource(ipCur, 0, iStart * (Length(NewName) - iOldTokenLen))
        else if iStart = 0 then
          CnOtaMovePosInCurSource(ipCur, 0, Max(-iMaxCursorOffset, Length(NewName) - iOldTokenLen));
        EditView.Paint;

        // �ָ��� View �� Bookmarks
        LoadBookMarksFromObjectList(EditView, BookMarkList);

        // ����һ���ļ�
        if Rit <> ritCppHPair then
          Exit;

        if IsCpp(F) then
          F := _CnChangeFileExt(F, '.h')
        else if IsH(F) then
          F := _CnChangeFileExt(F, '.cpp');

        if not CnOtaIsFileOpen(F) then
          Exit;

        // ��ͷ������һ���ļ��������滻
        FreeAndNil(CParser);
        FreeAndNil(CurTokens);
{$IFDEF DEBUG}
        CnDebugger.LogMsg('Cpp Another Starting: ' + F);
{$ENDIF}

        EditView := CnOtaGetTopOpenedEditViewFromFileName(F);
        if EditView = nil then
          Exit;

{$IFDEF DEBUG}
        CnDebugger.LogMsg('Cpp Another SourceEditor and EditView Got.');
{$ENDIF}
        CurToken := nil;
        CurTokens := TList.Create;

        CParser := TCnWideCppStructParser.Create;
        Stream := TMemoryStream.Create;
        try
{$IFDEF UNICODE}
          CnOtaSaveEditorToStreamW(FSrcEditor, Stream);
{$ELSE}
          CnOtaSaveEditorToStream(FSrcEditor, Stream, False, False); // ���� Utf8 ��
          // D2005~2007 ��ת�� WideString ����д�� Stream
          ConvertToUtf8Stream(Stream);
{$ENDIF}
          // ������ǰ��ʾ��Դ�ļ�
          CParser.ParseSource(PWideChar(Stream.Memory), Stream.Size div SizeOf(WideChar),
            1, 1, True);
        finally
          Stream.Free;
        end;

        // ��ת�����������������±�ʶ����ͬ�� Token�����ִ�Сд
        for I := 0 to CParser.Count - 1 do
        begin
          CharPos := OTACharPos(CParser.Tokens[I].CharIndex - 1, CParser.Tokens[I].LineNumber + 1);
          try
            EditView.ConvertPos(False, EditPos, CharPos);
          except
            Continue; // D5/6 �� ConvertPos ��ֻ��һ�����ں�ʱ�����ֻ������
          end;

          // ������� ConvertPos �� D2009 �������д�����ʱ�Ľ�����ܻ���ƫ�
          // ���ֱ�Ӳ������� CharIndex + 1 �ķ�ʽ������ Tab ��չ��ȱ������
          EditPos.Col := CParser.Tokens[I].CharIndex + 1;
          CParser.Tokens[I].EditCol := EditPos.Col;
          CParser.Tokens[I].EditLine := EditPos.Line;

          if (CParser.Tokens[I].CppTokenKind = ctkidentifier) and (string(CParser.Tokens[I].Token) = Cur) then
            CurTokens.Add(CParser.Tokens[I]);
        end;
        if CurTokens.Count = 0 then Exit;

        // ��һ���ļ��������жϷ�Χ��ȫ���������Ҳ�������
        // ��¼�� View �� Bookmarks
        FreeAndNil(BookMarkList);
        BookMarkList := TObjectList.Create(True);
        SaveBookMarksToObjectList(EditView, BookMarkList);

        NewCode := '';
        LastToken := nil;
        FirstEnter := True;
        iStart := 0;

        StartCurToken := nil;
        EndCurToken := nil;
        EditWriter := CnOtaGetEditWriterForSourceEditor(FSrcEditor);

        // ִ����ѭ����NewCode Ӧ��Ϊ��������Ҫ�滻������ Token ���滻������
        for I := 0 to CurTokens.Count - 1 do
        begin
          // ����Ҫ����֮�С���һ�أ�����ͷ�����ѭ������β
          if FirstEnter then
          begin
            StartCurToken := TCnWideCppToken(CurTokens[I]); // ��¼��һ�� CurToken
            FirstEnter := False;
          end;

          if LastToken = nil then
            NewCode := NewName
          else
          begin
            // ����һ Token ��β�ͣ������� Token ��ͷ���ټ��滻������֣����� AnsiString ������
            LastTokenPos := LastToken.TokenPos + Length(LastToken.Token);
            NewCode := NewCode + string(Copy(AnsiString(CParser.Source), LastTokenPos + 1,
              TCnWideCppToken(CurTokens[I]).TokenPos - LastTokenPos)) + NewName;
          end;
  {$IFDEF DEBUG}
          CnDebugger.LogMsg('Cpp Another NewCode: ' + NewCode);
  {$ENDIF}
          LastToken := TCnWideCppToken(CurTokens[I]);   // ��¼��һ��������� CurToken
          EndCurToken := TCnWideCppToken(CurTokens[I]); // ��¼���һ�� CurToken
        end;

        if StartCurToken <> nil then
        begin
          // Ҫ������� UTF8 �ĳ��ȣ��� Paser ����� TokenPos �� Unicode �������Ҫת��
          EditWriter.CopyTo(Length(UTF8Encode(Copy(CParser.Source, 1, StartCurToken.TokenPos))));
        end;

        if EndCurToken <> nil then
        begin
          // Ҫ������� UTF8 �ĳ��ȣ��� Paser ����� TokenPos �� Unicode �������Ҫת��
          EditWriter.DeleteTo(Length(UTF8Encode(Copy(CParser.Source, 1,
            EndCurToken.TokenPos + Length(EndCurToken.Token)))));
        end;

{$IFDEF UNICODE}
        EditWriter.Insert(PAnsiChar(ConvertTextToEditorTextW(NewCode)));
{$ELSE}
        EditWriter.Insert(PAnsiChar(ConvertWTextToEditorText(NewCode)));
{$ENDIF}

        // �ָ��� View �� Bookmarks
        LoadBookMarksFromObjectList(EditView, BookMarkList);
      end;
    finally
      FreeAndNil(CurTokens);
      FreeAndNil(CParser);
      FreeAndNil(BookMarkList);
    end;
  end;

  Handled := True;
end;

{$ENDIF}

{$HINTS ON}

function TCnSrcEditorKey.DoSearchAgain(View: IOTAEditView; Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean): Boolean;
var
  Block: IOTAEditBlock;
  Position: IOTAEditPosition;
  Len: Integer;
  Found: Boolean;
  SearchString: string;
  Bar: TStatusBar;
  ARow, ACol: Integer;
  EditPos: TOTAEditPos;
  EditControl: TControl;
  LineFlag, Element: Integer;
begin
  Result := False;
  if Key <> VK_F3 then Exit;
  if View.Buffer = nil then Exit;

  Position := View.Buffer.EditPosition;
  if Position = nil then Exit;

  Bar := GetStatusBarFromEditor(GetCurrentEditControl);
  if Bar <> nil then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogBoolean(Bar.SimplePanel, 'F3 Search: Fould Editor StatusBar. Check its SimplePanel.');
{$ENDIF}
    // ״̬���� SimplePanel Ϊ True ʱ�����ڽ��� Ctrl + E ������Ӧ�ûر�
    if Bar.SimplePanel then
      Exit;
  end;

  Block := View.Block;

  // ������δѡ�С�ѡ�л��ǲ���ƥ��ʱѡ�У�Block ����Ϊ nil
  // ��ֻ��ѡ��ʱ IsValid Ϊ True������δѡ�С�����ƥ��ѡ������� IsValid ���� False
  // ��˹��ж� Block ���������޷����ֵ�ǰ��δѡ�л��ǲ���ƥ��ѡ�У���Ҫͨ��
  // EditorAttribute ����������
  if (Block = nil) or not Block.IsValid then
  begin
    // �޲��һ����ƥ��ѡ�У���Ҫ����
    EditControl := CnOtaGetCurrentEditControl;
    EditPos := View.CursorPos;
    if EditPos.Col > 1 then
      Dec(EditPos.Col);
    EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);

    // ����� IDE �ڲ����У���ƥ�䣩�����˳��� IDE ���д���
    if Element = SearchMatch then
      Exit;

    // ��ʼ����δѡ��ʱ�Ĳ��Ҵ���
    // �� KeepSearch Ϊ True ʱ����Ҫ���в�����һ�� F3 ���ҵ����ݣ������� IDE �в��ҵ�����

    // �޿�ʱ���粻���� IDE �Ĳ��ң����˳����� IDE ȥִ�в�����һ��
    if not FKeepSearch then
      Exit;

    // ��ѡ��鲢���� KeepSearch ����£�ʹ���ϴ� F3 ���ҵ����ݡ�
    // ��ͨ���ҽ�ʵ���˼�¼ IDE ���ҶԻ����е��ַ����� FOldSearchText ��

    // ��ʹ�� FOldSearchText������Ϊ Position.SearchOptions.SearchText ���ܻ��Ǿ�ֵ
    SearchString := '';
    if FOldSearchText <> '' then
      SearchString := FOldSearchText;

    if Trim(SearchString) = '' then
      SearchString := Position.SearchOptions.SearchText;

    if Trim(SearchString) = '' then
    begin
      {$IFDEF DEBUG}
         CnDebugger.LogMsg('F3 Pressed, SearchString is Empty, Exit.');
      {$ENDIF}
      Exit;
    end;
  end
  else if Block.StartingRow <> Block.EndingRow then // ѡ����ʱ������
    Exit
  else // �е��п�ʱ��ѡ�еĿ�����
    SearchString := Block.Text;

  Len := Length(SearchString);
  if Len = 0 then Exit;

  ARow := Position.GetRow;
  ACol := Position.GetColumn;
  Position.SearchOptions.SearchText := SearchString;

  Position.SearchOptions.CaseSensitive := FCaseSense;
  Position.SearchOptions.WordBoundary := FWholeWords;
  Position.SearchOptions.RegularExpression := FRegExp;
{$IFDEF DEBUG}
  CnDebugger.LogFmt('F3 Search: Set Options: Case %d, Word %d, Reg %d. ',
    [Integer(FCaseSense), Integer(FWholeWords), Integer(FRegExp)]);
{$ENDIF}

{$IFDEF DEBUG}
  CnDebugger.LogMsg('F3 Search: '+ SearchString);
{$ENDIF}
  Found := False;
  FOldSearchText := Position.SearchOptions.SearchText;
  if Shift = [] then
  begin
    Position.SearchOptions.Direction := sdForward;
    Found := Position.SearchAgain;
    if not Found and FSearchWrap then // �Ƿ���Ʋ���
    begin
      Position.Move(1, 1);
      Found := Position.SearchAgain;
{$IFDEF DEBUG}
      CnDebugger.LogBoolean(Found, 'F3 Search Found Value after Move to BOF.');
{$ENDIF}
      if not Found then
        Position.Move(ARow, ACol);
    end;
  end
  else if Shift = [ssShift] then
  begin
    Position.SearchOptions.Direction := sdBackward;
    Found := Position.SearchAgain;
    if not Found and FSearchWrap then // �Ƿ���Ʋ���
    begin
      Position.MoveEOF;
      Found := Position.SearchAgain;
{$IFDEF DEBUG}
      CnDebugger.LogBoolean(Found, 'F3 Search Found Value after Move to EOF.');
{$ENDIF}
      if not Found then
        Position.Move(ARow, ACol);
    end;
  end;

  {$IFDEF DEBUG}
     CnDebugger.LogBoolean(Found, 'F3 Search Found Value at Last.');
  {$ENDIF}

  if Found then
  begin
    if Position.SearchOptions.Direction = sdForward then
    begin
      Position.MoveRelative(0, - Len);
      Block.ExtendRelative(0, Len);
    end
    else
    begin
      Position.MoveRelative(0, Len);
      Block.ExtendRelative(0, - Len);
    end;
  end;

  View.Paint;

  Result := True;
  Handled := True;
end;

procedure TCnSrcEditorKey.EditControlKeyDown(Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean);
var
  View: IOTAEditView;
begin
  if Active then
  begin
    View := CnOtaGetTopMostEditView;
    if not Assigned(View) then
      Exit;

    if FAutoBracket and DoAutoMatchEnter(View, Key, ScanCode, Shift, Handled) then
      Exit;

    if FSmartCopy or FSmartPaste then
      if DoSmartCopy(View, Key, ScanCode, Shift, Handled) then
        Exit;

  {$IFNDEF DELPHI10_UP} // 2006 �Ѿ������Զ������� end �Զ�����
    // �ж��Զ�����Ҫ�� ShiftEnter ֮ǰ
    if (FAutoIndent or FAutoEnterEnd) and DoAutoIndent(View, Key, ScanCode, Shift, Handled) then
      Exit;
  {$ENDIF}

    if FShiftEnter and DoShiftEnter(View, Key, ScanCode, Shift, Handled) then
      Exit;

    if FF3Search and DoSearchAgain(View, Key, ScanCode, Shift, Handled) then
      Exit;

{$IFDEF IDE_WIDECONTROL}
    if FF2Rename and DoRenameW(View, Key, ScanCode, Shift, Handled) then
      Exit;
{$ELSE}
    if FF2Rename and DoRename(View, Key, ScanCode, Shift, Handled) then
      Exit;
{$ENDIF}

    if FHomeExt and DoHomeExtend(View, Key, ScanCode, Shift, Handled) then
      Exit;

    if FLeftRightLineWrap and DoLeftRightLineWrap(View, Key, ScanCode, Shift, Handled) then
      Exit;

    if FSemicolonLastChar and DoSemicolonLastChar(View, Key, ScanCode, Shift, Handled) then
      Exit;
  end;
end;

procedure TCnSrcEditorKey.EditControlKeyUp(Key, ScanCode: Word; Shift: TShiftState;
  var Handled: Boolean);
begin
  if Active and FAutoBracket then
  begin
    // TODO: ������¸ɵĻ�
  end;
end;

procedure TCnSrcEditorKey.ExecuteInsertCharOnIdle(Sender: TObject);
begin
  if (FAutoMatchType = btNone) or (FRepaintView = 0) then
    Exit;

  case FAutoMatchType of
    btBracket: CnOtaInsertTextToCurSource(')');
    btSquare:  CnOtaInsertTextToCurSource(']');
    btCurly:   CnOtaInsertTextToCurSource('}');
    btQuote:   CnOtaInsertTextToCurSource('''');
    btDitto:   CnOtaInsertTextToCurSource('"');
  end;
  
  CnOtaMovePosInCurSource(ipCur, 0, -1);
  IOTAEditView(FRepaintView).Paint;
end;

//------------------------------------------------------------------------------
// ��������
//------------------------------------------------------------------------------

const
  csEditorKey = 'EditorKey';
  csSmartCopy = 'SmartCopy';
  csSmartPaste = 'SmartPaste';
  csShiftEnter = 'ShiftEnter';
  csF3Search = 'F3Search';
  csF2Rename = 'F2Rename';
  csRenameShortCut = 'RenameShortCut';
  csKeepSearch = 'KeepSearch';
  csSearchWrap = 'SearchWrap';
  csAutoIndent = 'AutoIndent';
  csHomeExt = 'HomeExt';
  csHomeFirstChar = 'HomeFirstChar';
  csCursorBeforeEOL = 'CursorBeforeEOL';
  csLeftRightLineWrap = 'LeftRightLineWrap';
  csAutoBracket = 'AutoBracket';
  csSemicolonLastChar = 'SemicolonLastChar';
  csAutoEnterEnd = 'AutoEnterEnd';

procedure TCnSrcEditorKey.LoadSettings(Ini: TCustomIniFile);
begin
  FSmartCopy := Ini.ReadBool(csEditorKey, csSmartCopy, True);
  FSmartPaste := Ini.ReadBool(csEditorKey, csSmartPaste, False);
  FShiftEnter := Ini.ReadBool(csEditorKey, csShiftEnter, True);
  FAutoIndent := Ini.ReadBool(csEditorKey, csAutoIndent, True);
  FF3Search := Ini.ReadBool(csEditorKey, csF3Search, True);
  FF2Rename := Ini.ReadBool(csEditorKey, csF2Rename, True);
  RenameShortCut := Ini.ReadInteger(csEditorKey, csRenameShortCut, FRenameShortCut);
  KeepSearch := Ini.ReadBool(csEditorKey, csKeepSearch, True);
  SearchWrap := Ini.ReadBool(csEditorKey, csSearchWrap, True);
  FHomeExt := Ini.ReadBool(csEditorKey, csHomeExt, True);
  FHomeFirstChar := Ini.ReadBool(csEditorKey, csHomeFirstChar, False);
  FCursorBeforeEOL := Ini.ReadBool(csEditorKey, csCursorBeforeEOL, False);
  FLeftRightLineWrap := Ini.ReadBool(csEditorKey, csLeftRightLineWrap, False);
  FAutoBracket := Ini.ReadBool(csEditorKey, csAutoBracket, False);
  FSemicolonLastChar := Ini.ReadBool(csEditorKey, csSemicolonLastChar, False);
  FAutoEnterEnd := Ini.ReadBool(csEditorKey, csAutoEnterEnd, True);
  WizOptions.LoadUserFile(FAutoIndentList, SCnAutoIndentFile);
end;

procedure TCnSrcEditorKey.SaveSettings(Ini: TCustomIniFile);
begin
  Ini.WriteBool(csEditorKey, csSmartCopy, FSmartCopy);
  Ini.WriteBool(csEditorKey, csSmartPaste, FSmartPaste);
  Ini.WriteBool(csEditorKey, csShiftEnter, FShiftEnter);
  Ini.WriteBool(csEditorKey, csF3Search, FF3Search);
  Ini.WriteBool(csEditorKey, csF2Rename, FF2Rename);
  Ini.WriteInteger(csEditorKey, csRenameShortCut, FRenameShortCut);
  Ini.WriteBool(csEditorKey, csKeepSearch, FKeepSearch);
  Ini.WriteBool(csEditorKey, csSearchWrap, FSearchWrap);
  Ini.WriteBool(csEditorKey, csAutoIndent, FAutoIndent);
  Ini.WriteBool(csEditorKey, csHomeExt, FHomeExt);
  Ini.WriteBool(csEditorKey, csHomeFirstChar, FHomeFirstChar);
  Ini.WriteBool(csEditorKey, csCursorBeforeEOL, FCursorBeforeEOL);
  Ini.WriteBool(csEditorKey, csLeftRightLineWrap, FLeftRightLineWrap);
  Ini.WriteBool(csEditorKey, csAutoBracket, FAutoBracket);
  Ini.WriteBool(csEditorKey, csSemicolonLastChar, FSemicolonLastChar);
  Ini.WriteBool(csEditorKey, csAutoEnterEnd, FAutoEnterEnd);
  WizOptions.SaveUserFile(FAutoIndentList, SCnAutoIndentFile);
end;

procedure TCnSrcEditorKey.ResetSettings(Ini: TCustomIniFile);
begin
  WizOptions.CleanUserFile(SCnAutoIndentFile);
end;

procedure TCnSrcEditorKey.DoEnhConfig;
begin
  if Assigned(FOnEnhConfig) then
    FOnEnhConfig(Self);
end;

procedure TCnSrcEditorKey.LanguageChanged(Sender: TObject);
begin

end;

//------------------------------------------------------------------------------
// ���Զ�д
//------------------------------------------------------------------------------

procedure TCnSrcEditorKey.SetActive(Value: Boolean);
begin
  if FActive <> Value then
  begin
    FActive := Value;
  end;
end;

procedure TCnSrcEditorKey.SetRenameShortCut(const Value: TShortCut);
begin
  FRenameShortCut := Value;
  ShortCutToKey(Value, FRenameKey, FRenameShift);
end;

procedure TCnSrcEditorKey.SetKeepSearch(const Value: Boolean);
begin
  FKeepSearch := Value;
end;

procedure TCnSrcEditorKey.EditorChanged(Editor: TEditorObject;
  ChangeType: TEditorChangeTypes);
var
  Line: string;
  AnsiLine: AnsiString;
  EditView: IOTAEditView;
  LineNo, CharIndex: Integer;
begin
  if not Active or not FCursorBeforeEOL then
    Exit;

  if ((ctCurrLine in ChangeType) or (ctCurrCol in ChangeType)) and not FCursorMoving then
  begin
    // ��õ�ǰ�༭�����λ�ã����ж��Ƿ񳬳���β
    if CnNtaGetCurrLineText(Line, LineNo, CharIndex) then
    begin
      if Trim(Line) = '' then // ���в�ǿ�ȵ�����
        Exit;
      AnsiLine := AnsiString(Line);

      EditView := CnOtaGetTopMostEditView;
      CharIndex := EditView.CursorPos.Col - 1;
{$IFDEF DEBUG}
      CnDebugger.LogFmt('Cursor Before EOL: Col %d, Len %d.', [CharIndex, Length(AnsiLine)]);
{$ENDIF}
      if CharIndex > Length(AnsiLine) then
      begin
        try
          FCursorMoving := True;
          EditView.Buffer.EditPosition.MoveEOL;
          EditView.Paint;
        finally
          FCursorMoving := False;
        end;
      end;
    end;
  end;
end;

function TCnSrcEditorKey.IsValidRenameIdent(const Ident: string): Boolean;
const
  Alpha = ['A'..'Z', 'a'..'z', '_'];
  AlphaNumeric = Alpha + ['0'..'9', '.'];
var
  I: Integer;
begin
  Result := False;
{$IFDEF UNICODE} // Unicode Identifier Supports
  if (Length(Ident) = 0) or not (CharInSet(Ident[1], Alpha) or (Ord(Ident[1]) > 127)) then
    Exit;
  for I := 2 to Length(Ident) do
    if not (CharInSet(Ident[I], AlphaNumeric) or (Ord(Ident[I]) > 127)) then
      Exit;
{$ELSE}
  if (Length(Ident) = 0) or not CharInSet(Ident[1], Alpha) then Exit;
  for I := 2 to Length(Ident) do if not CharInSet(Ident[I], AlphaNumeric) then Exit;
{$ENDIF}
  Result := True;
end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}
end.

