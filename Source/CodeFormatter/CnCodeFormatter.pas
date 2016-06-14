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

unit CnCodeFormatter;
{* |<PRE>
================================================================================
* ������ƣ�CnPack �����ʽ��ר��
* ��Ԫ���ƣ���ʽ��ר�Һ����� CnCodeFormater
* ��Ԫ���ߣ�CnPack������
* ��    ע���õ�Ԫʵ���˴����ʽ���ĺ�����
* ����ƽ̨��Win2003 + Delphi 5.0
* ���ݲ��ԣ�not test yet
* �� �� ����not test hell
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2003.12.16 V0.4
*               �������ʵ�֣��޴�Ĺ�������ʹ�õݹ��½�����������������ʵ����
*               Delphi 5 �� Object Pascal �﷨�����������ʽ�ϰ���������������
*               ���ִ�Сд�����á�
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, Windows, Dialogs, Contnrs, CnHashMap,
  CnTokens, CnScaners, CnCodeGenerators, CnCodeFormatRules, CnFormatterIntf;

const
  CN_MATCHED_INVALID = -1;

type
  TCnGoalType = (gtUnknown, gtProgram, gtLibrary, gtUnit, gtPackage);

  TCnElementStack = class(TStack)
  public
    function Contains(ElementTypes: TCnPascalFormattingElementTypeSet): Boolean;
  end;

  TCnAbstractCodeFormatter = class
  private
    FScaner: TAbstractScaner;
    FCodeGen: TCnCodeGenerator;
    FLastToken: TPascalToken;
    FInternalRaiseException: Boolean;
    FSliceMode: Boolean;
    FMatchedInStart: Integer;
    FMatchedOutStartRow: Integer;
    FMatchedOutStartCol: Integer;
    FMatchedOutEndCol: Integer;
    FMatchedInEnd: Integer;
    FMatchedOutEndRow: Integer;
    FFirstMatchStart: Boolean;
    FFirstMatchEnd: Boolean;
    // �������Լ�¼��ǰ���ڸ�ʽ���ĵ㣬�Ա����ʱ���ݳ����ж��Ƿ�ʹ�ùؼ��ֹ���
    FOldElementTypes: TCnElementStack;
    FElementType: TCnPascalFormattingElementType;
    FPrefixSpaces: Integer;
    FEnsureOneEmptyLine: Boolean;

    FNamesMap: TCnStrToStrHashMap;
    FInputLineMarks: TList;         // Դ��������ӳ���ϵ�е�Դ��
    FOutputLineMarks: TList;        // Դ��������ӳ���ϵ�еĽ����
    function ErrorTokenString: string;
    procedure CodeGenAfterWrite(Sender: TObject; IsWriteBlank: Boolean;
      IsWriteln: Boolean; PrefixSpaces: Integer);

    // ���ֵ�ǰ��λ�ã��������ʹ��
    procedure SpecifyElementType(Element: TCnPascalFormattingElementType);
    procedure RestoreElementType;
    // ���ֵ�ǰλ�ò��ָ����������ʹ��
    function UpperContainElementType(ElementTypes: TCnPascalFormattingElementTypeSet): Boolean;
    // �ϲ��Ƿ����ָ���ļ��� ElementType ֮һ����������ǰ
    function CurrentContainElementType(ElementTypes: TCnPascalFormattingElementTypeSet): Boolean;
    // �ϲ��뵱ǰ�Ƿ����ָ���ļ��� ElementType ֮һ

    procedure ResetElementType;
    function CalcNeedPadding: Boolean;
    function CalcNeedPaddingAndUnIndent: Boolean;
    procedure WriteOneSpace;
  protected
    FIsTypeID: Boolean;
    {* �������� }
    procedure Error(const Ident: Integer);
    procedure ErrorFmt(const Ident: Integer; const Args: array of const);
    procedure ErrorStr(const Message: string);
    procedure ErrorToken(Token: TPascalToken);
    procedure ErrorTokens(Tokens: array of TPascalToken);
    procedure ErrorExpected(Str: string);
    procedure ErrorNotSurpport(FurtureStr: string);

    procedure CheckHeadComments;
    {* ������뿪ʼ֮ǰ��ע��}
    function CanBeSymbol(Token: TPascalToken): Boolean;
    procedure Match(Token: TPascalToken; BeforeSpaceCount: Byte = 0;
      AfterSpaceCount: Byte = 0; IgnorePreSpace: Boolean = False;
      SemicolonIsLineStart: Boolean = False; NoSeparateSpace: Boolean = False);
    procedure MatchOperator(Token: TPascalToken); //������
    procedure WriteToken(Token: TPascalToken; BeforeSpaceCount: Byte = 0;
      AfterSpaceCount: Byte = 0; IgnorePreSpace: Boolean = False;
      SemicolonIsLineStart: Boolean = False; NoSeparateSpace: Boolean = False);

    function CheckIdentifierName(const S: string): string;
    {* �������ַ����Ƿ���һ���ⲿָ���ı�ʶ����������򷵻���ȷ�ĸ�ʽ }
    function Tab(PreSpaceCount: Byte = 0; CareBeginBlock: Boolean = True): Byte;
    {* ���ݴ����ʽ������÷�������һ�ε�ǰ���ո�����
       CareBeginBlock ���ڴ��������� begin ʱ��begin �Ƿ���Ҫ�������� if then
       ��� begin ������������ try ��� begin ����Ҫ������ }
    function BackTab(PreSpaceCount: Byte = 0; CareBeginBlock: Boolean = True): Integer;
    {* ���ݴ����ʽ������÷�����һ��������ǰ���ո��� }
    function Space(Count: Word): string;
    {* ����ָ����Ŀ�ո���ַ��� }
    procedure Writeln;
    {* ��ʽ������� }
    procedure WriteLine; 
    {* ��ʽ�����һ���� }
    procedure EnsureOneEmptyLine;
    {* ��ʽ�����֤��ǰ����һ����}
    procedure WriteBlankLineByPrevCondition;
    {* ������һ���Ƿ��������������������������������س�����˫�س��Ŀ��У�ĳЩ��������ȡ�� WriteLine}
    procedure WriteLineFeedByPrevCondition;
    {* ������һ���Ƿ��������������������������������л��ǵ����س���ĳЩ��������ȡ�� Writeln}
    function FormatString(const KeywordStr: string; KeywordStyle: TKeywordStyle): string;
    {* ����ָ���ؼ��ַ����ַ���}
    function UpperFirst(const KeywordStr: string): string;
    {* ��������ĸ��д���ַ���}
    property CodeGen: TCnCodeGenerator read FCodeGen;
    {* Ŀ�����������}
    property Scaner: TAbstractScaner read FScaner;
    {* �ʷ�ɨ����}
    property ElementType: TCnPascalFormattingElementType read FElementType;
    {* ��ʶ��ǰ�����һ����������}
  public
    constructor Create(AStream: TStream; AMatchedInStart: Integer = CN_MATCHED_INVALID;
      AMatchedInEnd: Integer = CN_MATCHED_INVALID;
      ACompDirectiveMode: TCompDirectiveMode = cdmAsComment);
    destructor Destroy; override;

    procedure SpecifyIdentifiers(Names: PLPSTR); overload;
    {* �� PPAnsiChar ��ʽ������ַ�ָ�����飬����ָ���ض����ŵĴ�Сд}
    procedure SpecifyIdentifiers(Names: TStrings); overload;
    {* �� TStrings ��ʽ������ַ���������ָ���ض����ŵĴ�Сд}
    procedure SpecifyLineMarks(Marks: PDWORD);
    {* �� PDWORD ָ������ķ�ʽ�����Դ�ļ�����ӳ�����}

    procedure FormatCode(PreSpaceCount: Byte = 0); virtual; abstract;
    procedure SaveToFile(FileName: string);
    procedure SaveToStream(Stream: TStream);
    procedure SaveToStrings(AStrings: TStrings);
    procedure SaveOutputLineMarks(var Marks: PDWORD);
    {* ����ʽ������е���ӳ�������Ƶ������У�����ָ����������ͷ�}

    property SliceMode: Boolean read FSliceMode write FSliceMode;
    {* Ƭ��ģʽ���������ơ�Ϊ True ʱ���� EOF Ӧ��ƽ���˳���������}
    property MatchedInStart: Integer read FMatchedInStart write FMatchedInStart;
    {* ����Ҫ Scaner ���������ʼλ��ʱ�����¼�ʱ���ã�����Ƭ��ģʽ}
    property MatchedInEnd: Integer read FMatchedInEnd write FMatchedInEnd;
    {* ����Ҫ Scaner ������˽���λ��ʱ�����¼�ʱ���ã�����Ƭ��ģʽ}

    property MatchedOutStartRow: Integer read FMatchedOutStartRow write FMatchedOutStartRow;
    property MatchedOutStartCol: Integer read FMatchedOutStartCol write FMatchedOutStartCol;
    property MatchedOutEndRow: Integer read FMatchedOutEndRow write FMatchedOutEndRow;
    property MatchedOutEndCol: Integer read FMatchedOutEndCol write FMatchedOutEndCol;

    property InputLineMarks: TList read FInputLineMarks;
    property OutputLineMarks: TList read FOutputLineMarks;
  end;

  TCnBasePascalFormatter = class(TCnAbstractCodeFormatter)
  private
    FGoalType: TCnGoalType;
    FNextBeginShouldIndent: Boolean; // �����Ƿ� begin ���뻻�м�ʹ����Ϊ SameLine
    FStructStmtEmptyEnd: Boolean;    // ��ǽṹ���Ľ�������Ƿ��ǿ���䣬�������ƺ��浥���ֺŵ�λ��
    function IsTokenAfterAttributesInSet(InTokens: TPascalTokenSet): Boolean;
    procedure CheckWriteBeginln;
  protected
    // IndentForAnonymous �������������ڲ����ܳ��ֵ���������������
    procedure FormatExprList(PreSpaceCount: Byte = 0; IndentForAnonymous: Byte = 0);
    procedure FormatExpression(PreSpaceCount: Byte = 0; IndentForAnonymous: Byte = 0);
    procedure FormatSimpleExpression(PreSpaceCount: Byte = 0; IndentForAnonymous: Byte = 0);
    procedure FormatTerm(PreSpaceCount: Byte = 0; IndentForAnonymous: Byte = 0);
    procedure FormatFactor(PreSpaceCount: Byte = 0; IndentForAnonymous: Byte = 0);
    procedure FormatDesignator(PreSpaceCount: Byte = 0; IndentForAnonymous: Byte = 0);
    procedure FormatDesignatorList(PreSpaceCount: Byte = 0);
    procedure FormatQualID(PreSpaceCount: Byte = 0);
    procedure FormatTypeID(PreSpaceCount: Byte = 0);
    procedure FormatIdent(PreSpaceCount: Byte = 0; const CanHaveUnitQual: Boolean = True);
    procedure FormatIdentList(PreSpaceCount: Byte = 0; const CanHaveUnitQual: Boolean = True);
    procedure FormatConstExpr(PreSpaceCount: Byte = 0);
    procedure FormatConstExprInType(PreSpaceCount: Byte = 0);
    procedure FormatSetConstructor(PreSpaceCount: Byte = 0);

    // ����֧��
    procedure FormatFormalTypeParamList(PreSpaceCount: Byte = 0);
    function FormatTypeParams(PreSpaceCount: Byte = 0; AllowFixEndGreateEqual: Boolean = False): Boolean;
    // AllowFixEndGreateEqual ���������ͽ�β >= ����������� True ��ʾ������ >=
    procedure FormatTypeParamDeclList(PreSpaceCount: Byte = 0);
    procedure FormatTypeParamDecl(PreSpaceCount: Byte = 0);
    procedure FormatTypeParamList(PreSpaceCount: Byte = 0);
    procedure FormatTypeParamIdentList(PreSpaceCount: Byte = 0);
    procedure FormatTypeParamIdent(PreSpaceCount: Byte = 0);

    // Anonymouse function support moving
    procedure FormatProcedureDecl(PreSpaceCount: Byte = 0; IsAnonymous: Boolean = False);
    procedure FormatFunctionDecl(PreSpaceCount: Byte = 0; IsAnonymous: Boolean = False);
    {* �� AllowEqual ���� ProcType �� ProcDecl �ɷ�����ںŵ�����}
    procedure FormatFunctionHeading(PreSpaceCount: Byte = 0; AllowEqual: Boolean = True);
    procedure FormatProcedureHeading(PreSpaceCount: Byte = 0; AllowEqual: Boolean = True);
    procedure FormatMethodName(PreSpaceCount: Byte = 0);
    procedure FormatFormalParameters(PreSpaceCount: Byte = 0);
    procedure FormatFormalParm(PreSpaceCount: Byte = 0);
    procedure FormatParameter(PreSpaceCount: Byte = 0);
    procedure FormatSimpleType(PreSpaceCount: Byte = 0);
    procedure FormatSubrangeType(PreSpaceCount: Byte = 0);
    procedure FormatDirective(PreSpaceCount: Byte = 0; IgnoreFirst: Boolean = False);
    procedure FormatBlock(PreSpaceCount: Byte = 0; IsInternal: Boolean = False;
      MultiCompound: Boolean = False);
    // MultiCompound ���ƿɴ��������е� begin end�����׺� program/library ���� begin end ������
    // �������׺�Ƕ�׵Ĺ��̺�������������Ŀǰ��ʱ����

    procedure FormatProgramInnerBlock(PreSpaceCount: Byte = 0; IsInternal: Boolean = False;
      IsLib: Boolean = False);
    // Program �е��� begin end ֮ǰ��������ͬ��Ƕ�� fucntion ������������˴˴�����

    procedure FormatDeclSection(PreSpaceCount: Byte; IndentProcs: Boolean = True;
      IsInternal: Boolean = False);

    procedure FormatCompoundStmt(PreSpaceCount: Byte = 0);
    procedure FormatStmtList(PreSpaceCount: Byte = 0);
    procedure FormatAsmBlock(PreSpaceCount: Byte = 0);
    procedure FormatStatement(PreSpaceCount: Byte = 0);
    procedure FormatLabel(PreSpaceCount: Byte = 0);
    procedure FormatSimpleStatement(PreSpaceCount: Byte = 0);
    procedure FormatStructStmt(PreSpaceCount: Byte = 0);
    procedure FormatIfStmt(PreSpaceCount: Byte = 0; IgnorePreSpace: Boolean = False);
    {* IgnorePreSpace ��Ϊ�˿��� else if ������}
    procedure FormatCaseLabel(PreSpaceCount: Byte = 0);
    procedure FormatCaseSelector(PreSpaceCount: Byte = 0);
    procedure FormatCaseStmt(PreSpaceCount: Byte = 0);
    procedure FormatRepeatStmt(PreSpaceCount: Byte = 0);
    procedure FormatWhileStmt(PreSpaceCount: Byte = 0);
    procedure FormatForStmt(PreSpaceCount: Byte = 0);
    procedure FormatWithStmt(PreSpaceCount: Byte = 0);
    procedure FormatTryStmt(PreSpaceCount: Byte = 0);
    procedure FormatTryEnd(PreSpaceCount: Byte = 0);
    procedure FormatExceptionHandler(PreSpaceCount: Byte = 0);
    procedure FormatRaiseStmt(PreSpaceCount: Byte = 0);

    procedure FormatLabelDeclSection(PreSpaceCount: Byte = 0);
    procedure FormatConstSection(PreSpaceCount: Byte = 0);
    procedure FormatConstantDecl(PreSpaceCount: Byte = 0);
    procedure FormatVarSection(PreSpaceCount: Byte = 0);
    procedure FormatVarDecl(PreSpaceCount: Byte = 0);
    procedure FormatProcedureDeclSection(PreSpaceCount: Byte = 0);
    procedure FormatSingleAttribute(PreSpaceCount: Byte = 0);
    procedure FormatType(PreSpaceCount: Byte = 0; IgnoreDirective: Boolean = False);
    procedure FormatSetType(PreSpaceCount: Byte = 0);
    procedure FormatFileType(PreSpaceCount: Byte = 0);
    procedure FormatPointerType(PreSpaceCount: Byte = 0);
    procedure FormatProcedureType(PreSpaceCount: Byte = 0);

    procedure FormatRestrictedType(PreSpaceCount: Byte = 0);
    procedure FormatClassRefType(PreSpaceCount: Byte = 0);
    procedure FormatOrdinalType(PreSpaceCount: Byte = 0; FromSetOf: Boolean = False);
    procedure FormatEnumeratedType(PreSpaceCount: Byte = 0);
    procedure FormatEnumeratedList(PreSpaceCount: Byte = 0);
    procedure FormatEmumeratedIdent(PreSpaceCount: Byte = 0);
    procedure FormatStringType(PreSpaceCount: Byte = 0);
    procedure FormatStructType(PreSpaceCount: Byte = 0);
    procedure FormatArrayType(PreSpaceCount: Byte = 0);
    procedure FormatRecType(PreSpaceCount: Byte = 0);
    procedure FormatFieldList(PreSpaceCount: Byte = 0; IgnoreFirst: Boolean = False);
    procedure FormatTypeSection(PreSpaceCount: Byte = 0);
    procedure FormatTypeDecl(PreSpaceCount: Byte = 0);
    procedure FormatTypedConstant(PreSpaceCount: Byte = 0);

    procedure FormatArrayConstant(PreSpaceCount: Byte = 0);
    procedure FormatRecordConstant(PreSpaceCount: Byte = 0);
    procedure FormatRecordFieldConstant(PreSpaceCount: Byte = 0);

    {* ���� record �� case �ڲ���������������������}
    procedure FormatFieldDecl(PreSpaceCount: Byte = 0);
    procedure FormatVariantSection(PreSpaceCount: Byte = 0);
    procedure FormatRecVariant(PreSpaceCount: Byte = 0; IgnoreFirst: Boolean = False);

    procedure FormatObjectType(PreSpaceCount: Byte = 0);
    procedure FormatObjHeritage(PreSpaceCount: Byte = 0);
    procedure FormatMethodList(PreSpaceCount: Byte = 0);
    procedure FormatMethodHeading(PreSpaceCount: Byte = 0; HasClassPrefixForVar: Boolean = True);
    procedure FormatConstructorHeading(PreSpaceCount: Byte = 0);
    procedure FormatDestructorHeading(PreSpaceCount: Byte = 0);
    procedure FormatOperatorHeading(PreSpaceCount: Byte = 0);
    procedure FormatVarDeclHeading(PreSpaceCount: Byte = 0; IsClassVar: Boolean = True);
    procedure FormatClassVarIdentList(PreSpaceCount: Byte = 0; const CanHaveUnitQual: Boolean = True);
    procedure FormatClassVarIdent(PreSpaceCount: Byte = 0; const CanHaveUnitQual: Boolean = True);
    procedure FormatObjFieldList(PreSpaceCount: Byte = 0);
    procedure FormatClassType(PreSpaceCount: Byte = 0);
    procedure FormatClassHeritage(PreSpaceCount: Byte = 0);
    procedure FormatClassVisibility(PreSpaceCount: Byte = 0);

    // fixed grammer
    procedure FormatClassBody(PreSpaceCount: Byte = 0);
    procedure FormatClassMemberList(PreSpaceCount: Byte = 0);
    procedure FormatClassMember(PreSpaceCount: Byte = 0);
    procedure FormatClassField(PreSpaceCount: Byte = 0);
    procedure FormatClassMethod(PreSpaceCount: Byte = 0);
    procedure FormatClassProperty(PreSpaceCount: Byte = 0);
    procedure FormatClassTypeSection(PreSpaceCount: Byte = 0);
    procedure FormatClassConstSection(PreSpaceCount: Byte = 0);
    procedure FormatClassConstantDecl(PreSpaceCount: Byte = 0);

    // orgin grammer
    procedure FormatClassFieldList(PreSpaceCount: Byte = 0);
    procedure FormatClassMethodList(PreSpaceCount: Byte = 0);
    procedure FormatClassPropertyList(PreSpaceCount: Byte = 0);

    procedure FormatPropertyList(PreSpaceCount: Byte = 0);
    procedure FormatPropertyInterface(PreSpaceCount: Byte = 0);
    procedure FormatPropertyParameterList(PreSpaceCount: Byte = 0);
    procedure FormatPropertySpecifiers(PreSpaceCount: Byte = 0);
    procedure FormatInterfaceType(PreSpaceCount: Byte = 0);
    procedure FormatGuid(PreSpaceCount: Byte = 0);
    procedure FormatInterfaceHeritage(PreSpaceCount: Byte = 0);
    procedure FormatRequiresClause(PreSpaceCount: Byte = 0);
    procedure FormatContainsClause(PreSpaceCount: Byte = 0);

    procedure FormatLabelID(PreSpaceCount: Byte = 0);
    procedure FormatExportsSection(PreSpaceCount: Byte = 0);
    procedure FormatExportsList(PreSpaceCount: Byte = 0);
    procedure FormatExportsDecl(PreSpaceCount: Byte = 0);
  public
    procedure FormatCode(PreSpaceCount: Byte = 0); override;
  end;

  TCnStatementFormatter = class(TCnBasePascalFormatter)
  protected

  public
    procedure FormatCode(PreSpaceCount: Byte = 0); override;
  end;

  TCnTypeSectionFormater = class(TCnStatementFormatter)
  protected

    //procedure FormatTypeID(PreSpaceCount: Byte = 0);
  end;

  TCnProgramBlockFormatter = class(TCnTypeSectionFormater)
  protected
    procedure FormatProgramBlock(PreSpaceCount: Byte = 0; IsLib: Boolean = False);
    procedure FormatPackageBlock(PreSpaceCount: Byte = 0);
    procedure FormatUsesClause(PreSpaceCount: Byte = 0; const NeedCRLF: Boolean = False);
    procedure FormatUsesList(PreSpaceCount: Byte = 0; const CanHaveUnitQual: Boolean = True;
      const NeedCRLF: Boolean = False);
    procedure FormatUsesDecl(PreSpaceCount: Byte; const CanHaveUnitQual: Boolean = True);
  end;

  TCnGoalCodeFormatter = class(TCnProgramBlockFormatter)
  protected
    procedure FormatGoal(PreSpaceCount: Byte = 0);
    procedure FormatProgram(PreSpaceCount: Byte = 0);
    procedure FormatUnit(PreSpaceCount: Byte = 0);
    procedure FormatLibrary(PreSpaceCount: Byte = 0);
    procedure FormatPackage(PreSpaceCount: Byte = 0);
    procedure FormatInterfaceSection(PreSpaceCount: Byte = 0);
    procedure FormatInterfaceDecl(PreSpaceCount: Byte = 0);
    procedure FormatExportedHeading(PreSpaceCount: Byte = 0);
    procedure FormatImplementationSection(PreSpaceCount: Byte = 0);
    procedure FormatInitSection(PreSpaceCount: Byte = 0);
  public
    procedure FormatCode(PreSpaceCount: Byte = 0); override;
  end;

  TCnPascalCodeFormatter = class(TCnGoalCodeFormatter)
  public
    procedure FormatCode(PreSpaceCount: Byte = 0); override;
    function HasSliceResult: Boolean;
    function CopyMatchedSliceResult: string;
    property CodeGen;
  end;

implementation

uses
  CnParseConsts {$IFDEF DEBUG}, CnDebug {$ENDIF};

var
  FKeywordsValidArray: array[Low(TPascalToken)..High(TPascalToken)] of
    TCnPascalFormattingElementTypeSet;
  {* ���ɹؼ��������������һ�����ٷ��ʵ�����}

procedure MakeKeywordsValidAreas;
var
  I: TPascalToken;
begin
  for I := Low(TPascalToken) to High(TPascalToken) do
    FKeywordsValidArray[I] := [];

  FKeywordsValidArray[tokComplexIndex] := [pfetPropertyIndex, pfetDirective];
  FKeywordsValidArray[tokComplexRead] := [pfetPropertySpecifier];
  FKeywordsValidArray[tokComplexWrite] := [pfetPropertySpecifier];
  FKeywordsValidArray[tokComplexDefault] := [pfetPropertySpecifier];
  FKeywordsValidArray[tokComplexStored] := [pfetPropertySpecifier];
  FKeywordsValidArray[tokComplexReadonly] := [pfetPropertySpecifier];

  FKeywordsValidArray[tokDirectiveMESSAGE] := [pfetDirective];
  FKeywordsValidArray[tokDirectiveREGISTER] := [pfetDirective];
  FKeywordsValidArray[tokDirectiveEXPORT] := [pfetDirective];
  // TODO: �������� Directive

  FKeywordsValidArray[tokComplexName] := [pfetDirective];
  FKeywordsValidArray[tokKeywordAlign] := [pfetRecordEnd];

  // δ�г��Ĺؼ��֣���ʾ���Ķ��ǹؼ���
end;

// ����Ӧ�ؼ����Ƿ��������������棬���� True ��ʾ�����棬������Ϊ�ؼ��ִ���
function CheckOutOfKeywordsValidArea(Key: TPascalToken; Element: TCnPascalFormattingElementType): Boolean;
begin
  Result := False;
  if FKeywordsValidArray[Key] = [] then // δָ���ģ���ʾ���Ķ��ǹؼ���
    Exit;
  Result := not (Element in FKeywordsValidArray[Key]);
end;

{ TCnAbstractCodeFormater }

function TCnAbstractCodeFormatter.CheckIdentifierName(const S: string): string;
begin
  { Check the S with pre-specified names e.g. ShowMessage }
  if (FNamesMap = nil) or not FNamesMap.Find(UpperCase(S), Result) then
    Result := S;
end;

constructor TCnAbstractCodeFormatter.Create(AStream: TStream;
   AMatchedInStart, AMatchedInEnd: Integer;
   ACompDirectiveMode: TCompDirectiveMode);
begin
  FMatchedInStart := AMatchedInStart;
  FMatchedInEnd := AMatchedInEnd;

  FMatchedOutStartRow := CN_MATCHED_INVALID;
  FMatchedOutStartCol := CN_MATCHED_INVALID;
  FMatchedOutEndRow := CN_MATCHED_INVALID;
  FMatchedOutEndCol := CN_MATCHED_INVALID;

  // FNamesMap := TCnStrToStrHashMap.Create; // Lazy Create
  FCodeGen := TCnCodeGenerator.Create;
  FCodeGen.CodeWrapMode := CnPascalCodeForRule.CodeWrapMode;
  FCodeGen.OnAfterWrite := CodeGenAfterWrite;
  FScaner := TScaner.Create(AStream, FCodeGen, ACompDirectiveMode);

  FOldElementTypes := TCnElementStack.Create;
  FScaner.NextToken;
end;

destructor TCnAbstractCodeFormatter.Destroy;
begin
  FOldElementTypes.Free;
  FScaner.Free;
  FCodeGen.Free;
  FNamesMap.Free;
  FOutputLineMarks.Free;
  FInputLineMarks.Free;
  inherited;
end;

procedure TCnAbstractCodeFormatter.Error(const Ident: Integer);
begin
  // �������
  PascalErrorRec.ErrorCode := Ident;
  PascalErrorRec.SourceLine := FScaner.SourceLine;
  PascalErrorRec.SourceCol := FScaner.SourceCol;
  PascalErrorRec.SourcePos := FScaner.SourcePos;
  PascalErrorRec.CurrentToken := ErrorTokenString;

  ErrorStr(RetrieveFormatErrorString(Ident));
end;

procedure TCnAbstractCodeFormatter.ErrorFmt(const Ident: Integer;
  const Args: array of const);
begin
  // �������
  PascalErrorRec.ErrorCode := Ident;
  PascalErrorRec.SourceLine := FScaner.SourceLine;
  PascalErrorRec.SourceCol := FScaner.SourceCol;
  PascalErrorRec.SourcePos := FScaner.SourcePos;
  PascalErrorRec.CurrentToken := ErrorTokenString;

  ErrorStr(Format(RetrieveFormatErrorString(Ident), Args));
end;

procedure TCnAbstractCodeFormatter.ErrorNotSurpport(FurtureStr: string);
begin
  ErrorFmt(CN_ERRCODE_PASCAL_NOT_SUPPORT, [FurtureStr]);
end;

procedure TCnAbstractCodeFormatter.ErrorStr(const Message: string);
begin
  raise EParserError.CreateFmt(
        SParseError,
        [ Message, FScaner.SourceLine, FScaner.SourcePos ]
  );
end;

procedure TCnAbstractCodeFormatter.ErrorToken(Token: TPascalToken);
begin
  if TokenToString(Scaner.Token) = '' then
    ErrorFmt(CN_ERRCODE_PASCAL_SYMBOL_EXP, [TokenToString(Token), Scaner.TokenString] )
  else
    ErrorFmt(CN_ERRCODE_PASCAL_SYMBOL_EXP, [TokenToString(Token), TokenToString(Scaner.Token)]);
end;

procedure TCnAbstractCodeFormatter.ErrorTokens(Tokens: array of TPascalToken);
var
  S: string;
  I: Integer;
begin
  S := '';
  for I := Low(Tokens) to High(Tokens) do
    S := S + TokenToString(Tokens[I]) + ' ';

  ErrorExpected(S);
end;

procedure TCnAbstractCodeFormatter.ErrorExpected(Str: string);
begin
  ErrorFmt(CN_ERRCODE_PASCAL_SYMBOL_EXP, [Str, TokenToString(Scaner.Token)]);
end;

function TCnAbstractCodeFormatter.FormatString(const KeywordStr: string;
  KeywordStyle: TKeywordStyle): string;
begin
  case KeywordStyle of
    ksPascalKeyword:    Result := UpperFirst(KeywordStr);
    ksUpperCaseKeyword: Result := UpperCase(KeywordStr);
    ksLowerCaseKeyword: Result := LowerCase(KeywordStr);
    ksNoChange:         Result := KeywordStr;
  else
    Result := KeywordStr;
  end;
end;

function TCnAbstractCodeFormatter.UpperFirst(const KeywordStr: string): string;
begin
  Result := LowerCase(KeywordStr);
  if Length(Result) >= 1 then
    Result[1] := Char(Ord(Result[1]) + Ord('A') - Ord('a'));
end;

function TCnAbstractCodeFormatter.CanBeSymbol(Token: TPascalToken): Boolean;
begin
  Result := Scaner.Token in ([tokSymbol] + ComplexTokens); //KeywordTokens + DirectiveTokens);
end;

procedure TCnAbstractCodeFormatter.Match(Token: TPascalToken; BeforeSpaceCount,
  AfterSpaceCount: Byte; IgnorePreSpace: Boolean; SemicolonIsLineStart: Boolean;
  NoSeparateSpace: Boolean);
begin
  if (Scaner.Token = Token) or ( (Token = tokSymbol) and
    CanBeSymbol(Scaner.Token) ) then
  begin
    WriteToken(Token, BeforeSpaceCount, AfterSpaceCount,
      IgnorePreSpace, SemicolonIsLineStart, NoSeparateSpace);
    Scaner.NextToken;
  end
  else if FInternalRaiseException or not CnPascalCodeForRule.ContinueAfterError then
  begin
    if FSliceMode and (Scaner.Token = tokEOF) then
      raise EReadError.Create('Eof')
    else
      ErrorToken(Token);
  end
  else // Ҫ�����ĳ��ϣ�д����˵
  begin
    WriteToken(Token, BeforeSpaceCount, AfterSpaceCount,
      IgnorePreSpace, SemicolonIsLineStart, NoSeparateSpace);
    Scaner.NextToken;
  end;
end;

procedure TCnAbstractCodeFormatter.MatchOperator(Token: TPascalToken);
begin
  Match(Token, CnPascalCodeForRule.SpaceBeforeOperator,
        CnPascalCodeForRule.SpaceAfterOperator);
end;

procedure TCnAbstractCodeFormatter.SaveToFile(FileName: string);
begin
  CodeGen.SaveToFile(FileName);
end;

procedure TCnAbstractCodeFormatter.SaveToStream(Stream: TStream);
begin
  CodeGen.SaveToStream(Stream);
end;

procedure TCnAbstractCodeFormatter.SaveToStrings(AStrings: TStrings);
begin
  CodeGen.SaveToStrings(AStrings);
end;

function TCnAbstractCodeFormatter.Space(Count: Word): string;
begin
  Result := 'a'#10'a'#13'sd'; // ???
  if SmallInt(Count) > 0 then
    Result := StringOfChar(' ', Count)
  else
    Result := '';
end;

function TCnAbstractCodeFormatter.Tab(PreSpaceCount: Byte;
  CareBeginBlock: Boolean): Byte;
begin
  if CareBeginBlock then
  begin
    // ������������ begin ����Ҫ������������Լ�with do try ���ֵ� try �����ٴ�����
    if not (Scaner.Token in [tokKeywordBegin, tokKeywordTry]) then
      Result := PreSpaceCount + CnPascalCodeForRule.TabSpaceCount
    else
      Result := PreSpaceCount;
  end
  else
  begin
    Result := PreSpaceCount + CnPascalCodeForRule.TabSpaceCount;
  end;
end;

procedure TCnAbstractCodeFormatter.WriteLine;
begin
  if CnPascalCodeForRule.UseIgnoreArea and Scaner.InIgnoreArea then  // �ں�������������д���У��� SkipBlank д��
  begin
    FLastToken := tokBlank;
    Exit;
  end;

  if (Scaner.BlankLinesBefore = 0) and (Scaner.BlankLinesAfter = 0) then
  begin
    FCodeGen.Writeln;
    FCodeGen.Writeln;
  end
  else // �� Comment���Ѿ�����ˣ��� Comment ��Ŀ���δ���������ǰ����л���
  begin
    if Scaner.BlankLinesBefore = 0 then
    begin
      // ע�Ϳ����һ����һ���ճ����������
      FCodeGen.Writeln;
      FCodeGen.Writeln;
    end
    else if (Scaner.BlankLinesBefore > 1) and (Scaner.BlankLinesAfter = 1) then
    begin
      // ע�Ϳ���ϲ����£��Ǿ������氤���£�����Ҫ�������������
      ;
    end
    else if (Scaner.BlankLinesBefore > 1) and (Scaner.BlankLinesAfter > 1) then
    begin
      // ע�Ϳ����¶��գ������汣��һ����
      FCodeGen.Writeln;
      FCodeGen.Writeln;
    end
    else if (Scaner.BlankLinesBefore = 1) and (Scaner.BlankLinesAfter = 1) then
    begin
      // ���¶����գ���ȡ���ϲ���
      FCodeGen.Writeln;
      FCodeGen.Writeln;
    end
    else if (Scaner.BlankLinesBefore = 1) and (Scaner.BlankLinesAfter > 1) then
    begin
      // �Ͽ��²��գ��ǾͿ���
      FCodeGen.Writeln;
      FCodeGen.Writeln;
    end;  
  end;
  FLastToken := tokBlank; // prevent 'Symbol'#13#10#13#10' Symbol'
end;

procedure TCnAbstractCodeFormatter.Writeln;
begin
  if CnPascalCodeForRule.UseIgnoreArea and Scaner.InIgnoreArea then  // �ں�������������д���У��� SkipBlank д��
  begin
    FLastToken := tokBlank;
    Exit;
  end;

  if FEnsureOneEmptyLine then // ����ⲿҪ�󱾴α���һ����
  begin
    FCodeGen.CheckAndWriteOneEmptyLine;
  end
  else if (Scaner.BlankLinesBefore = 0) and (Scaner.BlankLinesAfter = 0) then
  begin
    FCodeGen.Writeln;
  end
  else // �� Comment���Ѿ�����ˣ��� Comment ��Ŀ���δ���������ǰ����л���
  begin
    if Scaner.BlankLinesBefore = 0 then
    begin
      // ע�Ϳ����һ����һ���ճ��������
      FCodeGen.Writeln;

      // ע�Ϳ�����п��У�����Ӧ����
      if Scaner.BlankLinesAfter > 1 then
        FCodeGen.Writeln;
    end
    else if (Scaner.BlankLinesBefore > 1) and (Scaner.BlankLinesAfter = 1) then
    begin
      // ע�Ϳ���ϲ����£��Ǿ������氤���£�����Ҫ�������������
      ;
    end
    else if (Scaner.BlankLinesBefore >= 1) and (Scaner.BlankLinesAfter > 1) then
    begin
      // ע�Ϳ����¶��ջ����ϲ����¿գ������汣��һ����
      FCodeGen.Writeln;
      FCodeGen.Writeln;
    end
    else if (Scaner.BlankLinesBefore = 1) and (Scaner.BlankLinesAfter = 1) then
    begin
      // ���¶����գ���ȡ���ϲ���
      FCodeGen.Writeln;
    end;
  end;
  FLastToken := tokBlank; // prevent 'Symbol'#13#10' Symbol'
end;

procedure TCnAbstractCodeFormatter.WriteToken(Token: TPascalToken;
  BeforeSpaceCount, AfterSpaceCount: Byte; IgnorePreSpace: Boolean;
  SemicolonIsLineStart: Boolean; NoSeparateSpace: Boolean);
var
  NeedPadding: Boolean;
  NeedUnIndent: Boolean;
begin
  if CnPascalCodeForRule.UseIgnoreArea and Scaner.InIgnoreArea then
  begin
    // �ں��Կ��ڲ�������ע�ͷǿհ�����ԭʼ��������пհ���ע���� Scaner �ڲ�����
    CodeGen.Write(Scaner.TokenString);
    FLastToken := Token;
    Exit;
  end;

  if not NoSeparateSpace then  // �����Ҫ����ָ��ո��������˶�
  begin
    // ������ʶ��֮���Կո���룬ǰ���Ǳ���δ��ע�͵ȷ��дӶ����� FLastToken
    if not FCodeGen.NextOutputWillbeLineHead and
      ((FLastToken in IdentTokens) and (Token in IdentTokens + [tokAtSign])) then
      WriteOneSpace
    else if ((BeforeSpaceCount = 0) and (FLastToken = tokGreat) and (Token in IdentTokens + [tokAtSign])) then
      WriteOneSpace // ���� property ����� read ʱ����Ҫ�����ַ�ʽ�ӿո�ֿ�
    else if (FLastToken in RightBracket + [tokHat]) and (Token in [tokKeywordThen, tokKeywordDo,
      tokKeywordOf, tokKeywordTo, tokKeywordDownto]) then
      WriteOneSpace  // ǿ�з���������/ָ�����ؼ���
    else if (Token in LeftBracket + [tokPlus, tokMinus, tokHat]) and
      ((FLastToken in NeedSpaceAfterKeywordTokens)
      or ((FLastToken = tokKeywordAt) and UpperContainElementType([pfetRaiseAt]))) then
      WriteOneSpace; // ǿ�з���������/ǰ��������ţ���ؼ����Լ� raise ����е� at��ע�� at ��ı��ʽ�ǵ���pfetRaiseAt��������Ҫ��ȡ��һ��
  end;

  NeedPadding := CalcNeedPadding;
  NeedUnIndent := CalcNeedPaddingAndUnIndent;

  //�����ŵ�����
  case Token of
    tokComma:
      CodeGen.Write(Scaner.TokenString, 0, 1, NeedPadding);   // 1 Ҳ�ᵼ����βע�ͺ��ˣ��ֶ���Ŀո����� Generator ɾ��
    tokColon:
      begin
        if IgnorePreSpace then
          CodeGen.Write(Scaner.TokenString, 0, 0, NeedPadding)
        else
          CodeGen.Write(Scaner.TokenString, 0, 1, NeedPadding);  // 1 Ҳ�ᵼ����βע�ͺ��ˣ��ֶ���Ŀո����� Generator ɾ��
      end;
    tokSemiColon:
      begin
        if IgnorePreSpace then
          CodeGen.Write(Scaner.TokenString)
        else if SemicolonIsLineStart then
          CodeGen.Write(Scaner.TokenString, BeforeSpaceCount, 0, NeedPadding)
        else
          CodeGen.Write(Scaner.TokenString, 0, 1, NeedPadding);
          // 1 Ҳ�ᵼ����βע�ͺ��ˣ��ֶ���Ŀո����� Generator ɾ��
      end;
    tokAssign:
      CodeGen.Write(Scaner.TokenString, 1, 1, NeedPadding);
  else
    if (Token in KeywordTokens + ComplexTokens + DirectiveTokens) then // �ؼ��ַ�Χ����
    begin
      if FLastToken = tokAmpersand then // �ؼ���ǰ�� & ��ʾ�ǹؼ���
      begin
        CodeGen.Write(CheckIdentifierName(Scaner.TokenString), BeforeSpaceCount, AfterSpaceCount);
      end
      else if CheckOutOfKeywordsValidArea(Token, ElementType) then
      begin
        // �ؼ�����Ч����������ڴ�ԭ�����
        CodeGen.Write(CheckIdentifierName(Scaner.TokenString),
          BeforeSpaceCount, AfterSpaceCount, NeedPadding);
      end
      else
      begin
        if (Token <> tokKeywordEnd) and (Token <> tokKeywordString) then
        begin
            CodeGen.Write(
              FormatString(CheckIdentifierName(Scaner.TokenString),
                CnPascalCodeForRule.KeywordStyle),
              BeforeSpaceCount, AfterSpaceCount, NeedPadding);
        end
        else
        begin
          CodeGen.Write(
            FormatString(CheckIdentifierName(Scaner.TokenString),
            CnPascalCodeForRule.KeywordStyle), BeforeSpaceCount,
            AfterSpaceCount, NeedPadding);
        end;
      end;
    end
    else if FIsTypeID then // ��������������򰴹����� Scaner.TokenString
    begin
      CodeGen.Write(CheckIdentifierName(Scaner.TokenString), BeforeSpaceCount,
        AfterSpaceCount, NeedPadding);
    end
    else // Ŀǰֻ�������Ų���
    begin
      CodeGen.Write(CheckIdentifierName(Scaner.TokenString), BeforeSpaceCount,
        AfterSpaceCount, NeedPadding, NeedUnIndent);
    end;
  end;

  FLastToken := Token;
end;

procedure TCnAbstractCodeFormatter.CheckHeadComments;
var
  I: Integer;
begin
  if FCodeGen <> nil then
    for I := 1 to Scaner.BlankLinesAfter do
      FCodeGen.Writeln;
end;

function TCnAbstractCodeFormatter.BackTab(PreSpaceCount: Byte;
  CareBeginBlock: Boolean): Integer;
begin
  Result := 0;
  if CareBeginBlock then
  begin
    Result := PreSpaceCount - CnPascalCodeForRule.TabSpaceCount;
    if Result < 0 then
      Result := 0;
  end;
end;

{ TCnExpressionFormater }

procedure TCnBasePascalFormatter.FormatCode;
begin
  FormatExpression;
end;

{ ConstExpr -> <constant-expression> }
procedure TCnBasePascalFormatter.FormatConstExpr(PreSpaceCount: Byte);
begin
  SpecifyElementType(pfetConstExpr);
  try
    // �� FormatExpression ���ƶ�����Ϊ��������Դ
    FormatSimpleExpression(PreSpaceCount, PreSpaceCount);

    while Scaner.Token in RelOpTokens + [tokHat, tokSLB, tokDot] do
    begin
      // ���Է��͵Ĵ������ƶ����ڲ��Դ��� function call ������

      if Scaner.Token in RelOpTokens then
      begin
        MatchOperator(Scaner.Token);
        FormatSimpleExpression;
      end;

      // �⼸����������ݣ���֪����ɶ������

      // pchar(ch)^
      if Scaner.Token = tokHat then
        Match(tokHat)
      else if Scaner.Token = tokSLB then  // PString(PStr)^[1]
      begin
        Match(tokSLB);
        FormatExprList(0, PreSpaceCount);
        Match(tokSRB);
      end
      else if Scaner.Token = tokDot then // typecase
      begin
        Match(tokDot);
        FormatExpression(0, PreSpaceCount);
      end;
    end;
  finally
    RestoreElementType;
  end;
end;

{ �¼ӵ����� type �е� ConstExpr -> <constant-expression> ��
  ���к��߲�������� = �Լ����� <> �����}
procedure TCnBasePascalFormatter.FormatConstExprInType(PreSpaceCount: Byte);
var
  Old: Boolean;
begin
  // �����������ȵĴ�Сд����
  Old := FIsTypeID;
  try
    FIsTypeID := True;
    FormatSimpleExpression(PreSpaceCount);
  finally
    FIsTypeID := Old;
  end;

  while Scaner.Token in (RelOpTokens - [tokEqual, tokLess, tokGreat])  do
  begin
    MatchOperator(Scaner.Token);
    FormatSimpleExpression;
  end;
end;

{
  Designator -> QualId ['.' Ident | '[' ExprList ']' | '^']...

  ע����Ȼ�� Designator -> '(' Designator ')' ����������Ѿ������� QualId �Ĵ������ˡ�
}
procedure TCnBasePascalFormatter.FormatDesignator(PreSpaceCount: Byte;
  IndentForAnonymous: Byte);
var
  IsRB: Boolean;
begin
  if Scaner.Token = tokAtSign then // ����� @ Designator ����ʽ���ٴεݹ�
  begin
    Match(tokAtSign, PreSpaceCount);
    FormatDesignator(0, IndentForAnonymous);
    Exit;
  end
  else if Scaner.Token = tokKeywordInherited then // ���� (inherited a).a; �����﷨
    Match(tokKeywordInherited);

  FormatQualID(PreSpaceCount);
  while Scaner.Token in [tokDot, tokLB, tokSLB, tokHat, tokPlus, tokMinus] do
  begin
    case Scaner.Token of
      tokDot:
        begin
          Match(tokDot);
          FormatIdent;
        end;

      tokLB, tokSLB: // [ ] ()
        begin
          { DONE: deal with index visit and function/procedure call}
          Match(Scaner.Token);
          FormatExprList(PreSpaceCount, IndentForAnonymous);

          IsRB := Scaner.Token = tokRB;
          if IsRB then
            SpecifyElementType(pfetExprListRightBracket);
          try
            Match(Scaner.Token);
          finally
            if IsRB then
              RestoreElementType;
          end;
        end;

      tokHat: // ^
        begin
          { DONE: deal with pointer derefrence }
          Match(tokHat);
        end;

      tokPlus, tokMinus:
        begin
          MatchOperator(Scaner.Token);
          FormatExpression(0, PreSpaceCount);
        end;
    end; // case
  end; // while
end;

{ DesignatorList -> Designator/','... }
procedure TCnBasePascalFormatter.FormatDesignatorList(PreSpaceCount: Byte);
begin
  FormatDesignator;

  while Scaner.Token = tokComma do
  begin
    MatchOperator(tokComma);
    FormatDesignator;
  end;
end;

{ Expression -> SimpleExpression [RelOp SimpleExpression]... }
procedure TCnBasePascalFormatter.FormatExpression(PreSpaceCount: Byte;
  IndentForAnonymous: Byte);
begin
  SpecifyElementType(pfetExpression);
  try
    FormatSimpleExpression(PreSpaceCount, IndentForAnonymous);

    while Scaner.Token in RelOpTokens + [tokHat, tokSLB, tokDot] do
    begin
      // ���Է��͵Ĵ������ƶ����ڲ��Դ��� function call ������

      if Scaner.Token in RelOpTokens then
      begin
        MatchOperator(Scaner.Token);
        FormatSimpleExpression;
      end;

      // �⼸����������ݣ���֪����ɶ������

      // pchar(ch)^
      if Scaner.Token = tokHat then
        Match(tokHat)
      else if Scaner.Token = tokSLB then  // PString(PStr)^[1]
      begin
        Match(tokSLB);
        FormatExprList(0, PreSpaceCount);
        Match(tokSRB);
      end
      else if Scaner.Token = tokDot then // typecase
      begin
        Match(tokDot);
        FormatExpression(0, PreSpaceCount);
      end;
    end;
  finally
    RestoreElementType;
  end;
end;

{ ExprList -> Expression/','... }
procedure TCnBasePascalFormatter.FormatExprList(PreSpaceCount: Byte;
  IndentForAnonymous: Byte);
begin
  FormatExpression(0, IndentForAnonymous);

  if Scaner.Token = tokAssign then // ƥ�� OLE ���õ�����
  begin
    Match(tokAssign);
    FormatExpression(0, IndentForAnonymous);
  end;

  while Scaner.Token = tokComma do
  begin
    Match(tokComma, 0, 1);

    if Scaner.Token in ([tokAtSign, tokLB] + ExprTokens + KeywordTokens +
      DirectiveTokens + ComplexTokens) then // �йؼ����������������Ҳ�ÿ��ǵ�
    begin
      FormatExpression(0, IndentForAnonymous);

      if Scaner.Token = tokAssign then // ƥ�� OLE ���õ�����
      begin
        Match(tokAssign);
        FormatExpression(0, IndentForAnonymous);
      end;
    end;
  end;
end;

{
  Factor -> Designator ['(' ExprList ')']
         -> '@' Designator
         -> Number
         -> String
         -> NIL
         -> '(' Expression ')'
         -> NOT Factor
         -> SetConstructor
         -> TypeId '(' Expression ')'
         -> INHERITED Expression

  ����ͬ�����޷�ֱ������ '(' Expression ')' �ʹ����ŵ� Designator
  ���Ӿ���(str1+str2)[1] ���������ı��ʽ���ȹ����ж�һ�º����ķ�����
}
procedure TCnBasePascalFormatter.FormatFactor(PreSpaceCount: Byte;
  IndentForAnonymous: Byte);
var
  NeedPadding: Boolean;
begin
  case Scaner.Token of
    tokSymbol, tokAtSign,
    tokKeyword_BEGIN..tokKeywordIn,  // �����б�ʾ���ֹؼ���Ҳ���� Factor
    tokAmpersand,                    // & ��Ҳ����Ϊ Identifier
    tokKeywordInitialization..tokKeywordNil,
    tokKeywordObject..tokKeyword_END,
    tokDirective_BEGIN..tokDirective_END,
    tokComplex_BEGIN..tokComplex_END:
      begin
        FormatDesignator(PreSpaceCount, IndentForAnonymous);

        if Scaner.Token = tokLB then
        begin
          { TODO: deal with function call node }
          Match(tokLB);
          FormatExprList;
          Match(tokRB);
        end;
      end;

    tokKeywordInherited:
      begin
        Match(tokKeywordInherited);
        FormatExpression;
      end;

    tokChar, tokWString, tokString, tokInteger, tokFloat, tokTrue, tokFalse:
      begin
        NeedPadding := CalcNeedPadding;
        case Scaner.Token of
          tokInteger, tokFloat:
            WriteToken(Scaner.Token, PreSpaceCount);
          tokTrue, tokFalse:
            if CnPascalCodeForRule.UseIgnoreArea and Scaner.InIgnoreArea then
              CodeGen.Write(Scaner.TokenString)
            else
              CodeGen.Write(UpperFirst(Scaner.TokenString), PreSpaceCount, 0, NeedPadding);
            // CodeGen.Write(FormatString(Scaner.TokenString, CnCodeForRule.KeywordStyle), PreSpaceCount);
          tokChar, tokString, tokWString:
            begin
              if CnPascalCodeForRule.UseIgnoreArea and Scaner.InIgnoreArea then
                CodeGen.Write(Scaner.TokenString)
              else
              begin
                if (FLastToken in NeedSpaceAfterKeywordTokens) // �ַ���ǰ������Щ�ؼ���ʱ��Ҫ������һ���ո�ָ�
                  and (PreSpaceCount = 0) then
                  PreSpaceCount := 1;
                CodeGen.Write(Scaner.TokenString, PreSpaceCount, 0, NeedPadding);
              end;
            end;
        end;

        FLastToken := Scaner.Token;
        Scaner.NextToken;
      end;

    tokKeywordNOT:
      begin
        if Scaner.ForwardToken in [tokLB] then // ����֮�٣������ٸ��ո�
          Match(tokKeywordNot, 0, 1)
        else
          Match(tokKeywordNot);
        FormatFactor;
      end;

    tokLB: // (  ��Ҫ�ж��Ǵ�����Ƕ�׵� Designator ���� Expression.
      begin
        // �����޸��� Expression �ڲ���ʹ��֧��^��[]�ˡ�
        Match(tokLB, PreSpaceCount);
        FormatExpression;
        Match(tokRB);
      end;

    tokSLB: // [
      begin
        FormatSetConstructor(PreSpaceCount);
      end;
  else
    { Doesn't do anything to implemenation rule: '' Designator }
  end;
end;

procedure TCnBasePascalFormatter.FormatIdent(PreSpaceCount: Byte;
  const CanHaveUnitQual: Boolean);
begin
  while Scaner.Token = tokSLB do // Attribute
  begin
    FormatSingleAttribute(PreSpaceCount);
    // if not CurrentContainElementType([pfetFormalParameters]) then // �����б�������Բ�����
    Writeln;
  end;

  if Scaner.Token = tokAmpersand then // & ��ʾ���������ʹ�õĹؼ�����ת���
  begin
    Match(Scaner.Token, PreSpaceCount); // �ڴ�����
    if Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
      Match(Scaner.Token); // & ��ı�ʶ��������ʹ�ò��ֹؼ��֣������������﷨�����ֵ�
  end
  else if Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens + CanBeNewIdentifierTokens) then
    Match(Scaner.Token, PreSpaceCount); // ��ʶ��������ʹ�ò��ֹؼ��֣��ڴ�����

  while CanHaveUnitQual and (Scaner.Token = tokDot) do
  begin
    Match(tokDot);
    if Scaner.Token = tokAmpersand then // & ��ʾ���������ʹ�õĹؼ�����ת���
    begin
      Match(Scaner.Token); // ��ź���������
      if Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
        Match(Scaner.Token); // & ��ı�ʶ��������ʹ�ò��ֹؼ��֣������������﷨�����ֵ�
    end
    else if Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens + CanBeNewIdentifierTokens) then
      Match(Scaner.Token); // Ҳ��������ʹ�ò��ֹؼ���
  end;
