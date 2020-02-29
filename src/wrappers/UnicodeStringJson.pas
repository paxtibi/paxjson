unit UnicodeStringJson;
interface
uses
   Classes, SysUtils;
                             
implementation
uses
  typInfo, fpjson, paxjs, paxTypes;
type
  { TJSONUnicodeStringWrapperTypeHandler }

  TJSONUnicodeStringWrapperTypeHandler = class(TJsonTypeHandler)
    function parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONUnicodeStringWrapperTypeHandler }

function TJSONUnicodeStringWrapperTypeHandler.parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
var
  value : IUnicodeString;
begin
  Result := False;
  if (info^.PropType^.Kind = tkInterface) and  (info^.PropType^.Name = 'IUnicodeString') and (node <> nil) then
  begin
    try
      value := GetUnicodeStrProp(AObject, Info);
      SetInterfaceProp(AObject, Info^.Name, value);
    except
      on  e: Exception do
        raise Exception.CreateFmt('on parse %s, error %s', [Info^.Name, e.Message]);
    end;
    Result := True;
  end;
end;

function TJSONUnicodeStringWrapperTypeHandler.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
var
  prop : IUnicodeString;
begin
  Result := False;
  if (info^.PropType^.Kind = tkInterface) and (info^.PropType^.Name = 'IUnicodeString') then
  begin
    Result := True;
    prop := GetInterfaceProp(AObject,Info) as IUnicodeString;
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

  RegisterJsonTypeHandler(tkInterface, TJSONUnicodeStringWrapperTypeHandler.Create);

end.
