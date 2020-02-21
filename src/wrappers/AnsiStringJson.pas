unit AnsiStringJson;
interface
uses
   Classes, SysUtils;
                             
implementation
uses
  typInfo, fpjson, paxjs, paxTypes;
type
  { TJSONAnsiStringWrapperTypeHandler }

  TJSONAnsiStringWrapperTypeHandler = class(TJsonTypeHandler)
    function parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONAnsiStringWrapperTypeHandler }

function TJSONAnsiStringWrapperTypeHandler.parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
var
  value : IAnsiString;
begin
  Result := False;
  if (info^.PropType^.Kind = tkInterface) and  (info^.PropType^.Name = 'IDouble') and (node <> nil) then
  begin
    try
      value := GetStrProp(AObject, Info);
      SetInterfaceProp(AObject, Info^.Name, value);
    except
      on  e: Exception do
        raise Exception.CreateFmt('on parse %s, error %s', [Info^.Name, e.Message]);
    end;
    Result := True;
  end;
end;

function TJSONAnsiStringWrapperTypeHandler.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
var
  prop : IAnsiString;
begin
  Result := False;
  if (info^.PropType^.Kind = tkInterface) and (info^.PropType^.Name = 'IAnsiString') then
  begin
    Result := True;
    prop := GetInterfaceProp(AObject,Info) as IAnsiString;
    if prop = nil then
    begin
      res := nil;
    end
    else
    begin
      res := TJSONString.Create(prop.value);
    end;
  end;
end;     


initialization

  RegisterJsonTypeHandler(tkInterface, TJSONAnsiStringWrapperTypeHandler.Create);

end.