end;

{ IdentList -> Ident/','... }
procedure TCnBasePascalFormatter.FormatIdentList(PreSpaceCount: Byte;
  const CanHaveUnitQual: Boolean);
begin
  FormatIdent(PreSpaceCount, CanHaveUnitQual);

  while Scaner.Token = tokComma do
  begin
    Match(tokComma);
    FormatIdent(0, CanHaveUnitQual);
  end;
end;

{
  New Grammer:
  QualID -> '(' Designator [AS TypeId]')'
         -> [UnitId '.'] Ident<>
         -> '(' pointervar + expr ')'

  for typecast, e.g. "(x as Ty)" or just bracketed, as in (x).y();

  Old Grammer:
  QualId -> [UnitId '.'] Ident
}
procedure TCnBasePascalFormatter.FormatQualID(PreSpaceCount: Byte);

  procedure FormatIdentWithBracket(PreSpaceCount: Byte);
  var
    I, BracketCount, LessCount: Integer;
    IsGeneric: Boolean;
    GenericBookmark: TScannerBookmark;
  begin
    BracketCount := 0;
    while Scaner.Token = tokLB do
    begin
      Match(tokLB);
      Inc(BracketCount);
    end;

    FormatIdent(PreSpaceCount, True);

    // ���Ӧ�ü��뷺���ж�
    IsGeneric := False;
    if Scaner.Token = tokLess then
    begin
      // �жϷ��ͣ�������ǣ��ָ���ǩ�����ߣ�����ǣ��ͻָ���ǩ������
      Scaner.SaveBookmark(GenericBookmark);
      CodeGen.LockOutput;

      // �����ң�һֱ�ҵ������͵Ĺؼ��ֻ��߷ֺŻ����ļ�β��
      // �������С�ںźʹ��ں�һֱ����ԣ�����Ϊ���Ƿ��͡�
      // TODO: �жϻ��ǲ�̫���ܣ���������֤��
      Scaner.NextToken;
      LessCount := 1;
      while not (Scaner.Token in KeywordTokens + [tokSemicolon, tokEOF] - CanBeTypeKeywordTokens) do
      begin
        if Scaner.Token = tokLess then
          Inc(LessCount)
        else if Scaner.Token = tokGreat then
          Dec(LessCount);

        if LessCount = 0 then // Test<TObject><1 ���������ҪΪ 0 ���ʱ����ǰ����
          Break;

        Scaner.NextToken;
      end;
      IsGeneric := (LessCount = 0);
      
      Scaner.LoadBookmark(GenericBookmark);
      CodeGen.UnLockOutput;
    end;

    if IsGeneric then
      FormatTypeParams;
      
    for I := 1 to BracketCount do
      Match(tokRB);
  end;

