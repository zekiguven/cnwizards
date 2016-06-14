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

unit CnTestWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�CnPack IDE ר�Ұ�����ר�����ɵ�Ԫ
* ��Ԫ���ߣ�LiuXiao ��liuxiao@cnpack.org��
* ��    ע��CnPack IDE ר�Ұ�����ר�����ɵ�Ԫ
* ����ƽ̨��Windows XP + Delphi 5
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2016.04.23 V1.0
*               LiuXiao ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ToolsAPI, CnWizMultiLang, CnCommon, CnConsts, CnWizConsts,
  CnWizClasses, CnWizOptions, CnOTACreators;

type
  TCnTestWizardForm = class(TCnTranslateForm)
    grpTestWizard: TGroupBox;
    lblClassName: TLabel;
    lblMenuCaption: TLabel;
    lblComment: TLabel;
    edtMenuCaption: TEdit;
    lblCnTest: TLabel;
    edtClassName: TEdit;
    lblWizard: TLabel;
    edtComment: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    lblTest: TLabel;
    dlgSave: TSaveDialog;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TCnTestWizard = class(TCnUnitWizard)
  private
    FWizardClassName: string;
    FWizardMenuCaption: string;
    FWizardComment: string;
  public
    constructor Create; override;
    destructor Destroy; override;
    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    procedure Execute; override;

    property WizardClassName: string read FWizardClassName write FWizardClassName;
    property WizardMenuCaption: string read FWizardMenuCaption write FWizardMenuCaption;
    property WizardComment: string read FWizardComment write FWizardComment;
  end;

  TCnTestWizardCreator = class(TCnTemplateModuleCreator)
  private
    FTestWizard: TCnTestWizard;
{$IFDEF BDS}
    FFileName: string;
{$ENDIF}

  protected
    function GetTemplateFile(FileType: TCnSourceType): string; override;
    procedure DoReplaceTagsSource(const TagString: string; TagParams: TStrings;
      var ReplaceText: string; ASourceType: TCnSourceType; ModuleIdent, FormIdent,
      AncestorIdent: string); override;

  public
    function GetShowSource: Boolean; override;

{$IFDEF BDS}
    function GetUnnamed: Boolean; override;
    {* BDS �·��� FALSE����ʾ�Ѿ����� }
    function GetImplFileName: string; override;
    {* BDS ����ʵ�ʵ������ļ��� }
    function GetIntfFileName: string; override;
    {* BDS ����ʵ�ʵ������ļ��� }
{$ENDIF}

    property TestWizard: TCnTestWizard read FTestWizard write FTestWizard;

{$IFDEF BDS}
    property FileName: string read FFileName write FFileName;
{$ENDIF}
  end;

implementation

{$R *.DFM}

const
  SCnTestWizardModuleTemplatePasFile = 'CnTestWizard.pas';

  csClassName = 'ClassName';
  csWizardCaption = 'WizardCaption';
  csWizardComment = 'WizardComment';
  csCreateTime = 'CreateTime';

var
  SCnTestWizardWizardName: string = 'CnPack Test Wizard';
  SCnTestWizardWizardComment: string = 'Generate a Test Wizard for CnPack IDE Wizard.';

{ TCnTestWizard }

constructor TCnTestWizard.Create;
begin
  inherited;

end;

destructor TCnTestWizard.Destroy;
begin
  inherited;

end;

procedure TCnTestWizard.Execute;
var
  ModuleCreator: TCnTestWizardCreator;
begin
  with TCnTestWizardForm.Create(nil) do
  begin
    if ShowModal = mrOK then
    begin
      WizardClassName := Trim(edtClassName.Text);
      WizardMenuCaption := 'Test ' + Trim(edtMenuCaption.Text);
      WizardComment := Trim(edtComment.Text);

      ModuleCreator := TCnTestWizardCreator.Create;
      ModuleCreator.TestWizard := Self;

{$IFDEF BDS}
      if dlgSave.Execute then
        ModuleCreator.FileName := dlgSave.FileName
      else
        Exit;
{$ENDIF}

      (BorlandIDEServices as IOTAModuleServices).CreateModule(ModuleCreator);
    end;
    Free;
  end;

end;

class procedure TCnTestWizard.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnTestWizardWizardName;
  Author := SCnPack_LiuXiao;
  Email := SCnPack_LiuXiaoEmail;
  Comment := SCnTestWizardWizardComment;
end;

{ TCnTestWizardCreator }

procedure TCnTestWizardCreator.DoReplaceTagsSource(const TagString: string;
  TagParams: TStrings; var ReplaceText: string; ASourceType: TCnSourceType;
  ModuleIdent, FormIdent, AncestorIdent: string);
begin
  if ASourceType = stImplSource then
  begin
    if TagString = csClassName then
    begin
      ReplaceText := FTestWizard.WizardClassName;
    end
    else if TagString = csWizardCaption then
    begin
      ReplaceText := FTestWizard.WizardMenuCaption;
    end
    else if TagString = csWizardComment then
    begin
      ReplaceText := FTestWizard.WizardComment;
    end
    else if TagString = csCreateTime then
    begin
      ReplaceText := FormatDateTime('yyyy.MM.dd', Now);
    end;
  end;
end;

{$IFDEF BDS}

function TCnTestWizardCreator.GetUnnamed: Boolean;
begin
  Result := (FFileName = '');
end;

function TCnTestWizardCreator.GetImplFileName: string;
begin
  Result := _CnChangeFileExt(FFileName, '.pas')
end;

function TCnTestWizardCreator.GetIntfFileName: string;
begin
  Result := '';
end;

{$ENDIF}

function TCnTestWizardCreator.GetShowSource: Boolean;
begin
  Result := True;
end;

function TCnTestWizardCreator.GetTemplateFile(FileType: TCnSourceType): string;
begin
  if FileType = stImplSource then
    Result := MakePath(WizOptions.TemplatePath) + SCnTestWizardModuleTemplatePasFile
  else
    Result := '';
end;

{$IFDEF DEBUG}
initialization
  RegisterCnWizard(TCnTestWizard);
{$ENDIF}

end.
