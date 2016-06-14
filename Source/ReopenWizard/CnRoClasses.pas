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

unit CnRoClasses;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�����ʷ�ļ��ĸ����൥Ԫ
* ��Ԫ���ߣ�Leeon (real-like@163.com); John Howe
* ��    ע��
*           - TCnNodeManager : �ڵ������
*           - TCnStrIntfMap  : �ַ�����Ӧ�ӿ�Map
*           - TCnRoFiles     : ��¼�����ļ�
*           - TCnIniContainer: Ini�ļ�������
*           ʹ�ö�Ӧ�� Get ������ȡ�ӿ�ʵ��
*
* ����ƽ̨��PWin2000Pro + Delphi 5.02
* ���ݲ��ԣ�PWin2000 + Delphi 5/6/7
* �� �� �����ô����е��ַ���֧�ֱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2012-09-19 by shenloqi
*               ��ֲ��Delphi XE3
*           2004-12-12 V1.1
*               ȥ��TMyStringList������TList������
*               ��ӽڵ���������Լ���ȡ�ӿڵ�Map
*               ��TCnIniContainer�ƶ������ļ�
*           2004-03-02 V1.0
*               ��������ֲ��Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

uses
  Windows, SysUtils, Classes, IniFiles, CnRoConst, CnRoInterfaces, CnWizIni;

type
  PCnRoFileEntry = ^TCnRoFileEntry;
  TCnRoFileEntry = record
    FileName: string;
    OpenedTime: string;
    ClosingTime: string;
  end;

function GetNodeManager(ANodeSize: Cardinal): ICnNodeManager;

function GetStrIntfMap(): ICnStrIntfMap;

function GetRoFiles(ADefaultCap: Integer = iDefaultFileQty): ICnRoFiles;

function GetReopener(): ICnReopener;

