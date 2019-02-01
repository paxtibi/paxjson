unit test_simple_objects;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry;

type

  TTestSimpleObjects = class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestHookUp;
  end;

implementation

procedure TTestSimpleObjects.TestHookUp;
begin
  AssertEquals('Skip', True, True);
end;

procedure TTestSimpleObjects.SetUp;
begin

end;

procedure TTestSimpleObjects.TearDown;
begin

end;

initialization

  RegisterTest(TTestSimpleObjects);
end.

