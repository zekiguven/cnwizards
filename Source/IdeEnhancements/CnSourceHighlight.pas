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

unit CnSourceHighlight;
{ |<PRE>
================================================================================
* ������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�����༭����ʾ��չ��Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
*           Dragon P.C. (dragonpc@21cn.com)
*           LiuXiao
*           Shenloqi
* ��    ע��BDS �� UTF8 �������������ط���Ҫ������
*                              D7�����¡�  D2009���µ�BDS��D2009��
*           LineText ���ԣ�    AnsiString��UTF8��          UncodeString
*           EditView.CusorPos��Ansi�ֽڡ�  UTF8���ֽ�Col�� ת��Ansi���ַ�Col
*           GetAttributeAtPos��Ansi�ֽڡ�  UTF8���ֽ�Col�� UTF8���ֽ�Col
*               ��� D2009 �´���ʱ����Ҫ���⽫��õ� UnicodeString �� LineText
*               ת�� UTF8 ����Ӧ��ص� CursorPos �� GetAttributeAtPos
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ���֧�ֱ��ػ�����ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2016.05.22
*               ������Ӣ�Ļ����� Unicode IDE �ڵĿ��ֽ��ַ�ת���� Ansi ���������
*               ȫ�Ľ���ʱ������ͨ���ֽ��ַ��滻�ɵ����������ո񣬴Ӷ�����ֱ��
*               ת��ʱ������ʺŴ��浼�¼���ƫ�
*           2016.02.05
*               ���� Unicode IDE ��������Թ��ܶ��ڰ������ֵ��п��ܳ���λ��ƫ�������
*           2014.12.25
*               ���Ӹ����������Ե���������ָ���
*           2014.09.17
*               �Ż�������ǰ��ʶ���Ļ������ܣ���лvitaliyg2
*           2013.07.08
*               ����������̿��Ʊ�ʶ�������Ĺ���
*           2012.12.24
*               �޸� jtdd ����Ļ��ƿ��зָ������۵�״̬�¿��ܳ��������
*           2011.09.04
*               ���� white_nigger ���޲�������޸� CloseAll ʱ���������
*           2010.10.04
*               2009 ���� Unicode �����£����� Token �� Col ���� ConvertPos ����
*               ת��ʱ���Ժ����Լ���λ��˫�ֽ��ַ��ȵ��жϻ��д�����˲���
*               CharIndex + 1 ʱ���ֲ��ܴ���� Tab ����
*               �ٶȿ�� GetTextAtLine ȡ�õ��ı��ǽ� Tab ��չ�ɿո�ģ������޷�
*               �����Ƿ���� Tab ����ֻ���� UseTabChar ѡ��Ϊ True ʱ��ʹ�ô�ͳ��
*               D2009 ���ϻ��λ�ļ��㷽����
*           2009.03.28
*               ������ƴ�Сдƥ��Ļ��ƣ��� Pascal �ļ��������ִ�Сд
*           2009.01.06
*               ���������ǰ�б����Ĺ��ܡ�
*               ����˼�룺�ҽ� Editor::TCustomEditorControl::SetForeAndBackColor
*                         �жϲ����ñ���ɫ���ж��� BeforePaint �Լ� AfterPaint
*                         �н�� EditorChanged ����λ��������Ҫ�жϺܶ�ط���
*               Ŀǰ���⣺�е���
*           2008.09.09
*               ���������ǰ����µı�ʶ���Ĺ���
*           2008.06.25
*               ��������ˢ�����⣬if then ����� else ����ԣ��������ֺ����ַ���
*               �����ȳ��ִ�λ������
*           2008.06.22
*               ���Ӷ� BDS �Ĵ����۵���֧��
*           2008.06.17
*               ���Ӷ� BDS ��֧��
*           2008.06.08
*               ���ӻ���ƥ��Ĺ���
*           2008.03.11
*               ����EditControl�ر�ʱ֪ͨ���ڲ�δ�ͷŸ������������
*           2005.07.25
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}

uses
  Windows, Messages, Classes, Graphics, SysUtils, Controls, Menus, Forms,
  ToolsAPI, IniFiles, Contnrs, ExtCtrls, TypInfo, Math, mPasLex, 
  {$IFDEF COMPILER6_UP}Variants, {$ENDIF}
  CnWizClasses, CnEditControlWrapper, CnWizNotifier, CnIni, CnWizUtils, CnCommon,
  CnConsts, CnWizConsts, CnWizIdeUtils, CnWizShortCut, CnPasCodeParser,
  CnGraphUtils, CnFastList, CnCppCodeParser, mwBCBTokenList;

const
  HighLightDefColors: array[-1..5] of TColor = ($00000099, $000000FF, $000099FF,
    $0033CC00, $0099CC00, $00FF6600, $00CC00CC);
  csDefCurTokenColorBg = $0080DDFF;
  csDefCurTokenColorFg = clBlack;
  csDefCurTokenColorBd = $00226DA8;
  csDefFlowControlBg = $FFCCCC;
  csDefaultHighlightBackgroundColor = $0066FFFF;

  CN_LINE_STYLE_SMALL_DOT_STEP = 2;

  CN_LINE_STYLE_TINY_DOT_STEP = 1;
  // ÿ�������ؿռ�������

  CN_LINE_SEPARATE_FLAG = 1;

  csKeyTokens: set of TTokenKind = [
    tkIf, tkThen, tkElse,
    tkRecord, tkClass, tkInterface, tkDispInterface,
    tkFor, tkWith, tkOn, tkWhile, tkDo,
    tkAsm, tkBegin, tkEnd,
    tkTry, tkExcept, tkFinally,
    tkCase, tkOf,
    tkRepeat, tkUntil];

  csPasFlowTokenStr: array[0..3] of AnsiString =
    ('exit', 'continue', 'break', 'abort');

  csPasFlowTokenKinds: set of TTokenKind = [tkGoto, tkRaise];

  csCppFlowTokenStr: array[0..1] of AnsiString =
    ('abort', 'exit');

  csCppFlowTokenKinds: TIdentDirect = [ctkgoto, ctkreturn, ctkcontinue, ctkbreak];
  // If change here, CppCodeParser also need change.

  csPasCompDirectiveTokenStr: array[0..5] of AnsiString =
    ('{$IF ', '{$IFDEF ', '{$IFNDEF ', '{$ELSE', '{$ENDIF', '{$IFEND');

  csPasCompDirectiveTypes: array[0..5] of TCnCompDirectiveType =
    (ctIf, ctIfDef, ctIfNDef, ctElse, ctEndIf, ctIfEnd);

  csCppCompDirectiveKinds: TIdentDirect = [ctkdirif, ctkdirifdef, ctkdirifndef,
    ctkdirelif, ctkdirelse, ctkdirendif];

type
  TCnLineStyle = (lsSolid, lsDot, lsSmallDot, lsTinyDot);

  TBracketInfo = class
  {* ÿ�� EditControl ��Ӧһ���������༭���е�һ��������Ը�����Ϣ}
  private
    FTokenStr: AnsiString;
    FTokenLine: AnsiString;
    FTokenPos: TOTAEditPos;
    FTokenMatchStr: AnsiString;
    FTokenMatchLine: AnsiString;
    FTokenMatchPos: TOTAEditPos;
    FLastPos: TOTAEditPos;
    FLastMatchPos: TOTAEditPos;
    FIsMatch: Boolean;
    FControl: TControl;
  public
    constructor Create(AControl: TControl);
    property Control: TControl read FControl write FControl;
    property IsMatch: Boolean read FIsMatch write FIsMatch;
    property LastMatchPos: TOTAEditPos read FLastMatchPos write FLastMatchPos;
    property LastPos: TOTAEditPos read FLastPos write FLastPos;

    // ����£��������ŵ������ַ����������ݡ�λ����Ϣ
    property TokenStr: AnsiString read FTokenStr write FTokenStr;
    property TokenLine: AnsiString read FTokenLine write FTokenLine;
    property TokenPos: TOTAEditPos read FTokenPos write FTokenPos;

    // ��������Ե������ַ����������ݡ�λ����Ϣ
    property TokenMatchStr: AnsiString read FTokenMatchStr write FTokenMatchStr;
    property TokenMatchLine: AnsiString read FTokenMatchLine write FTokenMatchLine;
    property TokenMatchPos: TOTAEditPos read FTokenMatchPos write FTokenMatchPos;
  end;

  TBlockHighlightRange = (brAll, brMethod, brWholeBlock, brInnerBlock);

  TBlockHighlightStyle = (bsNow, bsDelay, bsHotkey);

  TBlockLineInfo = class;

  TCompDirectiveInfo = class;

  TBlockMatchInfo = class(TObject)
  {* ÿ�� EditControl ��Ӧһ���������������༭�������еĽṹ������Ϣ}
  private
    FControl: TControl;
    FModified: Boolean;
    FChanged: Boolean;
    FPasParser: TCnPasStructureParser;

    // *TokenList ���ɳ����������
    FKeyTokenList: TCnList;           // ���ɽ��������Ĺؼ��� Tokens
    FCurTokenList: TCnList;           // ���ɽ������������굱ǰ����ͬ�� Tokens
    FCurTokenListEditLine: TCnList;   // ���ɽ��������Ĺ�굱ǰ����ͬ�Ĵʵ�����
    FCurTokenListEditCol: TCnList;    // ���ɽ��������Ĺ�굱ǰ����ͬ�Ĵʵ�����
    FFlowTokenList: TCnList;          // ���ɽ������������̿��Ʊ�ʶ���� Tokens
    FCompDirectiveTokenList: TCnList; // ���ɽ��������ı���ָ�� Tokens

    // *LineList ���ɿ��ٷ��ʽ��
    FKeyLineList: TCnObjectList;      // ���ɰ��з�ʽ�洢�Ŀ��ٷ��ʵĹؼ�������
    FIdLineList: TCnObjectList;       // ���ɰ��з�ʽ�洢�Ŀ��ٷ��ʵı�ʶ������
    FFlowLineList: TCnObjectList;     // ���ɰ��з�ʽ�洢�Ŀ��ٷ��ʵ����̿��Ʒ�����
    FSeparateLineList: TCnList;       // �����з�ʽ�洢�Ŀ��ٷ��ʵķֽ������Ϣ
    FCompDirectiveLineList: TCnObjectList;  // �����з�ʽ�洢�Ŀ��ٷ��ʵı���ָ����Ϣ

    FLineInfo: TBlockLineInfo;              // ���ɽ��������� Tokens �����Ϣ
    FCompDirectiveInfo: TCompDirectiveInfo; // ���ɽ��������ı���ָ�������Ϣ

    FStack: TStack;  // �����ؼ������ʱ�Լ�����C�������ʱ�Լ�C����ָ�����ʱ�Լ�Pascal����ָ�����ʱʹ��
    FIfThenStack: TStack;
    FCurrentToken: TCnPasToken;
    FCurMethodStartToken, FCurMethodCloseToken: TCnPasToken;
    FCurrentTokenName: AnsiString;
    FCurrentBlockSearched: Boolean;
    FCaseSensitive: Boolean;
    FIsCppSource: Boolean;
    FCppParser: TCnCppStructureParser;

    function GetKeyCount: Integer;
    function GetKeyTokens(Index: Integer): TCnPasToken;
    function GetCurTokens(Index: Integer): TCnPasToken;
    function GetLineCount: Integer;
    function GetIdLineCount: Integer;
    function GetLines(LineNum: Integer): TCnList;
    function GetCurTokenCount: Integer;
    function GetIdLines(LineNum: Integer): TCnList;
    function GetFlowTokenCount: Integer;
    function GetFlowTokens(LineNum: Integer): TCnPasToken;
    function GetFlowLineCount: Integer;
    function GetFlowLines(LineNum: Integer): TCnList;
    function GetCompDirectiveTokenCount: Integer;
    function GetCompDirectiveTokens(LineNum: Integer): TCnPasToken;
    function GetCompDirectiveLineCount: Integer;
    function GetCompDirectiveLines(LineNum: Integer): TCnList;
  public
    constructor Create(AControl: TControl);
    destructor Destroy; override;

    function CheckBlockMatch(BlockHighlightRange: TBlockHighlightRange): Boolean; // �ҳ��ؼ��֣������������ĸ�����
    procedure UpdateSeparateLineList;  // �ҳ�����
    procedure UpdateFlowTokenList;     // �ҳ����̿��Ʊ�ʶ��
    procedure UpdateCurTokenList;      // �ҳ��͹������ͬ�ı�ʶ��
    procedure UpdateCompDirectiveList; // �ҳ�����ָ��

    procedure CheckLineMatch(View: IOTAEditView; IgnoreClass: Boolean);
    procedure CheckCompDirectiveMatch(View: IOTAEditView; IgnoreClass: Boolean);
    procedure ConvertLineList;          // ���������Ĺؼ����뵱ǰ��ʶ��ת���ɰ��з�ʽ���ٷ��ʵ�
    procedure ConvertIdLineList;        // ���������ı�ʶ��ת���ɰ��з�ʽ���ٷ��ʵ�
    procedure ConvertFlowLineList;      // �������������̿��Ʊ�ʶ��ת���ɰ��з�ʽ���ٷ��ʵ�
    procedure ConvertCompDirectiveLineList; // ���������ı���ָ��ת���ɰ��з�ʽ���ٷ��ʵ�
    procedure Clear;
    procedure AddToKeyList(AToken: TCnPasToken);
    procedure AddToCurrList(AToken: TCnPasToken);
    procedure AddToFlowList(AToken: TCnPasToken);
    procedure AddToCompDirectiveList(AToken: TCnPasToken);

    property KeyTokens[Index: Integer]: TCnPasToken read GetKeyTokens;
    {* �����ؼ����б�}
    property KeyCount: Integer read GetKeyCount;
    {* �����ؼ����б���Ŀ}
    property CurTokens[Index: Integer]: TCnPasToken read GetCurTokens;
    {* �͵�ǰ��ʶ����ͬ�ı�ʶ���б�}
    property CurTokenCount: Integer read GetCurTokenCount;
    {* �͵�ǰ��ʶ����ͬ�ı�ʶ���б���Ŀ}
    property FlowTokens[Index: Integer]: TCnPasToken read GetFlowTokens;
    {* ���̿��Ƶı�ʶ���б�}
    property FlowTokenCount: Integer read GetFlowTokenCount;
    {* ���̿��Ƶı�ʶ���б���Ŀ}
    property CompDirectiveTokens[Index: Integer]: TCnPasToken read GetCompDirectiveTokens;
    {* ����ָ��ı�ʶ���б�}
    property CompDirectiveTokenCount: Integer read GetCompDirectiveTokenCount;
    {* ����ָ��ı�ʶ���б���Ŀ}

    property LineCount: Integer read GetLineCount;
    property IdLineCount: Integer read GetIdLineCount;
    property FlowLineCount: Integer read GetFlowLineCount;
    property CompDirectiveLineCount: Integer read GetCompDirectiveLineCount;

    property Lines[LineNum: Integer]: TCnList read GetLines;
    {* ÿ��һ��CnList���������� Token}
    property IdLines[LineNum: Integer]: TCnList read GetIdLines;
    {* Ҳ�ǰ� Lines �ķ�ʽ����ÿ��һ�� CnList���������� CurToken}
    property FlowLines[LineNum: Integer]: TCnList read GetFlowLines;
    {* Ҳ�ǰ� Lines �ķ�ʽ����ÿ��һ�� CnList���������� FlowToken}
    property CompDirectiveLines[LineNum: Integer]: TCnList read GetCompDirectiveLines;
    {* Ҳ�ǰ� Lines �ķ�ʽ����ÿ��һ�� CnList���������� CompDirectiveToken}
    property Control: TControl read FControl;
    property Modified: Boolean read FModified write FModified;
    property Changed: Boolean read FChanged write FChanged;
    property CurrentTokenName: AnsiString read FCurrentTokenName write FCurrentTokenName;
    property CurrentToken: TCnPasToken read FCurrentToken write FCurrentToken;
    property CaseSensitive: Boolean read FCaseSensitive write FCaseSensitive;
    {* ��ǰƥ��ʱ�Ƿ��Сд���У����ⲿ�趨}
    property IsCppSource: Boolean read FIsCppSource write FIsCppSource;
    {* �Ƿ��� C/C++ �ļ���Ĭ���� False��Ҳ���� Pascal}
    property PasParser: TCnPasStructureParser read FPasParser;
    property CppParser: TCnCppStructureParser read FCppParser;

    property LineInfo: TBlockLineInfo read FLineInfo write FLineInfo;
    {* ���߸����������Ϣ�������ؼ��ָ���ʱ˳��Ҳ����}
    property CompDirectiveInfo: TCompDirectiveInfo read FCompDirectiveInfo write FCompDirectiveInfo;
    {* ����ָ��������Ϣ�������ؼ��ָ���ʱ˳��Ҳ����}
  end;

  TBlockLinePair = class(TObject)
  {* ����һ����Ե�������Ӧ�Ķ�� Token ���}
  private
    FTop: Integer;
    FLeft: Integer;
    FBottom: Integer;
    FStartToken: TCnPasToken;
    FEndToken: TCnPasToken;
    FLayer: Integer;
    FEndLeft: Integer;
    FStartLeft: Integer;
    FMiddleTokens: TList;
    FDontDrawVert: Boolean;
    function GetMiddleCount: Integer;
    function GetMiddleToken(Index: Integer): TCnPasToken;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure AddMidToken(const Token: TCnPasToken; const LineLeft: Integer);
    function IsInMiddle(const LineNum: Integer): Boolean;
    function IndexOfMiddleToken(const Token: TCnPasToken): Integer;

    property StartToken: TCnPasToken read FStartToken write FStartToken;
    property EndToken: TCnPasToken read FEndToken write FEndToken;
    //property EndIsFirstTokenInLine: Boolean read FEndIsFirstTokenInLine write FEndIsFirstTokenInLine;
    //{* ĩβ�Ƿ��ǵ�һ��Token}
    
    property StartLeft: Integer read FStartLeft write FStartLeft;
    {* �����ʼ Token �� Column}
    property EndLeft: Integer read FEndLeft write FEndLeft;
    {* �����ֹ�� Token �� Column}

    property Left: Integer read FLeft write FLeft;
    {* һ�Ի��ߵ���� Token ��Ӧ������� Column ֵ����ȻΪ StartLeft �� EndLeft ֮һ}
    property Top: Integer read FTop write FTop;
    {* һ�Ի��ߵ���� Token ��Ӧ������� Line ֵ����ȻΪ StartToken �� Line ֵ}
    property Bottom: Integer read FBottom write FBottom;
    {* һ�Ի��ߵ���� Token ��Ӧ������� Line ֵ����ȻΪ EndToken �� Line ֵ}

    property MiddleCount: Integer read GetMiddleCount;
    {* һ�Ի�����Ե� Token ���м�� Token ������}
    property MiddleToken[Index: Integer]: TCnPasToken read GetMiddleToken;
    {* һ�Ի�����Ե� Token ���м�� Token }

    property Layer: Integer read FLayer write FLayer;
    {* һ�Ի��ߵ���Բ��}

    property DontDrawVert: Boolean read FDontDrawVert write FDontDrawVert;
    {* �����Ƿ���Ҫ������}
  end;

  TCompDirectivePair = class(TBlockLinePair)
  {* ����һ����Եı���ָ������Ӧ�Ķ�� Token ��ǣ����� TBlockLinePair}
  end;

  TBlockLineInfo = class(TObject)
  {* ÿ�� EditControl ��Ӧһ�����ɶ�Ӧ�� BlockMatchInfo ת���������������
     LinePair.}
  private
    FControl: TControl;
    FPairList: TCnObjectList;
    FKeyLineList: TCnObjectList;
    FCurrentPair: TBlockLinePair;
    FCurrentToken: TCnPasToken;
    function GetCount: Integer;
    function GetPairs(Index: Integer): TBlockLinePair;
    function GetLineCount: Integer;
    function GetLines(LineNum: Integer): TCnList;
    procedure ConvertLineList; // ת���ɰ��п��ٷ��ʵ�
  public
    constructor Create(AControl: TControl);
    destructor Destroy; override;
    procedure Clear;
    procedure AddPair(Pair: TBlockLinePair);
    procedure FindCurrentPair(View: IOTAEditView; IsCppModule: Boolean = False); virtual;
    {* Ѱ������һ����ʶ���ڹ���µ�һ��ؼ��ֶ�}
    property Control: TControl read FControl;
    property Count: Integer read GetCount;
    property Pairs[Index: Integer]: TBlockLinePair read GetPairs;
    property LineCount: Integer read GetLineCount;
    property Lines[LineNum: Integer]: TCnList read GetLines;
    property CurrentPair: TBlockLinePair read FCurrentPair;
    property CurrentToken: TCnPasToken read FCurrentToken;
  end;

  TCompDirectiveInfo = class(TBlockLineInfo)
  {* ÿ�� EditControl ��Ӧһ�����ɶ�Ӧ�� BlockMatchInfo ת���������������
     TCompDirectivePair. ʵ�������� TBlockLineInfo��������� TBlockLinePair
     ʵ������ TCompDirectivePair}
    procedure FindCurrentPair(View: IOTAEditView; IsCppModule: Boolean = False); override;
    {* Ѱ������һ������ָ���ڹ���µ�һ�����ָ���}
  end;

  TCurLineInfo = class(TObject)
  {* ÿ�� EditControl ��Ӧһ������¼������ǰ�е���Ϣ}
  private
    FCurrentLine: Integer;
    FControl: TControl;
  public
    constructor Create(AControl: TControl);
    destructor Destroy; override;

    property Control: TControl read FControl;
    property CurrentLine: Integer read FCurrentLine write FCurrentLine;
  end;

