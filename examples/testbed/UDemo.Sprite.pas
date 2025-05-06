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

unit UDemo.Sprite;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  Winapi.Windows,
  Console,
  Console.Buffer,
  Console.Sprite;

procedure Demo_Sprite;

implementation

var
  PlayerSprite, EnemySprite, ExplosionSprite: TAsciiSprite;
  LargeShipSprite, AsteroidSprite, BossSprite: TAsciiSprite;

// Create and initialize the sprites
procedure InitSprites;
var
 I: Integer;
begin
  // Create player ship sprite (5x3)
  PlayerSprite := TAsciiSprite.Create(5, 3);
  PlayerSprite.LoadFromString(
    '  ^  ' + #13#10 +
    ' /|\ ' + #13#10 +
    '/===\',
    CSIFGCyan, CSIBGBlack);

  // Create enemy ship sprite (5x3)
  EnemySprite := TAsciiSprite.Create(5, 3);
  EnemySprite.LoadFromString(
    '\===/' + #13#10 +
    ' \|/ ' + #13#10 +
    '  v  ',
    CSIFGRed, CSIBGBlack);

  // Create explosion sprite (5x3)
  ExplosionSprite := TAsciiSprite.Create(5, 3);
  ExplosionSprite.LoadFromString(
    '\* */' + #13#10 +
    ' *** ' + #13#10 +
    '/* *\',
    CSIFGYellow, CSIBGBlack);

  // Create a larger spaceship (15x7)
  LargeShipSprite := TAsciiSprite.Create(15, 7);
  LargeShipSprite.LoadFromString(
    '      /^\      ' + #13#10 +
    '     /___\     ' + #13#10 +
    '    /|   |\    ' + #13#10 +
    ' __/||---||\\_ ' + #13#10 +
    '/___||___||___\' + #13#10 +
    '    \|___|/    ' + #13#10 +
    '     \___/     ',
    CSIFGCyan, CSIBGBlack);

  // Create an asteroid sprite (10x5)
  AsteroidSprite := TAsciiSprite.Create(10, 5);
  AsteroidSprite.LoadFromString(
    '    __    ' + #13#10 +
    '  _/  \_  ' + #13#10 +
    ' /      \ ' + #13#10 +
    ' \__/\__/ ' + #13#10 +
    '    \/    ',
    CSIFGWhite, CSIBGBlack);

  // Create a boss enemy sprite (15x10)
  BossSprite := TAsciiSprite.Create(15, 10);
  BossSprite.LoadFromString(
    '   /=======\   ' + #13#10 +
    '  / _______ \  ' + #13#10 +
    ' //|       |\ \' + #13#10 +
    '|| |  (O)  | ||' + #13#10 +
    '||/       \||' + #13#10 +
    '||\_______/||' + #13#10 +
    ' \\\=====/// ' + #13#10 +
    '  \||| |||/  ' + #13#10 +
    '   ||| |||   ' + #13#10 +
    '   \\\_///   ',
    CSIFGRed, CSIBGBlack);

  // Add color variations within a sprite
  BossSprite.SetChar(7, 3, 'O', CSIFGYellow, CSIBGBlack);  // Yellow eye

  // Highlight a row

  for I := 0 to 14 do
    BossSprite.SetChar(I, 6, '=', CSIFGRed + CSIBold, CSIBGBlack);
end;

procedure Demo_Sprite;
var
  Buffer: TAsciiBuffer;
  MaxW, MaxH: Integer;
  Running: Boolean;
  Time: Integer;
  X, Y: Integer;
  FPSStr: string;
  InstructionStr: string;
  I: Integer;
begin
  TConsole.SetTitle('TConsole: Sprite Demo');

  TConsole.ClearKeyStates();
  TConsole.ClearScreen();
  TConsole.SetCursorVisible(False);
  TConsole.GetSize(@MaxW, @MaxH);

  // Create buffer
  Buffer := TAsciiBuffer.Create(MaxW, MaxH);

  try
    // Initialize sprites
    InitSprites;

    // Set frame rate
    Buffer.TargetFPS := 60;

    // Main loop
    Running := True;
    Time := 0;

    while Running do
    begin
      // Check for exit key
      if TConsole.AnyKeyPressed() then
        Running := False;

      // Wait for next frame
      if Buffer.BeginFrame then
      begin
        // Clear buffer
        Buffer.Clear(' ', CSIFGWhite, CSIBGBlack);

        // Increment time
        Inc(Time);

        // Draw sprites at different positions

        // Small sprite demos - moving in a circle
        X := Round(MaxW / 4 + Cos(Time / 20) * 10);
        Y := Round(MaxH / 4 + Sin(Time / 20) * 5);
        Buffer.PutSprite(X, Y, PlayerSprite);

        X := Round(MaxW / 4 + Cos(Time / 20 + PI) * 10);
        Y := Round(MaxH / 4 + Sin(Time / 20 + PI) * 5);
        Buffer.PutSprite(X, Y, EnemySprite);

        // Only show explosion periodically
        if (Time mod 60) < 30 then
        begin
          X := Round(MaxW / 4);
          Y := Round(MaxH / 4);
          Buffer.PutSprite(X, Y, ExplosionSprite);
        end;

        // Large ship demo - moving side to side
        X := Round(MaxW / 2 - LargeShipSprite.Width / 2 + Sin(Time / 30) * (MaxW / 4));
        Y := Round(MaxH / 2 - LargeShipSprite.Height / 2);
        Buffer.PutSprite(X, Y, LargeShipSprite);

        // Asteroid orbiting
        X := Round(MaxW / 2 + Cos(Time / 15) * 20);
        Y := Round(MaxH / 2 + Sin(Time / 15) * 10);
        Buffer.PutSprite(X, Y, AsteroidSprite);

        // Boss sprite at bottom
        X := Round(MaxW / 2 - BossSprite.Width / 2);
        Y := MaxH - BossSprite.Height - 2;
        Buffer.PutSprite(X, Y, BossSprite);

        // Display FPS and instructions
        Buffer.PutChar(2, 2, 'F', CSIFGWhite, CSIBGBlack);
        Buffer.PutChar(3, 2, 'P', CSIFGWhite, CSIBGBlack);
        Buffer.PutChar(4, 2, 'S', CSIFGWhite, CSIBGBlack);
        Buffer.PutChar(5, 2, ':', CSIFGWhite, CSIBGBlack);

        // Convert FPS to string
        FPSStr := Format('%.1f', [Buffer.ActualFPS]);
        for I := 0 to Length(FPSStr) - 1 do
          Buffer.PutChar(7 + I, 2, FPSStr[I+1], CSIFGGreen, CSIBGBlack);

        // Display instructions
        InstructionStr := 'Press any key to exit';
        for I := 0 to Length(InstructionStr) - 1 do
          Buffer.PutChar(MaxW - Length(InstructionStr) - 2 + I, 2, InstructionStr[I+1], CSIFGYellow, CSIBGBlack);

        // Complete frame
        Buffer.EndFrame;
      end;
    end;

  finally
    // Free sprites
    PlayerSprite.Free;
    EnemySprite.Free;
    ExplosionSprite.Free;
    LargeShipSprite.Free;
    AsteroidSprite.Free;
    BossSprite.Free;

    // Free buffer
    Buffer.Free;

    TConsole.SetCursorVisible(True);
    TConsole.ClearScreen();
  end;
end;

end.
