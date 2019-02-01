unit test_minimal_objects;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry, test_om;

type
  { TTestMinimalObjects }

  TTestMinimalObjects = class(TTestCase)
  protected
    FTestObject: TMinimalObject;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestParse1;
    procedure TestParse2;
    procedure TestParse3;
    procedure TestStringify1;
    procedure TestStringify2;
    procedure TestStringify3;
  end;

implementation

uses
  paxjs;

procedure TTestMinimalObjects.SetUp;
begin
  RegisterJSONClass(TMinimalObject);
  inherited SetUp;
end;

procedure TTestMinimalObjects.TearDown;
begin
  UnRegisterJSONClass(TMinimalObject);
  inherited TearDown;
end;

procedure TTestMinimalObjects.TestParse1;
begin
  FTestObject := JSON.parse('{aProperty: 1}', TMinimalObject) as TMinimalObject;
  AssertEquals('Parse:1::1', 1, FTestObject.aProperty);
  FreeAndNil(FTestObject);
end;

procedure TTestMinimalObjects.TestParse2;
begin
  FTestObject := JSON.parse('{aProperty: 100}', TMinimalObject) as TMinimalObject;
  AssertEquals('Parse: 100::100', 100, FTestObject.aProperty);
  FreeAndNil(FTestObject);
end;

procedure TTestMinimalObjects.TestParse3;
begin
  FTestObject := JSON.parse('{aProperty: 65536}', TMinimalObject) as TMinimalObject;
  AssertEquals('Parse: 65536::65536', 65536, FTestObject.aProperty);
  FreeAndNil(FTestObject);
end;

procedure TTestMinimalObjects.TestStringify1;
begin
  FTestObject := TMinimalObject.Create;
  FTestObject.aProperty := 1000;
  AssertEquals('Parse: 1000', '{"aProperty":1000}', JSON.stringify(FTestObject));
  FreeAndNil(FTestObject);
end;

procedure TTestMinimalObjects.TestStringify2;
begin
  FTestObject := TMinimalObject.Create;
  FTestObject.aProperty := MaxInt;
  AssertEquals('Parse: ' + MaxInt.ToString + '', '{"aProperty":' + MaxInt.ToString + '}', JSON.stringify(FTestObject));
  FreeAndNil(FTestObject);
end;

procedure TTestMinimalObjects.TestStringify3;
begin
  FTestObject := TMinimalObject.Create;
  FTestObject.aProperty := -2147483648;
  AssertEquals('Parse:  ' + FTestObject.aProperty.ToString, '{"aProperty":' + FTestObject.aProperty.ToString + '}', JSON.stringify(FTestObject));
  FreeAndNil(FTestObject);
end;


initialization
  RegisterTest(TTestMinimalObjects);
end.