{ TCnSourceHighlight }

  TCnSourceHighlight = class(TCnIDEEnhanceWizard)
  private
    FOnEnhConfig: TNotifyEvent;

    FMatchedBracket: Boolean;
    FBracketColor: TColor;
    FBracketColorBk: TColor;
    FBracketColorBd: TColor;
    FBracketBold: Boolean;
    FBracketMiddle: Boolean;
    FBracketList: TObjectList;

    FStructureHighlight: Boolean;
    FBlockHighlightRange: TBlockHighlightRange;
    FBlockMatchDelay: Cardinal;
    FBlockHighlightStyle: TBlockHighlightStyle;
    FBlockMatchDrawLine: Boolean;
    FBlockMatchList: TObjectList;
    FBlockLineList: TObjectList;
    FCompDirectiveList: TObjectList;
    FLineMapList: TObjectList;   // ������ӳ����Ϣ
{$IFNDEF BDS}
    FCorIdeModule: HMODULE;
    FCurLineList: TObjectList;   // ���ɵ�ǰ�б��������ػ�����Ϣ
{$ENDIF}
    FBlockShortCut: TCnWizShortCut;
    FBlockMatchMaxLines: Integer;
    FStructureTimer: TTimer;
    FCurrentTokenValidateTimer: TTimer;
    FIsChecking: Boolean;
    CharSize: TSize;
    FBlockMatchLineLimit: Boolean;
    FBlockMatchLineWidth: Integer;
    FBlockMatchLineClass: Boolean;
    FBlockMatchHighlight: Boolean;
    FBlockMatchBackground: TColor;
    FCurrentTokenHighlight: Boolean;
    FCurrentTokenDelay: Integer;
    FCurrentTokenInvalid: Boolean;
    FHilightSeparateLine: Boolean;
    FCurrentTokenBackground: TColor;
    FCurrentTokenForeground: TColor;
    FCurrentTokenBorderColor: TColor;
    FShowTokenPosAtGutter: Boolean;
    FBlockMatchLineEnd: Boolean;
    FBlockMatchLineHori: Boolean;
    FBlockMatchLineHoriDot: Boolean;
    FBlockExtendLeft: Boolean;
    FBlockMatchLineStyle: TCnLineStyle;
    FKeywordHighlight: THighlightItem;
    FIdentifierHighlight: THighlightItem;
    FCompDirectiveHighlight: THighlightItem;
    FDirtyList: TList;
    FViewChangedList: TList;
    FViewFileNameIsPascalList: TList;
{$IFDEF BDS}
    FAnsiLineText: AnsiString;
    FUniLineText: string;
  {$IFDEF BDS2009_UP}
    FUseTabKey: Boolean;
    FTabWidth: Integer;
  {$ENDIF}
{$ELSE}
    FHighLightCurrentLine: Boolean;
    FHighLightLineColor: TColor;
    FDefaultHighLightLineColor: TColor;
{$ENDIF}
    FSeparateLineColor: TColor;
    FSeparateLineStyle: TCnLineStyle;
    FSeparateLineWidth: Integer;
    FHighlightFlowStatement: Boolean;
    FFlowStatementBackground: TColor;
    FFlowStatementForeground: TColor;
    FHighlightCompDirective: Boolean;
    FCompDirectiveBackground: TColor;
    function GetColorFg(ALayer: Integer): TColor;
    function EditorGetTextRect(Editor: TEditorObject; APos: TOTAEditPos;
      const {$IFDEF BDS}LineText, {$ENDIF} AText: string; var ARect: TRect): Boolean;
    procedure EditorPaintText(EditControl: TControl; ARect: TRect; AText: AnsiString;
      AColor, AColorBk, AColorBd: TColor; ABold, AItalic, AUnderline: Boolean);
    function IndexOfBracket(EditControl: TControl): Integer;
    function GetBracketMatch(EditView: IOTAEditView; EditBuffer: IOTAEditBuffer;
      EditControl: TControl; AInfo: TBracketInfo): Boolean;
    procedure CheckBracketMatch(Editor: TEditorObject);

    function IndexOfBlockMatch(EditControl: TControl): Integer;
    function IndexOfBlockLine(EditControl: TControl): Integer;
    function IndexOfCompDirectiveLine(EditControl: TControl): Integer;
{$IFNDEF BDS}
    function IndexOfCurLine(EditControl: TControl): Integer;
{$ENDIF}
{$IFDEF BDS2009_UP}
    procedure UpdateTabWidth;
{$ENDIF}
    procedure OnHighlightTimer(Sender: TObject);
    procedure OnHighlightExec(Sender: TObject);
    procedure OnCurrentTokenValidateTimer(Sender: TObject);
    procedure BeginUpdateEditor(Editor: TEditorObject);
    procedure EndUpdateEditor(Editor: TEditorObject);
    // ���һ�д�����Ҫ�ػ���ֻ���� BeginUpdateEditor �� EndUpdateEditor ֮�������Ч
    procedure EditorMarkLineDirty(LineNum: Integer);
    procedure RefreshCurrentTokens(Info: TBlockMatchInfo);
    procedure UpdateHighlight(Editor: TEditorObject; ChangeType: TEditorChangeTypes);
    procedure ActiveFormChanged(Sender: TObject);
    procedure AfterCompile(Succeeded: Boolean; IsCodeInsight: Boolean);
    procedure EditControlNotify(EditControl: TControl; EditWindow: TCustomForm;
      Operation: TOperation);
    procedure SourceEditorNotify(SourceEditor: IOTASourceEditor;
      NotifyType: TCnWizSourceEditorNotifyType; EditView: IOTAEditView);
    procedure EditorChanged(Editor: TEditorObject; ChangeType: TEditorChangeTypes);
    procedure EditorKeyDown(Key, ScanCode: Word; Shift: TShiftState; var Handled: Boolean);
    procedure ClearHighlight(Editor: TEditorObject);
    procedure PaintBracketMatch(Editor: TEditorObject;
      LineNum, LogicLineNum: Integer; AElided: Boolean);
    procedure PaintBlockMatchKeyword(Editor: TEditorObject;
      LineNum, LogicLineNum: Integer; AElided: Boolean);
    procedure PaintBlockMatchLine(Editor: TEditorObject;
      LineNum, LogicLineNum: Integer; AElided: Boolean);
    procedure PaintLine(Editor: TEditorObject; LineNum, LogicLineNum: Integer);
    function GetBlockMatchHotkey: TShortCut;
    procedure SetBlockMatchHotkey(const Value: TShortCut);
    procedure SetBlockMatchLineClass(const Value: Boolean);
    procedure ReloadIDEFonts;
    procedure SetHilightSeparateLine(const Value: Boolean);    
{$IFNDEF BDS}
    procedure BeforePaintLine(Editor: TEditorObject; LineNum, LogicLineNum: Integer);
    procedure SetHighLightCurrentLine(const Value: Boolean);
    procedure SetHighLightLineColor(const Value: TColor);
{$ENDIF}
    procedure SetFlowStatementBackground(const Value: TColor);
    procedure SetHighlightFlowStatement(const Value: Boolean);
    procedure SetFlowStatementForeground(const Value: TColor);
    procedure SetCompDirectiveBackground(const Value: TColor);
    procedure SetHighlightCompDirective(const Value: Boolean);
  protected
    procedure DoEnhConfig;
    procedure SetActive(Value: Boolean); override;
    function GetHasConfig: Boolean; override;
  public
    // �ų��������ô��ڶ�д
    FHighLightColors: array[-1..5] of TColor;

    constructor Create; override;
    destructor Destroy; override;

    class procedure GetWizardInfo(var Name, Author, Email, Comment: string); override;
    procedure LoadSettings(Ini: TCustomIniFile); override;
    procedure SaveSettings(Ini: TCustomIniFile); override;
    procedure Config; override;

    procedure RepaintEditors;
    {* �����ô��ڵ��ã�ǿ���ػ�}
    property MatchedBracket: Boolean read FMatchedBracket write FMatchedBracket;
    property BracketColor: TColor read FBracketColor write FBracketColor;
    property BracketBold: Boolean read FBracketBold write FBracketBold;
    property BracketColorBk: TColor read FBracketColorBk write FBracketColorBk;
    property BracketColorBd: TColor read FBracketColorBd write FBracketColorBd;
    property BracketMiddle: Boolean read FBracketMiddle write FBracketMiddle;

    property StructureHighlight: Boolean read FStructureHighlight write FStructureHighlight;
    {* �Ƿ����ؼ��ָ���}
    property BlockMatchHighlight: Boolean read FBlockMatchHighlight write FBlockMatchHighlight;
    {* �Ƿ����¹ؼ�����Ա���ɫ����}
    property BlockMatchBackground: TColor read FBlockMatchBackground write FBlockMatchBackground;
    {* ����¹ؼ�����Ը����ı���ɫ}
    property CurrentTokenHighlight: Boolean read FCurrentTokenHighlight write FCurrentTokenHighlight;
    {* �Ƿ����µ�ǰ��ʶ������ɫ����}
    property CurrentTokenForeground: TColor read FCurrentTokenForeground write FCurrentTokenForeground;
    {* ����µ�ǰ��ʶ��������ǰ��ɫ}
    property CurrentTokenBackground: TColor read FCurrentTokenBackground write FCurrentTokenBackground;
    {* ����µ�ǰ��ʶ�������ı���ɫ}
    property CurrentTokenBorderColor: TColor read FCurrentTokenBorderColor write FCurrentTokenBorderColor;
    {* ����µ�ǰ��ʶ�������ı߿�ɫ}
    property ShowTokenPosAtGutter: Boolean read FShowTokenPosAtGutter write FShowTokenPosAtGutter;
    {* �Ƿ�ѹ���µ�ǰ��ʶ���ǵ�λ����ʾ���к�����}
    property BlockHighlightRange: TBlockHighlightRange read FBlockHighlightRange write FBlockHighlightRange;
    {* ������Χ��Ĭ�ϸĳ��� brAll}
    property BlockHighlightStyle: TBlockHighlightStyle read FBlockHighlightStyle write FBlockHighlightStyle;
    {* ������ʱģʽ��Ĭ�ϸĳ��� bsNow}
    property BlockMatchDelay: Cardinal read FBlockMatchDelay write FBlockMatchDelay;
    property BlockMatchHotkey: TShortCut read GetBlockMatchHotkey write SetBlockMatchHotkey;
    property BlockMatchDrawLine: Boolean read FBlockMatchDrawLine write FBlockMatchDrawLine;
    {* �Ƿ���׵ػ��߸���}
    property BlockMatchLineWidth: Integer read FBlockMatchLineWidth write FBlockMatchLineWidth;
    {* �߿�Ĭ��Ϊ 1}
    property BlockMatchLineEnd: Boolean read FBlockMatchLineEnd write FBlockMatchLineEnd;
    {* �Ƿ�����ߵĶ˵㣬Ҳ���ǰ��Źؼ��ֵĲ��֣��ͺ���ʹ��ͬһ���ͣ�����߲�����ʹ����������}
    property BlockMatchLineStyle: TCnLineStyle read FBlockMatchLineStyle write FBlockMatchLineStyle;
    {* ����}
    property BlockMatchLineHori: Boolean read FBlockMatchLineHori write FBlockMatchLineHori;
    {* �Ƿ���ƺ��ߣ�Ҳ�������ߵ������Ĳ��ֵĺ���}
    property BlockMatchLineHoriDot: Boolean read FBlockMatchLineHoriDot write FBlockMatchLineHoriDot;
    {* ������ʱ�Ƿ�ʹ������ TinyDot ������}
    property BlockExtendLeft: Boolean read FBlockExtendLeft write FBlockExtendLeft;
    {* �Ƿ����׵�һ���ؼ�����Ϊ������ʼ�㣬�Լ��ٲ������߿��ܴӴ����д��������}

    property BlockMatchLineClass: Boolean read FBlockMatchLineClass write SetBlockMatchLineClass;
    {* �Ƿ���ƥ�� class/record/interface �ȵ�����}
{$IFNDEF BDS}
    property HighLightCurrentLine: Boolean read FHighLightCurrentLine write SetHighLightCurrentLine;
    {* �Ƿ������ǰ�еı���}
    property HighLightLineColor: TColor read FHighLightLineColor write SetHighLightLineColor;
    {* ������ǰ�еı���ɫ}
{$ENDIF}
    property HilightSeparateLine: Boolean read FHilightSeparateLine write SetHilightSeparateLine;
    {* �Ƿ���ƿ��зָ���}
    property SeparateLineColor: TColor read FSeparateLineColor write FSeparateLineColor;
    {* ���зָ��ߵ���ɫ}
    property SeparateLineStyle: TCnLineStyle read FSeparateLineStyle write FSeparateLineStyle;
    {* ���зָ��ߵ�����}
    property SeparateLineWidth: Integer read FSeparateLineWidth write FSeparateLineWidth;
    {* ���зָ��ߵ��߿�Ĭ��Ϊ 1}
    property BlockMatchLineLimit: Boolean read FBlockMatchLineLimit write FBlockMatchLineLimit;
    property BlockMatchMaxLines: Integer read FBlockMatchMaxLines write FBlockMatchMaxLines;
    property HighlightFlowStatement: Boolean read FHighlightFlowStatement write SetHighlightFlowStatement;
    {* �Ƿ�������̿������}
    property FlowStatementBackground: TColor read FFlowStatementBackground write SetFlowStatementBackground;
    {* �������̿������ı���ɫ}
    property FlowStatementForeground: TColor read FFlowStatementForeground write SetFlowStatementForeground;
    {* �������̿�������ǰ��ɫ}

    property HighlightCompDirective: Boolean read FHighlightCompDirective write SetHighlightCompDirective;
    {* ������ǰ��������ָ��}
    property CompDirectiveBackground: TColor read FCompDirectiveBackground write SetCompDirectiveBackground;
    {* ������ǰ��������ָ��ı���ɫ}
    
    property OnEnhConfig: TNotifyEvent read FOnEnhConfig write FOnEnhConfig;
  end;

function LoadIDEDefaultCurrentColor: TColor;
{* ���� IDE ��ɫ�����Զ������ĳ�ʼ����������ɫ}

procedure HighlightCanvasLine(ACanvas: TCanvas; X1, Y1, X2, Y2: Integer;
  AStyle: TCnLineStyle);
{* ����ר�õĻ��ߺ�����TinyDot ʱ����б��}

function CheckTokenMatch(const T1: AnsiString; const T2: AnsiString;
  CaseSensitive: Boolean): Boolean;
{* �ж��Ƿ���Identifer���}

function CheckIsCompDirectiveToken(AToken: TCnPasToken; IsCpp: Boolean): Boolean;
{* �ж��Ƿ�����������ָ��}

{$IFNDEF BDS}
procedure MyEditorsCustomEditControlSetForeAndBackColor(ASelf: TObject;
  Param1, Param2, Param3, Param4: Cardinal);
{$ENDIF}

{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}

implementation

{$IFDEF CNWIZARDS_CNSOURCEHIGHLIGHT}

uses
{$IFDEF DEBUG}
  CnDebug,
{$ENDIF}
  CnWizMethodHook, CnSourceHighlightFrm, CnWizCompilerConst, CnEventBus;

type
  TBracketChars = array[0..1] of AnsiChar;
  TBracketArray = array[0..255] of TBracketChars;
  PBracketArray = ^TBracketArray;
  // �Ӳ��� register û������Ĭ�Ͼ��� register ��ʽ
  TEVFillRectProc = procedure(Self: TObject; const Rect: TRect); register;
  TSetForeAndBackColorProc = procedure (Self: TObject;
    Param1, Param2, Param3, Param4: Cardinal); register;

  TCustomControlHack = class(TCustomControl);

const
  csBracketCountCpp = 3;
  csBracketsCpp: array[0..csBracketCountCpp - 1] of TBracketChars =
    (('(', ')'), ('[', ']'), ('{', '}'));

  csBracketCountPas = 2;
  csBracketsPas: array[0..csBracketCountPas - 1] of TBracketChars =
    (('(', ')'), ('[', ']'));

  csReservedWord = 'Reserved word'; // RegName of IDE Font for Reserved word
  csIdentifier = 'Identifier';      // RegName of IDE Font for Identifier
{$IFDEF DELPHI5}
  csCompDirective = 'Comment';      // Delphi 5/6 Compiler Directive = Comment
{$ELSE}
  {$IFDEF DELPHI6}
  csCompDirective = 'Comment';
  {$ELSE}
  csCompDirective = 'Preprocessor'; // RegName of IDE Font for Compiler Directive
  {$ENDIF}
{$ENDIF}

  csWhiteSpace = 'Whitespace';

  csMaxBracketMatchLines = 50;

  csShortDelay = 20;

{$IFNDEF BDS}
  {$IFDEF COMPILER5}
  SEVFillRectName = '@Editors@TCustomEditControl@EVFillRect$qqrrx13Windows@TRect';
  {$ELSE}
  SEVFillRectName = '@Editors@TCustomEditControl@EVFillRect$qqrrx11Types@TRect';
  {$ENDIF}
  SSetForeAndBackColorName = '@Editors@TCustomEditControl@SetForeAndBackColor$qqriioo';
{$ENDIF}
  csMatchedBracket = 'MatchedBracket';
  csBracketColor = 'BracketColor';
  csBracketColorBk = 'BracketColorBk';
  csBracketColorBd = 'BracketColorBd';
  csBracketBold = 'BracketBold';
  csBracketMiddle = 'BracketMiddle';

  csStructureHighlight = 'StructureHighlight';
  csBlockHighlightRange = 'BlockHighlightRange';
  csBlockMatchDelay = 'BlockMatchDelay';
  csBlockMatchMaxLines = 'BlockMatchMaxLines';
  csBlockMatchLineLimit = 'BlockMatchLineLimit';
  csBlockHighlightStyle = 'BlockHighlightStyle';
  csBlockMatchDrawLine = 'BlockMatchDrawLine';
  csBlockMatchLineWidth = 'BlockMatchLineWidth';
  csBlockMatchLineStyle = 'BlockMatchLineStyle';
  csBlockMatchLineClass = 'BlockMatchLineClass';
  csBlockMatchLineEnd = 'BlockMatchLineEnd';
  csBlockMatchLineHori = 'BlockMatchLineHori';
  csBlockMatchLineHoriDot = 'BlockMatchLineHoriDot';
  csBlockMatchHighlight = 'BlockMatchHighlight';
  csBlockMatchBackground = 'BlockMatchBackground';

  csCurrentTokenHighlight = 'CurrentTokenHighlight';
  csCurrentTokenColor = 'CurrentTokenColor';
  csCurrentTokenColorBk = 'CurrentTokenColorBk';
  csCurrentTokenColorBd = 'CurrentTokenColorBd';
  csShowTokenPosAtGutter = 'ShowTokenPosAtGutter';
  csLineGutterColor = 'LineGutterColor';

  csHilightSeparateLine = 'HilightSeparateLine';
  csSeparateLineColor = 'SeparateLineColor';
  csSeparateLineStyle = 'SeparateLineStyle';
  csSeparateLineWidth = 'SeparateLineWidth';
  csBlockMatchHighlightColor = 'BlockMatchHighlightColor';
  csHighlightCurrentLine = 'HighLightCurrentLine';
  csHighLightLineColor = 'HighLightLineColor';
  csHighlightFlowStatement = 'HighlightFlowStatement';
  csFlowStatementBackground = 'FlowStatementBackground';
  csFlowStatementForeground = 'FlowStatementForeground';
  csHighlightCompDirective = 'HighlightCompDirective';
  csCompDirectiveBackground = 'CompDirectiveBackground';

var
  FHighlight: TCnSourceHighlight = nil;
  GlobalIgnoreClass: Boolean = False;
{$IFNDEF BDS}
  CanDrawCurrentLine: Boolean = False;
  PaintingControl: TControl = nil;
  ColorChanged: Boolean;
  OldBkColor: TColor = clWhite;
  EVFillRect: TEVFillRectProc = nil;
  EVFRHook: TCnMethodHook = nil;

  SetForeAndBackColor: TSetForeAndBackColorProc = nil;
  SetForeAndBackColorHook: TCnMethodHook = nil;
  {$IFDEF DEBUG}
  // CurrentLineNum: Integer = -1;
  {$ENDIF}
{$ENDIF}

function CheckIsFlowToken(AToken: TCnPasToken; IsCpp: Boolean): Boolean;
var
  I: Integer;
  T: AnsiString;
begin
  Result := False;
  if AToken = nil then
    Exit;

  if IsCpp then // ���ִ�Сд
  begin
    if AToken.CppTokenKind in csCppFlowTokenKinds then // �ȱȹؼ���
    begin
      Result := True;
{$IFDEF DEBUG}
//    CnDebugger.LogFmt('Cpp TokenType %d, Token: %s', [Integer(AToken.CppTokenKind), AToken.Token]);
{$ENDIF}
      Exit;
    end
    else
    begin
      T := AToken.Token;
      for I := Low(csCppFlowTokenStr) to High(csCppFlowTokenStr) do
      begin
        if T = csCppFlowTokenStr[I] then
        begin
{$IFDEF DEBUG}
//        CnDebugger.LogFmt('Cpp is Flow. TokenType %d, Token: %s', [Integer(AToken.CppTokenKind), AToken.Token]);
{$ENDIF}
          Result := True;
          Exit;
        end;
      end;
    end;
  end
  else // �����ִ�Сд
  begin
    if AToken.TokenID in csPasFlowTokenKinds then // Ҳ�ȱȹؼ���
    begin
{$IFDEF DEBUG}
//    CnDebugger.LogFmt('Pascal TokenType %d, Token: %s', [Integer(AToken.TokenID), AToken.Token]);
{$ENDIF}
      Result := True;
      Exit;
    end
    else
    begin
      T := AToken.Token;
      for I := Low(csPasFlowTokenStr) to High(csPasFlowTokenStr) do
      begin
        {$IFDEF UNICODE}
        // Unicode ʱֱ�ӵ��� API �Ƚ��Ա���������ʱ�ַ�����Ӱ������
        Result := lstrcmpiA(@T[1], @((csPasFlowTokenStr[I])[1])) = 0;
        {$ELSE}
        Result := LowerCase(T) = csPasFlowTokenStr[I];
       {$ENDIF}

        if Result then
        begin
{$IFDEF DEBUG}
//        CnDebugger.LogFmt('Pascal is Flow. TokenType %d, Token: %s', [Integer(AToken.TokenID), AToken.Token]);
{$ENDIF}
          Exit;
        end;
      end;
    end;
  end;
  Result := False;
end;

// �˺����� Unicode IDE �²�Ӧ�ñ�����
function ConvertAnsiPositionToUtf8OnUnicodeText(const Text: string;
  AnsiCol: Integer): Integer;
{$IFDEF UNICODE}
var
  ULine: string;
  UniCol: Integer;
  ALine: AnsiString;
{$ENDIF}
begin
  Result := AnsiCol;
  if Result <= 0 then
    Exit;

{$IFDEF UNICODE}
  if CodePageOnlySupportsEnglish then
  begin
    UniCol := CalcWideStringLengthFromAnsiOffset(PWideChar(Text), AnsiCol);
    ULine := Copy(Text, 1, UniCol - 1);
    ALine := Utf8Encode(ULine);
    Result := Length(ALine) + 1;
  end
  else
  begin
    ALine := AnsiString(Text);
    ALine := Copy(ALine, 1, AnsiCol - 1);         // �� Ansi �� Col �ض�
    UniCol := Length(string(ALine)) + 1;          // ת�� Unicode �� Col
    ULine := Copy(Text, 1, UniCol - 1);           // ���½ض�
    ALine := CnAnsiToUtf8(AnsiString(ULine));     // ת�� Ansi-Utf8
    Result := Length(ALine) + 1;                  // ȡ UTF8 �ĳ���
  end;
{$ENDIF}
end;

{$IFDEF UNICODE}

function StartWithIgnoreCase(Pattern: PAnsiChar; Content: PAnsiChar): Boolean; inline;
var
  PP, PC: PAnsiChar;

  function AnsiCharEqualIgnoreCase(P, C: Byte): Boolean; inline;
  begin
    Result := P = C;
    if not Result then
    begin
      // Assume Pattern already uppercase.
      if C in [97..122] then  // if a..z to A..Z
        Dec(C, 32);
      Result := P = C;
    end;
  end;

begin
  PP := Pattern;
  PC := Content;

  while (PP^ <> #0) and (PC^ <> #0) do
  begin
    Result := AnsiCharEqualIgnoreCase(Ord(PP^), Ord(PC^));
    if not Result then
      Exit;
    Inc(PP);
    Inc(PC);
  end;
  Result := PP^ = #0;
end;

function ConvertUtf8PositionToAnsi(const Utf8Text: AnsiString; Utf8Col: Integer): Integer;
var
  ALine: AnsiString;
  ULine: string;
begin
  Result := Utf8Col;
  if Result < 0 then
    Exit;

  ALine := Copy(Utf8Text, 1, Utf8Col - 1);
  if CodePageOnlySupportsEnglish then
  begin
    ULine := string(ALine);
    Result := CalcAnsiLengthFromWideString(PWideChar(ULine)) + 1;
  end
  else
  begin
    Result := Length(CnUtf8ToAnsi(ALine)) + 1;
  end;
end;

{$ENDIF}

function CheckIsCompDirectiveToken(AToken: TCnPasToken; IsCpp: Boolean): Boolean;
var
  I: Integer;
  T: AnsiString;
begin
  Result := False;
  if AToken = nil then
    Exit;

  if IsCpp then
  begin
{$IFDEF DEBUG}
//  CnDebugger.LogFmt('Cpp check. TokenType %d, Token: %s', [Integer(AToken.CppTokenKind), AToken.Token]);
{$ENDIF}
    if AToken.CppTokenKind in csCppCompDirectiveKinds then // �ȹؼ���
    begin
      Result := True;
      Exit;
    end;
  end
  else // �����ִ�Сд
  begin
{$IFDEF DEBUG}
//  CnDebugger.LogFmt('Pascal check. TokenType %d, Token: %s', [Integer(AToken.TokenID), AToken.Token]);
{$ENDIF}
    if AToken.TokenID = tkCompDirect then // Ҳ�ȱȹؼ���
    begin
      T := AToken.Token;
      for I := Low(csPasCompDirectiveTokenStr) to High(csPasCompDirectiveTokenStr) do
      begin
        {$IFDEF UNICODE}
        // Unicode ʱҪ������������
        Result := StartWithIgnoreCase(@(csPasCompDirectiveTokenStr[I][1]), @T[1]);
        {$ELSE}
        Result := Pos(csPasCompDirectiveTokenStr[I], UpperCase(T)) = 1;
        {$ENDIF}

        if Result then
        begin
          AToken.CompDirectivtType := csPasCompDirectiveTypes[I];
{$IFDEF DEBUG}
//        CnDebugger.LogFmt('Pascal is CompDirective. TokenType %d, Token: %s', [Integer(AToken.TokenID), AToken.Token]);
{$ENDIF}
          Exit;
        end;
      end;
    end;
  end;
  Result := False;
end;

function CheckTokenMatch(const T1: AnsiString; const T2: AnsiString;
  CaseSensitive: Boolean): Boolean;
begin
  if CaseSensitive then
    Result := T1 = T2
  else
  begin
  {$IFDEF UNICODE}
    // Unicode ʱֱ�ӵ��� API �Ƚ��Ա���������ʱ�ַ�����Ӱ������
    Result := lstrcmpiA(@T1[1], @T2[1]) = 0;
  {$ELSE}
    Result := UpperCase(T1) = UpperCase(T2);
  {$ENDIF}
  end;
end;

procedure HighlightCanvasLine(ACanvas: TCanvas; X1, Y1, X2, Y2: Integer;
  AStyle: TCnLineStyle);
var
  I, XStep, YStep, Step: Integer;
  OldStyle: TBrushStyle;
  OldColor: TColor;
begin
  if ACanvas <> nil then
  begin
    OldStyle := ACanvas.Brush.Style;
    OldColor := ACanvas.Brush.Color;
    ACanvas.Brush.Style := bsClear;

    try
      case AStyle of
        lsSolid:
          begin
            ACanvas.Pen.Style := psSolid;
            ACanvas.MoveTo(X1, Y1);
            ACanvas.LineTo(X2, Y2);
          end;
        lsDot:
          begin
            ACanvas.Pen.Style := psDot;
            ACanvas.MoveTo(X1, Y1);
            ACanvas.LineTo(X2, Y2);
          end;
        lsSmallDot, lsTinyDot:
          begin
            ACanvas.Pen.Style := psSolid;
            if AStyle = lsSmallDot then
              Step := CN_LINE_STYLE_SMALL_DOT_STEP
            else
              Step := CN_LINE_STYLE_TINY_DOT_STEP;

            with ACanvas do
            begin
              if X1 = X2 then
              begin
                YStep := Abs(Y2 - Y1) div (Step * 2); // Y�����ܲ�������ֵ
                if Y1 < Y2 then
                begin
                  for I := 0 to YStep - 1 do
                  begin
                    MoveTo(X1, Y1 + (2 * I + 1) * Step);
                    LineTo(X1, Y1 + (2 * I + 2) * Step);
                  end;
                end
                else
                begin
                  for I := 0 to YStep - 1 do
                  begin
                    MoveTo(X1, Y1 - (2 * I + 1) * Step);
                    LineTo(X1, Y1 - (2 * I + 2) * Step);
                  end;
                end;
              end
              else if Y1 = Y2 then
              begin
                XStep := Abs(X2 - X1) div (Step * 2); // X�����ܲ���
                if X1 < X2 then
                begin
                  for I := 0 to XStep - 1 do
                  begin
                    MoveTo(X1 + (2 * I + 1) * Step, Y1);
                    LineTo(X1 + (2 * I + 2) * Step, Y1);
                  end;
                end
                else
                begin
                  for I := 0 to XStep - 1 do
                  begin
                    MoveTo(X1 - (2 * I + 1) * Step, Y1);
                    LineTo(X1 - (2 * I + 2) * Step, Y1);
                  end;
                end;
              end;
            end;
          end;
      end;
    finally
      ACanvas.Brush.Style := OldStyle;
      ACanvas.Brush.Color := OldColor;
    end;
  end;
end;

function TokenIsMethodOrClassName(const Token, Name: string): Boolean;
var
  I: Integer;
  s, sName: string;
begin
  Result := False;
  sName := Name;
  I := LastDelimiter('.', sName);
  if I > 0 then
    s := Copy(sName, I + 1, MaxInt)
  else
    s := sName;

  if AnsiSameText(Token, s) then
    Result := True;
  while (not Result) and (I > 0) do
  begin
    sName := Copy(sName, 1, I - 1);
    I := LastDelimiter('.', sName);
    if I > 0 then
      s := Copy(sName, I + 1, MaxInt)
    else
      s := sName;
    if AnsiSameText(Token, s) then
      Result := True;
  end;
end;

{ TBracketInfo }

constructor TBracketInfo.Create(AControl: TControl);
begin
  inherited Create;
  FControl := AControl;
end;

{ TBlockMatchInfo }

// ������鱾 EditControl �еĽṹ������Ϣ
function TBlockMatchInfo.CheckBlockMatch(
  BlockHighlightRange: TBlockHighlightRange): Boolean;
var
  EditView: IOTAEditView;
  Stream: TMemoryStream;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  i: Integer;
  StartIndex, EndIndex: Integer;
  UnicodeCanNotDirectlyToAnsi: Boolean;

  function IsHighlightKeywords(TokenID: TTokenKind): Boolean;
  var
    AToken: TCnPasToken;
  begin
    Result := TokenID in csKeyTokens;
    if Result and (TokenID = tkOf) and (FKeyTokenList.Count > 0) then // ���� of ǰһ���ؼ��ֱ����� case �����
    begin
      AToken := TCnPasToken(FKeyTokenList[FKeyTokenList.Count - 1]);
      if (AToken = nil) or (AToken.TokenID <> tkCase) then
        Result := False;
    end;
  end;

begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TBlockMatchInfo.CheckBlockMatch');
{$ENDIF}

  Result := False;

  // ���ܵ��� Clear ��������������ݣ����뱣�� FCurTokenList�������ػ�ʱ����ˢ��
  FKeyTokenList.Clear;
  FKeyLineList.Clear;
  FIdLineList.Clear;
  FFlowLineList.Clear;
  FSeparateLineList.Clear;
  FCompDirectiveLineList.Clear;
  if LineInfo <> nil then
    LineInfo.Clear;
  if CompDirectiveInfo <> nil then
    CompDirectiveInfo.Clear;

  if Control = nil then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('Control = nil');
  {$ENDIF}
    Exit;
  end;

  try
    EditView := EditControlWrapper.GetEditView(Control);
  except
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('GetEditView error');
  {$ENDIF}
    Exit;
  end;

  if EditView = nil then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('EditView = nil');
  {$ENDIF}
    Exit;
  end;

  UnicodeCanNotDirectlyToAnsi := _UNICODE_STRING and CodePageOnlySupportsEnglish;
  if not IsDprOrPas(EditView.Buffer.FileName) and not IsInc(EditView.Buffer.FileName) then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Highlight. Not IsDprOrPas Or Inc: ' + EditView.Buffer.FileName);
{$ENDIF}

    // �ж������ C/C++���������������� Tokens�������ı�ʱ���� FCurTokenList
    // ���ֻ�ǹ��λ�ñ仯����������Χ���ǵ�ǰ�����ļ��Ļ�������Ҫ���½��������� Pascal ��������ͬ
    if IsCppSourceModule(EditView.Buffer.FileName) and (Modified or (CppParser.Source = '') or
      (FHighlight.BlockHighlightRange <> brAll)) then
    begin
      FIsCppSource := True;
      CaseSensitive := True;
      Stream := TMemoryStream.Create;
      try
  {$IFDEF DEBUG}
        CnDebugger.LogMsg('Parse Cpp Source file: ' + EditView.Buffer.FileName);
  {$ENDIF}
        CnOtaSaveEditorToStream(EditView.Buffer, Stream, False, True, UnicodeCanNotDirectlyToAnsi);
        // ������ǰ��ʾ��Դ�ļ�
        CppParser.ParseSource(PAnsiChar(Stream.Memory), Stream.Size,
          EditView.CursorPos.Line, EditView.CursorPos.Col);
      finally
        Stream.Free;
      end;

      // �� FKeyTokenList �м�¼���������ŵ�λ�ã�
      // Ĭ�ϴ�����Ԫ�е�������Ҫ��ƥ��
      StartIndex := 0;
      EndIndex := CppParser.Count - 1;
      if BlockHighlightRange = brAll then
      begin
        // Ĭ��ȫ����
      end
      else if (BlockHighlightRange in [brMethod, brWholeBlock])
        and Assigned(CppParser.BlockStartToken)
        and Assigned(CppParser.BlockCloseToken) then
      begin
        // ֻ�ѱ��������Ҫ�� Token �ӽ���
        StartIndex := CppParser.BlockStartToken.ItemIndex;
        EndIndex := CppParser.BlockCloseToken.ItemIndex;
      end
      else if (BlockHighlightRange = brInnerBlock)
        and Assigned(CppParser.InnerBlockStartToken)
        and Assigned(CppParser.InnerBlockCloseToken) then
      begin
        // ֻ�ѱ��ڿ�����Ҫ�� Token �ӽ���
        StartIndex := CppParser.InnerBlockStartToken.ItemIndex;
        EndIndex := CppParser.InnerBlockCloseToken.ItemIndex;
      end;

      for I := StartIndex to EndIndex do
        if CppParser.Tokens[I].CppTokenKind in [ctkbraceopen, ctkbraceclose] then
          FKeyTokenList.Add(CppParser.Tokens[I]);

      for I := 0 to KeyCount - 1 do
      begin
        // ת���� Col �� Line
{$IFNDEF BDS2009_UP}
        CharPos := OTACharPos(KeyTokens[I].CharIndex - 1, KeyTokens[I].LineNumber);
        try
          EditView.ConvertPos(False, EditPos, CharPos);
        except
          Continue; // D5/6��ConvertPos��ֻ��һ�����ں�ʱ�����ֻ������
        end;
        // ������� ConvertPos �� D2009 �������д�����ʱ�Ľ�����ܻ���ƫ�
        // ���ֱ�Ӳ������� CharIndex + 1 �ķ�ʽ������ Tab ��չ��ȱ������
{$ELSE}
        EditPos.Line := KeyTokens[I].LineNumber;
        EditPos.Col := KeyTokens[I].CharIndex + 1;
{$ENDIF}
        KeyTokens[I].EditCol := EditPos.Col;
        KeyTokens[I].EditLine := EditPos.Line;
      end;

      // ��¼�����ŵĲ��
      UpdateCurTokenList;
      UpdateFlowTokenList;
      UpdateCompDirectiveList;

      ConvertLineList;
      if LineInfo <> nil then
      begin
        CheckLineMatch(EditView, GlobalIgnoreClass);
    {$IFDEF DEBUG}
        CnDebugger.LogInteger(LineInfo.Count, 'HighLight Cpp LinePairs Count.');
    {$ENDIF}
      end;
      if CompDirectiveInfo <> nil then
      begin
        CheckCompDirectiveMatch(EditView, GlobalIgnoreClass);
    {$IFDEF DEBUG}
        CnDebugger.LogInteger(CompDirectiveInfo.Count, 'HighLight Cpp CompDirectivePairs Count.');
    {$ENDIF}
      end;
    end;
  end
  else  // ������� Pascal �е���Թؼ���
  begin
    if Modified or (PasParser.Source = '') then
    begin
      FIsCppSource := False;
      CaseSensitive := False;
      Stream := TMemoryStream.Create;
      try
  {$IFDEF DEBUG}
        CnDebugger.LogMsg('Parse Pascal Source file: ' + EditView.Buffer.FileName);
  {$ENDIF}
        CnOtaSaveEditorToStream(EditView.Buffer, Stream, False, True, UnicodeCanNotDirectlyToAnsi);
        // ������ǰ��ʾ��Դ�ļ�����Ҫ������ǰ��ʶ��ʱ������KeyOnly
{$IFDEF BDS2009_UP}
        PasParser.TabWidth := FHighlight.FTabWidth;
{$ENDIF}
        PasParser.ParseSource(PAnsiChar(Stream.Memory),
          IsDpr(EditView.Buffer.FileName),
          not (FHighlight.CurrentTokenHighlight or FHighlight.HighlightFlowStatement));
      finally
        Stream.Free;
      end;
    end;

    // �������ٲ��ҵ�ǰ������ڵĿ�
    EditPos := EditView.CursorPos;
    EditView.ConvertPos(True, EditPos, CharPos);
    PasParser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);
    FCurrentBlockSearched := True;

    if BlockHighlightRange = brAll then
    begin
      // ������Ԫ�е�������Ҫ��ƥ��
      for I := 0 to PasParser.Count - 1 do
      begin
        if IsHighlightKeywords(PasParser.Tokens[I].TokenID) then
          FKeyTokenList.Add(PasParser.Tokens[I]);
      end;
    end
    else if (BlockHighlightRange = brMethod) and Assigned(PasParser.MethodStartToken)
      and Assigned(PasParser.MethodCloseToken) then
    begin
      // ֻ�ѱ���������Ҫ�� Token �ӽ���
      for I := PasParser.MethodStartToken.ItemIndex to
        PasParser.MethodCloseToken.ItemIndex do
        if IsHighlightKeywords(PasParser.Tokens[I].TokenID) then
          FKeyTokenList.Add(PasParser.Tokens[I]);
    end
    else if (BlockHighlightRange = brWholeBlock) and Assigned(PasParser.BlockStartToken)
      and Assigned(PasParser.BlockCloseToken) then
    begin
      for I := PasParser.BlockStartToken.ItemIndex to
        PasParser.BlockCloseToken.ItemIndex do
        if IsHighlightKeywords(PasParser.Tokens[I].TokenID) then
          FKeyTokenList.Add(PasParser.Tokens[I]);
    end
    else if (BlockHighlightRange = brInnerBlock) and Assigned(PasParser.InnerBlockStartToken)
      and Assigned(PasParser.InnerBlockCloseToken) then
    begin
      for I := PasParser.InnerBlockStartToken.ItemIndex to
        PasParser.InnerBlockCloseToken.ItemIndex do
        if IsHighlightKeywords(PasParser.Tokens[I].TokenID) then
          FKeyTokenList.Add(PasParser.Tokens[I]);
    end;

    UpdateCurTokenList;
    UpdateFlowTokenList;
    UpdateCompDirectiveList;
    FCurrentBlockSearched := False;

  {$IFDEF DEBUG}
    CnDebugger.LogInteger(FKeyTokenList.Count, 'HighLight Pas KeyList Count.');
  {$ENDIF}
    Result := (FKeyTokenList.Count > 0) or (FCompDirectiveTokenList.Count > 0);

    if Result then
    begin
      for I := 0 to KeyCount - 1 do
      begin
        // ת���� Col �� Line
{$IFNDEF BDS2009_UP}
        CharPos := OTACharPos(KeyTokens[I].CharIndex, KeyTokens[I].LineNumber + 1);
        EditView.ConvertPos(False, EditPos, CharPos);
        // TODO: ��������� D2009 �д�����ʱ�������ƫ����ް취��
        // ���ֱ�Ӳ������� CharIndex + 1 �ķ�ʽ��Parser �����Ѷ� Tab ��չ����
{$ELSE}
        EditPos.Line := KeyTokens[I].LineNumber + 1;
        EditPos.Col := KeyTokens[I].CharIndex + 1;
{$ENDIF}
        KeyTokens[I].EditCol := EditPos.Col;
        KeyTokens[I].EditLine := EditPos.Line;
      end;
      ConvertLineList;
    end;

    if FHighlight.FHilightSeparateLine then
    begin
      UpdateSeparateLineList;
{$IFDEF DEBUG}
      CnDebugger.LogInteger(FSeparateLineList.Count, 'FSeparateLineList.Count');
{$ENDIF}
    end;

    if LineInfo <> nil then
    begin
      CheckLineMatch(EditView, GlobalIgnoreClass);
    {$IFDEF DEBUG}
      CnDebugger.LogInteger(LineInfo.Count, 'HighLight Pas LinePairs Count.');
    {$ENDIF}
    end;

    if CompDirectiveInfo <> nil then
    begin
      CheckCompDirectiveMatch(EditView, GlobalIgnoreClass);
    {$IFDEF DEBUG}
      CnDebugger.LogInteger(CompDirectiveInfo.Count, 'HighLight Pas CompDirectivePairs Count.');
    {$ENDIF}
    end;
  end;

  try
    Control.Invalidate;
  except
    ;
  end;

  Changed := False;
  Modified := False;
