unit CompJson;
interface
uses
   Classes, SysUtils;
                             
implementation
uses
  typInfo, fpjson, paxjs, paxTypes;
type
  { TJSONCompWrapperTypeHandler }

  TJSONCompWrapperTypeHandler = class(TJsonTypeHandler)
    function parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONCompWrapperTypeHandler }

function TJSONCompWrapperTypeHandler.parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
var
  value : IComp;
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

function TJSONCompWrapperTypeHandler.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
var
  prop : IComp;
begin
  Result := False;
  if (info^.PropType^.Kind = tkInterface) and (info^.PropType^.Name = 'IComp') then
  begin
    Result := True;
    prop := GetInterfaceProp(AObject,Info) as IComp;
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

  RegisterJsonTypeHandler(tkInterface, TJSONCompWrapperTypeHandler.Create);

end.
