unit paxjs;

{$mode objfpc}{$H+}
{$D+}

interface

uses
  Classes, SysUtils, typinfo, fpjson, fgl;

const
  AsCompactJSON = [foSingleLineArray, foSingleLineObject, foskipWhiteSpace];

type
  TJSONLoggingCategory = (
    jetDebug = 1000,
    jetInfo = 2000,
    jetWarning = 3000,
    jetError = 4000,
    jetException = 5000
    );

  TJSONLoggingEvent = record
    Category:  TJSONLoggingCategory;
    Protocol:  RawByteString;
    Message:   RawByteString;
    ErrorCode: integer;
    Error:     RawByteString;
    Timestamp: TDateTime;

  end;

  IJSONLogListener = interface
    ['{F734133B-649C-4BF7-A043-49F184007842}']
    procedure LogEvent(Event: TJSONLoggingEvent);
  end;

var
  Log: IJSONLogListener;

//Date Format: http://es5.github.io/#x15.9.1.15

type
  TDynIntegerArray = array of integer;
  { TJSON }
  TJSON3 = class
    function parse(Source: TJSONStringType; clz: TClass): TObject; overload;
    function stringify(const obj: TObject; FormatOptions: TFormatOptions = AsCompressedJSON): TJSONStringType;
  end;

  { TJsonTypeHandler }

  TJsonTypeHandler = class
  public
    function parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; virtual; abstract;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; virtual; abstract;
  end;

  { TJSONObjectTypeHandler }

  TJSONObjectTypeHandler = class(TJsonTypeHandler)
  protected
    procedure parseProperties(AObject: TObject; Node: TJSONData); virtual;
    function stringifyPropertyAllowed(AObject: TObject; info: PPropInfo): boolean; virtual;
    function stringifyPropertyList(AObject: TObject; var Res: TJSONData): boolean; virtual;
  public
    function parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONIntegerTypeHandle }

  TJSONIntegerTypeHandle = class(TJsonTypeHandler)
    function parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONInt64TypeHandle }

  TJSONInt64TypeHandle = class(TJsonTypeHandler)
    function parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONBooleanTypeHandle }

  TJSONBooleanTypeHandle = class(TJsonTypeHandler)
    function parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONFloatTypeHandler }

  TJSONFloatTypeHandler = class(TJsonTypeHandler)
    function parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONCustomFloatNumber }

  TJSONCustomFloatNumber = class(TJSONFloatNumber)
  protected
    function GetAsString: TJSONStringType; override;
  end;

  { TJSONStringTypeHandle }

  TJSONStringTypeHandle = class(TJsonTypeHandler)
    function parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONWideStringTypeHandle }

  TJSONWideStringTypeHandle = class(TJsonTypeHandler)
    function parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONDynStringTypeHandle }

  TJSONDynStringTypeHandle = class(TJsonTypeHandler)
    function parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONStringListTypeHandle }

  TJSONStringListTypeHandle = class(TJsonTypeHandler)
    function parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONDynArrayIntegerTypeHandle }

  TJSONDynArrayIntegerTypeHandle = class(TJsonTypeHandler)
    function parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONEnumerationTypeHandle }

  TJSONEnumerationTypeHandle = class(TJsonTypeHandler)
    function parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONCollectionTypeHandle }

  TJSONCollectionTypeHandle = class(TJsonTypeHandler)
  protected
    procedure parseCollection(ACollection: TCollection; arrayNode: TJSONArray);
    function stringifyCollection(ACollection: TCollection; out Res: TJSONData): boolean;
    function stringifyPropertyList(AObject: TObject; var Res: TJSONData): boolean;
  public
    function parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

var
  JSON: TJSON3;

type
  EFactoryFailure = class(Exception)
  end;

  TFactory     = function(clz: TClass): TObject;
  THandlerList = specialize TFPGObjectList<TJsonTypeHandler>;

procedure RegisterJsonTypeHandler(aTypeKind: TTypeKind; aHandler: TJsonTypeHandler);
procedure RegisterJSONClass(aClass: TClass; aFactory: TFactory = nil);
procedure UnRegisterJSONClass(aClass: TClass);
function GetJSONClass(const AClassName: string): TClass;
function GetJSONFactory(const AClassName: string): TFactory; overload;
function GetJSONFactory(const AClass: TClass): TFactory; overload;
function camelCase(const aString: string): string;
function pascalCase(const aString: string): string;
function selectorCase(const aString: string): string;
procedure getHandlers(typeKind: TTypeKind; out handlers: THandlerList);
procedure getHandlers(typeKind: TTypeKinds; out handlers: THandlerList);

function DateToISO8601(DateTime: TDateTime): string;
function ISO8601ToDate(DateTime: string): TDateTime;

function isNull(node: TJSONData): boolean;
function nvl(node: TJSONData; defaultValue: boolean): boolean;
function nvl(node: TJSONData; defaultValue: string): string;
function nvl(node: TJSONData; defaultValue: int64): int64;
function nvl(node: TJSONData; defaultValue: extended): extended;

procedure doLog(eventType: TJSONLoggingCategory; message: string);
procedure LogInfo(message: string);
procedure LogDebug(message: string);
procedure LogError(message: string);
procedure LogException(context: string; e: Exception);

implementation

uses
  jsonparser, RegExpr, Math;

var
  fs: TFormatSettings;

procedure LogInfo(message: string);
begin
  doLog(jetInfo, message);
end;

procedure LogDebug(message: string);
begin
  doLog(jetDebug, message);
