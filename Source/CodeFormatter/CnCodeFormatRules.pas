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

unit CnCodeFormatRules;
{* |<PRE>
================================================================================
* ������ƣ�CnPack �����ʽ��ר��
* ��Ԫ���ƣ������ʽ������
* ��Ԫ���ߣ�CnPack������
* ��    ע���õ�Ԫʵ�ִ����ʽ������
* ����ƽ̨��Win2003 + Delphi 5.0
* ���ݲ��ԣ�not test yet
* �� �� ����not test hell
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2003.12.16 V0.1
*               ������Ŀǰ���� �����ո�����������ǰ��ո������ؼ��ִ�Сд �����á�
                ������δʵ�֡�
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

type
  TCnCodeStyle = (fsNone);

  TCnCodeStyles = set of TCnCodeStyle;

  TKeywordStyle = (ksLowerCaseKeyword, ksUpperCaseKeyword, ksPascalKeyword, ksNoChange);

  TBeginStyle = (bsNextLine, bsSameLine);

  TCodeWrapMode = (cwmNone, cwmSimple, cwmAdvanced);
  {* ���뻻�е����ã����Զ����С��򵥵ĳ����ͻ��У��߼��ĳ������˲Ŵ��ٵĵط�����}

  TTypeIDStyle = (tisUpperFirst, tisNoChange); // ���ͱ�ʶ���Ĵ���ʽ������ĸ��д�򲻱�

  TCompDirectiveMode = (cdmAsComment, cdmOnlyFirst, cdmNone); // None ��ʾ�Ӹ����洦��

  TCnPascalCodeFormatRule = record
    ContinueAfterError: Boolean;
    CodeStyle: TCnCodeStyles;

    CompDirectiveMode: TCompDirectiveMode;  // �������
    KeywordStyle: TKeywordStyle;
    BeginStyle: TBeginStyle;
    CodeWrapMode: TCodeWrapMode;
    TypeIDStyle: TTypeIDStyle;    // �����޷������ʶ���ڵķִʣ����岻���ݲ����⿪��
    TabSpaceCount: Byte;
    SpaceBeforeOperator: Byte;
    SpaceAfterOperator: Byte;
    SpaceBeforeASM: Byte;
    SpaceTabASMKeyword: Byte;
    WrapWidth: Integer;
    WrapNewLineWidth: Integer;
    UsesUnitSingleLine: Boolean;
    UseIgnoreArea: Boolean;
  end;

const
  CnPascalCodeForVCLRule: TCnPascalCodeFormatRule =
  (
    ContinueAfterError: False;
    CodeStyle: [];

    CompDirectiveMode: cdmAsComment;
    KeywordStyle: ksLowerCaseKeyword;
    BeginStyle: bsNextLine;
    CodeWrapMode: cwmNone;
    TypeIDStyle: tisNoChange;
    TabSpaceCount: 2;
    SpaceBeforeOperator: 1;
    SpaceAfterOperator: 1;
    SpaceBeforeASM: 8;
    SpaceTabASMKeyword: 8;
    WrapWidth: 80;
    WrapNewLineWidth: 90;
    UsesUnitSingleLine: False;
    UseIgnoreArea: True;
  );

var
  CnPascalCodeForRule: TCnPascalCodeFormatRule;

implementation

initialization
  // Default Setting
  CnPascalCodeForRule := CnPascalCodeForVCLRule;

end.
