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

unit CnGroupReplace;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ����滻��Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��TCnGroupReplacements���ܹ����������̳�ʵ�ִӲ�ͬ;������
*           TCnGroupReplacement������� Item������һ�����滻����
*           TCnReplacements�������һ�����ԣ�����һ���е������滻��
*           TCnReplacement������� Item������һ�������滻����
* ����ƽ̨��PWinXP SP2 + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2005.08.09
*               �� CnSrcEditorGroupReplace ���Ƴ�
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes, CnClasses, CnCommon;

type
  TCnReplacement = class(TCnAssignableCollectionItem)
  private
    FSource: string;
    FDest: string;
    FWholeWord: Boolean;
    FIgnoreCase: Boolean;
  public
    constructor Create(Collection: TCollection); override;
{$IFDEF UNICODE}
    function FindInTextW(Text: string): Integer;
{$ENDIF}
    function FindInText(Text: AnsiString): Integer;
  published
    property Source: string read FSource write FSource;
    property Dest: string read FDest write FDest;
    property IgnoreCase: Boolean read FIgnoreCase write FIgnoreCase;
    property WholeWord: Boolean read FWholeWord write FWholeWord;
  end;

  TCnReplacements = class(TCollection)
  private
    function GetItem(Index: Integer): TCnReplacement;
    procedure SetItem(Index: Integer; const Value: TCnReplacement);
  public
    constructor Create;
    function Add: TCnReplacement;
    property Items[Index: Integer]: TCnReplacement read GetItem write SetItem; default;
  end;

  TCnGroupReplacement = class(TCnAssignableCollectionItem)
  private
    FCaption: string;
    FShortCut: TShortCut;
    FItems: TCnReplacements;
    procedure SetItems(const Value: TCnReplacements);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    function Execute(Text: string): string;
  published
    property Caption: string read FCaption write FCaption;
    property ShortCut: TShortCut read FShortCut write FShortCut;
    property Items: TCnReplacements read FItems write SetItems;
  end;

  TCnGroupReplacements = class(TCollection)
  private
    function GetItem(Index: Integer): TCnGroupReplacement;
    procedure SetItem(Index: Integer; const Value: TCnGroupReplacement);
  public
    constructor Create;
    function Add: TCnGroupReplacement;
    property Items[Index: Integer]: TCnGroupReplacement read GetItem write SetItem;
      default;
  end;

implementation

{ TCnReplacement }

constructor TCnReplacement.Create(Collection: TCollection);
begin
  inherited;
  FIgnoreCase := True;
  FWholeWord := True;
end;

function TCnReplacement.FindInText(Text: AnsiString): Integer;
var
  ASrc: AnsiString;
  PSub, PText: PAnsiChar;
  L: Integer;