end;

procedure LogError(message: string);
begin
  doLog(jetError, message);
end;

procedure LogException(context: string; e: Exception);
var
  I: integer;
  Frames: PPointer;
  Report: string;
begin
  Report := 'Program exception! ' + LineEnding + 'Stacktrace:' + LineEnding + LineEnding;
  if E <> nil then
  begin
    Report := Report + 'Exception class: ' + E.ClassName + LineEnding + 'Message: ' + E.Message + LineEnding;
  end;
  Report := Report + BackTraceStrFunc(ExceptAddr);
  Frames := ExceptFrames;
  for I := 0 to ExceptFrameCount - 1 do
    Report := Report + LineEnding + BackTraceStrFunc(Frames[I]);
  LogError(context + LineEnding + Report);
end;


procedure doLog(eventType: TJSONLoggingCategory; message: string);
var
  event: TJSONLoggingEvent;
begin
  if log <> nil then
  begin
    event.Category  := eventType;
    event.Message   := message;
    event.Error     := '';
    event.Error     := '';
    event.ErrorCode := 0;
    event.Timestamp := now;
    log.LogEvent(event);
  end;
end;

function isNull(node: TJSONData): boolean;
begin
  Result := False;
  if (node = nil) or (node.IsNull) then
    Result := True;
end;

function nvl(node: TJSONData; defaultValue: string): string;
begin
  try
    Result := defaultValue;
    if node = nil then
      exit;
    if node.isNull then
      exit;
    if (node is TJSONArray) then
    begin
      Result := Trim(node.FormatJSON([], 0));
    end
    else
      Result := Trim(node.AsString);
  except
    on e: Exception do
      raise e;
  end;
end;

function nvl(node: TJSONData; defaultValue: int64): int64;
begin
  try
    Result := defaultValue;
    if node = nil then
      exit;
    if node.isNull then
      exit;
    Result := node.AsInt64;
  except
    on e: Exception do
      raise e;
  end;
end;

function nvl(node: TJSONData; defaultValue: extended): extended;
begin
  try
    Result := defaultValue;
    if node = nil then
      exit;
    if node.isNull then
      exit;
    Result := node.AsFloat;
  except
    on e: Exception do
      raise e;
  end;
end;


function nvl(node: TJSONData; defaultValue: boolean): boolean;
begin
  try
    Result := defaultValue;
    if node = nil then
      exit;
    if node.isNull then
      exit;
    Result := node.AsBoolean;
  except
    on e: Exception do
      raise e;
  end;
end;


// from fpIndexer
function DateToISO8601(DateTime: TDateTime): string;
begin
  Result := FormatDateTime('yyyy-mm-dd', DateTime) + 'T' + FormatDateTime('hh:mm:ss', DateTime);
end;

function ISO8601ToDate(DateTime: string): TDateTime;
begin
  Result :=
    EncodeDate(StrToInt(copy(DateTime, 1, 4)), StrToInt(copy(DateTime, 6, 2)), StrToInt(copy(DateTime, 9, 2))) + EncodeTime(StrToInt(copy(DateTime, 12, 2)), StrToInt(copy(DateTime, 15, 2)), StrToInt(copy(DateTime, 18, 2)), 0);
end;

function GenericCreateCall(clz: TClass): TObject;
begin
  Result := clz.Create;
end;

type

  { TJSONTypeHandlerHolder }

  TJSONTypeHandlerHolder = class
  private
    FHandler: TJsonTypeHandler;
    FKind: TTypeKind;
    procedure SetHandler(AValue: TJsonTypeHandler);
    procedure SetKind(AValue: TTypeKind);
  public
    destructor Destroy; override;
    property Kind: TTypeKind read FKind write SetKind;
    property Handler: TJsonTypeHandler read FHandler write SetHandler;
  end;

  TJSONTypeRegistry = specialize TFPGObjectList<TJSONTypeHandlerHolder>;


  { TJSONObjectHelper }

  TJSONObjectHelper = class helper for TJSONObject
    function hasProperty(Name: string): boolean;
  end;

  { TClassContainer }

  TClassContainer = class
  private
    FtheClass: TClass;
    FtheFactory: TFactory;
    procedure SettheClass(AValue: TClass);
    procedure SettheFactory(AValue: TFactory);
  public
    constructor Create;
    destructor Destroy; override;
    property theClass: TClass read FtheClass write SettheClass;
    property theFactory: TFactory read FtheFactory write SettheFactory;
  end;

  TClassList = specialize TFPGObjectList<TClassContainer>;

  { TClassListHelper }

  TClassListHelper = class helper for TClassList
    function indexOfClass(aClass: TClass): int64;
    function indexOfClassName(aClassName: shortString): int64;
    function getClass(aClassName: shortString): TClass;
    function getFactory(aClassName: shortString): TFactory;
  end;

var
  Registry: TJSONTypeRegistry;
  ClassList: TClassList;
  ClassCS: TRTLCriticalSection;

procedure RegisterJsonTypeHandler(aTypeKind: TTypeKind; aHandler: TJsonTypeHandler);
var
  holder: TJSONTypeHandlerHolder;
begin
  holder         := TJSONTypeHandlerHolder.Create;
  holder.Kind    := aTypeKind;
  holder.Handler := aHandler;
  Registry.Add(holder);
end;

procedure RegisterJSONClass(aClass: TClass; aFactory: TFactory);
var
  cc: TClassContainer;