end;

procedure TBlockMatchInfo.UpdateSeparateLineList;
var
  MaxLine, I, J, LastSepLine: Integer;
  Line: string;
begin
  MaxLine := 0;
  for I := 0 to FKeyTokenList.Count - 1 do
  begin
    if KeyTokens[I].EditLine > MaxLine then
      MaxLine := KeyTokens[I].EditLine;
  end;
  FSeparateLineList.Count := MaxLine + 1;

  LastSepLine := 1;
  for I := 0 to FKeyTokenList.Count - 1 do
  begin
    if KeyTokens[I].IsMethodStart then
    begin
      // �� LastSepLine ���� Token ǰһ�����ҵ�һ�����б��
      if LastSepLine > 1 then
      begin
        for J := LastSepLine to KeyTokens[I].EditLine do
        begin
          Line := Trim(EditControlWrapper.GetTextAtLine(Control, J));
          if Line = '' then
          begin
            FSeparateLineList[J] := Pointer(CN_LINE_SEPARATE_FLAG);
            Break;
          end;
        end;
      end;
    end
    else if KeyTokens[I].IsMethodClose then
    begin
      // �� LastLine ���� Token ǰһ�����������
      LastSepLine := KeyTokens[I].EditLine + 1;
    end;
  end;
end;

procedure TBlockMatchInfo.UpdateFlowTokenList;
var
  EditView: IOTAEditView;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  I: Integer;
begin
  FCurMethodStartToken := nil;
  FCurMethodCloseToken := nil;

  if FControl = nil then Exit;

  try
    EditView := EditControlWrapper.GetEditView(FControl);
  except
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('GetEditView error');
  {$ENDIF}
    Exit;
  end;

  if EditView = nil then
    Exit;

  FFlowTokenList.Clear;
  if not FIsCppSource then
  begin
    if Assigned(PasParser) then
    begin
      if not FCurrentBlockSearched then   // �ҵ�ǰ�飬��ת��Tokenλ��
      begin
        EditPos := EditView.CursorPos;
        EditView.ConvertPos(True, EditPos, CharPos);
        PasParser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);
      end;

{$IFDEF DEBUG}
      if Assigned(PasParser.MethodStartToken) and
        Assigned(PasParser.MethodCloseToken) then
        CnDebugger.LogFmt('CurrentMethod: %s, MethodStartToken: %d, MethodCloseToken: %d',
          [PasParser.CurrentMethod, PasParser.MethodStartToken.ItemIndex, PasParser.MethodCloseToken.ItemIndex]);
{$ENDIF}

      if Assigned(PasParser.MethodStartToken) and
        Assigned(PasParser.MethodCloseToken) then
      begin
        FCurMethodStartToken := PasParser.MethodStartToken;
        FCurMethodCloseToken := PasParser.MethodCloseToken;
      end;

      // �޵�ǰ���̻������������ʱ������ǰ���б�ʶ��������ֻ���������ڵ�ǰ�����ڵ�����
      for I := 0 to PasParser.Count - 1 do
      begin
        CharPos := OTACharPos(PasParser.Tokens[I].CharIndex, PasParser.Tokens[I].LineNumber + 1);
        EditView.ConvertPos(False, EditPos, CharPos);
        // TODO: ��������� D2009 �д�����ʱ�������ƫ����ް취��ֻ�ܰ���������
{$IFDEF BDS2009_UP}
        // if not FHighlight.FUseTabKey then
        EditPos.Col := PasParser.Tokens[I].CharIndex + 1;
{$ENDIF}
        PasParser.Tokens[I].EditCol := EditPos.Col;
        PasParser.Tokens[I].EditLine := EditPos.Line;
      end;

      // ����������Ԫʱ����ǰ�޿�ʱ������������Ԫ
      if (FCurMethodStartToken = nil) or (FCurMethodCloseToken = nil) or
        (FHighlight.BlockHighlightRange = brAll) then
      begin
        for I := 0 to PasParser.Count - 1 do
        begin
          if CheckIsFlowToken(PasParser.Tokens[I], FIsCppSource) then
            FFlowTokenList.Add(PasParser.Tokens[I]);
        end;
      end
      else if (FCurMethodStartToken <> nil) or (FCurMethodCloseToken <> nil) then // ������Χ��Ĭ�ϸ�Ϊ���������̵�
      begin
        for I := FCurMethodStartToken.ItemIndex to FCurMethodCloseToken.ItemIndex do
        begin
          if CheckIsFlowToken(PasParser.Tokens[I], FIsCppSource) then
            FFlowTokenList.Add(PasParser.Tokens[I]);
        end;
      end;
    end;

    FFlowLineList.Clear;
    ConvertFlowLineList;
  end
  else // �� C/C++ �еĵ�ǰ���������������̵ı�ʶ����������
  begin
    // Ϊ�˼��ٴ����ع��Ĺ��������˴� C/C++ �е�ǰ�������ı�ʶ�����Ծ���
    // TCnPasToken ����ʾ������ FFlowTokenList �У����� Pascal ������ص�����
    // ����Ч��ֻ�� Token ����λ�õ���Ч����� C/C++ �ĸ������̿��Ʋ�֧�ַ�Χ����

    // �������������̿��Ƶ�Token ����Χ�涨���� FFlowTokenList
    for I := 0 to CppParser.Count - 1 do
    begin
      CharPos := OTACharPos(CppParser.Tokens[I].CharIndex - 1, CppParser.Tokens[I].LineNumber);
      // �˴� LineNumber �����һ�ˣ���Ϊ mwBCBTokenList �еĴ������Ǵ� 1 ��ʼ��
      // ���� CharIndex �ü�һ
      EditView.ConvertPos(False, EditPos, CharPos);
      CppParser.Tokens[I].EditCol := EditPos.Col;
      CppParser.Tokens[I].EditLine := EditPos.Line;
    end;

{$IFDEF DEBUG}
    CnDebugger.LogFmt('CppParser.Count: %d', [CppParser.Count]);
{$ENDIF}
    if (FHighlight.BlockHighlightRange in [brMethod, brWholeBlock])
      and Assigned(CppParser.BlockStartToken) and Assigned(CppParser.BlockCloseToken) then
    begin
      for I := CppParser.BlockStartToken.ItemIndex to CppParser.BlockCloseToken.ItemIndex do
      begin
        if CheckIsFlowToken(CppParser.Tokens[I], FIsCppSource) then
          FFlowTokenList.Add(CppParser.Tokens[I]);
      end;
    end
    else if (FHighlight.BlockHighlightRange in [brInnerBlock])
      and Assigned(CppParser.InnerBlockStartToken) and Assigned(CppParser.InnerBlockCloseToken) then
    begin
      for I := CppParser.InnerBlockStartToken.ItemIndex to CppParser.InnerBlockCloseToken.ItemIndex do
      begin
        if CheckIsFlowToken(CppParser.Tokens[I], FIsCppSource) then
          FFlowTokenList.Add(CppParser.Tokens[I]);
      end;
    end
    else // ������Χ
    begin
      for I := 0 to CppParser.Count - 1 do
      begin
        if CheckIsFlowToken(CppParser.Tokens[I], FIsCppSource) then
          FFlowTokenList.Add(CppParser.Tokens[I]);
      end;
    end;

    FFlowLineList.Clear;
    ConvertFlowLineList;
  end;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('FFlowTokenList.Count: %d', [FFlowTokenList.Count]);
{$ENDIF}

  for I := 0 to FFlowTokenList.Count - 1 do
    FHighLight.EditorMarkLineDirty(TCnPasToken(FFlowTokenList[I]).EditLine);
end;

procedure TBlockMatchInfo.UpdateCurTokenList;
var
  EditView: IOTAEditView;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  I, TokenCursorIndex, StartIndex, EndIndex: Integer;
  TmpCurTokenStr: string;
  AToken: TCnPasToken;
begin
  FCurrentTokenName := '';
  FCurrentToken := nil;
  FCurMethodStartToken := nil;
  FCurMethodCloseToken := nil;

  if FControl = nil then Exit;

  try
    EditView := EditControlWrapper.GetEditView(FControl);
  except
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('GetEditView error');
  {$ENDIF}
    Exit;
  end;

  if EditView = nil then
    Exit;

  for I := 0 to FCurTokenList.Count - 1 do
    FHighLight.EditorMarkLineDirty(Integer(FCurTokenListEditLine[I]));

  FCurTokenList.Clear;
  FCurTokenListEditLine.Clear;
  FCurTokenListEditCol.Clear;
  if not FIsCppSource then
  begin
    if Assigned(PasParser) then
    begin
      if not FCurrentBlockSearched then
      begin
        EditPos := EditView.CursorPos;
        EditView.ConvertPos(True, EditPos, CharPos);
        PasParser.FindCurrentBlock(CharPos.Line, CharPos.CharIndex);
      end;

{$IFDEF DEBUG}
      if Assigned(PasParser.MethodStartToken) and
        Assigned(PasParser.MethodCloseToken) then
        CnDebugger.LogFmt('CurrentMethod: %s, MethodStartToken: %d, MethodCloseToken: %d',
          [PasParser.CurrentMethod, PasParser.MethodStartToken.ItemIndex, PasParser.MethodCloseToken.ItemIndex]);
{$ENDIF}

      if Assigned(PasParser.MethodStartToken) and
        Assigned(PasParser.MethodCloseToken) then
      begin
        FCurMethodStartToken := PasParser.MethodStartToken;
        FCurMethodCloseToken := PasParser.MethodCloseToken;
      end;

      CnOtaGetCurrPosToken(TmpCurTokenStr, TokenCursorIndex, True, [], [], EditView);
      FCurrentTokenName := AnsiString(TmpCurTokenStr);

      if FCurrentTokenName <> '' then
      begin
        StartIndex := 0;
        EndIndex := PasParser.Count - 1;

        // ����������Ԫʱ����ǰ�ǹ�����������ʱ�����޵�ǰMethodʱ������������Ԫ
        if (FHighlight.BlockHighlightRange = brAll)
          or TokenIsMethodOrClassName(string(FCurrentTokenName), string(PasParser.CurrentMethod))
          or ((FCurMethodStartToken = nil) or (FCurMethodCloseToken = nil)) then
        begin
//          StartIndex := 0;
//          EndIndex := Parser.Count - 1;
        end
        else if (FCurMethodStartToken <> nil) or (FCurMethodCloseToken <> nil) then // ������Χ��Ĭ�ϸ�Ϊ���������̵�
        begin
          StartIndex := FCurMethodStartToken.ItemIndex;
          EndIndex := FCurMethodCloseToken.ItemIndex;
        end;

        // ����������ǰ���б�ʶ��������ֻ���������ڵ�ǰ�����ڵ�����
        for I := StartIndex to EndIndex do
        begin
          AToken := PasParser.Tokens[I];
          if (AToken.TokenID = tkIdentifier) and // �˴��жϲ�֧��˫�ֽ��ַ�
            CheckTokenMatch(AToken.Token, FCurrentTokenName, CaseSensitive) then
          begin
            CharPos := OTACharPos(AToken.CharIndex, AToken.LineNumber + 1);
            EditView.ConvertPos(False, EditPos, CharPos);
            // TODO: ��������� D2009 �д�����ʱ�������ƫ����ް취��ֻ�ܰ���������
    {$IFDEF BDS2009_UP}
            // if not FHighlight.FUseTabKey then
            EditPos.Col := AToken.CharIndex + 1;
    {$ENDIF}
            AToken.EditCol := EditPos.Col;
            AToken.EditLine := EditPos.Line;

            FCurTokenList.Add(AToken);
            FCurTokenListEditLine.Add(Pointer(AToken.EditLine));
            if FHighlight.ShowTokenPosAtGutter then
              FCurTokenListEditCol.Add(Pointer(AToken.EditCol));
          end;
        end;

        if FCurTokenList.Count > 0 then
          FCurrentToken := FCurTokenList.Items[0];
      end;
    end;

    FIdLineList.Clear;
    ConvertIdLineList;
  end
  else // �� C/C++ �еĵ�ǰ����������ͬ�ı�ʶ����������
  begin
    // Ϊ�˼��ٴ����ع��Ĺ��������˴� C/C++ �е�ǰ�������ı�ʶ�����Ծ���
    // TCnPasToken ����ʾ������ FCurTokenList �У����� Pascal ������ص�����
    // ����Ч��ֻ�� Token ����λ�õ���Ч����� C/C++ �ĸ�����ʶ����֧�ַ�Χ����

    CnOtaGetCurrPosToken(TmpCurTokenStr, TokenCursorIndex, True, [], [], EditView);
    FCurrentTokenName := AnsiString(TmpCurTokenStr);

    if FCurrentTokenName <> '' then
    begin
      StartIndex := 0;
      EndIndex := CppParser.Count - 1;

      if (FHighlight.BlockHighlightRange in [brMethod, brWholeBlock])
        and Assigned(CppParser.BlockStartToken) and Assigned(CppParser.BlockCloseToken) then
      begin
        StartIndex := CppParser.BlockStartToken.ItemIndex;
        EndIndex := CppParser.BlockCloseToken.ItemIndex;
      end
      else if (FHighlight.BlockHighlightRange in [brInnerBlock])
        and Assigned(CppParser.InnerBlockStartToken) and Assigned(CppParser.InnerBlockCloseToken) then
      begin
        StartIndex := CppParser.InnerBlockStartToken.ItemIndex;
        EndIndex := CppParser.InnerBlockCloseToken.ItemIndex;
      end;

      // ����������ͬ�� Token ����Χ�涨���� FCurTokenList
      for I := StartIndex to EndIndex do
      begin
        AToken := CppParser.Tokens[I];
        if (AToken.CppTokenKind = ctkIdentifier) and
          CheckTokenMatch(AToken.Token, FCurrentTokenName, CaseSensitive) then
        begin
          CharPos := OTACharPos(AToken.CharIndex - 1, AToken.LineNumber);
          // �˴� LineNumber �����һ�ˣ���Ϊ mwBCBTokenList �еĴ������Ǵ� 1 ��ʼ��
          // ���� CharIndex �ü�һ
          EditView.ConvertPos(False, EditPos, CharPos);

          // DONE: ������䱾Ӧ�� D2009 ʱ�������޸���
          // ������C/C++�ļ���Tab������ʱ������¸����޷���ʾ���ʴ��Ƚ���
      {$IFDEF BDS2009_UP}
          // if not FHighlight.FUseTabKey then
          // EditPos.Col := AToken.CharIndex;
      {$ENDIF}
          AToken.EditCol := EditPos.Col;
          AToken.EditLine := EditPos.Line;

          FCurTokenList.Add(AToken);
          FCurTokenListEditLine.Add(Pointer(AToken.EditLine));
          if FHighlight.ShowTokenPosAtGutter then
              FCurTokenListEditCol.Add(Pointer(AToken.EditCol));
        end;
      end;
    end;

    FIdLineList.Clear;
    ConvertIdLineList;
  end;

  // ����緢�ͱ�ʶ����������Ϣ�ĸ���֪ͨ
  if FHighlight.ShowTokenPosAtGutter then
  begin
    EventBus.PostEvent(EVENT_HIGHLIGHT_IDENT_POSITION, FCurTokenListEditLine,
      FCurTokenListEditCol);
  end;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('FCurTokenList.Count: %d; FCurrentTokenName: %s',
    [FCurTokenList.Count, FCurrentTokenName]);
{$ENDIF}

  for I := 0 to FCurTokenList.Count - 1 do
    FHighLight.EditorMarkLineDirty(TCnPasToken(FCurTokenList[I]).EditLine);
end;

procedure TBlockMatchInfo.UpdateCompDirectiveList;
var
  EditView: IOTAEditView;
  CharPos: TOTACharPos;
  EditPos: TOTAEditPos;
  I: Integer;
begin
  if FControl = nil then Exit;

  try
    EditView := EditControlWrapper.GetEditView(FControl);
  except
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('GetEditView error');
  {$ENDIF}
    Exit;
  end;

  if EditView = nil then
    Exit;

  FCompDirectiveTokenList.Clear;
  if not FIsCppSource then
  begin
    if Assigned(PasParser) then
    begin
{$IFDEF DEBUG}
//    CnDebugger.LogFmt('UpdateCompDirectiveList.Count: %d', [Parser.Count]);
{$ENDIF}
      for I := 0 to PasParser.Count - 1 do // ����ָ��ֱ�����������Ԫ
      begin
        if not CheckIsCompDirectiveToken(PasParser.Tokens[I], FIsCppSource) then
          Continue;

{$IFNDEF BDS2009_UP}
        CharPos := OTACharPos(PasParser.Tokens[I].CharIndex, PasParser.Tokens[I].LineNumber + 1);
        EditView.ConvertPos(False, EditPos, CharPos);
        // ��������� D2009 �д�����ʱ�������ƫ����ް취��ֻ�ܰ���������
{$ELSE}
        EditPos.Line := PasParser.Tokens[I].LineNumber + 1;
        EditPos.Col := PasParser.Tokens[I].CharIndex + 1;
{$ENDIF}
        PasParser.Tokens[I].EditCol := EditPos.Col;
        PasParser.Tokens[I].EditLine := EditPos.Line;

        FCompDirectiveTokenList.Add(PasParser.Tokens[I]);
      end;
    end;
  end
  else // �� C/C++ �еĵ�ǰ������������ָ���������
  begin
    // Ϊ�˼��ٴ����ع��Ĺ��������˴� C/C++ �е�ǰ�������ı�ʶ�����Ծ���
    // TCnPasToken ����ʾ������ FCompDirectiveTokenList �У����� Pascal ������ص�����
    // ����Ч��ֻ�� Token ����λ�õ���Ч��

    // �������������������Token ����Χ�涨���� FCompDirectiveTokenList
    for I := 0 to CppParser.Count - 1 do
    begin
      if not CheckIsCompDirectiveToken(CppParser.Tokens[I], FIsCppSource) then
        Continue;

      CharPos := OTACharPos(CppParser.Tokens[I].CharIndex - 1, CppParser.Tokens[I].LineNumber);
      // �˴� LineNumber �����һ�ˣ���Ϊ mwBCBTokenList �еĴ������Ǵ� 1 ��ʼ��
      // ���� CharIndex �ü�һ
      EditView.ConvertPos(False, EditPos, CharPos);
      CppParser.Tokens[I].EditCol := EditPos.Col;
      CppParser.Tokens[I].EditLine := EditPos.Line;

      FCompDirectiveTokenList.Add(CppParser.Tokens[I]);
    end;
  end;

  FCompDirectiveLineList.Clear;
  ConvertCompDirectiveLineList;

{$IFDEF DEBUG}
  CnDebugger.LogFmt('FCompDirectiveTokenList.Count: %d', [FCompDirectiveTokenList.Count]);
{$ENDIF}

  for I := 0 to FCompDirectiveTokenList.Count - 1 do
    FHighLight.EditorMarkLineDirty(TCnPasToken(FCompDirectiveTokenList[I]).EditLine);
end;

procedure TBlockMatchInfo.CheckLineMatch(View: IOTAEditView; IgnoreClass: Boolean);
var
  I: Integer;
  Pair, PrevPair, IfThenPair: TBlockLinePair;
  Token: TCnPasToken;
  CToken: TCnCppToken;
  IfThenSameLine, Added: Boolean;
