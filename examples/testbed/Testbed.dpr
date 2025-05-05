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

program Testbed;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Console in '..\..\src\Console.pas',
  UTestbed in 'UTestbed.pas';

begin
  try
    RunTests();
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
