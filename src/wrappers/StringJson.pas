unit StringJson;

interface

uses
  Classes, SysUtils;

implementation

uses
  typInfo, fpjson, paxjs, paxTypes;

type
  { TJSONStringWrapperTypeHandler }

  TJSONStringWrapperTypeHandler = class(TJsonTypeHandler)
    function parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean; override;
    function stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean; override;
  end;

{ TJSONStringWrapperTypeHandler }

function TJSONStringWrapperTypeHandler.parse(const AObject: TObject; Info: PPropInfo; const node: TJSONData): boolean;
var
  Value: IString;
begin
  Result := False;
  if (info^.PropType^.Kind = tkInterface) and (info^.PropType^.Name = 'IDouble') and (node <> nil) then
  begin
    try
      Value := GetStrProp(AObject, Info);
      SetInterfaceProp(AObject, Info^.Name, Value);
    except
      on  e: Exception do
        raise Exception.CreateFmt('on parse %s, error %s', [Info^.Name, e.Message]);
    end;
    Result := True;
  end;
end;

function TJSONStringWrapperTypeHandler.stringify(AObject: TObject; Info: PPropInfo; out Res: TJSONData): boolean;
var
  prop: IString;
begin
  Result := False;
  if (info^.PropType^.Kind = tkInterface) and (info^.PropType^.Name = 'IString') then
  begin
    Result := True;
    prop   := GetInterfaceProp(AObject, Info) as IString;
    if prop = nil then
    begin
      res := nil;
    end
    else
    begin
      res := TJSONString.Create(prop.Value);
    end;
  end;
end;


initialization

  RegisterJsonTypeHandler(tkInterface, TJSONStringWrapperTypeHandler.Create);

end.