begin
  try
    EnterCriticalsection(ClassCS);
    while ClassList.IndexOfClass(AClass) = -1 do
    begin
      if ClassList.IndexOfClass(AClass) > -1 then  //class already registered!
      begin
        exit;
      end;
      cc          := TClassContainer.Create;
      cc.theClass := aClass;
      cc.theFactory := aFactory;
      ClassList.Add(cc);
      AClass := AClass.ClassParent;
      if (aClass = nil) or (aClass = TObject) then
      begin
        break;
      end;
    end;
  finally
    LeaveCriticalsection(ClassCS);
  end;
end;

procedure UnRegisterJSONClass(aClass: TClass);
var
  index: integer;
begin
  try
    EnterCriticalsection(ClassCS);
    while ClassList.IndexOfClass(AClass) <> -1 do
    begin
      index := ClassList.IndexOfClass(AClass);
      ClassList.Delete(index);
    end;
  finally
    LeaveCriticalsection(ClassCS);
  end;
end;

function GetJSONClass(const AClassName: string): TClass;
begin
  try
    EnterCriticalsection(ClassCS);
    Result := classList.getClass(AClassName);
  finally
    LeaveCriticalsection(ClassCS);
  end;
end;

function GetJSONFactory(const AClassName: string): TFactory;
begin
  try
    EnterCriticalsection(ClassCS);
    Result := classList.getFactory(AClassName);
  finally
    LeaveCriticalsection(ClassCS);
  end;
end;

function GetJSONFactory(const AClass: TClass): TFactory;
begin
  try
    EnterCriticalsection(ClassCS);
    Result := classList.getFactory(AClass.ClassName);
  finally
    LeaveCriticalsection(ClassCS);
  end;
end;

function camelCase(const aString: string): string;
begin
  Result    := StringReplace(aString, ' ', '', [rfReplaceAll]);
  Result    := ReplaceRegExpr('([A-Z ])', Result, '\U$1', True);
  Result[1] := lowerCase(Result[1]);
end;

function pascalCase(const aString: string): string;
begin
  Result    := StringReplace(aString, ' ', '', [rfReplaceAll]);
  Result    := ReplaceRegExpr('([A-Z])', Result, '\U$1', True);
  Result[1] := upCase(Result[1]);
end;


function selectorCase(const aString: string): string;
begin
  Result := lowerCase(aString[1]) + copy(aString, 2, Length(aString));
  Result := ReplaceRegExpr('(\s*)?([A-Z])', Result, '-\L$2', True);
end;

procedure getHandlers(typeKind: TTypeKind; out handlers: THandlerList);
var
  holder: TJSONTypeHandlerHolder;
  idx: integer;
begin
  handlers := THandlerList.Create(False);
  for idx := Registry.Count - 1 downto 0 do
  begin
    holder := Registry[idx];
    if holder.FKind = typeKind then
    begin
      handlers.add(holder.Handler);
    end;
  end;
end;

procedure getHandlers(typeKind: TTypeKinds; out handlers: THandlerList);
var
  holder: TJSONTypeHandlerHolder;
  idx: integer;
begin
  handlers := THandlerList.Create(False);
  for idx := Registry.Count - 1 downto 0 do
  begin
    holder := Registry[idx];
    if holder.FKind in typeKind then
    begin
      handlers.add(holder.Handler);
    end;
  end;
end;

{ TJSONInt64TypeHandle }

function TJSONInt64TypeHandle.parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
begin
  Result := False;
  if (node <> nil) and (not node.IsNull) then
  begin
    try
      if (info^.PropType^.Kind = tkInt64) then
      begin
        SetOrdProp(AObject, Info^.Name, node.AsInt64);
        Result := True;
      end
      else
      if (info^.PropType^.Kind = tkQWord) then
      begin
        SetOrdProp(AObject, Info^.Name, node.AsQWord);
        Result := True;
      end;
    except
      on  e: Exception do
        raise Exception.CreateFmt('on parse %s, error %s', [Info^.Name, e.Message]);
    end;
  end;
end;

function TJSONInt64TypeHandle.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
begin
  Result := False;
  if (info^.PropType^.Kind in [tkQWord, tkInt64]) then
  begin
    res    := TJSONQWordNumber.Create(GetOrdProp(AObject, Info^.Name));
    Result := True;
  end;

end;

{ TJSONCustomFloatNumber }

function TJSONCustomFloatNumber.GetAsString: TJSONStringType;
begin
  Result := FloatToStr(extended(Value), fs);
end;

{ TJSONBooleanTypeHandle }

function TJSONBooleanTypeHandle.parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
begin
  Result := False;
  if (info^.PropType^.Kind = tkBool) and (node <> nil) then
  begin
    try
      SetOrdProp(AObject, Info^.Name, ifThen(node.AsBoolean, 1, 0));
    except
      on  e: Exception do
        raise Exception.CreateFmt('on parse %s, error %s', [Info^.Name, e.Message]);
    end;
    Result := True;
  end;
end;

function TJSONBooleanTypeHandle.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
begin
  Result := False;
  if (info^.PropType^.Kind = tkBool) then
  begin
    res    := TJSONBoolean.Create(GetOrdProp(AObject, Info^.Name) <> 0);
    Result := True;
  end;

end;

function TJSONObjectHelper.hasProperty(Name: string): boolean;
begin
  Result := IndexOfName(Name) >= 0;
end;

{ TJSONStringListTypeHandle }

function TJSONStringListTypeHandle.parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
var
  target: TObject;
