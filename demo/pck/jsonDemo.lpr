program jsonDemo;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Classes,
  SysUtils,
  omtest,
  paxjs,
  CustApp,
  demoApp;

var
  Application: TJSONDemo;

{$R *.res}

begin
  Application := TJSONDemo.Create(nil);
  Application.Title := 'JSON Demo';
  Application.Run;
  Application.Free;
end.
