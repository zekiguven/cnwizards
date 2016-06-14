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

unit CnParseConsts;
{* |<PRE>
================================================================================
* ������ƣ�CnPack �����ʽ��ר��
* ��Ԫ���ƣ������ڴ�����ʾ��Դ
* ��Ԫ���ߣ�CnPack������
* ��    ע�������ڴ�����ʾ��Դ
* ����ƽ̨��Win2003 + Delphi 5.0
* ���ݲ��ԣ�not test yet
* �� �� ����should be work
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��
*   2003-12-16 V0.1
        ������
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  CnFormatterIntf;

const
  SIdentifierExpected: PAnsiChar = 'Identifier expected';
  SStringExpected: PAnsiChar = 'String expected';
  SNumberExpected: PAnsiChar = 'Number expected';
  SCharExpected: PAnsiChar = '''''%d'''' expected';
  SSymbolExpected: PAnsiChar = '%s expected, but "%s" found';
  SParseError: PAnsiChar = '%s on line %d:%d';
  SInvalidBinary: PAnsiChar = 'Invalid binary value';
  SInvalidString: PAnsiChar = 'Invalid string constant';
  SInvalidBookmark: PAnsiChar = 'Invalid Bookmark';
  SLineTooLong: PAnsiChar = 'Line too long';
  SEndOfCommentExpected: PAnsiChar = 'Comment end ''}'' or ''*)'' expected';
  SNotSurpport: PAnsiChar = 'Not Surport %s now';

  SErrorDirective: PAnsiChar = 'Error Directive';
  SMethodHeadingExpected: PAnsiChar = 'Method head expected';
  SStructTypeExpected: PAnsiChar = 'Struct type expected';
  STypedConstantExpected: PAnsiChar = 'Typed constant expected';
  SEqualColonExpected: PAnsiChar = ' = or : expected';
  SDeclSectionExpected: PAnsiChar = 'Declare section expected';
  SProcFuncExpected: PAnsiChar = 'Procedure or function expected';
  SUnknownGoal: PAnsiChar = 'Unknown file type';
  SErrorInterface: PAnsiChar = 'Interface part error';
  SErrorStatement: PAnsiChar = 'Statement part error';

  SUnknownErrorStr: PAnsiChar = 'Unknown Error String';

type
  PPAnsiChar = ^PAnsiChar;

  TCnPascalErrorRec = packed record
    ErrorCode: Integer;
    ErrorMessage: string;
    SourceLine: Integer; // ����ʱ��ǰ�У�1 ��ʼ
    SourceCol: Integer;  // ����ʱ��ǰ�У�1 ��ʼ
    SourcePos: Integer;  // ����ʱ��ǰ��ƫ��
    CurrentToken: string;
  end;

var
  ErrorStrings: array[CN_ERRCODE_START..CN_ERRCODE_END] of PPAnsiChar =
    (
      @SIdentifierExpected, @SStringExpected, @SNumberExpected, @SCharExpected,
      @SSymbolExpected, @SParseError, @SInvalidBinary, @SInvalidString,
      @SInvalidBookmark, @SLineTooLong, @SEndOfCommentExpected, @SNotSurpport,
      @SErrorDirective, @SMethodHeadingExpected, @SStructTypeExpected,
      @STypedConstantExpected, @SEqualColonExpected, @SDeclSectionExpected,
      @SProcFuncExpected, @SUnknownGoal, @SErrorInterface, @SErrorStatement
    );

  // ��ȫ�����ô�����Ϣ
  PascalErrorRec: TCnPascalErrorRec = (
    ErrorCode: 0;
    ErrorMessage: '';
    SourceLine: 0;
    SourceCol: 0;
    SourcePos: 0;
    CurrentToken: '';
  );

procedure ClearPascalError;

function RetrieveFormatErrorString(const Ident: Integer): PAnsiChar;

implementation

procedure ClearPascalError;
begin
  with PascalErrorRec do
  begin
    ErrorCode := 0;
    ErrorMessage := '';
    SourceLine := 0;
    SourceCol := 0;
    SourcePos := 0;
    CurrentToken := '';
  end;
end;

function RetrieveFormatErrorString(const Ident: Integer): PAnsiChar;
begin
  if Ident in [Low(ErrorStrings)..High(ErrorStrings)] then
    Result := ErrorStrings[Ident]^
  else
    Result := SUnknownErrorStr;
end;

end.

