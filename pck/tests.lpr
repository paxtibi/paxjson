program tests;

{$mode objfpc}{$H+}

uses
  Classes,
  consoletestrunner,
  test_casefunctions, test_minimal_objects, test_simple_objects;

type

  { TMyTestRunner }

  TMyTestRunner = class(TTestRunner)
  protected
    // override the protected methods of TTestRunner to customize its behavior
  end;

var
  Application: TMyTestRunner;

begin
  Application := TMyTestRunner.Create(nil);
  Application.Initialize;
  Application.Run;
  Application.Free;
end.
