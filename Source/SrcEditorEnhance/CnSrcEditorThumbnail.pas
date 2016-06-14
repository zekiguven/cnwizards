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

unit CnSrcEditorThumbnail;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�����༭����չԤ������ͼʵ�ֵ�Ԫ
* ��Ԫ���ߣ���Х (liuxiuao@cnpack.org)
* ��    ע��
* ����ƽ̨��PWinXP + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2015.07.16
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Dialogs, ToolsAPI,
  IniFiles, Forms, ExtCtrls, Menus, StdCtrls, AppEvnts, CnCommon, CnFloatWindow,
  CnWizUtils, CnWizIdeUtils, CnWizNotifier, CnEditControlWrapper, CnWizClasses;

const
  WM_NCMOUSELEAVE       = $02A2;

type
  TCnSrcEditorThumbnail = class;

  TCnSrcThumbnailWindow = class(TCustomMemo)
  private
    FMouseIn: Boolean;
    FThumbnail: TCnSrcEditorThumbnail;
    FPopup: TPopupMenu;
    FLineHintWindow: TCnFloatWindow;
    FLineHintLabel: TLabel;
    FTopLine: Integer;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;

    procedure MouseLeave(var Msg: TMessage); message WM_MOUSELEAVE;

    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseWheel(var Msg: TWMMouseWheel); message WM_MOUSEWHEEL;
    procedure MouseDblClick(var Msg: TWMMouse); message WM_LBUTTONDBLCLK;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetPos(X, Y: Integer);
    procedure UpdateHintPos;
    procedure SetTopLine(const Value: Integer; UseRelative: Boolean);

    property Thumbnail: TCnSrcEditorThumbnail read FThumbnail write FThumbnail;
    property TopLine: Integer read FTopLine; // ��ʾ�Ķ����кţ�0 ��ʼ
    property LineHintWindow: TCnFloatWindow read FLineHintWindow;
  end;

//==============================================================================
// ����༭����չ����ͼ����
//==============================================================================

{ TCnSrcEditorThumbnail }

  TCnSrcEditorThumbnail = class(TObject)
  private
    FActive: Boolean;
    FThumbWindow: TCnSrcThumbnailWindow;
    // FThumbMemo: TMemo;
    FInScroll: Boolean;
    FEditControl: TWinControl;
    FPoint: TPoint; // ��������洢�����λ������ʾ���壬x��y �� FEditControl �ڵ�����
    FShowTimer: TTimer;
    FHideTimer: TTimer;
    FAppEvents: TApplicationEvents;
    FShowThumbnail: Boolean;
    procedure EditControlMouseMove(Editor: TEditorObject; Shift: TShiftState;
      X, Y: Integer; IsNC: Boolean);
    procedure EditControlMouseLeave(Editor: TEditorObject; IsNC: Boolean);

    procedure OnShowTimer(Sender: TObject);
    procedure OnHideTimer(Sender: TObject);
    procedure AppDeactivate(Sender: TObject);

    procedure CheckCreateForm;
    procedure UpdateThumbnailForm(IsShow: Boolean; UseRelative: Boolean);
    procedure SetShowThumbnail(const Value: Boolean);
    // �������ݡ���������ͼ���ڵ�λ�ù����㡢��ʾ����ͼ����

    procedure CheckNotifiers;
  protected
    procedure SetActive(Value: Boolean);
    procedure ApplicationMessage(var Msg: TMsg; var Handled: Boolean);
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadSettings(Ini: TCustomIniFile);
    procedure SaveSettings(Ini: TCustomIniFile);
    procedure ResetSettings(Ini: TCustomIniFile);
    procedure LanguageChanged(Sender: TObject);

    property Active: Boolean read FActive write SetActive;
    property ShowThumbnail: Boolean read FShowThumbnail write SetShowThumbnail;
  end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}

implementation

{$IFDEF CNWIZARDS_CNSRCEDITORENHANCE}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

