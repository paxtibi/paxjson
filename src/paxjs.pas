unit paxjs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, typinfo, fpjson, fgl;

//
//Date Format: http://es5.github.io/#x15.9.1.15
//
type
  TDynIntegerArray = array of integer;
  { TJSON }
  TJSON3 = class
    function parse(source: TJSONStringType; clz: TClass): TObject; overload;
    function stringify(const obj: TObject; FormatOptions: TFormatOptions = AsCompressedJSON): TJSONStringType;
  end;

  TJsonTypeHandler = class
  public
    function parse(AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; virtual; abstract;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; virtual; abstract;
  end;

  { TJSONObjectTypeHandler }

  TJSONObjectTypeHandler = class(TJsonTypeHandler)
  protected
    function stringifyPropertyList(AObject: TObject; var Res: TJSONData): boolean;
  protected
    function parse(AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONIntegerTypeHandle }

  TJSONIntegerTypeHandle = class(TJsonTypeHandler)
    function parse(AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONFloatTypeHandler }

  TJSONFloatTypeHandler = class(TJsonTypeHandler)
    function parse(AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONStringTypeHandle }

  TJSONStringTypeHandle = class(TJsonTypeHandler)
    function parse(AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONWideStringTypeHandle }

  TJSONWideStringTypeHandle = class(TJsonTypeHandler)
    function parse(AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONDynStringTypeHandle }

  TJSONDynStringTypeHandle = class(TJsonTypeHandler)
    function parse(AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONDynArrayIntegerTypeHandle }

  TJSONDynArrayIntegerTypeHandle = class(TJsonTypeHandler)
    function parse(AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONEnumerationTypeHandle }

  TJSONEnumerationTypeHandle = class(TJsonTypeHandler)
    function parse(AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONCollectionTypeHandle }

  TJSONCollectionTypeHandle = class(TJsonTypeHandler)
  protected
    procedure parseCollection(ACollection: TCollection; arrayNode: TJSONArray);
    function stringifyCollection(ACollection: TCollection; var Res: TJSONData): boolean;
    function stringifyPropertyList(AObject: TObject; var Res: TJSONData): boolean;
  public
    function parse(AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

var
  JSON: TJSON3;

type
  EFactoryFailure = class(Exception)
  end;

  TFactory = function(clz: TClass): TObject;
  THandlerList = specialize TFPGObjectList<TJsonTypeHandler>;

procedure RegisterJsonTypeHandler(aTypeKind: TTypeKind; aHandler: TJsonTypeHandler);
procedure RegisterJSONClass(aClass: TClass; aFactory: TFactory = nil);
function GetJSONClass(const AClassName: string): TClass;
function GetJSONFactory(const AClassName: string): TFactory; overload;
function GetJSONFactory(const AClass: TClass): TFactory; overload;
function camelCase(const aString: string): string;
function pascalCase(const aString: string): string;
function selectorCase(const aString: string): string;
procedure getHandlers(typeKind: TTypeKind; out handlers: THandlerList);


implementation

uses
  jsonparser, RegExpr;

// from fpIndexer
function DateToISO8601(DateTime: TDateTime): string;
begin
  Result := FormatDateTime('yyyy-mm-dd', DateTime) + 'T' + FormatDateTime('hh:mm:ss', DateTime);
end;

function ISO8601ToDate(DateTime: string): TDateTime;
begin
  Result := EncodeDate(StrToInt(copy(DateTime, 1, 4)), StrToInt(copy(DateTime, 6, 2)), StrToInt(copy(DateTime, 9, 2))) + EncodeTime(StrToInt(copy(DateTime, 12, 2)), StrToInt(copy(DateTime, 15, 2)), StrToInt(copy(DateTime, 18, 2)), 0);
end;

function GenericCreateCall(clz: TClass): TObject;
begin
  result := clz.Create;
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


  { TClassContainer }

  TClassContainer = class
  private
    FtheClass: TClass;
    FtheFactory: TFactory;
    procedure SettheClass(AValue: TClass);
    procedure SettheFactory(AValue: TFactory);
  public
    property theClass: TClass read FtheClass write SettheClass;
    property theFactory: TFactory read FtheFactory write SettheFactory;
  end;

  TClassList = specialize TFPGList<TClassContainer>;

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
  holder := TJSONTypeHandlerHolder.Create;
  holder.Kind := aTypeKind;
  holder.Handler := aHandler;
  Registry.Add(holder);
end;

procedure RegisterJSONClass(aClass: TClass; aFactory: TFactory);
var
  cc: TClassContainer;
begin
  //('-->RegisterJSONClass(', aClass.ClassName, ')');
  try
    EnterCriticalsection(ClassCS);
    while ClassList.IndexOfClass(AClass) = -1 do
    begin
      if ClassList.IndexOfClass(AClass) > -1 then  //class alread registered!
      begin
        exit;
      end;
      cc := TClassContainer.Create;
      cc.theClass := aClass;
      cc.theFactory := aFactory;
      ClassList.Add(cc);
      AClass := AClass.ClassParent;
      if (aClass = nil) or (aClass = TObject) then
        break;
    end;
  finally
    LeaveCriticalsection(ClassCS);
  end;
  //writeln('<--RegisterJSONClass(', aClass.ClassName, ')');
end;

function GetJSONClass(const AClassName: string): TClass;
begin
  //writeln('-->GetJSONClass(', AClassName, ')');
  try
    EnterCriticalsection(ClassCS);
    result := classList.getClass(AClassName);
  finally
    LeaveCriticalsection(ClassCS);
  end;
  //writeln('<--GetJSONClass(', AClassName, ')');
end;

function GetJSONFactory(const AClassName: string): TFactory;
begin
  //writeln('-->GetJSONFactory(', AClassName, ')');
  try
    EnterCriticalsection(ClassCS);
    result := classList.getFactory(AClassName);
  finally
    LeaveCriticalsection(ClassCS);
  end;
  //writeln('<--GetJSONFactory(', AClassName, ')');
end;

function GetJSONFactory(const AClass: TClass): TFactory;
begin
  //writeln('-->GetJSONFactory(', AClassName, ')');
  try
    EnterCriticalsection(ClassCS);
    result := classList.getFactory(AClass.ClassName);
  finally
    LeaveCriticalsection(ClassCS);
  end;
  //writeln('<--GetJSONFactory(', AClassName, ')');
end;

function camelCase(const aString: string): string;
begin
  result := ReplaceRegExpr('([A-Z])', aString, '\U$1', True);
  result[1] := lowerCase(Result[1]);
end;

function pascalCase(const aString: string): string;
begin
  result := ReplaceRegExpr('([A-Z])', aString, '\U$1', True);
  result[1] := upCase(Result[1]);
end;


function selectorCase(const aString: string): string;
begin
  result := lowerCase(aString[1]) + copy(aString, 2, Length(aString));
  result := ReplaceRegExpr('([A-Z])', result, '-\L$1', True);
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
      handlers.add(holder.Handler);
  end;
end;

{ TClassListHelper }

function TClassListHelper.indexOfClass(aClass: TClass): int64;
var
  cc: TClassContainer;
begin
  result := -1;
  for cc in self do
  begin
    if cc.theClass = aClass then
    begin
      exit(IndexOf(cc));
    end;
  end;
end;

function TClassListHelper.indexOfClassName(aClassName: shortString): int64;
var
  cc: TClassContainer;
begin
  result := -1;
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
  result := nil;
  idx := IndexOfClassName(aClassName);
  if idx > -1 then
    exit(Items[idx].theClass);
end;

function TClassListHelper.getFactory(aClassName: shortString): TFactory;
var
  idx: int64;
begin
  idx := IndexOfClassName(aClassName);
  if idx > -1 then
    result := (Items[idx].theFactory);
  if result = nil then
    result := @GenericCreateCall;
end;


{ TClassContainer }

procedure TClassContainer.SettheClass(AValue: TClass);
begin
  if FtheClass = AValue then
    Exit;
  FtheClass := AValue;
end;

procedure TClassContainer.SettheFactory(AValue: TFactory);
begin
  if FtheFactory = AValue then
    Exit;
  FtheFactory := AValue;
end;

{ TJSONCollectionTypeHandle }

procedure TJSONCollectionTypeHandle.parseCollection(ACollection: TCollection; arrayNode: TJSONArray);
var
  idx: integer;
  childNode: TJSONData;
  aCollectionItem: TCollectionItem;
  handlers: THandlerList;
  h: TJsonTypeHandler;
begin
  getHandlers(tkClass, handlers);
  try
    for idx := 0 to arrayNode.Count - 1 do
    begin
      childNode := arrayNode[idx];
      aCollectionItem := aCollection.Add;
      for h in handlers do
      begin
        if h.parse(aCollectionItem, nil, childNode) then
          break;
      end;
    end;
  except
  end;
  handlers.Free;
end;

function TJSONCollectionTypeHandle.stringifyCollection(ACollection: TCollection; var Res: TJSONData): boolean;
var
  aCollectionItem: TCollectionItem;
  childNode: TJSONData;
  handlers: THandlerList;
  h: TJSONTypeHandler;
begin
  Res := TJSONArray.Create;
  getHandlers(tkClass, handlers);
  for aCollectionItem in aCollection do
  begin
    for h in handlers do
    begin
      if h.stringify(aCollectionItem, nil, childNode) then
        break;
    end;
    if childNode <> nil then
      TJSONArray(res).Add(childNode);
  end;
  handlers.Free;
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
  result := True;
  Count := GetPropList(AObject.ClassInfo, tkAny, nil);
  Size := Count * SizeOf(Pointer);
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

function TJSONCollectionTypeHandle.parse(AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
var
  clz: TClass;
  aCollection: TCollection;
begin
  result := False;
  if (Info = nil) and (AObject is TCollection) then
  begin
    parseCollection(AObject as TCollection, node as TJSONArray);
    result := True;
  end
  else
  if (Info <> nil) and (AObject is TCollection) and (Info^.PropType^.Kind in [tkClass, tkObject]) then
  begin
    clz := GetJSONClass(Info^.PropType^.Name);
    if clz.InheritsFrom(TCollection) then
    begin
      aCollection := GetObjectProp(AObject, Info) as TCollection;
      parseCollection(aCollection, node as TJSONArray);
      result := True;
    end;
  end;
end;

function TJSONCollectionTypeHandle.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
var
  clz: TClass;
  aCollection: TCollection;
begin
  result := False;
  if (Info = nil) and (AObject is TCollection) then
  begin
    stringifyCollection(AObject as TCollection, res);
    result := True;
  end
  else
  if (Info <> nil) and (Info^.PropType^.Kind in [tkClass, tkObject]) then
  begin
    clz := GetJSONClass(Info^.PropType^.Name);
    if clz.InheritsFrom(TCollection) then
    begin
      aCollection := GetObjectProp(AObject, Info) as TCollection;
      stringifyCollection(aCollection, Res);
      result := True;
    end;
  end;
end;

{ TJSONDynArrayIntegerTypeHandle }

function TJSONDynArrayIntegerTypeHandle.parse(AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
type
  TSetter = procedure(values: TDynIntegerArray) of object;
var
  values: TDynIntegerArray;
  idx: integer;
  m: TMethod;
begin
  result := False;
  if (Info^.PropType^.Kind = tkDynArray) and (comparetext(Info^.PropType^.name, 'TDynIntegerArray') = 0) then
  begin
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
    result := True;
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
  result := False;
  if (Info^.PropType^.Kind = tkDynArray) and (Info^.PropType^.name = 'TDynIntegerArray') then
  begin
    begin
      case (Info^.PropProcs) and 3 of
        ptField:
          values := TDynIntegerArray((Pointer(AObject) + PtrUInt(Info^.GetProc))^);
        ptStatic,
        ptVirtual:
        begin
          if (Info^.PropProcs and 3) = ptStatic then
            AMethod.Code := Info^.GetProc
          else
            AMethod.Code := PCodePointer(Pointer(AObject.ClassType) + PtrUInt(Info^.GetProc))^;
          AMethod.Data := AObject;
          if ((Info^.PropProcs shr 6) and 1) <> 0 then
            values := TGetterByIndex(AMethod)(Info^.Index)
          else
            values := TGetter(AMethod)();
        end;
      end;
    end;
    res := TJSONArray.Create;
    for idx := 0 to Length(values) - 1 do
    begin
      TJSONArray(res).Add(values[idx]);
    end;
    result := True;
  end;
end;

{ TJSONWideStringTypeHandle }

function TJSONWideStringTypeHandle.parse(AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
begin
  result := False;
  if (info^.PropType^.Kind in [tkWString]) and (node <> nil) then
  begin
    SetWideStrProp(AObject, Info^.Name, node.AsString);
    result := True;
  end;
end;

function TJSONWideStringTypeHandle.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
begin
  result := False;
  if (info^.PropType^.Kind in [tkWString]) then
  begin
    res := TJSONString.Create(GetWideStrProp(AObject, Info));
    result := True;
  end;
end;

{ TJSONEnumerationTypeHandle }

function TJSONEnumerationTypeHandle.parse(AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
begin
  result := False;
  if (Info^.PropType^.Kind = tkEnumeration) then
  begin
    if (node <> nil) then
      SetEnumProp(AObject, Info, Node.AsString);
    result := True;
  end;
end;

function TJSONEnumerationTypeHandle.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
begin
  result := False;
  if (Info^.PropType^.Kind = tkEnumeration) then
  begin
    res := TJSONString.Create(GetEnumProp(AObject, Info));
    result := True;
  end;
end;

{ TJSONDynStringTypeHandle }

function TJSONDynStringTypeHandle.parse(AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
type
  TSetter = procedure(values: TStringArray) of object;
var
  values: TStringArray;
  idx: integer;
  m: TMethod;
begin
  result := False;
  if (Info^.PropType^.Kind = tkDynArray) and (Info^.PropType^.name = 'TStringArray') then
  begin
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
    result := True;
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
  result := False;
  if (Info^.PropType^.Kind = tkDynArray) and (Info^.PropType^.name = 'TStringArray') then
  begin
    begin
      case (Info^.PropProcs) and 3 of
        ptField:
          values := TStringArray((Pointer(AObject) + PtrUInt(Info^.GetProc))^);
        ptStatic,
        ptVirtual:
        begin
          if (Info^.PropProcs and 3) = ptStatic then
            AMethod.Code := Info^.GetProc
          else
            AMethod.Code := PCodePointer(Pointer(AObject.ClassType) + PtrUInt(Info^.GetProc))^;
          AMethod.Data := AObject;
          if ((Info^.PropProcs shr 6) and 1) <> 0 then
            values := TGetterByIndex(AMethod)(Info^.Index)
          else
            values := TGetter(AMethod)();
        end;
      end;
    end;
    res := TJSONArray.Create;
    for idx := 0 to high(values) do
    begin
      TJSONArray(res).Add(values[idx]);
    end;
    result := True;
  end;
end;

{ TJSONFloatTypeHandler }

function TJSONFloatTypeHandler.parse(AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
begin
  result := False;
  if (info^.PropType^.Kind = tkFloat) and (info^.PropType^.Name = 'TDateTime') and (node <> nil) then
  begin
    SetFloatProp(AObject, Info^.Name, ISO8601ToDate(node.AsString));
    result := True;
  end
  else
  if (info^.PropType^.Kind = tkFloat) and (node <> nil) then
  begin
    SetFloatProp(AObject, Info^.Name, node.AsFloat);
    result := True;
  end;
end;

function TJSONFloatTypeHandler.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
begin
  result := False;
  if (info^.PropType^.Kind = tkFloat) and (info^.PropType^.Name = 'TDateTime') then
  begin
    res := TJSONString.Create(DateToISO8601(GetFloatProp(AObject, Info)));
    result := True;
  end
  else
  if (info^.PropType^.Kind = tkFloat) then
  begin
    res := TJSONFloatNumber.Create(GetFloatProp(AObject, Info));
    result := True;
  end;

end;


{ TJSONIntegerTypeHandle }

function TJSONIntegerTypeHandle.parse(AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
begin
  result := False;
  if (info^.PropType^.Kind = tkInteger) and (node <> nil) then
  begin
    SetOrdProp(AObject, Info^.Name, node.AsInteger);
    result := True;
  end;
end;

function TJSONIntegerTypeHandle.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
begin
  result := False;
  if (info^.PropType^.Kind = tkInteger) then
  begin
    res := TJSONIntegerNumber.Create(GetOrdProp(AObject, Info^.Name));
    result := True;
  end;
end;

{ TJSONStringTypeHandle }

function TJSONStringTypeHandle.parse(AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
begin
  result := False;
  if (info^.PropType^.Kind in [tkString, tkAString]) and (node <> nil) then
  begin
    SetStrProp(AObject, Info^.Name, node.AsString);
    result := True;
  end;
end;

function TJSONStringTypeHandle.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
begin
  result := False;
  if (info^.PropType^.Kind in [tkString, tkAString]) then
  begin
    res := TJSONString.Create(GetStrProp(AObject, Info));
    result := True;
  end;
end;

{ TJSONObjectTypeHandler }

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
  //Writeln('-->TJSONObjectTypeHandler.stringifyPropertyList');
  result := True;
  Count := GetPropList(AObject.ClassInfo, tkAny, nil);
  Size := Count * SizeOf(Pointer);
  GetMem(PList, Size);
  GetPropList(AObject.ClassInfo, tkAny, PList);
  try
    for idx := 0 to Count - 1 do
    begin
      try
        //writeln('-- ', PList^[idx]^.Name, '');
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
  //Writeln('<--TJSONObjectTypeHandler.stringifyPropertyList(', AObject.ClassName, ')');
end;

function TJSONObjectTypeHandler.parse(AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
var
  idx: integer;
  handlers: THandlerList;
  h: TJSONTypeHandler;
  PList: PPropList;
  Count: integer;
  Size: integer;
  anObject: TObject;
  clz: TClass;
  pname: string;
  childNode: TJSONData;
  factory: TFactory;
begin
  result := False;
  if node = nil then
    exit;
  if info = nil then
  begin
    Count := GetPropList(AObject.ClassInfo, tkAny, nil);
    Size := Count * SizeOf(Pointer);
    GetMem(PList, Size);
    GetPropList(AObject.ClassInfo, tkAny, PList);
    try
      for idx := 0 to Count - 1 do
      begin
        try
          pname := PList^[idx]^.Name;
          childNode := TJSONObject(node).Find(pname);
          if childNode = nil then
          begin
            pname := camelCase(PList^[idx]^.Name);
            childNode := TJSONObject(node).Find(pname);
          end;
          if childNode = nil then
          begin
            pname := selectorCase(PList^[idx]^.Name);
            childNode := TJSONObject(node).Find(pname);
          end;
          if childNode = nil then
          begin
            pname := pascalCase(PList^[idx]^.Name);
            childNode := TJSONObject(node).Find(pname);
          end;
          getHandlers(PList^[idx]^.PropType^.Kind, handlers);
          for h in handlers do
          begin
            if h.parse(AObject, PList^[idx], childNode) then
              break;
          end;
        finally
          FreeAndNil(handlers);
        end;
      end;
    finally
      FreeMem(PList);
    end;
    result := True;
  end
  else
  begin
    AnObject := GetObjectProp(AObject, Info^.Name);
    if anObject = nil then
    begin
      clz := GetJSONClass(info^.PropType^.Name);
      factory := GetJSONFactory(info^.PropType^.Name);
      if clz <> nil then
        anObject := factory(clz);
    end;
    if anObject <> nil then
    begin
      getHandlers(info^.PropType^.Kind, handlers);
      for h in handlers do
        if h.parse(anObject, nil, node) then
        begin
          Result := True;
          SetObjectProp(aObject, info, anObject);
          break;
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
  result := False;
  if AObject = nil then
  begin
    res := CreateJSON;
    Result := True;
  end
  else
  if info = nil then
  begin
    //Writeln(AObject.ClassName);
    Res := TJSONObject.Create;
    stringifyPropertyList(AObject, Res);
    result := True;
  end
  else
  begin
    propObject := GetObjectProp(AObject, Info^.Name);
    if propObject <> nil then
    begin
      getHandlers(Info^.PropType^.Kind, handlers);
      for h in handlers do
      begin
        if h.stringify(propObject, nil, childNode) then
          break;
      end;
      handlers.Free;
      res := childNode;
    end
    else
      res := CreateJSON;
    result := True;
  end;
end;


{ TJSONTypeHandlerHolder }

procedure TJSONTypeHandlerHolder.SetHandler(AValue: TJsonTypeHandler);
begin
  if FHandler = AValue then
    Exit;
  FHandler := AValue;
end;

procedure TJSONTypeHandlerHolder.SetKind(AValue: TTypeKind);
begin
  if FKind = AValue then
    Exit;
  FKind := AValue;
end;

destructor TJSONTypeHandlerHolder.Destroy;
begin
  FHandler.Free;
  inherited Destroy;
end;

{ TJSON }

function TJSON3.parse(source: TJSONStringType; clz: TClass): TObject;
var
  jsonData: TJSONData;
  factory: TFactory;
  handlers: THandlerList;
  h: TJsonTypeHandler;
begin
  jsonData := GetJSON(source, True);
  try
    factory := GetJSONFactory(clz.ClassName);
    result := factory(clz);
    if (result = nil) then
      raise EFactoryFailure.Create(clz.ClassName);

    getHandlers(tkObject, handlers);
    for h in handlers do
    begin
      if h.parse(Result, nil, jsonData) then
        break;
    end;
    handlers.Free;
    jsonData.Free;
  except
    if result <> nil then
      result.FreeInstance;
  end;
end;

function TJSON3.stringify(const obj: TObject; FormatOptions: TFormatOptions): TJSONStringType;
var
  jsonData: TJSONData = nil;
  handlers: THandlerList;
  h: TJsonTypeHandler;
begin
  try
    getHandlers(tkObject, handlers);
    for h in handlers do
    begin
      if h.stringify(obj, nil, jsonData) then
        break;
    end;
    handlers.Free;
    if jsonData = nil then
    begin
      getHandlers(tkClass, handlers);
      for h in handlers do
      begin
        if h.stringify(obj, nil, jsonData) then
          break;
      end;
      handlers.Free;
    end;
    if jsonData <> nil then
      result := jsonData.FormatJSON(FormatOptions)
    else
      result := 'null';
  finally
    try
      if jsonData <> nil then
        jsonData.Free;
    except
      on e: Exception do
        //Writeln(e.message);
    end;
  end;
end;

initialization
  InitCriticalSection(ClassCS);
  JSON := TJSON3.Create;
  Registry := TJSONTypeRegistry.Create();
  ClassList := TClassList.Create;
  RegisterJsonTypeHandler(tkObject, TJSONObjectTypeHandler.Create);
  RegisterJsonTypeHandler(tkClass, TJSONObjectTypeHandler.Create);
  RegisterJsonTypeHandler(tkInt64, TJSONIntegerTypeHandle.Create);
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


finalization;
  ClassList.Free;
  Registry.Free;
  JSON.Free;
  DoneCriticalsection(ClassCS);

end.
