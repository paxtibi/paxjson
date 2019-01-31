unit test_casefunctions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry;

type

  { TCaseFunctionTest }

  TCaseFunctionTest = class(TTestCase)
  private
  published
    procedure TestSelectorCase1;
    procedure TestSelectorCase2;
    procedure TestSelectorCase3;
    procedure TestSelectorCase4;
    procedure TestPascalCase1;
    procedure TestPascalCase2;
    procedure TestPascalCase3;
    procedure TestCamelCase1;
    procedure TestCamelCase2;
    procedure TestcamelCase3;
  end;

implementation

uses
  paxjs;

procedure TCaseFunctionTest.TestSelectorCase1;
begin
  AssertEquals('selectorCase ', selectorCase('ThisIsATry'), 'this-is-a-try');
end;

procedure TCaseFunctionTest.TestSelectorCase2;
begin
  AssertEquals('selectorCase ', selectorCase('thisIsATry'), 'this-is-a-try');
end;

procedure TCaseFunctionTest.TestSelectorCase3;
begin
  AssertEquals('selectorCase ', selectorCase('aSimpleTest'), 'a-simple-test');
end;

procedure TCaseFunctionTest.TestSelectorCase4;
begin
  AssertEquals('selectorCase ', selectorCase('A SimpleTest'), 'a-simple-test');
end;

procedure TCaseFunctionTest.TestPascalCase1;
begin
  AssertEquals('pascalCase ', pascalCase('ThisIsATry'), 'ThisIsATry');
end;

procedure TCaseFunctionTest.TestPascalCase2;
begin
  AssertEquals('pascalCase ', pascalCase('this IsATry'), 'ThisIsATry');
end;

procedure TCaseFunctionTest.TestPascalCase3;
begin
  AssertEquals('pascalCase ', pascalCase('aSimpleTest'), 'ASimpleTest');
end;

procedure TCaseFunctionTest.TestCamelCase1;
begin
  AssertEquals('camelCase ', camelCase('aSimpleTest'), 'aSimpleTest');
end;

procedure TCaseFunctionTest.TestCamelCase2;
begin
  AssertEquals('camelCase ', camelCase('ASimpleTest'), 'aSimpleTest');
end;

procedure TCaseFunctionTest.TestcamelCase3;
begin
  AssertEquals('camelCase ', camelCase('A SimpleTest'), 'aSimpleTest');
end;


initialization

  RegisterTest(TCaseFunctionTest);
end.

