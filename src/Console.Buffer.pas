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

unit Console.Buffer;

{$I Console.Defines.inc}

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Console,
  Console.Sprite;

type
  { TAsciiChar }
  TAsciiChar = record
    Ch: WideChar;
    FGColor: string;
    BGColor: string;
    Changed: Boolean;
  end;

  { TAsciiBuffer }
  TAsciiBuffer = class
  private
    FWidth, FHeight: Integer;
    FBuffer: array of array of TAsciiChar;
    FOldBuffer: array of array of TAsciiChar;
    FDirty: Boolean;
    FTargetFPS: Integer;
    FLastFrameTime: Cardinal;
    FFrameDelay: Cardinal;
    FActualFPS: Single;
    FFrameCount: Integer;
    FFPSCountStartTime: Cardinal;
    procedure SwapBuffers;
    procedure UpdateFPSCounter;
  public
    constructor Create(const AWidth, AHeight: Integer);
    destructor Destroy; override;
    procedure Clear(const AChar: WideChar = ' '; const AFG: string = CSIFGWhite; const ABG: string = CSIBGBlack);
    procedure PutChar(const X, Y: Integer; const Ch: WideChar; const AFG: string = CSIFGWhite; const ABG: string = CSIBGBlack);
    procedure PutSprite(const X, Y: Integer; const ASprite: TAsciiSprite; const ATransparentChar: WideChar = #0);
    procedure SetFrameRate(const AFPS: Integer);
    function BeginFrame: Boolean;
    procedure EndFrame;
    function ElapsedTime: Cardinal;
    procedure Render;
    procedure DrawHLine(const X1, X2, Y: Integer; const Ch: WideChar; const AFG: string = CSIFGWhite; const ABG: string = CSIBGBlack);
    procedure DrawVLine(const X, Y1, Y2: Integer; const Ch: WideChar; const AFG: string = CSIFGWhite; const ABG: string = CSIBGBlack);
    procedure DrawRect(const X1, Y1, X2, Y2: Integer; const Ch: WideChar; const AFG: string = CSIFGWhite; const ABG: string = CSIBGBlack);
    procedure FillRect(const X1, Y1, X2, Y2: Integer; const Ch: WideChar; const AFG: string = CSIFGWhite; const ABG: string = CSIBGBlack);
    procedure PrintAt(const X, Y: Integer; const AText: string; const AFG: string = CSIFGWhite; const ABG: string = CSIBGBlack);
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property TargetFPS: Integer read FTargetFPS write SetFrameRate;
    property ActualFPS: Single read FActualFPS;
    property FrameCount: Integer read FFrameCount;
  end;

implementation

{ TAsciiBuffer }
constructor TAsciiBuffer.Create(const AWidth, AHeight: Integer);
var
  X, Y: Integer;
begin
  inherited Create;
  FWidth := AWidth;
  FHeight := AHeight;
  FDirty := True;

  // Default frame rate
  FTargetFPS := 60;
  FFrameDelay := 1000 div FTargetFPS;
  FLastFrameTime := GetTickCount;
  FFPSCountStartTime := FLastFrameTime;
  FFrameCount := 0;
  FActualFPS := 0;

  // Allocate both buffers
  SetLength(FBuffer, FHeight, FWidth);
  SetLength(FOldBuffer, FHeight, FWidth);

  // Initialize both buffers
  for Y := 0 to FHeight - 1 do
    for X := 0 to FWidth - 1 do
    begin
      FBuffer[Y][X].Ch := ' ';
      FBuffer[Y][X].FGColor := CSIFGWhite;
      FBuffer[Y][X].BGColor := CSIBGBlack;
      FBuffer[Y][X].Changed := True;

      FOldBuffer[Y][X].Ch := #0; // Use null char to ensure initial render
      FOldBuffer[Y][X].FGColor := '';
      FOldBuffer[Y][X].BGColor := '';
      FOldBuffer[Y][X].Changed := False;
    end;

  // Initial clear screen
  TConsole.ClearScreen;
end;

destructor TAsciiBuffer.Destroy;
begin
  FBuffer := nil;
  FOldBuffer := nil;
  inherited;
end;

procedure TAsciiBuffer.SetFrameRate(const AFPS: Integer);
var
  LFPS: Integer;
begin
  LFPS := AFPS;
  if LFPS < 1 then LFPS := 1;
  if LFPS > 240 then LFPS := 240;
  FTargetFPS := LFPS;
  FFrameDelay := 1000 div FTargetFPS;
end;

function TAsciiBuffer.BeginFrame: Boolean;
var
  LCurrentTime, LDeltaTime: Cardinal;
  LSleepTime: Integer;
begin
  // Check if enough time has passed for the next frame
  LCurrentTime := GetTickCount;
  LDeltaTime := LCurrentTime - FLastFrameTime;

  // If we've reached our frame delay, start a new frame
  Result := LDeltaTime >= FFrameDelay;

  if not Result then
  begin
    // Calculate optimal sleep time
    LSleepTime := FFrameDelay - LDeltaTime;

    // Use short sleep for more precise timing
    if LSleepTime > 3 then
      Sleep(1)
    else
      Sleep(0); // Yield time slice but return immediately
  end;
end;

function TAsciiBuffer.ElapsedTime: Cardinal;
begin
  Result := GetTickCount - FLastFrameTime;
end;

procedure TAsciiBuffer.EndFrame;
begin
  // Render the frame
  Render;

  // Update timing information
  FLastFrameTime := GetTickCount;

  // Update FPS counter
  Inc(FFrameCount);
  UpdateFPSCounter;
end;

procedure TAsciiBuffer.UpdateFPSCounter;
var
  LCurrentTime: Cardinal;
  LElapsedSeconds: Single;
begin
  LCurrentTime := GetTickCount;

  // Calculate FPS every half second
  if LCurrentTime - FFPSCountStartTime >= 500 then
  begin
    LElapsedSeconds := (LCurrentTime - FFPSCountStartTime) / 1000;
    FActualFPS := FFrameCount / LElapsedSeconds;

    // Reset counters
    FFrameCount := 0;
    FFPSCountStartTime := LCurrentTime;
  end;
end;

procedure TAsciiBuffer.Clear(const AChar: WideChar; const AFG, ABG: string);
var
  X, Y: Integer;
begin
  for Y := 0 to FHeight - 1 do
    for X := 0 to FWidth - 1 do
    begin
      if (FBuffer[Y][X].Ch <> AChar) or
         (FBuffer[Y][X].FGColor <> AFG) or
         (FBuffer[Y][X].BGColor <> ABG) then
      begin
        FBuffer[Y][X].Ch := AChar;
        FBuffer[Y][X].FGColor := AFG;
        FBuffer[Y][X].BGColor := ABG;
        FBuffer[Y][X].Changed := True;
        FDirty := True;
      end;
    end;
end;

procedure TAsciiBuffer.PutChar(const X, Y: Integer; const Ch: WideChar; const AFG, ABG: string);
begin
  if (X < 0) or (X >= FWidth) or (Y < 0) or (Y >= FHeight) then
    Exit;

  if (FBuffer[Y][X].Ch <> Ch) or
     (FBuffer[Y][X].FGColor <> AFG) or
     (FBuffer[Y][X].BGColor <> ABG) then
  begin
    FBuffer[Y][X].Ch := Ch;
    FBuffer[Y][X].FGColor := AFG;
    FBuffer[Y][X].BGColor := ABG;
    FBuffer[Y][X].Changed := True;
    FDirty := True;
  end;
end;

procedure TAsciiBuffer.PutSprite(const X, Y: Integer; const ASprite: TAsciiSprite; const ATransparentChar: WideChar);
var
  SX, SY, BX, BY: Integer;
  Ch: WideChar;
begin
  // Render sprite to buffer
  for SY := 0 to ASprite.Height - 1 do
  begin
    BY := Y + SY;
    if (BY < 0) or (BY >= FHeight) then
      Continue;

    for SX := 0 to ASprite.Width - 1 do
    begin
      BX := X + SX;
      if (BX < 0) or (BX >= FWidth) then
        Continue;

      Ch := ASprite.GetChar(SX, SY);

      // Skip transparent characters
      if (Ch = ATransparentChar) then
        Continue;

      PutChar(BX, BY, Ch, ASprite.GetFGColor(SX, SY), ASprite.GetBGColor(SX, SY));
    end;
  end;
end;

procedure TAsciiBuffer.SwapBuffers;
var
  X, Y: Integer;
begin
  for Y := 0 to FHeight - 1 do
    for X := 0 to FWidth - 1 do
    begin
      FOldBuffer[Y][X] := FBuffer[Y][X];
      FBuffer[Y][X].Changed := False;
    end;
  FDirty := False;
end;

procedure TAsciiBuffer.Render;
var
  X, Y: Integer;
  LLastFG, LLastBG: string;
  LCurrentLine: string;
  LHasChanges: Boolean;
begin
  // Skip rendering if nothing has changed
  if not FDirty then
    Exit;

  // Hide cursor during render for better performance
  TConsole.SetCursorVisible(False);

  // Process each line
  for Y := 0 to FHeight - 1 do
  begin
    // Check if this line has any changes
    LHasChanges := False;
    for X := 0 to FWidth - 1 do
    begin
      if FBuffer[Y][X].Changed or
         (FBuffer[Y][X].Ch <> FOldBuffer[Y][X].Ch) or
         (FBuffer[Y][X].FGColor <> FOldBuffer[Y][X].FGColor) or
         (FBuffer[Y][X].BGColor <> FOldBuffer[Y][X].BGColor) then
      begin
        LHasChanges := True;
        Break;
      end;
    end;

    // Skip unchanged lines
    if not LHasChanges then
      Continue;

    // Build the entire line at once
    LCurrentLine := '';
    LLastFG := '';
    LLastBG := '';

    // Position cursor at start of line
    TConsole.SetCursorPos(0, Y);

    // Process characters for this line
    for X := 0 to FWidth - 1 do
    begin
      // If colors change, output what we have so far
      if (FBuffer[Y][X].FGColor <> LLastFG) or (FBuffer[Y][X].BGColor <> LLastBG) then
      begin
        // Output any accumulated text with previous colors
        if LCurrentLine <> '' then
        begin
          TConsole.Print(LCurrentLine);
          LCurrentLine := '';
        end;

        // Update colors and position
        if FBuffer[Y][X].FGColor <> LLastFG then
        begin
          TConsole.SetForegroundColor(FBuffer[Y][X].FGColor);
          LLastFG := FBuffer[Y][X].FGColor;
        end;

        if FBuffer[Y][X].BGColor <> LLastBG then
        begin
          TConsole.SetBackgroundColor(FBuffer[Y][X].BGColor);
          LLastBG := FBuffer[Y][X].BGColor;
        end;

        // Update cursor position to current position
        TConsole.SetCursorPos(X, Y);
      end;

      // Add character to current line
      LCurrentLine := LCurrentLine + FBuffer[Y][X].Ch;
    end;

    // Print any remaining text
    if LCurrentLine <> '' then
      TConsole.Print(LCurrentLine);
  end;

  // Swap buffers for next frame
  SwapBuffers;

  // Reset text formatting
  TConsole.ResetTextFormat;
end;

// Draw a horizontal line
procedure TAsciiBuffer.DrawHLine(const X1, X2, Y: Integer; const Ch: WideChar; const AFG: string; const ABG: string);
var
  X, LStartX, LEndX: Integer;
begin
  // Ensure X1 <= X2
  if X1 > X2 then
  begin
    LStartX := X2;
    LEndX := X1;
  end
  else
  begin
    LStartX := X1;
    LEndX := X2;
  end;

  // Draw the line
  for X := LStartX to LEndX do
    PutChar(X, Y, Ch, AFG, ABG);
end;

// Draw a vertical line
procedure TAsciiBuffer.DrawVLine(const X, Y1, Y2: Integer; const Ch: WideChar; const AFG: string; const ABG: string);
var
  Y, LStartY, LEndY: Integer;
begin
  // Ensure Y1 <= Y2
  if Y1 > Y2 then
  begin
    LStartY := Y2;
    LEndY := Y1;
  end
  else
  begin
    LStartY := Y1;
    LEndY := Y2;
  end;

  // Draw the line
  for Y := LStartY to LEndY do
    PutChar(X, Y, Ch, AFG, ABG);
end;

// Draw a rectangle (outline)
procedure TAsciiBuffer.DrawRect(const X1, Y1, X2, Y2: Integer; const Ch: WideChar; const AFG: string; const ABG: string);
begin
  // Draw horizontal lines
  DrawHLine(X1, X2, Y1, Ch, AFG, ABG);
  DrawHLine(X1, X2, Y2, Ch, AFG, ABG);

  // Draw vertical lines
  DrawVLine(X1, Y1, Y2, Ch, AFG, ABG);
  DrawVLine(X2, Y1, Y2, Ch, AFG, ABG);
end;

// Fill a rectangle area
procedure TAsciiBuffer.FillRect(const X1, Y1, X2, Y2: Integer; const Ch: WideChar; const AFG: string; const ABG: string);
var
  X, Y: Integer;
  LStartX, LEndX, LStartY, LEndY: Integer;
begin
  // Ensure X1 <= X2 and Y1 <= Y2
  if X1 > X2 then
  begin
    LStartX := X2;
    LEndX := X1;
  end
  else
  begin
    LStartX := X1;
    LEndX := X2;
  end;

  if Y1 > Y2 then
  begin
    LStartY := Y2;
    LEndY := Y1;
  end
  else
  begin
    LStartY := Y1;
    LEndY := Y2;
  end;

  // Fill the rectangle
  for Y := LStartY to LEndY do
    for X := LStartX to LEndX do
      PutChar(X, Y, Ch, AFG, ABG);
end;

// Print text at position
procedure TAsciiBuffer.PrintAt(const X, Y: Integer; const AText: string; const AFG: string; const ABG: string);
var
  I: Integer;
  LCurX: Integer;
begin
  LCurX := X;

  // Print each character
  for I := 1 to Length(AText) do
  begin
    // Skip out-of-bounds positions
    if (LCurX >= 0) and (LCurX < Width) and (Y >= 0) and (Y < Height) then
      PutChar(LCurX, Y, AText[I], AFG, ABG);

    // Move to next position
    Inc(LCurX);
  end;
end;

end.
