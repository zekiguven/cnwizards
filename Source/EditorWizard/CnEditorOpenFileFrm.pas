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

unit CnEditorOpenFileFrm;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����빤�߼����ļ��Ľ���б�Ԫ
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע��
* ����ƽ̨��PWinXPPro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2015.2.7 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNEDITORWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs, Contnrs,
{$IFDEF COMPILER6_UP}
  StrUtils,
{$ENDIF}
  ComCtrls, StdCtrls, ExtCtrls, Math, ToolWin, Clipbrd, IniFiles, ToolsAPI,
  Graphics, CnCommon, CnConsts, CnWizConsts, CnWizOptions, CnWizUtils, CnIni,
  CnWizIdeUtils, CnWizMultiLang, CnProjectViewBaseFrm, CnWizEditFiler,
  ImgList, ActnList;

type

//==============================================================================
// ��������б���
//==============================================================================

{ TCnEditorOpenFileForm }

  TCnEditorOpenFileForm = class(TCnProjectViewBaseForm)
    procedure StatusBarDrawPanel(StatusBar: TStatusBar;
      Panel: TStatusPanel; const Rect: TRect);
    procedure lvListData(Sender: TObject; Item: TListItem);
  private
    FFileList: TStrings;
  protected
    function DoSelectOpenedItem: string; override;
    function GetSelectedFileName: string; override;
    procedure UpdateStatusBar; override;
    procedure OpenSelect; override;
    function GetHelpTopic: string; override;
    procedure CreateList; override;
    procedure UpdateComboBox; override;
    procedure DoUpdateListView; override;
    procedure DoSortListView; override;
    procedure DrawListItem(ListView: TCustomListView; Item: TListItem); override;

    property FileList: TStrings read FFileList write FFileList;
  public
    { Public declarations }
    constructor Create(Owner: TComponent; List: TStrings); reintroduce;
  end;

function ShowOpenFileResultList(List: TStrings): Boolean;

{$ENDIF CNWIZARDS_CNEDITORWIZARD}

implementation

{$IFDEF CNWIZARDS_CNEDITORWIZARD}

{$R *.DFM}

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF DEBUG}

function ShowOpenFileResultList(List: TStrings): Boolean;
begin
  with TCnEditorOpenFileForm.Create(nil, List) do
  begin
    try
      ShowHint := WizOptions.ShowHint;
      Result := ShowModal = mrOk;
      if Result then
        BringIdeEditorFormToFront;
      List.Clear;
    finally
      Free;
    end;
  end;
end;

//==============================================================================
// ��������б���
//==============================================================================

{ TCnEditorOpenFileForm }

function TCnEditorOpenFileForm.DoSelectOpenedItem: string;
var
  CurrentModule: IOTAModule;
begin
  CurrentModule := CnOtaGetCurrentModule;
  Result := _CnChangeFileExt(_CnExtractFileName(CurrentModule.FileName), '');
end;

function TCnEditorOpenFileForm.GetSelectedFileName: string;
begin
  if Assigned(lvList.ItemFocused) then
    Result := Trim(FFileList[lvList.ItemFocused.Index]);
end;

function TCnEditorOpenFileForm.GetHelpTopic: string;
begin
  Result := 'CnEditorOpenFile';
end;

procedure TCnEditorOpenFileForm.OpenSelect;
var
  Item: TListItem;
begin
  Item := lvList.Selected;

  if not Assigned(Item) then
    Exit;

  if lvList.SelCount <= 1 then
    CnOtaOpenFile(FFileList[Item.Index]);

  ModalResult := mrOK;
end;

procedure TCnEditorOpenFileForm.StatusBarDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
var
  Item: TListItem;
begin
  Item := lvList.ItemFocused;
  if Assigned(Item) then
  begin
    if FileExists(FFileList[Item.Index]) then
      DrawCompactPath(StatusBar.Canvas.Handle, Rect, FFileList[Item.Index]);

    StatusBar.Hint := FFileList[Item.Index];
  end;
end;

procedure TCnEditorOpenFileForm.CreateList;
begin
  // Do nothing about list because list comes from outside
  ToolBar.Visible := False;
  pnlHeader.Visible := False;
end;

procedure TCnEditorOpenFileForm.UpdateComboBox;
begin
  cbbProjectList.Visible := False;
  lblProject.Visible := False;
end;

procedure TCnEditorOpenFileForm.DoUpdateListView;
begin
  lvList.Items.Count := FFileList.Count;
  lvList.Invalidate;

  UpdateStatusBar;
  if FFileList.Count > 0 then
    SelectItemByIndex(0);
end;

procedure TCnEditorOpenFileForm.UpdateStatusBar;
begin
  with StatusBar do
  begin
    Panels[1].Text := IntToStr(lvList.Items.Count);
  end;
end;

procedure TCnEditorOpenFileForm.DrawListItem(ListView: TCustomListView;
  Item: TListItem);
begin

end;

procedure TCnEditorOpenFileForm.lvListData(Sender: TObject;
  Item: TListItem);
begin
  if (Item.Index >= 0) and (Item.Index < FFileList.Count) then
  begin
    Item.Caption := _CnExtractFileName(FFileList[Item.Index]);
    Item.ImageIndex := 78;

    with Item.SubItems do
    begin
      Add(_CnExtractFilePath(FFileList[Item.Index]));
    end;
    RemoveListViewSubImages(Item);
  end;
end;

procedure TCnEditorOpenFileForm.DoSortListView;
begin

end;

constructor TCnEditorOpenFileForm.Create(Owner: TComponent;
  List: TStrings);
begin
  inherited Create(Owner);
  FileList := List;
end;

{$ENDIF CNWIZARDS_CNEDITORWIZARD}
end.