const
  SHOW_INTERVAL = 1000;
  csHintWidth = 90;
  csHintHeight = 24;

  csThumbnail = 'Thumbnail';                   
  csShowThumbnail = 'ShowThumbnail';

//==============================================================================
// ����༭����չ����ͼ
//==============================================================================

{ TCnSrcEditorThumbnail }

procedure TCnSrcEditorThumbnail.AppDeactivate(Sender: TObject);
begin
  if FThumbWindow <> nil then
    FThumbWindow.Visible := False;
end;

procedure TCnSrcEditorThumbnail.ApplicationMessage(var Msg: TMsg;
  var Handled: Boolean);
begin
  if FThumbWindow = nil then
    Exit;

  if (Msg.message = WM_MOUSEWHEEL) and FThumbWindow.Visible then
  begin
    SendMessage(FThumbWindow.Handle, WM_MOUSEWHEEL, Msg.wParam, Msg.lParam);
    Handled := True;
  end
  else if FThumbWindow.Visible and (Msg.hwnd = FThumbWindow.Handle) and
   (Msg.message > WM_MOUSEFIRST) and (Msg.message < WM_MOUSELAST) then
  begin
    // ���γ� MOUSEMOVE �� MOUSEWHEEL ֮���һ�������Ϣ
    // ��˫�����Ǵ���Ϊ��ת
    if Msg.message = WM_LBUTTONDBLCLK then
      SendMessage(FThumbWindow.Handle, WM_LBUTTONDBLCLK, Msg.wParam, Msg.lParam);
    Handled := True;
  end;
end;

procedure TCnSrcEditorThumbnail.CheckCreateForm;
var
  AFont: TFont;
  Canvas: TControlCanvas;
begin
  if FThumbWindow = nil then
  begin
    FThumbWindow := TCnSrcThumbnailWindow.Create(nil);
    FThumbWindow.Thumbnail := Self;
    FThumbWindow.DoubleBuffered := True;
    FThumbWindow.ReadOnly := True;
    FThumbWindow.Parent := Application.MainForm;
    FThumbWindow.Visible := False;
    FThumbWindow.BorderStyle := bsSingle;
    FThumbWindow.Color := clInfoBk;
    FThumbWindow.Width := 500;
    FThumbWindow.Height := 200;
    // FThumbForm.ScrollBars := ssVertical;

    AFont := TFont.Create;
    AFont.Name := 'Courier New';  {Do NOT Localize}
    AFont.Size := 10;

    GetIDERegistryFont('', AFont);
    FThumbWindow.Font := AFont;
    Canvas := TControlCanvas.Create;
    Canvas.Control := FThumbWindow;
    Canvas.Font := AFont;
    FThumbWindow.Width := Canvas.TextWidth(Spc(82));

    Canvas.Free;
  end;
end;

procedure TCnSrcEditorThumbnail.CheckNotifiers;
begin
  if Active and ShowThumbnail then
  begin
    EditControlWrapper.AddEditorMouseMoveNotifier(EditControlMouseMove);
    EditControlWrapper.AddEditorMouseLeaveNotifier(EditControlMouseLeave);
  end
  else
  begin
    EditControlWrapper.RemoveEditorMouseMoveNotifier(EditControlMouseMove);
    EditControlWrapper.REmoveEditorMouseLeaveNotifier(EditControlMouseLeave);
  end;
end;

constructor TCnSrcEditorThumbnail.Create;
begin
  inherited;
  // FShowThumbnail := True;

  FShowTimer := TTimer.Create(nil);
  FShowTimer.Enabled := False;
  FShowTimer.Interval := SHOW_INTERVAL;
  FShowTimer.OnTimer := OnShowTimer;

  FHideTimer := TTimer.Create(nil);
  FHideTimer.Enabled := False;
  FHideTimer.Interval := SHOW_INTERVAL;
  FHideTimer.OnTimer := OnHideTimer;

  FAppEvents := TApplicationEvents.Create(nil);
  FAppEvents.OnDeactivate := AppDeactivate;

  CheckCreateForm;
  CheckNotifiers;
  CnWizNotifierServices.AddApplicationMessageNotifier(ApplicationMessage);