begin
  Result := False;
  if node = nil then
  begin
    exit;
  end;
  if (Info <> nil) then
  begin
    try
      if (Info^.PropType^.Kind = tkClass) and (UpperCase(Info^.PropType^.Name) = UpperCase('TStringList')) then
      begin
        target := GetObjectProp(AObject, Info);
        if target = nil then
        begin
          target := TStringList.Create;
        end;
        TStringList(target).Text := node.AsString;
        SetObjectProp(AObject, Info, target);
        Result := True;
      end;
    except
      on  e: Exception do
        raise Exception.CreateFmt('on parse %s, error %s', [Info^.Name, e.Message]);
    end;
  end
  else
  begin
    if AObject is TStringList then
    begin
      TStringList(AObject).Text := node.AsString;
    end;
  end;
end;

function TJSONStringListTypeHandle.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
var
  target: TObject;
begin
  Result := False;
  if Info <> nil then
  begin
    if (Info^.PropType^.Kind = tkClass) and (UpperCase(Info^.PropType^.Name) = UpperCase('TStringList')) then
    begin
      target := GetObjectProp(AObject, Info);
      res    := TJSONString.Create(TStringList(target).Text);
      Result := True;
    end;
  end
  else
  begin
    if AObject is TStringList then
    begin
      res    := TJSONString.Create(TStringList(AObject).Text);
      Result := True;
    end;
  end;
end;

{ TClassListHelper }

function TClassListHelper.indexOfClass(aClass: TClass): int64;
var
  cc: TClassContainer;
  idx: integer;
begin
  Result := -1;
  for idx := 0 to self.Count - 1 do
  begin
    cc := Items[idx];
    if cc.theClass = aClass then
    begin
      exit(idx);
    end;
  end;
end;

function TClassListHelper.indexOfClassName(aClassName: shortString): int64;
var
  cc: TClassContainer;
begin
  Result := -1;
  for cc in self do
  begin
    if compareText(cc.theClass.ClassName, aClassName) = 0 then
    begin
      exit(IndexOf(cc));
    end;
  end;
end;

function TClassListHelper.getClass(aClassName: shortString): TClass;
var
  idx: int64;
begin
  Result := nil;
  idx    := IndexOfClassName(aClassName);
  if idx > -1 then
  begin
    exit(Items[idx].theClass);
  end;
end;

function TClassListHelper.getFactory(aClassName: shortString): TFactory;
var
  idx: int64;
begin
  idx := IndexOfClassName(aClassName);
  if idx > -1 then
  begin
    Result := (Items[idx].theFactory);
  end;
  if Result = nil then
  begin
    Result := @GenericCreateCall;
  end;
end;


{ TClassContainer }

procedure TClassContainer.SettheClass(AValue: TClass);
begin
  if FtheClass = AValue then
  begin
    Exit;
  end;
  FtheClass := AValue;
end;

procedure TClassContainer.SettheFactory(AValue: TFactory);
begin
  if FtheFactory = AValue then
  begin
    Exit;
  end;
  FtheFactory := AValue;
end;

constructor TClassContainer.Create;
begin
  FtheClass   := nil;
  FtheFactory := nil;
end;

destructor TClassContainer.Destroy;
begin
  inherited Destroy;
end;

{ TJSONCollectionTypeHandle }

procedure TJSONCollectionTypeHandle.parseCollection(ACollection: TCollection; arrayNode: TJSONArray);
var
  idx: integer;
  childNode: TJSONData;
  aCollectionItem: TCollectionItem;
  handlers: THandlerList;
  h: TJsonTypeHandler;
  collectionClassName, itemClassName: string;
begin
  collectionClassName := ACollection.ClassName;
  itemClassName       := ACollection.ItemClass.ClassName;
  try
    ACollection.Clear;
    getHandlers(tkClass, handlers);
    for idx := 0 to arrayNode.Count - 1 do
    begin
      childNode := arrayNode[idx];
      if childNode <> nil then
      begin
        aCollectionItem := aCollection.Add;
        for h in handlers do
        begin
          if h.parse(aCollectionItem, nil, childNode) then
          begin
            break;
          end;
        end;
      end;
    end;
  finally
    handlers.Free;
  end;
end;

function TJSONCollectionTypeHandle.stringifyCollection(ACollection: TCollection; out Res: TJSONData): boolean;
var
  aCollectionItem: TCollectionItem;
  childNode: TJSONData;
  handlers: THandlerList;
  h: TJSONTypeHandler;
begin
  //TLogLog.GetLogger('JSON').Enter(self, 'stringifyCollection');
  if ACollection <> nil then
  begin
    //TLogLogger.GetLogger('JSON').Trace(ACollection.ClassName + '(' + ACollection.ItemClass.ClassName + ')');
    Res := TJSONArray.Create;
    getHandlers(tkClass, handlers);
    for aCollectionItem in aCollection do
    begin
      for h in handlers do
      begin
        childNode := nil;
        if h.stringify(aCollectionItem, nil, childNode) then
        begin
          break;
        end;
      end;
      if childNode <> nil then
      begin
        TJSONArray(res).Add(childNode);
      end;
    end;
    handlers.Free;
    Result := True;
  end;
  //TLogLog.GetLogger('JSON').Leave(self, 'stringifyCollection');
end;

function TJSONCollectionTypeHandle.stringifyPropertyList(AObject: TObject; var Res: TJSONData): boolean;
var
  idx: integer;
  handlers: THandlerList;
  h: TJSONTypeHandler;
  PList: PPropList;
  Count: integer;
  Size: integer;
  childNode: TJSONData;