begin
  if (LineInfo <> nil) and (FKeyTokenList.Count > 1) then
  begin
    // ���� KeyList �е����ݲ��������Ϣд�� LineInfo ��
    LineInfo.Clear;
    if FIsCppSource then // C/C++ �Ĵ�������ԣ��Ƚϼ�
    begin
      try
        for I := 0 to FKeyTokenList.Count - 1 do
        begin
          CToken := TCnCppToken(FKeyTokenList[I]);
          if CToken.CppTokenKind = ctkbraceopen then
          begin
            Pair := TBlockLinePair.Create;
            Pair.StartToken := CToken;
            Pair.Top := CToken.EditLine;
            Pair.StartLeft := CToken.EditCol;
            Pair.Left := CToken.EditCol;
            Pair.Layer := CToken.ItemLayer - 1;

            FStack.Push(Pair);
          end
          else if CToken.CppTokenKind = ctkbraceclose then
          begin
            if FStack.Count = 0 then
              Continue;

            Pair := TBlockLinePair(FStack.Pop);

            Pair.EndToken := CToken;
            Pair.EndLeft := CToken.EditCol;
            if Pair.Left > CToken.EditCol then // Left ȡ���߼��С��
              Pair.Left := CToken.EditCol;
            Pair.Bottom := CToken.EditLine;

            LineInfo.AddPair(Pair);
          end;
        end;
        LineInfo.ConvertLineList;
        LineInfo.FindCurrentPair(View, FIsCppSource);
      finally
        for I := 0 to FStack.Count - 1 do
          TBlockLinePair(FStack.Pop).Free;
      end;
    end
    else // Pascal ���﷨��Դ������ӵö�
    begin
      try
        for I := 0 to FKeyTokenList.Count - 1 do
        begin
          Token := TCnPasToken(FKeyTokenList[I]);
          if Token.IsBlockStart then
          begin
            Pair := TBlockLinePair.Create;
            Pair.StartToken := Token;
            Pair.Top := Token.EditLine;
            Pair.StartLeft := Token.EditCol;
            Pair.Left := Token.EditCol;
            Pair.Layer := Token.MethodLayer + Token.ItemLayer - 2;

            FStack.Push(Pair);
          end
          else if Token.IsBlockClose then
          begin
            if FStack.Count = 0 then
              Continue;

            Pair := TBlockLinePair(FStack.Pop);

            Pair.EndToken := Token;
            Pair.EndLeft := Token.EditCol;
            if Pair.Left > Token.EditCol then // Left ȡ���߼��С��
              Pair.Left := Token.EditCol;
            Pair.Bottom := Token.EditLine;

  {$IFDEF DEBUG}
  //          CnDebugger.LogFmt('Highlight Pair start %d %s meet end %d %s. Ignore: %d',
  //            [Ord(Pair.StartToken.TokenID), Pair.StartToken.Token,
  //             Ord(Pair.EndToken.TokenID), Pair.EndToken.Token, Integer(IgnoreClass)]);
  {$ENDIF}

            if Pair.StartToken.TokenID in [tkClass, tkRecord, tkInterface, tkDispInterface] then
            begin
              if not IgnoreClass then // ���� class record interface ʱ����Ҫ������ӽ�ȥ
                LineInfo.AddPair(Pair)
              else
                Pair.Free;
            end
            else
            begin
              LineInfo.AddPair(Pair);
            
              // �ж��Ѿ��е� if then �飬�籾��α���ף�˵�� if then ���Ѿ���������Ҫ�޳�
              while FIfThenStack.Count > 0 do
              begin
                IfThenPair := TBlockLinePair(FIfThenStack.Peek);
                if IfThenPair.Layer > Pair.Layer then
                  FIfThenStack.Pop
                else
                  Break;
              end;  

              if (Pair.StartToken.TokenID = tkIf) and (Pair.EndToken.TokenID = tkThen) then
                FIfThenStack.Push(Pair);
              if (Pair.StartToken.TokenID = tkOn) and (Pair.EndToken.TokenID = tkDo) then
                FIfThenStack.Push(Pair);
              // ����if then �飬�ú���� else ���䡣ע��ͬʱҲ���� on Exception do ��
            end;
          end
          else
          begin
            Added := False;
            if Token.TokenID in [tkElse, tkExcept, tkFinally, tkOf] then
            begin
              // �������м��������������
              if FStack.Count > 0 then
              begin
                Pair := TBlockLinePair(FStack.Peek);
                if Pair <> nil then
                begin
                  if Pair.Layer = Token.MethodLayer + Token.ItemLayer - 2 then
                  begin
                    // ͬһ��εģ����� MidToken
                    Pair.AddMidToken(Token, Token.EditCol);
                    Added := Token.TokenID <> tkExcept;
                  end;
                end;
              end;
            end;

            if not Added and (Token.TokenID = tkElse) and (FIfThenStack.Count > 0) then
            begin
              // �� Else ��������û������Ļ����������һ��ͬ��� if then ��������ԣ�������߲��
              Pair := TBlockLinePair(FIfThenStack.Pop);
              while (FIfThenStack.Count > 0) and (Pair <> nil) and
                (Pair.Layer > Token.MethodLayer + Token.ItemLayer - 2) do
              begin
                Pair := TBlockLinePair(FIfThenStack.Pop);
              end;

              if (Pair <> nil) and (Pair.Layer = Token.MethodLayer + Token.ItemLayer - 2) then
              begin
                IfThenSameLine := Pair.StartToken.EditLine = Pair.EndToken.EditLine;
                Pair.AddMidToken(Pair.EndToken, Pair.EndToken.EditCol);

                Pair.EndToken := Token;
                Pair.EndLeft := Token.EditCol;
                if Pair.Left > Token.EditCol then // Left ȡ���߼��С��
                  Pair.Left := Token.EditCol;
                Pair.Bottom := Token.EditLine;

                // ���������Ϻ󣬼�� else ǰ��һ�� begin end ��
                // ������� if then ͬ�У����Һ�ǰһ�� begin end ������ͬ��
                // ��ô��������߾Ͳ���Ҫ����
                if IfThenSameLine and (LineInfo.Count > 0) then
                begin
                  PrevPair := LineInfo.Pairs[LineInfo.Count - 1];
                  if (PrevPair <> Pair) and (PrevPair.Left = Pair.Left) and (PrevPair.Bottom - PrevPair.Top > 1)
                    and (PrevPair.Top >= Pair.Top) and (PrevPair.Bottom <= Pair.Bottom) then
                  begin
                    Pair.DontDrawVert := True;
                  end;
                end;
              end;
            end;
          end;
        end;
        LineInfo.ConvertLineList;
        LineInfo.FindCurrentPair(View, FIsCppSource);
      finally
        for I := 0 to FIfThenStack.Count - 1 do
          FIfThenStack.Pop;
        for I := 0 to FStack.Count - 1 do
          TBlockLinePair(FStack.Pop).Free;
      end;
    end;
  end;
end;

procedure TBlockMatchInfo.CheckCompDirectiveMatch(View: IOTAEditView;
  IgnoreClass: Boolean);
var
  I: Integer;
  PToken: TCnPasToken;
  CToken: TCnCppToken;
  Pair: TCompDirectivePair;
begin
  if (CompDirectiveInfo = nil) or (FCompDirectiveTokenList.Count <= 1) then
    Exit;

  CompDirectiveInfo.Clear;
  if FIsCppSource then
  begin
    // C ���룬if/ifdef/ifndef �� endif ��ԣ�else/elif ���м�
    try
      for I := 0 to FCompDirectiveTokenList.Count - 1 do
      begin
        CToken := TCnCppToken(FCompDirectiveTokenList[I]);
{$IFDEF DEBUG}
//      CnDebugger.LogFmt('CompDirectiveInfo Check CompDirectivtType: %d', [Ord(CToken.CppTokenKind)]);
{$ENDIF}
        if CToken.CppTokenKind in [ctkdirif, ctkdirifdef, ctkdirifndef] then
        begin
          Pair := TCompDirectivePair.Create;
          Pair.StartToken := CToken;
          Pair.Top := CToken.EditLine;
          Pair.StartLeft := CToken.EditCol;
          Pair.Left := CToken.EditCol;
          Pair.Layer := CToken.ItemLayer - 1;

          FStack.Push(Pair);
        end
        else if CToken.CppTokenKind in [ctkdirelse, ctkdirelif] then
        begin
          if FStack.Count > 0 then
          begin
            Pair := TCompDirectivePair(FStack.Peek);
            if Pair <> nil then
              Pair.AddMidToken(CToken, CToken.EditCol);
          end;
        end
        else if CToken.CppTokenKind = ctkdirendif then
        begin
          if FStack.Count = 0 then
            Continue;

          Pair := TCompDirectivePair(FStack.Pop);

          Pair.EndToken := CToken;
          Pair.EndLeft := CToken.EditCol;
          if Pair.Left > CToken.EditCol then // Left ȡ���߼��С��
            Pair.Left := CToken.EditCol;
          Pair.Bottom := CToken.EditLine;

          CompDirectiveInfo.AddPair(Pair);
        end;
      end;
      CompDirectiveInfo.ConvertLineList;
      CompDirectiveInfo.FindCurrentPair(View, FIsCppSource);
    finally
      for I := 0 to FStack.Count - 1 do
        TCompDirectivePair(FStack.Pop).Free;
    end;
  end
  else
  begin
    // Pascal ���룬IF/IFDEF/IFNDEF �� ENDIF/IFEND ��ԣ�ELSE ���м�
    try
      for I := 0 to FCompDirectiveTokenList.Count - 1 do
      begin
        PToken := TCnPasToken(FCompDirectiveTokenList[I]);
{$IFDEF DEBUG}
//      CnDebugger.LogFmt('CompDirectiveInfo Check CompDirectivtType: %d', [Ord(PToken.CompDirectivtType)]);
{$ENDIF}
        if PToken.CompDirectivtType in [ctIf, ctIfDef, ctIfNDef] then
        begin
          Pair := TCompDirectivePair.Create;
          Pair.StartToken := PToken;
          Pair.Top := PToken.EditLine;
          Pair.StartLeft := PToken.EditCol;
          Pair.Left := PToken.EditCol;
          Pair.Layer := PToken.ItemLayer - 1;

          FStack.Push(Pair);
        end
        else if PToken.CompDirectivtType = ctElse then
        begin
          if FStack.Count > 0 then
          begin
            Pair := TCompDirectivePair(FStack.Peek);
            if Pair <> nil then
              Pair.AddMidToken(PToken, PToken.EditCol);
          end;
        end
        else if PToken.CompDirectivtType in [ctEndIf, ctIfEnd] then
        begin
          if FStack.Count = 0 then
            Continue;

          Pair := TCompDirectivePair(FStack.Pop);

          Pair.EndToken := PToken;
          Pair.EndLeft := PToken.EditCol;
          if Pair.Left > PToken.EditCol then // Left ȡ���߼��С��
            Pair.Left := PToken.EditCol;
          Pair.Bottom := PToken.EditLine;

          CompDirectiveInfo.AddPair(Pair);
        end;
      end;
      CompDirectiveInfo.ConvertLineList;
      CompDirectiveInfo.FindCurrentPair(View, FIsCppSource);
    finally
      for I := 0 to FStack.Count - 1 do
        TCompDirectivePair(FStack.Pop).Free;
    end;
  end;
{$IFDEF DEBUG}
//  CnDebugger.LogFmt('CompDirectiveInfo Pair Count: %d', [CompDirectiveInfo.Count]);
{$ENDIF}
end;

procedure TBlockMatchInfo.Clear;
begin
  FKeyTokenList.Clear;
  FCurTokenList.Clear;
  FCurTokenListEditLine.Clear;
  FCurTokenListEditCol.Clear;
  FFlowTokenList.Clear;
  FCompDirectiveTokenList.Clear;

  FKeyLineList.Clear;
  FIdLineList.Clear;
  FFlowLineList.Clear;
  FSeparateLineList.Clear;
  FCompDirectiveLineList.Clear;

  if LineInfo <> nil then
    LineInfo.Clear;
  if CompDirectiveInfo <> nil then
    CompDirectiveInfo.Clear;
end;

procedure TBlockMatchInfo.AddToKeyList(AToken: TCnPasToken);
begin
  FKeyTokenList.Add(AToken);
end;

procedure TBlockMatchInfo.AddToCurrList(AToken: TCnPasToken);
begin
  FCurTokenList.Add(AToken);
end;

procedure TBlockMatchInfo.AddToFlowList(AToken: TCnPasToken);
begin
  FFlowTokenList.Add(AToken);
end;

procedure TBlockMatchInfo.AddToCompDirectiveList(AToken: TCnPasToken);
begin
  FCompDirectiveTokenList.Add(AToken);
end;

constructor TBlockMatchInfo.Create(AControl: TControl);
begin
  inherited Create;
  FControl := AControl;
  FPasParser := TCnPasStructureParser.Create;
  FPasParser.UseTabKey := True;
  FCppParser := TCnCppStructureParser.Create;

  FKeyTokenList := TCnList.Create;
  FCurTokenList := TCnList.Create;
  FCurTokenListEditLine := TCnList.Create;
  FCurTokenListEditCol := TCnList.Create;
  FFlowTokenList := TCnList.Create;
  FCompDirectiveTokenList := TCnList.Create;

  FKeyLineList := TCnObjectList.Create;
  FIdLineList := TCnObjectList.Create;
  FFlowLineList := TCnObjectList.Create;
  FSeparateLineList := TCnList.Create;
  FCompDirectiveLineList := TCnObjectList.Create;
  
  FStack := TStack.Create;
  FIfThenStack := TStack.Create;

  FModified := True;
  FChanged := True;
end;

destructor TBlockMatchInfo.Destroy;
begin
  Clear;
  FStack.Free;
  FIfThenStack.Free;

  FKeyLineList.Free;
  FIdLineList.Free;
  FFlowLineList.Free;
  FCompDirectiveLineList.Free;
  FSeparateLineList.Free;
  
  FCompDirectiveTokenList.Free;
  FFlowTokenList.Free;
  FCurTokenListEditLine.Free;
  FCurTokenListEditCol.Free;
  FCurTokenList.Free;
  FKeyTokenList.Free;
  
  FCppParser.Free;
  FPasParser.Free;
  inherited;
end;

function TBlockMatchInfo.GetKeyCount: Integer;
begin
  Result := FKeyTokenList.Count;
end;

function TBlockMatchInfo.GetKeyTokens(Index: Integer): TCnPasToken;
begin
  Result := TCnPasToken(FKeyTokenList[Index]);
end;

function TBlockMatchInfo.GetCurTokens(Index: Integer): TCnPasToken;
begin
  Result := TCnPasToken(FCurTokenList[Index]);
end;

function TBlockMatchInfo.GetCurTokenCount: Integer;
begin
  Result := FCurTokenList.Count;
end;

function TBlockMatchInfo.GetFlowTokenCount: Integer;
begin
  Result := FFlowTokenList.Count;
end;

function TBlockMatchInfo.GetCompDirectiveTokenCount: Integer;
begin
  Result := FCompDirectiveTokenList.Count;
end;

function TBlockMatchInfo.GetFlowTokens(LineNum: Integer): TCnPasToken;
begin
  Result := TCnPasToken(FFlowTokenList[LineNum]);
end;

function TBlockMatchInfo.GetCompDirectiveTokens(
  LineNum: Integer): TCnPasToken;
begin
  Result := TCnPasToken(FCompDirectiveTokenList[LineNum]);
end;

function TBlockMatchInfo.GetLineCount: Integer;
begin
  Result := FKeyLineList.Count;
end;

function TBlockMatchInfo.GetIdLineCount: Integer;
begin
  Result := FIdLineList.Count;
end;

function TBlockMatchInfo.GetFlowLineCount: Integer;
begin
  Result := FFlowLineList.Count;
end;

function TBlockMatchInfo.GetCompDirectiveLineCount: Integer;
begin
  Result := FCompDirectiveLineList.Count;
end;

function TBlockMatchInfo.GetLines(LineNum: Integer): TCnList;
begin
  Result := TCnList(FKeyLineList[LineNum]);
end;

function TBlockMatchInfo.GetIdLines(LineNum: Integer): TCnList;
begin
  Result := TCnList(FIdLineList[LineNum]);
end;

function TBlockMatchInfo.GetFlowLines(LineNum: Integer): TCnList;
begin
  Result := TCnList(FFlowLineList[LineNum]);
end;

function TBlockMatchInfo.GetCompDirectiveLines(LineNum: Integer): TCnList;
begin
  Result := TCnList(FCompDirectiveLineList[LineNum]);
end;

procedure TBlockMatchInfo.ConvertLineList;
var
  I: Integer;
  Token: TCnPasToken;
  MaxLine: Integer;
begin
  MaxLine := 0;
  for I := 0 to FKeyTokenList.Count - 1 do
  begin
    if KeyTokens[I].EditLine > MaxLine then
      MaxLine := KeyTokens[I].EditLine;
  end;
  FKeyLineList.Count := MaxLine + 1;

  for I := 0 to FKeyTokenList.Count - 1 do
  begin
    Token := KeyTokens[I];
    if FKeyLineList[Token.EditLine] = nil then
      FKeyLineList[Token.EditLine] := TCnList.Create;
    TCnList(FKeyLineList[Token.EditLine]).Add(Token);
  end;

  ConvertIdLineList;
end;

procedure TBlockMatchInfo.ConvertIdLineList;
var
  I: Integer;
  Token: TCnPasToken;
  MaxLine: Integer;
begin
  if FHighlight.CurrentTokenHighlight then
  begin
    MaxLine := 0;
    for I := 0 to FCurTokenList.Count - 1 do
      if CurTokens[I].EditLine > MaxLine then
        MaxLine := CurTokens[I].EditLine;
    FIdLineList.Count := MaxLine + 1;

    for I := 0 to FCurTokenList.Count - 1 do
    begin
      Token := CurTokens[I];
      if FIdLineList[Token.EditLine] = nil then
        FIdLineList[Token.EditLine] := TCnList.Create;
      TCnList(FIdLineList[Token.EditLine]).Add(Token);
    end;
  end;
end;

procedure TBlockMatchInfo.ConvertFlowLineList;
var
  I: Integer;
  Token: TCnPasToken;
  MaxLine: Integer;
begin
  MaxLine := 0;
  for I := 0 to FFlowTokenList.Count - 1 do
    if FlowTokens[I].EditLine > MaxLine then
      MaxLine := FlowTokens[I].EditLine;
  FFlowLineList.Count := MaxLine + 1;

  if FHighlight.HighlightFlowStatement then
  begin
    for I := 0 to FFLowTokenList.Count - 1 do
    begin
      Token := FlowTokens[I];
      if FFlowLineList[Token.EditLine] = nil then
        FFlowLineList[Token.EditLine] := TCnList.Create;
      TCnList(FFlowLineList[Token.EditLine]).Add(Token);
    end;
  end;
end;

procedure TBlockMatchInfo.ConvertCompDirectiveLineList;
var
  I: Integer;
  Token: TCnPasToken;
  MaxLine: Integer;
begin
  MaxLine := 0;
  for I := 0 to FCompDirectiveTokenList.Count - 1 do
    if CompDirectiveTokens[I].EditLine > MaxLine then
      MaxLine := CompDirectiveTokens[I].EditLine;
  FCompDirectiveLineList.Count := MaxLine + 1;

  if True then
  begin
    for I := 0 to FCompDirectiveTokenList.Count - 1 do
    begin
      Token := CompDirectiveTokens[I];
      if FCompDirectiveLineList[Token.EditLine] = nil then
        FCompDirectiveLineList[Token.EditLine] := TCnList.Create;
      TCnList(FCompDirectiveLineList[Token.EditLine]).Add(Token);
    end;
  end;
end;

{ TCnSourceHighlight }

constructor TCnSourceHighlight.Create;
begin
  inherited;
  FHighlight := Self;

  FMatchedBracket := True;
  FBracketColor := clBlack;
  FBracketColorBk := clAqua;
  FBracketColorBd := $CCCCD6;
  FBracketBold := False;
  FBracketMiddle := True;
  FBracketList := TObjectList.Create;

  FStructureHighlight := True;
  FBlockMatchHighlight := True;     // Ĭ�ϴ򿪹������ԵĹؼ��ָ���
  FBlockMatchBackground := clYellow; 
{$IFNDEF BDS}
  FHighLightCurrentLine := True;     // Ĭ�ϴ򿪵�ǰ�и���
  FHighLightLineColor := LoadIDEDefaultCurrentColor; // ���ݵ�ǰ��ͬ��ɫ�����������ò�ͬɫ��

  FDefaultHighLightLineColor := FHighLightLineColor; // �����ж��뱣��
{$ENDIF}
  FCurrentTokenHighlight := True;    // Ĭ�ϴ򿪱�ʶ������
  FCurrentTokenDelay := 500;
  FCurrentTokenBackground := csDefCurTokenColorBg;
  FCurrentTokenForeground := csDEfCurTokenColorFg;
  FCurrentTokenBorderColor := csDefCurTokenColorBd;

  FShowTokenPosAtGutter := False; // Ĭ�ϰѱ�ʶ����λ����ʾ���к�����

  FBlockHighlightRange := brAll;
  FBlockMatchDelay := 600;  // Ĭ����ʱ 600 ����
  FBlockHighlightStyle := bsNow;

  FBlockMatchDrawLine := True; // Ĭ�ϻ���
  FBlockMatchLineWidth := 1;
  FBlockMatchLineClass := False;
  FBlockMatchLineHori := True;
  FBlockExtendLeft := True;
  // FBlockMatchLineStyle := lsTinyDot;
  FBlockMatchLineHoriDot := True;

  FKeywordHighlight := THighlightItem.Create;
  FIdentifierHighlight := THighlightItem.Create;
  FCompDirectiveHighlight := THighlightItem.Create;
  FKeywordHighlight.Bold := True;

  FHilightSeparateLine := True;  // Ĭ�ϻ�������Ŀ��зָ���
  FSeparateLineColor := clGray;
  FSeparateLineStyle := lsSmallDot;
  FSeparateLineWidth := 1;

  FHighlightFlowStatement := True; // Ĭ�ϻ�������䱳��
  FFlowStatementBackground := csDefFlowControlBg;
  FFlowStatementForeground := clBlack;

  FHighlightCompDirective := True;    // Ĭ�ϴ򿪹���µı���ָ�������
  FCompDirectiveBackground := csDefaultHighlightBackgroundColor;

  FBlockMatchLineLimit := True;
  FBlockMatchMaxLines := 40000; // ���ڴ������� unit��������
  FBlockMatchList := TObjectList.Create;
  FBlockLineList := TObjectList.Create;
  FCompDirectiveList := TObjectList.Create;
  FLineMapList := TObjectList.Create;
  FViewChangedList := TList.Create;
  FViewFileNameIsPascalList := TList.Create;
{$IFNDEF BDS}
  FCurLineList := TObjectList.Create;
{$ENDIF}
{$IFDEF BDS2009_UP}
  UpdateTabWidth;
{$ENDIF}
  FBlockShortCut := WizShortCutMgr.Add(SCnSourceHighlightBlock, ShortCut(Ord('H'), [ssCtrl, ssShift]),
    OnHighlightExec);
  FStructureTimer := TTimer.Create(nil);
  FStructureTimer.Enabled := False;
  FStructureTimer.Interval := FBlockMatchDelay;
  FStructureTimer.OnTimer := OnHighlightTimer;

  FCurrentTokenValidateTimer := TTimer.Create(nil);
  FCurrentTokenValidateTimer.Enabled := False;
  FCurrentTokenValidateTimer.Interval := FCurrentTokenDelay;
  FCurrentTokenValidateTimer.OnTimer := OnCurrentTokenValidateTimer;

{$IFNDEF BDS}
  FCorIdeModule := LoadLibrary(CorIdeLibName);
  if GetProcAddress(FCorIdeModule, SSetForeAndBackColorName) <> nil then
    SetForeAndBackColor := GetBplMethodAddress(GetProcAddress(FCorIdeModule, SSetForeAndBackColorName));
  Assert(Assigned(SetForeAndBackColor), 'Failed to load SetForeAndBackColor from CorIdeModule');

  SetForeAndBackColorHook := TCnMethodHook.Create(@SetForeAndBackColor,
    @MyEditorsCustomEditControlSetForeAndBackColor);
{$ENDIF}

  EditControlWrapper.AddEditControlNotifier(EditControlNotify);
  EditControlWrapper.AddEditorChangeNotifier(EditorChanged);
  EditControlWrapper.AddAfterPaintLineNotifier(PaintLine);
  EditControlWrapper.AddKeyDownNotifier(EditorKeyDown);
{$IFNDEF BDS}
  EditControlWrapper.AddBeforePaintLineNotifier(BeforePaintLine);
{$ENDIF}
  CnWizNotifierServices.AddActiveFormNotifier(ActiveFormChanged);
  CnWizNotifierServices.AddAfterCompileNotifier(AfterCompile);
  CnWizNotifierServices.AddSourceEditorNotifier(SourceEditorNotify);
end;

destructor TCnSourceHighlight.Destroy;
begin
  FStructureTimer.Free;
  FCurrentTokenValidateTimer.Free;
  FBracketList.Free;
  FCompDirectiveList.Free;
  FBlockLineList.Free;
  FBlockMatchList.Free;
  FLineMapList.Free;
  FKeywordHighlight.Free;
  FIdentifierHighlight.Free;
  FCompDirectiveHighlight.Free;
  FDirtyList.Free;
  FViewFileNameIsPascalList.Free;
  FViewChangedList.Free;
{$IFNDEF BDS}
  FCurLineList.Free;
  SetForeAndBackColorHook.Free;
  if FCorIdeModule <> 0 then
    FreeLibrary(FCorIdeModule);
{$ENDIF}

  WizShortCutMgr.DeleteShortCut(FBlockShortCut);
  CnWizNotifierServices.RemoveSourceEditorNotifier(SourceEditorNotify);
  CnWizNotifierServices.RemoveAfterCompileNotifier(AfterCompile);
  CnWizNotifierServices.RemoveActiveFormNotifier(ActiveFormChanged);
  EditControlWrapper.RemoveEditControlNotifier(EditControlNotify);
  EditControlWrapper.RemoveEditorChangeNotifier(EditorChanged);
  EditControlWrapper.RemoveKeyDownNotifier(EditorKeyDown);
{$IFNDEF BDS}
  EditControlWrapper.RemoveBeforePaintLineNotifier(BeforePaintLine);
{$ENDIF}
  EditControlWrapper.RemoveAfterPaintLineNotifier(PaintLine);
  FHighlight := nil;
  inherited;
end;

procedure TCnSourceHighlight.DoEnhConfig;
begin
  if Assigned(FOnEnhConfig) then
    FOnEnhConfig(Self);
end;

function TCnSourceHighlight.EditorGetTextRect(Editor: TEditorObject;
  APos: TOTAEditPos; const {$IFDEF BDS}LineText, {$ENDIF} AText: string; var ARect: TRect): Boolean;
{$IFDEF BDS}
var
  I, TotalWidth: Integer;
  S: AnsiString;
  UseTab: Boolean;
{$IFDEF BDS}
  UCol: Integer;
{$ENDIF}
{$IFDEF UNICODE}
  U: string;
{$ELSE}
  U: WideString;
{$ENDIF}
  EditCanvas: TCanvas;

  function GetWideCharWidth(AChar: WideChar): Integer;
  begin
    if Integer(AChar) < $80  then
      Result := CharSize.cx
    else
      Result := Round(EditCanvas.TextWidth(AChar) / CharSize.cx) * CharSize.cx;
  end;
{$ENDIF}

begin
  with Editor do
  begin
    if InBound(APos.Line, EditView.TopRow, EditView.BottomRow) and
      InBound(APos.Col, EditView.LeftColumn, EditView.RightColumn) then
    begin
{$IFDEF BDS}
  {$IFDEF BDS2009_UP}
      UseTab := FUseTabKey;
  {$ELSE}
      UseTab := False;
  {$ENDIF}
      if not UseTab then
      begin
        EditCanvas := EditControlWrapper.GetEditControlCanvas(Editor.EditControl);
        TotalWidth := 0;

        if _UNICODE_STRING and CodePageOnlySupportsEnglish then
        begin
          // ��Ӣ��ƽ̨�� D2009 ����ת AnsiString �ᶪ�ַ����¼�����󣬴˴���һ�ַ���
          UCol := CalcWideStringLengthFromAnsiOffset(PWideChar(LineText), APos.Col);
          if UCol > 1 then
          begin
{$IFDEF UNICODE}
            U := Copy(LineText, 1, UCol - 1);
{$ELSE}
            U := WideString(Copy(LineText, 1, UCol - 1));
{$ENDIF}
          end
          else
            U := '';
        end
        else
        begin
          if APos.Col > 1 then
          begin
            S := Copy(AnsiString(LineText), 1, APos.Col - 1)
          end
          else
            S := '';
{$IFDEF UNICODE}
          U := string(S);
{$ELSE}
          U := WideString(S);
{$ENDIF}
        end;

        if U <> '' then
        begin
          // ������¼ÿ���ַ���˫�ֽڣ��Ŀ�Ȳ��ۼ�
          for I := 1 to Length(U) do
            Inc(TotalWidth, GetWideCharWidth(U[I]));

          // Ȼ���ȥ�������ʱ������صĿ��
          if EditView.LeftColumn > 1 then
          begin
            TotalWidth := TotalWidth - (EditView.LeftColumn - 1) * CharSize.cx;
            if TotalWidth < 0 then // ����������̫�࣬����ʾ
            begin
              Result := False;
              Exit;
            end;
          end;
        end;
        ARect := Bounds(GutterWidth + TotalWidth,
          (APos.Line - EditView.TopRow) * CharSize.cy, EditCanvas.TextWidth(AText),
          CharSize.cy);
      end
      else
      begin
        ARect := Bounds(GutterWidth + (APos.Col - EditView.LeftColumn) * CharSize.cx,
          (APos.Line - EditView.TopRow) * CharSize.cy, CharSize.cx * Length(AText),
          CharSize.cy);
      end;
{$ELSE}
      ARect := Bounds(GutterWidth + (APos.Col - EditView.LeftColumn) * CharSize.cx,
        (APos.Line - EditView.TopRow) * CharSize.cy, CharSize.cx * Length(AText),
        CharSize.cy);
{$ENDIF}
      Result := True;
    end
    else
      Result := False;
  end;
