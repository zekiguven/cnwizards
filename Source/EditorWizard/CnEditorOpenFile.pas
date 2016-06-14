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

unit CnEditorOpenFile;
{* |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����ļ����ߵ�Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����ô����е��ַ��������ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2011.11.03 V1.2
*               �Ż����ļ����д��������ļ���֧��
*           2003.03.06 V1.1
*               ��չ��·��������Χ��֧�ֹ�������·��
*           2002.12.06 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNEDITORWIZARD}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus,
  StdCtrls, IniFiles, ToolsAPI, CnConsts, CnWizUtils, CnEditorWizard, CnWizConsts,
  CnEditorOpenFileFrm, CnCommon, CnWizOptions;

type

//==============================================================================
// ���ļ�������
//==============================================================================

{ TCnEditorOpenFile }

  TCnEditorOpenFile = class(TCnBaseEditorTool)
  private
    FFileList: TStrings;
    class procedure DoFindFile(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
    procedure DoFindFileList(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
  protected

  public
    destructor Destroy; override;

    function GetCaption: string; override;
    function GetHint: string; override;
    function GetDefShortCut: TShortCut; override;
    procedure Execute; override;
    procedure GetEditorInfo(var Name, Author, Email: string); override;

    class function SearchAndOpenFile(FileName: string): Boolean;
    function SearchFileList(FileName: string): Boolean;
  end;

{$ENDIF CNWIZARDS_CNEDITORWIZARD}

implementation

{$IFDEF CNWIZARDS_CNEDITORWIZARD}

uses
  CnWizIdeUtils;

var
  SrcFile: string;
  DstFile: string;
  Found: Boolean = False;

// ��ָ�����ļ�
function DoOpenFile(const FileName: string): Boolean;
var
  F: TSearchRec;
  AName: string;
begin
  if FindFirst(FileName, faAnyFile, F) = 0 then
  begin
    AName := _CnExtractFilePath(FileName) + (F.Name); // ȡ����ʵ���ļ���
    FindClose(F);                                  // ��Ϊ�û�����Ŀ�����ȫСд
    CnOtaOpenFile(AName);
    Result := True;
  end
  else
    Result := False;
end;

//==============================================================================
// ���ļ�������
//==============================================================================

{ TCnEditorOpenFile }

class procedure TCnEditorOpenFile.DoFindFile(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
begin
  if SameFileName(_CnExtractFileName(FileName), SrcFile) then
  begin
    DstFile := FileName;
    Found := True;
    Abort := True;
  end;
end;

procedure TCnEditorOpenFile.Execute;
var
  FileName, F: string;
  Ini: TCustomIniFile;
begin
  Ini := CreateIniFile;
  try
    F := CnInputBox(SCnEditorOpenFileDlgCaption,
      SCnEditorOpenFileDlgHint, '', Ini);
  finally
    Ini.Free;
  end;
  
  if F <> '' then
    if not SearchAndOpenFile(F) then
    begin
      // For Vcl.Forms like
      if IsDelphiRuntime then
        FileName := F + '.pas'
      else
        FileName := F + '.cpp';

      if not SearchAndOpenFile(FileName) then
      begin
        // ��һδ�ҵ�����ƥ������
        if FFileList = nil then
           FFileList := TStringList.Create
        else
          FFileList.Clear;

        if SearchFileList(F) and (FFileList.Count > 0) then
        begin
          // �ѵ����б�
          ShowOpenFileResultList(FFileList);
        end
        else
          ErrorDlg(SCnEditorOpenFileNotFind);
      end;

    end;
end;

function TCnEditorOpenFile.GetCaption: string;
begin
  Result := SCnEditorOpenFileMenuCaption;
end;

function TCnEditorOpenFile.GetDefShortCut: TShortCut;
begin
{$IFDEF DELPHI}
  Result := ShortCut(Word('O'), [ssCtrl, ssAlt]);
{$ELSE}
  Result := 0;
{$ENDIF}
end;

function TCnEditorOpenFile.GetHint: string;
begin
  Result := SCnEditorOpenFileMenuHint;
end;

procedure TCnEditorOpenFile.GetEditorInfo(var Name, Author, Email: string);
begin
  Name := SCnEditorOpenFileName;
  Author := SCnPack_Zjy;
  Email := SCnPack_ZjyEmail;
end;

class function TCnEditorOpenFile.SearchAndOpenFile(
  FileName: string): Boolean;

  function SearchAFile(F: string): Boolean;
  var
    I: Integer;
    Paths: TStrings;
    PathName: string;
  begin
    Result := True;
    Paths := TStringList.Create;
    try
      GetLibraryPath(Paths);
      for I := 0 to Paths.Count - 1 do
      begin
        PathName := MakePath(Paths[I]) + F;
        if DoOpenFile(PathName) then
          Exit;
      end;

      SrcFile := F;
      DstFile := '';
      Found := False;
      FindFile(MakePath(GetInstallDir) + 'Source\', '*.*', DoFindFile, nil, True, True);
      if Found and DoOpenFile(DstFile) then
        Exit
      else
        Result := False;
    finally
      Paths.Free;
    end;
  end;

begin
  if Pos('.', FileName) > 0 then // ����ļ������е㣬���������ص�����
  begin
    // ����ԭʼ�ļ���
    Result := SearchAFile(FileName);
    if Result then
      Exit;
  end;

  // �е㵫û�ҵ�����û�㣬�ͼ���չ��
  if IsDelphiRuntime then
    FileName := FileName + '.pas'
  else
    FileName := FileName + '.cpp';

  Result := SearchAFile(FileName);
end;

function TCnEditorOpenFile.SearchFileList(FileName: string): Boolean;
var
  I: Integer;
  Paths: TStrings;
begin
  Paths := TStringList.Create;
  try
    GetLibraryPath(Paths);
    for I := 0 to Paths.Count - 1 do
      FindFile(MakePath(Paths[I]), '*' + FileName + '*', DoFindFileList, nil, True, True);

    FindFile(MakePath(GetInstallDir) + 'Source\', '*' + FileName + '*', DoFindFileList, nil, True, True);

    Result := FFileList.Count > 0;
  finally
    Paths.Free;
  end;
end;

destructor TCnEditorOpenFile.Destroy;
begin
  FreeAndNil(FFileList);
  inherited;
end;

procedure TCnEditorOpenFile.DoFindFileList(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
var
  Ext: string;
begin
  if FFileList.IndexOf(FileName) < 0 then
  begin
    Ext := UpperCase(_CnExtractFileExt(FileName));

    if IsDelphiRuntime and (Pos(Ext, UpperCase(WizOptions.DelphiExt)) > 0) then
      FFileList.Add(FileName)
    else if not IsDelphiRuntime and (Pos(Ext, UpperCase(WizOptions.CExt)) > 0) then
      FFileList.Add(FileName);
  end;
end;

initialization
  RegisterCnEditor(TCnEditorOpenFile); // ע��ר��

{$ENDIF CNWIZARDS_CNEDITORWIZARD}
end.
