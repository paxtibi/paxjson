unit demoApp;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, CustApp, omtest;

type
  { TJSONDemo }

  TJSONDemo = class(TCustomApplication)
  protected
    procedure DoListParse;
    procedure DoListStringify;
    procedure DoCollectionStringify;
    procedure DoCollectionParse;
    procedure DoComplexObjectStringify;
    procedure DoComplexObjectParse;
    procedure DoSimpleObjectStringify;
    procedure DoSimpleObjectParse;
    procedure DoCaseFunctions;
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

implementation

uses
  paxjs, paxjsgl, typinfo;

const
  SimpleObjectJSONString = '{propertyFloat: 1.0,PropertyInteger:2,PropertyString:"3",lastUpdate:"2018-01-01T00:00:00",returnCodes:["4","5"],returnValues:[6,7]}';
  ComplexObjectJSONString = '{"EnumProperty":"enum2","SimpleObject":' + SimpleObjectJSONString + '}';
  CollectionJSONString = '[{"aProperty":10},{"aProperty":11},{"aProperty":12},{"aProperty":13},{"aProperty":14}]';
  GenericListJSONString = '[{"aProperty":1},{"aProperty":2},{"aProperty":3},{"aProperty":4},{"aProperty":50}]';


type
  TMinimalObjectListTypeHandle = specialize TGenericListTypeHandle<TMinimalObjectList, TMinimalObject>;

function ACollectionFactory(aClass: TClass): TObject;
begin
  result := nil;
  if aClass = TACollection then
  begin
    result := TACollection.Create;
  end;
end;

function MinimalObjectListFactory(aClass: TClass): TObject;
begin
  result := nil;
  if aClass = TMinimalObjectList then
  begin
    result := TMinimalObjectList.Create(True);
  end;
end;

{ TJSONDemo }

procedure TJSONDemo.DoListParse;
var
  list: TMinimalObjectList;
begin
  list := JSON.parse(GenericListJSONString, TMinimalObjectList) as TMinimalObjectList;
  Writeln('DoListParse ': 50, JSON.stringify(list));
  list.Free;
end;

procedure TJSONDemo.DoListStringify;
var
  list: TMinimalObjectList;
begin
  list := TMinimalObjectList.Create(True);
  list.Add(TMinimalObject.Create);
  list.Add(TMinimalObject.Create);
  list.Add(TMinimalObject.Create);
  list[0].aProperty := 100;
  list[1].aProperty := 200;
  list[2].aProperty := 300;
  Writeln('DoListStringify ': 50, JSON.stringify(list));
  list.Free;
end;

procedure TJSONDemo.DoCollectionStringify;
var
  idx: integer;
  col: TACollection;
begin
  col := TACollection.Create;
  for idx := 0 to 4 do
  begin
    TACollectionItem(col.Add).aProperty := idx + 10;
  end;
  Writeln('DoCollectionStringify ': 50, JSON.stringify(col));
  col.Free;
end;

procedure TJSONDemo.DoCollectionParse;
var
  col: TACollection;
begin
  col := JSON.parse(CollectionJSONString, TACollection) as TACollection;
  Writeln('DoCollectionParse ': 50, JSON.stringify(col));
  if col <> nil then
    col.Free;
end;

procedure TJSONDemo.DoComplexObjectStringify;
var
  co: TComplexObject = nil;
  simpleObject: TSimpleObject;
begin
  co := TComplexObject.Create;
  simpleObject := JSON.parse(SimpleObjectJSONString, TSimpleObject) as TSimpleObject;
  co.SimpleObject := simpleObject;
  co.EnumProperty := enum2;
  Writeln('DoComplexObjectStringify ': 50, JSON.stringify(co));
  co.Free;
end;

procedure TJSONDemo.DoComplexObjectParse;
var
  co: TComplexObject = nil;
begin
  co := JSON.parse(ComplexObjectJSONString, TComplexObject) as TComplexObject;
  Writeln('DoComplexObjectParse ': 50, JSON.stringify(co));
  co.Free;
end;

procedure TJSONDemo.DoSimpleObjectStringify;
var
  so: TSimpleObject = nil;
  sa: TStringArray;
  ia: TDynIntegerArray;
begin
  SetLength(sa, 2);
  SetLength(ia, 2);
  sa[0] := '4';
  sa[1] := '5';
  ia[0] := 6;
  ia[1] := 7;
  so := TSimpleObject.Create;
  so.PropertyFloat := 1.0;
  so.PropertyInteger := 2;
  so.PropertyString := '3';
  so.returnCodes := sa;
  so.returnValues := ia;
  writeln('DoSimpleObjectStringify ': 50, JSON.stringify(so));
  so.Free;
end;

procedure TJSONDemo.DoSimpleObjectParse;
var
  so: TSimpleObject = nil;
begin
  so := JSON.parse(SimpleObjectJSONString, TSimpleObject) as TSimpleObject;
  writeln('DoSimpleObjectParse ': 50, JSON.stringify(so));
  so.Free;
end;

procedure TJSONDemo.DoCaseFunctions;
begin
  Writeln(selectorCase('thisIsATry'));
  Writeln(pascalCase('thisIsATry'));
  Writeln(camelCase('ThisIsATry'));
end;

procedure TJSONDemo.DoRun;
begin
  RegisterJSONClass(TSimpleObject);
  RegisterJSONClass(TMinimalObject);
  RegisterJSONClass(TComplexObject);
  RegisterJSONClass(TACollection, @ACollectionFactory);
  RegisterJSONClass(TMinimalObjectList, @MinimalObjectListFactory);
  RegisterJsonTypeHandler(tkClass, TMinimalObjectListTypeHandle.Create);
  RegisterJsonTypeHandler(tkObject, TMinimalObjectListTypeHandle.Create);
  DoCaseFunctions;
  DoSimpleObjectStringify;
  DoSimpleObjectParse;
  DoComplexObjectStringify;
  DoComplexObjectParse;
  DoCollectionStringify;
  DoCollectionParse;
  DoListStringify;
  DoListParse;
  Terminate(0);
end;

constructor TJSONDemo.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException := True;
end;

destructor TJSONDemo.Destroy;
begin
  inherited Destroy;
end;

procedure TJSONDemo.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ', ExeName, ' -h');
end;


end.