{$ENDIF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

implementation

{$IFDEF CNWIZARDS_CNFILESSNAPSHOTWIZARD}

uses
  CnWizOptions, CnCommon;

type
  PCnGenericNode = ^TCnGenericNode;
  TCnGenericNode = packed record
    gnNext: PCnGenericNode;
    gnData: record end;
  end;
  
  TCnNodeManager = class(TInterfacedObject, ICnNodeManager)
  private
    FFreeList: Pointer;
    FNodeSize: Cardinal;
    FNodesPerPage: Cardinal;
    FPageHead: Pointer;
    FPageSize: Cardinal;
    procedure AllocNewPage;
  public
    constructor Create(aNodeSize: Cardinal);
    destructor Destroy; override;
    function AllocNode: Pointer;
    function AllocNodeClear: Pointer;
    procedure FreeNode(aNode: Pointer);
  end;

  TCnBaseClass = class(TInterfacedObject)
  private
    FNodeMgr: ICnNodeManager;
  protected
    property NodeMgr: ICnNodeManager read FNodeMgr write FNodeMgr;
  public
    constructor Create(ANodeSize: Integer); virtual;
    destructor Destroy; override;
  end;

  PCnStrIntfMapEntry = ^TCnStrIntfMapEntry;
  TCnStrIntfMapEntry = record
    Key: string;
    Value: IUnknown;
  end;

  TCnStrIntfMap = class(TCnBaseClass, ICnStrIntfMap)
  private
    FItems: TList;
  protected
    procedure Add(const Key: string; Value: IUnknown);
    procedure Clear;
    function GetValue(const Key: string): IUnknown;
    function IsEmpty: Boolean;
    function KeyOf(Value: IUnknown): string;
    procedure Remove(const Key: string);
  public
    constructor Create(ANodeSize: Integer); override;
    destructor Destroy; override;
  end;

  TCnRoFiles = class(TCnBaseClass, ICnRoFiles)
  private
    FCapacity: Integer;
    FColumnSorting: string;
    FItems: TList;
  protected
    procedure AddFile(AFileName: string);
    procedure AddFileAndTime(AFileName, AOpenedTime, AClosingTime: string);
    procedure Clear;
    function Count: Integer;
    procedure Delete(AIndex: Integer);
    function GetCapacity: Integer;
    function GetColumnSorting: string;
    function GetNodes(Index: Integer): Pointer;
    function GetString(Index: Integer): string;
    function IndexOf(AFileName: string): Integer;
    procedure SetCapacity(const AValue: Integer);
    procedure SetColumnSorting(const AValue: string);
    procedure SetString(Index: Integer; AValue: string);
    procedure SortByTimeOpened;
    procedure UpdateTime(AIndex: Integer; AOpenedTime, AClosingTime: string);
  public
    constructor Create(ADefaultCap: Integer); reintroduce;
    destructor Destroy; override;
  end;
  
  TSetTimeEvent = procedure (AFiles: ICnRoFiles; AIndex: Integer; ALocalData: Boolean);

  TCnIniContainer = class(TInterfacedObject, ICnReopener, ICnRoOptions)
  private
    FColumnPersistance: Boolean;
    FDefaultPage: Integer;
    FFormPersistance: Boolean;
    FIgnoreDefaultUnits: Boolean;
    FIniFile: TMemIniFile;
    FLocalDate: Boolean;
    FRoFilesList: ICnStrIntfMap;
    FSortPersistance: Boolean;
    FAutoSaveInterval: Cardinal;
    procedure CheckForIni;
    procedure CreateRoFilesList;
    procedure DestroyRoFilesList;
    function GetIniFileName: string;
    procedure GetValues(const ASection: string; Strings: TStrings);
    procedure ReadAll;
    procedure ReadFiles(ASection: string);
    procedure WriteFiles(ASection: string);
  protected
    function GetColumnPersistance: Boolean;
    function GetDefaultPage: Integer;
    function GetFiles(Name: string): ICnRoFiles;
    function GetFormPersistance: Boolean;
    function GetIgnoreDefaultUnits: Boolean;
    function GetLocalDate: Boolean;
    function GetSortPersistance: Boolean;
    function GetAutoSaveInterval: Cardinal;
    procedure LogClosingFile(AFileName: string);
    procedure LogFile(AFileName: string; ASetTime: TSetTimeEvent);
    procedure LogOpenedFile(AFileName: string);
    procedure SaveAll;
    procedure SaveFiles;
    procedure SaveSetting;
    procedure SetColumnPersistance(const AValue: Boolean);
    procedure SetDefaultPage(const AValue: Integer);
    procedure SetFormPersistance(const AValue: Boolean);
    procedure SetIgnoreDefaultUnits(const AValue: Boolean);
    procedure SetLocalDate(const AValue: Boolean);
    procedure SetSortPersistance(const AValue: Boolean);
    procedure SetAutoSaveInterval(const AValue: Cardinal);
    procedure UpdateIniFile;
    property Files[Name: string]: ICnRoFiles read GetFiles;
  public
    constructor Create;
    destructor Destroy; override;
  end;
  
function GetCurrTime(ALocalData: Boolean): string;
var
  S: string;
begin
  if (ALocalData) then
    S := {$IFDEF DelphiXE3_UP}FormatSettings.{$ENDIF}LongTimeFormat
  else
    S := SDataFormat;
  Result := FormatDateTime(S, Now);
end;

procedure SetOpenedTime(AFiles: ICnRoFiles; AIndex: Integer; ALocalData: Boolean);
begin
  AFiles.UpdateTime(AIndex, GetCurrTime(ALocalData), '');
end;

procedure SetClosingTime(AFiles: ICnRoFiles; AIndex: Integer; ALocalData: Boolean);
begin
  AFiles.UpdateTime(AIndex, '', GetCurrTime(ALocalData));
end;

function CompareOpenedTime(Item1, Item2: Pointer): Integer;
begin
  Result := AnsiCompareStr(PCnRoFileEntry(Item1)^.OpenedTime, PCnRoFileEntry(Item2)^.OpenedTime);
end;

constructor TCnNodeManager.Create(aNodeSize: Cardinal);
begin
  inherited Create;
  if (aNodeSize <= SizeOf(Pointer)) then
    aNodeSize := SizeOf(Pointer)
  else
    aNodeSize := ((aNodeSize + 3) shr 2) shl 2;
  FNodeSize := aNodeSize;
  
  FNodesPerPage := (PageSize - SizeOf(Pointer)) div aNodeSize;
  if (FNodesPerPage > 1) then
  begin
    FPageSize := 1024;
  end else
  begin
    FNodesPerPage := 1;
    FPagesize := aNodeSize + SizeOf(Pointer);
  end;
end;

destructor TCnNodeManager.Destroy;
var
  Temp: Pointer;
begin
  while (FPageHead <> nil) do
  begin
    Temp := PCnGenericNode(FPageHead)^.gnNext;
    FreeMem(FPageHead, FPageSize);
    FPageHead := Temp;
  end;
  inherited Destroy;
end;

procedure TCnNodeManager.AllocNewPage;
var
  NewPage: PAnsiChar;
  index: Integer;
begin
  GetMem(NewPage, FPageSize);
  PCnGenericNode(NewPage)^.gnNext := FPageHead;
  FPageHead := NewPage;
  
  Inc(NewPage, SizeOf(Pointer));
  for index := FNodesPerPage - 1 downto 0 do
  begin
    FreeNode(NewPage);
    Inc(NewPage, FNodeSize);
  end;
end;

function TCnNodeManager.AllocNode: Pointer;
begin
  if (FFreeList = nil) then AllocNewPage;
  Result := FFreeList;
  FFreeList := PCnGenericNode(FFreeList)^.gnNext;
end;

function TCnNodeManager.AllocNodeClear: Pointer;
begin
  if (FFreeList = nil) then AllocNewPage;
  Result := FFreeList;
  FFreeList := PCnGenericNode(FFreeList)^.gnNext;
  FillChar(Result^, FNodeSize, 0);
end;

procedure TCnNodeManager.FreeNode(aNode: Pointer);
begin
  if (aNode = nil) then Exit;
  PCnGenericNode(aNode)^.gnNext := FFreeList;
  FFreeList := aNode;
end;

constructor TCnBaseClass.Create(ANodeSize: Integer);
begin
  inherited Create;
  FNodeMgr := GetNodeManager(ANodeSize);
end;

destructor TCnBaseClass.Destroy;
begin
  FNodeMgr := nil;
  inherited Destroy;
end;

constructor TCnStrIntfMap.Create(ANodeSize: Integer);
begin
  inherited Create(ANodeSize);
  FItems := TList.Create();
end;

destructor TCnStrIntfMap.Destroy;
begin
  Clear;
  FreeAndNil(FItems);
  inherited Destroy;
end;

procedure TCnStrIntfMap.Add(const Key: string; Value: IUnknown);
var
  P: PCnStrIntfMapEntry;
begin
  P := NodeMgr.AllocNodeClear;
  P^.Key := Key;
  P^.Value := Value;
  FItems.Add(P);
end;

procedure TCnStrIntfMap.Clear;
var
  I: Integer;
  Temp: PCnStrIntfMapEntry;
begin
  for I := 0 to FItems.Count - 1 do
  begin
    Temp := FItems[I];
    Temp.Key := '';
    Temp.Value := nil;
    NodeMgr.FreeNode(Temp);
  end; //end for
  FItems.Clear;
end;

function TCnStrIntfMap.GetValue(const Key: string): IUnknown;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FItems.Count - 1 do
  begin
    if (AnsiSameText(PCnStrIntfMapEntry(FItems[I]).Key, Key)) then
    begin
      Result := PCnStrIntfMapEntry(FItems[I]).Value;
      Exit;
    end;
  end; //end for
end;

function TCnStrIntfMap.IsEmpty: Boolean;
begin
  Result := FItems.Count = 0;
end;

function TCnStrIntfMap.KeyOf(Value: IUnknown): string;
var
  I: Integer;
begin
  for I := 0 to FItems.Count - 1 do
  begin
    if (PCnStrIntfMapEntry(FItems[I]).Value = Value) then
    begin
      Result := PCnStrIntfMapEntry(FItems[I]).Key;
      Exit;
    end;
  end; //end for
end;

procedure TCnStrIntfMap.Remove(const Key: string);
var
  I: Integer;
  Temp: PCnStrIntfMapEntry;
begin
  for I := 0 to FItems.Count - 1 do
  begin
    Temp := FItems[I];
    if (AnsiSameText(Temp.Key, Key)) then
    begin
      Temp.Key := '';
      Temp.Value := nil;
      NodeMgr.FreeNode(Temp);
      FItems.Delete(I);
      Exit;
    end;
  end; //end for
end;

constructor TCnRoFiles.Create(ADefaultCap: Integer);
begin
  inherited Create(SizeOf(TCnRoFileEntry));
  FItems := TList.Create();
  FCapacity := ADefaultCap;
end;

destructor TCnRoFiles.Destroy;
begin
  Clear;
  FreeAndNil(FItems);
  inherited Destroy;
end;

procedure TCnRoFiles.AddFile(AFileName: string);
begin
  AddFileAndTime(AFileName, '', '');
end;

procedure TCnRoFiles.AddFileAndTime(AFileName, AOpenedTime, AClosingTime: string);
var
  Node: PCnRoFileEntry;
begin
  Node := NodeMgr.AllocNodeClear;
  with Node^ do
  begin
    FileName := AFileName;
    OpenedTime := AOpenedTime;
    ClosingTime := AClosingTime;
  end;
  FItems.Add(Node);
end;

procedure TCnRoFiles.Clear;
var
  I: Integer;
begin
  for I := FItems.Count - 1 downto 0 do
  begin
    Delete(I);
  end; //end for
end;

function TCnRoFiles.Count: Integer;
begin
  Result := FItems.Count;
end;

procedure TCnRoFiles.Delete(AIndex: Integer);
var
  Temp: PCnRoFileEntry;
begin
  Temp := FItems[AIndex];
  with Temp^ do
  begin
    FileName := '';
    OpenedTime := '';
    ClosingTime := '';
  end;
  NodeMgr.FreeNode(Temp);
  FItems.Delete(AIndex);
end;

function TCnRoFiles.GetCapacity: Integer;
begin
  Result := FCapacity;
end;

function TCnRoFiles.GetColumnSorting: string;
begin
  Result := FColumnSorting;
end;

function TCnRoFiles.GetNodes(Index: Integer): Pointer;
begin
  Result := FItems[Index];
end;

function TCnRoFiles.GetString(Index: Integer): string;
begin
  with PCnRoFileEntry(FItems[Index])^ do
  begin
    Result := FileName + SSeparator + OpenedTime + SSeparator + ClosingTime + SSeparator;
  end; //end with
end;

function TCnRoFiles.IndexOf(AFileName: string): Integer;
begin
  for Result := 0 to FItems.Count - 1 do
    if (AnsiSameText(PCnRoFileEntry(GetNodes(Result))^.FileName, AFileName)) then Exit;
  Result := -1;
end;

procedure TCnRoFiles.SetCapacity(const AValue: Integer);
begin
  FCapacity := AValue;
end;

procedure TCnRoFiles.SetColumnSorting(const AValue: string);
begin
  FColumnSorting := AValue;
end;

procedure TCnRoFiles.SetString(Index: Integer; AValue: string);
var
  I: Integer;
  AParam: array[0..2] of string;
  P, Start: PChar;
begin
  if (AnsiPos(SSeparator, AValue) = 0) then Exit;
  
  P := Pointer(AValue);
  I := 0;
  while P^ <> #0 do
  begin
    Start := P;
    while not CharInSet(P^, [#0, SSeparator]) do Inc(P);
    System.SetString(AParam[I], Start, P - Start);
    Inc(I);
    if P^ = SSeparator then Inc(P);
  end; //end while

  if (not FileExists(AParam[0])) then Exit;
  
  if (Index > Count - 1) or (Index < 0) then
  begin
    AddFileAndTime(AParam[0], AParam[1], AParam[2]);
  end else
  begin
    PCnRoFileEntry(FItems[Index])^.FileName := AParam[0];
    PCnRoFileEntry(FItems[Index])^.OpenedTime:= AParam[1];
    PCnRoFileEntry(FItems[Index])^.ClosingTime := AParam[2];
  end;
end;

procedure TCnRoFiles.SortByTimeOpened;
begin
  FItems.Sort(CompareOpenedTime);
end;

procedure TCnRoFiles.UpdateTime(AIndex: Integer; AOpenedTime, AClosingTime: string);
begin
  if (AIndex < 0) then Exit;
  with PCnRoFileEntry(FItems[AIndex])^ do
  begin
    if (AOpenedTime <> '') then OpenedTime := AOpenedTime;
    if (AClosingTime <> '') then ClosingTime := AClosingTime;
  end; //end with
end;

constructor TCnIniContainer.Create;
begin
  inherited Create;
  CheckForIni;
  FIniFile := TMemIniFile.Create(GetIniFileName);
  CreateRoFilesList;
  ReadAll;
end;

destructor TCnIniContainer.Destroy;
begin
  SaveAll;
  FreeAndNil(FIniFile);
  DestroyRoFilesList;
  inherited Destroy;
end;

procedure TCnIniContainer.CheckForIni;
var
  F: Text;
  
  function AddBool(const S: string; B: Boolean): string;
  begin
    Result := S + '=' + IntToStr(Integer(B));
  end;
  
  function AddNum(const S: string; I: Integer): string;
  begin
    Result := S + '=' + IntToStr(I);
  end;
  
begin
  if FileExists(GetIniFileName) then Exit;
  Assign(F, GetIniFileName);
  Rewrite(F);
  Writeln(F, Format(SSection, [SCapacity]));
  Writeln(F, AddNum(SProjectGroup, iDefaultFileQty));
  Writeln(F, AddNum(SProject, iDefaultFileQty));
  Writeln(F, AddNum(SUnt, iDefaultFileQty * 2));
  Writeln(F, AddNum(SPackge, iDefaultFileQty));
  Writeln(F, AddNum(SOther, iDefaultFileQty));
  Writeln(F, AddNum(SFavorite, iDefaultFileQty));
  
  Writeln(F, Format(SSection, [SDefaults]));
  Writeln(F, AddBool(SIgnoreDefaultUnits, True));
  Writeln(F, AddNum(SDefaultPage, 2));
  //  Writeln(F, AddBool(SFormPersistance, True));
  //  Writeln(F, AddBool(SColumnPersistance, False));
  Writeln(F, AddBool(SSortPersistance, True));
  Writeln(F, AddBool(SLocalDate, False));
  
  Writeln(F, Format(SSection, [SPersistance]));
  Writeln(F, AddBool(SColumnSorting + SProjectGroup, False));
  Writeln(F, AddBool(SColumnSorting + SProject, False));
  Writeln(F, AddBool(SColumnSorting + SUnt, False));
  Writeln(F, AddBool(SColumnSorting + SPackge, False));
  Writeln(F, AddBool(SColumnSorting + SOther, False));
  Writeln(F, AddBool(SColumnSorting + SFavorite, False));
  
  Writeln(F, Format(SSection, [SProjectGroup]));
  Writeln(F, Format(SSection, [SProject]));
  Writeln(F, Format(SSection, [SUnt]));
  Writeln(F, Format(SSection, [SPackge]));
  Writeln(F, Format(SSection, [SOther]));
  Writeln(F, Format(SSection, [SFavorite]));
  Close(F);
end;

procedure TCnIniContainer.CreateRoFilesList;
var
  I: Integer;
begin
  FRoFilesList := GetStrIntfMap;
  with FRoFilesList do
    for I := LowFileType to HighFileType do
      Add(FileType[I], GetRoFiles(iDefaultFileQty));
end;

procedure TCnIniContainer.DestroyRoFilesList;
begin
  FRoFilesList := nil;
end;

function TCnIniContainer.GetColumnPersistance: Boolean;
begin
  Result := FColumnPersistance;
end;

function TCnIniContainer.GetDefaultPage: Integer;
begin
  Result := FDefaultPage;
end;

function TCnIniContainer.GetFiles(Name: string): ICnRoFiles;
begin
  Result := ICnRoFiles(FRoFilesList[Name]);
end;

function TCnIniContainer.GetFormPersistance: Boolean;
begin
  Result := FFormPersistance;
end;

function TCnIniContainer.GetIgnoreDefaultUnits: Boolean;
begin
  Result := FIgnoreDefaultUnits;
end;

function TCnIniContainer.GetIniFileName: string;
begin
  Result := WizOptions.UserPath + SCnRecentFile;
end;

function TCnIniContainer.GetLocalDate: Boolean;
begin
  Result := FLocalDate;
end;

function TCnIniContainer.GetSortPersistance: Boolean;
begin
  Result := FSortPersistance;
end;

procedure TCnIniContainer.GetValues(const ASection: string; Strings: TStrings);
var
  I, J: Integer;
  S: string;
  Sections: TStrings;
  SectionStrings: TStrings;
begin
  Sections := TStringList.Create;
  try
    FIniFile.ReadSections(Sections);
  
    Strings.BeginUpdate;
    try
      Strings.Clear;
      I := Sections.IndexOf(ASection);
      if I < 0 then Exit;
  
      SectionStrings := TStrings(Sections.Objects[I]);
      for J := 0 to SectionStrings.Count - 1 do
      begin
        S := SectionStrings.Names[J];
        S := Copy(SectionStrings[J], Length(S) + 2, MaxInt);
        Strings.Add(S);
      end;
    finally
      Strings.EndUpdate;
    end;
  finally
    Sections.Free;
  end;          
end;

procedure TCnIniContainer.LogClosingFile(AFileName: string);
begin
  LogFile(AFileName, SetClosingTime);
end;

procedure TCnIniContainer.LogFile(AFileName: string; ASetTime: TSetTimeEvent);
var
  I: Integer;
  vFiles: ICnRoFiles;
  
  function GetList(S: string): ICnRoFiles;
  var
    Index: Integer;
  begin
    S := _CnExtractFileExt(S);
    Index := IndexStr(S, [
      '.BPG',
      '.DPR', '.BPR', '.BPF',
      '.PAS', '.H', '.HPP', '.C', '.CPP',
      '.DPK', '.BPK',
      '.FAV', '.BDSPROJ', '.DPROJ', '.CBPROJ',
      '.GROUPPROJ']);
    case Index of
      0, 15:
        Result := GetFiles(SProjectGroup);
      1, 2, 3, 12, 13, 14:
        Result := GetFiles(SProject);
      4, 5, 6, 7, 8:
        Result := GetFiles(SUnt);
      9, 10:
        Result := GetFiles(SPackge);
      11:
        Result := GetFiles(SFavorite);
    else
      Result := GetFiles(SOther);
    end;
  end;
  
  function IsDefaultUnit(S: string): Boolean;
  begin
    Result := (AnsiPos('ProjectGroup1', S) <> 0) or
              (AnsiPos('Project1', S) <> 0) or
              (AnsiPos('Package1', S) <> 0) or
              (AnsiPos('Unit1', S) <> 0)
  end;
  
  procedure SetTime(S: string; Idx: Integer);
  begin
    vFiles.AddFile(S);
    ASetTime(vFiles, Idx, GetLocalDate);
  end;
  
begin
  if (AFileName = '') then Exit;
  vFiles := GetList(AFileName);
  I := vFiles.IndexOf(AFileName);
  if (I >= 0) then
  begin
    ASetTime(vFiles, I, GetLocalDate);
  end else
  begin
    if (GetIgnoreDefaultUnits) and (IsDefaultUnit(AFileName)) then Exit;
    if vFiles.Count = vFiles.Capacity then
      vFiles.Delete(0)
    else if vFiles.Capacity < vFiles.Count then
      for I := 0 to (vFiles.Count - vFiles.Capacity) do
      begin
        vFiles.Delete(I);
      end;
    SetTime(AFileName, vFiles.Count - 1);
  end;
end;

procedure TCnIniContainer.LogOpenedFile(AFileName: string);
begin
  LogFile(AFileName, SetOpenedTime);
end;

procedure TCnIniContainer.ReadAll;
var
  I: Integer;
begin
  with FIniFile do
  begin
    SetIgnoreDefaultUnits(ReadBool(SDefaults, SIgnoreDefaultUnits, False));
    SetDefaultPage(ReadInteger(SDefaults, SDefaultPage, 0));
    SetLocalDate(ReadBool(SDefaults, SLocalDate, False));
    SetSortPersistance(ReadBool(SDefaults, SSortPersistance, False));
    SetAutoSaveInterval(ReadInteger(SDefaults, SAutoSaveInterval, 5));
    //SetColumnPersistance(ReadBool(SDefaults, SColumnPersistance, False));
    //SetFormPersistance(ReadBool(SDefaults, SFormPersistance, True));
    for I := LowFileType to HighFileType do
    begin
      Files[FileType[I]].Capacity := ReadInteger(SCapacity, FileType[I], iDefaultFileQty);
      Files[FileType[I]].ColumnSorting := ReadString(SPersistance, SColumnSorting + FileType[I], '0,0');
      ReadFiles(FileType[I]);
    end;
  end;
end;

procedure TCnIniContainer.ReadFiles(ASection: string);
var
  I: Integer;
  vFiles: ICnRoFiles;
  vStrs: TStrings;
begin
  vFiles := GetFiles(ASection);
  vStrs := TStringList.Create;
  try
    GetValues(ASection, vStrs);
    if (vStrs.Count = 0) then Exit;
    with vFiles do
    begin
      Clear;
      for I := 0 to vStrs.Count - 1 do
      begin
        SetString(-1, vStrs[I]);
      end;
      SortByTimeOpened;
    end;
  finally
    vStrs.Free;
  end;
end;

procedure TCnIniContainer.SaveAll;
begin
  SaveSetting;
  SaveFiles;
end;

procedure TCnIniContainer.SaveFiles;
var
  I: Integer;
begin
  for I := LowFileType to HighFileType do
  begin
    WriteFiles(FileType[I]);
  end;
  UpdateIniFile;
end;

procedure TCnIniContainer.SaveSetting;
var
  I: Integer;
begin
  with FIniFile do
  begin
    EraseSection(SDefaults);
    EraseSection(SPersistance);
    EraseSection(SCapacity);
    WriteBool(SDefaults, SIgnoreDefaultUnits, GetIgnoreDefaultUnits);
    WriteInteger(SDefaults, SDefaultPage, GetDefaultPage);
    WriteBool(SDefaults, SSortPersistance, GetSortPersistance);
    WriteBool(SDefaults, SLocalDate, GetLocalDate);
    WriteInteger(SDefaults, SAutoSaveInterval, FAutoSaveInterval);
    //WriteBool(SDefaults, SColumnPersistance, GetColumnPersistance);
    //WriteBool(SDefaults, SFormPersistance, GetFormPersistance);
    for I := LowFileType to HighFileType do
    begin
      WriteInteger(SCapacity, FileType[I], Files[FileType[I]].Capacity);
      WriteString(SPersistance, SColumnSorting + FileType[I], Files[FileType[I]].ColumnSorting);
    end;
  end; //end with
  UpdateIniFile;
end;

procedure TCnIniContainer.SetColumnPersistance(const AValue: Boolean);
begin
  FColumnPersistance := AValue;
end;

procedure TCnIniContainer.SetDefaultPage(const AValue: Integer);
begin
  FDefaultPage := AValue;
end;

procedure TCnIniContainer.SetFormPersistance(const AValue: Boolean);
begin
  FFormPersistance := AValue;
end;

procedure TCnIniContainer.SetIgnoreDefaultUnits(const AValue: Boolean);
begin
  FIgnoreDefaultUnits := AValue;
end;

procedure TCnIniContainer.SetLocalDate(const AValue: Boolean);
begin
  FLocalDate := AValue;
end;

procedure TCnIniContainer.SetSortPersistance(const AValue: Boolean);
begin
  FSortPersistance := AValue;
end;

procedure TCnIniContainer.UpdateIniFile;
begin
  FIniFile.UpdateFile;
end;

procedure TCnIniContainer.WriteFiles(ASection: string);
var
  I: Integer;
begin
  with Files[ASection], FIniFile do
  begin
    EraseSection(ASection);
    for I := 0 to Count - 1 do
    begin
      WriteString(ASection, SFilePrefix + IntToStr(I), GetString(I));
    end;
  end;
end;

{******************************************************************************}

function GetNodeManager(ANodeSize: Cardinal): ICnNodeManager;
begin
  Result := TCnNodeManager.Create(ANodeSize);
end;

function GetStrIntfMap(): ICnStrIntfMap;
begin
  Result := TCnStrIntfMap.Create(SizeOf(TCnStrIntfMapEntry));
end;

function GetRoFiles(ADefaultCap: Integer = iDefaultFileQty): ICnRoFiles;
begin
  Result := TCnRoFiles.Create(ADefaultCap);
end;

function GetReopener(): ICnReopener;
begin
  Result := TCnIniContainer.Create;
end;

function TCnIniContainer.GetAutoSaveInterval: Cardinal;
begin
  Result := FAutoSaveInterval;
end;

procedure TCnIniContainer.SetAutoSaveInterval(const AValue: Cardinal);
begin
  FAutoSaveInterval := AValue;
end;

{$ENDIF CNWIZARDS_CNFILESSNAPSHOTWIZARD}
end.


