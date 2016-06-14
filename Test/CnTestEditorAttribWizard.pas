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

unit CnTestEditorAttribWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��򵥵�ר����ʾ��Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע���õ�Ԫ�ɻ�ȡ����������༭����ǰ������ڵ����Լ��ַ����Ե�����
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2016.04.25 V1.1
*               �޸ĳ��Ӳ˵�ר���Լ�����һ����������
*           2009.01.07 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnCommon, CnWizClasses, CnWizUtils, CnWizConsts,
  CnEditControlWrapper;

type

//==============================================================================
// �༭�����Ի�ȡ�Ӳ˵�ר��
//==============================================================================

{ TCnTestEditorAttribWizard }

  TCnTestEditorAttribWizard = class(TCnSubMenuWizard)
  private
    FIdAttrib: Integer;
    FIdLine: Integer;
    procedure TestAttributeAtCursor;
    procedure TestAttributeLine;
  protected
    function GetHasConfig: Boolean; override;
  public
    function GetState: TWizardState; override;
    procedure Config; override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;

    procedure AcquireSubActions; override;
    procedure SubActionExecute(Index: Integer); override;
  end;

implementation

uses
  CnDebug;

const
  SCnAttribCommand = 'CnAttribCommand';
  SCnLineAttribCommand = 'CnLineAttribCommand';
  SCnAttribCaption = 'Show Attribute at Cursor';
  SCnLineAttribCaption = 'Show Attribute in Whole Line';

//==============================================================================
// �༭�����Ի�ȡ�Ӳ˵�ר��
//==============================================================================

{ TCnTestEditorAttribWizard }

procedure TCnTestEditorAttribWizard.AcquireSubActions;
begin
  FIdAttrib := RegisterASubAction(SCnAttribCommand, SCnAttribCaption);
  FIdLine := RegisterASubAction(SCnLineAttribCommand, SCnLineAttribCaption);
end;

procedure TCnTestEditorAttribWizard.Config;
begin

end;

procedure TCnTestEditorAttribWizard.TestAttributeAtCursor;
var
  EditPos: TOTAEditPos;
  EditControl: TControl;
  EditView: IOTAEditView;
  LineFlag, Element: Integer;
  S, T: string;
  Block: IOTAEditBlock;
begin
  EditControl := CnOtaGetCurrentEditControl;
  EditView := CnOtaGetTopMostEditView;

  Block := EditView.Block;
  S := Format('Edit Block %8.8x. ', [Integer(Block)]);
  if Block <> nil then
  begin
    if Block.IsValid then
      S := S + 'Is Valid.'
    else
      S := S + 'NOT Valid.';
  end;

  EditPos := EditView.CursorPos;
  EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);

  S := S + #13#10 +Format('EditPos Line %d, Col %d. LineFlag %d. Element: %d, ',
    [EditPos.Line, EditPos.Col, LineFlag, Element]);
  case Element of
    0:  T := 'atWhiteSpace  ';
    1:  T := 'atComment     ';
    2:  T := 'atReservedWord';
    3:  T := 'atIdentifier  ';
    4:  T := 'atSymbol      ';
    5:  T := 'atString      ';
    6:  T := 'atNumber      ';
    7:  T := 'atFloat       ';
    8:  T := 'atOctal       ';
    9:  T := 'atHex         ';
    10: T := 'atCharacter   ';
    11: T := 'atPreproc     ';
    12: T := 'atIllegal     ';
    13: T := 'atAssembler   ';
    14: T := 'SyntaxOff     ';
    15: T := 'MarkedBlock   ';
    16: T := 'SearchMatch   ';
  else
    T := 'Unknown';
  end;
  ShowMessage(S + T);

  if EditPos.Col > 1 then
    Dec(EditPos.Col);

  EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False, Element, LineFlag);

  S := Format('EditPos Line %d, Col %d. LineFlag %d. Element: %d, ',
    [EditPos.Line, EditPos.Col, LineFlag, Element]);
  case Element of
    0:  T := 'atWhiteSpace  ';
    1:  T := 'atComment     ';
    2:  T := 'atReservedWord';
    3:  T := 'atIdentifier  ';
    4:  T := 'atSymbol      ';
    5:  T := 'atString      ';
    6:  T := 'atNumber      ';
    7:  T := 'atFloat       ';
    8:  T := 'atOctal       ';
    9:  T := 'atHex         ';
    10: T := 'atCharacter   ';
    11: T := 'atPreproc     ';
    12: T := 'atIllegal     ';
    13: T := 'atAssembler   ';
    14: T := 'SyntaxOff     ';
    15: T := 'MarkedBlock   ';
    16: T := 'SearchMatch   ';
  else
    T := 'Unknown';
  end;
  ShowMessage(S + T);
end;

function TCnTestEditorAttribWizard.GetCaption: string;
begin
  Result := 'Test Editor Attribute';
