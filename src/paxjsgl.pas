unit paxjsgl;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, typinfo, paxjs, fgl, fpjson;

type

  { TGenericListTypeHandle }

  generic TGenericListTypeHandle <aType: TFPSList; aItemType: TObject> = class(TJsonTypeHandler)
  private
    type
     TCastContainerType = aType;
     TCastContainedType = aItemType;
  protected
    procedure parseType(aObject: aType; arrayNode: TJSONArray);
    procedure stringifyType(AObject: TCastContainerType; var Res: TJSONData);
  public
    function parse(AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

implementation

{ TGenericListTypeHandle }

procedure TGenericListTypeHandle.parseType(aObject: aType; arrayNode: TJSONArray);
var
  idx: integer;
  item: TCastContainedType;
  handlers: THandlerList;
  h: TJsonTypeHandler;
  factory: TFactory;
  childNode: TJSONData;
begin
  getHandlers(tkClass, handlers);
  factory := GetJSONFactory(TCastContainedType);

  for idx := 0 to arrayNode.Count - 1 do
  begin
    childNode := arrayNode[idx];
    item := factory(TCastContainedType) as TCastContainedType;
    for h in handlers do
    begin
      if h.parse(item, nil, childNode) then
      begin
        aObject.Add(item);
        break;
      end;
    end;
  end;
  handlers.Free;
end;

procedure TGenericListTypeHandle.stringifyType(AObject: TCastContainerType;
  var Res: TJSONData);
var
  idx: integer;
  item: TObject;
  childNode: TJSONData;
  handlers: THandlerList;
  h: TJSONTypeHandler;
begin
  Res := TJSONArray.Create;
  getHandlers(tkClass, handlers);
  for idx := 0 to TFPSList(aObject).count - 1 do
  begin
    item := TCastContainedType(aObject[idx]);
    for h in handlers do
    begin
      if h.stringify(item, nil, childNode) then
        break;
    end;
    if childNode <> nil then
      TJSONArray(res).Add(childNode);
  end;
  handlers.Free;
end;

function TGenericListTypeHandle.parse(AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
var
  clz: TClass;
  aList: aType;
begin
  result := False;
  if (Info = nil) and  (compareText(AObject.ClassName,TCastContainerType.className)=0) then
  begin
    parseType(TCastContainerType(AObject), node as TJSONArray);
    result := True;
  end
  else
  if (Info <> nil) and (compareText(AObject.ClassName,TCastContainerType.className)=0) and (Info^.PropType^.Kind in [tkClass, tkObject]) then
  begin
    clz := GetJSONClass(Info^.PropType^.Name);
    if clz.InheritsFrom(TCollection) then
    begin
      aList := TCastContainerType(GetObjectProp(AObject, Info));
      parseType(aList, node as TJSONArray);
      result := True;
    end;
  end;
end;

function TGenericListTypeHandle.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
var
  clz: TClass;
  aList: aType;
begin
  result := False;
  if (CompareText(AObject.ClassName, TCastContainerType.ClassName)=0) then
  begin
  if (Info = nil) then
  begin
    stringifyType(TCastContainerType(AObject), res);
    result := True;
  end
  else
  if (Info <> nil) then
  begin
    clz := GetJSONClass(Info^.PropType^.Name);
    if clz.InheritsFrom(TCollection) then
    begin
      aList := TCastContainerType(GetObjectProp(AObject, Info));
      stringifyType(aList, Res);
      result := True;
    end;
  end;
  end;
end;

end.