begin
  if FIgnoreCase then
  begin
    ASrc := AnsiString(UpperCase(Source));
    Text := AnsiString(UpperCase(string(Text)));
  end
  else
    ASrc := AnsiString(Source);

  Result := -1;
  if (Text = '') or (ASrc = '') then Exit;

  L := Length(ASrc);
  PText := PAnsiChar(Text);
  PSub := PText;
  repeat
    PSub := AnsiStrPos(PSub, PAnsiChar(ASrc)); // Must using AnsiString in Unicode IDE
    if PSub <> nil then
    begin
      if not FWholeWord then
      begin
        Result := Integer(PSub) - Integer(PText);
        Exit;
      end
      else
      begin
        if (Cardinal(PSub) > Cardinal(PText)) and IsValidIdentChar(Char(PSub[-1])) or
          IsValidIdentChar(Char(PSub[L])) then
        begin
          PSub := PAnsiChar(Integer(PSub) + L);
        end
        else
        begin
          Result := Integer(PSub) - Integer(PText);
          Exit;
        end;
      end;
    end;
  until (PSub = nil) or (PSub^ = #0);
end;

{$IFDEF UNICODE}

function TCnReplacement.FindInTextW(Text: string): Integer;
var
  ASrc: string;
  PSub, PText: PChar;
  L: Integer;
begin
  if FIgnoreCase then
  begin
    ASrc := UpperCase(Source);
    Text := UpperCase(Text);
  end
  else
    ASrc := Source;

  Result := -1;
  if (Text = '') or (ASrc = '') then Exit;

  L := Length(ASrc);
  PText := PChar(Text);
  PSub := PText;
  repeat
    PSub := StrPos(PSub, PChar(ASrc)); // Must using AnsiString in Unicode IDE
    if PSub <> nil then
    begin
      if not FWholeWord then
      begin
        Result := Integer(PSub) - Integer(PText);
        Exit;
      end
      else
      begin
        if (Cardinal(PSub) > Cardinal(PText)) and IsValidIdentChar(Char(PSub[-1])) or
          IsValidIdentChar(Char(PSub[L])) then
        begin
          PSub := PChar(Integer(PSub) + L);
        end
        else
        begin
          Result := Integer(PSub) - Integer(PText);
          Exit;
        end;
      end;
    end;
  until (PSub = nil) or (PSub^ = #0);
end;

{$ENDIF}

{ TCnReplacements }

function TCnReplacements.Add: TCnReplacement;
begin
  Result := TCnReplacement(inherited Add);
end;

constructor TCnReplacements.Create;
begin
  inherited Create(TCnReplacement);
end;

function TCnReplacements.GetItem(Index: Integer): TCnReplacement;
begin
  Result := TCnReplacement(inherited Items[Index]);
end;

procedure TCnReplacements.SetItem(Index: Integer;
  const Value: TCnReplacement);
begin
  inherited Items[Index] := Value;
end;

{ TCnGroupReplacement }

constructor TCnGroupReplacement.Create(Collection: TCollection);
begin
  inherited;
  FItems := TCnReplacements.Create;
end;

destructor TCnGroupReplacement.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TCnGroupReplacement.Execute(Text: string): string;
var
  i, APos, MinPos, ItemIdx: Integer;
  AnsiText, AnsiResult: {$IFDEF UNICODE} string {$ELSE} AnsiString {$ENDIF};
begin
  Result := '';
  if Text = '' then Exit;

{$IFDEF UNICODE}
  AnsiText := Text;
  AnsiResult := '';

  repeat
    MinPos := MaxInt;
    ItemIdx := -1;
    for i := 0 to Items.Count - 1 do
    begin
      APos := Items[i].FindInTextW(AnsiText);
      if (APos >= 0) and (APos < MinPos) then
      begin
        ItemIdx := i;
        MinPos := APos;
        if MinPos = 0 then
          Break;
      end;
    end;

    if (ItemIdx >= 0) then
    begin
      AnsiResult := AnsiResult + Copy(AnsiText, 1, MinPos) + Items[ItemIdx].Dest;
      Delete(AnsiText, 1, MinPos + Length(Items[ItemIdx].Source));
    end;
  until (ItemIdx = -1) or (AnsiText = '');
  Result := AnsiResult + AnsiText;

{$ELSE}
  AnsiText := AnsiString(Text);
  AnsiResult := '';

  repeat
    MinPos := MaxInt;
    ItemIdx := -1;
    for i := 0 to Items.Count - 1 do
    begin
      APos := Items[i].FindInText(AnsiText);
      if (APos >= 0) and (APos < MinPos) then
      begin
        ItemIdx := i;
        MinPos := APos;
        if MinPos = 0 then
          Break;
      end;
    end;

    if (ItemIdx >= 0) then
    begin
      AnsiResult := AnsiResult + Copy(AnsiText, 1, MinPos) + AnsiString(Items[ItemIdx].Dest);
      Delete(AnsiText, 1, MinPos + Length(Items[ItemIdx].Source));
    end;
  until (ItemIdx = -1) or (AnsiText = '');
  Result := string(AnsiResult + AnsiText);
{$ENDIF}
end;

procedure TCnGroupReplacement.SetItems(const Value: TCnReplacements);
begin
  FItems.Assign(Value);
end;

{ TCnGroupReplacements }

function TCnGroupReplacements.Add: TCnGroupReplacement;
begin
  Result := TCnGroupReplacement(inherited Add);
end;

constructor TCnGroupReplacements.Create;
begin
  inherited Create(TCnGroupReplacement);
end;

function TCnGroupReplacements.GetItem(Index: Integer): TCnGroupReplacement;
begin
  Result := TCnGroupReplacement(inherited Items[Index]);
end;

procedure TCnGroupReplacements.SetItem(Index: Integer; const Value:
  TCnGroupReplacement);
begin
  inherited Items[Index] := Value;
end;

end.
