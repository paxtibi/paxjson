unit DoubleJson;

interface

uses
  Classes, SysUtils;

implementation

uses
  typInfo, fpjson, paxjs, paxTypes;

type
  { TJSONDoubleWrapperTypeHandler }

  TJSONDoubleWrapperTypeHandler = class(TJsonTypeHandler)
    function parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

{ TJSONDoubleWrapperTypeHandler }

function TJSONDoubleWrapperTypeHandler.parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
var
  Value: IDouble;
begin
  Result := False;
  if (info^.PropType^.Kind = tkInterface) and (info^.PropType^.Name = 'IDouble') and (node <> nil) then
  begin
    try
      Value := node.AsFloat;
      SetInterfaceProp(AObject, Info^.Name, Value);
    except
      on  e: Exception do
        raise Exception.CreateFmt('on parse %s, error %s', [Info^.Name, e.Message]);
    end;
    Result := True;
  end;
end;

function TJSONDoubleWrapperTypeHandler.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
var
  prop: IDouble;
begin
  Result := False;
  if (info^.PropType^.Kind = tkInterface) and (info^.PropType^.Name = 'IDouble') then
  begin
    Result := True;
    prop := GetInterfaceProp(AObject, Info) as IDouble;
    if prop = nil then
    begin
      res := nil;
    end
    else
    begin
      res := TJSONFloatNumber.Create(prop.Value);
    end;
  end;
end;


initialization

  RegisterJsonTypeHandler(tkInterface, TJSONDoubleWrapperTypeHandler.Create);

end.
