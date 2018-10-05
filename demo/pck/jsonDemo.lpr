program jsonDemo;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Classes,
  SysUtils,
  omtest,
  paxjs,
  CustApp { you can add units after this };

const
  SimpleObjectJSONString = '{propertyFloat: 1.0,PropertyInteger:2,PropertyString:"3",lastUpdate:"2018-01-01T00:00:00",returnCodes:["4","5"],returnValues:[6,7]}';
  ComplexObjectJSONString = '{"EnumProperty":"enum2","SimpleObject":' + SimpleObjectJSONString + '}';
  CollectionJSONString = '[{"APropery":10},{"APropery":11},{"APropery":12},{"APropery":13},{"APropery":14}]';

type
  { TJSONDemo }

  TJSONDemo = class(TCustomApplication)
  protected
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

  { TJSONDemo }

  procedure TJSONDemo.DoCollectionStringify;
  var
    idx: integer;
    col: TACollection;
  begin
    col := TACollection.Create;
    for idx := 0 to 4 do
    begin
      TACollectionItem(col.Add).APropery := idx + 10;
    end;
    Writeln(JSON.stringify(col));
    col.Free;
  end;

  procedure TJSONDemo.DoCollectionParse;
  var
    col: TACollection;
  begin
    col := JSON.parse(CollectionJSONString, TACollection) as TACollection;
    Writeln(JSON.stringify(col));
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
    Writeln(JSON.stringify(co));
    co.Free;
  end;

  procedure TJSONDemo.DoComplexObjectParse;
  var
    co: TComplexObject = nil;
  begin
    co := JSON.parse(ComplexObjectJSONString, TComplexObject) as TComplexObject;
    Writeln(JSON.stringify(co));
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
    writeln(JSON.stringify(so));
    so.Free;
  end;

  procedure TJSONDemo.DoSimpleObjectParse;
  var
    so: TSimpleObject = nil;
  begin
    so := JSON.parse(SimpleObjectJSONString, TSimpleObject) as TSimpleObject;
    writeln(JSON.stringify(so));
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
    RegisterJSONClass(TComplexObject);
    RegisterJSONClass(TACollection);
    DoCaseFunctions;
    DoSimpleObjectStringify;
    DoSimpleObjectParse;
    DoComplexObjectStringify;
    DoComplexObjectParse;
    DoCollectionStringify;
    DoCollectionParse;
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