begin
  Result := True;
  Count  := GetPropList(AObject.ClassInfo, tkAny, nil);
  Size   := Count * SizeOf(Pointer);
  GetMem(PList, Size);
  GetPropList(AObject.ClassInfo, tkAny, PList);
  try
    for idx := 0 to Count - 1 do
    begin
      try
        getHandlers(PList^[idx]^.PropType^.Kind, handlers);
        for h in handlers do
        begin
          if h.stringify(AObject, PList^[idx], childNode) then
          begin
            TJSONObject(Res).Add(PList^[idx]^.Name, childNode);
            break;
          end;
        end;
      finally
        FreeAndNil(handlers);
      end;
    end;
  finally
    FreeMem(PList);
  end;
end;

function TJSONCollectionTypeHandle.parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
var
  clz: TClass;
  aCollection: TCollection;
begin
  Result := False;
  if (Info = nil) and (AObject is TCollection) then
  begin
    parseCollection(AObject as TCollection, node as TJSONArray);
    Result := True;
  end
  else
  if (Info <> nil) and (AObject is TCollection) and (Info^.PropType^.Kind in [tkClass, tkObject]) then
  begin
    clz := GetJSONClass(Info^.PropType^.Name);
    if clz.InheritsFrom(TCollection) then
    begin
      aCollection := GetObjectProp(AObject, Info) as TCollection;
      parseCollection(aCollection, node as TJSONArray);
      Result := True;
    end;
  end;
end;

function TJSONCollectionTypeHandle.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
var
  clz: TClass;
  aCollection: TCollection;
begin
  Result := False;
  if AObject <> nil then
  begin
    if (Info = nil) and (AObject is TCollection) then
    begin
      stringifyCollection(AObject as TCollection, res);
      Result := True;
    end
    else
    if (Info <> nil) and (Info^.PropType^.Kind in [tkClass, tkObject]) then
    begin
      clz := GetJSONClass(Info^.PropType^.Name);
      if clz.InheritsFrom(TCollection) then
      begin
        aCollection := GetObjectProp(AObject, Info) as TCollection;
        stringifyCollection(aCollection, Res);
        Result := True;
      end;
    end;
  end;
end;

{ TJSONDynArrayIntegerTypeHandle }

function TJSONDynArrayIntegerTypeHandle.parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
type
  TSetter = procedure(values: TDynIntegerArray) of object;
var
  values: TDynIntegerArray;
  idx: integer;
  m: TMethod;
begin
  Result := False;
  if (Info^.PropType^.Kind = tkDynArray) and (comparetext(Info^.PropType^.Name, 'TDynIntegerArray') = 0) then
  begin
    try
      if node <> nil then
      begin
        SetLength(values, TJSONArray(node).Count);
        for idx := 0 to TJSONArray(node).Count - 1 do
        begin
          values[idx] := TJSONArray(node)[idx].AsInteger;
        end;
      end
      else
      begin
        SetLength(values, 0);
      end;
      if Info^.SetProc <> nil then
      begin
        m.Code := Info^.SetProc;
        m.Data := AObject;
        TSetter(m)(values);
      end;
      Result := True;
    except
      on  e: Exception do
        raise Exception.CreateFmt('on parse %s, error %s', [Info^.Name, e.Message]);
    end;
  end;
end;

function TJSONDynArrayIntegerTypeHandle.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
type
  TGetterByIndex = function(index: longint): TDynIntegerArray of object;
  TGetter = function: TDynIntegerArray of object;
var
  values: TDynIntegerArray;
  idx: integer;
  AMethod: TMethod;
begin
  Result := False;
  if (Info^.PropType^.Kind = tkDynArray) and (Info^.PropType^.Name = 'TDynIntegerArray') then
  begin
    begin
      case (Info^.PropProcs) and 3 of
        ptField:
        begin
          values := TDynIntegerArray((Pointer(AObject) + PtrUInt(Info^.GetProc))^);
        end;
        ptStatic,
        ptVirtual:
        begin
          if (Info^.PropProcs and 3) = ptStatic then
          begin
            AMethod.Code := Info^.GetProc;
          end
          else
          begin
            AMethod.Code := PCodePointer(Pointer(AObject.ClassType) + PtrUInt(Info^.GetProc))^;
          end;
          AMethod.Data := AObject;
          if ((Info^.PropProcs shr 6) and 1) <> 0 then
          begin
            values := TGetterByIndex(AMethod)(Info^.Index);
          end
          else
          begin
            values := TGetter(AMethod)();
          end;
        end;
      end;
    end;
    res := TJSONArray.Create;
    for idx := 0 to Length(values) - 1 do
    begin
      TJSONArray(res).Add(values[idx]);
    end;
    Result := True;
  end;
end;

{ TJSONWideStringTypeHandle }

function TJSONWideStringTypeHandle.parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
begin
  Result := False;
  if (info^.PropType^.Kind in [tkWString]) and (node <> nil) then
  begin
    try
      SetWideStrProp(AObject, Info^.Name, node.AsString);
    except
      on  e: Exception do
        raise Exception.CreateFmt('on parse %s, error %s', [Info^.Name, e.Message]);
    end;
    Result := True;
  end;
end;

function TJSONWideStringTypeHandle.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
begin
  Result := False;
  if (info^.PropType^.Kind in [tkWString]) then
  begin
    res    := TJSONString.Create(GetWideStrProp(AObject, Info));
    Result := True;
  end;
end;

{ TJSONEnumerationTypeHandle }