begin
  if(Scaner.Token = tokLB) then
  begin
    Match(tokLB, PreSpaceCount);
    FormatDesignator;

    if(Scaner.Token = tokKeywordAs) then
    begin
      Match(tokKeywordAs, 1, 1);
      FormatIdentWithBracket(0);
    end;
    Match(tokRB);    
  end
  else
  begin
    FormatIdentWithBracket(PreSpaceCount);
    // ��ʱ������ UnitId ������
  end;
end;

{
  SetConstructor -> '[' [SetElement/','...] ']'
  SetElement -> Expression ['..' Expression]
}
procedure TCnBasePascalFormatter.FormatSetConstructor(PreSpaceCount: Byte);

  procedure FormatSetElement;
  begin
    FormatExpression;

    if Scaner.Token = tokRange then
    begin
      Match(tokRange);
      FormatExpression;
    end;
  end;
  
begin
  Match(tokSLB);
  SpecifyElementType(pfetSetConstructor);
  try
    if Scaner.Token <> tokSRB then
    begin
      FormatSetElement;
    end;

    while Scaner.Token = tokComma do
    begin
      MatchOperator(tokComma);
      FormatSetElement;
    end;

    Match(tokSRB);
  finally
    RestoreElementType;
  end;
end;

{ SimpleExpression -> ['+' | '-' | '^'] Term [AddOp Term]... }
procedure TCnBasePascalFormatter.FormatSimpleExpression(
  PreSpaceCount: Byte; IndentForAnonymous: Byte);
begin
  if Scaner.Token in [tokPlus, tokMinus, tokHat] then // ^H also support
  begin
    Match(Scaner.Token, PreSpaceCount);
    FormatTerm(0, IndentForAnonymous);
  end
  else if Scaner.Token in [tokKeywordFunction, tokKeywordProcedure] then
  begin
    // Anonymous function/procedure. ��������������ʹ�� IndentForAnonymous ����
    Writeln;
    if Scaner.Token = tokKeywordProcedure then
      FormatProcedureDecl(Tab(IndentForAnonymous), True)
    else
      FormatFunctionDecl(Tab(IndentForAnonymous), True);
  end
  else
    FormatTerm(PreSpaceCount, IndentForAnonymous);

  while Scaner.Token in AddOpTokens do
  begin
    MatchOperator(Scaner.Token);
    FormatTerm(0, IndentForAnonymous);
  end;
end;

{ Term -> Factor [MulOp Factor]... }
procedure TCnBasePascalFormatter.FormatTerm(PreSpaceCount: Byte; IndentForAnonymous: Byte);
begin
  FormatFactor(PreSpaceCount, IndentForAnonymous);

  while Scaner.Token in (MulOPTokens + ShiftOpTokens) do
  begin
    MatchOperator(Scaner.Token);
    FormatFactor(0, IndentForAnonymous);
  end;
end;

// ����֧��
procedure TCnBasePascalFormatter.FormatFormalTypeParamList(
  PreSpaceCount: Byte);
begin
  FormatTypeParams(PreSpaceCount); // ���ߵ�ͬ��ֱ�ӵ���
end;

{TypeParamDecl -> TypeParamList [ ':' ConstraintList ]}
procedure TCnBasePascalFormatter.FormatTypeParamDecl(PreSpaceCount: Byte);
begin
  FormatTypeParamList(PreSpaceCount);
  if Scaner.Token = tokColon then // ConstraintList
  begin
    Match(tokColon);
    FormatIdentList(PreSpaceCount, True);
  end;
end;

{ TypeParamDeclList -> TypeParamDecl/';'... }
procedure TCnBasePascalFormatter.FormatTypeParamDeclList(
  PreSpaceCount: Byte);
begin
  FormatTypeParamDecl(PreSpaceCount);
  while Scaner.Token = tokSemicolon do
  begin
    Match(tokSemicolon);
    FormatTypeParamDecl(PreSpaceCount);
  end;
end;

{TypeParamList -> ( [ CAttrs ] [ '+' | '-' [ CAttrs ] ] Ident )/','...}
procedure TCnBasePascalFormatter.FormatTypeParamList(PreSpaceCount: Byte);
begin
  FormatIdent(PreSpaceCount);
  // �����п������׷���
  while Scaner.Token = tokLess do
    FormatTypeParams(PreSpaceCount);

  while Scaner.Token = tokComma do // �ݲ����� CAttr
  begin
    Match(tokComma);
    FormatIdent(PreSpaceCount);
    // �����п������׷���
    while Scaner.Token = tokLess do
      FormatTypeParams(PreSpaceCount);
  end;
end;

{ TypeParams -> '<' TypeParamDeclList '>' }
function TCnBasePascalFormatter.FormatTypeParams(PreSpaceCount: Byte;
  AllowFixEndGreateEqual: Boolean): Boolean;
begin
  Result := False;
  Match(tokLess);
  FormatTypeParamDeclList(PreSpaceCount);
  if AllowFixEndGreateEqual and (Scaner.Token = tokGreatOrEqu) then
  begin
    Match(tokGreatOrEqu, 0, 1); // TODO: �� > �� =
    Result := True;
  end
  else
    Match(tokGreat);
end;

procedure TCnBasePascalFormatter.FormatTypeParamIdent(PreSpaceCount: Byte);
begin
  if Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
    Match(Scaner.Token, PreSpaceCount); // ��ʶ��������ʹ�ò��ֹؼ���

  while Scaner.Token = tokDot do
  begin
    Match(tokDot);
    if Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
      Match(Scaner.Token); // Ҳ��������ʹ�ò��ֹؼ���
  end;

  if Scaner.Token = tokLess then
    FormatTypeParams;
end;

procedure TCnBasePascalFormatter.FormatTypeParamIdentList(
  PreSpaceCount: Byte);
begin
  FormatTypeParamIdent(PreSpaceCount);

  while Scaner.Token = tokComma do
  begin
    Match(tokComma);
    FormatTypeParamIdent;
  end;
end;

{ TCnStatementFormater }

{ CaseLabel -> ConstExpr ['..' ConstExpr] }
procedure TCnBasePascalFormatter.FormatCaseLabel(PreSpaceCount: Byte);
begin
  SpecifyElementType(pfetCaseLabel);
  try
    FormatConstExpr(PreSpaceCount);

    if Scaner.Token = tokRange then
    begin
      Match(tokRange);
      FormatConstExpr;
    end;
  finally
    RestoreElementType;
  end;
end;

{ CaseSelector -> CaseLabel/','... ':' Statement }
procedure TCnBasePascalFormatter.FormatCaseSelector(PreSpaceCount: Byte);
begin
  FormatCaseLabel(PreSpaceCount);

  while Scaner.Token = tokComma do
  begin
    Match(tokComma);
    FormatCaseLabel; 
  end;

  Match(tokColon);
  // ÿ�� caselabel ��� begin �����У����� begin ����Ӱ��
  Writeln;
  if Scaner.Token = tokKeywordBegin then // ���� begin ���������ã������Ӱ��������
    FNextBeginShouldIndent := True;

  if Scaner.Token <> tokSemicolon then
    FormatStatement(Tab(PreSpaceCount, False))
  else // �ǿ������ֹ�д����
    CodeGen.Write('', Tab(PreSpaceCount));
end;

{ CaseStmt -> CASE Expression OF CaseSelector/';'... [ELSE StmtList] [';'] END }
procedure TCnBasePascalFormatter.FormatCaseStmt(PreSpaceCount: Byte);
var
  HasElse: Boolean;
begin
  Match(tokKeywordCase, PreSpaceCount);
  FormatExpression(0, PreSpaceCount);
  Match(tokKeywordOf);
  Writeln;
  FormatCaseSelector(Tab(PreSpaceCount));

  while Scaner.Token in [tokSemicolon, tokKeywordEnd] do
  begin
    if Scaner.Token = tokSemicolon then
      Match(tokSemicolon);

    Writeln;
    if Scaner.Token in [tokKeywordElse, tokKeywordEnd] then
      Break;   
    FormatCaseSelector(Tab(PreSpaceCount));
  end;

  HasElse := False;
  if Scaner.Token = tokKeywordElse then
  begin
    HasElse := True;
    if FLastToken = tokKeywordEnd then
      Writeln;
    // else ǰ�ɲ���Ҫ��һ��
    Match(tokKeywordElse, PreSpaceCount, 1);
    Writeln;
    // FormatStatement(Tab(PreSpaceCount, False)); 
    // �˴��޸ĳ�ƥ�������
    FormatStmtList(Tab(PreSpaceCount, False));
  end;

  if Scaner.Token = tokSemicolon then
    Match(tokSemicolon);

  if HasElse then
    Writeln;
  Match(tokKeywordEnd, PreSpaceCount);
end;

procedure TCnStatementFormatter.FormatCode(PreSpaceCount: Byte);
begin
  FormatStmtList(PreSpaceCount);
end;

{ CompoundStmt -> BEGIN StmtList END
               -> ASM ... END
}
procedure TCnBasePascalFormatter.FormatCompoundStmt(PreSpaceCount: Byte);
var
  OldKeepOneBlankLine: Boolean;
begin
  OldKeepOneBlankLine := Scaner.KeepOneBlankLine;
  Scaner.KeepOneBlankLine := True;
  try
    case Scaner.Token of
      tokKeywordBegin:
        begin
          if (CnPascalCodeForRule.BeginStyle = bsNextLine) or FNextBeginShouldIndent
            or FCodeGen.NextOutputWillbeLineHead // �������������һ�л�û������Ԫ�أ�˵�����е� begin ��������
            or not (FLastToken in [tokKeywordDo, tokKeywordElse, tokKeywordThen]) then
            Match(tokKeywordBegin, PreSpaceCount)
          else
            Match(tokKeywordBegin); // begin ǰ�Ƿ�����������ƣ�begin ǰ�����������
          FNextBeginShouldIndent := False;

          Writeln;

          // �տ鵫 begin ����ע�͵�����£�������һ������
          if Scaner.Token <> tokKeywordEnd then
          begin
            FormatStmtList(Tab(PreSpaceCount, False));
            Writeln;
          end;
          Match(tokKeywordEnd, PreSpaceCount);
        end;

      tokKeywordAsm:
        begin
          FormatAsmBlock(PreSpaceCount);
        end;
    else
      ErrorTokens([tokKeywordBegin, tokKeywordAsm]);
    end;
  finally
    Scaner.KeepOneBlankLine := OldKeepOneBlankLine;
  end;
end;

{ ForStmt -> FOR QualId ':=' Expression (TO | DOWNTO) Expression DO Statement }
{ ForStmt -> FOR QualId in Expression DO Statement }

procedure TCnBasePascalFormatter.FormatForStmt(PreSpaceCount: Byte);
begin
  Match(tokKeywordFor, PreSpaceCount);
  FormatQualId;

  case Scaner.Token of
    tokAssign:
      begin
        Match(tokAssign);
        FormatExpression;

        if Scaner.Token in [tokKeywordTo, tokKeywordDownTo] then
          Match(Scaner.Token)
        else
          ErrorFmt(CN_ERRCODE_PASCAL_SYMBOL_EXP, ['to/downto', TokenToString(Scaner.Token)]);

        FormatExpression;
      end;

    tokKeywordIn:
      begin
        Match(tokKeywordIn, 1, 1);
        FormatExpression;
        { DONE: surport "for .. in .. do .." statment parser }
      end;

  else
    ErrorExpected(':= or in');
  end;

  SpecifyElementType(pfetDo);
  try
    Match(tokKeywordDo);
  finally
    RestoreElementType;
  end;

  CheckWriteBeginln; // ��� do begin �Ƿ�ͬ��

  if Scaner.Token = tokSemicolon then
    FStructStmtEmptyEnd := True;
  FormatStatement(Tab(PreSpaceCount));
end;

{ IfStmt -> IF Expression THEN Statement [ELSE Statement] }
procedure TCnBasePascalFormatter.FormatIfStmt(PreSpaceCount: Byte; IgnorePreSpace: Boolean);
var
  OldKeepOneBlankLine, ElseAfterThen: Boolean;
begin
  if IgnorePreSpace then
    Match(tokKeywordIF)
  else
    Match(tokKeywordIF, PreSpaceCount);

  { TODO: Apply more if stmt rule }
  FormatExpression(0, PreSpaceCount);
  SpecifyElementType(pfetThen);
  try
    OldKeepOneBlankLine := Scaner.KeepOneBlankLine;
    Scaner.KeepOneBlankLine := False;
    Match(tokKeywordThen);  // To Avoid 2 Empty Line after then in 'if True then (CRLFCRLF) else Exit;'
    Scaner.KeepOneBlankLine := OldKeepOneBlankLine;
  finally
    RestoreElementType;
  end;
  CheckWriteBeginln; // ��� if then begin �Ƿ�ͬ��

  if Scaner.Token = tokSemicolon then
    FStructStmtEmptyEnd := True;

  ElseAfterThen := Scaner.Token = tokKeywordElse;
  FormatStatement(Tab(PreSpaceCount));

  if Scaner.Token = tokKeywordElse then
  begin
    if ElseAfterThen then // ��� then ����� else���� then �� else ���һ�С�
      EnsureOneEmptyLine
    else
      Writeln;
    Match(tokKeywordElse, PreSpaceCount);
    if Scaner.Token = tokKeywordIf then // ���� else if
    begin
      FormatIfStmt(PreSpaceCount, True);
      FormatStatement(Tab(PreSpaceCount));
    end
    else
    begin
      CheckWriteBeginln; // ��� else begin �Ƿ�ͬ��
      if Scaner.Token = tokSemicolon then
        FStructStmtEmptyEnd := True;
      FormatStatement(Tab(PreSpaceCount));
    end;
  end;
end;

{ RepeatStmt -> REPEAT StmtList UNTIL Expression }
procedure TCnBasePascalFormatter.FormatRepeatStmt(PreSpaceCount: Byte);
begin
  Match(tokKeywordRepeat, PreSpaceCount, 1);
  Writeln;
  FormatStmtList(Tab(PreSpaceCount));
  Writeln;
  
  Match(tokKeywordUntil, PreSpaceCount);
  FormatExpression(0, PreSpaceCount);
end;

