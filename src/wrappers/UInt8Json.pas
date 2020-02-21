unit UInt8Json;

interface

uses
  Classes, SysUtils;

implementation

uses
  typInfo, fpjson, paxjs, paxTypes;

type
  { TJSONUInt8WrapperTypeHandler }

  TJSONUInt8WrapperTypeHandler = class(TJsonTypeHandler)
    function parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

{ TJSONUInt8WrapperTypeHandler }

function TJSONUInt8WrapperTypeHandler.parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
var
  Value: IUInt8;
begin
  Result := False;
  if (info^.PropType^.Kind = tkInterface) and (info^.PropType^.Name = 'IDouble') and (node <> nil) then
  begin
    try
      Value := GetOrdProp(AObject, Info);
      SetInterfaceProp(AObject, Info^.Name, Value);
    except
      on  e: Exception do
        raise Exception.CreateFmt('on parse %s, error %s', [Info^.Name, e.Message]);
    end;
    Result := True;
  end;
end;

function TJSONUInt8WrapperTypeHandler.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
var
  prop: IUInt8;
begin
  Result := False;
  if (info^.PropType^.Kind = tkInterface) and (info^.PropType^.Name = 'IUInt8') then
  begin
    Result := True;
    prop   := GetInterfaceProp(AObject, Info) as IUInt8;
    if prop = nil then
    begin
      res := nil;
    end
    else
    begin
      res := TJSONInt64Number.Create(prop.Value);
    end;
  end;
end;


initialization

  RegisterJsonTypeHandler(tkInterface, TJSONUInt8WrapperTypeHandler.Create);

end.
