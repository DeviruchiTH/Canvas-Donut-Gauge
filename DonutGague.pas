{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit DonutGague;

interface

uses
  rfDonutGauge, TyphonPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('rfDonutGauge', @rfDonutGauge.Register);
end;

initialization
  RegisterPackage('DonutGague', @Register);
end.
