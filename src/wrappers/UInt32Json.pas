unit UInt32Json;
interface
uses
   Classes, SysUtils;
                             
implementation
uses
  typInfo, fpjson, paxjs, paxTypes;
type
  { TJSONUInt32WrapperTypeHandler }

  TJSONUInt32WrapperTypeHandler = class(TJsonTypeHandler)
    function parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONUInt32WrapperTypeHandler }

function TJSONUInt32WrapperTypeHandler.parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
var
  value : IUInt32;
begin
  Result := False;
  if (info^.PropType^.Kind = tkInterface) and  (info^.PropType^.Name = 'IDouble') and (node <> nil) then
  begin
    try
      value := GetOrdProp(AObject, Info);
      SetInterfaceProp(AObject, Info^.Name, value);
    except
      on  e: Exception do
        raise Exception.CreateFmt('on parse %s, error %s', [Info^.Name, e.Message]);
    end;
    Result := True;
  end;
end;

function TJSONUInt32WrapperTypeHandler.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
var
  prop : IUInt32;
begin
  Result := False;
  if (info^.PropType^.Kind = tkInterface) and (info^.PropType^.Name = 'IUInt32') then
  begin
    Result := True;
    prop := GetInterfaceProp(AObject,Info) as IUInt32;
    if prop = nil then
    begin
      res := nil;
    end
    else
    begin
      res := TJSONIntegerNumber.Create(prop.value);
    end;
  end;
end;     


initialization

  RegisterJsonTypeHandler(tkInterface, TJSONUInt32WrapperTypeHandler.Create);

end.