function TJSONEnumerationTypeHandle.parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
begin
  Result := False;
  if (Info^.PropType^.Kind = tkEnumeration) then
  begin
    if (node <> nil) then
    begin
      SetEnumProp(AObject, Info, Node.AsString);
    end;
    Result := True;
  end;
end;

function TJSONEnumerationTypeHandle.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
begin
  Result := False;
  if (Info^.PropType^.Kind = tkEnumeration) then
  begin
    res    := TJSONString.Create(GetEnumProp(AObject, Info));
    Result := True;
  end;
end;

{ TJSONDynStringTypeHandle }

function TJSONDynStringTypeHandle.parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
type
  TSetter = procedure(values: TStringArray) of object;
var
  values: TStringArray;
  idx: integer;
  m: TMethod;
begin
  Result := False;
  if (Info^.PropType^.Kind = tkDynArray) and (Info^.PropType^.Name = 'TStringArray') then
  begin
    try
      if node <> nil then
      begin
        SetLength(values, TJSONArray(node).Count);
        for idx := 0 to TJSONArray(node).Count - 1 do
        begin
          values[idx] := TJSONArray(node)[idx].AsString;
        end;
      end
      else
      begin
        SetLength(values, 0);
      end;
      if Info^.SetProc <> nil then
      begin
        m.Code := Info^.SetProc;
        m.Data := AObject;
        TSetter(m)(values);
      end;
    except
      on  e: Exception do
        raise Exception.CreateFmt('on parse %s, error %s', [Info^.Name, e.Message]);
    end;
    Result := True;
  end;
end;

function TJSONDynStringTypeHandle.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
type
  TGetterByIndex = function(index: longint): TStringArray of object;
  TGetter = function: TStringArray of object;
var
  values: TStringArray;
  idx: integer;
  AMethod: TMethod;
begin
  Result := False;
  if (Info^.PropType^.Kind = tkDynArray) and (Info^.PropType^.Name = 'TStringArray') then
  begin
    begin
      case (Info^.PropProcs) and 3 of
        ptField:
        begin
          values := TStringArray((Pointer(AObject) + PtrUInt(Info^.GetProc))^);
        end;
        ptStatic,
        ptVirtual:
        begin
          if (Info^.PropProcs and 3) = ptStatic then
          begin
            AMethod.Code := Info^.GetProc;
          end
          else
          begin
            AMethod.Code := PCodePointer(Pointer(AObject.ClassType) + PtrUInt(Info^.GetProc))^;
          end;
          AMethod.Data := AObject;
          if ((Info^.PropProcs shr 6) and 1) <> 0 then
          begin
            values := TGetterByIndex(AMethod)(Info^.Index);
          end
          else
          begin
            values := TGetter(AMethod)();
          end;
        end;
      end;
    end;
    res := TJSONArray.Create;
    for idx := 0 to high(values) do
    begin
      TJSONArray(res).Add(values[idx]);
    end;
    Result := True;
  end;
end;

{ TJSONFloatTypeHandler }

function TJSONFloatTypeHandler.parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
begin
  Result := False;
  if (info^.PropType^.Kind = tkFloat) and (info^.PropType^.Name = 'TDateTime') and (node <> nil) then
  begin
    try
      SetFloatProp(AObject, Info^.Name, ISO8601ToDate(node.AsString));
    except
      on  e: Exception do
        raise Exception.CreateFmt('on parse %s, error %s', [Info^.Name, e.Message]);
    end;
    Result := True;
  end
  else
  if (info^.PropType^.Kind = tkFloat) and (node <> nil) then
  begin
    try
      SetFloatProp(AObject, Info^.Name, node.AsFloat);
    except
      on  e: Exception do
        raise Exception.CreateFmt('on parse %s, error %s', [Info^.Name, e.Message]);
    end;
    Result := True;
  end;
end;

function TJSONFloatTypeHandler.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
begin
  Result := False;
  if (info^.PropType^.Kind = tkFloat) and (info^.PropType^.Name = 'TDateTime') then
  begin
    res    := TJSONString.Create(DateToISO8601(GetFloatProp(AObject, Info)));
    Result := True;
  end
  else
  if (info^.PropType^.Kind = tkFloat) then
  begin
    res    := TJSONCustomFloatNumber.Create(GetFloatProp(AObject, Info));
    Result := True;
  end;
end;


{ TJSONIntegerTypeHandle }

function TJSONIntegerTypeHandle.parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
begin
  Result := False;
  if (info^.PropType^.Kind = tkInteger) and (node <> nil) then
  begin
    try
      SetOrdProp(AObject, Info^.Name, node.AsInteger);
    except
      on  e: Exception do
        raise Exception.CreateFmt('on parse %s, error %s', [Info^.Name, e.Message]);
    end;
    Result := True;
  end;
end;

function TJSONIntegerTypeHandle.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
begin
  Result := False;
  if (info^.PropType^.Kind = tkInteger) then
  begin
    res    := TJSONIntegerNumber.Create(GetOrdProp(AObject, Info^.Name));
    Result := True;
  end;
end;

{ TJSONStringTypeHandle }

function TJSONStringTypeHandle.parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
var
  Value: string;
begin
  Result := False;
  if (info^.PropType^.Kind in [tkString, tkAString]) and (node <> nil) then
  begin
    LogDebug(Format('%s as String', [info^.Name]));
    try
      Value := node.AsString;
      SetStrProp(AObject, Info^.Name, Value);
    except
      on  e: Exception do
        raise Exception.CreateFmt('on parse %s, error %s', [Info^.Name, e.Message]);
    end;
    Result := True;
  end;
