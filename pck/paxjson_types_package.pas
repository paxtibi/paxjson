{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit paxjson_types_package;

{$warn 5023 off : no warning about unused units}
interface

uses
  AnsiStringJson, BooleanJson, ByteJson, CardinalJson, CompJson, CurrencyJson, 
  DoubleJson, DWordJson, ExtendedJson, Int8Json, Int16Json, Int32Json, 
  Int64Json, IntegerJson, LongIntJson, LongWordJson, NativeIntJson, 
  NativeUIntJson, QWordJson, RawByteStringJson, RealJson, ShortIntJson, 
  SingleJson, SmallIntJson, StringJson, UInt8Json, UInt16Json, UInt32Json, 
  UInt64Json, UnicodeStringJson, UTF8StringJson, WideStringJson, WordJson, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('paxjson_types_package', @Register);
end.