{
  SimpleStatement -> Designator ['(' ExprList ')']
                  -> Designator ':=' Expression
                  -> INHERITED
                  -> GOTO LabelId
                  -> '(' SimpleStatement ')'

  argh this doesn't take brackets into account
  as far as I can tell, typecasts like "(lcFoo as TComponent)" is a designator

  so is "Pointer(lcFoo)" so that you can do
  " Pointer(lcFoo) := Pointer(lcFoo) + 1;

  Niether does it take into account using property on returned object, e.g.
  qry.fieldbyname('line').AsInteger := 1;

  These can be chained indefinitely, as in
  foo.GetBar(1).Stuff['fish'].MyFudgeFactor.Default(2).Name := 'Jiim';

  ���䣺
  1. Designator ������� ( ��ͷ������ (a)^ := 1; �������
     �����Ժ� '(' SimpleStatement ')' ���֡����� Designator ����Ҳ����������Ƕ��
     ���ڵĴ������ǣ��ȹر�������� Designator ����FormatDesignator�ڲ�����
     ����Ƕ�׵Ĵ�����ƣ���ɨ�账����Ϻ󿴺����ķ����Ծ����� Designator ����
     Simplestatement��Ȼ���ٴλص����������������
}
procedure TCnBasePascalFormatter.FormatSimpleStatement(PreSpaceCount: Byte);
var
  Bookmark: TScannerBookmark;
  OldLastToken: TPascalToken;
  IsDesignator, OldInternalRaiseException: Boolean;

  procedure FormatDesignatorAndOthers(PreSpaceCount: Byte);
  begin
    FormatDesignator(PreSpaceCount, PreSpaceCount);

    while Scaner.Token in [tokAssign, tokLB, tokLess] do
    begin
      case Scaner.Token of
        tokAssign:
          begin
            Match(tokAssign);
            FormatExpression(0, PreSpaceCount);
          end;

        tokLB:
          begin
            { DONE: deal with function call, save to symboltable }
            Match(tokLB);
            FormatExprList(0, PreSpaceCount);
            Match(tokRB);

            if Scaner.Token = tokHat then
              Match(tokHat);

            if Scaner.Token = tokDot then
            begin
              Match(tokDot);
              FormatSimpleStatement;
            end;
          end;
        tokLess:
          begin
            FormatTypeParams;
          end;
      end;
    end;
  end;
begin
  case Scaner.Token of
    tokSymbol, tokAtSign, tokKeywordFinal, tokKeywordIn, tokKeywordOut,
    tokKeywordString, tokKeywordAlign, tokInteger, tokFloat,
    tokDirective_BEGIN..tokDirective_END, // ��������Բ��ֹؼ����Լ����ֿ�ͷ
    tokComplex_BEGIN..tokComplex_END:
      begin
        FormatDesignatorAndOthers(PreSpaceCount);
      end;

    tokKeywordInherited:
      begin
        {
          inherited can be:
          inherited;
          inherited Foo;
          inherited Foo(bar);
          inherited FooProp := bar;
          inherited FooProp[Bar] := Fish;
          bar :=  inherited FooProp[Bar];
        }
        Match(Scaner.Token, PreSpaceCount);

        if CanBeSymbol(Scaner.Token) then
          FormatSimpleStatement;
      end;

    tokKeywordGoto:
      begin
        Match(Scaner.Token, PreSpaceCount);
        { DONE: FormatLabel }
        FormatLabel;
      end;

    tokLB: // ���ſ�ͷ��δ���� (SimpleStatement)���������� (a)^ := 1 ���� Designator
      begin
        // found in D9 surpport: if ... then (...)

        // can delete the LB & RB, code optimize ??
        // �ȵ��� Designator ������������Ͽ��������� := ( ���ж��Ƿ����
        // ����ǽ����ˣ��� Designator �Ĵ����ǶԵģ����� Simplestatement ����

        Scaner.SaveBookmark(Bookmark);
        OldLastToken := FLastToken;
        OldInternalRaiseException := FInternalRaiseException;
        FInternalRaiseException := True;
        // ��Ҫ Exception ���жϺ�������

        try
          CodeGen.LockOutput;

          try
            FormatDesignator(PreSpaceCount);
            // ���� Designator ������ϣ��жϺ�����ɶ

            IsDesignator := Scaner.Token in [tokAssign, tokLB, tokSemicolon,
              tokKeywordElse, tokKeywordEnd];
            // TODO: Ŀǰֻ�뵽�⼸����Semicolon ���� Designator �Ѿ���Ϊ��䴦�����ˣ�
            // else/end ����������û�ֺŵ����ж�ʧ��
          except
            IsDesignator := False;
            // ������������� := �����Σ�FormatDesignator �����
            // ˵�������Ǵ�����Ƕ�׵� Simplestatement
          end;
        finally
          Scaner.LoadBookmark(Bookmark);
          FLastToken := OldLastToken;
          CodeGen.UnLockOutput;
          FInternalRaiseException := OldInternalRaiseException;
        end;

        if not IsDesignator then
        begin
          //Match(tokLB);  �Ż����õ�����
          Scaner.NextToken;

          FormatSimpleStatement(PreSpaceCount);

          if Scaner.Token = tokRB then
            Scaner.NextToken
          else
            ErrorToken(tokRB);

          //Match(tokRB);
          end
        else
        begin
          FormatDesignatorAndOthers(PreSpaceCount);
        end;
      end;
  else
    Error(CN_ERRCODE_PASCAL_INVALID_STATEMENT);
  end;
end;

procedure TCnBasePascalFormatter.FormatLabel(PreSpaceCount: Byte);
begin
  if Scaner.Token = tokInteger then
    Match(tokInteger, PreSpaceCount)
  else
    Match(tokSymbol, PreSpaceCount);
end;

{ Statement -> [LabelId ':']/.. [SimpleStatement | StructStmt] }
procedure TCnBasePascalFormatter.FormatStatement(PreSpaceCount: Byte);
begin
  while Scaner.ForwardToken() = tokColon do
  begin
    // WriteLineFeedByPrevCondition;  label ǰ�治������һ�У��� begin ������Ե��ѿ�
    FormatLabel;
    Match(tokColon);

    Writeln;
  end;

  // ��������Բ��ֹؼ��ֿ�ͷ�������������
  if Scaner.Token in SimpStmtTokens + DirectiveTokens + ComplexTokens +
    StmtKeywordTokens + CanBeNewIdentifierTokens then
    FormatSimpleStatement(PreSpaceCount)
  else if Scaner.Token in StructStmtTokens then
  begin
    FormatStructStmt(PreSpaceCount);
  end;
  { Do not raise error here, Statement maybe empty }
end;

{ StmtList -> Statement/';'... }
procedure TCnBasePascalFormatter.FormatStmtList(PreSpaceCount: Byte);
var
  OldKeepOneBlankLine: Boolean;
begin
  OldKeepOneBlankLine := Scaner.KeepOneBlankLine;
  Scaner.KeepOneBlankLine := True;
  try
    // �������䵥�����е�����
    while Scaner.Token = tokSemicolon do
    begin
      Match(tokSemicolon, PreSpaceCount, 0, False, True);
      if not (Scaner.Token in [tokKeywordEnd, tokKeywordUntil, tokKeywordExcept,
        tokKeywordFinally, tokKeywordFinalization]) then // ��Щ�ؼ����������У���������˴�����
        Writeln;
    end;

    FormatStatement(PreSpaceCount);

    while Scaner.Token = tokSemicolon do
    begin
      if FStructStmtEmptyEnd then
      begin
        FStructStmtEmptyEnd := False;
        Match(tokSemicolon, Tab(PreSpaceCount), 0, False, True);
      end
      else
        Match(tokSemicolon);
      // �������ķָ�ֺ��ã������ǰһ��������Ϊ�գ���if True then ;
      // �򱾾�Ϳ��ܶ�����ȥ�ˣ���Ҫ�� FormatStructStmt ��ͷ��ǲ�����

      // �������䵥�����е�����
      while Scaner.Token = tokSemicolon do
      begin
        Writeln;
        Match(tokSemicolon, PreSpaceCount, 0, False, True);
      end;

      if Scaner.Token in StmtTokens + DirectiveTokens + ComplexTokens
        + [tokInteger] + StmtKeywordTokens then // ���ֹؼ���������俪ͷ��Label ���������ֿ�ͷ
      begin
        { DONE: ��������б� }
        Writeln;
        FormatStatement(PreSpaceCount);
      end;
    end;
  finally
    Scaner.KeepOneBlankLine := OldKeepOneBlankLine;
  end;
end;

{
  StructStmt -> CompoundStmt
             -> ConditionalStmt
             -> LoopStmt
             -> WithStmt
             -> TryStmt
}
procedure TCnBasePascalFormatter.FormatStructStmt(PreSpaceCount: Byte);
begin
  FStructStmtEmptyEnd := False;
  case Scaner.Token of
    tokKeywordBegin,
    tokKeywordAsm:    FormatCompoundStmt(PreSpaceCount);
    tokKeywordIf:     FormatIfStmt(PreSpaceCount);
    tokKeywordCase:   FormatCaseStmt(PreSpaceCount);
    tokKeywordRepeat: FormatRepeatStmt(PreSpaceCount);
    tokKeywordWhile:  FormatWhileStmt(PreSpaceCount);
    tokKeywordFor:    FormatForStmt(PreSpaceCount);
    tokKeywordWith:   FormatWithStmt(PreSpaceCount);
    tokKeywordTry:    FormatTryStmt(PreSpaceCount);
    tokKeywordRaise:  FormatRaiseStmt(PreSpaceCount);
  else
    ErrorFmt(CN_ERRCODE_PASCAL_SYMBOL_EXP, ['Statement', TokenToString(Scaner.Token)]);
  end;
end;

{
  TryEnd -> FINALLY StmtList END
         -> EXCEPT [ StmtList | (ExceptionHandler/;... [ELSE Statement]) ] [';'] END
}
procedure TCnBasePascalFormatter.FormatTryEnd(PreSpaceCount: Byte);
begin
  case Scaner.Token of
    tokKeywordFinally:
      begin
        Match(Scaner.Token, PreSpaceCount);
        Writeln;
        if Scaner.Token <> tokKeywordEnd then
        begin
          FormatStmtList(Tab(PreSpaceCount, False));
          Writeln;
        end;
        Match(tokKeywordEnd, PreSpaceCount);
      end;

    tokKeywordExcept:
      begin
        Match(Scaner.Token, PreSpaceCount);
        if Scaner.Token <> tokKeywordEnd then // �������ʱ�������
        begin
          if Scaner.Token <> tokKeywordOn then
          begin
            Writeln;
            FormatStmtList(Tab(PreSpaceCount, False))
          end
          else
          begin
            while Scaner.Token = tokKeywordOn do
            begin
              Writeln;
              FormatExceptionHandler(Tab(PreSpaceCount, False));
            end;

            if Scaner.Token = tokKeywordElse then
            begin
              Writeln;
              Match(tokKeywordElse, Tab(PreSpaceCount), 1);
              Writeln;
              FormatStmtList(Tab(Tab(PreSpaceCount, False), False));
            end;

            if Scaner.Token = tokSemicolon then
              Match(tokSemicolon);
          end;
        end;
        Writeln;

        Match(tokKeywordEnd, PreSpaceCount);
      end;
  else
    ErrorFmt(CN_ERRCODE_PASCAL_SYMBOL_EXP, ['except/finally', Scaner.TokenString]);
  end;
end;

{
  ExceptionHandler -> ON [ident :] Type do Statement
}
procedure TCnBasePascalFormatter.FormatExceptionHandler(PreSpaceCount: Byte);
var
  OnlySemicolon: Boolean;
begin
  Match(tokKeywordOn, PreSpaceCount);

  // On Exception class name allow dot
  Match(tokSymbol);
  while Scaner.Token = tokDot do
  begin
    Match(Scaner.Token);
    Match(tokSymbol);
  end;

  if Scaner.Token = tokColon then
  begin
    Match(tokColon);
    Match(tokSymbol);

    // On Exception class name allow dot
    while Scaner.Token = tokDot do
    begin
      Match(Scaner.Token);
      Match(tokSymbol);
    end;
  end;

  SpecifyElementType(pfetDo);
  try
    Match(tokKeywordDo);
  finally
    RestoreElementType;
  end;

  CheckWriteBeginln; // ��� do begin �Ƿ�ͬ��;

  OnlySemicolon := Scaner.Token = tokSemicolon;
  FormatStatement(Tab(PreSpaceCount));
  
  if Scaner.Token = tokSemicolon then
  begin
    if OnlySemicolon then
      Match(tokSemicolon, Tab(PreSpaceCount), 0, False, True)
    else
      Match(tokSemicolon);
  end;
end;

{ TryStmt -> TRY StmtList TryEnd }
procedure TCnBasePascalFormatter.FormatTryStmt(PreSpaceCount: Byte);
begin
  Match(tokKeywordTry, PreSpaceCount);
  Writeln;
  if not (Scaner.Token in [tokKeywordExcept, tokKeywordFinally]) then // �������
  begin
    FormatStmtList(Tab(PreSpaceCount, False));
    Writeln;
  end;
  FormatTryEnd(PreSpaceCount);
end;

{ WhileStmt -> WHILE Expression DO Statement }
procedure TCnBasePascalFormatter.FormatWhileStmt(PreSpaceCount: Byte);
begin
  Match(tokKeywordWhile, PreSpaceCount);
  FormatExpression(0, PreSpaceCount);

  SpecifyElementType(pfetDo);
  try
    Match(tokKeywordDo);
  finally
    RestoreElementType;
  end;

  CheckWriteBeginln; // ��� do begin �Ƿ�ͬ��

  if Scaner.Token = tokSemicolon then
    FStructStmtEmptyEnd := True;
  FormatStatement(Tab(PreSpaceCount));
end;

{ WithStmt -> WITH IdentList DO Statement }
procedure TCnBasePascalFormatter.FormatWithStmt(PreSpaceCount: Byte);
begin
  Match(tokKeywordWith, PreSpaceCount);
  // FormatDesignatorList; // Grammer error.

  FormatExpression(0, PreSpaceCount);
  while Scaner.Token = tokComma do
  begin
    MatchOperator(tokComma);
    FormatExpression(0, PreSpaceCount);
  end;

  SpecifyElementType(pfetDo);
  try
    Match(tokKeywordDo);
  finally
    RestoreElementType;
  end;

  CheckWriteBeginln; // ��� do begin �Ƿ�ͬ��

  if Scaner.Token = tokSemicolon then
    FStructStmtEmptyEnd := True;
  FormatStatement(Tab(PreSpaceCount));
end;

{ RaiseStmt -> RAISE [ Expression | Expression AT Expression ] }
procedure TCnBasePascalFormatter.FormatRaiseStmt(PreSpaceCount: Byte);
begin
  Match(tokKeywordRaise, PreSpaceCount);

  if not (Scaner.Token in [tokSemicolon, tokKeywordEnd, tokKeywordElse]) then
    FormatExpression(0, PreSpaceCount);

  if Scaner.Token = tokKeywordAt then
  begin
    SpecifyElementType(pfetRaiseAt);
    try
      Match(Scaner.Token);
      FormatExpression(0, PreSpaceCount);
    finally
      RestoreElementType;
    end;
  end;
end;

{ AsmBlock -> AsmStmtList ���Զ����ظ�ʽ��}
procedure TCnBasePascalFormatter.FormatAsmBlock(PreSpaceCount: Byte);
var
  NewLine, AfterKeyword, IsLabel, HasAtSign: Boolean;
  T: TPascalToken;
  Bookmark: TScannerBookmark;
  OldLastToken: TPascalToken;
  LabelLen, InstrucLen: Integer;
  ALabel: string;
  OldKeywordStyle: TKeywordStyle;
begin
  Match(tokKeywordAsm, PreSpaceCount);
  Writeln;
  Scaner.ASMMode := True;
  SpecifyElementType(pfetAsm);

  OldKeywordStyle := CnPascalCodeForRule.KeywordStyle;
  CnPascalCodeForRule.KeywordStyle := ksUpperCaseKeyword; // ��ʱ�滻

  try
    NewLine := True;
    AfterKeyword := False;
    InstrucLen := 0;
    IsLabel := False;

    while (Scaner.Token <> tokKeywordEnd) or
      ((Scaner.Token = tokKeywordEnd) and (FLastToken = tokAtSign)) do
    begin
      T := Scaner.Token;
      Scaner.SaveBookmark(Bookmark);
      OldLastToken := FLastToken;
      CodeGen.LockOutput;

      if NewLine then // ���ף�Ҫ���label
      begin
        LabelLen := 0;
        ALabel := '';
        HasAtSign := False;
        AfterKeyword := False;
        InstrucLen := Length(Scaner.TokenString); // ��ס�����ǵĻ��ָ��ؼ��ֵĳ���

        while Scaner.Token in [tokAtSign, tokSymbol, tokInteger, tokAsmHex] + KeywordTokens +
          DirectiveTokens + ComplexTokens do
        begin
          if Scaner.Token = tokAtSign then
          begin
            HasAtSign := True;
            ALabel := ALabel + '@';
            Inc(LabelLen);
            Scaner.NextToken;
          end
          else if Scaner.Token in [tokSymbol, tokInteger, tokAsmHex] + KeywordTokens +
            DirectiveTokens + ComplexTokens then // �ؼ��ֿ����� label ��
          begin
            ALabel := ALabel + Scaner.TokenString;
            Inc(LabelLen, Length(Scaner.TokenString));

            Scaner.NextToken;
          end;
        end;
        // ������һ�������� label �ģ����� @ ��ͷ�Ĳ��� label
        IsLabel := HasAtSign and (Scaner.Token = tokColon);
        if IsLabel then
        begin
          Inc(LabelLen);
          ALabel := ALabel + ':';
        end;

        // �����label����ôALabel��ͷ�Ѿ�����label�ˣ����Բ���ҪLoadBookmark��
        if IsLabel then
        begin
          // Match(Scaner.Token);
          CodeGen.UnLockOutput;
          Writeln;
          CodeGen.Write(ALabel); // д�� label����дʣ�µĹؼ���ǰ�Ŀո�
          if CnPascalCodeForRule.SpaceBeforeASM - LabelLen <= 0 then // Label ̫���ͻ���
          begin
            // Writeln;
            CodeGen.Write(Space(CnPascalCodeForRule.SpaceBeforeASM));
          end
          else
            CodeGen.Write(Space(CnPascalCodeForRule.SpaceBeforeASM - LabelLen));
          Scaner.NextToken; // ���� label ��ð��
          InstrucLen := Length(Scaner.TokenString); // ��סӦ���ǵĻ��ָ��ؼ��ֵĳ���
        end
        else // ���� Label �Ļ����ص���ͷ
        begin
          Scaner.LoadBookmark(Bookmark);
          FLastToken := OldLastToken;
          CodeGen.UnLockOutput;
          
          Match(Scaner.Token, CnPascalCodeForRule.SpaceBeforeASM);
          AfterKeyword := True;
        end;
      end
      else
      begin
        CodeGen.ClearOutputLock;

        if AfterKeyword and not (Scaner.Token in [tokCRLF, tokSemicolon]) then // ��һ�ֺ�������пո�
        begin
          if InstrucLen >= CnPascalCodeForRule.SpaceTabASMKeyword then
            WriteOneSpace
          else
            CodeGen.Write(Space(CnPascalCodeForRule.SpaceTabASMKeyword - InstrucLen));
        end;

        if Scaner.Token <> tokCRLF then
        begin
          if AfterKeyword then // �ֹ�д��ASM�ؼ��ֺ�������ݣ����� Pascal �Ŀո����
          begin
            CodeGen.Write(Scaner.TokenString);
            FLastToken := Scaner.Token;
            Scaner.NextToken;
            AfterKeyword := False;
          end
          else if IsLabel then // ���ǰһ���� label��������ǵ�һ�� Keyword
          begin
            CodeGen.Write(Scaner.TokenString);
            FLastToken := Scaner.Token;
            Scaner.NextToken;
            IsLabel := False;
            AfterKeyword := True;
          end
          else
          begin
            if Scaner.Token = tokColon then
              Match(Scaner.Token, 0, 0, True)
            else if Scaner.Token in (AddOPTokens + MulOPTokens) then
              Match(Scaner.Token, 1, 1) // ��Ԫ�����ǰ�����һ��
            else if (FLastToken in CanBeNewIdentifierTokens) and
              (UpperCase(Scaner.TokenString) = 'H') then
              Match(Scaner.Token, 0, 0, False, False, True) // �޲����ֿ�ͷ��ʮ�������� H ��Ŀո񣬵�������
            else
              Match(Scaner.Token);
            AfterKeyword := False;
          end;
        end;
      end;

      //if not OnlyKeyword then
      NewLine := False;

      if (T = tokSemicolon) or (Scaner.Token = tokCRLF) or
        ((Scaner.Token = tokKeywordEnd) and (FLastToken <> tokAtSign)) then
      begin
        Writeln;
        NewLine := True;
        while Scaner.Token in [tokBlank, tokCRLF] do
          Scaner.NextToken;
      end;
    end;
  finally
    Scaner.ASMMode := False;
    RestoreElementType;
    if Scaner.Token in [tokBlank, tokCRLF] then
      Scaner.NextToken;
    CnPascalCodeForRule.KeywordStyle := OldKeywordStyle; // �ָ� KeywordStyle
    Match(tokKeywordEnd, PreSpaceCount);
  end;
end;

{ TCnTypeSectionFormater }

{ ArrayConstant -> '(' TypedConstant/','... ')' }
procedure TCnBasePascalFormatter.FormatArrayConstant(PreSpaceCount: Byte);
begin
  Match(tokLB);

  SpecifyElementType(pfetArrayConstant);
  try
    FormatTypedConstant(PreSpaceCount);

  //  if Scaner.Token = tokLB then // ��������ſ���Ƕ��
  //    FormatArrayConstant(PreSpaceCount)
  //  else

    while Scaner.Token = tokComma do
    begin
      Match(Scaner.Token);
      FormatTypedConstant(PreSpaceCount);
  //    if Scaner.Token = tokLB then // ��������ſ���Ƕ��
  //      FormatArrayConstant(PreSpaceCount)
  //    else
    end;

    Match(tokRB);
  finally
    RestoreElementType;
  end;
end;

{ ArrayType -> ARRAY ['[' OrdinalType/','... ']'] OF Type }
procedure TCnBasePascalFormatter.FormatArrayType(PreSpaceCount: Byte);
begin
  Match(tokKeywordArray);

  if Scaner.Token = tokSLB then
  begin
    Match(tokSLB);
    FormatOrdinalType;

    while Scaner.Token = tokComma do
    begin
      Match(Scaner.Token);
      FormatOrdinalType;
    end;

    Match(tokSRB);
  end;

  Match(tokkeywordOf);
  FormatType(PreSpaceCount);
end;

{ ClassFieldList -> (ClassVisibility ObjFieldList)/';'... }
procedure TCnBasePascalFormatter.FormatClassFieldList(PreSpaceCount: Byte);
begin
  FormatClassVisibility(PreSpaceCount);
  FormatObjFieldList(PreSpaceCount);
  Match(tokSemicolon);

  while (Scaner.Token in ClassVisibilityTokens) or (Scaner.Token = tokSymbol) do
  begin
    if Scaner.Token in ClassVisibilityTokens then
      FormatClassVisibility(PreSpaceCount);

    FormatObjFieldList(PreSpaceCount);
    Match(tokSemicolon);
  end;
end;

{ ClassHeritage -> '(' IdentList ')' }
procedure TCnBasePascalFormatter.FormatClassHeritage(PreSpaceCount: Byte);
begin
  Match(tokLB);
  FormatTypeParamIdentList(); // ���뷺�͵�֧��
  Match(tokRB);
end;

{ ClassMethodList -> (ClassVisibility MethodList)/';'... }
procedure TCnBasePascalFormatter.FormatClassMethodList(PreSpaceCount: Byte);
begin
  FormatClassVisibility(PreSpaceCount);
  FormatMethodList(PreSpaceCount);

  while Scaner.Token = tokSemicolon do
  begin
    FormatClassVisibility(PreSpaceCount);
    FormatMethodList(PreSpaceCount);
  end;
end;

{ ClassPropertyList -> (ClassVisibility PropertyList ';')... }
procedure TCnBasePascalFormatter.FormatClassPropertyList(PreSpaceCount: Byte);
begin
  FormatClassVisibility(PreSpaceCount);
  FormatPropertyList(PreSpaceCount);
  if Scaner.Token = tokSemicolon then
    Match(tokSemicolon);

  { TODO: Need Scaner forward look future }
  while (Scaner.Token in ClassVisibilityTokens) or (Scaner.Token = tokKeywordProperty) do
  begin
    if Scaner.Token in ClassVisibilityTokens then
      FormatClassVisibility(PreSpaceCount);
    Writeln;
    FormatPropertyList(PreSpaceCount);
    if Scaner.Token = tokSemicolon then
      Match(tokSemicolon);
  end;
end;

{ ClassRefType -> CLASS OF TypeId }
procedure TCnBasePascalFormatter.FormatClassRefType(PreSpaceCount: Byte);
begin
  Match(tokkeywordClass);
  Match(tokKeywordOf);

  { TypeId -> [UnitId '.'] <type-identifier> }
  Match(tokSymbol);
  while Scaner.Token = tokDot do
  begin
    Match(Scaner.Token);
    Match(tokSymbol);
  end;
end;

{
  ClassType -> CLASS [ClassHeritage]
               [ClassFieldList]
               [ClassMethodList]
               [ClassPropertyList]
               END
}
{
  TODO:  This grammer has something wrong...need to be fixed.

  My current FIXED grammer:

  ClassType -> CLASS (OF Ident) | ClassBody
  ClassBody -> [ClassHeritage] [ClassMemberList END]
  ClassMemberList -> ([ClassVisibility] [ClassMember ';']) ...
  ClassMember -> ClassField | ClassMethod | ClassProperty

  
  Here is some note in JCF:
  =============Cut Here=============
  ClassType -> CLASS [ClassHeritage]
       [ClassFieldList]
       [ClassMethodList]
       [ClassPropertyList]
       END

  This is not right - these can repeat

  My own take on this is as follows:

  class -> ident '=' 'class' [Classheritage] classbody 'end'
  classbody -> clasdeclarations (ClassVisibility clasdeclarations) ...
  ClassVisibility -> 'private' | 'protected' | 'public' | 'published' | 'automated'
  classdeclarations -> (procheader|fnheader|constructor|destructor|vars|property|) [';'] ...

  can also be a forward declaration, e.g.
    TFred = class;

  or a class ref type
    TFoo = class of TBar;

  or a class helper
    TFoo = class helper for TBar
  =============Cut End==============
}
procedure TCnBasePascalFormatter.FormatClassType(PreSpaceCount: Byte);
begin
  Match(tokKeywordClass);
  if Scaner.Token = tokSemiColon then // class declare forward, like TFoo = class;
    Exit;

  if Scaner.Token = tokKeywordOF then  // like TFoo = class of TBar;
  begin
    Match(tokKeywordOF);
    FormatIdent;
    Exit;
  end
  else if (Scaner.Token = tokSymbol) and (Scaner.ForwardToken = tokKeywordFor)
    and (LowerCase(Scaner.TokenString) = 'helper') then
  begin
    // class helper for Ident
    Match(Scaner.Token);
    Match(tokKeywordFor);
    FormatIdent(0);
  end;

  if Scaner.Token in [tokKeywordSealed, tokDirectiveABSTRACT] then // TFoo = class sealed
    Match(Scaner.Token);

  FormatClassBody(PreSpaceCount);

{
  while Scaner.Token <> tokKeywordEnd do
  begin
    // skip ClassVisibilityTokens ( private public ... )
    Scaner.SaveBookmark;
    while (Scaner.Token in ClassVisibilityTokens + [tokKeywordEnd, tokEOF]) do
    begin
      Scaner.NextToken;
    end;
    Token := Scaner.Token;
    Scaner.LoadBookmark;

    if Token = tokKeywordProperty then
      FormatClassPropertyList(Tab(PreSpaceCount))
    else if Token in MethodListTokens then
      FormatMethodList(Tab(PreSpaceCount))
    else
      FormatClassFieldList(Tab(PreSpaceCount));
  end;

  Match(tokKeywordEnd);
}
end;

{ ClassVisibility -> [PUBLIC | PROTECTED | PRIVATE | PUBLISHED] }
procedure TCnBasePascalFormatter.FormatClassVisibility(PreSpaceCount: Byte);
begin
  if Scaner.Token = tokKeywordStrict then
  begin
    Match(Scaner.Token, PreSpaceCount);
    if Scaner.Token in ClassVisibilityTokens then
    begin
      Match(Scaner.Token);
      Writeln;
    end;
  end
  else if Scaner.Token in ClassVisibilityTokens then
  begin
    Match(Scaner.Token, PreSpaceCount);
    Writeln;
  end;
end;

{ ConstructorHeading -> CONSTRUCTOR Ident [FormalParameters] }
procedure TCnBasePascalFormatter.FormatConstructorHeading(PreSpaceCount: Byte);
begin
  Match(tokKeywordConstructor, PreSpaceCount);
  FormatMethodName;

  if Scaner.Token = tokLB then
    FormatFormalParameters;
end;

{ ContainsClause -> CONTAINS IdentList... ';' }
procedure TCnBasePascalFormatter.FormatContainsClause(PreSpaceCount: Byte);
begin
  if Scaner.TokenSymbolIs('CONTAINS') then
  begin
    Match(Scaner.Token, 0, 1);
    FormatIdentList;
    Match(tokSemicolon);
  end;
end;

{ DestructorHeading -> DESTRUCTOR Ident [FormalParameters] }
procedure TCnBasePascalFormatter.FormatDestructorHeading(PreSpaceCount: Byte);
begin
  Match(tokKeywordDestructor, PreSpaceCount);
  FormatMethodName;

  if Scaner.Token = tokLB then
    FormatFormalParameters;
end;

{ OperatorHeading -> OPERATOR Ident [FormalParameters] }
procedure TCnBasePascalFormatter.FormatOperatorHeading(PreSpaceCount: Byte);
begin
  Match(tokKeywordOperator, PreSpaceCount);
  FormatMethodName;

  if Scaner.Token = tokLB then
    FormatFormalParameters;
end;

{ VarDecl -> IdentList ':' Type [(ABSOLUTE (Ident | ConstExpr)) | '=' TypedConstant] }
procedure TCnBasePascalFormatter.FormatVarDeclHeading(PreSpaceCount: Byte;
  IsClassVar: Boolean);
begin
  if Scaner.Token in [tokKeywordVar, tokKeywordThreadVar] then
  begin
    if IsClassVar then
      Match(Scaner.Token)
    else
      Match(Scaner.Token, BackTab(PreSpaceCount));
  end;
  
  repeat
    Writeln;
    
    FormatClassVarIdentList(PreSpaceCount);
    if Scaner.Token = tokColon then // �ſ��﷨����
    begin
      Match(tokColon);
      FormatType(PreSpaceCount); // �� Type ���ܻ��У����봫��
    end;

    if Scaner.Token = tokEQUAL then
    begin
      Match(Scaner.Token, 1, 1);
      FormatTypedConstant;
    end
    else if Scaner.TokenSymbolIs('ABSOLUTE') then
    begin
      Match(Scaner.Token);
      FormatConstExpr; // include indent
    end;

    while Scaner.Token in DirectiveTokens do
      FormatDirective;

    if Scaner.Token = tokSemicolon then
      Match(tokSemicolon);
  until Scaner.Token in ClassMethodTokens + ClassVisibilityTokens + [tokKeywordEnd,
    tokEOF, tokKeywordCase];
    // ������Щ����Ϊ class var ������������ record ���ܳ��ֵ� case
end;

{ IdentList -> [Attribute] Ident/','... }
procedure TCnBasePascalFormatter.FormatClassVarIdentList(PreSpaceCount: Byte;
  const CanHaveUnitQual: Boolean);
begin
  FormatClassVarIdent(PreSpaceCount, CanHaveUnitQual);

  while Scaner.Token = tokComma do
  begin
    Match(tokComma);
    FormatClassVarIdent(0, CanHaveUnitQual);
  end;
end;

procedure TCnBasePascalFormatter.FormatClassVarIdent(PreSpaceCount: Byte;
  const CanHaveUnitQual: Boolean);
begin
  while Scaner.Token = tokSLB do // Attribute
  begin
    FormatSingleAttribute(PreSpaceCount);
    Writeln;
  end;
  if Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
    Match(Scaner.Token, PreSpaceCount); // ��ʶ��������ʹ�ò��ֹؼ���

  while CanHaveUnitQual and (Scaner.Token = tokDot) do
  begin
    Match(tokDot);
    if Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
      Match(Scaner.Token); // Ҳ��������ʹ�ò��ֹؼ���
  end;
end;

{
  Directive -> CDECL
            -> REGISTER
            -> DYNAMIC
            -> VIRTUAL
            -> EXPORT
            -> EXTERNAL
            -> FAR
            -> FORWARD
            -> MESSAGE
            -> OVERRIDE
            -> OVERLOAD
            -> PASCAL
            -> REINTRODUCE
            -> SAFECALL
            -> STDCALL

  ע��Directive �����֣�һ������˵�Ĵ���ں�������������ģ�������Ҫ�ֺŷָ�
  һ�������ͻ�����������ģ�platform library �ȣ�����ֺŷָ��ġ�
}
procedure TCnBasePascalFormatter.FormatDirective(PreSpaceCount: Byte;
  IgnoreFirst: Boolean);
begin
  try
    SpecifyElementType(pfetDirective);
    if Scaner.Token in DirectiveTokens + ComplexTokens then
    begin
      // deal with the Directive use like this
      // function MessageBox(...): Integer; stdcall; external 'user32.dll' name 'MessageBoxA';
  {
      while not (Scaner.Token in [tokSemicolon] + KeywordTokens) do
      begin
        CodeGen.Write(FormatString(Scaner.TokenString, CnCodeForRule.KeywordStyle), 1);
        FLastToken := Scaner.Token;
        Scaner.NextToken;
      end;
  }
      if Scaner.Token in [   // ��Щ�Ǻ�����ԼӲ�����
        tokDirectiveDispID,
        tokDirectiveExternal,
        tokDirectiveMESSAGE,
        tokDirectiveDEPRECATED,
        tokComplexName,
        tokComplexImplements,
        tokComplexStored,
        tokComplexRead,
        tokComplexWrite,
        tokComplexIndex
      ] then
      begin
        if not IgnoreFirst then
          WriteOneSpace; // �ǵ�һ�� Directive����֮ǰ�����ݿո�ָ�
        WriteToken(Scaner.Token, 0, 0, False, False, True);
        Scaner.NextToken;

        if not (Scaner.Token in DirectiveTokens) then // �Ӹ������ı��ʽ
        begin
          if Scaner.Token in [tokString, tokWString, tokLB, tokPlus, tokMinus] then
            WriteOneSpace; // �������ʽ�ո�ָ�
          FormatConstExpr;
        end;
        //  Match(Scaner.Token);
      end
      else
      begin
        if not IgnoreFirst then
          WriteOneSpace; // �ǵ�һ�� Directive����֮ǰ�����ݿո�ָ�
        WriteToken(Scaner.Token, 0, 0, False, False, True);
        Scaner.NextToken;
      end;
    end
    else
      Error(CN_ERRCODE_PASCAL_ERROR_DIRECTIVE);
  finally
    RestoreElementType;
  end;
end;

{ EnumeratedType -> '(' EnumeratedList ')' }
procedure TCnBasePascalFormatter.FormatEnumeratedType(PreSpaceCount: Byte);
begin
  Match(tokLB, PreSpaceCount);
  FormatEnumeratedList;
  Match(tokRB);
end;

{ EnumeratedList -> EmumeratedIdent/','... }
procedure TCnBasePascalFormatter.FormatEnumeratedList(PreSpaceCount: Byte);
begin
  SpecifyElementType(pfetEnumList);
  try
    FormatEmumeratedIdent(PreSpaceCount);
    while Scaner.Token = tokComma do
    begin
      Match(tokComma);
      FormatEmumeratedIdent;
    end;
  finally
    RestoreElementType;
  end;
end;

{ EmumeratedIdent -> [&] Ident ['=' ConstExpr] }
procedure TCnBasePascalFormatter.FormatEmumeratedIdent(PreSpaceCount: Byte);
begin
//  if Scaner.Token = tokAndSign then // e.g. TAnimationType = (&In, Out, InOut);
//    Match(tokAndSign);              // Moved to FormatIdent
    
  FormatIdent(PreSpaceCount);
  if Scaner.Token = tokEQUAL then
  begin
    Match(tokEQUAL, 1, 1);
    FormatConstExpr;
  end;
end;

{ FieldDecl -> IdentList ':' Type }
procedure TCnBasePascalFormatter.FormatFieldDecl(PreSpaceCount: Byte);
begin
  SpecifyElementType(pfetFieldDecl);
  try
    FormatIdentList(PreSpaceCount);
    Match(tokColon);
    FormatType(PreSpaceCount);
  finally
    RestoreElementType;
  end;
end;

{ FieldList ->  FieldDecl/';'... [VariantSection] [';'] }
procedure TCnBasePascalFormatter.FormatFieldList(PreSpaceCount: Byte;
  IgnoreFirst: Boolean);
var
  First, AfterIsRB: Boolean;
begin
  First := True;
  while not (Scaner.Token in [tokKeywordEnd, tokKeywordCase, tokRB]) do
  begin
    if Scaner.Token in ClassVisibilityTokens then
      FormatClassVisibility(BackTab(PreSpaceCount));

    if Scaner.Token in [tokKeywordProcedure, tokKeywordFunction,
      tokKeywordConstructor, tokKeywordDestructor, tokKeywordClass] then
    begin
      FormatClassMethod(PreSpaceCount);
      Writeln;
      First := False;
    end
    else if Scaner.Token = tokKeywordProperty then
    begin
      FormatClassProperty(PreSpaceCount);
      Writeln;
      First := False;
    end
    else if Scaner.Token = tokKeywordType then
    begin
      FormatClassTypeSection(PreSpaceCount);
      Writeln;
      First := False;
    end
    else if Scaner.Token in [tokKeywordVar, tokKeywordThreadVar] then
    begin
      FormatVarSection(PreSpaceCount);
      Writeln;
      First := False;
    end
    else if Scaner.Token = tokKeywordConst then
    begin
      FormatClassConstSection(PreSpaceCount);
      Writeln;
      First := False;
    end
    else if Scaner.Token <> tokKeywordEnd then
    begin
      if First and IgnoreFirst then
        FormatFieldDecl
      else
        FormatFieldDecl(PreSpaceCount);
      First := False;

      if Scaner.Token = tokSemicolon then
      begin
        AfterIsRB := Scaner.ForwardToken in [tokRB];
        if not AfterIsRB then // ���滹�в�д�ֺźͻ���
        begin
          Match(Scaner.Token);
          Writeln;
        end
        else
          Scaner.NextToken;
      end
      else if Scaner.Token = tokKeywordEnd then // ���һ���޷ֺ�ʱҲ����
      begin
        Writeln;
        Break;
      end;
    end;
  end;

  if First and not (Scaner.Token = tokKeywordCase) then // û���������Ȼ��У�case ����
    Writeln;

  if Scaner.Token = tokKeywordCase then
  begin
    FormatVariantSection(PreSpaceCount);
    Writeln;
  end;

  if Scaner.Token = tokSemicolon then
    Match(Scaner.Token);
end;

{ FileType -> FILE [OF TypeId] }
procedure TCnBasePascalFormatter.FormatFileType(PreSpaceCount: Byte);
begin
  Match(tokKeywordFile);
  if Scaner.Token = tokKeywordOf then // �����ǵ����� file
  begin
    Match(tokKeywordOf);
    FormatTypeID;
  end;
end;

{ FormalParameters -> ['(' FormalParm/';'... ')'] }
procedure TCnBasePascalFormatter.FormatFormalParameters(PreSpaceCount: Byte);
begin
  Match(tokLB);

  SpecifyElementType(pfetFormalParameters);
  try
    if Scaner.Token <> tokRB then
      FormatFormalParm;

    while Scaner.Token = tokSemicolon do
    begin
      Match(Scaner.Token);
      FormatFormalParm;
    end;
  finally
    RestoreElementType;
  end;

  SpecifyElementType(pfetFormalParametersRightBracket);
  try
    Match(tokRB);
  finally
    RestoreElementType;
  end;
end;

{ FormalParm -> [Ref] [VAR | CONST | OUT] [Ref] Parameter }
procedure TCnBasePascalFormatter.FormatFormalParm(PreSpaceCount: Byte);
begin
  if Scaner.Token = tokSLB then
  begin
    Match(tokSLB);
    if Scaner.Token in KeywordTokens + [tokSymbol] then
      Match(Scaner.Token);
    Match(tokSRB, 0, 1); // ] ���и��ո�
  end;

  if (Scaner.Token in [tokKeywordVar, tokKeywordConst, tokKeywordOut]) and
     not (Scaner.ForwardToken in [tokColon, tokComma])
  then
  begin
    Match(Scaner.Token);

    if Scaner.Token = tokSLB then
    begin
      Match(tokSLB, 1, 0); // [ ǰ�и��ո�
      if Scaner.Token in KeywordTokens + [tokSymbol] then
        Match(Scaner.Token);
      Match(tokSRB, 0, 1); // ] ���и��ո�
    end;
  end;

  FormatParameter;
end;

{ TypeId -> [UnitId '.'] <type-identifier>
procedure TCnTypeSectionFormater.FormatTypeID(PreSpaceCount: Byte);
begin
  Match(tokSymbol);

  if Scaner.Token = tokDot then
  begin
    Match(Scaner.Token);
    Match(tokSymbol);
  end;
end;
}

{ FunctionHeading -> FUNCTION Ident [FormalParameters] ':' (SimpleType | STRING) }
procedure TCnBasePascalFormatter.FormatFunctionHeading(PreSpaceCount: Byte;
  AllowEqual: Boolean);
begin
  if Scaner.Token = tokKeywordClass then
  begin
    Match(tokKeywordClass, PreSpaceCount); // class ���������ֹ��ӿո�
    if Scaner.Token in [tokKeywordFunction, tokKeywordOperator] then
      Match(Scaner.Token);
  end
  else
  begin
    if Scaner.Token in [tokKeywordFunction, tokKeywordOperator] then
      Match(Scaner.Token, PreSpaceCount);
  end;
  
  {!! Fixed. e.g. "const proc: procedure = nil;" }
  if Scaner.Token in [tokSymbol] + ComplexTokens + DirectiveTokens
    + KeywordTokens then // ������������ֹؼ���
  begin
    // ���� of����Ȼ�� function of object ���﷨
    if (Scaner.Token <> tokKeywordOf) or (Scaner.ForwardToken = tokLB) then
      FormatMethodName;
  end;

  if Scaner.Token = tokSemicolon then // ���� Forward �ĺ���������������ʡ�Բ���������
    Exit;

  if AllowEqual and (Scaner.Token = tokEQUAL) then  // procedure Intf.Ident = Ident
  begin
    Match(tokEQUAL, 1, 1);
    FormatIdent;
    Exit;
  end;

  if Scaner.Token = tokLB then
    FormatFormalParameters;

  Match(tokColon);

  if Scaner.Token = tokKeywordString then
    Match(Scaner.Token)
  else
    FormatSimpleType;
end;

{ InterfaceHeritage -> '(' IdentList ')' }
procedure TCnBasePascalFormatter.FormatInterfaceHeritage(PreSpaceCount: Byte);
begin
  Match(tokLB);
  FormatTypeParamIdentList(); // ���뷺�͵�֧��
  Match(tokRB);
end;

{ // Change to below:
  InterfaceType -> INTERFACE [InterfaceHeritage] | DISPINTERFACE
                   [GUID]
                   [InterfaceMemberList]
                   END

  InterfaceMemberList -> ([InterfaceMember ';']) ...
  InterfaceMember -> InterfaceMethod | InterfaceProperty

  Ȼ�� InterfaceMethod �� InterfaceProperty ������ ClassMethod �� ClassProperty
}
procedure TCnBasePascalFormatter.FormatInterfaceType(PreSpaceCount: Byte);
begin
  if Scaner.Token = tokKeywordInterface then
  begin
    Match(tokKeywordInterface);

    if Scaner.Token = tokSemicolon then // �� ITest = interface; �����
      Exit;

    if Scaner.Token = tokLB then
      FormatInterfaceHeritage;
  end
  else if Scaner.Token = tokKeywordDispinterface then // ���� dispinterface �����
  begin
    Match(tokKeywordDispinterface);
    if Scaner.Token = tokSemicolon then // �� ITest = dispinterface; �����
      Exit;
  end;

  if Scaner.Token = tokSLB then // �� GUID
     FormatGuid(PreSpaceCount);

  if Scaner.Token in ClassVisibilityTokens then
    FormatClassVisibility;
  // �ſ����������� public ������

  // ѭ�����ڲ�������ڲ���Ҫ Writeln������ Class �� Property ����һ��
  while Scaner.Token in [tokKeywordProperty] + ClassMethodTokens + [tokSLB] do
  begin
    if Scaner.Token = tokSLB then // interface ����֧������
    begin
      Writeln;
      FormatSingleAttribute(Tab(PreSpaceCount));
    end
    else if Scaner.Token = tokKeywordProperty then
    begin
      Writeln;
      FormatClassPropertyList(PreSpaceCount + CnPascalCodeForRule.TabSpaceCount);
    end
    else
    begin
      Writeln;
      FormatMethodList(PreSpaceCount + CnPascalCodeForRule.TabSpaceCount);
    end;
  end;
  
  Writeln;
  Match(tokKeywordEnd, PreSpaceCount);
end;

procedure TCnBasePascalFormatter.FormatGuid(PreSpaceCount: Byte = 0);
begin
  Writeln;
  Match(tokSLB, PreSpaceCount + CnPascalCodeForRule.TabSpaceCount);
  FormatConstExpr;
  Match(tokSRB);
end;

{
  MethodHeading -> ProcedureHeading
                -> FunctionHeading
                -> ConstructorHeading
                -> DestructorHeading
                -> PROCEDURE | FUNCTION InterfaceId.Ident '=' Ident

                class var / class property also processed here
}
procedure TCnBasePascalFormatter.FormatMethodHeading(PreSpaceCount: Byte;
  HasClassPrefixForVar: Boolean);
begin
  case Scaner.Token of
    tokKeywordProcedure: FormatProcedureHeading(PreSpaceCount);
    tokKeywordFunction, tokKeywordOperator: FormatFunctionHeading(PreSpaceCount); // class operator
    tokKeywordConstructor: FormatConstructorHeading(PreSpaceCount);
    tokKeywordDestructor: FormatDestructorHeading(PreSpaceCount);
    tokKeywordProperty: FormatClassProperty(PreSpaceCount); // class property

    tokKeywordVar, tokKeywordThreadVar: FormatVarDeclHeading(Tab(PreSpaceCount), HasClassPrefixForVar);  // class var/threadvar
  else
    Error(CN_ERRCODE_PASCAL_NO_METHODHEADING);
  end;
end;

{ MethodList -> (MethodHeading [';' VIRTUAL])/';'... }
procedure TCnBasePascalFormatter.FormatMethodList(PreSpaceCount: Byte);
var
  IsFirst: Boolean;
begin
  // Writeln;

  // Class Method List maybe hava Class Visibility Token
  FormatClassVisibility(PreSpaceCount);
  FormatMethodHeading(PreSpaceCount);
  Match(tokSemicolon);

  IsFirst := True;
  while Scaner.Token in DirectiveTokens do
  begin
    FormatDirective(PreSpaceCount, IsFirst);
    IsFirst := False;
    if Scaner.Token = tokSemicolon then
     Match(tokSemicolon, 0, 0, True);
  end;

  while (Scaner.Token in ClassVisibilityTokens) or
        (Scaner.Token in ClassMethodTokens) do
  begin
    Writeln;

    if Scaner.Token in ClassVisibilityTokens then
      FormatClassVisibility(PreSpaceCount);

    FormatMethodHeading(PreSpaceCount);
    Match(tokSemicolon);

    IsFirst := True;
    while Scaner.Token in DirectiveTokens do
    begin
      FormatDirective(PreSpaceCount, IsFirst);
      IsFirst := False;
      if Scaner.Token = tokSemicolon then
        Match(tokSemicolon, 0, 0, True);
    end;
  end;
end;

{ ObjectType -> OBJECT [ObjHeritage] [ObjFieldList] [MethodList] END }
procedure TCnBasePascalFormatter.FormatObjectType(PreSpaceCount: Byte);
begin
  Match(tokKeywordObject);
  if Scaner.Token = tokSemicolon then
    Exit;

  if Scaner.Token = tokLB then
  begin
    FormatObjHeritage // ObjHeritage -> '(' QualId ')'
  end;

  Writeln;

  // �� class �Ĵ���ʽӦ�ü���
  while Scaner.Token in ClassVisibilityTokens + ClassMemberSymbolTokens
    - [tokKeywordPublished, tokKeywordConstructor, tokKeywordDestructor] do
  begin
    if Scaner.Token in ClassVisibilityTokens - [tokKeywordPublished] then
      FormatClassVisibility(PreSpaceCount);

    if Scaner.Token in ClassMemberSymbolTokens
      - [tokKeywordConstructor, tokKeywordDestructor] then
      FormatClassMember(Tab(PreSpaceCount));
  end;

  Match(tokKeywordEnd, PreSpaceCount);
end;

{ ObjFieldList -> (IdentList ':' Type)/';'... }
procedure TCnBasePascalFormatter.FormatObjFieldList(PreSpaceCount: Byte);
begin
  FormatIdentList(PreSpaceCount);
  Match(tokColon);
  FormatType(PreSpaceCount);

  while Scaner.Token = tokSemicolon do
  begin
    Match(Scaner.Token);

    if Scaner.Token <> tokSymbol then Exit;

    Writeln;

    FormatIdentList(PreSpaceCount);
    Match(tokColon);
    FormatType(PreSpaceCount);
  end;
end;

{ ObjHeritage -> '(' QualId ')' }
procedure TCnBasePascalFormatter.FormatObjHeritage(PreSpaceCount: Byte);
begin
  Match(tokLB);
  FormatQualID;
  Match(tokRB);
end;

{ OrdinalType -> (SubrangeType | EnumeratedType | OrdIdent) }
procedure TCnBasePascalFormatter.FormatOrdinalType(PreSpaceCount: Byte;
  FromSetOf: Boolean);
var
  Bookmark: TScannerBookmark;

  procedure NextTokenWithDot;
  begin
    repeat
      Scaner.NextToken;
    until not (Scaner.Token in [tokSymbol, tokDot, tokInteger, tokLB, tokRB,
      tokPlus, tokMinus, tokStar, tokDiv, tokKeywordDiv, tokKeywordMod]);
    // ���� () ����Ϊ������������ Low(Integer)..High(Integer) �����
    // ���ð�������������ȣ��Ա��������������������
  end;

  procedure MatchTokenWithDot;
  begin
    while Scaner.Token in [tokSymbol, tokDot] do
      Match(Scaner.Token);
  end;

begin
  if Scaner.Token = tokLB then  // EnumeratedType
  begin
    if FromSetOf then // ���ǰ���� set of ����ǰ��Ҫ��һ��
      FormatEnumeratedType(1)
    else
      FormatEnumeratedType(PreSpaceCount);
  end
  else
  begin
    Scaner.SaveBookmark(Bookmark);
    CodeGen.LockOutput;

    if Scaner.Token = tokMinus then // ���ǵ����ŵ����
      Scaner.NextToken;

    NextTokenWithDot;
    
    if Scaner.Token = tokRange then
    begin
      Scaner.LoadBookmark(Bookmark);
      CodeGen.UnLockOutput;
      // SubrangeType
      FormatSubrangeType(PreSpaceCount);
    end
    else
    begin
      Scaner.LoadBookmark(Bookmark);
      CodeGen.UnLockOutput;
      // OrdIdent
      if Scaner.Token = tokMinus then
        Match(Scaner.Token);

      MatchTokenWithDot;
    end;
    {
    // OrdIdent
    if Scaner.TokenSymbolIs('SHORTINT') or
       Scaner.TokenSymbolIs('SMALLINT') or
       Scaner.TokenSymbolIs('INTEGER')  or
       Scaner.TokenSymbolIs('BYTE')     or
       Scaner.TokenSymbolIs('LONGINT')  or
       Scaner.TokenSymbolIs('INT64')    or
       Scaner.TokenSymbolIs('WORD')     or
       Scaner.TokenSymbolIs('BOOLEAN')  or
       Scaner.TokenSymbolIs('CHAR')     or
       Scaner.TokenSymbolIs('WIDECHAR') or
       Scaner.TokenSymbolIs('LONGWORD') or
       Scaner.TokenSymbolIs('PCHAR')
    then
      Match(Scaner.Token);
    }
  end;
end;

{
  Parameter -> [CONST] IdentList  [':' ([ARRAY OF] SimpleType | STRING | FILE)]
            -> [CONST] Ident  [':' ([ARRAY OF] SimpleType | STRING | FILE | CONST)] ['=' ConstExpr]]
            // -> Ident ':=' Expression

  note: [ARRAY OF] and ['=' ConstExpr] can not exists at same time
        old grammer is -> Ident ':' SimpleType ['=' ConstExpr]
        // Ident ':=' Expression ��Ϊ��֧�� OLE �ĸ�ʽ�ĵ���
}
procedure TCnBasePascalFormatter.FormatParameter(PreSpaceCount: Byte);
begin
  if Scaner.Token = tokKeywordConst then
    Match(Scaner.Token);
  
  if Scaner.ForwardToken = tokComma then //IdentList
  begin
    FormatIdentList(PreSpaceCount);
    
    if Scaner.Token = tokColon then
    begin
      Match(Scaner.Token);

      if Scaner.Token = tokKeywordArray then
      begin
        Match(Scaner.Token);
        Match(tokKeywordOf);
      end;

      if Scaner.Token in [tokKeywordString, tokKeywordFile] then
        Match(Scaner.Token)
      else
        FormatSimpleType;
    end;
  end
  else // Ident
  begin
    FormatIdent(PreSpaceCount);

    if Scaner.Token = tokColon then
    begin
      Match(tokColon);

      if Scaner.Token = tokKeywordArray then
      begin
        //CanHaveDefaultValue := False;
        Match(Scaner.Token);
        Match(tokKeywordOf);
      end;

      if Scaner.Token in [tokKeywordString, tokKeywordFile, tokKeywordConst] then
        Match(Scaner.Token)
      else
        FormatSimpleType;

      if Scaner.Token = tokEQUAL then
      begin
        //if not CanHaveDefaultValue then
        //  Error('Can not have default value');

        Match(tokEQUAL, 1, 1);
        FormatConstExpr;
      end;
    end
    else if Scaner.Token = tokAssign then // ƥ�� OLE ���õ�����
    begin
      Match(tokAssign);
      FormatExpression;
    end;
  end;

  {
  // IdentList
  if Scaner.Token = tokComma then
  begin
    Match(tokComma);
    FormatIdentList;
    if Scaner.Token = tokColon then
    begin
      Match(Scaner.Token);

      if Scaner.Token = tokKeywordArray then
      begin
        Match(Scaner.Token);
        Match(tokKeywordOf);
      end;

      if Scaner.Token in [tokKeywordString, tokKeywordFile] then
        Match(Scaner.Token)
      else
        FormatSimpleType;
    end;
  end else
  // Ident
  begin
    Match(tokColon);

    if Scaner.Token = tokKeywordString then
    begin
      Match(Scaner.Token);
    end else
      FormatSimpleType;

    if Scaner.Token = tokEQUAL then
    begin
      Match(tokEQUAL);
      FormatConstExpr;
    end;
  end;
}
end;

