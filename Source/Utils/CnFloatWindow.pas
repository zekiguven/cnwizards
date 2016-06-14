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

unit CnFloatWindow;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ��������������������Լ�������������ʹ��
* ��Ԫ���ߣ�Johnson Zhong zhongs@tom.com http://www.longator.com
*           �ܾ��� zjy@cnpack.org
* ��    ע��
* ����ƽ̨��PWinXP + Delphi 7.1
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2015.07.21
*               �Ӵ������������Ƴ�
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Classes, Windows, Controls, SysUtils, Messages, CnCommon;

const
  CS_DROPSHADOW = $20000;

type
{ TCnFloatWindow }

  TCnFloatWindow = class(TCustomControl)
  private
    FOnPaint: TNotifyEvent;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure Paint; override;
  public
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
  end;

implementation

//==============================================================================
// ��������
//==============================================================================

{ TCnFloatWindow }

procedure TCnFloatWindow.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or WS_CHILDWINDOW or WS_MAXIMIZEBOX;
  Params.ExStyle := WS_EX_TOOLWINDOW or WS_EX_WINDOWEDGE;
  if CheckWinXP then
    Params.WindowClass.style := CS_DBLCLKS or CS_DROPSHADOW
  else
    Params.WindowClass.style := CS_DBLCLKS;
end;

procedure TCnFloatWindow.CreateWnd;
begin
  inherited;
  Windows.SetParent(Handle, 0);
  CallWindowProc(DefWndProc, Handle, WM_SETFOCUS, 0, 0);
end;

procedure TCnFloatWindow.Paint;
begin
  if Assigned(FOnPaint) then
    FOnPaint(Self);
end;

end.
