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

//{$APPTYPE CONSOLE}
{$APPTYPE GUI}

{$R *.res}

uses
  System.SysUtils,
  Console in '..\..\src\Console.pas',
  UTestbed in 'UTestbed.pas',
  Console.Buffer in '..\..\src\Console.Buffer.pas',
  UDemo.Buffer in 'UDemo.Buffer.pas',
  UDemo.SpaceInvaders in 'UDemo.SpaceInvaders.pas',
  UDemo.StellarAssault in 'UDemo.StellarAssault.pas',
  UDemo.Sprite in 'UDemo.Sprite.pas',
  UDemo.StellarDefender in 'UDemo.StellarDefender.pas',
  UCommon in 'UCommon.pas',
  Console.Sprite in '..\..\src\Console.Sprite.pas';

begin
  RunTests();
end.
