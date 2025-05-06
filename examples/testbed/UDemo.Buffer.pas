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

unit UDemo.Buffer;

interface

uses
  WinApi.Windows,
  System.SysUtils,
  Console,
  Console.Buffer;

procedure Demo_AsciiBuffer;

implementation

procedure Demo_AsciiBuffer;
var
  Buffer: TAsciiBuffer;
  X, Y, DX, DY: Integer;
  MaxW, MaxH: Integer;
  KeyPressed: Boolean;
  StatusLine: string;
  LastX, LastY: Integer;
  StarChar: WideChar;
  LocalFrameCount: Integer; // Added local frame counter
begin
  TConsole.SetTitle('TConsole: ASCII Buffer Demo');

  TConsole.ClearScreen();
  TConsole.SetCursorVisible(False);
  TConsole.GetSize(@MaxW, @MaxH);

  Buffer := TAsciiBuffer.Create(MaxW, MaxH);
  try
    // Request higher frame rate
    Buffer.TargetFPS := 120; // Aim higher than 60 to account for overhead

    // Initial setup
    X := 10;
    Y := 5;
    DX := 1;
    DY := 1;
    //LastX := X;
    //LastY := Y;
    StarChar := '*';
    LocalFrameCount := 0; // Initialize frame counter

    // Initial clear of the buffer - do this only once
    Buffer.Clear(' ', CSIDim+CSIFGWhite, CSIBGBlack);

    // Draw initial position
    Buffer.PutChar(X, Y, StarChar, CSIFGGreen, CSIBGBlack);

    KeyPressed := False;
    while not KeyPressed do
    begin
      // Check for keypress without waiting
      KeyPressed := TConsole.AnyKeyPressed;

      // Wait for next frame timing
      if Buffer.BeginFrame then
      begin
        // Increment frame counter
        Inc(LocalFrameCount);

        // Remember last position before updating
        LastX := X;
        LastY := Y;

        // Update position
        Inc(X, DX);
        Inc(Y, DY);

        // Handle collisions
        if (X <= 0) or (X >= Buffer.Width - 1) then DX := -DX;
        if (Y <= 0) or (Y >= Buffer.Height - 1) then DY := -DY;

        // Clear only the previous position
        Buffer.PutChar(LastX, LastY, ' ', CSIDim+CSIFGWhite, CSIBGBlack);

        // Draw at new position
        Buffer.PutChar(X, Y, StarChar, CSIFGGreen, CSIBGBlack);

        // Only update status every few frames to reduce overhead
        if LocalFrameCount mod 10 = 0 then
        begin
          // Display status info at bottom of screen
          StatusLine := Format('Position: (%d,%d) FPS: %.1f Target: %d',
                              [X, Y, Buffer.ActualFPS, Buffer.TargetFPS]);

          // Only update status line if it changed
          for var i := 0 to Length(StatusLine) - 1 do
            if i < Buffer.Width then
              Buffer.PutChar(i, Buffer.Height - 1, StatusLine[i+1], CSIFGYellow, CSIBGBlack);
        end;

        // Finalize frame
        Buffer.EndFrame;
      end;
    end;
  finally
    Buffer.Free;
    TConsole.SetCursorVisible(True);
    TConsole.ClearScreen();
  end;
end;

end.
