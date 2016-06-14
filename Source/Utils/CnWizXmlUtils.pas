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

unit CnWizXmlUtils;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�Xml Parser Helper ��Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע��
* ����ƽ̨��Win7 SP1 + Delphi 2010
* ���ݲ��ԣ�
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id: CnWizXmlUtils.pas 1146 2012-10-24 06:25:41Z liuxiaoshanzhashu@gmail.com $
* �޸ļ�¼��2013.02.17
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes,
{$IFDEF CN_USE_MSXML}
  ActiveX, ComObj, msxml;
{$ELSE}
  OmniXML, OmniXMLUtils;
{$ENDIF}

{$IFDEF CN_USE_MSXML}
type
  IXMLNode = IXMLDOMNode;
  IXMLDocument = IXMLDOMDocument;

function XMLStrToInt(nodeValue: WideString; var value: integer): boolean;
function XMLStrToIntDef(nodeValue: WideString; defaultValue: integer): integer;
function GetNodeAttr(parentNode: IXMLNode; attrName: string;
  var value: WideString): boolean;
function GetNodeAttrStr(parentNode: IXMLNode; attrName: string;
  defaultValue: WideString): WideString;
function GetTextChild(node: IXMLNode): IXMLNode;
function GetNodeText(parentNode: IXMLNode; nodeTag: string;
  var nodeText: WideString): boolean;
function GetNodeTextInt(parentNode: IXMLNode; nodeTag: string;
  defaultValue: integer): integer;
function GetNodeTextStr(parentNode: IXMLNode; nodeTag: string;
  defaultValue: WideString): WideString;
function FindNode(parentNode: IXMLNode; matchesName: string): IXMLNode;
function CreateXMLDoc: IXMLDOMDocument;
{$ENDIF}

implementation

{$IFDEF CN_USE_MSXML}
function XMLStrToInt(nodeValue: WideString; var value: integer): boolean;
begin
  try
    value := StrToInt(nodeValue);
    Result := True;
  except
    on EConvertError do
      Result := False;
  end;
end;

function XMLStrToIntDef(nodeValue: WideString; defaultValue: integer): integer;
begin
  if not XMLStrToInt(nodeValue,Result) then
    Result := defaultValue;
end;

function GetNodeAttr(parentNode: IXMLNode; attrName: string;
  var value: WideString): boolean;
var
  attrNode: IXMLNode;
begin
  attrNode := parentNode.Attributes.GetNamedItem(attrName);
  if not assigned(attrNode) then
    Result := False
  else begin
    value := attrNode.NodeValue;
    Result := True;
  end;
end;

function GetNodeAttrStr(parentNode: IXMLNode; attrName: string;
  defaultValue: WideString): WideString;
begin
  if not GetNodeAttr(parentNode,attrName,Result) then
    Result := defaultValue
  else
    Result := Trim(Result);
end;

function GetTextChild(node: IXMLNode): IXMLNode;
var
  iText: integer;
begin
  Result := nil;
  for iText := 0 to node.ChildNodes.Length-1 do
    if node.ChildNodes.Item[iText].NodeType = NODE_TEXT then begin
      Result := node.ChildNodes.Item[iText];
      Break; //for
    end;
end;

function GetNodeText(parentNode: IXMLNode; nodeTag: string;
  var nodeText: WideString): boolean;
var
  myNode: IXMLNode;
begin
  nodeText := '';
  Result := False;
  myNode := parentNode.SelectSingleNode(nodeTag);
  if assigned(myNode) then
  begin
    nodeText := myNode.text;
    Result := True;
  end;
end;

function GetNodeTextInt(parentNode: IXMLNode; nodeTag: string;
  defaultValue: integer): integer;
var
  nodeText: WideString;
begin
  if not GetNodeText(parentNode,nodeTag,nodeText) then
    Result := defaultValue
  else
    Result := XMLStrToIntDef(nodeText,defaultValue);
end;

function GetNodeTextStr(parentNode: IXMLNode; nodeTag: string;
  defaultValue: WideString): WideString;
begin
  if not GetNodeText(parentNode,nodeTag,Result) then
    Result := defaultValue
  else
    Result := Trim(Result);
end;

function FindNode(parentNode: IXMLNode; matchesName: string): IXMLNode;
var
  i: Integer;
begin
  for i := 0 to parentNode.childNodes.length - 1 do
    if SameText(parentNode.childNodes.item[i].nodeName, matchesName) then
    begin
      Result := parentNode.childNodes.item[i];
      Exit;
    end;
  Result := nil;
end;

function CreateXMLDoc: IXMLDOMDocument;
begin
  try
    Result := CreateOleObject('Microsoft.XMLDOM') as IXMLDomDocument;
  except
    ;
  end;
end;

{$ENDIF}

end.
