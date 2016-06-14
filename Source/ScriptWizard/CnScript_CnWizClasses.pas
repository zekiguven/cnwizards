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

unit CnScript_CnWizClasses;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��ű��� CnWizClasses ע���࣬�в��� CnWizManager ����
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע���õ�Ԫ�� UnitParser v0.7 �Զ����ɵ��ļ��޸Ķ���
* ����ƽ̨��PWinXP SP2 + Delphi 7.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7
* �� �� �����ô����е��ַ���֧�ֱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2015.05.22 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
   SysUtils
  ,Classes
  ,uPSComponent
  ,uPSRuntime
  ,uPSCompiler
  ;
 
type 
(*----------------------------------------------------------------------------*)
  TPSImport_CnWizClasses = class(TPSPlugin)
  public
    procedure CompileImport1(CompExec: TPSScript); override;
    procedure ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter); override;
  end;

{ compile-time registration functions }
procedure SIRegister_TCnContextMenuExecutor(CL: TPSPascalCompiler);

{ run-time registration functions }
procedure RIRegister_CnWizClasses_Routines(S: TPSExec);
procedure RIRegister_TCnContextMenuExecutor(CL: TPSRuntimeClassImporter);

implementation

uses
   Windows
  ,Graphics
  ,Menus
  ,ActnList
  ,IniFiles
  ,ToolsAPI
  ,Registry
  ,ComCtrls
  ,Forms
  ,CnWizShortCut
  ,CnWizMenuAction
  ,CnIni
  ,CnWizConsts
  ,CnPopupMenu
  ,CnWizClasses
  ,CnWizManager
  ;

(* === compile-time registration functions === *)
(*----------------------------------------------------------------------------*)
procedure SIRegister_TCnContextMenuExecutor(CL: TPSPascalCompiler);
begin
  //with RegClassS(CL,'TCnBaseMenuExecutor', 'TCnContextMenuExecutor') do
  with CL.AddClassN(CL.FindClass('TCnBaseMenuExecutor'),'TCnContextMenuExecutor') do
  begin
    RegisterMethod('Constructor Create');
    RegisterProperty('Caption', 'string', iptrw);
    RegisterProperty('Hint', 'string', iptrw);
    RegisterProperty('Active', 'Boolean', iptrw);
    RegisterProperty('Enabled', 'Boolean', iptrw);
    RegisterProperty('OnExecute', 'TNotifyEvent', iptrw);
  end;
end;

(*----------------------------------------------------------------------------*)
procedure SIRegister_CnWizClasses(CL: TPSPascalCompiler);
begin
  SIRegister_TCnContextMenuExecutor(CL);
  CL.AddDelphiFunction('Procedure RegisterDesignMenuExecutor( Executor : TCnContextMenuExecutor)');
  CL.AddDelphiFunction('Procedure RegisterEditorMenuExecutor( Executor : TCnContextMenuExecutor)');
end;

(* === run-time registration functions === *)
(*----------------------------------------------------------------------------*)
procedure TCnContextMenuExecutorOnExecute_W(Self: TCnContextMenuExecutor; const T: TNotifyEvent);
begin Self.OnExecute := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnContextMenuExecutorOnExecute_R(Self: TCnContextMenuExecutor; var T: TNotifyEvent);
begin T := Self.OnExecute; end;

(*----------------------------------------------------------------------------*)
procedure TCnContextMenuExecutorEnabled_W(Self: TCnContextMenuExecutor; const T: Boolean);
begin Self.Enabled := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnContextMenuExecutorEnabled_R(Self: TCnContextMenuExecutor; var T: Boolean);
begin T := Self.Enabled; end;

(*----------------------------------------------------------------------------*)
procedure TCnContextMenuExecutorActive_W(Self: TCnContextMenuExecutor; const T: Boolean);
begin Self.Active := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnContextMenuExecutorActive_R(Self: TCnContextMenuExecutor; var T: Boolean);
begin T := Self.Active; end;

(*----------------------------------------------------------------------------*)
procedure TCnContextMenuExecutorHint_W(Self: TCnContextMenuExecutor; const T: string);
begin Self.Hint := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnContextMenuExecutorHint_R(Self: TCnContextMenuExecutor; var T: string);
begin T := Self.Hint; end;

(*----------------------------------------------------------------------------*)
procedure TCnContextMenuExecutorCaption_W(Self: TCnContextMenuExecutor; const T: string);
begin Self.Caption := T; end;

(*----------------------------------------------------------------------------*)
procedure TCnContextMenuExecutorCaption_R(Self: TCnContextMenuExecutor; var T: string);
begin T := Self.Caption; end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_CnWizClasses_Routines(S: TPSExec);
begin
  S.RegisterDelphiFunction(@RegisterDesignMenuExecutor, 'RegisterDesignMenuExecutor', cdRegister);
  S.RegisterDelphiFunction(@RegisterEditorMenuExecutor, 'RegisterEditorMenuExecutor', cdRegister);
end;

(*----------------------------------------------------------------------------*)
procedure RIRegister_TCnContextMenuExecutor(CL: TPSRuntimeClassImporter);
begin
  with CL.Add(TCnContextMenuExecutor) do
  begin
    RegisterVirtualConstructor(@TCnContextMenuExecutor.Create, 'Create');
    RegisterPropertyHelper(@TCnContextMenuExecutorCaption_R,@TCnContextMenuExecutorCaption_W,'Caption');
    RegisterPropertyHelper(@TCnContextMenuExecutorHint_R,@TCnContextMenuExecutorHint_W,'Hint');
    RegisterPropertyHelper(@TCnContextMenuExecutorActive_R,@TCnContextMenuExecutorActive_W,'Active');
    RegisterPropertyHelper(@TCnContextMenuExecutorEnabled_R,@TCnContextMenuExecutorEnabled_W,'Enabled');
    RegisterPropertyHelper(@TCnContextMenuExecutorOnExecute_R,@TCnContextMenuExecutorOnExecute_W,'OnExecute');
  end;
end;


(*----------------------------------------------------------------------------*)
procedure RIRegister_CnWizClasses(CL: TPSRuntimeClassImporter);
begin
  RIRegister_TCnContextMenuExecutor(CL);
end;

 
 
{ TPSImport_CnWizClasses }
(*----------------------------------------------------------------------------*)
procedure TPSImport_CnWizClasses.CompileImport1(CompExec: TPSScript);
begin
  SIRegister_CnWizClasses(CompExec.Comp);
end;
(*----------------------------------------------------------------------------*)
procedure TPSImport_CnWizClasses.ExecImport1(CompExec: TPSScript; const ri: TPSRuntimeClassImporter);
begin
  RIRegister_CnWizClasses(ri);
  RIRegister_CnWizClasses_Routines(CompExec.Exec); // comment it if no routines
end;
(*----------------------------------------------------------------------------*)
 
 
end.