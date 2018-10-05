# PaxJson.pas
PaxJson.pas try to provide a 3rd version of json format specification (http://es5.github.io/#x15.9.1.15) 

# Class TJSON3
## Methods

### function parse(source: TJSONStringType; const clz: TClass): TObject; overload;

This function try to translate a string into instance of a class. Use standard fpjson as parser of string. 
The parser function use a registry for classes to be instantiate autonomous. 

### function stringify(const obj: TObject): TJSONStringType;
This function translate an object into it's string representation.

## Utilities

### procedure RegisterJsonTypeHandler(typeKind: TTypeKind; anHandler: TJsonTypeHandler);
Register a new global handler type.

### procedure RegisterJSONClass(aClass: TClass);
Register a class for parser method

### function GetJSONClass(const AClassName: string): TClass;
Find a class by name on the registry. 

### function camelCase(aString: string): string;
Translate a string in camel case. eg "camelCase" 

### function pascalCase(aString: string): string;
Translate a string in pascal case. eg "PascalCase". 

### function selectorCase(aString: string): string;   
Translate a string in "selector case". css libraries such as Bootstrap.css use "-" to separate single words.