{ PointerType -> '^' TypeId }
procedure TCnBasePascalFormatter.FormatPointerType(PreSpaceCount: Byte);
begin
  Match(tokHat);
  FormatTypeID;
end;

{ ProcedureHeading -> [CLASS] PROCEDURE Ident [FormalParameters] }
procedure TCnBasePascalFormatter.FormatProcedureHeading(PreSpaceCount: Byte;
  AllowEqual: Boolean);
begin
  if Scaner.Token = tokKeywordClass then
  begin
    Match(tokKeywordClass, PreSpaceCount); // class ���������ֹ��ӿո�
    Match(Scaner.Token);
  end
  else
    Match(Scaner.Token, PreSpaceCount);

  { !! Fixed. e.g. "const proc: procedure = nil;" }
  if Scaner.Token in [tokSymbol] + ComplexTokens + DirectiveTokens
    + KeywordTokens - [tokKeywordBegin, tokKeywordVar, tokKeywordConst, tokKeywordType] then
  begin // ������������ֹؼ��֣������������޲ζ����� begin/var/const/type �ȳ���
    // ���� of
    if (Scaner.Token <> tokKeywordOf) or (Scaner.ForwardToken = tokLB) then
      FormatMethodName;
  end;

  if Scaner.Token = tokLB then
    FormatFormalParameters;

  if AllowEqual and (Scaner.Token = tokEQUAL) then  // procedure Intf.Ident = Ident
  begin
    Match(tokEQUAL, 1, 1);
    FormatIdent;
  end;
