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

library CnFormatLibW;

uses
  SysUtils,
  Classes,
  CnFormatterIntf in '..\..\Source\CodeFormatter\CnFormatterIntf.pas',
  CnCodeFormatterImplW in 'CnCodeFormatterImplW.pas',
  CnCodeFormatter in '..\..\Source\CodeFormatter\CnCodeFormatter.pas',
  CnCodeFormatRules in '..\..\Source\CodeFormatter\CnCodeFormatRules.pas',
  CnCodeGenerators in '..\..\Source\CodeFormatter\CnParser\CnCodeGenerators.pas',
  CnParseConsts in '..\..\Source\CodeFormatter\CnParser\CnParseConsts.pas',
  CnPascalGrammar in '..\..\Source\CodeFormatter\CnParser\CnPascalGrammar.pas',
  CnScaners in '..\..\Source\CodeFormatter\CnParser\CnScaners.pas',
  CnTokens in '..\..\Source\CodeFormatter\CnParser\CnTokens.pas';

{$R *.RES}

begin
end.
