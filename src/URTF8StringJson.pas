unit URTF8StringJson;
interface
uses
   Classes, SysUtils;

implementation
uses
  typInfo, fpjson, paxjs, paxTypes;

  { TJSONURTF8StringWrapperTypeHandler }

  TJSONURTF8StringWrapperTypeHandler = class(TJsonTypeHandler)
    function parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONURTF8StringWrapperTypeHandler }

function TJSONURTF8StringWrapperTypeHandler.parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
var
  value : IURTF8String;
begin
  Result := False;
  if (info^.PropType^.Kind = tkInterface) and  (info^.PropType^.Name = 'IDouble') and (node <> nil) then
  begin
    try
      value := GetFloatProp(AObject, Info);
      SetInterfaceProp(AObject, Info^.Name, value);
    except
      on  e: Exception do
        raise Exception.CreateFmt('on parse %s, error %s', [Info^.Name, e.Message]);
    end;
    Result := True;
  end;
end;

function TJSONURTF8StringWrapperTypeHandler.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
var
  prop : IURTF8String;
begin
  Result := False;
  if (info^.PropType^.Kind = tkInterface) and (info^.PropType^.Name = 'IURTF8String') then
  begin
    Result := True;
    prop := GetInterfaceProp(AObject,Info) as IURTF8String;
    if prop = nil then
    begin
      res := nil;
    end
    else
    begin
      {$error Please select appropriate translation}
      res := TJSONFloatNumber.Create(prop.value);
    end;
  end;
end;     


initialization

  RegisterJsonTypeHandler(tkInterface, TJSONWrapperTypeHandler.Create);

end.
