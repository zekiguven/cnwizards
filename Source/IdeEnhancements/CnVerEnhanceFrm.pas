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

unit CnVerEnhanceFrm;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��汾��Ϣ��չ���õ�Ԫ
* ��Ԫ���ߣ���ʡ��hubdog��
* ��    ע��
* ����ƽ̨��JWinXPPro + Delphi 7.01
* ���ݲ��ԣ�JWinXPPro+ Delphi 7.01
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2005.05.05 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNVERENHANCEWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, CnWizMultiLang, StdCtrls, CnLangTranslator, CnLangMgr,
  CnClasses, CnLangStorage, CnHashLangStorage;

type
  TCnVerEnhanceForm = class(TCnTranslateForm)
    grpVerEnh: TGroupBox;
    chkLastCompiled: TCheckBox;
    chkIncBuild: TCheckBox;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    lblNote: TLabel;
    lblFormat: TLabel;
    cbbFormat: TComboBox;
    procedure btnHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure chkLastCompiledClick(Sender: TObject);
  private
    { Private declarations }
  protected
    function GetHelpTopic: string; override;    
  public
    { Public declarations }
  end;

{$ENDIF CNWIZARDS_CNVERENHANCEWIZARD}

implementation

{$IFDEF CNWIZARDS_CNVERENHANCEWIZARD}

{$R *.dfm}

procedure TCnVerEnhanceForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

function TCnVerEnhanceForm.GetHelpTopic: string;
begin
  Result := 'CnVerEnhanceWizard';
end;

procedure TCnVerEnhanceForm.FormCreate(Sender: TObject);
begin
{$IFNDEF COMPILER6_UP}
  chkLastCompiled.Enabled := False;
  chkIncBuild.Enabled := False;
  lblFormat.Enabled := False;
  cbbFormat.Enabled := False;
{$ELSE}
  lblFormat.Enabled := chkLastCompiled.Checked;
  cbbFormat.Enabled := chkLastCompiled.Checked;
{$ENDIF}
end;

procedure TCnVerEnhanceForm.chkLastCompiledClick(Sender: TObject);
begin
  lblFormat.Enabled := chkLastCompiled.Checked;
  cbbFormat.Enabled := chkLastCompiled.Checked;
end;

{$ENDIF CNWIZARDS_CNVERENHANCEWIZARD}
end.