end;

procedure TCnSourceHighlight.EditorPaintText(EditControl: TControl; ARect:
  TRect; AText: AnsiString; AColor, AColorBk, AColorBd: TColor; ABold, AItalic,
  AUnderline: Boolean);
var
  SavePenColor, SaveBrushColor, SaveFontColor: TColor;
  SavePenStyle: TPenStyle;
  SaveBrushStyle: TBrushStyle;
  SaveFontStyles: TFontStyles;
  ACanvas: TCanvas;
begin
  ACanvas := EditControlWrapper.GetEditControlCanvas(EditControl);
  if ACanvas = nil then Exit;

  with ACanvas do
  begin
    SavePenColor := Pen.Color;
    SavePenStyle := Pen.Style;
    SaveBrushColor := Brush.Color;
    SaveBrushStyle := Brush.Style;
    SaveFontColor := Font.Color;
    SaveFontStyles := Font.Style;

    // Fill Background
    if AColorBk <> clNone then
    begin
      Brush.Color := AColorBk;
      Brush.Style := bsSolid;
      FillRect(ARect);
    end;

    // Draw Border
    if AColorBd <> clNone then
    begin
      Pen.Color := AColorBd;
      Brush.Style := bsClear;
      Rectangle(ARect);
    end;

    // Draw Text
    Font.Color := AColor;
    Font.Style := [];
    if ABold then
      Font.Style := Font.Style + [fsBold];
    if AItalic then
      Font.Style := Font.Style + [fsItalic];
    if AUnderline then
      Font.Style := Font.Style + [fsUnderline];
    Brush.Style := bsClear;
    TextOut(ARect.Left, ARect.Top, string(AText));

    Pen.Color := SavePenColor;
    Pen.Style := SavePenStyle;
    Brush.Color := SaveBrushColor;
    Brush.Style := SaveBrushStyle;
    Font.Color := SaveFontColor;
    Font.Style := SaveFontStyles;
  end;
end;

//------------------------------------------------------------------------------
// ����ƥ�����
//------------------------------------------------------------------------------

function TCnSourceHighlight.IndexOfBracket(EditControl: TControl): Integer;
var
  i: Integer;
begin
  for i := 0 to FBracketList.Count - 1 do
    if TBracketInfo(FBracketList[i]).Control = EditControl then
    begin
      Result := i;
      Exit;
    end;
  Result := -1;
end;

// ���´���ʹ�� EditControlWrapper.GetTextAtLine ��ȡ��ĳһ�еĴ��룬
// ��Ϊʹ�� EditView.CharPosToPos ת������λ���ڴ��ļ�ʱ����
// ���� GetTextAtLine ȡ�õ��ı��ǽ� Tab ��չ�ɿո�ģ��ʲ���ʹ�� ConvertPos ��ת��
function TCnSourceHighlight.GetBracketMatch(EditView: IOTAEditView;
  EditBuffer: IOTAEditBuffer; EditControl: TControl; AInfo: TBracketInfo):
  Boolean;
var
  i: Integer;
  CL, CR: AnsiChar;
  LText: AnsiString;
  PL, PR: TOTAEditPos;
  CharPos: TOTACharPos;
  BracketCount: Integer;
  BracketChars: PBracketArray;
  TmpPos: TOTAEditPos;
  TmpULine: string;

  function InCommentOrString(APos: TOTAEditPos): Boolean;
  var
    Element, LineFlag: Integer;
  begin
    // IOTAEditView.GetAttributeAtPos �ᵼ��ѡ������ʧЧ��Undo �����ң��ʴ˴�
    // ֱ��ʹ�õײ���á�ע�⣬Unicode ��������� APos �� Col ������ UTF8 �ġ�
    EditControlWrapper.GetAttributeAtPos(EditControl, APos, False, Element, LineFlag);
    Result := (Element = atComment) or (Element = atString) or
      (Element = atCharacter);
  end;

  function ForwardFindMatchToken(const FindToken, MatchToken: AnsiString;
    out ALine: AnsiString): TOTAEditPos;
  var
    I, J, L, Layer: Integer;
    TopLine, BottomLine: Integer;
  {$IFDEF UNICODE}
    ULine: string;
  {$ENDIF}
    LineText: AnsiString;
  begin
    Result.Col := 0;
    Result.Line := 0;

    TopLine := CharPos.Line;
    BottomLine := Min(EditBuffer.GetLinesInBuffer, EditView.BottomRow);
    if TopLine <= BottomLine then
    begin
      Layer := 1;
      for I := TopLine to BottomLine do
      begin
      {$IFDEF BDS}
        if EditControlWrapper.GetLineIsElided(EditControl, I) then
          Continue;
      {$ENDIF}

{$IFDEF UNICODE}
        // Unicode �����±���ѷ��ص� UnicodeString ����ת�� UTF8����Ϊ InCommentOrString ��ʹ�õĵײ����Ҫ����� UTF8
        ULine := EditControlWrapper.GetTextAtLine(EditControl, I);
        LineText := Utf8Encode(ULine); // UTF16 ֱ��ת���� Ansi �� Utf8���м䲻���� AnsiString
{$ELSE}
        LineText := AnsiString(EditControlWrapper.GetTextAtLine(EditControl, I));
{$ENDIF}

        if I = TopLine then
        begin
          L := CharPos.CharIndex + 1;  // �ӹ���һ���ַ���ʼ
{$IFDEF UNICODE}
          // L �� 0 ��ʼ��L + 1 �� CursorPos.Col��Unicode �������� Ansi �ģ���Ҫת�� UTF8 �Է��� LineText �ļ���
          L := ConvertAnsiPositionToUtf8OnUnicodeText(ULine, L + 1) - 1;
{$ENDIF}
        end
        else
          L := 0;

        for J := L to Length(LineText) - 1 do
        begin
          if (LineText[J + 1] = FindToken) and
            not InCommentOrString(OTAEditPos(J + 1, I)) then
          begin
            Inc(Layer);
          end
          else if (LineText[J + 1] = MatchToken) and
            not InCommentOrString(OTAEditPos(J + 1, I)) then
          begin
            Dec(Layer);
            if Layer = 0 then
            begin
              ALine := LineText;
              Result := OTAEditPos(J + 1, I);
{$IFDEF UNICODE}
              // LineText �� Utf8 �ģ�ת�� Ansi��Result �� Utf8 �ģ�ת�� Ansi
              Result.Col := ConvertUtf8PositionToAnsi(LineText, Result.Col);
{$ENDIF}
              Exit;
            end;
          end;
        end;
      end;
    end;
  end;

  function BackFindMatchToken(const FindToken, MatchToken: AnsiString;
    out ALine: AnsiString): TOTAEditPos;
  var
    I, J, L, Layer: Integer;
    TopLine, BottomLine: Integer;
  {$IFDEF UNICODE}
    ULine: string;
  {$ENDIF}
    LineText: AnsiString;
  begin
    Result.Col := 0;
    Result.Line := 0;

    TopLine := EditView.GetTopRow;
    BottomLine := CharPos.Line;
    if TopLine <= BottomLine then
    begin
      Layer := 1;
      for I := BottomLine downto TopLine do
      begin
      {$IFDEF BDS}
        if EditControlWrapper.GetLineIsElided(EditControl, I) then
          Continue;
      {$ENDIF}

{$IFDEF UNICODE}
        // Unicode �����±���ѷ��ص� UnicodeString ����ת�� UTF8����Ϊ InCommentOrString ��ʹ�õĵײ����Ҫ����� UTF8
        ULine := EditControlWrapper.GetTextAtLine(EditControl, I);
        LineText := Utf8Encode(ULine); // UTF16 ֱ��ת���� Ansi �� Utf8���м䲻���� AnsiString
{$ELSE}
        LineText := AnsiString(EditControlWrapper.GetTextAtLine(EditControl, I));
{$ENDIF}

        if I = BottomLine then
        begin
          L := CharPos.CharIndex - 1; // �ӹ��ǰһ���ַ���ʼ
{$IFDEF UNICODE}
          // L �� 0 ��ʼ��L + 1 �� CursorPos.Col��Unicode �������� Ansi �ģ���Ҫת�� UTF8 �Է��� LineText �ļ���
          L := ConvertAnsiPositionToUtf8OnUnicodeText(ULine, L + 1) - 1;
{$ENDIF}
        end
        else
          L := Length(LineText) - 1;

        for J := L downto 0 do
        begin
          if (LineText[J + 1] = FindToken) and
            not InCommentOrString(OTAEditPos(J + 1, I)) then
          begin
            Inc(Layer);
          end
          else if (LineText[J + 1] = MatchToken) and
            not InCommentOrString(OTAEditPos(J + 1, I)) then
          begin
            Dec(Layer);
            if Layer = 0 then
            begin
              ALine := LineText;
              Result := OTAEditPos(J + 1, I);
{$IFDEF UNICODE}
              // LineText �� Utf8 �ģ�ת�� Ansi��Result �� Utf8 �ģ�ת�� Ansi
              Result.Col := ConvertUtf8PositionToAnsi(LineText, Result.Col);
{$ENDIF}
              Exit;
            end;
          end;
        end;
      end;
    end;
  end;

  function FindMatchTokenFromMiddle: Boolean;
  var
    I, J, K, L: Integer;
    ML, MR: Integer;
    TopLine, BottomLine, Cnt: Integer;
    LineText: AnsiString;
    Layers: array of Integer;
  {$IFDEF UNICODE}
    ULine: string;
  {$ENDIF}
  begin
    Result := False;
    SetLength(Layers, BracketCount);
    CharPos.CharIndex := EditView.CursorPos.Col - 1;
    CharPos.Line := EditView.CursorPos.Line;
    TopLine := Min(CharPos.Line, EditView.TopRow);
    BottomLine := Min(EditBuffer.GetLinesInBuffer, Max(CharPos.Line, EditView.BottomRow));
    if TopLine <= BottomLine then
    begin
      ML := 0;
      MR := BracketCount - 1;
      for I := 0 to BracketCount - 1 do
        Layers[I] := 0;

      // ��ǰ����������
      Cnt := 0;
      for I := CharPos.Line downto TopLine do
      begin
      {$IFDEF BDS}
        if EditControlWrapper.GetLineIsElided(EditControl, I) then
          Continue;
      {$ENDIF}

{$IFDEF UNICODE}
        // Unicode �����±���ѷ��ص� UnicodeString ����ת�� UTF8����Ϊ InCommentOrString ��ʹ�õĵײ����Ҫ����� UTF8
        ULine := EditControlWrapper.GetTextAtLine(EditControl, I);
        LineText := Utf8Encode(ULine); // UTF16 ֱ��ת���� Ansi �� Utf8���м䲻���� AnsiString
{$ELSE}
        LineText := AnsiString(EditControlWrapper.GetTextAtLine(EditControl, I));
{$ENDIF}

        if I = CharPos.Line then
        begin
          L := Min(CharPos.CharIndex, Length(LineText)) - 1;  // �ӹ�괦����β�����ĸ���С����ǰ��
{$IFDEF UNICODE}
          // L �� 0 ��ʼ��L + 1 �� CursorPos.Col��Unicode �������� Ansi �ģ���Ҫת�� UTF8 �Է��� LineText �ļ���
          L := ConvertAnsiPositionToUtf8OnUnicodeText(ULine, L + 1) - 1;
{$ENDIF}
        end
        else
          L := Length(LineText) - 1;

        for J := L downto 0 do
        begin
          for K := 0 to BracketCount - 1 do
          begin
            if (LineText[J + 1] = BracketChars^[K][0]) and
              not InCommentOrString(OTAEditPos(J + 1, I)) then
            begin
              if Layers[K] = 0 then
              begin
                AInfo.TokenStr := BracketChars^[K][0];
                AInfo.TokenLine := LineText;
                AInfo.TokenPos := OTAEditPos(J + 1, I);
{$IFDEF UNICODE}
                // LineText �� Utf8 �ģ�ת�� Ansi��Result �� Utf8 �ģ�ת�� Ansi
                AInfo.TokenLine := CnUtf8ToAnsi(AInfo.TokenLine);
                AInfo.TokenPos := OTAEditPos(ConvertUtf8PositionToAnsi(LineText, AInfo.TokenPos.Col), I);
{$ENDIF}
                ML := K;
                MR := K;
                Break;
              end
              else
                Dec(Layers[K]);
            end
            else if (LineText[J + 1] = BracketChars^[K][1]) and
              not InCommentOrString(OTAEditPos(J + 1, I)) then
            begin
              Inc(Layers[K]);
            end;
          end;
          if AInfo.TokenStr <> '' then
            Break;
        end;
        if AInfo.TokenStr <> '' then
          Break;

        Inc(Cnt);
        if Cnt > csMaxBracketMatchLines then
          Break;
      end;

      for I := 0 to BracketCount - 1 do
        Layers[I] := 0;

      // ������������
      Cnt := 0;
      for I := CharPos.Line to BottomLine do
      begin
      {$IFDEF BDS}
        if EditControlWrapper.GetLineIsElided(EditControl, I) then
          Continue;
      {$ENDIF}

{$IFDEF UNICODE}
        // Unicode �����±���ѷ��ص� UnicodeString ����ת�� UTF8����Ϊ InCommentOrString ��ʹ�õĵײ����Ҫ����� UTF8
        ULine := EditControlWrapper.GetTextAtLine(EditControl, I);
        LineText := Utf8Encode(ULine); // UTF16 ֱ��ת���� Ansi �� Utf8���м䲻���� AnsiString
{$ELSE}
        LineText := AnsiString(EditControlWrapper.GetTextAtLine(EditControl, I));
{$ENDIF}

        if I = CharPos.Line then
        begin
          L := CharPos.CharIndex;  // �ӹ�괦������
{$IFDEF UNICODE}
          // L �� 0 ��ʼ��L + 1 �� CursorPos.Col��Unicode �������� Ansi �ģ���Ҫת�� UTF8 �Է��� LineText �ļ���
          L := ConvertAnsiPositionToUtf8OnUnicodeText(ULine, L + 1) - 1;
{$ENDIF}
        end
        else
          L := 0;

        for J := L to Length(LineText) - 1 do
        begin
          for K := ML to MR do
          begin
            if (LineText[J + 1] = BracketChars^[K][1]) and
              not InCommentOrString(OTAEditPos(J + 1, I)) then
            begin
              if Layers[K] = 0 then
              begin
                AInfo.TokenMatchStr := BracketChars^[K][1];
                AInfo.TokenMatchLine := LineText;
                AInfo.TokenMatchPos := OTAEditPos(J + 1, I);
{$IFDEF UNICODE}
                // LineText �� Utf8 �ģ�ת�� Ansi��Result �� Utf8 �ģ�ת�� Ansi
                AInfo.TokenMatchLine := CnUtf8ToAnsi(AInfo.TokenMatchLine);
                AInfo.TokenMatchPos := OTAEditPos(ConvertUtf8PositionToAnsi(LineText, AInfo.TokenMatchPos.Col), I);
{$ENDIF}
                Break;
              end
              else
                Dec(Layers[K]);
            end
            else if (LineText[J + 1] = BracketChars^[K][0]) and
              not InCommentOrString(OTAEditPos(J + 1, I)) then
            begin
              Inc(Layers[K]);
            end;
          end;
          if AInfo.TokenMatchStr <> '' then
            Break;
        end;
        if AInfo.TokenMatchStr <> '' then
          Break;

        Inc(Cnt);
        if Cnt > csMaxBracketMatchLines then
          Break;
      end;

      Layers := nil;
      Result := (AInfo.TokenStr <> '') or (AInfo.TokenMatchStr <> '');
    end;
  end;
begin
  Result := False;
  Assert(Assigned(EditView), 'EditView is nil.');
  Assert(Assigned(EditBuffer), 'EditBuffer is nil.');

  try
    AInfo.TokenStr := '';
    AInfo.TokenLine := '';
    AInfo.TokenPos := OTAEditPos(0, 0);
    AInfo.TokenMatchStr := '';
    AInfo.TokenMatchLine := '';
    AInfo.TokenMatchPos := OTAEditPos(0, 0);

    if IsDprOrPas(EditView.Buffer.FileName) then
    begin
      BracketCount := csBracketCountPas;
      BracketChars := @csBracketsPas;
    end
    else if IsCppSourceModule(EditView.Buffer.FileName) then
    begin
      BracketCount := csBracketCountCpp;
      BracketChars := @csBracketsCpp;
    end
    else
      Exit;

    CharPos.CharIndex := EditView.CursorPos.Col - 1;
    CharPos.Line := EditView.CursorPos.Line;
    TmpULine := EditControlWrapper.GetTextAtLine(EditControl, CharPos.Line);
    LText := AnsiString(TmpULine);
    // BDS �� CursorPos �� utf8 ��λ�ã�LText �� BDS ���� UTF8��һ�¡�
    // �� D2009 ���� UnicodeString��CursorPos �� Ansi λ�ã������Ҫת�� Ansi��

    TmpPos := EditView.CursorPos;
{$IFDEF UNICODE}
    // �� Ansi �� TmpPos �� Col ת�� UTF8 ��
    TmpPos.Col := ConvertAnsiPositionToUtf8OnUnicodeText(TmpULine, TmpPos.Col);
{$ENDIF}

    if not CnOtaIsEditPosOutOfLine(EditView.CursorPos, EditView) and
      not InCommentOrString(TmpPos) then
    begin
      if LText <> '' then
      begin
        if CharPos.CharIndex > 0 then
        begin
          CL := LText[CharPos.CharIndex];
          PL := EditView.CursorPos;
          Dec(PL.Col);
        end
        else
        begin
          CL := #0;
          PL := OTAEditPos(0, 0);
        end;
        CR := LText[CharPos.CharIndex + 1];
{$IFDEF DEBUG}
//      CnDebugger.LogFmt('GetBracketMatch Chars Left and Right to Cursor: ''%s'', ''%s''', [CL, CR]);
{$ENDIF}
        PR := EditView.CursorPos;
        for i := 0 to BracketCount - 1 do
        begin
          if CL = BracketChars^[i][0] then
          begin
            AInfo.TokenStr := CL;
            AInfo.TokenLine := LText;
            AInfo.TokenPos := PL;
            CharPos := OTACharPos(PL.Col - 1, PL.Line);
            AInfo.TokenMatchStr := BracketChars^[i][1];
            AInfo.TokenMatchPos := ForwardFindMatchToken(AInfo.TokenStr,
              AInfo.TokenMatchStr, AInfo.FTokenMatchLine);
            Result := True;
            Break;
          end
          else if CR = BracketChars^[i][1] then
          begin
            AInfo.TokenStr := CR;
            AInfo.TokenLine := LText;
            AInfo.TokenPos := PR;
            CharPos := OTACharPos(PR.Col - 1, PR.Line);
            AInfo.TokenMatchStr := BracketChars^[i][0];
            AInfo.TokenMatchPos := BackFindMatchToken(AInfo.TokenStr,
              AInfo.TokenMatchStr, AInfo.FTokenMatchLine);
            Result := True;
            Break;
          end;
        end;
      end;
    end;

    // �����������м������
    if not Result and FBracketMiddle then
      Result := FindMatchTokenFromMiddle;

{$IFDEF IDE_STRING_ANSI_UTF8}
    // BDS �� LineText �� Utf8��EditView.CursorPos.Col Ҳ�� Utf8 �ַ����е�λ��
    // �˴�ת��Ϊ AnsiString λ�á�D2009 �� LineText ���� Utf8������������Ҫת�ء�
    if Result then
    begin
      AInfo.FTokenPos.Col := Length(CnUtf8ToAnsi(AnsiString(Copy(AInfo.TokenLine, 1,
        AInfo.TokenPos.Col))));
      AInfo.FTokenMatchPos.Col := Length(CnUtf8ToAnsi(AnsiString(Copy(AInfo.TokenMatchLine, 1,
        AInfo.TokenMatchPos.Col))));
    end;
{$ENDIF}

{$IFDEF DEBUG}
    if Result then
    begin
      CnDebugger.LogFmt('TCnSourceHighlight.GetBracketMatch Matched! %s at %d:%d and %s at %d:%d.',
        [AInfo.TokenStr, AInfo.TokenPos.Line, AInfo.TokenPos.Col,
        AInfo.TokenMatchStr, AInfo.TokenMatchPos.Line, AInfo.TokenMatchPos.Col]);
    end;
{$ENDIF}
  finally
    AInfo.IsMatch := Result;
  end;
end;

procedure TCnSourceHighlight.CheckBracketMatch(Editor: TEditorObject);
var
  IsMatch: Boolean;
  Info: TBracketInfo;
begin
  if FIsChecking then Exit;
  FIsChecking := True;
  
  with Editor do
  try
    if IndexOfBracket(EditControl) >= 0 then
      Info := TBracketInfo(FBracketList[IndexOfBracket(EditControl)])
    else
    begin
      Info := TBracketInfo.Create(EditControl);
      FBracketList.Add(Info);
    end;

    // ȡƥ������
    Info.TokenPos := OTAEditPos(0, 0);
    Info.TokenMatchPos := OTAEditPos(0, 0);
    IsMatch := FMatchedBracket and (EditView <> nil) and (EditView.Buffer <> nil)
      and (EditControl <> nil) and (EditControl is TWinControl) and // BDS is WinControl
      GetBracketMatch(EditView, EditView.Buffer, EditControl, Info);

    // �ָ���һ�εĸ�������
    if not SameEditPos(Info.LastPos, Info.TokenPos) and
      not SameEditPos(Info.LastPos, Info.TokenMatchPos) then
    begin
      EditorMarkLineDirty(Info.LastPos.Line);
    end;

    if not SameEditPos(Info.LastMatchPos, Info.TokenMatchPos) and
      not SameEditPos(Info.LastMatchPos, Info.TokenPos) then
    begin
      EditorMarkLineDirty(Info.LastMatchPos.Line);
    end;

    Info.LastPos := Info.TokenPos;
    Info.LastMatchPos := Info.TokenMatchPos;

    // ��ʾ��ǰ����
    if IsMatch then
    begin
      EditorMarkLineDirty(Info.TokenPos.Line);
      EditorMarkLineDirty(Info.TokenMatchPos.Line);
    end;
  finally
    FIsChecking := False;
  end;
end;

procedure TCnSourceHighlight.PaintBracketMatch(Editor: TEditorObject;
  LineNum, LogicLineNum: Integer; AElided: Boolean);
var
  R: TRect;
  Info: TBracketInfo;
begin
  with Editor do
  begin
    if IndexOfBracket(EditControl) >= 0 then
    begin
      Info := TBracketInfo(FBracketList[IndexOfBracket(EditControl)]);
      if Info.IsMatch then
      begin
        if (LogicLineNum = Info.TokenPos.Line) and EditorGetTextRect(Editor,
          OTAEditPos(Info.TokenPos.Col, LineNum), {$IFDEF BDS}FUniLineText, {$ENDIF} string(Info.TokenStr), R) then
          EditorPaintText(EditControl, R, Info.TokenStr, BracketColor,
            BracketColorBk, BracketColorBd, BracketBold, False, False);

        if (LogicLineNum = Info.TokenMatchPos.Line) and EditorGetTextRect(Editor,
          OTAEditPos(Info.TokenMatchPos.Col, LineNum), {$IFDEF BDS}FUniLineText, {$ENDIF} string(Info.TokenMatchStr), R) then
          EditorPaintText(EditControl, R, Info.TokenMatchStr, BracketColor,
            BracketColorBk, BracketColorBd, BracketBold, False, False);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
// �ṹ������ʾ
//------------------------------------------------------------------------------

function TCnSourceHighlight.IndexOfBlockMatch(EditControl: TControl): Integer;
var
  i: Integer;
begin
  for i := 0 to FBlockMatchList.Count - 1 do
    if TBlockMatchInfo(FBlockMatchList[i]).Control = EditControl then
    begin
      Result := i;
      Exit;
    end;
  Result := -1;
end;

function TCnSourceHighlight.IndexOfBlockLine(EditControl: TControl): Integer;
var
  I: Integer;
begin
  for I := 0 to FBlockLineList.Count - 1 do
    if TBlockLineInfo(FBlockLineList[I]).Control = EditControl then
    begin
      Result := I;
      Exit;
    end;
  Result := -1;
end;

function TCnSourceHighlight.IndexOfCompDirectiveLine(EditControl: TControl): Integer;
var
  I: Integer;
begin
  for I := 0 to FCompDirectiveList.Count - 1 do
    if TCompDirectiveInfo(FCompDirectiveList[I]).Control = EditControl then
    begin
      Result := I;
      Exit;
    end;
  Result := -1;
end;

procedure TCnSourceHighlight.ClearHighlight(Editor: TEditorObject);
var
  Index: Integer;
begin
  Index := IndexOfBlockMatch(Editor.EditControl);
  if Index >= 0 then
  begin
    with TBlockMatchInfo(FBlockMatchList[Index]) do
    begin
      FKeyTokenList.Clear;
      FKeyLineList.Clear;
      FIdLineList.Clear;
      FSeparateLineList.Clear;
      FFlowLineList.Clear;
      if LineInfo <> nil then
        LineInfo.Clear;
    end;
  end;

  Index := IndexOfBlockLine(Editor.EditControl);
  if Index >= 0 then
    with TBlockLineInfo(FBlockLineList[Index]) do
    begin
      Clear;
    end;

  Index := IndexOfCompDirectiveLine(Editor.EditControl);
  if Index >= 0 then
    with TCompDirectiveInfo(FCompDirectiveList[Index]) do
    begin
      Clear;
    end;

  Index := IndexOfBracket(Editor.EditControl);
  if Index >= 0 then
    with TBracketInfo(FBracketList[Index]) do
    begin
      IsMatch := False;
    end;
end;

// Editor ���ݸı�ʱ�����ã������﷨����
procedure TCnSourceHighlight.UpdateHighlight(Editor: TEditorObject;
  ChangeType: TEditorChangeTypes);
var
  OldPair, NewPair: TBlockLinePair;
  Info: TBlockMatchInfo;
  Line: TBlockLineInfo;
  CompDirective: TCompDirectiveInfo;
{$IFNDEF BDS}
  CurLine: TCurLineInfo;
{$ENDIF}
  I: Integer;
  CurTokenRefreshed: Boolean;
