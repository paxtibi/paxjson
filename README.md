# PaxJson.pas
PaxJson.pas tries to provide a 3rd version of the json format specifications  (http://es5.github.io/#x15.9.1.15) 

# Class TJSON3
## Methods

### function parse(source: TJSONStringType; const clz: TClass): TObject; overload;

This function attempts to translate a string into an instance of a class. Use standard fpjson as a string parser. The parser function uses a register for classes that can be instantiated autonomously.

### function stringify(const obj: TObject): TJSONStringType;
This function translates an object into its string representation.

## Utilities

### procedure RegisterJsonTypeHandler(typeKind: TTypeKind; anHandler: TJsonTypeHandler);
Register a new type handler.

### procedure RegisterJSONClass(aClass: TClass);
Register a class for the parser method

### function GetJSONClass(const AClassName: string): TClass;
Find a class by name in the registry.

### function camelCase(aString: string): string;
Turn a string into a camel case. for example "CamelCase"

### function pascalCase(aString: string): string;
Translate a string in Pascal case. for example "PascalCase".

### function selectorCase(aString: string): string;   
Translate a string into "selector case". css libraries like Bootstrap.css use "-" to separate individual words. eg "selector-case".