end;

function TJSONStringTypeHandle.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
begin
  Result := False;
  if (info^.PropType^.Kind in [tkString, tkAString]) then
  begin
    res    := TJSONString.Create(GetStrProp(AObject, Info));
    Result := True;
  end;
end;

{ TJSONObjectTypeHandler }

procedure TJSONObjectTypeHandler.parseProperties(AObject: TObject; Node: TJSONData);

var
  idx: integer;
  handlers: THandlerList;
  h: TJSONTypeHandler;
  PList: PPropList;
  Count: integer;
  Size: integer;
  pname: string;
  childNode: TJSONData;
begin
  if AObject = nil then
    exit;
  Count := GetPropList(AObject.ClassInfo, tkAny, nil);
  Size  := Count * SizeOf(Pointer);
  GetMem(PList, Size);
  GetPropList(AObject.ClassInfo, tkAny, PList);
  try
    for idx := 0 to Count - 1 do
    begin
      pname     := PList^[idx]^.Name;
      childNode := TJSONObject(node).Find(pname);
      if childNode = nil then
      begin
        pname     := camelCase(PList^[idx]^.Name);
        childNode := TJSONObject(node).Find(pname);
      end;
      if childNode = nil then
      begin
        pname     := selectorCase(PList^[idx]^.Name);
        childNode := TJSONObject(node).Find(pname);
      end;
      if childNode = nil then
      begin
        pname     := pascalCase(PList^[idx]^.Name);
        childNode := TJSONObject(node).Find(pname);
      end;
      if (childNode <> nil) and (not childNode.IsNull) then
      begin
        LogDebug(PList^[idx]^.Name);
        try
          getHandlers(PList^[idx]^.PropType^.Kind, handlers);
          for h in handlers do
          begin
            try
              if h.parse(AObject, PList^[idx], childNode) then
              begin
                break;
              end;
            except
              on e: Exception do
                raise Exception.CreateFmt('on parse %s, error %s', [PName, e.Message]);
            end;
          end;
        finally
          FreeAndNil(handlers);
        end;
      end;
    end;
  finally
    FreeMem(PList);
  end;
end;

function TJSONObjectTypeHandler.stringifyPropertyAllowed(AObject: TObject; info: PPropInfo): boolean;
begin
  Result := True;
end;

function TJSONObjectTypeHandler.stringifyPropertyList(AObject: TObject; var Res: TJSONData): boolean;
var
  idx: integer;
  handlers: THandlerList;
  h: TJSONTypeHandler;
  PList: PPropList;
  Count: integer;
  Size: integer;
  childNode: TJSONData;
begin

  Result := True;
  Count  := GetPropList(AObject.ClassInfo, tkAny, nil);
  Size   := Count * SizeOf(Pointer);
  GetMem(PList, Size);
  LogDebug(AObject.ClassName);
  GetPropList(AObject.ClassInfo, tkAny, PList, True);
  try
    for idx := 0 to Count - 1 do
    begin
      if stringifyPropertyAllowed(AObject, PList^[idx]) then
      begin
        try
          getHandlers(PList^[idx]^.PropType^.Kind, handlers);
          for h in handlers do
          begin
            LogDebug(Format(' stringif property %s (%s) -> %s', [PList^[idx]^.Name, GetEnumName(typeInfo(TTypeKind), Ord(PList^[idx]^.PropType^.Kind)), h.ClassName]));
            if h.stringify(AObject, PList^[idx], childNode) then
            begin
              TJSONObject(Res).Add(PList^[idx]^.Name, childNode);
              break;
            end;
          end;
        finally
          FreeAndNil(handlers);
        end;
      end;
    end;
  finally
    FreeMem(PList);
  end;
end;

function TJSONObjectTypeHandler.parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
var
  handlers: THandlerList;
  h: TJSONTypeHandler;
  anObject: TObject;
  clz: TClass;
  factory: TFactory;
begin
  Result := False;
  if (node = nil) or (node.IsNull) then
  begin
    exit;
  end;
  if info = nil then
  begin
    LogDebug(Format('parse %s', [AObject.ClassName]));
    parseProperties(AObject, node);
    Result := True;
  end
  else
  begin
    AnObject := GetObjectProp(AObject, Info^.Name);
    if anObject = nil then
    begin
      clz     := GetJSONClass(info^.PropType^.Name);
      factory := GetJSONFactory(info^.PropType^.Name);
      if (clz <> nil) and (not node.IsNull) then
      begin
        anObject := factory(clz);
      end;
    end;
    if (anObject <> nil) and (not node.IsNull) then
    begin
      getHandlers(info^.PropType^.Kind, handlers);
      for h in handlers do
      begin
        if h.parse(anObject, nil, node) then
        begin
          Result := True;
          SetObjectProp(aObject, info, anObject);
          break;
        end;
      end;
      handlers.Free;
    end;
  end;
end;

function TJSONObjectTypeHandler.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
var
  propObject: TObject;
  childNode: TJSONData;
  handlers: THandlerList;
  h: TJSONTypeHandler;