begin
  with Editor do
  begin
    // һ�� EditControl ��Ӧһ�� TBlockMatchInfo������ FBlockMatchList ��
    if IndexOfBlockMatch(EditControl) >= 0 then
      Info := TBlockMatchInfo(FBlockMatchList[IndexOfBlockMatch(EditControl)])
    else
    begin
      Info := TBlockMatchInfo.Create(EditControl);
      FBlockMatchList.Add(Info);
    end;

    // �趨�Ƿ��Сд�����ڵ�ǰ��ʶ���Ƚ�
    I := FViewChangedList.IndexOf(Editor);
    if I >= 0 then
    begin
      Info.CaseSensitive := not Boolean(FViewFileNameIsPascalList[I]);
      Info.IsCppSource := not Boolean(FViewFileNameIsPascalList[I]);
    end;

    Line := nil;
    if FBlockMatchDrawLine or FBlockMatchHighlight then
    begin
      // ������߽ṹ��������ͬʱ���ɻ��߽ṹ�����Ķ���
      if IndexOfBlockLine(EditControl) >= 0 then
        Line := TBlockLineInfo(FBlockLineList[IndexOfBlockLine(EditControl)])
      else
      begin
        Line := TBlockLineInfo.Create(EditControl);
        FBlockLineList.Add(Line);
      end;
    end;

    CompDirective := nil;
    if FHighlightCompDirective then
    begin
      // ���ɱ���ָ����Զ���
      if IndexOfCompDirectiveLine(EditControl) >= 0 then
        CompDirective := TCompDirectiveInfo(FCompDirectiveList[IndexOfCompDirectiveLine(EditControl)])
      else
      begin
        CompDirective := TCompDirectiveInfo.Create(EditControl);
        FCompDirectiveList.Add(CompDirective);
      end;
    end;
{$IFNDEF BDS}
    CurLine := nil;
    if FHighLightCurrentLine then
    begin
      // ���������ǰ�еı�������ͬʱ���ɸ��������Ķ���
      if IndexOfCurLine(EditControl) >= 0 then
        CurLine := TCurLineInfo(FCurLineList[IndexOfCurLine(EditControl)])
      else
      begin
        CurLine := TCurLineInfo.Create(EditControl);
        FCurLineList.Add(CurLine);
      end;
    end;

    if FHighLightCurrentLine and (ChangeType * [ctView, ctCurrLine] <> []) then
    begin
      if CurLine.CurrentLine > 0 then
        EditorMarkLineDirty(CurLine.CurrentLine);
      CurLine.CurrentLine := Editor.EditView.CursorPos.Line;
      EditorMarkLineDirty(CurLine.CurrentLine);
    end;
{$ENDIF}

    if (ChangeType * [ctView, ctModified, ctElided, ctUnElided] <> []) or
      ((FBlockHighlightRange <> brAll) and (ChangeType * [ctCurrLine, ctCurrCol] <> [])) then
    begin
      FStructureTimer.Enabled := False;

      // չ���Լ��䶯����������߾ֲ�����ʱλ�øĶ�����������½���
      Info.FKeyTokenList.Clear;
      Info.FKeyLineList.Clear;
      Info.FIdLineList.Clear;
      Info.FSeparateLineList.Clear;
      Info.FFlowLineList.Clear;
      Info.FCompDirectiveLineList.Clear;

      if Info.LineInfo <> nil then
        Info.LineInfo.Clear;
      if Info.CompDirectiveInfo <> nil then
        Info.CompDirectiveInfo.Clear;  
      // ���ϲ��ܵ��� Info.Clear ��������������ݣ����벻�� FCurTokenList
      // �����ػ�ʱ����ˢ��

      if Line <> nil then
        Line.Clear;

      Info.LineInfo := Line;
      Info.CompDirectiveInfo := CompDirective;
      Info.FChanged := True;
      Info.FModified := ChangeType * [ctView, ctModified] <> [];

      if (EditView <> nil) then
      begin
        if not FBlockMatchLineLimit or
          (EditView.Buffer.GetLinesInBuffer <= FBlockMatchMaxLines) then
        begin
          // ��������£���ʱһ��ʱ���ٽ����Ա����ظ�
          case BlockHighlightStyle of
            bsNow: FStructureTimer.Interval := csShortDelay;
            bsDelay: FStructureTimer.Interval := BlockMatchDelay;
            bsHotkey: Exit;
          end;
          FStructureTimer.Enabled := True;
        end
        else // ��С����������
        begin
          FStructureTimer.Enabled := False;
        end;
      end;
    end
    else if not FStructureTimer.Enabled then // �����ʱ���Ѿ����������ٴ���
    begin
      CurTokenRefreshed := False;
      if ChangeType * [ctCurrLine, ctCurrCol] <> [] then
      begin
        if FCurrentTokenHighlight and not CurTokenRefreshed then
        begin
          Info.UpdateCurTokenList;
          CurTokenRefreshed := True;
        end;

        // ֻλ�ñ䶯�Ļ���ֻ���¸�����ʾ�ؼ��֣��Լ�����ָ��
        if (Line <> nil) and (EditView <> nil) then
        begin
          OldPair := Line.CurrentPair;
          Line.FindCurrentPair(EditView); // ��ʱ������C/C++�����
          NewPair := Line.CurrentPair;
          if OldPair <> NewPair then
          begin
            if OldPair <> nil then
            begin
              EditorMarkLineDirty(OldPair.Top);
              EditorMarkLineDirty(OldPair.Bottom);
              for I := 0 to OldPair.MiddleCount - 1 do
                EditorMarkLineDirty(OldPair.MiddleToken[I].EditLine);
            end;
            if NewPair <> nil then
            begin
              EditorMarkLineDirty(NewPair.Top);
              EditorMarkLineDirty(NewPair.Bottom);
              for I := 0 to NewPair.MiddleCount - 1 do
                EditorMarkLineDirty(NewPair.MiddleToken[I].EditLine);
            end;
          end;
        end;

        if (CompDirective <> nil) and (EditView <> nil) then
        begin
          OldPair := CompDirective.CurrentPair;
          CompDirective.FindCurrentPair(EditView); // ��ʱ������C/C++�����
          NewPair := CompDirective.CurrentPair;
          if OldPair <> NewPair then
          begin
            if OldPair <> nil then
            begin
              EditorMarkLineDirty(OldPair.Top);
              EditorMarkLineDirty(OldPair.Bottom);
              for I := 0 to OldPair.MiddleCount - 1 do
                EditorMarkLineDirty(OldPair.MiddleToken[I].EditLine);
            end;
            if NewPair <> nil then
            begin
              EditorMarkLineDirty(NewPair.Top);
              EditorMarkLineDirty(NewPair.Bottom);
              for I := 0 to NewPair.MiddleCount - 1 do
                EditorMarkLineDirty(NewPair.MiddleToken[I].EditLine);
            end;
          end;
        end;
      end;

      if FCurrentTokenHighlight and not CurTokenRefreshed then
      begin
        if ctHScroll in ChangeType then
        begin
          Info.UpdateCurTokenList;
        end
        else if ctVScroll in ChangeType then
          RefreshCurrentTokens(Info);
      end;
    end;
  end;
end;

// �������ʱ��ʱ���ˣ���ʼ����
procedure TCnSourceHighlight.OnHighlightTimer(Sender: TObject);
var
  i: Integer;
  Info: TBlockMatchInfo;
begin
  FStructureTimer.Enabled := False;

  if FIsChecking then Exit;
  GlobalIgnoreClass := not FBlockMatchLineClass;

  FIsChecking := True;
  try
    for i := 0 to FBlockMatchList.Count - 1 do
    begin
      Info := TBlockMatchInfo(FBlockMatchList[i]);

      // CheckBlockMatch ʱ������ FChanged
      if Info.FChanged then
      begin
        try
          Info.CheckBlockMatch(BlockHighlightRange);
        except
          ; // Hide an Unknown exception.
        end;
      end;
    end;
  finally
    FIsChecking := False;
  end;
end;

procedure TCnSourceHighlight.OnHighlightExec(Sender: TObject);
var
  i: Integer;
  Info: TBlockMatchInfo;
  Line: TBlockLineInfo;
  CompDirective: TCompDirectiveInfo;
begin
  if FIsChecking then Exit;
  FIsChecking := True;
  GlobalIgnoreClass := not FBlockMatchLineClass;
  try
    begin
      for i := 0 to FBlockMatchList.Count - 1 do
      begin
        try
          Info := TBlockMatchInfo(FBlockMatchList[i]);
          if (FBlockMatchDrawLine or FBlockMatchHighlight) and (Info.LineInfo = nil) then
          begin
            // ������߽ṹ������֮ǰ�޻��߶�����ͬʱ���ɻ��߽ṹ�����Ķ���
            Line := TBlockLineInfo.Create(Info.Control);
            FBlockLineList.Add(Line);
            Info.LineInfo := Line;
          end;
          if FHighlightCompDirective and (Info.CompDirectiveInfo = nil) then
          begin
            // ������߽ṹ������֮ǰ�ޱ���ָ����Զ�����ͬʱ���ɱ���ָ����ԵĶ���
            CompDirective := TCompDirectiveInfo.Create(Info.Control);
            FCompDirectiveList.Add(CompDirective);
            Info.CompDirectiveInfo := CompDirective;
          end;
          Info.FChanged := True;
          Info.FModified := True;
          Info.CheckBlockMatch(BlockHighlightRange);
        except
          ;
        end;
      end;
    end;
  finally
    FIsChecking := False;
  end;
end;

procedure TCnSourceHighlight.SetBlockMatchLineClass(const Value: Boolean);
begin
  FBlockMatchLineClass := Value;
  GlobalIgnoreClass := not Value;
end;

function TCnSourceHighlight.GetColorFg(ALayer: Integer): TColor;
begin
  if ALayer < 0 then ALayer := -1;
  Result := FHighLightColors[ ALayer mod 6 ];
   // HSLToRGB(ALayer / 7, 1, 0.5);
end;

procedure TCnSourceHighlight.PaintBlockMatchKeyword(Editor: TEditorObject;
  LineNum, LogicLineNum: Integer; AElided: Boolean);
var
  R, R1: TRect;
  I, J, Layer: Integer;
  Info: TBlockMatchInfo;
  LineInfo: TBlockLineInfo;
  CompDirectiveInfo: TCompDirectiveInfo;
  Token: TCnPasToken;
  EditPos: TOTAEditPos;
  EditPosColBase: Integer;
  ColorFg, ColorBk: TColor;
  Element, LineFlag: Integer;
  KeyPair: TBlockLinePair;
  CompDirectivePair: TCompDirectivePair;
  SavePenColor, SaveBrushColor, SaveFontColor: TColor;
  SavePenStyle: TPenStyle;
  SaveBrushStyle: TBrushStyle;
  SaveFontStyles: TFontStyles;
  EditCanvas: TCanvas;
  TokenLen: Integer;
  CanDrawToken: Boolean;
  RectGot: Boolean;
  CanvasSaved: Boolean;

  function CalcEditColBase(AToken: TCnPasToken): Integer;
  begin
    // ��Ϊ�ؼ��ֵ� Token �в������˫�ֽ��ַ������ֻ�����һ�� EditPosColBase ����
    Result := Token.EditCol;
{$IFDEF BDS}
    // GetAttributeAtPos ��Ҫ���� UTF8 ��Pos����˽��� Col �� UTF8 ת��
    // ��ʵ���ϲ������ת���ļ򵥣���Ϊ�в���˫�ֽ��ַ��� Accent Char
    // ������ֻռһ���ַ���λ�ã������纺���ַ�һ��ռ�����ַ�λ�ã����
    // �������д˵��ַ�ʱ����ִ�λ�������BDS ����������⡣
    if _UNICODE_STRING and CodePageOnlySupportsEnglish then
    begin
      if FUniLineText <> '' then
        Result := ConvertAnsiPositionToUtf8OnUnicodeText(FUniLineText, Token.EditCol);
    end
    else
    begin
      if FAnsiLineText <> '' then
        Result := Length(CnAnsiToUtf8(Copy(FAnsiLineText, 1, Token.EditCol)));
    end;
{$ENDIF}
  end;

begin
  with Editor do
  begin
    if IndexOfBlockMatch(EditControl) >= 0 then
    begin
      // �ҵ��� EditControl��Ӧ��BlockMatch�б�
      Info := TBlockMatchInfo(FBlockMatchList[IndexOfBlockMatch(EditControl)]);

      CanvasSaved := False;
      SavePenColor := clNone;
      SavePenStyle := psSolid;
      SaveBrushColor := clNone;
      SaveBrushStyle := bsSolid;
      SaveFontColor := clNone;
      SaveFontStyles := [];
      EditCanvas := EditControlWrapper.GetEditControlCanvas(EditControl);

      if FHilightSeparateLine and (LogicLineNum <= Info.FSeparateLineList.Count - 1)
        and (Integer(Info.FSeparateLineList[LogicLineNum]) = CN_LINE_SEPARATE_FLAG)
        and (Trim(EditControlWrapper.GetTextAtLine(EditControl, LogicLineNum)) = '') then
      begin
        // ���� EditCanvas �ľ�����
        with EditCanvas do
        begin
          SavePenColor := Pen.Color;
          SavePenStyle := Pen.Style;
          SaveBrushColor := Brush.Color;
          SaveBrushStyle := Brush.Style;
          SaveFontColor := Font.Color;
          SaveFontStyles := Font.Style;
        end;
        CanvasSaved := True;

        // �Ȼ��Ϸָ�����˵
        EditPos := OTAEditPos(Editor.EditView.LeftColumn, LineNum);
        if EditorGetTextRect(Editor, EditPos, {$IFDEF BDS}FUniLineText, {$ENDIF} ' ', R) then
        begin
          EditCanvas.Pen.Color := FSeparateLineColor;
          EditCanvas.Pen.Width := FSeparateLineWidth;
          HighlightCanvasLine(EditCanvas, R.Left, (R.Top + R.Bottom) div 2,
            R.Left + 2048, (R.Top + R.Bottom) div 2, FSeparateLineStyle);
        end;
      end;

      if (Info.KeyCount > 0) or (Info.CurTokenCount > 0) or (Info.CompDirectiveTokenCount > 0) then
      begin
        // ͬʱ���ؼ��ֱ���ƥ������������� MarkLinesDirty ����
        KeyPair := nil;
        if FBlockMatchHighlight then
        begin
          if IndexOfBlockLine(EditControl) >= 0 then
          begin
            LineInfo := TBlockLineInfo(FBlockLineList[IndexOfBlockLine(EditControl)]);
            if (LineInfo.CurrentPair <> nil) and ((LineInfo.CurrentPair.Top = LogicLineNum)
              or (LineInfo.CurrentPair.Bottom = LogicLineNum)
              or (LineInfo.CurrentPair.IsInMiddle(LogicLineNum))) then
            begin
              // Ѱ�ҵ�ǰ���Ѿ���Ե� Pair
              KeyPair := LineInfo.CurrentPair;
            end;
          end;
        end;

        CompDirectivePair := nil;
        if FHighlightCompDirective then
        begin
          if IndexOfCompDirectiveLine(EditControl) >= 0 then
          begin
            CompDirectiveInfo := TCompDirectiveInfo(FCompDirectiveList[IndexOfCompDirectiveLine(EditControl)]);
            if (CompDirectiveInfo.CurrentPair <> nil) and ((CompDirectiveInfo.CurrentPair.Top = LogicLineNum)
              or (CompDirectiveInfo.CurrentPair.Bottom = LogicLineNum)
              or (CompDirectiveInfo.CurrentPair.IsInMiddle(LogicLineNum))) then
            begin
              // Ѱ�ҵ�ǰ���Ѿ���Ե���������ָ�� Pair
              CompDirectivePair := TCompDirectivePair(CompDirectiveInfo.CurrentPair);
            end;
          end;
        end;

        if not CanvasSaved then
        begin
          // ���� EditCanvas �ľ�����
          with EditCanvas do
          begin
            SavePenColor := Pen.Color;
            SavePenStyle := Pen.Style;
            SaveBrushColor := Brush.Color;
            SaveBrushStyle := Brush.Style;
            SaveFontColor := Font.Color;
            SaveFontStyles := Font.Style;
          end;
          CanvasSaved := True;
        end;

        // BlockMatch ���ж��TCnPasToken
        if (LogicLineNum < Info.LineCount) and (Info.Lines[LogicLineNum] <> nil) then
        begin
          with EditCanvas do
          begin
            Font.Style := [];
            if FKeywordHighlight.Bold then
              Font.Style := Font.Style + [fsBold];
            if FKeywordHighlight.Italic then
              Font.Style := Font.Style + [fsItalic];
            if FKeywordHighlight.Underline then
              Font.Style := Font.Style + [fsUnderline];
          end;

          for I := 0 to Info.Lines[LogicLineNum].Count - 1 do
          begin
            Token := TCnPasToken(Info.Lines[LogicLineNum][I]);

            Layer := Token.MethodLayer + Token.ItemLayer - 2;
            if FStructureHighlight then
              ColorFg := GetColorFg(Layer)
            else
              ColorFg := FKeywordHighlight.ColorFg;

            ColorBk := clNone; // ֻ�е�ǰToken�ڵ�ǰKeyPair�ڲŸ�������
            if KeyPair <> nil then
            begin
              if (KeyPair.StartToken = Token) or (KeyPair.EndToken = Token) or
                (KeyPair.IndexOfMiddleToken(Token) >= 0) then
                ColorBk := FBlockMatchBackground;
            end;

            if not FStructureHighlight and (ColorBk = clNone) then
              Continue; // ����θ���ʱ�����޵�ǰ�����������򲻻�

            EditCanvas.Font.Color := ColorFg;
            EditPosColBase := CalcEditColBase(Token);

            // �����ַ��ػ�����Ӱ��ѡ��Ч��������Ǹ�����ColorBk�����ú�
            RectGot := False;
            for J := 0 to Length(Token.Token) - 1 do
            begin
              EditPos := OTAEditPos(Token.EditCol + J, LineNum);
              if not RectGot then
              begin
                if EditorGetTextRect(Editor, EditPos, {$IFDEF BDS}FUniLineText, {$ENDIF} string(Token.Token[J]), R) then
                  RectGot := True
                else
                  Continue;
              end
              else
              begin
                Inc(R.Left, CharSize.cx);
                Inc(R.Right, CharSize.cx);
              end;

              EditPos.Col := EditPosColBase + J;
              EditPos.Line := Token.EditLine;
              EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                Element, LineFlag);

              if (Element = atReservedWord) and (LineFlag = 0) then
              begin
                // ��λ���ϻ��ӴֵĹؼ��֣�����ɫ�����ú�
                with EditCanvas do
                begin
                  if ColorBk <> clNone then
                  begin
                    Brush.Color := ColorBk;
                    Brush.Style := bsSolid;
                    FillRect(R);
                  end;

                  Brush.Style := bsClear;
                  TextOut(R.Left, R.Top, string(Token.Token[J]));
                  // ע���±꣬Token �� string �� PAnsiChar ʱ��㲻ͬ
                end;
              end;
            end;
          end;
        end;

        // �������Ҫ�������Ƶı�ʶ������
        if FCurrentTokenHighlight and not FCurrentTokenInvalid and
          (LogicLineNum < Info.IdLineCount) and (Info.IdLines[LogicLineNum] <> nil) then
        begin
          with EditCanvas do
          begin
            Font.Style := [];
            Font.Color := FIdentifierHighlight.ColorFg;
            if FIdentifierHighlight.Bold then
              Font.Style := Font.Style + [fsBold];
            if FIdentifierHighlight.Italic then
              Font.Style := Font.Style + [fsItalic];
            if FIdentifierHighlight.Underline then
              Font.Style := Font.Style + [fsUnderline];
          end;

          for I := 0 to Info.IdLines[LogicLineNum].Count - 1 do
          begin
            Token := TCnPasToken(Info.IdLines[LogicLineNum][I]);
            TokenLen := Length(Token.Token);

            EditPos := OTAEditPos(Token.EditCol, LineNum);
            if not EditorGetTextRect(Editor, EditPos, {$IFDEF BDS}FUniLineText, {$ENDIF} string(Token.Token), R) then
              Continue;

            EditPos.Col := Token.EditCol;
            EditPos.Line := Token.EditLine;

            // Token ǰҲ���ǳ�ʼ EditCol ��Ҫ UTF8 ת��
{$IFDEF BDS}
            if _UNICODE_STRING and CodePageOnlySupportsEnglish then
            begin
              if FUniLineText <> '' then
                EditPos.Col := ConvertAnsiPositionToUtf8OnUnicodeText(FUniLineText, Token.EditCol);
            end
            else
            begin
              if FAnsiLineText <> '' then
                EditPos.Col := Length(CnAnsiToUtf8(Copy(FAnsiLineText, 1, Token.EditCol)));
            end;
{$ENDIF}
            CanDrawToken := True;
            for J := 0 to TokenLen - 1 do
            begin
              // �˴�ѭ���ڱ�����Ҫһ�� UTF8 ��λ��ת������Ŀǰ���������� Token ������
              // ˫�ֽ��ַ������ Token ���ݲ���Ҫת����
              EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                Element, LineFlag);
              CanDrawToken := (LineFlag = 0) and (Element in [atIdentifier]);

              if not CanDrawToken then // ����м���ѡ�������򲻻�
                Break;
              Inc(EditPos.Col);
            end;

            if CanDrawToken then
            begin
              // ��λ���ϻ����������ı�ʶ��
              with EditCanvas do
              begin
                R1 := Rect(R.Left - 1, R.Top, R.Right + 1, R.Bottom - 1);
{$IFDEF BDS}
                // BDS ���ַ�����Ǻ���Ŀ�ȣ��� EditorGetTextRect ��������Ĳ�һ�£�
                // ������ֲ�һ�¡�CharSize.cx �Ǻ�����
                if (R1.Right - R1.Left) < Length(Token.Token) * CharSize.cx then
                  R1.Right := R1.Left + Length(Token.Token) * CharSize.cx;
{$ENDIF}
                if FCurrentTokenBackground <> clNone then
                begin
                  Brush.Color := FCurrentTokenBackground;
                  Brush.Style := bsSolid;
                  FillRect(R1);
                end;

                Brush.Style := bsClear;
                if (FCurrentTokenBorderColor <> clNone) and
                  (FCurrentTokenBorderColor <> FCurrentTokenBackground) then
                begin
                  Pen.Color := FCurrentTokenBorderColor;
                  Rectangle(R1);
                end;

                Font.Color := FCurrentTokenForeground;
{$IFDEF BDS}
                // BDS ����Ҫ���������ַ�����Ϊ BDS ������õ��ǼӴֵ��ַ�������
                EditPosColBase := CalcEditColBase(Token);
                for J := 0 to Length(Token.Token) - 1 do
                begin
                  EditPos.Col := EditPosColBase + J;
                  EditPos.Line := Token.EditLine;
                  EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                    Element, LineFlag);

                  if (Element = atIdentifier) and (LineFlag = 0) then
                  begin
                    // ��λ���ϻ��֣���ɫ�������ú�
                    TextOut(R.Left, R.Top, string(Token.Token[J]));
                  end;
                  Inc(R.Left, CharSize.cx);
                  Inc(R.Right, CharSize.cx);
                end;
{$ELSE}
                // �Ͱ汾��ֱ�ӻ���
                TextOut(R.Left, R.Top, string(Token.Token));
{$ENDIF}
              end;
            end;
          end;
        end;

        // �������Ҫ�������Ƶ����̿��Ʊ�ʶ��������
        if FHighlightFlowStatement and (LogicLineNum < Info.FlowLineCount) and
          (Info.FlowLines[LogicLineNum] <> nil) then
        begin
          for I := 0 to Info.FlowLines[LogicLineNum].Count - 1 do
          begin
            Token := TCnPasToken(Info.FlowLines[LogicLineNum][I]);
            TokenLen := Length(Token.Token);

            EditPos := OTAEditPos(Token.EditCol, LineNum);
            if not EditorGetTextRect(Editor, EditPos, {$IFDEF BDS}FUniLineText, {$ENDIF} string(Token.Token), R) then
              Continue;

            EditPos.Col := Token.EditCol;
            EditPos.Line := Token.EditLine;

            // Token ǰҲ���ǳ�ʼ EditCol ��Ҫ UTF8 ת��
{$IFDEF BDS}
            if _UNICODE_STRING and CodePageOnlySupportsEnglish then
            begin
              if FUniLineText <> '' then
                EditPos.Col := ConvertAnsiPositionToUtf8OnUnicodeText(FUniLineText, Token.EditCol);
            end
            else
            begin
              if FAnsiLineText <> '' then
                EditPos.Col := Length(CnAnsiToUtf8(Copy(FAnsiLineText, 1, Token.EditCol)));
            end;
{$ENDIF}
            CanDrawToken := True;
            for J := 0 to TokenLen - 1 do
            begin
              // �˴�ѭ���ڱ�����Ҫһ�� UTF8 ��λ��ת������Ŀǰ���������� Token ������
              // ˫�ֽ��ַ������ Token ���ݲ���Ҫת����
              EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                Element, LineFlag);
              CanDrawToken := (LineFlag = 0) and (Element in [atIdentifier, atReservedWord]);

              if not CanDrawToken then // ����м���ѡ�������򲻻�
                Break;
              Inc(EditPos.Col);
            end;

            if CanDrawToken then
            begin
              // ��λ���ϻ��������������̿��Ʊ�ʶ��
              with EditCanvas do
              begin
                R1 := Rect(R.Left - 1, R.Top, R.Right + 1, R.Bottom - 1);
                if FFlowStatementBackground <> clNone then
                begin
                  Brush.Color := FFlowStatementBackground;
                  Brush.Style := bsSolid;
                  FillRect(R1);
                end;

                if Element = atIdentifier then
                begin
                  Font.Style := [];
                  Font.Color := FIdentifierHighlight.ColorFg;
                  if FIdentifierHighlight.Bold then
                    Font.Style := Font.Style + [fsBold];
                  if FIdentifierHighlight.Italic then
                    Font.Style := Font.Style + [fsItalic];
                  if FIdentifierHighlight.Underline then
                    Font.Style := Font.Style + [fsUnderline];
                end
                else if Element = atReservedWord then
                begin
                  Font.Style := [];
                  Font.Color := FKeywordHighlight.ColorFg;
                  if FKeywordHighlight.Bold then
                    Font.Style := Font.Style + [fsBold];
                  if FKeywordHighlight.Italic then
                    Font.Style := Font.Style + [fsItalic];
                  if FKeywordHighlight.Underline then
                    Font.Style := Font.Style + [fsUnderline];
                end;
                Font.Color := FFlowStatementForeground;
{$IFDEF BDS}
                // BDS ����Ҫ���������ַ�����Ϊ BDS ������õ��ǼӴֵ��ַ�������
                EditPosColBase := CalcEditColBase(Token);
                for J := 0 to Length(Token.Token) - 1 do
                begin
                  EditPos.Col := EditPosColBase + J;
                  EditPos.Line := Token.EditLine;
                  EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                    Element, LineFlag);

                  if ((Element = atReservedWord) or (Element = atIdentifier)) and (LineFlag = 0) then
                  begin
                    // ��λ���ϻ��֣��Ƿ�����������ú�
                    TextOut(R.Left, R.Top, string(Token.Token[J]));
                  end;
                  Inc(R.Left, CharSize.cx);
                  Inc(R.Right, CharSize.cx);
                end;
{$ELSE}
                // �Ͱ汾��ֱ�ӻ���
                TextOut(R.Left, R.Top, string(Token.Token));
{$ENDIF}
              end;
            end;
          end;
        end;

        // �������Ҫ��������������ָ��
        if FHighlightCompDirective and (LogicLineNum < Info.CompDirectiveLineCount) and
          (Info.CompDirectiveLines[LogicLineNum] <> nil) and
          (FCompDirectiveBackground <> clNone) and (CompDirectivePair <> nil) then
        begin
          for I := 0 to Info.CompDirectiveLines[LogicLineNum].Count - 1 do
          begin
            Token := TCnPasToken(Info.CompDirectiveLines[LogicLineNum][I]);
            TokenLen := Length(Token.Token);

            if (CompDirectivePair.StartToken = Token) or (CompDirectivePair.EndToken = Token) or
              (CompDirectivePair.IndexOfMiddleToken(Token) >= 0) then
            begin
              EditPos := OTAEditPos(Token.EditCol, LineNum);
              if not EditorGetTextRect(Editor, EditPos, {$IFDEF BDS}FUniLineText, {$ENDIF} string(Token.Token), R) then
                Continue;

              EditPos.Col := Token.EditCol;
              EditPos.Line := Token.EditLine;

              // Token ǰҲ���ǳ�ʼ EditCol ��Ҫ UTF8 ת��
{$IFDEF BDS}
              if FAnsiLineText <> '' then
                EditPos.Col := Length(CnAnsiToUtf8(Copy(FAnsiLineText, 1, Token.EditCol)));
{$ENDIF}
              CanDrawToken := True;
              for J := 0 to TokenLen - 1 do
              begin
                // �˴�ѭ���ڱ�����Ҫһ�� UTF8 ��λ��ת������Ŀǰ���������� Token ������
                // ˫�ֽ��ַ������ Token ���ݲ���Ҫת����
                EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                  Element, LineFlag);
                CanDrawToken := (LineFlag = 0) and (Element in [atPreproc, atComment]);

                if not CanDrawToken then // ����м���ѡ�������򲻻�
                  Break;
                Inc(EditPos.Col);
              end;

              if CanDrawToken then
              begin
                // ��λ���ϸ������������������ı���ָ��
                with EditCanvas do
                begin
                  R1 := Rect(R.Left - 1, R.Top, R.Right + 1, R.Bottom - 1);
                  Brush.Color := FCompDirectiveBackground;
                  Brush.Style := bsSolid;
                  FillRect(R1);

                  Font.Style := [];
                  Font.Color := FCompDirectiveHighlight.ColorFg;
                  if FCompDirectiveHighlight.Bold then
                    Font.Style := Font.Style + [fsBold];
                  if FCompDirectiveHighlight.Italic then
                    Font.Style := Font.Style + [fsItalic];
                  if FCompDirectiveHighlight.Underline then
                    Font.Style := Font.Style + [fsUnderline];
{$IFDEF BDS}
                  // BDS ����Ҫ���������ַ�����Ϊ BDS ������õ��ǼӴֵ��ַ�������
                  EditPosColBase := CalcEditColBase(Token);
                  for J := 0 to Length(Token.Token) - 1 do
                  begin
                    EditPos.Col := EditPosColBase + J;
                    EditPos.Line := Token.EditLine;
                    EditControlWrapper.GetAttributeAtPos(EditControl, EditPos, False,
                      Element, LineFlag);

                    if (Element in [atPreproc, atComment]) and (LineFlag = 0) then
                    begin
                      // ��λ���ϻ���
                      TextOut(R.Left, R.Top, string(Token.Token[J]));
                    end;
                    Inc(R.Left, CharSize.cx);
                    Inc(R.Right, CharSize.cx);
                  end;
{$ELSE}
                  // �Ͱ汾��ֱ�ӻ���
                  TextOut(R.Left, R.Top, string(Token.Token));
{$ENDIF}
                end;
              end;
            end;
          end;
        end;
      end;

      if CanvasSaved then
      begin
        // �ָ��ɵ�
        with EditCanvas do
        begin
          Pen.Color := SavePenColor;
          Pen.Style := SavePenStyle;
          Brush.Color := SaveBrushColor;
          Brush.Style := SaveBrushStyle;
          Font.Color := SaveFontColor;
          Font.Style := SaveFontStyles;
        end;
      end;
    end;
  end;
