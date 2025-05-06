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

implementation

procedure ClearInput();
begin
  while (TConsole.IsKeyPressed(VK_ESC) = True) or (TConsole.IsKeyPressed(Ord('S')) = True) do
  begin
    TConsole.ProcessMessages();
  end;
  TConsole.ClearKeyStates();
end;

end.