end;

{ ProcedureType -> (ProcedureHeading | FunctionHeading) [OF OBJECT] [(DIRECTIVE [';'])...] }
procedure TCnBasePascalFormatter.FormatProcedureType(PreSpaceCount: Byte);
var
  IsSemicolon: Boolean;
begin
  case Scaner.Token of
    tokKeywordProcedure:
      begin
        FormatProcedureHeading(PreSpaceCount, False); // Proc �� Type ������ֵȺ�
        if Scaner.Token = tokKeywordOf then
        begin
          Match(tokKeywordOf); // ����� procedure��ǰ��û�ո�Ҫ����ո�
          Match(tokKeywordObject);
        end;
      end;
    tokKeywordFunction:
      begin
        FormatFunctionHeading(PreSpaceCount, False);
        if Scaner.Token = tokKeywordOf then
        begin
          Match(tokKeywordOf); // ����� function��ǰ���Ѿ��пո��˾Ͳ��ÿո���
          Match(tokKeywordObject);
        end;
      end;
  end;

  // deal with the Directive after OF OBJECT
  // if Scaner.Token in DirectiveTokens then WriteOneSpace;

  IsSemicolon := False;
  if (Scaner.Token = tokSemicolon) and (Scaner.ForwardToken in DirectiveTokens) then
  begin
    Match(tokSemicolon);
    IsSemicolon := True;
  end;  // ���� stdcall ֮ǰ�ķֺ�

  while Scaner.Token in DirectiveTokens do
  begin
    FormatDirective(0, IsSemicolon);

    if (Scaner.Token = tokSemicolon) and
      (Scaner.ForwardToken() in DirectiveTokens) then
      Match(tokSemicolon);

    // leave one semicolon for procedure type define at last.
  end;
end;

{ PropertyInterface -> [PropertyParameterList] ':' Ident }
procedure TCnBasePascalFormatter.FormatPropertyInterface(PreSpaceCount: Byte);
begin
  if Scaner.Token <> tokColon then
    FormatPropertyParameterList;

  Match(tokColon);

  FormatType(PreSpaceCount, True);
end;

{ PropertyList -> PROPERTY  Ident [PropertyInterface]  PropertySpecifiers }
procedure TCnBasePascalFormatter.FormatPropertyList(PreSpaceCount: Byte);
begin
  Match(tokKeywordProperty, PreSpaceCount);
  FormatIdent;

  if Scaner.Token in [tokSLB, tokColon] then
    FormatPropertyInterface;

  FormatPropertySpecifiers;

  if Scaner.Token = tokSemicolon then
    Match(tokSemicolon);
  
  if Scaner.TokenSymbolIs('DEFAULT') then
  begin
    Match(Scaner.Token);
    Match(tokSemicolon);
  end;
end;

{ PropertyParameterList -> '[' (IdentList ':' TypeId)/';'... ']' }
procedure TCnBasePascalFormatter.FormatPropertyParameterList(PreSpaceCount: Byte);
begin
  Match(tokSLB);

  if Scaner.Token in [tokKeywordVar, tokKeywordConst, tokKeywordOut] then
    Match(Scaner.Token);
  FormatIdentList;
  Match(tokColon);
  FormatTypeID;

  while Scaner.Token = tokSemicolon do
  begin
    Match(tokSemicolon);
    if Scaner.Token in [tokKeywordVar, tokKeywordConst, tokKeywordOut] then
      Match(Scaner.Token);
    FormatIdentList;
    Match(tokColon);
    FormatTypeID;
  end;

  Match(tokSRB);
end;

{
  PropertySpecifiers -> [INDEX ConstExpr]
                        [READ Ident]
                        [WRITE Ident]
                        [STORED (Ident | Constant)]
                        [(DEFAULT ConstExpr) | NODEFAULT]
                        [IMPLEMENTS TypeId]
}
{
  TODO: Here has something wrong. The keyword can be repeat.
}
procedure TCnBasePascalFormatter.FormatPropertySpecifiers(PreSpaceCount: Byte);

  procedure ProcessBlank;
  begin
    if Scaner.Token in [tokString, tokWString, tokLB, tokPlus, tokMinus] then
      WriteOneSpace; // �������ʽ�ո�ָ�
  end;

begin
  try
    SpecifyElementType(pfetPropertySpecifier);
    while Scaner.Token in PropertySpecifiersTokens do
    begin
      case Scaner.Token of
        tokComplexIndex:
        begin
          try
            SpecifyElementType(pfetPropertyIndex);
            Match(Scaner.Token);
          finally
            RestoreElementType;
          end;
          ProcessBlank;
          FormatConstExpr;
        end;

        tokComplexRead:
        begin
          Match(Scaner.Token);
          ProcessBlank;
          FormatDesignator(0);
          //FormatIdent(0, True);
        end;

        tokComplexWrite:
        begin
          Match(Scaner.Token);
          ProcessBlank;
          FormatDesignator(0);
          //FormatIdent(0, True);
        end;

        tokComplexStored:
        begin
          Match(Scaner.Token);
          ProcessBlank;
          FormatConstExpr; // Constrant is an Expression
        end;

        tokComplexImplements:
        begin
          Match(Scaner.Token);
          ProcessBlank;
          FormatTypeID;
        end;

        tokComplexDefault:
        begin
          Match(Scaner.Token);
          ProcessBlank;
          FormatConstExpr;
        end;

        tokDirectiveDispID:
        begin
          Match(Scaner.Token);
          ProcessBlank;
          FormatExpression;
        end;

        tokComplexNodefault, tokComplexReadonly, tokComplexWriteonly:
          Match(Scaner.Token);
      end;
    end;
  finally
    RestoreElementType;
  end;
end;

{ RecordConstant -> '(' RecordFieldConstant/';'... ')' }
procedure TCnBasePascalFormatter.FormatRecordConstant(PreSpaceCount: Byte);
begin
  Match(tokLB);

  Writeln;
  FormatRecordFieldConstant(Tab(PreSpaceCount));
  if Scaner.Token = tokSemicolon then Match(Scaner.Token);

  while Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens) do // ��ʶ������˵�����
  begin
    Writeln;
    FormatRecordFieldConstant(Tab(PreSpaceCount));
    if Scaner.Token = tokSemicolon then Match(Scaner.Token);
  end;

  Writeln;
  Match(tokRB, PreSpaceCount);
end;

{ RecordFieldConstant -> Ident ':' TypedConstant }
procedure TCnBasePascalFormatter.FormatRecordFieldConstant(PreSpaceCount: Byte);
begin
  FormatIdent(PreSpaceCount);
  Match(tokColon);
  FormatTypedConstant;
end;

{ RecType -> RECORD [FieldList] END }
procedure TCnBasePascalFormatter.FormatRecType(PreSpaceCount: Byte);
begin
  Match(tokKeywordRecord);

  // record helper for Ident
  if (Scaner.Token = tokSymbol) and (Scaner.ForwardToken = tokKeywordFor)
    and (LowerCase(Scaner.TokenString) = 'helper') then
  begin
    Match(Scaner.Token);
    Match(tokKeywordFor);
    FormatIdent(0);
  end;
  Writeln;

  if Scaner.Token <> tokKeywordEnd then
    FormatFieldList(Tab(PreSpaceCount));

//  FormatClassMemberList(PreSpaceCount); Classmember do not know 'case'

  Match(tokKeywordEnd, PreSpaceCount);
  if Scaner.Token = tokKeywordAlign then  // ֧�� record end align 16 �������﷨
  begin
    SpecifyElementType(pfetRecordEnd);
    try
      Match(tokKeywordAlign);
      FormatConstExpr;
    finally
      RestoreElementType;
    end;
  end;
end;

{ RecVariant -> ConstExpr/','...  ':' '(' [FieldList] ')' }
procedure TCnBasePascalFormatter.FormatRecVariant(PreSpaceCount: Byte;
  IgnoreFirst: Boolean);
begin
  FormatConstExpr(PreSpaceCount);

  while Scaner.Token = tokComma do
  begin
    Match(Scaner.Token);
    FormatConstExpr;
  end;

  Match(tokColon); // case ����д�����־�������־��������д()
  Writeln;
  Match(tokLB, Tab(PreSpaceCount));
  if Scaner.Token <> tokRB then
    FormatFieldList(Tab(PreSpaceCount), IgnoreFirst);

  // ���Ƕ���˼�¼�������ű���������û�ð취�������ж���һ���ǲ��Ƿֺź�������
  if FLastToken in [tokSemicolon, tokLB, tokBlank] then
    Match(tokRB, PreSpaceCount)
  else
    Match(tokRB);
end;

{ RequiresClause -> REQUIRES IdentList... ';' }
procedure TCnBasePascalFormatter.FormatRequiresClause(PreSpaceCount: Byte);
begin
  if Scaner.TokenSymbolIs('REQUIRES') then
  begin
    Match(Scaner.Token, 0, 1);
    FormatIdentList;
    Match(tokSemicolon);
  end;
end;

{
  RestrictedType -> ObjectType
                 -> ClassType
                 -> InterfaceType
}
procedure TCnBasePascalFormatter.FormatRestrictedType(PreSpaceCount: Byte);
begin
  case Scaner.Token of
    tokKeywordObject: FormatObjectType(PreSpaceCount);
    tokKeywordClass: FormatClassType(PreSpaceCount);
    tokKeywordInterface, tokKeywordDispinterface: FormatInterfaceType(PreSpaceCount);
  end;
end;

{ SetType -> SET OF OrdinalType }
procedure TCnBasePascalFormatter.FormatSetType(PreSpaceCount: Byte);
begin
  // Set �ڲ��������������ʹ�� PreSpaceCount
  Match(tokKeywordSet);
  Match(tokKeywordOf);
  FormatOrdinalType(0, True);
end;

{ SimpleType -> (SubrangeType | EnumeratedType | OrdIdent | RealType) }
procedure TCnBasePascalFormatter.FormatSimpleType(PreSpaceCount: Byte);
begin
  if Scaner.Token = tokLB then
    FormatSubrangeType
  else
  begin
    FormatConstExprInType;
    if Scaner.Token = tokRange then
    begin
      Match(tokRange);
      FormatConstExprInType;
    end;
  end;

  // �����<>���͵�֧��
  if Scaner.Token = tokLess then
  begin
    FormatTypeParams;
  end;
end;

{
  StringType -> STRING
             -> ANSISTRING
             -> WIDESTRING
             -> STRING '[' ConstExpr ']'
}
procedure TCnBasePascalFormatter.FormatStringType(PreSpaceCount: Byte);
begin
  Match(Scaner.Token);
  if Scaner.Token = tokSLB then
  begin
    Match(Scaner.Token);
    FormatConstExpr;
    Match(tokSRB);
  end
  else if Scaner.Token = tokLB then   // ���� _UTF8String = type AnsiString(65001); ����
  begin
    Match(tokLB);
    FormatExpression;
    Match(tokRB);
  end;
end;

{ StrucType -> [PACKED] (ArrayType | SetType | FileType | RecType) }
procedure TCnBasePascalFormatter.FormatStructType(PreSpaceCount: Byte);
begin
  if Scaner.Token = tokkeywordPacked then
    Match(Scaner.Token);

  case Scaner.Token of
    tokKeywordArray: FormatArrayType(PreSpaceCount);
    tokKeywordSet: FormatSetType(PreSpaceCount);
    tokKeywordFile: FormatFileType(PreSpaceCount);
    tokKeywordRecord: FormatRecType(PreSpaceCount);
  else
    Error(CN_ERRCODE_PASCAL_NO_STRUCTTYPE);
  end;
end;

{ SubrangeType -> ConstExpr '..' ConstExpr }
procedure TCnBasePascalFormatter.FormatSubrangeType(PreSpaceCount: Byte);
begin
  FormatConstExpr(PreSpaceCount);
  Match(tokRange);
  FormatConstExpr(PreSpaceCount);
end;

{
  Type -> TypeId
       -> SimpleType
       -> StrucType
       -> PointerType
       -> StringType
       -> ProcedureType
       -> VariantType
       -> ClassRefType

       -> reference to ProcedureType
}
procedure TCnBasePascalFormatter.FormatType(PreSpaceCount: Byte;
  IgnoreDirective: Boolean);
var
  Bookmark: TScannerBookmark;
  AToken, OldLastToken: TPascalToken;
begin
  if (Scaner.Token = tokSymbol) and (Scaner.ForwardToken = tokKeywordTo) and
    (LowerCase(Scaner.TokenString) = 'reference') then
  begin
    // Anonymous Declaration
    Match(Scaner.Token);
    Match(tokKeywordTo);
  end;

  case Scaner.Token of // ���������軻�У�������贫�� PreSpaceCount
    tokKeywordProcedure, tokKeywordFunction: FormatProcedureType();
    tokHat: FormatPointerType();
    tokKeywordClass: FormatClassRefType();
  else
    // StructType
    if Scaner.Token in StructTypeTokens then
    begin
      FormatStructType(PreSpaceCount);
    end
    else
    // StringType
    if (Scaner.Token = tokKeywordString) or
      Scaner.TokenSymbolIs('String')  or
      Scaner.TokenSymbolIs('AnsiString') or
      Scaner.TokenSymbolIs('WideString') then
    begin
      FormatStringType; // ���軻��
    end
    else // EnumeratedType
    if Scaner.Token = tokLB then
    begin
      FormatEnumeratedType; // ���軻��
    end
    else
    begin
      //TypeID, SimpleType, VariantType
      { SubrangeType -> ConstExpr '..' ConstExpr }
      { TypeId -> [UnitId '.'] <type-identifier> }

      Scaner.SaveBookmark(Bookmark);
      OldLastToken := FLastToken;

      // �Ȳ�һ�£�����һ�����ʽ�������������ʲô
      CodeGen.LockOutput;
      try
        FormatConstExprInType;
      finally
        CodeGen.UnLockOutput;
      end;

      // LoadBookmark �󣬱���ѵ�ʱ�� FLastToken Ҳ�ָ������������Ӱ��ո�����
      AToken := Scaner.Token;
      Scaner.LoadBookmark(Bookmark);
      FLastToken := OldLastToken;

      { TypeId }
      if AToken = tokDot then
      begin
        FormatConstExpr;
        Match(Scaner.Token);
        Match(tokSymbol);
      end
      else if AToken = tokRange then { SubrangeType }
      begin
        FormatConstExpr;
        Match(tokRange);
        FormatConstExpr;
      end
      else if AToken = tokLess then // �����<>���͵�֧��
      begin
        FormatIdent;
        FormatTypeParams;
        if Scaner.Token = tokDot then
        begin
          Match(tokDot);
          FormatIdent;
        end;
      end
      else
      begin
        FormatTypeID;
      end;
    end;
  end;

  // �����<>���͵�֧��
  if Scaner.Token = tokLess then
  begin
    FormatTypeParams;
    if Scaner.Token = tokDot then
    begin
      Match(tokDot);
      FormatIdent;
    end;
  end;

  if not IgnoreDirective then
    while Scaner.Token in DirectiveTokens do
      FormatDirective;
end;

{ TypedConstant -> (ConstExpr | SetConstructor | ArrayConstant | RecordConstant) }
procedure TCnBasePascalFormatter.FormatTypedConstant(PreSpaceCount: Byte);
type
  TCnTypedConstantType = (tcConst, tcArray, tcRecord);
var
  TypedConstantType: TCnTypedConstantType;
  Bookmark: TScannerBookmark;
  OldLastToken: TPascalToken;
begin
  // DONE: �������ž͸��ж�һ�£�����Ĵ����� symbol: ���ǳ�����
  // Ȼ��ֱ����FormatArrayConstant��FormatRecordConstant
  TypedConstantType := tcConst;
  case Scaner.Token of
    // tokKeywordArray: FormatArrayConstant(PreSpaceCount); // û�����﷨
    tokSLB:
      begin
        FormatSetConstructor;
        while Scaner.Token in (AddOPTokens + MulOpTokens) do // Set ֮�������
        begin
          MatchOperator(Scaner.Token);
          FormatSetConstructor;
        end;
      end;  
    tokLB:
      begin // �����ŵģ���ʾ����ϵ�Type
        if Scaner.ForwardToken = tokLB then // ������滹�����ţ���˵���������ǳ�����array
        begin
          Scaner.SaveBookmark(Bookmark);
          OldLastToken := FLastToken;
          try
            try
              CodeGen.LockOutput;
              FormatConstExpr;

              if Scaner.Token = tokComma then // ((1, 1) ������
                TypedConstantType := tcArray
              else if Scaner.Token = tokSemicolon then // ((1) ������
                TypedConstantType := tcConst;
            except
              // ��������������������
              TypedConstantType := tcArray;
            end;
          finally
            CodeGen.UnLockOutput;
          end;

          Scaner.LoadBookmark(Bookmark);
          FLastToken := OldLastToken;

          if TypedConstantType = tcArray then
            FormatArrayConstant(PreSpaceCount)
          else if Scaner.Token in ConstTokens
            + [tokAtSign, tokPlus, tokMinus, tokLB, tokRB] then // �п��ܳ�ʼ����ֵ����Щ��ͷ
            FormatConstExpr(PreSpaceCount)
        end
        else // ���ֻ�Ǳ����ţ����ú������ж��Ƿ� a: 0 ��������ʽ������ TypedConstantType
        begin
          Scaner.SaveBookmark(Bookmark);
          OldLastToken := FLastToken;

          if (Scaner.ForwardToken in ([tokSymbol] + KeywordTokens + ComplexTokens))
            and (Scaner.ForwardToken(2) = tokColon) then
          begin
            // ���ź��г�������ð�ű�ʾ�� recordfield
            TypedConstantType := tcRecord;
          end
          else // ƥ��һ�� ( ConstExpr)  Ȼ�󿴺����Ƿ���;���������ж��Ƿ�������
          begin
            try
              try
                CodeGen.LockOutput;
                Match(tokLB);
                FormatConstExpr;

                if Scaner.Token = tokComma then // (1, 1) ������
                  TypedConstantType := tcArray;
                if Scaner.Token = tokRB then
                  Match(tokRB);

                if Scaner.Token = tokSemicolon then // (1) ������
                  TypedConstantType := tcArray;
              except
                ;
              end;
            finally
              CodeGen.UnLockOutput;
            end;
          end;

          Scaner.LoadBookmark(Bookmark);
          FLastToken := OldLastToken;

          if TypedConstantType = tcArray then
            FormatArrayConstant(PreSpaceCount)
          else if TypedConstantType = tcRecord then
            FormatRecordConstant(PreSpaceCount + CnPascalCodeForRule.TabSpaceCount)
          else if Scaner.Token in ConstTokens
            + [tokAtSign, tokPlus, tokMinus, tokLB, tokRB] then // �п��ܳ�ʼ����ֵ����Щ��ͷ
            FormatConstExpr(PreSpaceCount)
        end;
      end;
  else // �������ſ�ͷ��˵���Ǽ򵥵ĳ�����ֱ�Ӵ���
    if Scaner.Token in ConstTokens + [tokAtSign, tokPlus, tokMinus, tokHat] then // �п��ܳ�ʼ����ֵ����Щ��ͷ
      FormatConstExpr(PreSpaceCount)
    else if Scaner.Token <> tokRB then
      Error(CN_ERRCODE_PASCAL_NO_TYPEDCONSTANT);
  end;
end;

{
  TypeDecl -> Ident '=' Type
           -> Ident '=' RestrictedType
}
procedure TCnBasePascalFormatter.FormatTypeDecl(PreSpaceCount: Byte);
var
  Old, GreatEqual: Boolean;
begin
  while Scaner.Token = tokSLB do
  begin
    FormatSingleAttribute(PreSpaceCount);
    Writeln;
  end;

  Old := FIsTypeID;
  try
    FIsTypeID := True;
    FormatIdent(PreSpaceCount);
  finally
    FIsTypeID := Old;
  end;

  // �����<>���͵�֧��
  GreatEqual := False;
  if Scaner.Token = tokLess then
  begin
    GreatEqual := FormatTypeParams(0, True);
  end;

  if not GreatEqual then
    MatchOperator(tokEQUAL);

  if Scaner.Token = tokKeywordType then // ���� TInt = type Integer; ������
    Match(tokKeywordType);

  if Scaner.Token in RestrictedTypeTokens then
    FormatRestrictedType(PreSpaceCount)
  else
    FormatType(PreSpaceCount);
end;

