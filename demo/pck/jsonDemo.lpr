program jsonDemo;

           {$macro on}
{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Classes,
  SysUtils,
  omtest,
  CustApp,
  demoApp;

var
  Application: TJSONDemo;

{$R *.res}

begin
  writeln('FPC_FULLVERSION ', FPC_FULLVERSION);
  writeln('FPC_VERSION     ', FPC_VERSION);
  writeln('FPC_RELEASE     ', FPC_RELEASE);
  writeln('FPC_PATCH       ', FPC_PATCH);
  Application := TJSONDemo.Create(nil);
  Application.Title:='JSON Demo';
  Application.Run;
  Application.Free;
end.
