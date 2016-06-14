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

unit CnHighlightSeparateLineFrm;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�����༭�����зָ��߸����������ô���
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id: CnHighlightSeparateLineFrm.pas 1146 2012-10-24 06:25:41Z liuxiaoshanzhashu@gmail.com $
* �޸ļ�¼��2013.01.20
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CnSpin, CnLangMgr, CnWizMultiLang, ExtCtrls;

type
  TCnHighlightSeparateLineForm = class(TCnTranslateForm)
    GroupBox1: TGroupBox;
    lblLineColor: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    lblLineType: TLabel;
    cbbLineType: TComboBox;
    shpSeparateLine: TShape;
    dlgColor: TColorDialog;
    seLineWidth: TCnSpinEdit;
    lblLineWidth: TLabel;
    procedure cbbLineTypeDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure btnHelpClick(Sender: TObject);
    procedure shpSeparateLineMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  protected
    function GetHelpTopic: string; override;
  public
    { Public declarations }
  end;

{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}

implementation

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}

uses
  CnSourceHighlight;

{$R *.DFM}

procedure TCnHighlightSeparateLineForm.cbbLineTypeDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  OldStyle: TPenStyle;
  OldBrushColor, OldPenColor: TColor;
begin
  OldStyle := cbbLineType.Canvas.Pen.Style;
  OldBrushColor := cbbLineType.Canvas.Brush.Color;
  OldPenColor := cbbLineType.Canvas.Pen.Color;

  if odSelected in State then
  begin
    cbbLineType.Canvas.Brush.Color := clHighlight;
    cbbLineType.Canvas.Pen.Color := clWhite;
  end
  else
  begin
    cbbLineType.Canvas.Brush.Color := clWhite;
    cbbLineType.Canvas.Pen.Color := clBlack;
  end;

  cbbLineType.Canvas.FillRect(Rect);

  HighlightCanvasLine(cbbLineType.Canvas, Rect.Left + 2, (Rect.Top + Rect.Bottom) div 2,
    Rect.Right - 2, (Rect.Top + Rect.Bottom) div 2, TCnLineStyle(Index));

  cbbLineType.Canvas.Pen.Style := OldStyle;
  cbbLineType.Canvas.Pen.Color := OldPenColor;
  cbbLineType.Canvas.Brush.Color := OldBrushColor;
end;

function TCnHighlightSeparateLineForm.GetHelpTopic: string;
begin
  Result := 'CnSourceHighlight';
end;

procedure TCnHighlightSeparateLineForm.btnHelpClick(Sender: TObject);
begin
  ShowFormHelp;
end;

procedure TCnHighlightSeparateLineForm.shpSeparateLineMouseDown(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if Sender is TShape then
  begin
    dlgColor.Color := TShape(Sender).Brush.Color;
    if dlgColor.Execute then
      TShape(Sender).Brush.Color := dlgColor.Color;
  end;
end;

{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}
end.