end;

destructor TCnSrcEditorThumbnail.Destroy;
begin
  CnWizNotifierServices.RemoveApplicationMessageNotifier(ApplicationMessage);
  EditControlWrapper.RemoveEditorMouseMoveNotifier(EditControlMouseMove);
  EditControlWrapper.REmoveEditorMouseLeaveNotifier(EditControlMouseLeave);

  FAppEvents.Free;
  FHideTimer.Free;
  FShowTimer.Free;

  FThumbWindow.Free;
  inherited;
end;

procedure TCnSrcEditorThumbnail.EditControlMouseLeave(
  Editor: TEditorObject; IsNC: Boolean);
begin
  if not Active or not FShowThumbnail or (Editor.EditControl <> CnOtaGetCurrentEditControl) then
    Exit;

  FInScroll := False;
  FShowTimer.Enabled := False; // �뿪�˵Ļ���׼����ʾ�ľ�ͣ��
  FHideTimer.Enabled := True;  // ׼������
end;

procedure TCnSrcEditorThumbnail.EditControlMouseMove(Editor: TEditorObject;
  Shift: TShiftState; X, Y: Integer; IsNC: Boolean);
var
  InRightScroll: Boolean;
begin
  if not Active or not FShowThumbnail or (Editor.EditControl <> CnOtaGetCurrentEditControl) then
    Exit;

  // �жϵ�ǰ�Ƿ�����Ҫ��ʾ����ͼ��������߼�Ϊ��X ���� ClientWidth ���� IsNC
  InRightScroll := (IsNC and (X >= Editor.EditControl.ClientWidth));
  FEditControl := TWinControl(Editor.EditControl);

  CheckCreateForm;
  if not FInScroll and InRightScroll then // ��һ�ν����˹�������
  begin
    // ֻ�е�һ�ν����˹�����������Ҫ�󲶻� MouseLeave
    FPoint.x := X;
    FPoint.y := Y;
    if not FThumbWindow.Visible then
    begin
      // ��һ�ν�����������ʾ Thumbnail Form �Ķ�ʱ��
      FShowTimer.Enabled := True;
    end
    else
    begin
      // ��������ʾ�� Thumbnail ��λ�ò���������λ��
      UpdateThumbnailForm(False, False);
    end;
  end
  else if InRightScroll then
  begin
    FPoint.x := X;
    FPoint.y := Y;
    // ���ڲ��������Ѿ���ʾ Thumbnail �ˣ���������������
    if FThumbWindow.Visible then
    begin
      FHideTimer.Enabled := False;
      UpdateThumbnailForm(False, True);
    end;
  end;

  FInScroll := InRightScroll;
end;

procedure TCnSrcEditorThumbnail.LanguageChanged(Sender: TObject);
begin

end;

procedure TCnSrcEditorThumbnail.LoadSettings(Ini: TCustomIniFile);
begin
  ShowThumbnail := Ini.ReadBool(csThumbnail, csShowThumbnail, FShowThumbnail);
end;

procedure TCnSrcEditorThumbnail.OnHideTimer(Sender: TObject);
begin
  FHideTimer.Enabled := False;
  if FThumbWindow <> nil then
  begin
    FThumbWindow.Visible := False;
    FThumbWindow.LineHintWindow.Visible := False;
  end;
end;

procedure TCnSrcEditorThumbnail.OnShowTimer(Sender: TObject);
begin
  FShowTimer.Enabled := False;
  UpdateThumbnailForm(True, False);
end;

procedure TCnSrcEditorThumbnail.ResetSettings(Ini: TCustomIniFile);
begin