end;

procedure TCnSourceHighlight.PaintBlockMatchLine(Editor: TEditorObject;
  LineNum, LogicLineNum: Integer; AElided: Boolean);
var
  LineInfo: TBlockLineInfo;
  Info: TBlockMatchInfo;
  I, J: Integer;
  R1, R2: TRect;
  Pair: TBlockLinePair;
  SavePenColor: TColor;
  SavePenWidth: Integer;
  SavePenStyle: TPenStyle;
  EditPos1, EditPos2: TOTAEditPos;
  EditorCanvas: TCanvas;
  LineFirstToken: TCnPasToken;
  EndLineStyle: TCnLineStyle;

  function EditorGetEditPoint(APos: TOTAEditPos; var ARect: TRect): Boolean;
  begin
    with Editor, Editor.EditView do
    begin
      if InBound(APos.Line, TopRow, BottomRow) and
        InBound(APos.Col, LeftColumn, RightColumn) then
      begin
        ARect := Bounds(GutterWidth + (APos.Col - LeftColumn) * CharSize.cx,
          (APos.Line - TopRow) * CharSize.cy, CharSize.cx * 1,
          CharSize.cy); // �õ� EditPos ��һ���ַ����ڵĻ��ƿ��
        Result := True;
      end
      else
        Result := False;
    end;        
  end;
begin
  with Editor do
  begin
    if IndexOfBlockLine(EditControl) >= 0 then
    begin
      LineInfo := TBlockLineInfo(FBlockLineList[IndexOfBlockLine(EditControl)]);
      if IndexOfBlockMatch(EditControl) >= 0 then
        Info := TBlockMatchInfo(FBlockMatchList[IndexOfBlockMatch(EditControl)])
      else
        Info := nil;

      if LineInfo.Count > 0 then
      begin
        EditorCanvas := EditControlWrapper.GetEditControlCanvas(EditControl);
        SavePenColor := EditorCanvas.Pen.Color;
        SavePenWidth := EditorCanvas.Pen.Width;
        SavePenStyle := EditorCanvas.Pen.Style;

        if FBlockMatchDrawLine then
        begin
          if (LogicLineNum < LineInfo.LineCount) and (LineInfo.Lines[LogicLineNum] <> nil) then
          begin
            EditorCanvas.Pen.Width := FBlockMatchLineWidth; // �߿�

            for I := 0 to LineInfo.Lines[LogicLineNum].Count - 1 do
            begin
              // һ�� EditControl �� LineInfo ���ж����Ի��ߵ���Ϣ LinePair
              Pair := TBlockLinePair(LineInfo.Lines[LogicLineNum][I]);
              EditorCanvas.Pen.Color := GetColorFg(Pair.Layer);

              if FBlockExtendLeft and (Info <> nil) and (LogicLineNum = Pair.Top)
                and (Pair.EndToken.EditLine > Pair.StartToken.EditLine) then
              begin
                // ����ǰ�滹�� token �����Σ��� Start/End Token �����еĵ�һ�� Token
                if Info.Lines[LogicLineNum].Count > 0 then
                begin
                  LineFirstToken := TCnPasToken(Info.Lines[LogicLineNum][0]);
                  if LineFirstToken <> Pair.StartToken then
                  begin
                    if Pair.Left > LineFirstToken.EditCol then
                    begin
                      Pair.Left := LineFirstToken.EditCol;
                    end;
                  end;
                end;

                if Pair.EndToken.EditLine < Info.LineCount then
                begin
                  if Info.Lines[Pair.EndToken.EditLine].Count > 0 then
                  begin
                    LineFirstToken := TCnPasToken(Info.Lines[Pair.EndToken.EditLine][0]);

                    if LineFirstToken <> Pair.EndToken then
                    begin
                      if Pair.Left > LineFirstToken.EditCol then
                      begin
                        Pair.Left := LineFirstToken.EditCol;
                      end;
                    end;
                  end;
                end;
              end;

              EditPos1 := OTAEditPos(Pair.Left, LineNum); // ��ʵ����ȥ��������
              // �õ� R1���� Left ��Ҫ���Ƶ�λ��
              if not EditorGetEditPoint(EditPos1, R1) then
                Continue;

              // �����ͷβ
              if LogicLineNum = Pair.Top then
              begin
                // �����ͷ������� Left �� StartLeft
                EditPos2 := OTAEditPos(Pair.StartLeft, LineNum);
                if not EditorGetEditPoint(EditPos2, R2) then
                  Continue;

                if FBlockMatchLineEnd and (Pair.Top <> Pair.Bottom) then // ������ͷ�ϻ�����
                begin
                  if FBlockMatchLineHoriDot and (Pair.StartLeft <> Pair.Left) then
                    EndLineStyle := lsTinyDot // �������߲�ͬ��ʱ�������߻���
                  else
                    EndLineStyle := FBlockMatchLineStyle;

                  // HighlightCanvasLine(EditorCanvas, R2.Left, R2.Bottom - 1,
                  //  R2.Right, R2.Bottom - 1, EndLineStyle); ͷ������
                  HighlightCanvasLine(EditorCanvas, R2.Left, R2.Top,
                    R2.Right, R2.Top, EndLineStyle);
                  HighlightCanvasLine(EditorCanvas, R2.Left, R2.Top,
                    R2.Left, R2.Bottom, EndLineStyle);
                end;

                if FBlockMatchLineHori and (Pair.Top <> Pair.Bottom) then  // ���Ҷ˻���
                begin
                  if FBlockMatchLineHoriDot then // �Ҷ˵�������
                    HighlightCanvasLine(EditorCanvas, R1.Left, R1.Bottom - 1,
                      R2.Left, R2.Bottom - 1, lsTinyDot)
                  else
                    HighlightCanvasLine(EditorCanvas, R1.Left, R1.Bottom - 1,
                      R2.Left, R2.Bottom - 1, FBlockMatchLineStyle);
                end;
              end
              else if LogicLineNum = Pair.Bottom then
              begin
                // �����β������� Left �� EndLeft
                EditPos2 := OTAEditPos(Pair.EndLeft, LineNum);
                if not EditorGetEditPoint(EditPos2, R2) then
                  Continue;

                if FBlockMatchLineEnd  and (Pair.Top <> Pair.Bottom) then // ������ͷ�ϻ�����
                begin
                  if FBlockMatchLineHoriDot and (Pair.EndLeft <> Pair.Left) then
                    EndLineStyle := lsTinyDot // �������߲�ͬ��ʱ�������߻���
                  else
                    EndLineStyle := FBlockMatchLineStyle;

                  HighlightCanvasLine(EditorCanvas, R2.Left, R2.Bottom - 1,
                    R2.Right, R2.Bottom - 1, EndLineStyle);
                  // HighlightCanvasLine(EditorCanvas, R2.Left, R2.Top,
                  //   R2.Right, R2.Top, EndLineStyle); β������

                  if Pair.EndLeft = Pair.Left then
                    HighlightCanvasLine(EditorCanvas, R2.Left, R2.Top,
                      R2.Left, R2.Bottom - 1, EndLineStyle); // ��ͬ��ʱβ������
                end;

                if Pair.Left <> Pair.EndLeft then
                  HighlightCanvasLine(EditorCanvas, R1.Left, R1.Top, R1.Left,
                    R1.Bottom, FBlockMatchLineStyle);

                if FBlockMatchLineHori and (Pair.Top <> Pair.Bottom) and (Pair.Left <> Pair.EndLeft) then  // ���Ҷ˻��ף��Ѿ������������ϻ��׵����
                begin
                  if FBlockMatchLineHoriDot then // �Ҷ˵�������
                    HighlightCanvasLine(EditorCanvas, R1.Left, R1.Bottom - 1,
                      R2.Left, R2.Bottom - 1, lsTinyDot)
                  else
                    HighlightCanvasLine(EditorCanvas, R1.Left, R1.Bottom - 1,
                      R2.Left, R2.Bottom - 1, FBlockMatchLineStyle);
                end;
              end
              else if (LogicLineNum < Pair.Bottom) and (LogicLineNum > Pair.Top) then
              begin
                // �ڲ��� [ ʱ����ʱ����Ҫ������е����ߣ����� Left ��
                if not Pair.DontDrawVert or FBlockMatchLineEnd then
                  HighlightCanvasLine(EditorCanvas, R1.Left, R1.Top, R1.Left,
                    R1.Bottom, FBlockMatchLineStyle);

                if FBlockMatchLineHori and (Pair.MiddleCount > 0) then
                begin
                  for J := 0 to Pair.MiddleCount - 1 do
                  begin
                    if LogicLineNum = Pair.MiddleToken[J].EditLine then
                    begin
                      EditPos2 := OTAEditPos(Pair.MiddleToken[J].EditCol, LineNum);
                      if not EditorGetEditPoint(EditPos2, R2) then
                        Continue;

                      // ������ĺ���
                      if FBlockMatchLineHoriDot then
                        HighlightCanvasLine(EditorCanvas, R1.Left, R1.Bottom - 1,
                          R2.Left, R2.Bottom - 1, lsTinyDot)
                      else
                        HighlightCanvasLine(EditorCanvas, R1.Left, R1.Bottom - 1,
                          R2.Left, R2.Bottom - 1, FBlockMatchLineStyle);

                      if FBlockMatchLineEnd then // ������ͷ�ϻ�����
                      begin
                        if FBlockMatchLineHoriDot and (Pair.MiddleToken[J].EditCol <> Pair.Left) then
                          EndLineStyle := lsTinyDot // �������߲�ͬ��ʱ�������߻���
                        else
                          EndLineStyle := FBlockMatchLineStyle;

                        HighlightCanvasLine(EditorCanvas, R2.Left, R2.Bottom - 1,
                          R2.Right, R2.Bottom - 1, EndLineStyle);
                        // HighlightCanvasLine(EditorCanvas, R2.Left, R2.Top,
                        //   R2.Right, R2.Top, EndLineStyle);
                        // HighlightCanvasLine(EditorCanvas, R2.Left, R2.Top,
                        //   R2.Left, R2.Bottom - 1, EndLineStyle);
                        // ��ֻ����
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;

        EditorCanvas.Pen.Color := SavePenColor;
        EditorCanvas.Pen.Width := SavePenWidth;
        EditorCanvas.Pen.Style := SavePenStyle;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
// ֪ͨ�¼�
//------------------------------------------------------------------------------

procedure TCnSourceHighlight.EditControlNotify(
  EditControl: TControl; EditWindow: TCustomForm; Operation: TOperation);
var
  Idx: Integer;
begin
  if Operation = opRemove then
  begin
    Idx := IndexOfBracket(EditControl);
    if Idx >= 0 then
    begin
      FBracketList.Delete(Idx);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('BracketList Index %d Deleted.', [Idx]);
{$ENDIF}
    end;

    Idx := IndexOfBlockMatch(EditControl);
    if Idx >= 0 then
    begin
      FBlockMatchList.Delete(Idx);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('BlockMatchList Index %d Deleted.', [Idx]);
{$ENDIF}
    end;

    Idx := IndexOfBlockLine(EditControl);
    if Idx >= 0 then
    begin
      FBlockLineList.Delete(Idx);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('BlockLineList Index %d Deleted.', [Idx]);
{$ENDIF}
    end;

    Idx := IndexOfCompDirectiveLine(EditControl);
    if Idx >= 0 then
    begin
      FCompDirectiveList.Delete(Idx);
{$IFDEF DEBUG}
      CnDebugger.LogFmt('CompDirectiveList Index %d Deleted.', [Idx]);
{$ENDIF}
    end;
  end;
end;

procedure TCnSourceHighlight.SourceEditorNotify(SourceEditor: IOTASourceEditor;
  NotifyType: TCnWizSourceEditorNotifyType; EditView: IOTAEditView);
begin
{$IFDEF UNICODE}
  if NotifyType = setClosing then
    FStructureTimer.OnTimer := nil
  else if (NotifyType = setOpened) or (NotifyType = setEditViewActivated) then
    FStructureTimer.OnTimer := OnHighlightTimer;
{$ENDIF}    
end;

procedure TCnSourceHighlight.ActiveFormChanged(Sender: TObject);
begin
  if Active and (FStructureHighlight or FBlockMatchDrawLine or FHilightSeparateLine
    {$IFNDEF BDS} or FHighLightCurrentLine {$ENDIF} or FHighlightFlowStatement
    or FCurrentTokenHighlight or FHighlightCompDirective) and (BlockHighlightStyle <> bsHotkey)
    and IsIdeEditorForm(Screen.ActiveForm) then
    CnWizNotifierServices.ExecuteOnApplicationIdle(OnHighlightExec);
end;

procedure TCnSourceHighlight.AfterCompile(Succeeded,
  IsCodeInsight: Boolean);
begin
  if Active and (not IsCodeInsight) and (FStructureHighlight or FBlockMatchDrawLine
    or FHilightSeparateLine {$IFNDEF BDS} or FHighLightCurrentLine {$ENDIF}
    or FHighlightFlowStatement or FCurrentTokenHighlight or FHighlightCompDirective)
    and (BlockHighlightStyle <> bsHotkey) and IsIdeEditorForm(Screen.ActiveForm) then
    CnWizNotifierServices.ExecuteOnApplicationIdle(OnHighlightExec);
end;

// EditorChange ʱ���ô��¼�ȥ������źͽṹ����
procedure TCnSourceHighlight.EditorChanged(Editor: TEditorObject;
  ChangeType: TEditorChangeTypes);
var
  EditorIndex: Integer;
begin
  if Active then
  begin
    if ctModified in ChangeType then
    begin
      FCurrentTokenValidateTimer.Enabled := False;
      FCurrentTokenValidateTimer.Enabled := True;
      FCurrentTokenInvalid := True;
    end;

    // �� View �л�ʱ���õײ㺯�������ǲ���ȫ�ģ����и�����Ҫ����ˢ��
    if ChangeType = [ctView] then
    begin
      ClearHighlight(Editor);
      if FViewChangedList.IndexOf(Editor) < 0 then
      begin
        FViewChangedList.Add(Editor);
        if IsDelphiSourceModule(Editor.EditView.Buffer.FileName)
          or IsInc(Editor.EditView.Buffer.FileName) then
          FViewFileNameIsPascalList.Add(Pointer(True))
        else
          FViewFileNameIsPascalList.Add(Pointer(False));
      end;
      Exit;
    end;  

    CharSize := EditControlWrapper.GetCharSize;

    if (ctFont in ChangeType) or (ctOptionChanged in ChangeType) then
    begin
      if ctFont in ChangeType then
      begin
        ReloadIDEFonts;
{$IFNDEF BDS}
        if FHighLightLineColor = FDefaultHighLightLineColor then
          FHighLightLineColor := LoadIDEDefaultCurrentColor;
{$ENDIF}
      end;
{$IFDEF BDS2009_UP}
      if ctOptionChanged in ChangeType then
      begin
        // ��¼��ǰ�Ƿ�ʹ�� Tab ���Լ� TabWidth
        UpdateTabWidth;
      end;
{$ENDIF}
      RepaintEditors;
    end;

    BeginUpdateEditor(Editor);
    try
      if FViewChangedList.IndexOf(Editor) >= 0 then
      begin
        EditorIndex := FViewChangedList.Remove(Editor);
        FViewFileNameIsPascalList.Delete(EditorIndex);
        ChangeType := ChangeType + [ctView];
      end;

      CheckBracketMatch(Editor);

      if FStructureHighlight or FBlockMatchDrawLine or FBlockMatchHighlight
        or FHighlightFlowStatement or FHilightSeparateLine
        {$IFNDEF BDS} or FHighLightCurrentLine {$ENDIF} then
      begin
        UpdateHighlight(Editor, ChangeType);
      end;
    finally
      EndUpdateEditor(Editor);
    end;
  end;
end;

procedure TCnSourceHighlight.PaintLine(Editor: TEditorObject;
  LineNum, LogicLineNum: Integer);
var
  AElided: Boolean;
begin
  if Active then
  begin
{$IFDEF BDS}
    // Ԥ�Ȼ�õ�ǰ�У����ػ�ʱ���½��� UTF8 λ�ü���
  {$IFDEF UNICODE}
    FUniLineText := EditControlWrapper.GetTextAtLine(Editor.EditControl,
      LogicLineNum);
    // Delphi 2009 �²��ý��ж���� UTF8 ת��
    FAnsiLineText := AnsiString(FUniLineText);
  {$ELSE}
    FAnsiLineText := Utf8ToAnsi(EditControlWrapper.GetTextAtLine(Editor.EditControl,
      LogicLineNum));
    FUniLineText := FAnsiLineText;
  {$ENDIF}
{$ELSE}
    CanDrawCurrentLine := False;
  {$IFDEF DEBUG}
//  CnDebugger.LogFmt('Source Highlight after PaintLine %8.8x', [Integer(Editor.EditControl)]);
  {$ENDIF}
    if FHighLightCurrentLine and ColorChanged and (PaintingControl = Editor.EditControl) then
    begin
      SetForeAndBackColorHook.UnhookMethod;
      TCustomControlHack(Editor.EditControl).Canvas.Brush.Color := OldBkColor;
      PaintingControl := nil;
      ColorChanged := False;
  {$IFDEF DEBUG}
//    CnDebugger.LogFmt('Source Highlight: Restore Old Back Color after PaintLine %d.', [LineNum]);
//    CnDebugger.LogColor(TCustomControlHack(Editor.EditControl).Canvas.Brush.Color, 'Source Highlight: Restore to Color.');
  {$ENDIF}
    end;
{$ENDIF}
    AElided := LineNum <> LogicLineNum;
    if FMatchedBracket then
      PaintBracketMatch(Editor, LineNum, LogicLineNum, AElided);
    if FStructureHighlight or FBlockMatchHighlight or FCurrentTokenHighlight
      or FHilightSeparateLine or FHighlightFlowStatement or FHighlightCompDirective then // ��ͷ˳��������ƥ�����
      PaintBlockMatchKeyword(Editor, LineNum, LogicLineNum, AElided);
    if FBlockMatchDrawLine then
      PaintBlockMatchLine(Editor, LineNum, LogicLineNum, AElided);
  end;
end;

//------------------------------------------------------------------------------
// ���Ｐ����
//------------------------------------------------------------------------------

function TCnSourceHighlight.GetBlockMatchHotkey: TShortCut;
begin
  Result := FBlockShortCut.ShortCut;
end;

procedure TCnSourceHighlight.SetBlockMatchHotkey(const Value: TShortCut);
begin
  FBlockShortCut.ShortCut := Value;
end;

procedure TCnSourceHighlight.SetActive(Value: Boolean);
begin
  inherited;
  RepaintEditors;
end;

procedure TCnSourceHighlight.Config;
begin
  ShowSourceHighlightForm(Self);
end;

procedure TCnSourceHighlight.LoadSettings(Ini: TCustomIniFile);
var
  I: Integer;
begin
  with TCnIniFile.Create(Ini) do
  try
    FMatchedBracket := ReadBool('', csMatchedBracket, FMatchedBracket);
    FBracketColor := ReadColor('', csBracketColor, FBracketColor);
    FBracketColorBk := ReadColor('', csBracketColorBk, FBracketColorBk);
    FBracketColorBd := ReadColor('', csBracketColorBd, FBracketColorBd);
    FBracketBold := ReadBool('', csBracketBold, FBracketBold);
    FBracketMiddle := ReadBool('', csBracketMiddle, FBracketMiddle);

    FStructureHighlight := ReadBool('', csStructureHighlight, FStructureHighlight);
    FBlockMatchHighlight := ReadBool('', csBlockMatchHighlight, FBlockMatchHighlight);
    FBlockMatchBackground := ReadColor('', csBlockMatchBackground, FBlockMatchBackground);
    FCurrentTokenHighlight := ReadBool('', csCurrentTokenHighlight, FCurrentTokenHighlight);
    FCurrentTokenForeground := ReadColor('', csCurrentTokenColor, FCurrentTokenForeground);
    FCurrentTokenBackground := ReadColor('', csCurrentTokenColorBk, FCurrentTokenBackground);
    FCurrentTokenBorderColor := ReadColor('', csCurrentTokenColorBd, FCurrentTokenBorderColor);
    FShowTokenPosAtGutter := ReadBool('', csShowTokenPosAtGutter, FShowTokenPosAtGutter);

    FHilightSeparateLine := ReadBool('', csHilightSeparateLine, FHilightSeparateLine);
    FSeparateLineColor := ReadColor('', csSeparateLineColor, FSeparateLineColor);
    FSeparateLineStyle := TCnLineStyle(ReadInteger('', csSeparateLineStyle, Ord(FSeparateLineStyle)));
    FSeparateLineWidth := ReadInteger('', csSeparateLineWidth, FSeparateLineWidth);
{$IFNDEF BDS}
    FHighLightLineColor := ReadColor('', csHighLightLineColor, FHighLightLineColor);
    FHighLightCurrentLine := ReadBool('', csHighLightCurrentLine, FHighLightCurrentLine);
{$ENDIF}
    FHighlightFlowStatement := ReadBool('', csHighlightFlowStatement, FHighlightFlowStatement);
    FFlowStatementBackground := ReadColor('', csFlowStatementBackground, FFlowStatementBackground);
    FFlowStatementForeground := ReadColor('', csFlowStatementForeground, FFlowStatementForeground);
    FHighlightCompDirective := ReadBool('', csHighlightCompDirective, FHighlightCompDirective);
    FCompDirectiveBackground := ReadColor('', csCompDirectiveBackground, FCompDirectiveBackground);

    FBlockHighlightRange := TBlockHighlightRange(ReadInteger('', csBlockHighlightRange,
      Ord(FBlockHighlightRange)));
    FBlockMatchDelay := ReadInteger('', csBlockMatchDelay, FBlockMatchDelay);
    FBlockMatchLineLimit := ReadBool('', csBlockMatchLineLimit, FBlockMatchLineLimit);
    FBlockMatchMaxLines := ReadInteger('', csBlockMatchMaxLines, FBlockMatchMaxLines);
    FBlockHighlightStyle := TBlockHighlightStyle(ReadInteger('', csBlockHighlightStyle,
      Ord(FBlockHighlightStyle)));
    FBlockMatchDrawLine := ReadBool('', csBlockMatchDrawLine, FBlockMatchDrawLine);
    FBlockMatchLineClass := ReadBool('', csBlockMatchLineClass, FBlockMatchLineClass);
    FBlockMatchLineStyle := TCnLineStyle(ReadInteger('', csBlockMatchLineStyle,
      Ord(FBlockMatchLineStyle)));
    FBlockMatchLineEnd := ReadBool('', csBlockMatchLineEnd, FBlockMatchLineEnd);
    FBlockMatchLineWidth := ReadInteger('', csBlockMatchLineWidth, FBlockMatchLineWidth);
    FBlockMatchLineHori := ReadBool('', csBlockMatchLineHori, FBlockMatchLineHori);
    FBlockMatchLineHoriDot := ReadBool('', csBlockMatchLineHoriDot, FBlockMatchLineHoriDot);

    for I := Low(FHighLightColors) to High(FHighLightColors) do
      FHighLightColors[I] := ReadColor('', csBlockMatchHighlightColor + IntToStr(I),
        HighLightDefColors[I]);
  finally
    Free;
  end;
end;

procedure TCnSourceHighlight.SaveSettings(Ini: TCustomIniFile);
var
  I: Integer;
begin
  with TCnIniFile.Create(Ini) do
  try
    WriteBool('', csMatchedBracket, FMatchedBracket);
    WriteColor('', csBracketColor, FBracketColor);
    WriteColor('', csBracketColorBk, FBracketColorBk);
    WriteColor('', csBracketColorBd, FBracketColorBd);
    WriteBool('', csBracketBold, FBracketBold);
    WriteBool('', csBracketMiddle, FBracketMiddle);

    WriteBool('', csStructureHighlight, FStructureHighlight);
    WriteBool('', csBlockMatchHighlight, FBlockMatchHighlight);
    WriteColor('', csBlockMatchBackground, FBlockMatchBackground);
    WriteBool('', csCurrentTokenHighlight, FCurrentTokenHighlight);
    WriteColor('', csCurrentTokenColor, FCurrentTokenForeground);
    WriteColor('', csCurrentTokenColorBk, FCurrentTokenBackground);
    WriteColor('', csCurrentTokenColorBd, FCurrentTokenBorderColor);
    WriteBool('', csShowTokenPosAtGutter, FShowTokenPosAtGutter);

    WriteBool('', csHilightSeparateLine, FHilightSeparateLine);
    WriteColor('', csSeparateLineColor, FSeparateLineColor);
    WriteInteger('', csSeparateLineStyle, Ord(FSeparateLineStyle));
    WriteInteger('', csSeparateLineWidth, FSeparateLineWidth);
{$IFNDEF BDS}
    WriteBool('', csHighLightCurrentLine, FHighLightCurrentLine);
    if FDefaultHighLightLineColor <> FHighLightLineColor then
      WriteColor('', csHighLightLineColor, FHighLightLineColor);
{$ENDIF}
    WriteBool('', csHighlightFlowStatement, FHighlightFlowStatement);
    WriteColor('', csFlowStatementBackground, FFlowStatementBackground);
    WriteColor('', csFlowStatementForeground, FFlowStatementForeground);
    WriteBool('', csHighlightCompDirective, FHighlightCompDirective);
    WriteColor('', csCompDirectiveBackground, FCompDirectiveBackground);

    WriteInteger('', csBlockHighlightRange, Ord(FBlockHighlightRange));
    WriteInteger('', csBlockMatchDelay, FBlockMatchDelay);
    WriteBool('', csBlockMatchLineLimit, FBlockMatchLineLimit);
    WriteInteger('', csBlockMatchMaxLines, FBlockMatchMaxLines);
    WriteInteger('', csBlockHighlightStyle, Ord(FBlockHighlightStyle));

    for I := Low(FHighLightColors) to High(FHighLightColors) do
      WriteColor('', csBlockMatchHighlightColor + IntToStr(I), FHighLightColors[I]);

    WriteBool('', csBlockMatchDrawLine, FBlockMatchDrawLine);
    WriteInteger('', csBlockMatchLineWidth, FBlockMatchLineWidth);
    WriteInteger('', csBlockMatchLineStyle, Ord(FBlockMatchLineStyle));
    WriteBool('', csBlockMatchLineClass, FBlockMatchLineClass);
    WriteBool('', csBlockMatchLineEnd, FBlockMatchLineEnd);
    WriteBool('', csBlockMatchLineHori, FBlockMatchLineHori);
    WriteBool('', csBlockMatchLineHoriDot, FBlockMatchLineHoriDot);
  finally
    Free;
  end;