{ TypeSection -> TYPE (TypeDecl ';')... }
procedure TCnBasePascalFormatter.FormatTypeSection(PreSpaceCount: Byte);
const
  IsTypeStartTokens = [tokSymbol, tokSLB] + ComplexTokens + DirectiveTokens
    + KeywordTokens - NOTExpressionTokens;
var
  FirstType: Boolean;
begin
  Match(tokKeywordType, PreSpaceCount);
  Writeln;

  FirstType := True;
  while Scaner.Token in IsTypeStartTokens do // Attribute will use [
  begin
    // �����[����ҪԽ�������ԣ��ҵ�]��ĵ�һ����ȷ�����Ƿ��� type��������ǣ�������
    if (Scaner.Token = tokSLB) and not IsTokenAfterAttributesInSet(IsTypeStartTokens) then
      Exit;

    if not FirstType then WriteLine;

    FormatTypeDecl(Tab(PreSpaceCount));
    while Scaner.Token in DirectiveTokens do
      FormatDirective;
    Match(tokSemicolon);
    FirstType := False;
  end;
end;

{ VariantSection -> CASE [Ident ':'] TypeId OF RecVariant/';'... }
procedure TCnBasePascalFormatter.FormatVariantSection(PreSpaceCount: Byte);
begin
  Match(tokKeywordCase, PreSpaceCount);
  if Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens) then // case ������˵�����
    Match(Scaner.Token);

  // Ident
  if Scaner.Token = tokColon then
  begin
    Match(tokColon);
    FormatTypeID;
  end
  else
  // TypeID ���� Dot��ǰ���Ϊ UnitId�����Ϊ TypeId
  while Scaner.Token = tokDot do
  begin
    Match(tokDot);
    FormatTypeID;
  end;

  Match(tokKeywordOf);
  Writeln;
  FormatRecVariant(Tab(PreSpaceCount), True);

  while Scaner.Token = tokSemicolon do
  begin
    Match(Scaner.Token);
    if not (Scaner.Token in [tokKeywordEnd, tokRB]) then // end �� ) ��ʾ��Ҫ�˳���
    begin
      Writeln;
      FormatRecVariant(Tab(PreSpaceCount), True);
    end;
  end;
end;

{ TCnProgramBlockFormater }

{
  Block -> [DeclSection]
           CompoundStmt
}
procedure TCnBasePascalFormatter.FormatBlock(PreSpaceCount: Byte;
  IsInternal: Boolean; MultiCompound: Boolean);
begin
  while Scaner.Token in DeclSectionTokens do
  begin
    FormatDeclSection(PreSpaceCount, True, IsInternal);
    Writeln;
  end;

  if MultiCompound and not (FGoalType in [gtProgram, gtLibrary]) then
  begin
    while Scaner.Token in BlockStmtTokens do
    begin
      FormatCompoundStmt(PreSpaceCount);
      if Scaner.Token = tokSemicolon then
      begin
        Match(Scaner.Token);
        if Scaner.Token in BlockStmtTokens then // ���滹������
          Writeln;
      end;
    end;
  end
  else
  begin
    FormatCompoundStmt(PreSpaceCount);
  end;
end;

procedure TCnBasePascalFormatter.FormatProgramInnerBlock(PreSpaceCount: Byte;
  IsInternal: Boolean; IsLib: Boolean);
var
  HasDeclSection: Boolean;
begin
  HasDeclSection := False;
  while Scaner.Token in DeclSectionTokens do
  begin
    FormatDeclSection(PreSpaceCount, False, IsInternal);
    Writeln;
    HasDeclSection := True;
  end;

  if HasDeclSection then // �������Ŷ໻�У���������������
    Writeln;

  if IsLib and (Scaner.Token = tokKeywordEnd) then // Library ����ֱ�� end
    Match(Scaner.Token)
  else
    FormatCompoundStmt(PreSpaceCount);
end;

{
  ConstantDecl -> Ident '=' ConstExpr [DIRECTIVE/..]

               -> Ident ':' TypeId '=' TypedConstant
  FIXED:       -> Ident ':' Type '=' TypedConstant [DIRECTIVE/..]
}
procedure TCnBasePascalFormatter.FormatConstantDecl(PreSpaceCount: Byte);
begin
  FormatIdent(PreSpaceCount);

  case Scaner.Token of
    tokEQUAL:
      begin
        Match(Scaner.Token, 1); // �Ⱥ�ǰ��һ��
        FormatConstExpr(1); // �Ⱥź�ֻ��һ��
      end;

    tokColon: // �޷�ֱ������ record/array/��ͨ������ʽ�ĳ�ʼ������Ҫ�ڲ�����
      begin
        Match(Scaner.Token);

        FormatType;
        Match(tokEQUAL, 1, 1); // �Ⱥ�ǰ���һ��

        FormatTypedConstant; // �Ⱥź��һ��
      end;
  else
    Error(CN_ERRCODE_PASCAL_NO_EQUALCOLON);
  end;

  while Scaner.Token in DirectiveTokens do
    FormatDirective;
end;

{
  ConstSection -> CONST (ConstantDecl ';')...
                  RESOURCESTRING (ConstantDecl ';')...

  Note: resourcestring ֻ֧���ַ��ͳ���������ʽ��ʱ�ɲ����Ƕ�������ͨ�����Դ�
}
procedure TCnBasePascalFormatter.FormatConstSection(PreSpaceCount: Byte);
const
  IsConstStartTokens = [tokSymbol, tokSLB] + ComplexTokens + DirectiveTokens
    + KeywordTokens - NOTExpressionTokens;
begin
  if Scaner.Token in [tokKeywordConst, tokKeywordResourcestring] then
    Match(Scaner.Token, PreSpaceCount);

  while Scaner.Token in IsConstStartTokens do // ��Щ�ؼ��ֲ�������������Ҳ���ô���ֻ����д��
  begin
    // �����[����ҪԽ�������ԣ��ҵ�]��ĵ�һ����ȷ�����Ƿ��� const��������ǣ�������
    if (Scaner.Token = tokSLB) and not IsTokenAfterAttributesInSet(IsConstStartTokens) then
      Exit;

    Writeln;
    FormatConstantDecl(Tab(PreSpaceCount));
    Match(tokSemicolon);
  end;
end;

{
  DeclSection -> LabelDeclSection
              -> ConstSection
              -> TypeSection
              -> VarSection
              -> ProcedureDeclSection
              -> ExportsSelection
}
procedure TCnBasePascalFormatter.FormatDeclSection(PreSpaceCount: Byte;
  IndentProcs: Boolean; IsInternal: Boolean);
var
  MakeLine, LastIsInternalProc: Boolean;
begin
  MakeLine := False;
  LastIsInternalProc := False;

  while Scaner.Token in DeclSectionTokens do
  begin
    if MakeLine then // Attribute ��������зָ����� MakeLine �ᱻ��Ϊ False
    begin
      if IsInternal then  // �ڲ��Ķ���ֻ��Ҫ��һ��
        EnsureOneEmptyLine
      else
        WriteLine;
    end;

    MakeLine := True;
    case Scaner.Token of
      tokKeywordLabel:
        begin
          FormatLabelDeclSection(PreSpaceCount);
          LastIsInternalProc := False;
        end;
      tokKeywordConst, tokKeywordResourcestring:
        begin
          FormatConstSection(PreSpaceCount);
          LastIsInternalProc := False;
        end;
      tokKeywordType:
        begin
          FormatTypeSection(PreSpaceCount);
          LastIsInternalProc := False;
        end;
      tokKeywordVar, tokKeywordThreadvar:
        begin
          FormatVarSection(PreSpaceCount);
          LastIsInternalProc := False;
        end;
      tokKeywordExports:
        begin
          FormatExportsSection(PreSpaceCount);
          LastIsInternalProc := False;
        end;
      tokKeywordClass, tokKeywordProcedure, tokKeywordFunction,
      tokKeywordConstructor, tokKeywordDestructor:
        begin
          if IndentProcs then
          begin
            if not LastIsInternalProc then // ��һ��Ҳ�� proc��ֻ��һ��
              EnsureOneEmptyLine;
            FormatProcedureDeclSection(Tab(PreSpaceCount));
          end
          else
            FormatProcedureDeclSection(PreSpaceCount);
          if IsInternal then
            Writeln;
          LastIsInternalProc := True;
        end;
      tokSLB:
        begin
          // Attributes for procedure in implementation
          if IsInternal then
          begin
            EnsureOneEmptyLine; // ����һ�� local procedure ��һ��
            FormatSingleAttribute(Tab(PreSpaceCount));
          end
          else
          begin
            FormatSingleAttribute(PreSpaceCount);
            Writeln;
          end;
          MakeLine := False;
        end;
    else
      Error(CN_ERRCODE_PASCAL_NO_DECLSECTION);
    end;
  end;
end;

{
 ExportsDecl -> Ident [FormalParameters] [':' (SimpleType | STRING)] [Directive]
}
procedure TCnBasePascalFormatter.FormatExportsDecl(PreSpaceCount: Byte);
begin
  FormatIdent(PreSpaceCount);

  if Scaner.Token = tokLB then
    FormatFormalParameters;

  if Scaner.Token = tokColon then
  begin
      Match(tokColon);

    if Scaner.Token = tokKeywordString then
      Match(Scaner.Token)
    else
      FormatSimpleType;
  end;

  while Scaner.Token in DirectiveTokens do
    FormatDirective;
end;

{ ExportsList -> ( ExportsDecl ',')... }
procedure TCnBasePascalFormatter.FormatExportsList(PreSpaceCount: Byte);
begin
  FormatExportsDecl(PreSpaceCount);
  while Scaner.Token = tokComma do
  begin
    Match(tokComma);
    Writeln;
    FormatExportsDecl(PreSpaceCount);
  end;
end;

{ ExportsSection -> EXPORTS ExportsList ';' }
procedure TCnBasePascalFormatter.FormatExportsSection(PreSpaceCount: Byte);
begin
  Match(tokKeywordExports);
  Writeln;
  FormatExportsList(Tab(PreSpaceCount));
  Match(tokSemicolon);
end;

{
  FunctionDecl -> FunctionHeading ';' [(DIRECTIVE ';')...]
                  Block ';'
}

procedure TCnBasePascalFormatter.FormatFunctionDecl(PreSpaceCount: Byte;
  IsAnonymous: Boolean);
var
  IsExternal: Boolean;
  IsForward: Boolean;
begin
  FormatFunctionHeading(PreSpaceCount);

  if Scaner.Token = tokSemicolon then // ������ʡ�Էֺŵ����
    Match(tokSemicolon, 0, 0, True); // ���÷ֺź�д�ո����Ӱ�� Directive �Ŀո�

  IsExternal := False;
  IsForward := False;
  while Scaner.Token in DirectiveTokens + ComplexTokens do
  begin
    if Scaner.Token = tokDirectiveExternal then
      IsExternal := True;
    if Scaner.Token = tokDirectiveForward then
      IsForward := True;
    FormatDirective;
    {
     FIX A BUG: semicolon can missing after directive like this:
     
     procedure Foo; external 'foo.dll' name '__foo'
     procedure Bar; external 'bar.dll' name '__bar'
    }
    if Scaner.Token = tokSemicolon then
      Match(tokSemicolon, 0, 0, True);
  end;

  if (not IsExternal) and (not IsForward) then
  begin
    FNextBeginShouldIndent := True; // ���������� begin ���뻻��
    Writeln;
  end;

  if ((not IsExternal)  and (not IsForward))and
     (Scaner.Token in BlockStmtTokens + DeclSectionTokens) then
  begin
    FormatBlock(PreSpaceCount, True);
    if not IsAnonymous and (Scaner.Token = tokSemicolon) then // �������������� end ��ķֺ�
      Match(tokSemicolon);
  end;
end;

{ LabelDeclSection -> LABEL LabelId/ ',' .. ';'}
procedure TCnBasePascalFormatter.FormatLabelDeclSection(
  PreSpaceCount: Byte);
begin
  Match(tokKeywordLabel, PreSpaceCount);
  Writeln;
  FormatLabelID(Tab(PreSpaceCount));

  while Scaner.Token = tokComma do
  begin
    Match(Scaner.Token);
    FormatLabelID;
  end;

  Match(tokSemicolon);
end;

{ LabelID can be symbol or number }
procedure TCnBasePascalFormatter.FormatLabelID(PreSpaceCount: Byte);
begin
  Match(Scaner.Token, PreSpaceCount);
end;

{
  ProcedureDecl -> ProcedureHeading ';' [(DIRECTIVE ';')...]
                   Block ';'
}
procedure TCnBasePascalFormatter.FormatProcedureDecl(PreSpaceCount: Byte;
  IsAnonymous: Boolean);
var
  IsExternal: Boolean;
  IsForward: Boolean;
begin
  FormatProcedureHeading(PreSpaceCount);

  if Scaner.Token = tokSemicolon then // ������ʡ�Էֺŵ����
    Match(tokSemicolon, 0, 0, True); // ���÷ֺź�д�ո����Ӱ�� Directive �Ŀո�

  IsExternal := False;
  IsForward := False;
  while Scaner.Token in DirectiveTokens + ComplexTokens do  // Use ComplexTokens for "local;"
  begin
    if Scaner.Token = tokDirectiveExternal then
      IsExternal := True;
    if Scaner.Token = tokDirectiveForward then
      IsForward := True;

    FormatDirective;
    {
      FIX A BUG: semicolon can missing after directive like this:

       procedure Foo; external 'foo.dll' name '__foo'
       procedure Bar; external 'bar.dll' name '__bar'
    }
    if Scaner.Token = tokSemicolon then
      Match(tokSemicolon, 0, 0, True);
  end;

  if (not IsExternal) and (not IsForward) then
  begin
    FNextBeginShouldIndent := True; // ���������� begin ���뻻��
    Writeln;
  end;

  if ((not IsExternal) and (not IsForward)) and
    (Scaner.Token in BlockStmtTokens + DeclSectionTokens) then // Local procedure also supports Attribute
  begin
    FormatBlock(PreSpaceCount, True);
    if not IsAnonymous and (Scaner.Token = tokSemicolon) then // �������������� end ��ķֺ�
      Match(tokSemicolon);
  end;
end;

{
  ProcedureDeclSection -> ProcedureDecl
                       -> FunctionDecl
}
procedure TCnBasePascalFormatter.FormatProcedureDeclSection(
  PreSpaceCount: Byte);
var
  Bookmark: TScannerBookmark;
begin
  Scaner.SaveBookmark(Bookmark);
  CodeGen.LockOutput;

  if Scaner.Token = tokKeywordClass then
  begin
    Scaner.NextToken;
  end;

  case Scaner.Token of
    tokKeywordProcedure, tokKeywordConstructor, tokKeywordDestructor:
    begin
      Scaner.LoadBookmark(Bookmark);
      CodeGen.UnLockOutput;
      FormatProcedureDecl(PreSpaceCount);
    end;

    tokKeywordFunction, tokKeywordOperator:
    begin
      Scaner.LoadBookmark(Bookmark);
      CodeGen.UnLockOutput;
      FormatFunctionDecl(PreSpaceCount);
    end;
  else
    Error(CN_ERRCODE_PASCAL_NO_PROCFUNC);
  end;
end;

{
  ProgramBlock -> [UsesClause]
                  Block
}
procedure TCnProgramBlockFormatter.FormatProgramBlock(PreSpaceCount: Byte; IsLib: Boolean);
begin
  if Scaner.Token = tokKeywordUses then
  begin
    FormatUsesClause(PreSpaceCount, True); // �� IN �ģ���Ҫ����
    WriteLine;
  end;
  FormatProgramInnerBlock(PreSpaceCount, False, IsLib);
end;

procedure TCnProgramBlockFormatter.FormatPackageBlock(PreSpaceCount: Byte);
begin
  if Scaner.Token = tokKeywordRequires then
  begin
    FormatUsesClause(PreSpaceCount, True); // ���� IN �� requires����Ҫ����
    WriteLine;
  end;

  if Scaner.Token = tokKeywordContains then
  begin
    FormatUsesClause(PreSpaceCount, True); // �� IN �ģ���Ҫ����
    WriteLine;
  end;
end;

{ UsesClause -> USES UsesList ';' }
procedure TCnProgramBlockFormatter.FormatUsesClause(PreSpaceCount: Byte;
  const NeedCRLF: Boolean);
begin
  if Scaner.Token in [tokKeywordUses, tokKeywordRequires, tokKeywordContains] then
    Match(Scaner.Token);

  Writeln;
  SpecifyElementType(pfetUsesList);
  try
    FormatUsesList(Tab(PreSpaceCount), True, NeedCRLF);
  finally
    RestoreElementType;
  end;

  Match(tokSemicolon);
end;

{ UsesList -> (UsesDecl ',') ... }
procedure TCnProgramBlockFormatter.FormatUsesList(PreSpaceCount: Byte;
  const CanHaveUnitQual: Boolean; const NeedCRLF: Boolean);
var
  OldWrapMode: TCodeWrapMode;
  OldAuto: Boolean;
begin
  FormatUsesDecl(PreSpaceCount, CanHaveUnitQual);

  while Scaner.Token = tokComma do
  begin
    Match(tokComma);
    if NeedCRLF then
    begin
      Writeln;
      FormatUsesDecl(PreSpaceCount, CanHaveUnitQual);
    end
    else // �����ֹ�����ʱҲ��������
    begin
      OldWrapMode := CodeGen.CodeWrapMode;
      OldAuto := CodeGen.AutoWrapButNoIndent;
      try
        CodeGen.CodeWrapMode := cwmSimple; // uses Ҫ��򵥻���
        CodeGen.AutoWrapButNoIndent := True; // uses ��Ԫ���к���������
        FormatUsesDecl(0, CanHaveUnitQual);
      finally
        CodeGen.CodeWrapMode := OldWrapMode;
        CodeGen.AutoWrapButNoIndent := OldAuto;
      end;
    end;
  end;
end;

{ UseDecl -> Ident [IN String]}
procedure TCnProgramBlockFormatter.FormatUsesDecl(PreSpaceCount: Byte;
 const CanHaveUnitQual: Boolean);
begin
  if Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
    Match(Scaner.Token, PreSpaceCount); // ��ʶ��������ʹ�ò��ֹؼ���

  while CanHaveUnitQual and (Scaner.Token = tokDot) do
  begin
    Match(tokDot);
    if Scaner.Token in ([tokSymbol] + KeywordTokens + ComplexTokens + DirectiveTokens) then
      Match(Scaner.Token);
  end;

  if Scaner.Token = tokKeywordIn then // ���� in
  begin
    Match(tokKeywordIn, 1, 1);
    if Scaner.Token in [tokString, tokWString] then
      Match(Scaner.Token)
    else
      ErrorToken(tokString);
  end;
end;

{ VarDecl -> IdentList ':' Type [(ABSOLUTE (Ident | ConstExpr)) | '=' TypedConstant] }
procedure TCnBasePascalFormatter.FormatVarDecl(PreSpaceCount: Byte);
begin
  FormatIdentList(PreSpaceCount);
  if Scaner.Token = tokColon then // �ſ��﷨����
  begin
    Match(tokColon);
    FormatType(PreSpaceCount); // �� Type ���ܻ��У����봫��
  end;

  if Scaner.Token = tokEQUAL then
  begin
    Match(Scaner.Token, 1, 1);
    FormatTypedConstant;
  end
  else if Scaner.TokenSymbolIs('ABSOLUTE') then
  begin
    Match(Scaner.Token);
    FormatConstExpr; // include indent
  end;

  while Scaner.Token in DirectiveTokens do
    FormatDirective;
end;

{ VarSection -> VAR | THREADVAR (VarDecl ';')... }
procedure TCnBasePascalFormatter.FormatVarSection(PreSpaceCount: Byte);
const
  IsVarStartTokens = [tokSymbol, tokSLB] + ComplexTokens + DirectiveTokens
    + KeywordTokens - NOTExpressionTokens;
begin
  if Scaner.Token in [tokKeywordVar, tokKeywordThreadvar] then
    Match(Scaner.Token, PreSpaceCount);

  while Scaner.Token in IsVarStartTokens do // ��Щ�ؼ��ֲ�������������Ҳ���ô���ֻ����д��
  begin
    // �����[����ҪԽ�������ԣ��ҵ�]��ĵ�һ����ȷ�����Ƿ��� var��������ǣ�������
    if (Scaner.Token = tokSLB) and not IsTokenAfterAttributesInSet(IsVarStartTokens) then
      Exit;

    Writeln;
    FormatVarDecl(Tab(PreSpaceCount));
    Match(tokSemicolon);
  end;
end;

procedure TCnBasePascalFormatter.FormatTypeID(PreSpaceCount: Byte);
var
  Old: Boolean;
begin
  if Scaner.Token in BuiltInTypeTokens then
    Match(Scaner.Token)
  else if Scaner.Token = tokKeywordFile then
    Match(tokKeywordFile)
  else
  begin
    // �����������ȵĴ�Сд����
    Old := FIsTypeID;
    try
      FIsTypeID := True;
      FormatIdent(0, True);
    finally
      FIsTypeID := Old;
    end;
    
    // ���� _UTF8String = type _AnsiString(65001); ����
    if Scaner.Token = tokLB then
    begin
      Match(tokLB);
      FormatExpression;
      Match(tokRB);
    end;
  end;
end;

{ TCnGoalCodeFormater }

procedure TCnGoalCodeFormatter.FormatCode(PreSpaceCount: Byte);
begin
  ResetElementType;
  FPrefixSpaces := 0;
  CheckHeadComments;
  FormatGoal(PreSpaceCount);
end;

{
  ExportedHeading -> ProcedureHeading ';' [(DIRECTIVE ';')...]
                  -> FunctionHeading ';' [(DIRECTIVE ';')...]
}
procedure TCnGoalCodeFormatter.FormatExportedHeading(PreSpaceCount: Byte);
begin
  case Scaner.Token of
    tokKeywordProcedure: FormatProcedureHeading(PreSpaceCount);
    tokKeywordFunction: FormatFunctionHeading(PreSpaceCount);
  else
    Error(CN_ERRCODE_PASCAL_NO_PROCFUNC);
  end;

  if Scaner.Token = tokSemicolon then
    Match(tokSemicolon, 0, 0, True); // ���÷ֺź�д�ո����Ӱ�� Directive �Ŀո�

  while Scaner.Token in DirectiveTokens do
  begin
    FormatDirective;
    {
     FIX A BUG: semicolon can missing after directive like this:

     procedure Foo; external 'foo.dll' name '__foo'
     procedure Bar; external 'bar.dll' name '__bar'
    }
    if Scaner.Token = tokSemicolon then
      Match(tokSemicolon, 0, 0, True);
  end;
end;

{ Goal -> (Program | Package  | Library  | Unit) }
procedure TCnGoalCodeFormatter.FormatGoal(PreSpaceCount: Byte);
begin
  case Scaner.Token of
    tokKeywordProgram:
      begin
        FGoalType := gtProgram;
        FormatProgram(PreSpaceCount);
      end;
    tokKeywordLibrary:
      begin
        FGoalType := gtLibrary;
        FormatLibrary(PreSpaceCount);
      end;
    tokKeywordUnit:
      begin
        FGoalType := gtUnit;
        FormatUnit(PreSpaceCount);
      end;
    tokKeywordPackage:
      begin
        FGoalType := gtPackage;
        FormatPackage(PreSpaceCount);
      end;
  else
    FGoalType := gtUnknown;
    Error(CN_ERRCODE_PASCAL_UNKNOWN_GOAL);
  end;
end;

{
  ImplementationSection -> IMPLEMENTATION
                           [UsesClause]
                           [DeclSection]...
}
procedure TCnGoalCodeFormatter.FormatImplementationSection(
  PreSpaceCount: Byte);
begin
  Match(tokKeywordImplementation);

  while Scaner.Token = tokKeywordUses do
  begin
    WriteLine;
    FormatUsesClause(PreSpaceCount, CnPascalCodeForRule.UsesUnitSingleLine);
  end;

  if Scaner.Token in DeclSectionTokens then
  begin
    WriteLine;
    FormatDeclSection(PreSpaceCount, False);
  end;
end;

{
  InitSection -> INITIALIZATION StmtList [FINALIZATION StmtList]
              -> BEGIN StmtList END
}
procedure TCnGoalCodeFormatter.FormatInitSection(PreSpaceCount: Byte);
begin
  Match(tokKeywordInitialization);
  Writeln;
  if Scaner.Token = tokKeywordFinalization then // Empty initialization
  begin
    Writeln;
    Match(Scaner.Token);
    Writeln;
    FormatStmtList(Tab);
    Exit;
  end
  else
    FormatStmtList(Tab);

  if Scaner.Token = tokKeywordFinalization then
  begin
    WriteBlankLineByPrevCondition;
    Match(Scaner.Token);
    Writeln;
    FormatStmtList(Tab);
  end;
