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

unit CnCompDirectiveTree;
{* |<PRE>
================================================================================
* ������ƣ�CnPack ר�Ұ�
* ��Ԫ���ƣ�ʵ�ִ������ IFDEF �����ĵ�Ԫ
* ��Ԫ���ߣ���Х (liuxiao@cnpack.org)
* ��    ע���õ�ԪΪʹ�� TCnTree �� TCnLeaf ����������д���� IFDEF ����ʵ�ֵ�Ԫ��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2015.03.13 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

(*
  ����˼�룺�����뱻 IFDEF/ELSEIF/ENDIF �ֿ��������ֳ���״�ṹ��
  ����루δ�����س����У���
  begin 1111 {$IFDEF DEBUG} 22222 {$ELSEIF NDEBUG} 33333 {ELSE} 4444 {ENDIF} end;

  Root:
    SliceNode 0    -- ǰ׺���ޡ����ݣ�begin 1111
      SliceNode 1  -- ǰ׺��{$IFDEF DEBUG}�����ݣ�22222
      SliceNode 2  -- ǰ׺��{$ELSEIF NDEBUG}�����ݣ�33333
      SliceNode 3  -- ǰ׺��{$ELSE}�����ݣ�4444��
    SliceNode 5    -- ǰ׺��{$ENDIF}�����ݣ�end;

  ���Ƕ�ף�
  begin 111
  {$IFDEF DEBUG}
    2222
    {IFDEF NDEBUG}
       3333
    {$ENDIF}
    4444
  {$ELSE}
    5555
  {$ENDIF}
  end;

  ��
  Root:
    SliceNode 0     -- ǰ׺���ޡ����ݣ�begin 1111
      SliceNode 1   -- ǰ׺��{$IFDEF DEBUG}�����ݣ�22222
        SliceNode 2 -- ǰ׺��{$IFDEF NDEBUG}�����ݣ�3333
      SliceNode 3   -- ǰ׺��{$ENDIF}�����ݣ�4444
      SliceNode 4   -- ǰ׺��{$ELSE}�����ݣ�5555
    SliceNode 5     -- ǰ׺��{$ENDIF}�����ݣ�END;
  
  �����Ǽ�IFDEF�ͽ�һ�㲢��IFDEF�ͺ����������ȥ��
  ��ENDIF��һ���ENDIF�ͺ����������ȥ��
  ��ELSE/ELIF��ͬ�����ɸ��µġ�

  ������Ϻ󣬲�������ֱ���ӽڵ��ų� ENDIF/IFEND����Ŀ���ڵ��������Ľڵ��ֱ���ӽڵ�
  ���ÿһ���ӽڵ㣬����ͷ������ڵ��Դ���ַ�������������ʽ����
  ����ڵ��Ӧ���ɵ�Դ���ַ�����Ҫ��Ӧ����ʽ��������ݡ�
*)

uses
  SysUtils, Classes, Windows,
  CnTree, CnScaners, CnCodeFormatRules, CnTokens;

type
  TCnSliceNode = class(TCnLeaf)
  {* IFDEF �������ӽڵ�ʵ���࣬�� Child Ҳ�� TCnSliceNode}
  private
    FCompDirectiveStream: TMemoryStream;
    FNormalCodeStream: TMemoryStream;
    FCompDirectiveType: TPascalCompDirectiveType;
    FStartOffset: Integer;
    FReachingStart: Integer;
    FEndBlankLength: Integer;
    FKeepFlag: Boolean;
    FProcessed: Boolean;
    function GetItems(Index: Integer): TCnSliceNode;
    function GetLength: Integer;
    function GetReachingEnd: Integer;

    function BuildString: string;
    procedure SetKeepFlag(const Value: Boolean);
  protected

  public
    constructor Create(ATree: TCnTree); override;
    destructor Destroy; override;

    function IsSingleSlice: Boolean;

    property CompDirectiveStream: TMemoryStream read FCompDirectiveStream write FCompDirectiveStream;
    property NormalCodeStream: TMemoryStream read FNormalCodeStream write FNormalCodeStream;
    property CompDirectivtType: TPascalCompDirectiveType read FCompDirectiveType write FCompDirectiveType;

    property StartOffset: Integer read FStartOffset write FStartOffset;
    {* ����Ƭ��ԭʼԴ���е���ʼƫ�ƣ�����ʵ������������Ǳ���ָ���Ҳ�����Ǵ����}
    property ReachingStart: Integer read FReachingStart write FReachingStart;
    {* ����Ƭ��ֱ��Դ���е���ʼƫ�ƣ�����ʵ������������Ǳ���ָ���Ҳ�����Ǵ����}
    property Length: Integer read GetLength;
    {* ����Ƭ�����Ĵ��������ָ����ַ�����}
    property ReachingEnd: Integer read GetReachingEnd;
    {* ����Ƭ��ֱ��Դ���е��յ�ƫ�ƣ������������}
    property EndBlankLength: Integer read FEndBlankLength write FEndBlankLength;
    {* ��Ƭĩβ�Ŀհ��ַ������ȣ���ʽ��ʱ��Ҫ�õ����� ReachingEnd ������}
    
    property Items[Index: Integer]: TCnSliceNode read GetItems; default;
    {* ֱ��Ҷ�ڵ����� }

    property KeepFlag: Boolean read FKeepFlag write SetKeepFlag;
    property Processed: Boolean read FProcessed write FProcessed;
  end;

  TCnCompDirectiveTree = class(TCnTree)
  private
    FScaner: TAbstractScaner;
    function GetItems(AbsoluteIndex: Integer): TCnSliceNode;

    procedure SyncTexts;
    {* �����������ݸ�ֵ�� Text �����й����ʹ��}
    procedure ClearFlags;
    {* ��� KeepFlag ���}
    procedure PruneDuplicated;
    {* ͨ��������ȱ����ķ�ʽ����ǣ��ѷ��ǲ��е���������ֻʣһ��}

    procedure WidthFirstTravelSlice(Sender: TObject);
  public
    constructor Create(AStream: TStream);
    destructor Destroy; override;

    procedure ParseTree;
    {* ���ɱ���ָ�����}

    procedure SearchMultiNodes(Results: TList);
    {* ��������ֱ���ӽڵ���Ŀ���ڵ��������Ľڵ��ֱ���ӽڵ㣬����Ҫ�ų� ENDIF/IFEND}

    function ReachNode(EndNode: TCnSliceNode): string;
    {* ������ȱ��������ɴ�ͷ���˽ڵ��ֱ��Դ���ַ�������֤���ǲ��е�����ֻѡһ����
      ���������ǰһ�� Node �ͱ� Node ͬ������ Node �������� Node ���µ��ӽڵ����������
      ֱ�� EndNode �� Parent Ϊֹ���ټ� EndNode ����ͬʱ�� EndNode ���� ReachingOffset}

    property Items[AbsoluteIndex: Integer]: TCnSliceNode read GetItems;
  end;

implementation

const
  ACnPasCompDirectiveTokenStr: array[0..5] of AnsiString =
    ('{$IF ', '{$IFDEF ', '{$IFNDEF ', '{$ELSE', '{$ENDIF', '{$IFEND');

  ACnPasCompDirectiveTypes: array[0..5] of TPascalCompDirectiveType =
    (cdtIf, cdtIfDef, cdtIfNDef, cdtElse, cdtEndIf, cdtIfEnd);

{ TCnSliceNode }

constructor TCnSliceNode.Create(ATree: TCnTree);
begin
  inherited;

end;

destructor TCnSliceNode.Destroy;
begin
  FreeAndNil(FCompDirectiveStream);
  FreeAndNil(FNormalCodeStream);
  inherited;
end;

function TCnSliceNode.GetItems(Index: Integer): TCnSliceNode;
begin
  Result := TCnSliceNode(inherited GetItems(Index));
end;

function TCnSliceNode.GetLength: Integer;
begin
  Result := 0;
  if FCompDirectiveStream <> nil then
    Inc(Result, FCompDirectiveStream.Size div SizeOf(Char));
  if FNormalCodeStream <> nil then
    Inc(Result, FNormalCodeStream.Size div SizeOf(Char));
end;

function TCnSliceNode.GetReachingEnd: Integer;
begin
  Result := FReachingStart + GetLength;
end;

function TCnSliceNode.IsSingleSlice: Boolean;
begin
  Result := not GetHasChildren;
end;

procedure TCnSliceNode.SetKeepFlag(const Value: Boolean);
begin
  FKeepFlag := Value;
{$IFDEF DEBUG}
  Data := Integer(Value);
{$ENDIF}
end;

function TCnSliceNode.BuildString: string;
var
  Len: Integer;
begin
  Result := '';
  if (FCompDirectiveStream = nil) and (FNormalCodeStream = nil) then
    Exit;

  Len := 0;
  if FCompDirectiveStream <> nil then
    Len := FCompDirectiveStream.Size div SizeOf(Char);
  if FNormalCodeStream <> nil then
    Inc(Len, FNormalCodeStream.Size div SizeOf(Char));

  SetLength(Result, Len);
  if FCompDirectiveStream <> nil then
    CopyMemory(@(Result[1]), FCompDirectiveStream.Memory,
      FCompDirectiveStream.Size);

  if FNormalCodeStream <> nil then
  begin
    Len := 0;
    if FCompDirectiveStream <> nil then
      Len := FCompDirectiveStream.Size div SizeOf(Char);
    CopyMemory(@(Result[1 + Len]),
      FNormalCodeStream.Memory, FNormalCodeStream.Size);
  end;
end;

{ TCnCompDirectiveTree }

procedure TCnCompDirectiveTree.ClearFlags;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Items[I].KeepFlag := False;
    Items[I].Processed := False;
  end;
end;

constructor TCnCompDirectiveTree.Create(AStream: TStream);
begin
  inherited Create(TCnSliceNode);
  FScaner := TScaner.Create(AStream, nil, cdmNone);
  FScaner.NextToken;
end;

destructor TCnCompDirectiveTree.Destroy;
begin
  FScaner.Free;
  inherited;
end;

function TCnCompDirectiveTree.GetItems(
  AbsoluteIndex: Integer): TCnSliceNode;
begin
  Result := TCnSliceNode(inherited GetItems(AbsoluteIndex));
end;

procedure TCnCompDirectiveTree.ParseTree;
var
  CurNode: TCnSliceNode;
  TokenStr: string;
  CompDirectType: TPascalCompDirectiveType;

  function CalcPascalCompDirectiveType: TPascalCompDirectiveType;
  var
    I: Integer;
  begin
    for I := Low(ACnPasCompDirectiveTokenStr) to High(ACnPasCompDirectiveTokenStr) do
    begin
      if Pos(ACnPasCompDirectiveTokenStr[I], TokenStr) = 1 then
      begin
        Result := ACnPasCompDirectiveTypes[I];
        Exit;
      end;
    end;
    Result := cdtUnknown;
  end;

  procedure PutNormalCodeToNode;
  var
    Blank: string;
  begin
    if (CurNode.CompDirectiveStream = nil) and (CurNode.NormalCodeStream = nil) then
      CurNode.StartOffset := FScaner.SourcePos;
      
    if CurNode.NormalCodeStream = nil then
      CurNode.NormalCodeStream := TMemoryStream.Create;

    if FScaner.BlankStringLength > 0 then
    begin
      Blank := FScaner.BlankString;
      CurNode.NormalCodeStream.Write((PChar(Blank))^, FScaner.BlankStringLength * SizeOf(Char));
    end;
    CurNode.NormalCodeStream.Write(FScaner.TokenPtr^, FScaner.TokenStringLength * SizeOf(Char));
  end;

  procedure PutBlankToNode;
  var
    Blank: string;
  begin
    if FScaner.BlankStringLength > 0 then
    begin
      CurNode.EndBlankLength := FScaner.BlankStringLength;
      Blank := FScaner.BlankString;
      if CurNode.NormalCodeStream = nil then
        CurNode.NormalCodeStream := TMemoryStream.Create;
      CurNode.NormalCodeStream.Write((PChar(Blank))^, FScaner.BlankStringLength * SizeOf(Char));
    end;
  end;

  procedure PutCompDirectiveToNode;
  begin
    if CurNode.CompDirectiveStream = nil then
    begin
      CurNode.CompDirectiveStream := TMemoryStream.Create;
      CurNode.StartOffset := FScaner.SourcePos;
    end;
    // ֮ǰ�Ŀհ���س��� PutBlankToNode д����һ��ĩβ����֤�ڵ��� CompDirective ��ͷ
    CurNode.CompDirectiveStream.Write(FScaner.TokenPtr^, FScaner.TokenStringLength * SizeOf(Char));
  end;

begin
  Clear;
  CurNode := nil;
  if FScaner.Token <> tokEOF then
    CurNode := TCnSliceNode(AddChildFirst(Root));

  while FScaner.Token <> tokEOF do
  begin
    if FScaner.Token = tokCompDirective then
    begin
      TokenStr := UpperCase(FScaner.TokenString);
      CompDirectType := CalcPascalCompDirectiveType;

      case CompDirectType of
        cdtIf, cdtIfDef, cdtIfNDef:
          begin
            // ��һ�㲢�ѱ�����ָ������ȥ
            PutBlankToNode;
            CurNode := TCnSliceNode(AddChild(CurNode));
            CurNode.CompDirectivtType := CompDirectType;
            PutCompDirectiveToNode;
          end;
        cdtElse:
          begin
            // ͬ�����ɸ��µĲ��ѱ�����ָ������ȥ
            PutBlankToNode;
            CurNode := TCnSliceNode(AddChild(CurNode.Parent));
            CurNode.CompDirectivtType := CompDirectType;
            PutCompDirectiveToNode;
          end;
        cdtIfEnd, cdtEndIf:
          begin
            // ��һ�㲢�ѱ�����ָ������ȥ
            if CurNode.Parent <> nil then
            begin
              PutBlankToNode;
              CurNode := TCnSliceNode(Add(CurNode.Parent));
              CurNode.CompDirectivtType := CompDirectType;
              PutCompDirectiveToNode;
            end;
          end;
      else
        // As other token
        PutNormalCodeToNode;
      end;
    end
    else
      PutNormalCodeToNode;

    FScaner.NextToken;
  end;
  SyncTexts;
end;

procedure TCnCompDirectiveTree.PruneDuplicated;
begin
  OnWidthFirstTravelLeaf := WidthFirstTravelSlice;
  WidthFirstTravel;
end;

function TCnCompDirectiveTree.ReachNode(EndNode: TCnSliceNode): string;
var
  I: Integer;
  Node: TCnSliceNode;
begin
  Result := '';
  if EndNode = nil then
    Exit;

  if Count <= 1 then // Only root��no content
    Exit;

  ClearFlags;
  Node := EndNode;
  while Node <> nil do
  begin
    Node.KeepFlag := True;
    Node.Processed := False;
    Node := TCnSliceNode(Node.Parent);
  end;

  PruneDuplicated;
  for I := 0 to Count - 1 do
  begin
    if Items[I].KeepFlag then
    begin
      if Items[I] = EndNode then
        EndNode.ReachingStart := Length(Result); // ��¼�˷�Ƭ��ֱ��Դ���е���ʼλ��
      Result := Result + Items[I].Text;
    end;
  end;
end;

procedure TCnCompDirectiveTree.SearchMultiNodes(Results: TList);
var
  I, J, Cnt: Integer;
  Node, Node2: TCnSliceNode;
begin
  if Results = nil then
    Exit;
  Results.Clear;

  if Count <= 1 then // Only root��no content
    Exit;

  for I := 1 to Count - 1 do
  begin
    Node := Items[I];
    if Node.Count > 1 then
    begin
      Cnt := Node.Count;
      // �ڲ��κ�һ�� ENDIF/IFEND �����������ڲ�Ƕ�׿���˳�����
      // ����� ENDIF/IFEND�����������⣬������һ
      for J := 0 to Node.Count - 1 do
      begin
        Node2 := TCnSliceNode(Node.Items[J]);
        if Node2.CompDirectivtType in [cdtEndIf, cdtIfEnd] then
          Dec(Cnt);
      end;

      if Cnt > 1 then // ȥ���ڲ��˳��� ENDIF/IFEND �����������㹻�������¼�
      begin
        for J := 0 to Node.Count - 1 do
        begin
          Node2 := TCnSliceNode(Node.Items[J]);
          if not (Node2.CompDirectivtType in [cdtEndIf, cdtIfEnd]) then
            Results.Add(Node2);
        end;
      end;
    end;
  end;
end;

procedure TCnCompDirectiveTree.SyncTexts;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Text := Items[I].BuildString;
end;

procedure TCnCompDirectiveTree.WidthFirstTravelSlice(Sender: TObject);
var
  Node, Node2: TCnSliceNode;
  I, Cnt, KeepIdx: Integer;
  HasKeep: Boolean;

  procedure RecursiveSetKeepFlag(ANode: TCnSliceNode; Value: Boolean);
  var
    I: Integer;
  begin
    ANode.KeepFlag := Value;
    for I := 0 to ANode.Count - 1 do
      RecursiveSetKeepFlag(ANode.Items[I], Value);
  end;

  procedure RecursiveSetProcessed(ANode: TCnSliceNode; Value: Boolean);
  var
    I: Integer;
  begin
    ANode.Processed := Value;
    for I := 0 to ANode.Count - 1 do
      RecursiveSetProcessed(ANode.Items[I], Value);
  end;

begin
  // ��֦����
  Node := TCnSliceNode(Sender);
  if Node.Processed then  // Root �ô����������ֵ�һ�����
    Exit;

  if Node.Count > 1 then
  begin
    Cnt := Node.Count;
    // ���ֱ���ӽڵ��� ENDIF/IFEND�����������⣬������һ
    for I := 0 to Node.Count - 1 do
    begin
      Node2 := TCnSliceNode(Node.Items[I]);
      if Node2.CompDirectivtType in [cdtEndIf, cdtIfEnd] then
        Dec(Cnt);
    end;

    if Cnt > 1 then // ȥ���ڲ��˳��� ENDIF/IFEND ��������������2����ʼ��֦
    begin
      HasKeep := False;
      KeepIdx := -1;
      for I := 0 to Node.Count - 1 do
      begin
        if Node.Items[I].KeepFlag then
        begin
          HasKeep := True;
          KeepIdx := I;
          Break;
        end;
      end;

      if not HasKeep then
        KeepIdx := 0;

      // �����и�������Ϊ Keep �ľ��� KeepIdx ��ָ�ģ������õ�һ��
      // ���������� KeepFlag �Ľڵ㣬���ӻ����ٴδ������Ա��� Processed ��Ϊ False
      for I := 0 to Node.Count - 1 do
      begin
        if I = KeepIdx then
        begin
          Node.Items[I].KeepFlag := True;
          Node.Items[I].Processed := False;
        end
        else if (I = KeepIdx + 1) and (Node.Items[I].CompDirectivtType in
          [cdtIfEnd, cdtEndIf]) then
        begin
          Node.Items[I].KeepFlag := True;
          Node.Items[I].Processed := False;
        end
        else
        begin
          RecursiveSetKeepFlag(Node.Items[I], False);
          RecursiveSetProcessed(Node.Items[I], True);
          // �ݹ����������ԣ��������������ӽڵ�
          // ���� KeepFlag ��Ϊ False�ģ�����ȫ������
        end;
      end;
    end
    else // ����ӽڵ���������һ����ֻ��һ����Ч�ģ���ȡ����������������
    begin
      for I := 0 to Node.Count - 1 do
      begin
        Node.Items[I].KeepFlag := True;
        Node.Items[I].Processed := False;
      end;
    end;
  end
  else if Node.Count = 1 then // ����ӽڵ���������һ����ȡ����������������
  begin
    Node.Items[0].KeepFlag := True;
    Node.Items[0].Processed := False;
  end;
  Node.Processed := True; // ���ڵ㴦�����
end;

end.