end;

function TCnSourceHighlight.GetHasConfig: Boolean;
begin
  Result := True;
end;

class procedure TCnSourceHighlight.GetWizardInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnSourceHighlightWizardName;
  Author := SCnPack_Zjy + ';' + SCnPack_LiuXiao + ';' + SCnPack_Shenloqi;
  Email := SCnPack_ZjyEmail + ';' + SCnPack_LiuXiaoEmail + ';' + SCnPack_ShenloqiEmail;
  Comment := SCnSourceHighlightWizardComment;
end;

procedure TCnSourceHighlight.RepaintEditors;
var
  i: Integer;
  EditControl: TControl;
  Info: TBlockMatchInfo;
begin
  if not Active then
  begin
    FBracketList.Clear;
    FBlockMatchList.Clear;
    FBlockLineList.Clear;
    EditControlWrapper.RepaintEditControls;
  end
  else
  begin
    // ���༭�������ܱ༭����Infoδ����
    ReloadIDEFonts;
    for i := 0 to EditControlWrapper.EditorCount - 1 do
    begin
      EditControl := EditControlWrapper.Editors[i].EditControl;
      if IndexOfBlockMatch(EditControl) < 0 then
      begin
        Info := TBlockMatchInfo.Create(EditControl);
        FBlockMatchList.Add(Info);
      end;
    end;
    OnHighlightExec(nil);
  end;

  if not FShowTokenPosAtGutter then
    EventBus.PostEvent(EVENT_HIGHLIGHT_IDENT_POSITION);
end;

procedure TCnSourceHighlight.BeginUpdateEditor(Editor: TEditorObject);
begin
  if FDirtyList = nil then
    FDirtyList := TList.Create
  else
    FDirtyList.Clear;
end;

procedure TCnSourceHighlight.EndUpdateEditor(Editor: TEditorObject);
var
  I: Integer;
  NeedRefresh: Boolean;
{$IFDEF BDS}
  ALine, LLine, BottomLine: Integer;
{$ENDIF}
begin
  with Editor do
  begin
  {$IFDEF BDS}
    // ȥ�����۵�����
    for I := FDirtyList.Count - 1 downto 0 do
      if EditControlWrapper.GetLineIsElided(EditControl, Integer(FDirtyList[I])) then
        FDirtyList.Delete(I);

    // �������۵�
    NeedRefresh := False;
    if FDirtyList.Count > 0 then
    begin
      ALine := EditView.TopRow;
      LLine := ALine; // ��ʼ��ͬ
      BottomLine := EditView.BottomRow;

      while ALine <= BottomLine + 1 do // ���һ�У����յ��
      begin
        if EditControlWrapper.GetLineIsElided(EditControl, LLine) then
        begin
          Inc(LLine);
          Continue;
        end;
        if FDirtyList.IndexOf(Pointer(LLine)) >= 0 then
        begin
          EditControlWrapper.MarkLinesDirty(EditControl, ALine - EditView.TopRow, 1);
          NeedRefresh := True;
          FDirtyList.Remove(Pointer(LLine));
          if FDirtyList.Count = 0 then
            Break;
        end;
        Inc(LLine);
        Inc(ALine);
      end;
    end;
  {$ELSE}
    NeedRefresh := FDirtyList.Count > 0;
    for I := 0 to FDirtyList.Count - 1 do
      EditControlWrapper.MarkLinesDirty(EditControl, Integer(FDirtyList[I])
        - EditView.TopRow, 1);
  {$ENDIF}

    if NeedRefresh then
      EditControlWrapper.EditorRefresh(EditControl, True);

    FreeAndNil(FDirtyList);
  end;
end;

procedure TCnSourceHighlight.EditorMarkLineDirty(LineNum: Integer);
begin
  if (FDirtyList <> nil) and (FDirtyList.IndexOf(Pointer(LineNum)) < 0) then
    FDirtyList.Add(Pointer(LineNum));
end;

procedure TCnSourceHighlight.ReloadIDEFonts;
var
  AHighlight: THighlightItem;
begin
  if EditControlWrapper.IndexOfHighlight(csReservedWord) >= 0 then
  begin
    AHighlight := EditControlWrapper.Highlights[EditControlWrapper.IndexOfHighlight(csReservedWord)];

    FKeywordHighlight.ColorFg := AHighlight.ColorFg;
    FKeywordHighlight.ColorBk := AHighlight.ColorBk;
    FKeywordHighlight.Bold := AHighlight.Bold;
    FKeywordHighlight.Italic := AHighlight.Italic;
    FKeywordHighlight.Underline := AHighlight.Underline;
  end;

  if EditControlWrapper.IndexOfHighlight(csIdentifier) >= 0 then
  begin
    AHighlight := EditControlWrapper.Highlights[EditControlWrapper.IndexOfHighlight(csIdentifier)];

    FIdentifierHighlight.ColorFg := AHighlight.ColorFg;
    FIdentifierHighlight.ColorBk := AHighlight.ColorBk;
    FIdentifierHighlight.Bold := AHighlight.Bold;
    FIdentifierHighlight.Italic := AHighlight.Italic;
    FIdentifierHighlight.Underline := AHighlight.Underline;
  end;

  if EditControlWrapper.IndexOfHighlight(csCompDirective) >= 0 then
  begin
    AHighlight := EditControlWrapper.Highlights[EditControlWrapper.IndexOfHighlight(csCompDirective)];
{$IFDEF DEBUG}
    CnDebugger.LogMsg('Load IDE Font from Registry: ' + csCompDirective);
{$ENDIF}
    FCompDirectiveHighlight.ColorFg := AHighlight.ColorFg;
    FCompDirectiveHighlight.ColorBk := AHighlight.ColorBk;
    FCompDirectiveHighlight.Bold := AHighlight.Bold;
    FCompDirectiveHighlight.Italic := AHighlight.Italic;
    FCompDirectiveHighlight.Underline := AHighlight.Underline;
  end
  else // If no default settings saved in Registry, using default.
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('No IDE Font Found in Registry: ' + csCompDirective + '. Use Default.');
{$ENDIF}
{$IFDEF DELPHI5}
    // Delphi 5/6 ����ָ���ʽ��ע��һ��
    FCompDirectiveHighlight.ColorFg := clNavy;
    FCompDirectiveHighlight.Italic := True;
{$ELSE}
  {$IFDEF DELPHI6}
    FCompDirectiveHighlight.ColorFg := clNavy;
    FCompDirectiveHighlight.Italic := True;
  {$ELSE}
    // D7 �����ϼ� C/C++ ����ľ��ǲ�б����ɫ
    FCompDirectiveHighlight.ColorFg := clGreen;
  {$ENDIF}
{$ENDIF}
  end;
end;

procedure TCnSourceHighlight.RefreshCurrentTokens(Info: TBlockMatchInfo);
var
  I: Integer;
begin
  for I := 0 to Info.CurTokenCount - 1 do
    EditorMarkLineDirty(Info.CurTokens[I].EditLine);
end;

{$IFNDEF BDS}

procedure MyEditorsCustomEditControlSetForeAndBackColor(ASelf: TObject; Param1,
  Param2, Param3, Param4: Cardinal);
begin
  SetForeAndBackColorHook.UnhookMethod;
  try
    try
      // ����զ����Ҫ���þɵ�
      SetForeAndBackColor(ASelf, Param1, Param2, Param3, Param4);
    except
      on E: Exception do
        DoHandleException(E.Message);
    end;
  finally
    SetForeAndBackColorHook.HookMethod;
  end;

  // �ɵĵ�����Ϻ������Ҫ���ñ������ɫ
  if CanDrawCurrentLine and (ASelf = PaintingControl) and FHighlight.Active
    and FHighlight.HighLightCurrentLine then
  begin
    // ����ǵ�ǰ�����ı༭���ĵ�ǰ��
    if TCustomControlHack(ASelf).Canvas.Brush.Color <> FHighlight.HighLightLineColor then
    begin
      OldBkColor := TCustomControlHack(ASelf).Canvas.Brush.Color;
      TCustomControlHack(ASelf).Canvas.Brush.Color := FHighlight.HighLightLineColor;
      ColorChanged := True;

{$IFDEF DEBUG}
//    Cndebugger.LogFmt('Source Highlight: Set Current Line %d Back Color to Control %8.8x.',
//      [CurrentLineNum, Integer(PaintingControl)]);
{$ENDIF}
    end;
  end;
end;

procedure TCnSourceHighlight.SetHighLightCurrentLine(const Value: Boolean);
begin
  if FHighLightCurrentLine <> Value then
  begin
    FHighLightCurrentLine := Value;
    // ��λ���û������Ϊ Create ʱ���Ѿ� Hook ��
    if Value and (SetForeAndBackColorHook = nil) then
      SetForeAndBackColorHook := TCnMethodHook.Create(@SetForeAndBackColor,
        @MyEditorsCustomEditControlSetForeAndBackColor);

    if SetForeAndBackColorHook <> nil then
    begin
      if Value then
        SetForeAndBackColorHook.HookMethod
      else
        SetForeAndBackColorHook.UnhookMethod;
    end;
  end;
end;

procedure TCnSourceHighlight.SetHighLightLineColor(const Value: TColor);
begin
  if FHighLightLineColor <> Value then
  begin
    FHighLightLineColor := Value;
    // RepaintEditors;
  end;
end;

procedure TCnSourceHighlight.BeforePaintLine(Editor: TEditorObject;
  LineNum, LogicLineNum: Integer);
var
  CurLine: TCurLineInfo;
  EditPos: TOTAEditPos;
  Element, LineFlag: Integer;
  StartRow, EndRow: Integer;
begin
  // ֻ���ڵ� PaintLine ǰ������������ CanDrawCurrentLine Ϊ True
  // PaintLine ������������̽� CanDrawCurrentLine ��Ϊ False
  // ���� PaintLine ֮��ĵط����� SetForeAndBackColor ���¶��⸱����
  CanDrawCurrentLine := False;
  if IndexOfCurLine(Editor.EditControl) >= 0 then
    CurLine := TCurLineInfo(FCurLineList[IndexOfCurLine(Editor.EditControl)])
  else
    Exit;

  CanDrawCurrentLine := LineNum = CurLine.CurrentLine;
  PaintingControl := Editor.EditControl;
  if CanDrawCurrentLine then
  begin
    EditPos.Line := LineNum;
    EditPos.Col := Editor.EditView.CursorPos.Col;
    EditControlWrapper.GetAttributeAtPos(Editor.EditControl, EditPos, False,
      Element, LineFlag);
    CanDrawCurrentLine := (LineFlag = 0) and not (Element in [MarkedBlock, SearchMatch]);

    if CanDrawCurrentLine and (EditPos.Col > 1) then
    begin
      Dec(EditPos.Col);
      EditControlWrapper.GetAttributeAtPos(Editor.EditControl, EditPos, False,
        Element, LineFlag);
      CanDrawCurrentLine := not (Element in [MarkedBlock, SearchMatch]);
    end;

    if CanDrawCurrentLine then
    begin
      // DONE: ���뵱ǰ���Ƿ���ѡ�������ж�
      if Editor.EditView <> nil then
      begin
        if Editor.EditView.Block <> nil then
        begin
          if Editor.EditView.Block.IsValid then
          begin
            StartRow := Editor.EditView.Block.StartingRow;
            EndRow := Editor.EditView.Block.EndingRow;
            if (LineNum >= StartRow) and (LineNum <= EndRow) then
              CanDrawCurrentLine := False;
          end;
        end;
      end;
    end;
  end;
{$IFDEF DEBUG}
//  CurrentLineNum := LineNum;
//  CnDebugger.LogFmt('Source Highlight Line %d, CanDraw? %d. PaintControl %8.8x',
//    [LineNum, Integer(CanDrawCurrentLine), Integer(PaintingControl)]);
{$ENDIF}

  SetForeAndBackColorHook.HookMethod;
end;

function TCnSourceHighlight.IndexOfCurLine(EditControl: TControl): Integer;
var
  I: Integer;
begin
  for I := 0 to FCurLineList.Count - 1 do
    if TCurLineInfo(FCurLineList[i]).Control = EditControl then
    begin
      Result := I;
      Exit;
    end;
  Result := -1;
end;

{$ENDIF}

{$IFDEF BDS2009_UP}

function GetAvrTabWidth(TabWidthStr: string): Integer;
var
  sl: TStringList;
  prev: Integer;
  I: Integer;
begin
  sl := TStringList.Create();
  try
    sl.Delimiter := ' ';
    // The tab-string might separeted by ';', too
    if Pos(';', TabWidthStr) > 0 then
    begin
      // if so, use it
      sl.Delimiter := ';';
    end;
    sl.DelimitedText := TabWidthStr;
    Result := 0;
    prev := 0;
    for I := 0 to sl.Count - 1 do
    begin
      Inc(Result, StrToInt(sl[i]) - prev);
      prev := StrToInt(sl[i]);
    end;
    Result := Result div sl.Count;
  finally
    FreeAndNil(sl);
  end;
end;

procedure TCnSourceHighlight.UpdateTabWidth;
var
  Options: IOTAEnvironmentOptions;
begin
  FUseTabKey := False;
  FTabWidth := 2;
  Options := CnOtaGetEnvironmentOptions;
  if Options <> nil then
  begin
{$IFDEF DEBUG}
    CnDebugger.LogMsg('SourceHighlight: Editor Option Changed. Get UseTabKey is '
      + VarToStr(Options.GetOptionValue('UseTabCharacter')));
{$ENDIF}
    try
      FTabWidth := GetAvrTabWidth(Options.GetOptionValue('TabStops'));
    except
      ;
    end;
    if VarToStr(Options.GetOptionValue('UseTabCharacter')) = 'True' then
      FUseTabKey := True;
  end;
end;

{$ENDIF}

function LoadIDEDefaultCurrentColor: TColor;
var
  AHighlight: THighlightItem;
begin
  Result := $00E6FFFA;  // Ĭ��
  if EditControlWrapper.IndexOfHighlight(csWhiteSpace) >= 0 then
  begin
    AHighlight := EditControlWrapper.Highlights[EditControlWrapper.IndexOfHighlight(csWhiteSpace)];

    case AHighlight.ColorBk of
      clWhite: Result := $00E6FFFA;
      clNavy:  Result := $009999CC;
      clBlack: Result := $00505050;
      clAqua:  Result := $00CCFFCC;
    end;
  end;
end;

procedure TCnSourceHighlight.SetHilightSeparateLine(const Value: Boolean);
begin
  FHilightSeparateLine := Value;
end;

procedure TCnSourceHighlight.SetFlowStatementBackground(
  const Value: TColor);
begin
  FFlowStatementBackground := Value;
end;

procedure TCnSourceHighlight.SetHighlightFlowStatement(
  const Value: Boolean);
begin
  FHighlightFlowStatement := Value;
end;

procedure TCnSourceHighlight.SetFlowStatementForeground(
  const Value: TColor);
begin
  FFlowStatementForeground := Value;
end;


procedure TCnSourceHighlight.SetCompDirectiveBackground(
  const Value: TColor);
begin
  FCompDirectiveBackground := Value;
end;

procedure TCnSourceHighlight.SetHighlightCompDirective(
  const Value: Boolean);
begin
  FHighlightCompDirective := Value;
end;

procedure TCnSourceHighlight.EditorKeyDown(Key, ScanCode: Word;
  Shift: TShiftState; var Handled: Boolean);
begin
  if (Shift = []) and ((Key = VK_LEFT) or (Key = VK_UP) or
    (Key = VK_RIGHT) or (Key = VK_DOWN) or (Key = VK_PRIOR) or
    (Key = VK_NEXT))
  then
    Exit;

  FCurrentTokenValidateTimer.Enabled := False;
  FCurrentTokenValidateTimer.Enabled := True;
  FCurrentTokenInvalid := True;
end;

procedure TCnSourceHighlight.OnCurrentTokenValidateTimer(Sender: TObject);
var
  I: Integer;
  Info: TBlockMatchInfo;
begin
  FCurrentTokenValidateTimer.Enabled := False;
  FCurrentTokenInvalid := False;
  for I := 0 to FBlockMatchList.Count - 1 do
  begin
    Info := TBlockMatchInfo(FBlockMatchList[I]);
    Info.Control.Invalidate;
  end;
end;

{ TBlockLinePair }

procedure TBlockLinePair.AddMidToken(const Token: TCnPasToken;
  const LineLeft: Integer);
begin
  if Token <> nil then
  begin
    FMiddleTokens.Add(Token);
    if Left > LineLeft then
      Left := LineLeft;
  end;
end;

constructor TBlockLinePair.Create;
begin
  FMiddleTokens := TList.Create;
end;

destructor TBlockLinePair.Destroy;
begin
  FMiddleTokens.Free;
  inherited;
end;

function TBlockLinePair.GetMiddleCount: Integer;
begin
  Result := FMiddleTokens.Count;
end;

function TBlockLinePair.GetMiddleToken(Index: Integer): TCnPasToken;
begin
  if (Index >= 0) and (Index < FMiddleTokens.Count) then
    Result := TCnPasToken(FMiddleTokens[Index])
  else
    Result := nil;
end;

function TBlockLinePair.IndexOfMiddleToken(
  const Token: TCnPasToken): Integer;
begin
  Result := FMiddleTokens.IndexOf(Token);
end;

function TBlockLinePair.IsInMiddle(const LineNum: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to FMiddleTokens.Count - 1 do
    if MiddleToken[I].EditLine = LineNum then
    begin
      Result := True;
      Exit;
    end;
end;

{ TBlockLineInfo }

procedure TBlockLineInfo.AddPair(Pair: TBlockLinePair);
begin
  FPairList.Add(Pair);
end;

procedure TBlockLineInfo.Clear;
begin
  FPairList.Clear;
  FKeyLineList.Clear;
end;

constructor TBlockLineInfo.Create(AControl: TControl);
begin
  inherited Create;
  FControl := AControl;
  FPairList := TCnObjectList.Create;
  FKeyLineList := TCnObjectList.Create;
end;

destructor TBlockLineInfo.Destroy;
begin
  Clear;
  FPairList.Free;
  FKeyLineList.Free;
  inherited;
end;

procedure TBlockLineInfo.FindCurrentPair(View: IOTAEditView;
  IsCppModule: Boolean);
var
  I: Integer;
  Col: SmallInt;
  Line: TCnList;
  Pair: TBlockLinePair;
  Text: AnsiString;
  LineNo, CharIndex, Len: Integer;
  StartIndex, EndIndex: Integer;
  PairIndex: Integer;

  // �жϱ�ʶ���Ƿ��ڹ����
  function InternalIsCurrentToken(Token: TCnPasToken): Boolean;
  begin
    Result := (Token <> nil) and // (Token.IsBlockStart or Token.IsBlockClose) and
      (Token.EditLine = LineNo) and (Token.EditCol <= EndIndex) and
      (Token.EditCol >= StartIndex);
  end;

  // �ж�һ�� Pair �Ƿ��� Middle �� Token �ڹ����
  function IndexOfCurrentMiddleToken(Pair: TBlockLinePair): Integer;
  var
    I: Integer;
  begin
    Result := -1;
    for I := 0 to Pair.MiddleCount - 1 do
      if InternalIsCurrentToken(Pair.MiddleToken[I]) then
      begin
        Result := I;
        Exit;
      end;
  end;

begin
  FCurrentPair := nil;
  FCurrentToken := nil;

  if _UNICODE_STRING and CodePageOnlySupportsEnglish then // ��Ӣ�� Unicode �����²���ֱ��ת Ansi
    Text := ConvertUtf16ToAlterAnsi(PWideChar(GetStrProp(FControl, 'LineText')), 'C')
  else
    Text := AnsiString(GetStrProp(FControl, 'LineText'));

  Col := View.CursorPos.Col;
{$IFDEF BDS}
  // TODO: �� TextWidth ��ù��λ�þ�ȷ��Ӧ��Դ���ַ�λ�ã���ʵ�ֽ��ѡ�
  // ������ռ�ݵ��ַ�λ�õ�˫�ֽ��ַ�ʱ�������㷨����ƫ�

  // D2007 �����°汾��õ��� UTF8 �ַ����� Pos����Ҫת���� Ansi �ģ�
  // �� D2009 �� LineText ������ UnicodeString�������Ѿ� Ansi ���ˣ������ٴ�ת��
  if Text <> '' then
  begin
    {$IFNDEF UNICODE}
    Col := Length(CnUtf8ToAnsi(Copy(Text, 1, Col)));
    Text := CnUtf8ToAnsi(Text);
    {$ENDIF}
  end;
{$ENDIF}
  LineNo := View.CursorPos.Line;

  // ��֪Ϊ������˴�����Ч
  if IsCppModule then
    CharIndex := Min(Col, Length(Text))
  else
    CharIndex := Min(Col - 1, Length(Text));

  Len := Length(Text);

  // �ҵ���ʼ StartIndex
  StartIndex := CharIndex;
  if not IsCppModule then
  begin
    while (StartIndex > 0) and (Text[StartIndex] in AlphaNumeric) do
      Dec(StartIndex);
  end
  else
  begin
    while (StartIndex > 0) and (Text[StartIndex] in AlphaNumeric + ['{', '}']) do
      Dec(StartIndex);
  end;

  EndIndex := CharIndex;
  while EndIndex < Len do
  begin
    // �������ҵ�����ĸ���־�����������ɷ���ĸ���֣����Ҳ���������ĸ֮ǰ��
    if (not (Text[EndIndex] in AlphaNumeric)) and not
     ((EndIndex = CharIndex) and (Text[EndIndex + 1] in AlphaNumeric)) then
      Break;
    Inc(EndIndex);
  end;

  if (LineNo < LineCount) and (Lines[LineNo] <> nil) then
  begin
    Line := Lines[LineNo];
    for I := 0 to Line.Count - 1 do
    begin
      Pair := TBlockLinePair(Line[I]);
      if InternalIsCurrentToken(Pair.StartToken) then
      begin
        FCurrentPair := Pair;
        FCurrentToken := Pair.StartToken;
        Exit;
      end
      else if InternalIsCurrentToken(Pair.EndToken) then
      begin
        FCurrentPair := Pair;
        FCurrentToken := Pair.EndToken;
        Exit;
      end
      else
      begin
        PairIndex := IndexOfCurrentMiddleToken(Pair);
        if PairIndex >= 0 then
        begin
          FCurrentPair := Pair;
          FCurrentToken := Pair.MiddleToken[PairIndex];
          Exit;
        end;
      end;
    end;
  end;
end;

function TBlockLineInfo.GetCount: Integer;
begin
  Result := FPairList.Count;
end;

function TBlockLineInfo.GetLineCount: Integer;
begin
  Result := FKeyLineList.Count;
end;

function TBlockLineInfo.GetLines(LineNum: Integer): TCnList;
begin
  Result := TCnList(FKeyLineList[LineNum]);
end;

function TBlockLineInfo.GetPairs(Index: Integer): TBlockLinePair;
begin
  Result := TBlockLinePair(FPairList[Index]);
end;

procedure TBlockLineInfo.ConvertLineList;
var
  I, J: Integer;
  Pair: TBlockLinePair;
  MaxLine: Integer;
begin
  MaxLine := 0;
  for I := 0 to FPairList.Count - 1 do
  begin
    if Pairs[I].FBottom > MaxLine then
      MaxLine := Pairs[I].FBottom;
  end;
  FKeyLineList.Count := MaxLine + 1;

  for I := 0 to FPairList.Count - 1 do
  begin
    Pair := Pairs[I];
    for J := Pair.FTop to Pair.FBottom do
    begin
      if FKeyLineList[J] = nil then
        FKeyLineList[J] := TCnList.Create;
      TCnList(FKeyLineList[J]).Add(Pair);
    end;
  end;
end;

{ TCurLineInfo }

constructor TCurLineInfo.Create(AControl: TControl);
begin
  FControl := AControl;
end;

destructor TCurLineInfo.Destroy;
begin
  inherited;

end;

{ TCompDirectiveInfo }

procedure TCompDirectiveInfo.FindCurrentPair(View: IOTAEditView;
  IsCppModule: Boolean);
var
  I: Integer;
  Col: SmallInt;
  Line: TCnList;
  Pair: TBlockLinePair;
  Text: AnsiString;
  LineNo, CharIndex: Integer;
  PairIndex: Integer;

  // �жϱ�ʶ�������Ƿ��ڹ�����ˣ���BlockInfo����������ͬ
  function InternalIsCurrentToken(Token: TCnPasToken): Boolean;
  begin
    Result := (Token <> nil) and // (Token.IsBlockStart or Token.IsBlockClose) and
      (Token.EditLine = LineNo) and (Token.EditCol <= CharIndex + 1) and
      ((Token.EditCol + Integer(StrLen(Token.Token)) >= CharIndex + 1));
  end;

  // �ж�һ�� Pair �Ƿ��� Middle �� Token �ڹ����
  function IndexOfCurrentMiddleToken(Pair: TBlockLinePair): Integer;
  var
    I: Integer;
  begin
    Result := -1;
    for I := 0 to Pair.MiddleCount - 1 do
      if InternalIsCurrentToken(Pair.MiddleToken[I]) then
      begin
        Result := I;
        Exit;
      end;
  end;

begin
  FCurrentPair := nil;
  FCurrentToken := nil;

  if _UNICODE_STRING and CodePageOnlySupportsEnglish then // ��Ӣ�� Unicode �����²���ֱ��ת Ansi
    Text := ConvertUtf16ToAlterAnsi(PWideChar(GetStrProp(FControl, 'LineText')), 'C')
  else
    Text := AnsiString(GetStrProp(FControl, 'LineText'));

  Col := View.CursorPos.Col;
{$IFDEF BDS}
  // TODO: �� TextWidth ��ù��λ�þ�ȷ��Ӧ��Դ���ַ�λ�ã���ʵ�ֽ��ѡ�
  // ������ռ�ݵ��ַ�λ�õ�˫�ֽ��ַ�ʱ�������㷨����ƫ�

  // ��õ��� UTF8 �ַ����� Pos����Ҫת���� Ansi �ģ��� D2009 ����ת��
  if Text <> '' then
  begin
    {$IFDEF UNICODE}
    //Col := Length(CnUtf8ToAnsi(Copy(CnAnsiToUtf8(Text), 1, Col)));
    {$ELSE}
    Col := Length(CnUtf8ToAnsi(Copy(Text, 1, Col)));
    Text := CnUtf8ToAnsi(Text);
    {$ENDIF}
  end;
{$ENDIF}
  LineNo := View.CursorPos.Line;

  // ��֪Ϊ������˴�����Ч
  if IsCppModule then
    CharIndex := Min(Col, Length(Text))
  else
    CharIndex := Min(Col - 1, Length(Text));

  if (LineNo < LineCount) and (Lines[LineNo] <> nil) then
  begin
    Line := Lines[LineNo];
    for I := 0 to Line.Count - 1 do
    begin
      Pair := TBlockLinePair(Line[I]);
      if InternalIsCurrentToken(Pair.StartToken) then
      begin
        FCurrentPair := Pair;
        FCurrentToken := Pair.StartToken;
        Exit;
      end
      else if InternalIsCurrentToken(Pair.EndToken) then
      begin
        FCurrentPair := Pair;
        FCurrentToken := Pair.EndToken;
        Exit;
      end
      else
      begin
        PairIndex := IndexOfCurrentMiddleToken(Pair);
        if PairIndex >= 0 then
        begin
          FCurrentPair := Pair;
          FCurrentToken := Pair.MiddleToken[PairIndex];
          Exit;
        end;
      end;
    end;
  end;
end;

initialization
  RegisterCnWizard(TCnSourceHighlight);

{$ENDIF CNWIZARDS_CNSOURCEHIGHLIGHT}
end.
