unit test_om;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fgl;

type
  TDynIntegerArray = array of integer;

  { TMinimalObject }

  TMinimalObject = class(TObject)
  private
    FaProperty: integer;
    procedure SetaProperty(AValue: integer);
  published
    property aProperty: integer read FaProperty write SetaProperty;
  end;

  { TSimpleObject }

  TSimpleObject = class(TObject)
  private
    FLastUpdate: TDateTime;
    FPropertyFloat: single;
    FPropertyInteger: integer;
    FPropertyString: string;
    FreturnCodes: TStringArray;
    FreturnValues: TDynIntegerArray;
    function GetReturnCodes: TStringArray;
    procedure SetlastUpdate(AValue: TDateTime);
    procedure SetPropertyFloat(AValue: single);
    procedure SetPropertyInteger(AValue: integer);
    procedure SetPropertyString(AValue: string);
    procedure SetreturnCodes(AValue: TStringArray);
    procedure SetreturnValues(AValue: TDynIntegerArray);
  public
    constructor Create;
    function ToString: ansistring; override;
  published
    property PropertyString: string read FPropertyString write SetPropertyString;
    property PropertyInteger: integer read FPropertyInteger write SetPropertyInteger;
    property PropertyFloat: single read FPropertyFloat write SetPropertyFloat;
    property returnCodes: TStringArray read FReturnCodes write SetReturnCodes;
    property returnValues: TDynIntegerArray read FreturnValues write SetreturnValues;
    property lastUpdate: TDateTime read FlastUpdate write SetlastUpdate;
  end;

  TMinimalObjectList = specialize TFPGObjectList<TMinimalObject>;

  { TSimpleObjectListContainer }

  TSimpleObjectListContainer = class
  private
    FList: TMinimalObjectList;
    procedure SetList(AValue: TMinimalObjectList);
  published
    property List: TMinimalObjectList read FList write SetList;
  end;

  TEnumProperty = (enum1, enum2, enum3);

  { TComplexObject }

  TComplexObject = class(TObject)
  private
    FMinimalObjectList: TMinimalObjectList;
    FSimpleObject: TSimpleObject;
    FEnumProperty: TEnumProperty;
    FStrings: TStringList;
    procedure SetMinimalObjectList(AValue: TMinimalObjectList);
    procedure SetSimpleObject(AValue: TSimpleObject);
    procedure SetEnumProperty(AValue: TEnumProperty);
    procedure SetStrings(AValue: TStringList);
  public
    function ToString: ansistring; override;
    constructor Create;
    destructor Destroy; override;
  published
    property SimpleObject: TSimpleObject read FSimpleObject write SetSimpleObject;
    property EnumProperty: TEnumProperty read FEnumProperty write SetEnumProperty;
    property MinimalObjectList: TMinimalObjectList read FMinimalObjectList write SetMinimalObjectList;
    property Strings: TStringList read FStrings write SetStrings;
  end;

  { TACollectionItem }

  TACollectionItem = class(TCollectionItem)
  private
    FaProperty: integer;
    procedure SetAProperty(AValue: integer);
  public
    constructor Create(ACollection: TCollection); override;
  published
    property aProperty: integer read FaProperty write SetAProperty;
  end;

  { TACollection }

  TACollection = class(TCollection)
  public
    constructor Create; reintroduce;
    function Add: TCollectionItem;
  end;

implementation

uses
  paxjs, typinfo;

{ TSimpleObjectListContainer }

procedure TSimpleObjectListContainer.SetList(AValue: TMinimalObjectList);
begin
  if FList = AValue then
  begin
    Exit;
  end;
  FList := AValue;
end;

{ TMinimalObject }

procedure TMinimalObject.SetaProperty(AValue: integer);
begin
  if FaProperty = AValue then
  begin
    Exit;
  end;
  FaProperty := AValue;
end;

{ TACollectionItem }

procedure TACollectionItem.SetAProperty(AValue: integer);
begin
  if FaProperty = AValue then
  begin
    Exit;
  end;
  FaProperty := AValue;
end;

constructor TACollectionItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FaProperty := ID;
end;

{ TACollection }

constructor TACollection.Create;
begin
  inherited Create(TACollectionItem);
end;

function TACollection.Add: TCollectionItem;
begin
  Result := inherited Add;
end;


{ TComplexObject }

procedure TComplexObject.SetSimpleObject(AValue: TSimpleObject);
begin
  if FSimpleObject = AValue then
  begin
    Exit;
  end;
  FSimpleObject := AValue;
end;

procedure TComplexObject.SetMinimalObjectList(AValue: TMinimalObjectList);
begin
  if FMinimalObjectList = AValue then
  begin
    Exit;
  end;
  FMinimalObjectList := AValue;
end;

procedure TComplexObject.SetEnumProperty(AValue: TEnumProperty);
begin
  if FEnumProperty = AValue then
  begin
    Exit;
  end;
  FEnumProperty := AValue;
end;

procedure TComplexObject.SetStrings(AValue: TStringList);
begin
  if FStrings = AValue then
  begin
    Exit;
  end;
  FStrings := AValue;
end;

function TComplexObject.ToString: ansistring;
begin
  result := JSON.stringify(Self);
end;

constructor TComplexObject.Create;
begin
  FStrings := nil;
end;

destructor TComplexObject.Destroy;
begin
  FreeAndNil(FStrings);
  inherited Destroy;
end;

{ TSimpleObject }

procedure TSimpleObject.SetPropertyString(AValue: string);
begin
  if FPropertyString = AValue then
  begin
    Exit;
  end;
  FPropertyString := AValue;
end;

procedure TSimpleObject.SetreturnCodes(AValue: TStringArray);
begin
  if FreturnCodes = AValue then
  begin
    Exit;
  end;
  FreturnCodes := AValue;
end;

procedure TSimpleObject.SetreturnValues(AValue: TDynIntegerArray);
begin
  if FreturnValues = AValue then
  begin
    Exit;
  end;
  FreturnValues := AValue;
end;

constructor TSimpleObject.Create;
begin
  SetLength(FreturnCodes, 0);
  setlength(FreturnValues, 0);
  FlastUpdate := Now;
end;

function TSimpleObject.ToString: ansistring;
begin
  result := JSON.stringify(Self);
end;

procedure TSimpleObject.SetPropertyInteger(AValue: integer);
begin
  if FPropertyInteger = AValue then
  begin
    Exit;
  end;
  FPropertyInteger := AValue;
end;

procedure TSimpleObject.SetPropertyFloat(AValue: single);
begin
  if FpropertyFloat = AValue then
  begin
    Exit;
  end;
  FpropertyFloat := AValue;
end;

function TSimpleObject.GetReturnCodes: TStringArray;
begin
  result := FreturnCodes;
end;

procedure TSimpleObject.SetlastUpdate(AValue: TDateTime);
begin
  if FlastUpdate = AValue then
  begin
    Exit;
  end;
  FlastUpdate := AValue;
end;

initialization


end.
