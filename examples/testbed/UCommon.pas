{===============================================================================
    ___                  _
   / __|___ _ _  ___ ___| |___™
  | (__/ _ \ ' \(_-</ _ \ / -_)
   \___\___/_||_/__/\___/_\___|
       Delphi CSI Console

 Copyright © 2025-present tinyBigGAMES™ LLC
 All Rights Reserved.

 https://github.com/tinyBigGAMES/Console

 See LICENSE file for license information
===============================================================================}

unit UCommon;

interface

uses
  System.SysUtils,
  Console;

procedure ClearInput();
function  IfThen(const Condition: Boolean; const TrueValue, FalseValue: string): string;

implementation

procedure ClearInput();
begin
  while (TConsole.IsKeyPressed(VK_ESC) = True) or (TConsole.IsKeyPressed(Ord('S')) = True) do
  begin
    TConsole.ProcessMessages();
  end;
  TConsole.ClearKeyStates();
end;

function IfThen(const Condition: Boolean; const TrueValue, FalseValue: string): string;
begin
  if Condition then
    Result := TrueValue
  else
    Result := FalseValue;
end;

end.