end;

function TCnTestEditorAttribWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestEditorAttribWizard.GetHasConfig: Boolean;
begin
  Result := False;
end;

function TCnTestEditorAttribWizard.GetHint: string;
begin
  Result := 'Show Attributes in Current Editor';
end;

function TCnTestEditorAttribWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestEditorAttribWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Editor Attribute Menu Wizard';
  Author := 'CnPack Team';
  Email := 'liuxiao@cnpack.org';
  Comment := 'Test Editor Attribute Menu Wizard';
end;

procedure TCnTestEditorAttribWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditorAttribWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestEditorAttribWizard.SubActionExecute(Index: Integer);
begin
  if Index = FIdAttrib then
    TestAttributeAtCursor
  else if Index = FIdLine then
    TestAttributeLine;
end;

procedure TCnTestEditorAttribWizard.TestAttributeLine;
var
  EdPos: TOTAEditPos;
  View: IOTAEditView;
  Line: AnsiString;
  ULine: string;
{$IFDEF UNICODE}
  ALine: AnsiString;
  UCol: Integer;
{$ENDIF}
  EditControl: TControl;
  I, Element, LineFlag: Integer;
begin
  View := CnOtaGetTopMostEditView;
  if View = nil then
    Exit;

  EditControl := EditControlWrapper.GetEditControl(View);
  if EditControl = nil then
    Exit;

  EdPos := View.CursorPos;

  ULine := EditControlWrapper.GetTextAtLine(EditControl, EdPos.Line);
  CnDebugger.LogRawString(ULine);
  Line := AnsiString(ULine);
  CnDebugger.LogRawAnsiString(Line);

  CnDebugger.LogInteger(EdPos.Col, 'Before Possible UTF8 Convertion CursorPos Col');
{$IFDEF UNICODE}
  // Unicode ������ GetTextAtLine ���ص��� Unicode��
  // GetAttributeAtPos Ҫ����� UTF8��
  // �� CursorPos ��Ӧ Ansi��������Ҫ���ӵ�ת����
  // �Ȱ� Unicode ת���� Ansi���� Col �ضϣ�ת�� Unicode���䳤�Ⱦ��� Col�� Unicode�е�λ�ã�
  // �ٰ����� Unicode ���� Col �ضϣ���ת���� Ansi-Utf8���䳤�Ⱦ��� UTF8 �� Col

  ALine := Copy(Line, 1, EdPos.Col - 1);            // �ض�
  CnDebugger.LogRawAnsiString(ALine);

  UCol := Length(string(ALine)) + 1;                // ת�� Unicode
  CnDebugger.LogInteger(UCol, 'Temp Unicode Col');

  ULine := Copy(ULine, 1, UCol - 1);                // ���½ض�
  CnDebugger.LogRawString(ULine);

  ALine := CnAnsiToUtf8(AnsiString(ULine));         // ת�� Ansi-Utf8
  CnDebugger.LogRawAnsiString(ALine);

  EdPos.Col := Length(CnAnsiToUtf8(ALine)) + 1;     // ȡ����

  Line := CnAnsiToUtf8(Line);                       // �������ת�� Utf8����������Ĵ���һ��
{$ENDIF}

  CnDebugger.LogInteger(EdPos.Col, 'After Possible UTF8 Conversion. CursorPos Col');

  if EdPos.Col > Length(Line) then
    Exit;

  if Line <> '' then
  begin
    for I := 1 to Length(Line) do
    begin
      if EdPos.Col = I then
        CnDebugger.LogInteger(I, 'Here is the Cursor Position.');
      EditControlWrapper.GetAttributeAtPos(EditControl, OTAEditPos(I, EdPos.Line),
        False, Element, LineFlag);
      case Element of
        atWhiteSpace:
          CnDebugger.LogAnsiChar(Line[I], IntToStr(I) + ' WhiteSpace');
        atComment:
          CnDebugger.LogAnsiChar(Line[I], IntToStr(I) + ' Comment');
        atReservedWord:
          CnDebugger.LogAnsiChar(Line[I], IntToStr(I) + ' ReservedWord');
        atIdentifier:
          CnDebugger.LogAnsiChar(Line[I], IntToStr(I) + ' Identifier');
        atSymbol:
          CnDebugger.LogAnsiChar(Line[I], IntToStr(I) + ' Symbol');
        atString:
          CnDebugger.LogAnsiChar(Line[I], IntToStr(I) + ' String');
        atNumber:
          CnDebugger.LogAnsiChar(Line[I], IntToStr(I) + ' Number');
      else
        CnDebugger.LogAnsiChar(Line[I], IntToStr(I) + ' Unknown');
      end;
    end;
  end;
  ShowMessage('Information Sent to CnDebugViewer for Current Line.');
end;

initialization
  RegisterCnWizard(TCnTestEditorAttribWizard); // ע��ר��

end.
