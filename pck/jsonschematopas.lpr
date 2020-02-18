program jsonschematopas;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Classes,
  SysUtils,
  fpjson,
  jsonparser,
  jsonscanner,
  CustApp;

type
  { TJSonSchema }

  TJSonSchema = class(TCustomApplication)
  protected
    FParser: TJSONParser;
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

  { TJSonSchema }

  procedure TJSonSchema.DoRun;
  var
    ErrorMsg: string;
    Data: TJSONData;
    sl: TStringList;
  begin
    // quick check parameters
    ErrorMsg := CheckOptions('h', 'help');
    if ErrorMsg <> '' then
    begin
      ShowException(Exception.Create(ErrorMsg));
      Terminate;
      Exit;
    end;

    // parse parameters
    if HasOption('h', 'help') then
    begin
      WriteHelp;
      Terminate;
      Exit;
    end;

    { add your program here }

    // stop program loop

    sl := TStringList.Create;
    sl.LoadFromFile(GetParams(1));
    FParser := TJSONParser.Create(sl.Text, [joUTF8, joComments, joIgnoreTrailingComma]);
    FreeAndNil(sl);
    Data := FParser.Parse;
    writeln(Data.FindPath('title').AsString);
    writeln(Data.FindPath('id').AsString);
    FreeAndNil(Data);
    FreeAndNil(FParser);
    Terminate;
  end;

  constructor TJSonSchema.Create(TheOwner: TComponent);
  begin
    inherited Create(TheOwner);
    StopOnException := True;
  end;

  destructor TJSonSchema.Destroy;
  begin
    inherited Destroy;
  end;

  procedure TJSonSchema.WriteHelp;
  begin
    { add your help code here }
    writeln('Usage: ', ExeName, ' -h');
  end;

var
  Application: TJSonSchema;
begin
  Application       := TJSonSchema.Create(nil);
  Application.Title := 'JSon Schema to pascal';
  Application.Run;
  Application.Free;
end.