begin
  Result := False;
  if AObject = nil then
  begin
    res    := CreateJSON;
    Result := True;
  end
  else
  if info = nil then
  begin
    Res := TJSONObject.Create;
    stringifyPropertyList(AObject, Res);
    Result := True;
  end
  else
  begin
    LogDebug(Format('TJSONObjectTypeHandler.stringify check %s', [AObject.ClassName]));
    propObject := GetObjectProp(AObject, Info^.Name);
    if propObject <> nil then
    begin
      getHandlers(Info^.PropType^.Kind, handlers);
      for h in handlers do
      begin
        if h.stringify(propObject, nil, childNode) then
        begin
          break;
        end;
      end;
      handlers.Free;
      res := childNode;
    end
    else
    begin
      res := CreateJSON;
    end;
    Result := True;
  end;
end;


{ TJSONTypeHandlerHolder }

procedure TJSONTypeHandlerHolder.SetHandler(AValue: TJsonTypeHandler);
begin
  if FHandler = AValue then
  begin
    Exit;
  end;
  FHandler := AValue;
end;

procedure TJSONTypeHandlerHolder.SetKind(AValue: TTypeKind);
begin
  if FKind = AValue then
  begin
    Exit;
  end;
  FKind := AValue;
end;

destructor TJSONTypeHandlerHolder.Destroy;
begin
  FHandler.Free;
  inherited Destroy;
end;

{ TJSON }

function TJSON3.parse(Source: TJSONStringType; clz: TClass): TObject;
var
  jsonData: TJSONData;
  factory: TFactory;
  handlers: THandlerList;
  h: TJsonTypeHandler;
begin
  jsonData := GetJSON(Source, True);
  try
    factory := GetJSONFactory(clz.ClassName);
    if (factory = nil) then
    begin
      raise EFactoryFailure.Create(clz.ClassName);
    end;
    Result := factory(clz);
    if (Result = nil) then
    begin
      raise EFactoryFailure.Create(clz.ClassName);
    end;

    getHandlers(tkClass, handlers);
    for h in handlers do
    begin
      if h.parse(Result, nil, jsonData) then
      begin
        break;
      end;
    end;
    handlers.Free;
    jsonData.Free;
  except
    if Result <> nil then
    begin
      Result.FreeInstance;
    end;
    raise;
  end;
end;

function TJSON3.stringify(const obj: TObject; FormatOptions: TFormatOptions): TJSONStringType;
var
  jsonData: TJSONData = nil;
  handlers: THandlerList;
  h: TJsonTypeHandler;
begin
  LogDebug(Format('TJSON3.stringify %s', [obj.ClassName]));
  try
    getHandlers(tkObject, handlers);
    for h in handlers do
    begin
      LogDebug(Format('TJSON3.stringify ask to %s', [h.ClassName]));
      if h.stringify(obj, nil, jsonData) then
      begin
        break;
      end;
    end;
    handlers.Free;
    if jsonData = nil then
    begin
      getHandlers(tkClass, handlers);
      for h in handlers do
      begin
        LogDebug(Format('TJSON3.stringify ask to %s', [h.ClassName]));
        if h.stringify(obj, nil, jsonData) then
        begin
          break;
        end;
      end;
      handlers.Free;
    end;
    if jsonData <> nil then
    begin
      Result := jsonData.FormatJSON(FormatOptions);
    end
    else
    begin
      Result := 'null';
    end;
  finally
    try
      if jsonData <> nil then
      begin
        jsonData.Free;
      end;
    except
      on e: Exception do
        if isConsole then
        begin
          LogError(e.message);
        end;
    end;
  end;
end;


var
  idx: integer;

initialization
  log := nil;
  InitCriticalSection(ClassCS);

  fs.DecimalSeparator  := '.';
  fs.ThousandSeparator := ',';

  JSON     := TJSON3.Create;
  Registry := TJSONTypeRegistry.Create();

  ClassList := TClassList.Create(True);
  RegisterJSONClass(TStringList);
  RegisterJsonTypeHandler(tkObject, TJSONObjectTypeHandler.Create);
  RegisterJsonTypeHandler(tkClass, TJSONObjectTypeHandler.Create);
  RegisterJsonTypeHandler(tkInt64, TJSONInt64TypeHandle.Create);
  RegisterJsonTypeHandler(tkQWord, TJSONInt64TypeHandle.Create);
  RegisterJsonTypeHandler(tkBool, TJSONBooleanTypeHandle.Create);
  RegisterJsonTypeHandler(tkInteger, TJSONIntegerTypeHandle.Create);
  RegisterJsonTypeHandler(tkFloat, TJSONFloatTypeHandler.Create);
  RegisterJsonTypeHandler(tkString, TJSONStringTypeHandle.Create);
  RegisterJsonTypeHandler(tkAString, TJSONStringTypeHandle.Create);
  RegisterJsonTypeHandler(tkWString, TJSONWideStringTypeHandle.Create);
  RegisterJsonTypeHandler(tkDynArray, TJSONDynStringTypeHandle.Create);
  RegisterJsonTypeHandler(tkDynArray, TJSONDynArrayIntegerTypeHandle.Create);
  RegisterJsonTypeHandler(tkEnumeration, TJSONEnumerationTypeHandle.Create);
  RegisterJsonTypeHandler(tkClass, TJSONCollectionTypeHandle.Create);
  RegisterJsonTypeHandler(tkObject, TJSONCollectionTypeHandle.Create);
  RegisterJsonTypeHandler(tkClass, TJSONStringListTypeHandle.Create);
  RegisterJsonTypeHandler(tkObject, TJSONStringListTypeHandle.Create);

finalization
  ClassList.Clear;
  for idx := Registry.Count - 1 downto 0 do
  begin
    Registry.Delete(idx);
  end;
  ClassList.Free;
  Registry.Free;
  JSON.Free;
  DoneCriticalsection(ClassCS);

end.
