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

unit CnTest<#ClassName>Wizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ�CnTest<#ClassName>Wizard
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��Windows 7 + Delphi 5
* ���ݲ��ԣ�XP/7 + Delphi 5/6/7
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��<#CreateTime> V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnWizClasses, CnWizUtils, CnWizConsts;

type

//==============================================================================
// CnTest<#ClassName>Wizard �˵�ר��
//==============================================================================

{ TCnTest<#ClassName>Wizard }

  TCnTest<#ClassName>Wizard = class(TCnMenuWizard)
  private

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
    procedure Execute; override;
  end;

implementation

//==============================================================================
// CnTest<#ClassName>Wizard �˵�ר��
//==============================================================================

{ TCnTest<#ClassName>Wizard }

procedure TCnTest<#ClassName>Wizard.Config;
begin
  ShowMessage('No Option for this Test Case.');
end;

procedure TCnTest<#ClassName>Wizard.Execute;
begin

end;

function TCnTest<#ClassName>Wizard.GetCaption: string;
begin
  Result := '<#WizardCaption>';
end;

function TCnTest<#ClassName>Wizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTest<#ClassName>Wizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTest<#ClassName>Wizard.GetHint: string;
begin
  Result := 'Test Hint';
end;

function TCnTest<#ClassName>Wizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTest<#ClassName>Wizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := '<#WizardCaption> Menu Wizard';
  Author := 'CnPack IDE Wizards';
  Email := 'master@cnpack.org';
  Comment := '<#WizardComment>';
end;

procedure TCnTest<#ClassName>Wizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTest<#ClassName>Wizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

initialization
  RegisterCnWizard(TCnTest<#ClassName>Wizard); // ע��˲���ר��

end.
