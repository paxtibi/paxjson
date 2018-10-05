program jsonDemo;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Classes,
  SysUtils,
  omtest,
  paxjs,
  CustApp { you can add units after this };

type

  { TJSONDemo }

  TJSONDemo = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

  { TJSONDemo }

  procedure TJSONDemo.DoRun;
  var
    so: TSimpleObject;
    co: TComplexObject;
  begin
    Writeln(selectorCase('thisIsATry'));
    Writeln(pascalCase('thisIsATry'));
    Writeln(camelCase('ThisIsATry'));
    so := JSON.parse('{propertyInteger:10, propertyString:"Ciao", propertyFloat:10.6, returnCodes:["10","20"]}', TSimpleObject) as TSimpleObject;
    co := JSON.parse('{ EnumProperty : "enum2", SimpleObject : {"property-integer":10, "property-string":"Ciao", PropertyFloat:10.6}}', TComplexObject) as TComplexObject;
    writeln(co.ToString);
    co.SimpleObject.Free;
    co.SimpleObject := JSON.parse(JSON.stringify(so), TSimpleObject) as TSimpleObject;
    Writeln(JSON.stringify(co.SimpleObject));
    FreeAndNil(co);
    FreeAndNil(so);
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

var
  Application: TJSONDemo;

{$R *.res}

begin
  Application := TJSONDemo.Create(nil);
  Application.Title := 'JSON Demo';
  Application.Run;
  Application.Free;
end.