end;

procedure TCnSrcEditorThumbnail.SaveSettings(Ini: TCustomIniFile);
begin
  Ini.WriteBool(csThumbnail, csShowThumbnail, FShowThumbnail);
end;

procedure TCnSrcEditorThumbnail.SetActive(Value: Boolean);
begin
  if Value <> FActive then
  begin
    FActive := Value;
    CheckNotifiers;

    if not FActive then
      if FThumbWindow <> nil then
        FThumbWindow.Hide;
  end;
end;

procedure TCnSrcEditorThumbnail.SetShowThumbnail(const Value: Boolean);
begin
  if FShowThumbnail <> Value then
  begin
    FShowThumbnail := Value;
    CheckNotifiers;

    if FThumbWindow <> nil then
      FreeAndNil(FThumbWindow);
  end;
end;

procedure TCnSrcEditorThumbnail.UpdateThumbnailForm(IsShow: Boolean; UseRelative: Boolean);
var
  P: TPoint;
  ThisLine: Integer;
begin
  CheckCreateForm;

  // �������ݡ���������ͼ���ڵ�λ�ù����㡢��ʾ����ͼ����
  if IsShow or (FThumbWindow.Lines.Text = '') then
    FThumbWindow.Lines.Text := CnOtaGetCurrentEditorSource;

  // FPoint ��Ҫ����ʱ�� FEditControl �ڵ����λ�� ���Դ�Ϊ׼���ô���λ��
  P := FPoint;
  P.x := FEditControl.Width;
  P := FEditControl.ClientToScreen(P);

  P.x := P.x - FThumbWindow.Width - 20;
  P.y := P.y - FThumbWindow.Height div 2;

  // ���ⳬ����Ļ
  if P.x < 0 then
    P.x := 0;
  if P.y < 0 then
    P.y := 0;

  if P.x + FThumbWindow.Width > Screen.Width then
    P.x := Screen.Width - FThumbWindow.Width;
  if P.y + FThumbWindow.Height > Screen.Height then
    P.y := Screen.Height - FThumbWindow.Height;

  FThumbWindow.SetPos(P.x, P.y) ;

  // ����λ�ù�����
  ThisLine := FThumbWindow.Lines.Count * FPoint.y div FEditControl.ClientHeight;
  FThumbWindow.SetTopLine(ThisLine, UseRelative);

  if IsShow and not FThumbWindow.Visible then
  begin
    FThumbWindow.Visible := True;
    // FThumbWindow.LineHintWindow.Visible := True;
    // TODO: ��ʱ���ã���Ϊ��������ݳ�������ԭ��δ֪
    
    FThumbWindow.SetPos(P.x, P.y) ;
  end;
end;

{ TCnSrcThumbnailForm }

constructor TCnSrcThumbnailWindow.Create(AOwner: TComponent);
begin
  inherited;
  FPopup := TPopupMenu.Create(Self);
  WordWrap := False;
  PopupMenu := FPopup;  // ȡ���������Դ����Ҽ��˵�

  FLineHintWindow := TCnFloatWindow.Create(Self);
  FLineHintWindow.Parent := Application.MainForm;
  FLineHintWindow.Height := csHintHeight;
  FLineHintWindow.Width := csHintWidth;
  FLineHintWindow.Visible := False;

  FLineHintLabel := TLabel.Create(Self);
  FLineHintLabel.Align := alClient;
  FLineHintLabel.Alignment := taCenter;
  FLineHintLabel.Layout := tlCenter;
  FLineHintLabel.Parent := FLineHintWindow;
end;

procedure TCnSrcThumbnailWindow.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or WS_CHILDWINDOW {or WS_SIZEBOX} or WS_MAXIMIZEBOX
    or WS_BORDER;
  Params.ExStyle := WS_EX_TOOLWINDOW or WS_EX_WINDOWEDGE;
  if CheckWinXP then
    Params.WindowClass.style := CS_DBLCLKS or CS_DROPSHADOW
  else
    Params.WindowClass.style := CS_DBLCLKS;
