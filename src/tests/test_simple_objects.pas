unit test_simple_objects;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry, test_om;

const
  SimpleObjectJSONString = '{propertyFloat: 1.0,PropertyInteger:2,PropertyString:"3",lastUpdate:"2018-01-01T00:00:00",returnCodes:["4","5"],returnValues:[6,7]}';


type

  { TTestSimpleObjects }

  TTestSimpleObjects = class(TTestCase)
  protected
    FTestObject: TSimpleObject;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestParse1;
    procedure TestStringify1;
  end;

implementation

uses
  paxjs;

procedure TTestSimpleObjects.TestParse1;
var
  idx: integer;
const
  returnCodes: array [0..1] of string = ('4', '5');
  returnValues: array [0..1] of integer = (6, 7);
begin
  FTestObject := JSON.parse(SimpleObjectJSONString, TSimpleObject) as TSimpleObject;
  AssertEquals('lastUpdate', FTestObject.lastUpdate, ISO8601ToDate('2018-01-01T00:00:00'));
  AssertEquals('propertyFloat', FTestObject.PropertyFloat, 1.0);
  AssertEquals('PropertyInteger', FTestObject.PropertyInteger, 2);
  AssertEquals('PropertyString', FTestObject.PropertyString, '3');
  for idx := Low(returnCodes) to High(returnCodes) do
  begin
    AssertEquals('returnCodes', FTestObject.returnCodes[idx], returnCodes[idx]);
  end;
  for idx := Low(returnValues) to High(returnValues) do
  begin
    AssertEquals('returnValues', FTestObject.returnValues[idx], returnValues[idx]);
  end;
  FreeAndNil(FTestObject);
end;

procedure TTestSimpleObjects.TestStringify1;
const
  _returnCodes: array [0..1] of string = ('4', '5');
  _returnValues: array [0..1] of integer = (6, 7);
begin
  FTestObject := TSimpleObject.Create;
  with FTestObject do
  begin
    lastUpdate := ISO8601ToDate('2018-01-01T00:00:00');
    propertyFloat := 1.0;
    PropertyInteger := 2;
    PropertyString := '3';
    returnCodes := _returnCodes;
    returnValues := _returnValues;
  end;
  AssertEquals('Stringify', '{"PropertyFloat":' + FloatToStr(1.0) + ',"PropertyInteger":2,"PropertyString":"3","lastUpdate":"2018-01-01T00:00:00","returnCodes":["4","5"],"returnValues":[6,7]}', JSON.stringify(FTestObject));
  FreeAndNil(FTestObject);
end;

procedure TTestSimpleObjects.SetUp;
begin
  RegisterJSONClass(TSimpleObject);
end;

procedure TTestSimpleObjects.TearDown;
begin
  UnRegisterJSONClass(TSimpleObject);
end;

initialization

  RegisterTest(TTestSimpleObjects);
end.