end;

{
  InterfaceDecl -> ConstSection
                -> TypeSection
                -> VarSection
                -> ExportedHeading
                -> ExportsSection
}
procedure TCnGoalCodeFormatter.FormatInterfaceDecl(PreSpaceCount: Byte);
var
  MakeLine: Boolean;
begin
  MakeLine := False;
  
  while Scaner.Token in InterfaceDeclTokens do
  begin
    if MakeLine then WriteLine;

    case Scaner.Token of
      tokKeywordUses: FormatUsesClause(PreSpaceCount, CnPascalCodeForRule.UsesUnitSingleLine); // ���� uses �Ĵ���������ݴ���
      tokKeywordConst, tokKeywordResourcestring: FormatConstSection(PreSpaceCount);
      tokKeywordType: FormatTypeSection(PreSpaceCount);
      tokKeywordVar, tokKeywordThreadvar: FormatVarSection(PreSpaceCount);
      tokKeywordProcedure, tokKeywordFunction: FormatExportedHeading(PreSpaceCount);
      tokKeywordExports: FormatExportsSection(PreSpaceCount);
      tokSLB: FormatSingleAttribute(PreSpaceCount);
    else
      if not CnPascalCodeForRule.ContinueAfterError then
        Error(CN_ERRCODE_PASCAL_ERROR_INTERFACE)
      else
      begin
        Match(Scaner.Token);
        Continue;
      end;
    end;

    MakeLine := True;
  end;
end;

{
  InterfaceSection -> INTERFACE
                      [UsesClause]
                      [InterfaceDecl]...
}
procedure TCnGoalCodeFormatter.FormatInterfaceSection(PreSpaceCount: Byte);
begin
  Match(tokKeywordInterface, PreSpaceCount);

  while Scaner.Token = tokKeywordUses do
  begin
    WriteLine;
    FormatUsesClause(PreSpaceCount, CnPascalCodeForRule.UsesUnitSingleLine);
  end;

  if Scaner.Token in InterfaceDeclTokens then
  begin
    WriteLine;
    FormatInterfaceDecl(PreSpaceCount);
  end;
end;

{
  Library -> LIBRARY Ident ';'
             ProgramBlock '.'
}
procedure TCnGoalCodeFormatter.FormatLibrary(PreSpaceCount: Byte);
begin
  Match(tokKeywordLibrary);
  FormatIdent(PreSpaceCount);
  while Scaner.Token in DirectiveTokens do
    Match(Scaner.Token);

  Match(tokSemicolon);
  WriteLine;

  FormatProgramBlock(PreSpaceCount, True);
  Match(tokDot);
end;

{
  Program -> [PROGRAM Ident ['(' IdentList ')'] ';']
             ProgramBlock '.'
}
procedure TCnGoalCodeFormatter.FormatPackage(PreSpaceCount: Byte);
begin
  Match(tokKeywordPackage, PreSpaceCount);
  FormatIdent;

  if Scaner.Token = tokSemicolon then
    Match(Scaner.Token, PreSpaceCount);

  WriteLine;
  FormatPackageBlock(PreSpaceCount);
  Match(tokKeywordEnd);
  Match(tokDot);
end;

procedure TCnGoalCodeFormatter.FormatProgram(PreSpaceCount: Byte);
begin
  Match(tokKeywordProgram, PreSpaceCount);
  FormatIdent;

  if Scaner.Token = tokLB then
  begin
    Match(Scaner.Token);
    FormatIdentList;
    Match(tokRB);
  end;

  if Scaner.Token = tokSemicolon then // �ѵ����Բ�Ҫ�ֺţ�
    Match(Scaner.Token, PreSpaceCount);

  WriteLine;
  FormatProgramBlock(PreSpaceCount);
  Match(tokDot);
end;

{
  Unit -> UNIT Ident [ DIRECTIVE ...] ';'
          InterfaceSection
          ImplementationSection
          [ InitSection ]
          END '.'
}
procedure TCnGoalCodeFormatter.FormatUnit(PreSpaceCount: Byte);
begin
  Match(tokKeywordUnit, PreSpaceCount);
  FormatIdent;

  while Scaner.Token in DirectiveTokens do
  begin
    Match(Scaner.Token);
  end;

  Match(tokSemicolon, PreSpaceCount);
  WriteLine;

  FormatInterfaceSection(PreSpaceCount);
  WriteLine;

  FormatImplementationSection(PreSpaceCount);
  WriteLine;

  if Scaner.Token = tokKeywordInitialization then
  begin
    FormatInitSection(PreSpaceCount);
    WriteBlankLineByPrevCondition;
  end;

  Match(tokKeywordEnd, PreSpaceCount);
  Match(tokDot);
end;

{ ClassBody -> [ClassHeritage] [ClassMemberList END] }
procedure TCnBasePascalFormatter.FormatClassBody(PreSpaceCount: Byte);
begin
  if Scaner.Token = tokLB then
  begin
    FormatClassHeritage;
  end;

  if Scaner.Token <> tokSemiColon then
  begin
    Writeln;
    FormatClassMemberList(PreSpaceCount);
    Match(tokKeywordEnd, PreSpaceCount);
  end;
end;

procedure TCnBasePascalFormatter.FormatClassField(PreSpaceCount: Byte);
begin
  SpecifyElementType(pfetClassField);
  try
    FormatClassVarIdentList(PreSpaceCount);
    Match(tokColon);
    FormatType(PreSpaceCount);

    while Scaner.Token = tokSemicolon do
    begin
      Match(Scaner.Token);

      if Scaner.Token <> tokSymbol then Exit;

      Writeln;

      FormatClassVarIdentList(PreSpaceCount);
      Match(tokColon);
      FormatType(PreSpaceCount);
    end;
  finally
    RestoreElementType;
  end;
end;

{ ClassMember -> ClassField | ClassMethod | ClassProperty }
procedure TCnBasePascalFormatter.FormatClassMember(PreSpaceCount: Byte);
begin
  // no need loop here, we have one loop outter
  if Scaner.Token in ClassMemberSymbolTokens then // ���ֹؼ��ִ˴����Ե��� Symbol
  begin
    case Scaner.Token of
      tokKeywordProcedure, tokKeywordFunction, tokKeywordConstructor,
      tokKeywordDestructor, tokKeywordOperator, tokKeywordClass:
        FormatClassMethod(PreSpaceCount);

      tokKeywordProperty:
        FormatClassProperty(PreSpaceCount);
      tokKeywordType:
        FormatClassTypeSection(PreSpaceCount);
      tokKeywordConst:
        FormatClassConstSection(PreSpaceCount);
        
      // ������ֵ�var/threadvar��ͬ�� class var/threadvar �Ĵ�����д�� FormatClassMethod ��
      tokKeywordVar, tokKeywordThreadvar:
        FormatClassMethod(PreSpaceCount);
      tokSLB:
        FormatSingleAttribute(PreSpaceCount); // ���ԣ����� [Weak] ǰ׺
    else // �����Ķ��� symbol
      FormatClassField(PreSpaceCount);
    end;

    Writeln;
  end;
end;

{ ClassMemberList -> ([ClassVisibility] [ClassMember]) ... }
procedure TCnBasePascalFormatter.FormatClassMemberList(
  PreSpaceCount: Byte);
begin
  while Scaner.Token in ClassVisibilityTokens + ClassMemberSymbolTokens do
  begin
    if Scaner.Token in ClassVisibilityTokens then
    begin
      FormatClassVisibility(PreSpaceCount);
      // Ӧ�ã������һ�����ǣ��Ϳ�һ��
      // if Scaner.Token in ClassVisibilityTokens + [tokKeywordEnd] then
      //  Writeln;
    end;

    if Scaner.Token in ClassMemberSymbolTokens then
      FormatClassMember(Tab(PreSpaceCount));
  end;
end;

{ ClassMethod -> [CLASS] MethodHeading ';' [(DIRECTIVE ';')...] }
procedure TCnBasePascalFormatter.FormatClassMethod(PreSpaceCount: Byte);
var
  IsFirst: Boolean;
begin
  if Scaner.Token = tokKeywordClass then
  begin
    Match(tokKeywordClass, PreSpaceCount);
    if Scaner.Token in [tokKeywordProcedure, tokKeywordFunction,
      tokKeywordConstructor, tokKeywordDestructor, tokKeywordProperty,
      tokKeywordOperator] then // Single line heading
      FormatMethodHeading
    else
      FormatMethodHeading(PreSpaceCount, True);
  end else if Scaner.Token in [tokKeywordVar, tokKeywordThreadVar] then
  begin
    FormatMethodHeading(PreSpaceCount, False);
  end
  else
    FormatMethodHeading(PreSpaceCount);

  if Scaner.Token = tokSemicolon then // class property already processed ;
    Match(tokSemicolon);

  IsFirst := True;
  while Scaner.Token in DirectiveTokens do
  begin
    FormatDirective(PreSpaceCount, IsFirst);
    IsFirst := False;
    if Scaner.Token = tokSemicolon then
      Match(tokSemicolon, 0, 0, True);
  end;

//  begin
//    if Scaner.Token = tokDirectiveMESSAGE then
//    begin
//      Match(Scaner.Token); // message MESSAGE_ID;
//      FormatConstExpr;
//    end
//    else
//      Match(Scaner.Token);
//    Match(tokSemicolon);
//  end;
end;

{ ClassProperty -> PROPERTY Ident [PropertyInterface]  PropertySpecifiers ';' [DEFAULT ';']}
procedure TCnBasePascalFormatter.FormatClassProperty(PreSpaceCount: Byte);
begin
  Match(tokKeywordProperty, PreSpaceCount);
  FormatIdent;

  if Scaner.Token in [tokSLB, tokColon] then
    FormatPropertyInterface;

  FormatPropertySpecifiers;
  Match(tokSemiColon);

  if Scaner.TokenSymbolIs('DEFAULT') then
  begin
    Match(Scaner.Token);
    Match(tokSemiColon);
  end;
end;

// class/record �ڵ� type �������Խ����жϲ�һ����
procedure TCnBasePascalFormatter.FormatClassTypeSection(
  PreSpaceCount: Byte);
var
  FirstType: Boolean;
begin
  Match(tokKeywordType, PreSpaceCount);
  Writeln;

  FirstType := True;
  while Scaner.Token in [tokSymbol, tokSLB] + ComplexTokens + DirectiveTokens
   + KeywordTokens - NOTExpressionTokens - NOTClassTypeConstTokens do
  begin
    if not FirstType then WriteLine;
    FormatTypeDecl(Tab(PreSpaceCount));
    while Scaner.Token in DirectiveTokens do
      FormatDirective;
    Match(tokSemicolon);
    FirstType := False;
  end;
end;

{ procedure/function/constructor/destructor Name, can be classname.name}
procedure TCnBasePascalFormatter.FormatMethodName(PreSpaceCount: Byte);
begin
  FormatTypeParamIdent;
  // ����Է��͵�֧��
  if Scaner.Token = tokDot then
  begin
    Match(tokDot);
    FormatTypeParamIdent;
  end;
end;

procedure TCnBasePascalFormatter.FormatClassConstSection(
  PreSpaceCount: Byte);
begin
  Match(tokKeywordConst, PreSpaceCount);

  while Scaner.Token in [tokSymbol] + ComplexTokens + DirectiveTokens + KeywordTokens
   - NOTExpressionTokens - NOTClassTypeConstTokens do // ��Щ�ؼ��ֲ�������������Ҳ���ô���ֻ����д��
  begin
    Writeln;
    FormatClassConstantDecl(Tab(PreSpaceCount));
    Match(tokSemicolon);
  end;
end;

procedure TCnBasePascalFormatter.FormatClassConstantDecl(PreSpaceCount: Byte);
begin
  FormatIdent(PreSpaceCount);

  case Scaner.Token of
    tokEQUAL:
      begin
        Match(Scaner.Token, 1); // �Ⱥ�ǰ��һ��
        FormatConstExpr(1); // �Ⱥź�ֻ��һ��
      end;

    tokColon: // �޷�ֱ������ record/array/��ͨ������ʽ�ĳ�ʼ������Ҫ�ڲ�����
      begin
        Match(Scaner.Token);

        FormatType;
        Match(tokEQUAL, 1, 1); // �Ⱥ�ǰ���һ��

        FormatTypedConstant; // �Ⱥź��һ��
      end;
  else
    Error(CN_ERRCODE_PASCAL_NO_EQUALCOLON); 
  end;

  while Scaner.Token in DirectiveTokens do
    FormatDirective;
end;

procedure TCnBasePascalFormatter.FormatSingleAttribute(
  PreSpaceCount: Byte);
var
  IsFirst, JustLn: Boolean;
begin
  Match(tokSLB, PreSpaceCount);
  IsFirst := True;
  repeat
    JustLn := False;
    if IsFirst then
      FormatIdent
    else
      FormatIdent(PreSpaceCount);
      
    if Scaner.Token = tokLB then
    begin
      Match(tokLB);
      FormatExprList;
      Match(tokRB);
    end
    else if Scaner.Token = tokColon then
    begin
      Match(tokColon);
      FormatIdent;
    end;

    if Scaner.Token = tokComma then // Multi-Attribute, use new line.
    begin
      Match(tokComma);
      IsFirst := False;
      Writeln;
      JustLn := True;
    end;

    // If not Attribute, maybe infinite loop here, jump and fix.
    if not (Scaner.Token in [tokSRB, tokUnknown, tokEOF]) then
    begin
      if JustLn then
        Match(Scaner.Token, PreSpaceCount)
      else
        Match(Scaner.Token);
    end;

  until Scaner.Token in [tokSRB, tokUnknown, tokEOF];
  Match(tokSRB);
end;

function TCnBasePascalFormatter.IsTokenAfterAttributesInSet(
  InTokens: TPascalTokenSet): Boolean;
var
  Bookmark: TScannerBookmark;
begin
  Scaner.SaveBookmark(Bookmark);
  CodeGen.LockOutput;

  try
    Result := False;
    if Scaner.Token <> tokSLB then
      Exit;

    // Ҫ����������ܽ��ڵ����ԣ�����ֹһ��
    while Scaner.Token = tokSLB do
    begin
      while not (Scaner.Token in [tokEOF, tokUnknown, tokSRB]) do
        Scaner.NextToken;

      if Scaner.Token <> tokSRB then
        Exit;

      Scaner.NextToken;
    end;
    Result := (Scaner.Token in InTokens);
  finally
    Scaner.LoadBookmark(Bookmark);
    CodeGen.UnLockOutput;
  end;
end;

function TCnAbstractCodeFormatter.ErrorTokenString: string;
begin
  Result := TokenToString(Scaner.Token);
  if Result = '' then
    Result := Scaner.TokenString;
end;

procedure TCnAbstractCodeFormatter.WriteBlankLineByPrevCondition;
begin
  if Scaner.PrevBlankLines then
    Writeln
  else
    WriteLine;
end;

procedure TCnAbstractCodeFormatter.WriteLineFeedByPrevCondition;
begin
  if not Scaner.PrevBlankLines then
    Writeln;
end;

procedure TCnBasePascalFormatter.CheckWriteBeginln;
begin
  if (Scaner.Token <> tokKeywordBegin) or
    (CnPascalCodeForRule.BeginStyle <> bsSameLine) then
    Writeln;
end;

{ TCnPascalCodeFormatter }

function TCnPascalCodeFormatter.CopyMatchedSliceResult: string;
begin
  Result := '';
  if FSliceMode and HasSliceResult then
  begin
    // ��ƥ����
    Result := CodeGen.CopyPartOut(MatchedOutStartRow, MatchedOutStartCol,
      MatchedOutEndRow, MatchedOutEndCol);
  end;
end;

procedure TCnPascalCodeFormatter.FormatCode(PreSpaceCount: Byte);
begin
  if FSliceMode then
    try
      inherited FormatCode(PreSpaceCount);
    except
      on E: EReadError do
      begin
        ; // Catch Eof Exception and give the result
      end;
    end
  else
    inherited FormatCode(PreSpaceCount);
end;

procedure TCnAbstractCodeFormatter.CodeGenAfterWrite(Sender: TObject;
  IsWriteBlank: Boolean; IsWriteln: Boolean; PrefixSpaces: Integer);
var
  StartPos, EndPos, I: Integer;
begin
  // CodeGen д��һ���ַ����� Scaner ��û NextToken ʱ����
  // �����ж� Scaner ��λ���Ƿ���ָ�� Offset
{$IFDEF DEBUG}
//  CnDebugger.LogFmt('OnAfter Write. From %d %d to %d %d. Scaner Offset is %d.',
//    [TCnCodeGenerator(Sender).PrevRow, TCnCodeGenerator(Sender).PrevColumn,
//    TCnCodeGenerator(Sender).CurrRow, TCnCodeGenerator(Sender).CurrColumn,
//    FScaner.SourcePos]);
{$ENDIF}

  // ��¼Ŀ����Դ����ӳ��
  if not IsWriteBlank and not IsWriteln and (FInputLineMarks <> nil) then
  begin
    for I := 0 to FInputLineMarks.Count - 1 do
    begin
      if Scaner.SourceLine = Integer(FInputLineMarks[I]) then
        if Integer(FOutputLineMarks[I]) = 0 then // ��һ��ƥ��
          FOutputLineMarks[I] := Pointer(TCnCodeGenerator(Sender).ActualRow);
    end;
  end;

  if IsWriteBlank then
  begin
    StartPos := FScaner.BlankStringPos;
    EndPos := FScaner.BlankStringPos + FScaner.BlankStringLength;
  end
  else
  begin
    StartPos := FScaner.SourcePos;
    EndPos := FScaner.SourcePos + FScaner.TokenStringLength;
  end;

  // д�������ڴ��뱾��Ŀ���ʱ������ǵĻ�������
  if (StartPos >= FMatchedInStart) and not IsWriteln and not FFirstMatchStart then
  begin
    FMatchedOutStartRow := TCnCodeGenerator(Sender).PrevRow;
    FMatchedOutStartCol := TCnCodeGenerator(Sender).PrevColumn - FPrefixSpaces;
    // ����ע��ʱ���ò����ϻ�����հ�ʱ�������Ŀհ�
    if FMatchedOutStartCol < 0 then
      FMatchedOutStartCol := 0;
    FFirstMatchStart := True;
{$IFDEF DEBUG}
//    CnDebugger.LogMsg('OnAfter Write. Got MatchStart.');
{$ENDIF}
  end
  else if (EndPos >= FMatchedInEnd) and IsWriteln and not FFirstMatchEnd then
  begin
    // Ҫд��������Ŀ���ʱ���㣬�Ա�֤������β���лس�
    FMatchedOutEndRow := TCnCodeGenerator(Sender).CurrRow;
    FMatchedOutEndCol := TCnCodeGenerator(Sender).CurrColumn;
    FFirstMatchEnd := True;
{$IFDEF DEBUG}
//    CnDebugger.LogMsg('OnAfter Write. Got MatchEnd.');
{$ENDIF}
  end;
  FPrefixSpaces := PrefixSpaces;
end;

function TCnPascalCodeFormatter.HasSliceResult: Boolean;
begin
  Result := (MatchedOutStartRow <> CN_MATCHED_INVALID)
    and (MatchedOutStartCol <> CN_MATCHED_INVALID)
    and (MatchedOutEndRow <> CN_MATCHED_INVALID)
    and (MatchedOutEndCol <> CN_MATCHED_INVALID);
end;

procedure TCnAbstractCodeFormatter.RestoreElementType;
begin
  if FOldElementTypes <> nil then
    FElementType := TCnPascalFormattingElementType(FOldElementTypes.Pop)
  else
    FElementType := pfetUnknown;
end;

procedure TCnAbstractCodeFormatter.SpecifyElementType(
  Element: TCnPascalFormattingElementType);
begin
  if FOldElementTypes <> nil then
    FOldElementTypes.Push(Pointer(FElementType));
  FElementType := Element;
end;

procedure TCnAbstractCodeFormatter.ResetElementType;
begin
  FOldElementTypes.Free;
  FOldElementTypes := TCnElementStack.Create;

  FElementType := pfetUnknown;
end;

procedure TCnAbstractCodeFormatter.SpecifyIdentifiers(Names: PLPSTR);
var
  P: LPSTR;
  S: string;
begin
  if FNamesMap <> nil then
    FreeAndNil(FNamesMap);
  FNamesMap := TCnStrToStrHashMap.Create;

  if Names = nil then
    Exit;

  while Names^ <> nil do
  begin
    P := Names^;
    S := string(StrPas(P));
    FNamesMap.Add(UpperCase(S), S);
    Inc(Names);
  end;
end;

procedure TCnAbstractCodeFormatter.SpecifyIdentifiers(Names: TStrings);
var
  I: Integer;
begin
  if FNamesMap <> nil then
    FreeAndNil(FNamesMap);
  FNamesMap := TCnStrToStrHashMap.Create;

  if Names = nil then
    Exit;

  for I := 0 to Names.Count - 1 do
    FNamesMap.Add(UpperCase(Names[I]), Names[I]);
end;

procedure TCnAbstractCodeFormatter.SpecifyLineMarks(Marks: PDWORD);
begin
  if FInputLineMarks <> nil then
    FreeAndNil(FInputLineMarks);
  if FOutputLineMarks <> nil then
    FreeAndNil(FOutputLineMarks);

  if Marks = nil then
    Exit;
  if Marks^ = 0 then
    Exit;

  FInputLineMarks := TList.Create;
  FOutputLineMarks := TList.Create;

  while Marks^ <> 0 do
  begin
    FInputLineMarks.Add(Pointer(Marks^));
    FOutputLineMarks.Add(nil);
    Inc(Marks);
  end;
end;

procedure TCnAbstractCodeFormatter.SaveOutputLineMarks(var Marks: PDWORD);
var
  I: Integer;
  M: PDWORD;
begin
  if (FOutputLineMarks = nil) or (FOutputLineMarks.Count = 0) or (Marks <> nil) then
    Exit;

  Marks := GetMemory((FOutputLineMarks.Count + 1) * SizeOf(DWORD));
  M := Marks;
  for I := 0 to FOutputLineMarks.Count - 1 do
  begin
    M^ := DWORD(FOutputLineMarks[I]);
    Inc(M);
  end;
  M^ := 0;
end;

function TCnAbstractCodeFormatter.CalcNeedPadding: Boolean;
begin
  Result := (FElementType in [pfetExpression, pfetEnumList,pfetArrayConstant,
    pfetSetConstructor, pfetFormalParameters, pfetUsesList, pfetFieldDecl, pfetClassField,
    pfetThen, pfetDo, pfetExprListRightBracket, pfetFormalParametersRightBracket])
    or ((FElementType in [pfetConstExpr]) and not UpperContainElementType([pfetCaseLabel])) // Case Label �������������һ��ע������
    or UpperContainElementType([pfetFormalParameters, pfetArrayConstant]);
  // ���ұ��ʽ�ڲ���ö�ٶ����ڲ���һϵ��Ԫ���ڲ��������ڲ����б�uses ��
  // ����ע�͵��µĻ���ʱ����Ҫ���Զ�����һ�ж���
  // ��Ҫ���ڱ��������е������������ if then ��while do �for do ��
  // �ϸ����� then/do ���ֻ���ͬ������Ҫ��һ��������������ʱ������һ����������
end;

function TCnAbstractCodeFormatter.CalcNeedPaddingAndUnIndent: Boolean;
begin
  Result := FElementType in [pfetExprListRightBracket, pfetFormalParametersRightBracket,
    pfetFieldDecl, pfetClassField];
  // �� CalcNeedPadding Ϊ True ��ǰ���£�����Ҫ������
end;

function TCnAbstractCodeFormatter.UpperContainElementType(ElementTypes:
  TCnPascalFormattingElementTypeSet): Boolean;
begin
  if FOldElementTypes = nil then
    Result := False
  else
    Result := FOldElementTypes.Contains(ElementTypes);
end;

{ TCnElementStack }

function TCnElementStack.Contains(
  ElementTypes: TCnPascalFormattingElementTypeSet): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 0 to Count - 1 do
    if TCnPascalFormattingElementType(List[I]) in ElementTypes then
      Exit;
  Result := False;
end;

procedure TCnAbstractCodeFormatter.WriteOneSpace;
begin
  CodeGen.WriteOneSpace;
end;

procedure TCnAbstractCodeFormatter.EnsureOneEmptyLine;
begin
  FEnsureOneEmptyLine := True;
  Writeln;
  FEnsureOneEmptyLine := False;
end;

function TCnAbstractCodeFormatter.CurrentContainElementType(
  ElementTypes: TCnPascalFormattingElementTypeSet): Boolean;
begin
  Result := (FElementType in ElementTypes) or UpperContainElementType(ElementTypes);
end;

initialization
  MakeKeywordsValidAreas;

end.