end;

procedure TCnSrcThumbnailWindow.CreateWnd;
begin
  inherited;
  Windows.SetParent(Handle, 0);
  CallWindowProc(DefWndProc, Handle, WM_SETFOCUS, 0, 0);

  SendMessage(Handle, EM_SETMARGINS, EC_LEFTMARGIN, 5);
  SendMessage(Handle, EM_SETMARGINS, EC_RIGHTMARGIN, 5);
end;

destructor TCnSrcThumbnailWindow.Destroy;
begin
  inherited;

end;

procedure TCnSrcThumbnailWindow.MouseDblClick(var Msg: TWMMouse);
var
  View: IOTAEditView;
  P: TOTAEditPos;
begin
  // ȥ TopLine ����ʶ�ĵط�
  View := CnOtaGetTopMostEditView;
  if View <> nil then
  begin
    P.Col := 1;
    P.Line := TopLine + 1; // 0 ��ʼ��� 1 ��ʼ
    CnOtaGotoEditPos(P, View, True);
  end;

  Visible := False;
  FLineHintWindow.Visible := False;
end;

procedure TCnSrcThumbnailWindow.MouseLeave(var Msg: TMessage);
begin
  FMouseIn := False;
  FThumbnail.FHideTimer.Enabled := True;
end;

procedure TCnSrcThumbnailWindow.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Tme: TTrackMouseEvent;
begin
  inherited;
  if not FMouseIn then
  begin
    Tme.cbSize := SizeOf(TTrackMouseEvent);
    Tme.dwFlags := TME_LEAVE;
    Tme.hwndTrack := Handle;
    TrackMouseEvent(Tme);
  end;

  FMouseIn := True;
  FThumbnail.FHideTimer.Enabled := False;
end;

procedure TCnSrcThumbnailWindow.MouseWheel(var Msg: TWMMouseWheel);
var
  NewLine: Integer;
begin
  if Msg.WheelDelta > 0 then
    NewLine := TopLine - Mouse.WheelScrollLines
  else
    NewLine := TopLine + Mouse.WheelScrollLines;

  if NewLine < 0 then
    NewLine := 0;
  if NewLine > Lines.Count then
    NewLine := Lines.Count;

  SetTopLine(NewLine, True);
end;

procedure TCnSrcThumbnailWindow.SetPos(X, Y: Integer);
begin
  Left := X;
  Top := Y;
  if Visible then
  begin
    SetWindowPos(Handle, HWND_TOPMOST, X, Y, 0, 0, SWP_NOACTIVATE or SWP_NOSIZE);
    UpdateHintPos;
  end;
end;

procedure TCnSrcThumbnailWindow.SetTopLine(const Value: Integer; UseRelative: Boolean);
begin
  if FTopLine <> Value then
  begin
    if UseRelative then
      SendMessage(Handle, EM_LINESCROLL, 0, Value - FTopLine)
    else
    begin
      SendMessage(Handle, EM_LINESCROLL, 0, -Lines.Count);
      SendMessage(Handle, EM_LINESCROLL, 0, Value);
    end;
    FTopLine := Value;
    FLineHintLabel.Caption := IntToStr(FTopLine + 1);
  end;
end;

procedure TCnSrcThumbnailWindow.UpdateHintPos;
begin
  if FLineHintWindow.Visible then
  begin
    SetWindowPos(FLineHintWindow.Handle, HWND_TOPMOST, Left + Width - FLineHintWindow.Width,
      Top - FLineHintWindow.Height - 5, 0, 0, SWP_NOACTIVATE or SWP_NOSIZE);
    FLineHintWindow.Invalidate;
  end;
end;

{$ENDIF CNWIZARDS_CNSRCEDITORENHANCE}
end.


