unit LongWordJson;
interface
uses
   Classes, SysUtils;
                             
implementation
uses
  typInfo, fpjson, paxjs, paxTypes;
type
  { TJSONLongWordWrapperTypeHandler }

  TJSONLongWordWrapperTypeHandler = class(TJsonTypeHandler)
    function parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

  { TJSONLongWordWrapperTypeHandler }

function TJSONLongWordWrapperTypeHandler.parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
var
  value : ILongWord;
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

function TJSONLongWordWrapperTypeHandler.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
var
  prop : ILongWord;
begin
  Result := False;
  if (info^.PropType^.Kind = tkInterface) and (info^.PropType^.Name = 'ILongWord') then
  begin
    Result := True;
    prop := GetInterfaceProp(AObject,Info) as ILongWord;
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

  RegisterJsonTypeHandler(tkInterface, TJSONLongWordWrapperTypeHandler.Create);

end.
