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

unit CnTestDesignMenuWizard;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ���������
* ��Ԫ���ƣ�����������Ҽ��˵���Ĳ���������Ԫ
* ��Ԫ���ߣ�CnPack ������
* ��    ע��
* ����ƽ̨��WinXP + Delphi 7
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 7 ����
* �� �� �����ô����е��ַ����ݲ�֧�ֱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id:  CnTestDesignMenuWizard 1146 2012-10-24 06:25:41Z liuxiaoshanzhashu@gmail.com $
* �޸ļ�¼��2015.05.20 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolsAPI, IniFiles, CnCommon, CnWizClasses, CnWizUtils, CnWizConsts, CnWizManager;

type

//==============================================================================
// ����������Ҽ��˵���Ĳ˵�ר��
//==============================================================================

{ TCnTestDesignMenuWizard }

  TCnTestDesignMenuWizard = class(TCnMenuWizard)
  private
    FExecutor: TCnContextMenuExecutor;
    procedure Executor2Execute(Sender: TObject);
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

  TCnTestDesignMenu1 = class(TCnBaseMenuExecutor)
    function GetActive: Boolean; override;
    function GetCaption: string; override;
    function GetEnabled: Boolean; override;
    function Execute: Boolean; override;
  end;

  TCnTestDesignMenu2 = class(TCnBaseMenuExecutor)
    function GetActive: Boolean; override;
    function GetCaption: string; override;
    function GetEnabled: Boolean; override;
    function Execute: Boolean; override;
  end;

  TCnTestDesignMenu3 = class(TCnBaseMenuExecutor)
    function GetActive: Boolean; override;
    function GetCaption: string; override;
    function GetEnabled: Boolean; override;
    function Execute: Boolean; override;
  end;

implementation

uses
  CnDebug;

//==============================================================================
// ����������Ҽ��˵���Ĳ˵�ר��
//==============================================================================

{ TCnTestDesignMenuWizard }

procedure TCnTestDesignMenuWizard.Config;
begin
  ShowMessage('No option for this test case.');
end;

procedure TCnTestDesignMenuWizard.Execute;
begin
  RegisterBaseDesignMenuExecutor(TCnTestDesignMenu1.Create(Self));
  RegisterBaseDesignMenuExecutor(TCnTestDesignMenu2.Create(Self));
  RegisterBaseDesignMenuExecutor(TCnTestDesignMenu3.Create(Self));
  ShowMessage('3 Menu Items Registered using TCnBaseMenuExecutor.' + #13#10
    + '1 Hidden, 1 Disabled and 1 Enabled. Please Check Designer Context Menu.');

  if FExecutor = nil then
  begin
    FExecutor := TCnContextMenuExecutor.Create;
    FExecutor.Active := True;
    FExecutor.Enabled := True;
    FExecutor.Caption := '2 Caption';
    FExecutor.Hint := '2 Hint';
    FExecutor.OnExecute := Executor2Execute;
    RegisterDesignMenuExecutor(FExecutor);
  end;
end;

procedure TCnTestDesignMenuWizard.Executor2Execute(Sender: TObject);
begin
  ShowMessage('Executor 2 Run Here.');
end;

function TCnTestDesignMenuWizard.GetCaption: string;
begin
  Result := 'Test Designer Menu';
end;

function TCnTestDesignMenuWizard.GetDefShortCut: TShortCut;
begin
  Result := 0;
end;

function TCnTestDesignMenuWizard.GetHasConfig: Boolean;
begin
  Result := True;
end;

function TCnTestDesignMenuWizard.GetHint: string;
begin
  Result := 'Test hint';
end;

function TCnTestDesignMenuWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

class procedure TCnTestDesignMenuWizard.GetWizardInfo(var Name, Author, Email, Comment: string);
begin
  Name := 'Test Designer Menu Wizard';
  Author := 'Liu Xiao';
  Email := 'master@cnpack.org';
  Comment := 'Test for Designer Context Menu';
end;

procedure TCnTestDesignMenuWizard.LoadSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnTestDesignMenuWizard.SaveSettings(Ini: TCustomIniFile);
begin

end;

{ TCnTestDesignMenu1 }

function TCnTestDesignMenu1.Execute: Boolean;
begin
  ShowMessage('Should NOT Run Here.');
  Result := True;
end;

function TCnTestDesignMenu1.GetActive: Boolean;
begin
  Result := False;
end;

function TCnTestDesignMenu1.GetCaption: string;
begin
  Result := 'Hidden Caption';
end;

function TCnTestDesignMenu1.GetEnabled: Boolean;
begin
  Result := True;
end;

{ TCnTestDesignMenu2 }

function TCnTestDesignMenu2.Execute: Boolean;
begin
  ShowMessage('Should NOT Run Here.');
  Result := True;
end;

function TCnTestDesignMenu2.GetActive: Boolean;
begin
  Result := True;
end;

function TCnTestDesignMenu2.GetCaption: string;
begin
  Result := 'Disabled Caption'
end;

function TCnTestDesignMenu2.GetEnabled: Boolean;
begin
  Result := False;
end;

{ TCnTestDesignMenu3 }

function TCnTestDesignMenu3.Execute: Boolean;
begin
  ShowMessage('Should Run Here.');
  Result := True;
end;

function TCnTestDesignMenu3.GetActive: Boolean;
begin
  Result := True;
end;

function TCnTestDesignMenu3.GetCaption: string;
begin
  Result := 'Enabled Caption';
end;

function TCnTestDesignMenu3.GetEnabled: Boolean;
begin
  Result := True;
end;

initialization
  RegisterCnWizard(TCnTestDesignMenuWizard); // ע��˲���ר��

end.
