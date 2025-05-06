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

unit UDemo.Effects;

interface

uses
  WinApi.Windows,
  System.SysUtils,
  System.Math,
  Console,
  Console.Buffer,
  UCommon;


procedure Demo_PipeWrite();
procedure Demo_ClockDisplay();
procedure Demo_Dashboard();
procedure Demo_AnimationPlayer();
procedure Demo_BouncingText();
procedure Demo_WaveText();
procedure Demo_Kaleidoscope();
procedure Demo_FractalTree();
procedure Demo_RainEffect();
procedure Demo_FireEffect();
procedure Demo_ParticleSystem();
procedure Demo_ColorTunnel();
procedure Demo_FlowingText();
procedure Demo_AdvancedAnimations();
procedure Demo_AdvancedEffects();

implementation

procedure Demo_PipeWrite;
var
  FG, BG: integer;
  LLine: string;
begin
  TConsole.SetTitle('TConsole: PipeWrite Demo');

  for FG := 0 to 15 do
  begin
    TConsole.PipeWrite('|B0|%2.2d ', [FG]);
    for BG := 0 to 7 do
      TConsole.PipeWrite('|%2.2d|B%dABC|B0 ', [FG, BG]);
    Writeln;
  end;

  TConsole.Pause();
end;

// Bouncing Text Demo with Flicker-Free Rendering
procedure Demo_BouncingText;
const
  DEMO_DURATION = 15000; // 15 seconds
  FPS = 30;
  MESSAGE = 'TConsole Demo!';
type
  TTextChar = record
    Ch: Char;
    X, Y: Double;
    VelX, VelY: Double;
    Color: string;
    LastX, LastY: Integer; // Last drawn position
  end;
var
  Chars: array of TTextChar;
  ConsoleWidth, ConsoleHeight: Integer;
  OriginalTitle: string;
  StartTime, CurrentTime, LastFrameTime: TDateTime;
  ElapsedMs, FrameTimeMs: Int64;
  I, IntX, IntY: Integer;
  ColorIndex: Integer;
  InfoString: string;
begin
  ClearInput();

  // Store original title
  OriginalTitle := TConsole.GetTitle;
  TConsole.SetTitle('TConsole Bouncing Text Demo');

  // Get console dimensions
  TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);

  // Hide cursor
  TConsole.HideCursor;

  // Initialize characters
  SetLength(Chars, Length(MESSAGE));
  for I := 0 to High(Chars) do
  begin
    Chars[I].Ch := MESSAGE[I+1];

    // Initial position - clustered in center
    Chars[I].X := ConsoleWidth / 2 + (I - Length(MESSAGE)/2) * 2;
    Chars[I].Y := ConsoleHeight / 2;

    // Initial velocity - random
    Chars[I].VelX := 0.3 - Random * 0.6;
    Chars[I].VelY := 0.3 - Random * 0.6;

    // Ensure some velocity
    if Abs(Chars[I].VelX) < 0.1 then
      Chars[I].VelX := 0.1 * Sign(Chars[I].VelX);
    if Abs(Chars[I].VelY) < 0.1 then
      Chars[I].VelY := 0.1 * Sign(Chars[I].VelY);

    // Assign color based on position in string
    ColorIndex := I mod 6;
    case ColorIndex of
      0: Chars[I].Color := CSIFGRed;
      1: Chars[I].Color := CSIFGYellow;
      2: Chars[I].Color := CSIFGGreen;
      3: Chars[I].Color := CSIFGCyan;
      4: Chars[I].Color := CSIFGBlue;
      5: Chars[I].Color := CSIFGMagenta;
    end;

    // Initialize last position
    Chars[I].LastX := -1;
    Chars[I].LastY := -1;
  end;

  // Setup timing
  FrameTimeMs := 1000 div FPS;
  StartTime := Now;
  LastFrameTime := StartTime;

  // Clear screen once at the beginning
  TConsole.ClearScreen;

  // Main loop
  try
    repeat
      // Get current time
      CurrentTime := Now;
      ElapsedMs := Round((CurrentTime - StartTime) * 24 * 60 * 60 * 1000);

      // Check if it's time for a new frame
      if Round((CurrentTime - LastFrameTime) * 24 * 60 * 60 * 1000) >= FrameTimeMs then
      begin
        // First clear old positions
        for I := 0 to High(Chars) do
        begin
          if (Chars[I].LastX >= 0) and (Chars[I].LastY >= 0) and
             (Chars[I].LastX < ConsoleWidth) and (Chars[I].LastY < ConsoleHeight) then
          begin
            TConsole.SetCursorPos(Chars[I].LastX, Chars[I].LastY);
            TConsole.Print(' ', False); // Erase
          end;
        end;

        // Update and draw characters
        for I := 0 to High(Chars) do
        begin
          // Update position
          Chars[I].X := Chars[I].X + Chars[I].VelX;
          Chars[I].Y := Chars[I].Y + Chars[I].VelY;

          // Bounce off walls
          if (Chars[I].X < 0) or (Chars[I].X >= ConsoleWidth) then
          begin
            Chars[I].VelX := -Chars[I].VelX;

            // Ensure within bounds
            if Chars[I].X < 0 then
              Chars[I].X := 0
            else if Chars[I].X >= ConsoleWidth then
              Chars[I].X := ConsoleWidth - 1;
          end;

          if (Chars[I].Y < 0) or (Chars[I].Y >= ConsoleHeight - 1) then
          begin
            Chars[I].VelY := -Chars[I].VelY;

            // Ensure within bounds
            if Chars[I].Y < 0 then
              Chars[I].Y := 0
            else if Chars[I].Y >= ConsoleHeight - 1 then
              Chars[I].Y := ConsoleHeight - 2;
          end;

          // Draw at new position
          IntX := Round(Chars[I].X);
          IntY := Round(Chars[I].Y);

          TConsole.SetCursorPos(IntX, IntY);
          TConsole.SetForegroundColor(Chars[I].Color);
          TConsole.Print(Chars[I].Ch, False);

          // Update last position
          Chars[I].LastX := IntX;
          Chars[I].LastY := IntY;
        end;

        // Display info
        InfoString := Format('Bouncing Text Demo - Time: %.1fs', [ElapsedMs / 1000.0]);
        TConsole.SetCursorPos(2, ConsoleHeight - 1);
        TConsole.SetForegroundColor(CSIFGWhite);
        TConsole.Print(InfoString + StringOfChar(' ', 20), False); // Pad with spaces

        // Update last frame time
        LastFrameTime := CurrentTime;
      end;

      // Sleep to reduce CPU usage
      Sleep(5);

    until (ElapsedMs >= DEMO_DURATION) or TConsole.AnyKeyPressed;

    // Clean up
    TConsole.ClearScreen;
    TConsole.ResetTextFormat;
    TConsole.ShowCursor;
    TConsole.SetTitle(OriginalTitle);

  except
    on E: Exception do
    begin
      TConsole.ClearScreen;
      TConsole.ResetTextFormat;
      TConsole.ShowCursor;
      TConsole.SetTitle(OriginalTitle);

      TConsole.SetForegroundColor(CSIFGRed);
      TConsole.PrintLn('Error: %s', [E.Message], False);
      TConsole.ResetTextFormat;
    end;
  end;
end;

// Wave Text Demo with Flicker-Free Rendering
procedure Demo_WaveText;
const
  DEMO_DURATION = 15000; // 15 seconds
  FPS = 30;
  MESSAGE = 'TConsole Wave Animation Demo';
type
  TCharPosition = record
    Ch: Char;
    X, Y: Integer;
    BaseY: Integer;
    Color: string;
    LastY: Integer; // Last drawn Y position
  end;
var
  Chars: array of TCharPosition;
  ConsoleWidth, ConsoleHeight: Integer;
  OriginalTitle: string;
  StartTime, CurrentTime, LastFrameTime: TDateTime;
  ElapsedMs, FrameTimeMs: Int64;
  I, CenterX, CenterY: Integer;
  T, WaveHeight, WaveLength, WaveSpeed: Double;
  ColorIndex: Integer;
  InfoString: string;
begin
  ClearInput();

  // Store original title
  OriginalTitle := TConsole.GetTitle;
  TConsole.SetTitle('TConsole Wave Text Demo');

  // Get console dimensions
  TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);

  // Hide cursor
  TConsole.HideCursor;

  // Calculate center position
  CenterX := (ConsoleWidth - Length(MESSAGE)) div 2;
  CenterY := ConsoleHeight div 2;

  // Initialize characters
  SetLength(Chars, Length(MESSAGE));
  for I := 0 to High(Chars) do
  begin
    Chars[I].Ch := MESSAGE[I+1];
    Chars[I].X := CenterX + I;
    Chars[I].BaseY := CenterY;
    Chars[I].LastY := -1; // Invalid initial position

    // Cycle through colors
    ColorIndex := I mod 6;
    case ColorIndex of
      0: Chars[I].Color := CSIFGRed;
      1: Chars[I].Color := CSIFGYellow;
      2: Chars[I].Color := CSIFGGreen;
      3: Chars[I].Color := CSIFGCyan;
      4: Chars[I].Color := CSIFGBlue;
      5: Chars[I].Color := CSIFGMagenta;
    end;
  end;

  // Wave parameters
  WaveHeight := 4.0; // Peak amplitude
  WaveLength := 0.3; // Wave frequency
  WaveSpeed := 5.0;  // Wave speed

  // Setup timing
  FrameTimeMs := 1000 div FPS;
  StartTime := Now;
  LastFrameTime := StartTime;

  // Clear screen once at the beginning
  TConsole.ClearScreen;

  // Main loop
  try
    repeat
      // Get current time
      CurrentTime := Now;
      ElapsedMs := Round((CurrentTime - StartTime) * 24 * 60 * 60 * 1000);

      // Check if it's time for a new frame
      if Round((CurrentTime - LastFrameTime) * 24 * 60 * 60 * 1000) >= FrameTimeMs then
      begin
        // Calculate time parameter
        T := ElapsedMs / 1000.0;

        // Clear old characters
        for I := 0 to High(Chars) do
        begin
          if (Chars[I].LastY >= 0) and (Chars[I].LastY < ConsoleHeight) then
          begin
            TConsole.SetCursorPos(Chars[I].X, Chars[I].LastY);
            TConsole.Print(' ', False); // Erase
          end;
        end;

        // Update and draw characters
        for I := 0 to High(Chars) do
        begin
          // Calculate wave offset for this character
          var Offset := Sin((I * WaveLength) + (T * WaveSpeed)) * WaveHeight;

          // Update Y position with wave effect
          Chars[I].Y := Chars[I].BaseY + Round(Offset);

          // Ensure within bounds
          if Chars[I].Y < 0 then
            Chars[I].Y := 0
          else if Chars[I].Y >= ConsoleHeight - 1 then
            Chars[I].Y := ConsoleHeight - 2;

          // Draw at new position
          TConsole.SetCursorPos(Chars[I].X, Chars[I].Y);
          TConsole.SetForegroundColor(Chars[I].Color);
          TConsole.Print(Chars[I].Ch, False);

          // Update last position
          Chars[I].LastY := Chars[I].Y;
        end;

        // Draw secondary wave effects (echo waves)
        for I := 0 to High(Chars) do
        begin
          // Second wave (echo)
          var Offset2 := Sin((I * WaveLength * 1.5) + (T * WaveSpeed * 0.7)) * (WaveHeight * 0.5);
          var Y2 := Chars[I].BaseY + Round(Offset2) + 2;

          if (Y2 >= 0) and (Y2 < ConsoleHeight - 1) and (Y2 <> Chars[I].Y) then
          begin
            TConsole.SetCursorPos(Chars[I].X, Y2);
            TConsole.SetForegroundColor(CSIFGBrightBlack);
            TConsole.Print('·', False); // Echo character
          end;
        end;

        // Display info
        InfoString := Format('Wave Text Demo - Time: %.1fs', [T]);
        TConsole.SetCursorPos(2, ConsoleHeight - 1);
        TConsole.SetForegroundColor(CSIFGWhite);
        TConsole.Print(InfoString + StringOfChar(' ', 20), False); // Pad with spaces

        // Update last frame time
        LastFrameTime := CurrentTime;
      end;

      // Sleep to reduce CPU usage
      Sleep(5);

    until (ElapsedMs >= DEMO_DURATION) or TConsole.AnyKeyPressed;

    // Clean up
    TConsole.ClearScreen;
    TConsole.ResetTextFormat;
    TConsole.ShowCursor;
    TConsole.SetTitle(OriginalTitle);

  except
    on E: Exception do
    begin
      TConsole.ClearScreen;
      TConsole.ResetTextFormat;
      TConsole.ShowCursor;
      TConsole.SetTitle(OriginalTitle);

      TConsole.SetForegroundColor(CSIFGRed);
      TConsole.PrintLn('Error: %s', [E.Message], False);
      TConsole.ResetTextFormat;
    end;
  end;
end;

// Kaleidoscope Demo with Flicker-Free Rendering
procedure Demo_Kaleidoscope;
const
  DEMO_DURATION = 15000; // 15 seconds
  FPS = 30;
  SEGMENTS = 8;
type
  TKaleidoPoint = record
    X, Y: Integer;
    Color: string;
    Ch: Char;
  end;
var
  Points: array of TKaleidoPoint;
  LastPoints: array of TKaleidoPoint;
  ConsoleWidth, ConsoleHeight: Integer;
  OriginalTitle: string;
  StartTime, CurrentTime, LastFrameTime: TDateTime;
  ElapsedMs, FrameTimeMs: Int64;
  CenterX, CenterY: Integer;
  I, J, PointCount, LastPointCount: Integer;
  Angle, Radius, T: Double;
  SegmentAngle: Double;
  ColorIndex: Integer;
  ColorCycle: array[0..5] of string;
  CharCycle: array[0..4] of Char;
  InfoString: string;
begin
  ClearInput();

  // Store original title
  OriginalTitle := TConsole.GetTitle;
  TConsole.SetTitle('TConsole Kaleidoscope Demo');

  // Get console dimensions
  TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);

  // Calculate center position (adjust for character aspect ratio)
  CenterX := ConsoleWidth div 2;
  CenterY := ConsoleHeight div 2;

  // Hide cursor
  TConsole.HideCursor;

  // Initialize color cycle
  ColorCycle[0] := CSIFGRed;
  ColorCycle[1] := CSIFGYellow;
  ColorCycle[2] := CSIFGGreen;
  ColorCycle[3] := CSIFGCyan;
  ColorCycle[4] := CSIFGBlue;
  ColorCycle[5] := CSIFGMagenta;

  // Initialize character cycle
  CharCycle[0] := '*';
  CharCycle[1] := '+';
  CharCycle[2] := '·';
  CharCycle[3] := '°';
  CharCycle[4] := '#';

  // Segment angle
  SegmentAngle := 2 * Pi / SEGMENTS;

  // Initialize point arrays
  SetLength(Points, ConsoleWidth * ConsoleHeight);    // Max possible
  SetLength(LastPoints, ConsoleWidth * ConsoleHeight);
  //PointCount := 0;
  LastPointCount := 0;

  // Setup timing
  FrameTimeMs := 1000 div FPS;
  StartTime := Now;
  LastFrameTime := StartTime;

  // Clear screen once at the beginning
  TConsole.ClearScreen;

  // Main loop
  try
    repeat
      // Get current time
      CurrentTime := Now;
      ElapsedMs := Round((CurrentTime - StartTime) * 24 * 60 * 60 * 1000);

      // Check if it's time for a new frame
      if Round((CurrentTime - LastFrameTime) * 24 * 60 * 60 * 1000) >= FrameTimeMs then
      begin
        // Calculate time parameter
        T := ElapsedMs / 1000.0;

        // Erase old points
        for I := 0 to LastPointCount - 1 do
        begin
          TConsole.SetCursorPos(LastPoints[I].X, LastPoints[I].Y);
          TConsole.Print(' ', False); // Erase
        end;

        // Reset point count
        PointCount := 0;

        // Generate new base points along a moving spiral
        for I := 0 to 15 do
        begin
          // Spiral parameters
          Radius := 2 + (I * 0.7) + Sin(T * 0.8) * 3;
          Angle := (I * 0.3) + T * 1.5;

          // Calculate base point in first segment
          var BaseX := Round(CenterX + Cos(Angle) * Radius);
          var BaseY := Round(CenterY + Sin(Angle) * Radius * 0.5); // Adjust for aspect ratio

          // Select color and character for this point
          ColorIndex := (I + Round(T * 3)) mod 6;
          var CharIndex := (I + Round(T * 2)) mod 5;

          // Create symmetric points in all segments
          for J := 0 to SEGMENTS - 1 do
          begin
            // Rotate the point around center by segment angle * j
            var SegAngle := J * SegmentAngle;
            var OffsetX := BaseX - CenterX;
            var OffsetY := (BaseY - CenterY) * 2; // Adjust for aspect ratio

            // Rotate point
            var RotX := OffsetX * Cos(SegAngle) - OffsetY * Sin(SegAngle);
            var RotY := OffsetX * Sin(SegAngle) + OffsetY * Cos(SegAngle);

            // Convert back to screen coordinates
            var NewX := Round(CenterX + RotX);
            var NewY := Round(CenterY + RotY * 0.5); // Adjust for aspect ratio

            // Store point if in bounds
            if (NewX >= 0) and (NewX < ConsoleWidth) and
               (NewY >= 0) and (NewY < ConsoleHeight - 1) then
            begin
              Points[PointCount].X := NewX;
              Points[PointCount].Y := NewY;
              Points[PointCount].Color := ColorCycle[ColorIndex];
              Points[PointCount].Ch := CharCycle[CharIndex];
              Inc(PointCount);

              // Safety check
              if PointCount >= Length(Points) then
                Break;
            end;
          end;

          if PointCount >= Length(Points) then
            Break;
        end;

        // Draw new points
        for I := 0 to PointCount - 1 do
        begin
          TConsole.SetCursorPos(Points[I].X, Points[I].Y);
          TConsole.SetForegroundColor(Points[I].Color);
          TConsole.Print(Points[I].Ch, False);

          // Save this point to LastPoints
          LastPoints[I] := Points[I];
        end;
        LastPointCount := PointCount;

        // Display info
        InfoString := Format('Kaleidoscope Demo - Time: %.1fs - Segments: %d', [T, SEGMENTS]);
        TConsole.SetCursorPos(2, ConsoleHeight - 1);
        TConsole.SetForegroundColor(CSIFGWhite);
        TConsole.Print(InfoString + StringOfChar(' ', 20), False); // Pad with spaces

        // Update last frame time
        LastFrameTime := CurrentTime;
      end;

      // Sleep to reduce CPU usage
      Sleep(5);

    until (ElapsedMs >= DEMO_DURATION) or TConsole.AnyKeyPressed;

    // Clean up
    TConsole.ClearScreen;
    TConsole.ResetTextFormat;
    TConsole.ShowCursor;
    TConsole.SetTitle(OriginalTitle);

  except
    on E: Exception do
    begin
      TConsole.ClearScreen;
      TConsole.ResetTextFormat;
      TConsole.ShowCursor;
      TConsole.SetTitle(OriginalTitle);

      TConsole.SetForegroundColor(CSIFGRed);
      TConsole.PrintLn('Error: %s', [E.Message], False);
      TConsole.ResetTextFormat;
    end;
  end;
end;

// Fractal Tree Animation Demo with Improved Rendering
procedure Demo_FractalTree;
const
  DEMO_DURATION = 15000; // 15 seconds
  FPS = 30;
  MAX_DEPTH = 8;
  MIN_BRANCH_LENGTH = 3;
type
  TPoint = record
    X, Y: Integer;
  end;

  TTreeState = record
    Points: array of TPoint;
    Colors: array of string;
    Chars: array of Char;
    Count: Integer;
  end;
var
  OldState, NewState: TTreeState;
  MaxPoints: Integer;
  ConsoleWidth, ConsoleHeight: Integer;
  OriginalTitle: string;
  StartTime, CurrentTime, LastFrameTime: TDateTime;
  ElapsedMs, FrameTimeMs: Int64;
  Angle, BranchAngle: Double;
  RootX, RootY: Integer;

  // Add a point to the new state
  procedure AddPoint(X, Y: Integer; Ch: Char; Color: string);
  begin
    // Skip if outside boundaries
    if (X < 0) or (X >= ConsoleWidth) or (Y < 0) or (Y >= ConsoleHeight) then
      Exit;

    // Add to new state if there's space
    if NewState.Count < MaxPoints then
    begin
      NewState.Points[NewState.Count].X := X;
      NewState.Points[NewState.Count].Y := Y;
      NewState.Chars[NewState.Count] := Ch;
      NewState.Colors[NewState.Count] := Color;

      Inc(NewState.Count);
    end;
  end;

  // Draw a fractal branch recursively
  procedure DrawBranch(X, Y: Integer; Angle, Length: Double; Depth: Integer);
  var
    EndX, EndY: Integer;
    NewLength: Double;
    NewAngle1, NewAngle2: Double;
    {I,} IntX, IntY: Integer;
    {LastX, LastY: Integer;}
    Color: string;
    Ch: Char;
  begin
    if Depth > MAX_DEPTH then
      Exit;

    if Length < MIN_BRANCH_LENGTH then
      Exit;

    // Calculate end point
    EndX := Round(X + Cos(Angle) * Length);
    EndY := Round(Y + Sin(Angle) * Length);

    // Choose color based on depth
    case Depth mod 6 of
      0: Color := CSIFGGreen;
      1: Color := CSIFGBrightGreen;
      2: Color := CSIFGYellow;
      3: Color := CSIFGBrightYellow;
      4: Color := CSIFGBrightCyan;
      5: Color := CSIFGWhite;
    end;

    // Choose character based on depth
    if Depth <= 2 then
      Ch := '#'
    else if Depth <= 4 then
      Ch := '+'
    else if Depth <= 6 then
      Ch := '*'
    else
      Ch := '.';

    // Draw the line using Bresenham's algorithm
    var DX := Abs(EndX - X);
    var DY := -Abs(EndY - Y);
    var SX: Integer;
    if X < EndX then SX := 1 else SX := -1;
    var SY: Integer;
    if Y < EndY then SY := 1 else SY := -1;
    var Error := DX + DY;
    var Error2: Integer;

    IntX := X;
    IntY := Y;

    while True do
    begin
      // Add point to new state
      AddPoint(IntX, IntY, Ch, Color);

      // Check if we reached the end
      if (IntX = EndX) and (IntY = EndY) then
        Break;

      Error2 := 2 * Error;

      if Error2 >= DY then
      begin
        if IntX = EndX then Break;
        Error := Error + DY;
        IntX := IntX + SX;
      end;

      if Error2 <= DX then
      begin
        if IntY = EndY then Break;
        Error := Error + DX;
        IntY := IntY + SY;
      end;
    end;

    // Calculate new length for branches
    NewLength := Length * 0.7;

    // Calculate branch angles
    NewAngle1 := Angle - BranchAngle;
    NewAngle2 := Angle + BranchAngle;

    // Draw branches recursively
    DrawBranch(EndX, EndY, NewAngle1, NewLength, Depth + 1);
    DrawBranch(EndX, EndY, NewAngle2, NewLength, Depth + 1);
  end;

  // Update the display by comparing old and new states
  procedure UpdateDisplay;
  var
    I, J: Integer;
    Found: Boolean;
  begin
    // First, erase points that are in old state but not in new state
    for I := 0 to OldState.Count - 1 do
    begin
      Found := False;

      for J := 0 to NewState.Count - 1 do
      begin
        if (OldState.Points[I].X = NewState.Points[J].X) and
           (OldState.Points[I].Y = NewState.Points[J].Y) then
        begin
          Found := True;
          Break;
        end;
      end;

      if not Found then
      begin
        // Erase this point as it's not in the new state
        TConsole.SetCursorPos(OldState.Points[I].X, OldState.Points[I].Y);
        TConsole.Print(' ', False);
      end;
    end;

    // Now, draw new points or update changed points
    for I := 0 to NewState.Count - 1 do
    begin
      Found := False;

      for J := 0 to OldState.Count - 1 do
      begin
        if (NewState.Points[I].X = OldState.Points[J].X) and
           (NewState.Points[I].Y = OldState.Points[J].Y) and
           (NewState.Chars[I] = OldState.Chars[J]) and
           (NewState.Colors[I] = OldState.Colors[J]) then
        begin
          Found := True;
          Break;
        end;
      end;

      if not Found then
      begin
        // Draw this point as it's new or changed
        TConsole.SetCursorPos(NewState.Points[I].X, NewState.Points[I].Y);
        TConsole.SetForegroundColor(NewState.Colors[I]);
        TConsole.Print(NewState.Chars[I], False);
      end;
    end;

    // Swap states
    OldState.Count := NewState.Count;
    for I := 0 to NewState.Count - 1 do
    begin
      OldState.Points[I] := NewState.Points[I];
      OldState.Chars[I] := NewState.Chars[I];
      OldState.Colors[I] := NewState.Colors[I];
    end;

    // Reset new state
    NewState.Count := 0;
  end;

begin
  ClearInput();

  // Store original title
  OriginalTitle := TConsole.GetTitle;
  TConsole.SetTitle('TConsole Fractal Tree Demo');

  // Get console dimensions
  TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);

  // Hide cursor
  TConsole.HideCursor;

  // Initialize state buffers
  MaxPoints := ConsoleWidth * ConsoleHeight; // Maximum possible

  SetLength(OldState.Points, MaxPoints);
  SetLength(OldState.Chars, MaxPoints);
  SetLength(OldState.Colors, MaxPoints);
  OldState.Count := 0;

  SetLength(NewState.Points, MaxPoints);
  SetLength(NewState.Chars, MaxPoints);
  SetLength(NewState.Colors, MaxPoints);
  NewState.Count := 0;

  // Root position
  RootX := ConsoleWidth div 2;
  RootY := ConsoleHeight - 2;

  // Setup timing
  FrameTimeMs := 1000 div FPS;
  StartTime := Now;
  LastFrameTime := StartTime;

  // Clear screen once at the beginning
  TConsole.ClearScreen;

  // Main loop
  try
    repeat
      // Get current time
      CurrentTime := Now;
      ElapsedMs := Round((CurrentTime - StartTime) * 24 * 60 * 60 * 1000);

      // Check if it's time for a new frame
      if Round((CurrentTime - LastFrameTime) * 24 * 60 * 60 * 1000) >= FrameTimeMs then
      begin
        // Reset new state
        NewState.Count := 0;

        // Calculate animation parameters
        Angle := -Pi/2; // Start growing upward
        BranchAngle := Pi/6 + Sin(ElapsedMs / 2000.0) * Pi/12;

        // Draw the fractal tree
        DrawBranch(RootX, RootY, Angle, ConsoleHeight / 4, 0);

        // Update display
        UpdateDisplay;

        // Display info
        TConsole.SetCursorPos(2, ConsoleHeight - 1);
        TConsole.SetForegroundColor(CSIFGWhite);
        TConsole.Print('Fractal Tree Animation - Angle: %.2f - Points: %d  ',
                      [BranchAngle * 180 / Pi, NewState.Count], False);

        // Update last frame time
        LastFrameTime := CurrentTime;
      end;

      // Sleep to reduce CPU usage
      Sleep(5);

    until (ElapsedMs >= DEMO_DURATION) or TConsole.AnyKeyPressed;

    // Clean up
    TConsole.ClearScreen;
    TConsole.ResetTextFormat;
    TConsole.ShowCursor;
    TConsole.SetTitle(OriginalTitle);

  except
    on E: Exception do
    begin
      TConsole.ClearScreen;
      TConsole.ResetTextFormat;
      TConsole.ShowCursor;
      TConsole.SetTitle(OriginalTitle);

      TConsole.SetForegroundColor(CSIFGRed);
      TConsole.PrintLn('Error: %s', [E.Message], False);
      TConsole.ResetTextFormat;
    end;
  end;
end;

// Rain Effect Demo
procedure Demo_RainEffect;
const
  DEMO_DURATION = 15000; // 15 seconds
  FPS = 30;
  MAX_DROPS = 200;
  LIGHTNING_CHANCE = 0.005; // Probability of lightning per frame
  LIGHTNING_DURATION = 2; // Number of frames lightning stays visible
type
  TRainDrop = record
    X, Y: Double;
    Speed: Double;
    Length: Integer;
    Active: Boolean;
    LastX, LastY: array of Integer; // Track the "tail" positions
  end;
var
  Drops: array of TRainDrop;
  ConsoleWidth, ConsoleHeight: Integer;
  OriginalTitle: string;
  StartTime, CurrentTime, LastFrameTime: TDateTime;
  ElapsedMs, FrameTimeMs: Int64;
  I: Integer;
  LightningActive: Boolean;
  LightningFrames: Integer;

  // Initialize a raindrop
  procedure InitDrop(var Drop: TRainDrop);
  var
    J: Integer;
  begin
    Drop.X := Random(ConsoleWidth);
    Drop.Y := Random(10) - 10;  // Start above screen
    Drop.Speed := 0.3 + Random * 0.7;
    Drop.Length := 1 + Random(4);
    Drop.Active := True;

    // Initialize tail positions
    SetLength(Drop.LastX, Drop.Length);
    SetLength(Drop.LastY, Drop.Length);

    for J := 0 to Drop.Length - 1 do
    begin
      Drop.LastX[J] := -1;  // Invalid position
      Drop.LastY[J] := -1;
    end;
  end;

  // Update and draw raindrops
  procedure UpdateRain;
  var
    I, J: Integer;
    IntX, IntY: Integer;
  begin
    // First clear all old positions
    for I := 0 to MAX_DROPS - 1 do
    begin
      if Drops[I].Active then
      begin
        for J := 0 to Drops[I].Length - 1 do
        begin
          if (Drops[I].LastX[J] >= 0) and (Drops[I].LastY[J] >= 0) and
             (Drops[I].LastX[J] < ConsoleWidth) and (Drops[I].LastY[J] < ConsoleHeight) then
          begin
            TConsole.SetCursorPos(Drops[I].LastX[J], Drops[I].LastY[J]);
            TConsole.Print(' ', False); // Erase old position
          end;
        end;
      end;
    end;

    // Check for lightning
    if (not LightningActive) and (Random < LIGHTNING_CHANCE) then
    begin
      LightningActive := True;
      LightningFrames := LIGHTNING_DURATION;

      // Flash the screen with lightning
      for I := 0 to ConsoleWidth - 1 do
      begin
        for J := 0 to 5 do // Only flash top portion of screen
        begin
          TConsole.SetCursorPos(I, J);
          TConsole.SetBackgroundColor(CSIBGBrightWhite);
          TConsole.Print(' ', False);
        end;
      end;
      TConsole.ResetTextFormat;
    end;

    // Fade lightning
    if LightningActive then
    begin
      Dec(LightningFrames);

      if LightningFrames <= 0 then
      begin
        LightningActive := False;

        // Clear lightning effect
        for I := 0 to ConsoleWidth - 1 do
        begin
          for J := 0 to 5 do
          begin
            TConsole.SetCursorPos(I, J);
            TConsole.Print(' ', False);
          end;
        end;
      end;
    end;

    // Then update and draw new positions
    for I := 0 to MAX_DROPS - 1 do
    begin
      if Drops[I].Active then
      begin
        // Update position
        Drops[I].Y := Drops[I].Y + Drops[I].Speed;

        // Check if offscreen
        if Drops[I].Y >= ConsoleHeight then
        begin
          InitDrop(Drops[I]); // Reset
          Continue;
        end;

        // Shift tail positions
        for J := Drops[I].Length - 1 downto 1 do
        begin
          Drops[I].LastX[J] := Drops[I].LastX[J-1];
          Drops[I].LastY[J] := Drops[I].LastY[J-1];
        end;

        // Set new head position
        IntX := Round(Drops[I].X);
        IntY := Round(Drops[I].Y);
        Drops[I].LastX[0] := IntX;
        Drops[I].LastY[0] := IntY;

        // Draw raindrop and its tail
        for J := 0 to Drops[I].Length - 1 do
        begin
          if (Drops[I].LastX[J] >= 0) and (Drops[I].LastY[J] >= 0) and
             (Drops[I].LastX[J] < ConsoleWidth) and (Drops[I].LastY[J] < ConsoleHeight) then
          begin
            TConsole.SetCursorPos(Drops[I].LastX[J], Drops[I].LastY[J]);

            // Head is brighter, tail gets dimmer
            if J = 0 then
            begin
              if LightningActive then
                TConsole.SetForegroundColor(CSIFGBrightWhite)
              else
                TConsole.SetForegroundColor(CSIFGBrightCyan);
              TConsole.Print('|', False);
            end
            else if J = 1 then
            begin
              TConsole.SetForegroundColor(CSIFGCyan);
              TConsole.Print('|', False);
            end
            else
            begin
              TConsole.SetForegroundColor(CSIFGBlue);
              TConsole.Print('.', False);
            end;
          end;
        end;
      end
      else
      begin
        // Initialize inactive drops
        InitDrop(Drops[I]);
      end;
    end;

    // Display info
    TConsole.SetCursorPos(2, ConsoleHeight - 1);
    TConsole.SetForegroundColor(CSIFGWhite);

    if LightningActive then
      TConsole.Print('Rain Effect Demo - LIGHTNING! - Drops: %d   ', [MAX_DROPS], False)
    else
      TConsole.Print('Rain Effect Demo - Drops: %d   ', [MAX_DROPS], False);
  end;

begin
  ClearInput();

  // Store original title
  OriginalTitle := TConsole.GetTitle;
  TConsole.SetTitle('TConsole Rain Effect Demo');

  // Get console dimensions
  TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);

  // Hide cursor
  TConsole.HideCursor;

  // Initialize raindrops
  SetLength(Drops, MAX_DROPS);
  for I := 0 to MAX_DROPS - 1 do
    InitDrop(Drops[I]);

  // Initialize lightning
  LightningActive := False;
  LightningFrames := 0;

  // Setup timing
  FrameTimeMs := 1000 div FPS;
  StartTime := Now;
  LastFrameTime := StartTime;

  // Clear screen once at the beginning
  TConsole.ClearScreen;

  // Initialize random seed
  Randomize;

  // Main loop
  try
    repeat
      // Get current time
      CurrentTime := Now;
      ElapsedMs := Round((CurrentTime - StartTime) * 24 * 60 * 60 * 1000);

      // Check if it's time for a new frame
      if Round((CurrentTime - LastFrameTime) * 24 * 60 * 60 * 1000) >= FrameTimeMs then
      begin
        // Update and draw rain
        UpdateRain;

        // Update last frame time
        LastFrameTime := CurrentTime;
      end;

      // Sleep to reduce CPU usage
      Sleep(5);

    until (ElapsedMs >= DEMO_DURATION) or TConsole.AnyKeyPressed;

    // Clean up
    TConsole.ClearScreen;
    TConsole.ResetTextFormat;
    TConsole.ShowCursor;
    TConsole.SetTitle(OriginalTitle);

  except
    on E: Exception do
    begin
      TConsole.ClearScreen;
      TConsole.ResetTextFormat;
      TConsole.ShowCursor;
      TConsole.SetTitle(OriginalTitle);

      TConsole.SetForegroundColor(CSIFGRed);
      TConsole.PrintLn('Error: %s', [E.Message], False);
      TConsole.ResetTextFormat;
    end;
  end;
end;

// Fire Effect Demo
procedure Demo_FireEffect;
const
  DEMO_DURATION = 15000; // 15 seconds
  FPS = 30;
  FIRE_HEIGHT = 16;
var
  FireBuffer: array of array of Integer;
  ConsoleWidth, ConsoleHeight: Integer;
  OriginalTitle: string;
  StartTime, CurrentTime, LastFrameTime: TDateTime;
  ElapsedMs, FrameTimeMs: Int64;
  X, Y{, Value, LastValue}: Integer;
  LastChar: array of array of Char;
  LastColor: array of array of string;

  // Update the fire simulation
  procedure UpdateFire;
  var
    X, Y, Value: Integer;
    Left, Right: Integer;
    Ch: Char;
    Color: string;
  begin
    // 1. Seed bottom row with random values
    for X := 0 to ConsoleWidth - 1 do
    begin
      // Base fire level varies slightly over time
      if Random(3) = 0 then
        FireBuffer[ConsoleHeight - 1][X] := 35 + Random(5)
      else if X = 0 then
        FireBuffer[ConsoleHeight - 1][X] := Max(25, FireBuffer[ConsoleHeight - 1][ConsoleWidth-1])
      else
        FireBuffer[ConsoleHeight - 1][X] := Max(25, FireBuffer[ConsoleHeight - 1][X-1]);

      // Create hotspots randomly
      if Random(100) < 15 then
        FireBuffer[ConsoleHeight - 1][X] := 40 + Random(10);
    end;

    // 2. Propagate fire upwards
    for Y := 0 to ConsoleHeight - 2 do
    begin
      for X := 0 to ConsoleWidth - 1 do
      begin
        // Get neighbor positions (wrapping at edges)
        Left := (X - 1 + ConsoleWidth) mod ConsoleWidth;
        Right := (X + 1) mod ConsoleWidth;

        // Calculate new value based on cells below
        Value := (
          FireBuffer[Y + 1][Left] +
          FireBuffer[Y + 1][X] +
          FireBuffer[Y + 1][Right] +
          FireBuffer[Y + 1][X]
        ) div 4;

        // Apply decay
        if Value > 0 then
          if Random(3) = 0 then
            Dec(Value);

        // Store new value
        FireBuffer[Y][X] := Value;
      end;
    end;

    // 3. Render fire
    for Y := 0 to ConsoleHeight - 1 do
    begin
      for X := 0 to ConsoleWidth - 1 do
      begin
        Value := FireBuffer[Y][X];

        // Map value to appearance
        if Value > 35 then
        begin
          Ch := '#';
          Color := CSIFGBrightYellow;
        end
        else if Value > 30 then
        begin
          Ch := '*';
          Color := CSIFGYellow;
        end
        else if Value > 25 then
        begin
          Ch := '+';
          Color := CSIFGBrightRed;
        end
        else if Value > 20 then
        begin
          Ch := 'o';
          Color := CSIFGRed;
        end
        else if Value > 15 then
        begin
          Ch := '.';
          Color := CSIFGBrightBlack;
        end
        else
        begin
          Ch := ' ';
          Color := CSIFGBlack;
        end;

        // Only update if changed
        if (LastChar[Y][X] <> Ch) or (LastColor[Y][X] <> Color) then
        begin
          TConsole.SetCursorPos(X, Y);
          TConsole.SetForegroundColor(Color);
          TConsole.Print(Ch, False);

          LastChar[Y][X] := Ch;
          LastColor[Y][X] := Color;
        end;
      end;
    end;

    // Display info
    TConsole.SetCursorPos(2, ConsoleHeight - 1);
    TConsole.SetForegroundColor(CSIFGWhite);
    TConsole.Print('Fire Effect Demo - Time: %.1fs   ', [ElapsedMs / 1000.0], False);
  end;

begin
  ClearInput();

  // Store original title
  OriginalTitle := TConsole.GetTitle;
  TConsole.SetTitle('TConsole Fire Effect Demo');

  // Get console dimensions
  TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);

  // Hide cursor
  TConsole.HideCursor;

  // Initialize fire buffer
  SetLength(FireBuffer, ConsoleHeight, ConsoleWidth);
  for Y := 0 to ConsoleHeight - 1 do
    for X := 0 to ConsoleWidth - 1 do
      FireBuffer[Y][X] := 0;

  // Initialize last drawn state
  SetLength(LastChar, ConsoleHeight, ConsoleWidth);
  SetLength(LastColor, ConsoleHeight, ConsoleWidth);
  for Y := 0 to ConsoleHeight - 1 do
    for X := 0 to ConsoleWidth - 1 do
    begin
      LastChar[Y][X] := ' ';
      LastColor[Y][X] := '';
    end;

  // Setup timing
  FrameTimeMs := 1000 div FPS;
  StartTime := Now;
  LastFrameTime := StartTime;

  // Clear screen once at the beginning
  TConsole.ClearScreen;

  // Initialize random seed
  Randomize;

  // Main loop
  try
    repeat
      // Get current time
      CurrentTime := Now;
      ElapsedMs := Round((CurrentTime - StartTime) * 24 * 60 * 60 * 1000);

      // Check if it's time for a new frame
      if Round((CurrentTime - LastFrameTime) * 24 * 60 * 60 * 1000) >= FrameTimeMs then
      begin
        // Update and draw fire
        UpdateFire;

        // Update last frame time
        LastFrameTime := CurrentTime;
      end;

      // Sleep to reduce CPU usage
      Sleep(5);

    until (ElapsedMs >= DEMO_DURATION) or TConsole.AnyKeyPressed;

    // Clean up
    TConsole.ClearScreen;
    TConsole.ResetTextFormat;
    TConsole.ShowCursor;
    TConsole.SetTitle(OriginalTitle);

  except
    on E: Exception do
    begin
      TConsole.ClearScreen;
      TConsole.ResetTextFormat;
      TConsole.ShowCursor;
      TConsole.SetTitle(OriginalTitle);

      TConsole.SetForegroundColor(CSIFGRed);
      TConsole.PrintLn('Error: %s', [E.Message], False);
      TConsole.ResetTextFormat;
    end;
  end;
end;

// Particle System Demo with Flicker-Free Rendering
procedure Demo_ParticleSystem;
const
  MAX_PARTICLES = 500;
  GRAVITY = 0.05;
  FPS = 30;
  DEMO_DURATION = 10000; // 10 seconds
type
  TParticle = record
    X, Y: Double;
    VelX, VelY: Double;
    Color: string;
    Ch: Char;
    Age: Integer;
    MaxAge: Integer;
    Active: Boolean;
    LastX, LastY: Integer; // Track last drawn position
  end;
var
  Particles: array of TParticle;
  ConsoleWidth, ConsoleHeight: Integer;
  StartTime, CurrentTime, LastFrameTime: TDateTime;
  ElapsedMs, FrameTimeMs: Int64;
  I, EmitterX, EmitterY, LastEmitterX, LastEmitterY: Integer;
  OriginalTitle: string;

  // Initialize a particle
  procedure InitParticle(var P: TParticle; X, Y: Double);
  var
    ColorChoice: Integer;
    Speed, Angle: Double;
  begin
    P.X := X;
    P.Y := Y;
    P.LastX := -1; // Invalid position to force initial draw
    P.LastY := -1;

    // Random velocity
    Angle := Random * 2 * Pi;
    Speed := 0.2 + Random * 0.7;
    P.VelX := Cos(Angle) * Speed;
    P.VelY := Sin(Angle) * Speed - 0.5; // Initial upward bias

    // Random color
    ColorChoice := Random(7);
    case ColorChoice of
      0: P.Color := CSIFGRed;
      1: P.Color := CSIFGGreen;
      2: P.Color := CSIFGBlue;
      3: P.Color := CSIFGYellow;
      4: P.Color := CSIFGMagenta;
      5: P.Color := CSIFGCyan;
      6: P.Color := CSIFGWhite;
    end;

    // Random character
    case Random(4) of
      0: P.Ch := '*';
      1: P.Ch := '+';
      2: P.Ch := '•';
      3: P.Ch := '°';
    end;

    // Set lifetime
    P.Age := 0;
    P.MaxAge := 30 + Random(70);
    P.Active := True;
  end;

  // Update and draw all particles
  procedure UpdateParticles;
  var
    I, IntX, IntY: Integer;
    ParticlesActive: Integer;
  begin
    ParticlesActive := 0;

    // First erase old particle positions by drawing spaces
    for I := 0 to MAX_PARTICLES - 1 do
    begin
      if (Particles[I].LastX >= 0) and (Particles[I].LastY >= 0) and
         (Particles[I].LastX < ConsoleWidth) and (Particles[I].LastY < ConsoleHeight) then
      begin
        TConsole.SetCursorPos(Particles[I].LastX, Particles[I].LastY);
        TConsole.Print(' ', False);
      end;
    end;

    // Draw emitter marker (erase old one first)
    if (LastEmitterX >= 0) and (LastEmitterY >= 0) and
       (LastEmitterX < ConsoleWidth) and (LastEmitterY < ConsoleHeight) then
    begin
      TConsole.SetCursorPos(LastEmitterX, LastEmitterY);
      TConsole.Print(' ', False);
    end;

    // Draw new emitter
    TConsole.SetCursorPos(EmitterX, EmitterY);
    TConsole.SetForegroundColor(CSIFGBrightWhite);
    TConsole.Print('O', False);
    LastEmitterX := EmitterX;
    LastEmitterY := EmitterY;

    // Now update and draw particles
    for I := 0 to MAX_PARTICLES - 1 do
    begin
      if Particles[I].Active then
      begin
        // Update position
        Particles[I].X := Particles[I].X + Particles[I].VelX;
        Particles[I].Y := Particles[I].Y + Particles[I].VelY;

        // Apply gravity
        Particles[I].VelY := Particles[I].VelY + GRAVITY;

        // Apply age
        Particles[I].Age := Particles[I].Age + 1;

        // Get integer position
        IntX := Round(Particles[I].X);
        IntY := Round(Particles[I].Y);

        // Deactivate if too old or off screen
        if (Particles[I].Age >= Particles[I].MaxAge) or
           (IntX < 0) or (IntX >= ConsoleWidth) or
           (IntY < 0) or (IntY >= ConsoleHeight) then
        begin
          Particles[I].Active := False;
        end
        else
        begin
          // Draw particle at new position
          TConsole.SetCursorPos(IntX, IntY);
          TConsole.SetForegroundColor(Particles[I].Color);
          TConsole.Print(Particles[I].Ch, False);

          // Update last position
          Particles[I].LastX := IntX;
          Particles[I].LastY := IntY;

          Inc(ParticlesActive);
        end;
      end;
    end;

    // Spawn new particles at emitter
    if ParticlesActive < MAX_PARTICLES then
    begin
      for I := 0 to MAX_PARTICLES - 1 do
      begin
        if not Particles[I].Active then
        begin
          InitParticle(Particles[I], EmitterX, EmitterY);
          Inc(ParticlesActive);

          // Only create a few per frame
          if ParticlesActive >= MAX_PARTICLES - 5 then
            Break;
        end;
      end;
    end;

    // Display info (with static position to avoid flickering)
    TConsole.SetCursorPos(2, ConsoleHeight - 2);
    TConsole.SetForegroundColor(CSIFGWhite);
    // Use a fixed-width format to ensure consistent overwriting
    TConsole.Print('Particle System Demo - Active: %3d/%3d', [ParticlesActive, MAX_PARTICLES], False);
  end;

begin
  ClearInput();

  // Store original title
  OriginalTitle := TConsole.GetTitle;
  TConsole.SetTitle('TConsole Particle System Demo');

  // Get console dimensions
  TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);

  // Initialize emitter at center
  EmitterX := ConsoleWidth div 2;
  EmitterY := ConsoleHeight - 4;
  LastEmitterX := -1;
  LastEmitterY := -1;

  // Hide cursor
  TConsole.HideCursor;

  // Initialize particles
  SetLength(Particles, MAX_PARTICLES);
  for I := 0 to MAX_PARTICLES - 1 do
    Particles[I].Active := False;

  // Setup timing
  FrameTimeMs := 1000 div FPS;
  StartTime := Now;
  LastFrameTime := StartTime;

  // Clear screen once at the beginning
  TConsole.ClearScreen;

  // Main loop
  try
    repeat
      // Get current time
      CurrentTime := Now;
      ElapsedMs := Round((CurrentTime - StartTime) * 24 * 60 * 60 * 1000);

      // Check if it's time for a new frame
      if Round((CurrentTime - LastFrameTime) * 24 * 60 * 60 * 1000) >= FrameTimeMs then
      begin
        // Move emitter in a figure-8 pattern
        EmitterX := ConsoleWidth div 2 + Round(Sin(ElapsedMs / 1000.0) * (ConsoleWidth div 4));
        EmitterY := ConsoleHeight div 2 + Round(Sin(2 * ElapsedMs / 1000.0) * (ConsoleHeight div 4));

        // Update and draw particles
        UpdateParticles;

        // Update last frame time
        LastFrameTime := CurrentTime;
      end;

      // Sleep to reduce CPU usage
      Sleep(5);

    until (ElapsedMs >= DEMO_DURATION) or TConsole.AnyKeyPressed;

    // Clean up
    TConsole.ClearScreen;
    TConsole.ResetTextFormat;
    TConsole.ShowCursor;
    TConsole.SetTitle(OriginalTitle);

  except
    on E: Exception do
    begin
      TConsole.ClearScreen;
      TConsole.ResetTextFormat;
      TConsole.ShowCursor;
      TConsole.SetTitle(OriginalTitle);

      TConsole.SetForegroundColor(CSIFGRed);
      TConsole.PrintLn('Error: %s', [E.Message], False);
      TConsole.ResetTextFormat;
    end;
  end;
end;

// Color Tunnel Animation with Flicker-Free Rendering
procedure Demo_ColorTunnel;
const
  DURATION_MS = 10000; // 10 seconds
  FPS = 30;
type
  TLayer = record
    Size: Integer;
    Color: string;
    Char: Char;
  end;

  TPixel = record
    X, Y: Integer;
    Ch: Char;
    Color: string;
    Active: Boolean;
  end;
var
  Layers: array of TLayer;
  DisplayBuffer: array of TPixel;  // Store all active pixels
  BufferSize: Integer;
  ConsoleWidth, ConsoleHeight: Integer;
  CenterX, CenterY: Integer;
  OriginalTitle: string;
  StartTime, CurrentTime, LastFrameTime: TDateTime;
  ElapsedMs, FrameTimeMs: Int64;
  I, X, Y, Distance, BufferIndex: Integer;
  {Angle: Double;}
  InfoString: string;
begin
  ClearInput();

  // Store original title
  OriginalTitle := TConsole.GetTitle;
  TConsole.SetTitle('TConsole Color Tunnel Demo');

  // Get console dimensions
  TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);

  // Calculate center position
  CenterX := ConsoleWidth div 2;
  CenterY := ConsoleHeight div 2;

  // Hide cursor
  TConsole.HideCursor;

  // Initialize layers
  SetLength(Layers, 16);
  for I := 0 to High(Layers) do
  begin
    Layers[I].Size := I * 2;

    // Cycle through colors
    case I mod 8 of
      0: Layers[I].Color := CSIFGRed;
      1: Layers[I].Color := CSIFGYellow;
      2: Layers[I].Color := CSIFGGreen;
      3: Layers[I].Color := CSIFGCyan;
      4: Layers[I].Color := CSIFGBlue;
      5: Layers[I].Color := CSIFGMagenta;
      6: Layers[I].Color := CSIFGWhite;
      7: Layers[I].Color := CSIFGBrightCyan;
    end;

    // Alternate characters
    case I mod 4 of
      0: Layers[I].Char := '@';
      1: Layers[I].Char := '#';
      2: Layers[I].Char := '*';
      3: Layers[I].Char := '+';
    end;
  end;

  // Initialize display buffer (allocate max possible size)
  BufferSize := ConsoleWidth * ConsoleHeight;
  SetLength(DisplayBuffer, BufferSize);
  for I := 0 to BufferSize - 1 do
    DisplayBuffer[I].Active := False;

  // Setup timing
  FrameTimeMs := 1000 div FPS;
  StartTime := Now;
  LastFrameTime := StartTime;

  // Clear screen once at the beginning
  TConsole.ClearScreen;

  // Main loop
  try
    repeat
      // Get current time
      CurrentTime := Now;
      ElapsedMs := Round((CurrentTime - StartTime) * 24 * 60 * 60 * 1000);

      // Check if it's time for a new frame
      if Round((CurrentTime - LastFrameTime) * 24 * 60 * 60 * 1000) >= FrameTimeMs then
      begin
        // Clear all currently active pixels
        for I := 0 to BufferSize - 1 do
        begin
          if DisplayBuffer[I].Active then
          begin
            TConsole.SetCursorPos(DisplayBuffer[I].X, DisplayBuffer[I].Y);
            TConsole.Print(' ', False); // Erase
            DisplayBuffer[I].Active := False;
          end;
        end;

        // Update layer sizes with pulsating effect
        for I := 0 to High(Layers) do
        begin
          Layers[I].Size := Round((I * 2) + Sin(ElapsedMs / 500.0 + I * 0.3) * 4);
        end;

        // Reset buffer index
        BufferIndex := 0;

        // Draw from outer to inner layers
        for I := High(Layers) downto 0 do
        begin
          // Draw circle for this layer
          for Y := 0 to ConsoleHeight - 1 do
          begin
            for X := 0 to ConsoleWidth - 1 do
            begin
              // Calculate distance from center (scaled to make circles look right)
              Distance := Round(Sqrt(Sqr(X - CenterX) + Sqr((Y - CenterY) * 2)));

              // Draw if at the right distance
              if Distance = Layers[I].Size then
              begin
                // Store in buffer
                DisplayBuffer[BufferIndex].X := X;
                DisplayBuffer[BufferIndex].Y := Y;
                DisplayBuffer[BufferIndex].Ch := Layers[I].Char;
                DisplayBuffer[BufferIndex].Color := Layers[I].Color;
                DisplayBuffer[BufferIndex].Active := True;

                // Draw
                TConsole.SetCursorPos(X, Y);
                TConsole.SetForegroundColor(Layers[I].Color);
                TConsole.Print(Layers[I].Char, False);

                // Increment buffer index
                Inc(BufferIndex);
                if BufferIndex >= BufferSize then
                  Break; // Safety check
              end;
            end;

            if BufferIndex >= BufferSize then
              Break; // Safety check
          end;
        end;

        // Display info
        InfoString := Format('Color Tunnel Demo - Time: %.1fs', [ElapsedMs / 1000.0]);
        TConsole.SetCursorPos(2, ConsoleHeight - 2);
        TConsole.SetForegroundColor(CSIFGWhite);
        TConsole.Print(InfoString + StringOfChar(' ', 20), False); // Pad with spaces to overwrite

        // Update last frame time
        LastFrameTime := CurrentTime;
      end;

      // Sleep to reduce CPU usage
      Sleep(5);

    until (ElapsedMs >= DURATION_MS) or TConsole.AnyKeyPressed;

    // Clean up
    TConsole.ClearScreen;
    TConsole.ResetTextFormat;
    TConsole.ShowCursor;
    TConsole.SetTitle(OriginalTitle);

  except
    on E: Exception do
    begin
      TConsole.ClearScreen;
      TConsole.ResetTextFormat;
      TConsole.ShowCursor;
      TConsole.SetTitle(OriginalTitle);

      TConsole.SetForegroundColor(CSIFGRed);
      TConsole.PrintLn('Error: %s', [E.Message], False);
      TConsole.ResetTextFormat;
    end;
  end;
end;

// Flowing Text Demo with Flicker-Free Rendering
procedure Demo_FlowingText;
const
  DEMO_DURATION = 15000; // 15 seconds
  FPS = 30;
  MESSAGE = 'TConsole API - Advanced Terminal Graphics - Text Animation Demo - ';
  COLOR_CYCLE = 10; // Chars per color
type
  TTextParticle = record
    X, Y: Double;
    VelX, VelY: Double;
    Ch: Char;
    ColorIndex: Integer;
    Age: Integer;
    LastX, LastY: Integer; // Track last drawn position
  end;
var
  Particles: array of TTextParticle;
  ConsoleWidth, ConsoleHeight: Integer;
  OriginalTitle: string;
  StartTime, CurrentTime, LastFrameTime: TDateTime;
  ElapsedMs, FrameTimeMs: Int64;
  I, CharIndex, ColorIndex: Integer;
  MessageLen: Integer;
  T: Double;
  InfoString: string;
begin
  ClearInput();

  // Store original title
  OriginalTitle := TConsole.GetTitle;
  TConsole.SetTitle('TConsole Flowing Text Demo');

  // Get console dimensions
  TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);

  // Hide cursor
  TConsole.HideCursor;

  // Initialize particles
  MessageLen := Length(MESSAGE);
  SetLength(Particles, MessageLen * 2); // Multiple instances of the message

  for I := 0 to High(Particles) do
  begin
    CharIndex := I mod MessageLen;
    Particles[I].Ch := MESSAGE[CharIndex + 1];
    Particles[I].ColorIndex := (CharIndex div COLOR_CYCLE) mod 6;
    Particles[I].X := Random(ConsoleWidth);
    Particles[I].Y := Random(ConsoleHeight);
    Particles[I].LastX := -1; // Invalid initial position
    Particles[I].LastY := -1;
    Particles[I].VelX := 0.2 - Random * 0.4;
    Particles[I].VelY := 0.2 - Random * 0.4;

    // Ensure some velocity
    if Abs(Particles[I].VelX) < 0.05 then
      Particles[I].VelX := 0.05 * Sign(Particles[I].VelX);
    if Abs(Particles[I].VelY) < 0.05 then
      Particles[I].VelY := 0.05 * Sign(Particles[I].VelY);

    Particles[I].Age := Random(100);
  end;

  // Setup timing
  FrameTimeMs := 1000 div FPS;
  StartTime := Now;
  LastFrameTime := StartTime;

  // Clear screen once at the beginning
  TConsole.ClearScreen;

  // Main loop
  try
    repeat
      // Get current time
      CurrentTime := Now;
      ElapsedMs := Round((CurrentTime - StartTime) * 24 * 60 * 60 * 1000);

      // Check if it's time for a new frame
      if Round((CurrentTime - LastFrameTime) * 24 * 60 * 60 * 1000) >= FrameTimeMs then
      begin
        // Update time parameter
        T := ElapsedMs / 1000.0;

        // First erase old positions
        for I := 0 to High(Particles) do
        begin
          if (Particles[I].LastX >= 0) and (Particles[I].LastY >= 0) and
             (Particles[I].LastX < ConsoleWidth) and (Particles[I].LastY < ConsoleHeight) then
          begin
            TConsole.SetCursorPos(Particles[I].LastX, Particles[I].LastY);
            TConsole.Print(' ', False); // Erase
          end;
        end;

        // Update and draw particles
        for I := 0 to High(Particles) do
        begin
          // Update position with sinusoidal motion
          Particles[I].X := Particles[I].X + Particles[I].VelX * Sin(T * 0.5 + I * 0.1);
          Particles[I].Y := Particles[I].Y + Particles[I].VelY * Cos(T * 0.7 + I * 0.1);

          // Wrap around screen edges
          if Particles[I].X < 0 then
            Particles[I].X := ConsoleWidth - 1
          else if Particles[I].X >= ConsoleWidth then
            Particles[I].X := 0;

          if Particles[I].Y < 0 then
            Particles[I].Y := ConsoleHeight - 1
          else if Particles[I].Y >= ConsoleHeight then
            Particles[I].Y := 0;

          // Increment age
          Particles[I].Age := Particles[I].Age + 1;

          // Get integer position
          Particles[I].LastX := Round(Particles[I].X);
          Particles[I].LastY := Round(Particles[I].Y);

          // Draw particle
          TConsole.SetCursorPos(Particles[I].LastX, Particles[I].LastY);

          // Set color based on index and age (pulsating)
          ColorIndex := (Particles[I].ColorIndex + (Particles[I].Age div 20)) mod 6;
          case ColorIndex of
            0: TConsole.SetForegroundColor(CSIFGRed);
            1: TConsole.SetForegroundColor(CSIFGYellow);
            2: TConsole.SetForegroundColor(CSIFGGreen);
            3: TConsole.SetForegroundColor(CSIFGCyan);
            4: TConsole.SetForegroundColor(CSIFGBlue);
            5: TConsole.SetForegroundColor(CSIFGMagenta);
          end;

          TConsole.Print(Particles[I].Ch, False);
        end;

        // Display info with fixed width
        InfoString := Format('Flowing Text Demo - Time: %.1fs', [T]);
        TConsole.SetCursorPos(2, ConsoleHeight - 2);
        TConsole.SetForegroundColor(CSIFGWhite);
        TConsole.Print(InfoString + StringOfChar(' ', 20), False); // Pad with spaces to overwrite

        // Update last frame time
        LastFrameTime := CurrentTime;
      end;

      // Sleep to reduce CPU usage
      Sleep(5);

    until (ElapsedMs >= DEMO_DURATION) or TConsole.AnyKeyPressed;

    // Clean up
    TConsole.ClearScreen;
    TConsole.ResetTextFormat;
    TConsole.ShowCursor;
    TConsole.SetTitle(OriginalTitle);

  except
    on E: Exception do
    begin
      TConsole.ClearScreen;
      TConsole.ResetTextFormat;
      TConsole.ShowCursor;
      TConsole.SetTitle(OriginalTitle);

      TConsole.SetForegroundColor(CSIFGRed);
      TConsole.PrintLn('Error: %s', [E.Message], False);
      TConsole.ResetTextFormat;
    end;
  end;
end;

// Advanced Animation and Effects Test
procedure Demo_AdvancedAnimations;
const
  FRAMES = 30;
  WIDTH = 80;
  HEIGHT = 20;
  DURATION_MS = 3000;
  FPS = 30; // Target frames per second
var
  StartTime, EndTime, CurrentTime, LastFrameTime: TDateTime;
  ElapsedMs, TotalMs, {FrameMs,} TargetFrameTimeMs: Int64;
  T: Double;
  XPos, YPos: Double;
  IntX, IntY: Integer;
  CenterX, CenterY: Integer;
  ConsoleWidth, ConsoleHeight: Integer;
  OriginalTitle: string;
  Value: Double;
  Red, Green, Blue: Integer;
  LastRenderTime: TDateTime;
  FrameCount: Integer;
  SleepTime: Integer;
  Buffer: array of array of record
    Ch: Char;
    FgColor: string;
    BgColor: string;
    LastRed, LastGreen, LastBlue: Integer;
    NeedsUpdate: Boolean;
  end;
begin
  ClearInput();

  // Store the original title and set a test title
  OriginalTitle := TConsole.GetTitle;
  TConsole.SetTitle('TConsole Advanced Animation Test');

  // Get console dimensions
  TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);

  // Calculate center position
  CenterX := ConsoleWidth div 2;
  CenterY := ConsoleHeight div 2;

  // Hide cursor during animation
  TConsole.HideCursor;

  // Initialize buffer with tracking for changes
  SetLength(Buffer, ConsoleHeight, ConsoleWidth);
  for IntY := 0 to ConsoleHeight - 1 do
    for IntX := 0 to ConsoleWidth - 1 do
    begin
      Buffer[IntY][IntX].Ch := ' ';
      Buffer[IntY][IntX].FgColor := CSIFGWhite;
      Buffer[IntY][IntX].BgColor := CSIBGBlack;
      Buffer[IntY][IntX].LastRed := -1;    // Invalid value to force initial update
      Buffer[IntY][IntX].LastGreen := -1;
      Buffer[IntY][IntX].LastBlue := -1;
      Buffer[IntY][IntX].NeedsUpdate := True;
    end;

  // Animation parameters
  TotalMs := DURATION_MS;
  //FrameMs := TotalMs div FRAMES;
  TargetFrameTimeMs := 1000 div FPS; // Time per frame in ms

  // Start timer
  StartTime := Now;
  LastFrameTime := StartTime;
  EndTime := StartTime + (TotalMs / (24 * 60 * 60 * 1000));

  // Frame counter
  FrameCount := 0;

  // Initial screen clear
  TConsole.ClearScreen;

  // Main animation loop
  repeat
    // Get current time
    CurrentTime := Now;
    ElapsedMs := Round((CurrentTime - StartTime) * 24 * 60 * 60 * 1000);

    // Calculate animation parameter (0.0 to 1.0)
    T := ElapsedMs / TotalMs;
    if T > 1.0 then T := 1.0;

    // Calculate time since last frame
    LastRenderTime := CurrentTime - LastFrameTime;

    // Only render a new frame if enough time has passed
    if (LastRenderTime * 24 * 60 * 60 * 1000) >= TargetFrameTimeMs then
    begin
      // Update frame counter
      Inc(FrameCount);

      // Draw a plasma-like effect
      for IntY := 0 to ConsoleHeight - 1 do
      begin
        YPos := IntY; // Convert to Double for calculations

        for IntX := 0 to ConsoleWidth - 1 do
        begin
          XPos := IntX; // Convert to Double for calculations

          // Generate plasma value
          Value := Sin((XPos - CenterX) * 0.2 + T * 3.14159 * 2) +
                   Cos((YPos - CenterY) * 0.2) +
                   Sin(0.1 * Sqrt(Sqr(XPos - CenterX) + Sqr(YPos - CenterY)) + T * 3.14159 * 2);

          Value := (Value + 3) / 6;  // Normalize to 0..1

          // Choose character based on value
          case Trunc(Value * 5) of
            0: Buffer[IntY][IntX].Ch := ' ';
            1: Buffer[IntY][IntX].Ch := '.';
            2: Buffer[IntY][IntX].Ch := '+';
            3: Buffer[IntY][IntX].Ch := '*';
            4: Buffer[IntY][IntX].Ch := '#';
          end;

          // RGB Colors based on value
          Red := Trunc(Sin(Value * 3.14159 * 2) * 127 + 128);
          Green := Trunc(Sin(Value * 3.14159 * 2 + 3.14159 * 2/3) * 127 + 128);
          Blue := Trunc(Sin(Value * 3.14159 * 2 + 3.14159 * 4/3) * 127 + 128);

          // Only update if something changed
          if (Buffer[IntY][IntX].LastRed <> Red) or
             (Buffer[IntY][IntX].LastGreen <> Green) or
             (Buffer[IntY][IntX].LastBlue <> Blue) then
          begin
            Buffer[IntY][IntX].LastRed := Red;
            Buffer[IntY][IntX].LastGreen := Green;
            Buffer[IntY][IntX].LastBlue := Blue;
            Buffer[IntY][IntX].NeedsUpdate := True;
          end;
        end;
      end;

      // Draw only the pixels that changed
      for IntY := 0 to ConsoleHeight - 1 do
      begin
        for IntX := 0 to ConsoleWidth - 1 do
        begin
          if Buffer[IntY][IntX].NeedsUpdate then
          begin
            TConsole.SetCursorPos(IntX, IntY);
            TConsole.SetForegroundRGB(Buffer[IntY][IntX].LastRed,
                                      Buffer[IntY][IntX].LastGreen,
                                      Buffer[IntY][IntX].LastBlue);
            TConsole.Print(Buffer[IntY][IntX].Ch, False);
            Buffer[IntY][IntX].NeedsUpdate := False;
          end;
        end;
      end;

      // Display frame info
      TConsole.SetCursorPos(2, ConsoleHeight - 2);
      TConsole.SetForegroundColor(CSIFGWhite);
      TConsole.Print('Frame: %d/%d | Progress: %.1f%%',
        [FrameCount, FRAMES, T * 100], False);

      // Update last frame time
      LastFrameTime := CurrentTime;
    end;

    // Calculate time to sleep
    SleepTime := TargetFrameTimeMs - Round((Now - CurrentTime) * 24 * 60 * 60 * 1000);
    if SleepTime > 0 then
      Sleep(SleepTime)
    else
      Sleep(1); // Yield CPU time

  until CurrentTime >= EndTime;

  // Show final frame
  Sleep(500);

  // Clean up
  TConsole.ClearScreen;
  TConsole.ResetTextFormat;
  TConsole.ShowCursor;
  TConsole.SetTitle(OriginalTitle);
end;

// Advanced Console Effects Demo
procedure Demo_AdvancedEffects;
const
  DURATION_MS = 5000;
  WAVE_WIDTH = 60;
  WAVE_HEIGHT = 15;
  MATRIX_SPEED = 3;
  RAIN_DENSITY = 0.2;
  FIREWORKS_COUNT = 3;
  FPS = 30;
  TOTAL_PHASES = 4; // Total number of demo phases

type
  TFireworkParticle = record
    X, Y: Double;
    VelX, VelY: Double;
    Age: Integer;
    MaxAge: Integer;
    Color: string;
    Ch: Char;
  end;

  TRainDrop = record
    X, Y: Double;
    Speed: Double;
    Length: Integer;
    Ch: Char;
  end;

var
  ConsoleWidth, ConsoleHeight: Integer;
  OriginalTitle: string;
  StartTime, CurrentTime, LastFrameTime: TDateTime;
  ElapsedMs, TotalMs, FrameTime: Int64;
  DemoPhase, LastDemoPhase: Integer;
  {I,} X, Y: Integer;
  RainDrops: array of TRainDrop;
  Fireworks: array of array of TFireworkParticle;
  FireworkCount: Integer;
  T{, Value}: Double;
  Angle, Amplitude: Double;
  //TotalElapsedMs: Int64; // Track total elapsed time across all phases
  PhaseStartTime: TDateTime; // Track when the current phase started
  CompletedPhases: Integer; // Track number of completed phases

  // Draw digital rain effect
  procedure DrawDigitalRain;
  var
    I, TailY, IntX, IntY: Integer;
  begin
    // Update rain drops
    for I := 0 to Length(RainDrops) - 1 do
    begin
      // Move drop down
      RainDrops[I].Y := RainDrops[I].Y + RainDrops[I].Speed;

      // Reset if off screen
      if RainDrops[I].Y > ConsoleHeight + RainDrops[I].Length then
      begin
        RainDrops[I].X := Random(ConsoleWidth);
        RainDrops[I].Y := -RainDrops[I].Length;
        RainDrops[I].Speed := 0.1 + Random * 0.3;
      end;

      // Draw drop
      IntX := Round(RainDrops[I].X);
      IntY := Round(RainDrops[I].Y);

      if (IntX >= 0) and (IntX < ConsoleWidth) then
      begin
        // Draw tail
        for TailY := 0 to RainDrops[I].Length - 1 do
        begin
          if (IntY - TailY >= 0) and (IntY - TailY < ConsoleHeight) then
          begin
            TConsole.SetCursorPos(IntX, IntY - TailY);

            // Head is brighter
            if TailY = 0 then
              TConsole.SetForegroundColor(CSIFGBrightGreen)
            else
              TConsole.SetForegroundColor(CSIFGGreen);

            TConsole.Print(RainDrops[I].Ch, False);
          end;
        end;
      end;
    end;

    // Show info
    TConsole.SetCursorPos(2, ConsoleHeight - 2);
    TConsole.SetForegroundColor(CSIFGWhite);
    TConsole.Print('Matrix Digital Rain - %d raindrops', [Length(RainDrops)], False);
  end;

  // Draw sine wave animation
  procedure DrawSineWave;
  var
    X, Y, WaveY: Integer;
    SineValue: Double;
  begin
    // Calculate time-based parameter
    T := ElapsedMs / 500.0;

    // Draw sine wave
    for X := 0 to WAVE_WIDTH - 1 do
    begin
      // Calculate base sine value
      SineValue := Sin((X / WAVE_WIDTH * 6 * Pi) + T) *
                  (1 + 0.5 * Sin(T * 0.5)); // Modulate amplitude

      // Calculate Y position
      WaveY := Round((WAVE_HEIGHT / 2) * (1 + SineValue));

      // Draw at calculated position
      for Y := 0 to WAVE_HEIGHT - 1 do
      begin
        // Center in console
        TConsole.SetCursorPos((ConsoleWidth - WAVE_WIDTH) div 2 + X,
                             (ConsoleHeight - WAVE_HEIGHT) div 2 + Y);

        if Y = WaveY then
        begin
          // Wave line position
          TConsole.SetForegroundColor(CSIFGBrightCyan);
          TConsole.Print('~', False);
        end
        else if Abs(Y - WaveY) <= 1 then
        begin
          // Glow around wave line
          TConsole.SetForegroundColor(CSIFGCyan);
          TConsole.Print('·', False);
        end
        else
        begin
          // Background
          TConsole.Print(' ', False);
        end;
      end;
    end;

    // Draw wave parameters
    TConsole.SetCursorPos((ConsoleWidth - 40) div 2,
                       (ConsoleHeight + WAVE_HEIGHT) div 2 + 2);
    TConsole.SetForegroundColor(CSIFGWhite);
    TConsole.Print('Sine Wave Animation - t: %.2f', [T], False);
  end;

  // Initialize fireworks system
  procedure InitFireworks;
  begin
    FireworkCount := 0;
    SetLength(Fireworks, 0);
  end;

  // Create a new firework
  procedure CreateFirework(Origin_X, Origin_Y: Integer);
  var
    ParticleCount, I: Integer;
    Color: string;
  begin
    FireworkCount := FireworkCount + 1;
    SetLength(Fireworks, FireworkCount);

    // Random number of particles
    ParticleCount := 50 + Random(50);
    SetLength(Fireworks[FireworkCount-1], ParticleCount);

    // Choose random color
    case Random(7) of
      0: Color := CSIFGRed;
      1: Color := CSIFGGreen;
      2: Color := CSIFGBlue;
      3: Color := CSIFGYellow;
      4: Color := CSIFGMagenta;
      5: Color := CSIFGCyan;
      6: Color := CSIFGWhite;
    end;

    // Initialize particles
    for I := 0 to ParticleCount - 1 do
    begin
      Fireworks[FireworkCount-1][I].X := Origin_X;
      Fireworks[FireworkCount-1][I].Y := Origin_Y;

      // Random velocity in circle
      Angle := Random * 2 * Pi;
      Amplitude := 0.1 + Random * 0.3;
      Fireworks[FireworkCount-1][I].VelX := Cos(Angle) * Amplitude;
      Fireworks[FireworkCount-1][I].VelY := Sin(Angle) * Amplitude;

      // Random lifespan
      Fireworks[FireworkCount-1][I].Age := 0;
      Fireworks[FireworkCount-1][I].MaxAge := 20 + Random(30);
      Fireworks[FireworkCount-1][I].Color := Color;

      // Random character
      case Random(6) of
        0: Fireworks[FireworkCount-1][I].Ch := '*';
        1: Fireworks[FireworkCount-1][I].Ch := '+';
        2: Fireworks[FireworkCount-1][I].Ch := '.';
        3: Fireworks[FireworkCount-1][I].Ch := 'o';
        4: Fireworks[FireworkCount-1][I].Ch := '•';
        5: Fireworks[FireworkCount-1][I].Ch := '°';
      end;
    end;
  end;

  // Update and draw fireworks
  procedure UpdateFireworks;
  var
    F, P, IntX, IntY: Integer;
    ActiveFireworks{, FireworkFinished}: Boolean;
  begin
    ActiveFireworks := False;

    for F := 0 to FireworkCount - 1 do
    begin
      //FireworkFinished := True;

      for P := 0 to Length(Fireworks[F]) - 1 do
      begin
        // Update position
        Fireworks[F][P].X := Fireworks[F][P].X + Fireworks[F][P].VelX;
        Fireworks[F][P].Y := Fireworks[F][P].Y + Fireworks[F][P].VelY;

        // Apply gravity
        Fireworks[F][P].VelY := Fireworks[F][P].VelY + 0.01;

        // Age particle
        Fireworks[F][P].Age := Fireworks[F][P].Age + 1;

        // Check if particle is still alive
        if Fireworks[F][P].Age < Fireworks[F][P].MaxAge then
        begin
          //FireworkFinished := False;
          ActiveFireworks := True;

          // Draw particle
          IntX := Round(Fireworks[F][P].X);
          IntY := Round(Fireworks[F][P].Y);

          if (IntX >= 0) and (IntX < ConsoleWidth) and
             (IntY >= 0) and (IntY < ConsoleHeight) then
          begin
            TConsole.SetCursorPos(IntX, IntY);
            TConsole.SetForegroundColor(Fireworks[F][P].Color);
            TConsole.Print(Fireworks[F][P].Ch, False);
          end;
        end;
      end;
    end;

    // Create new fireworks if needed
    if (not ActiveFireworks) or (FireworkCount < FIREWORKS_COUNT) then
    begin
      CreateFirework(Random(ConsoleWidth), Random(ConsoleHeight div 2));
    end;

    // Show info
    TConsole.SetCursorPos(2, ConsoleHeight - 2);
    TConsole.SetForegroundColor(CSIFGWhite);
    TConsole.Print('Fireworks Animation - %d active fireworks', [FireworkCount], False);
  end;

  // Initialize rain drops
  procedure InitRainDrops;
  var
    I: Integer;
  begin
    SetLength(RainDrops, Round(ConsoleWidth * RAIN_DENSITY * 10));

    for I := 0 to Length(RainDrops) - 1 do
    begin
      RainDrops[I].X := Random(ConsoleWidth);
      RainDrops[I].Y := Random(ConsoleHeight) - ConsoleHeight;
      RainDrops[I].Speed := 0.1 + Random * 0.3;
      RainDrops[I].Length := 1 + Random(5);

      // Select random character for this drop
      case Random(3) of
        0: RainDrops[I].Ch := '|';
        1: RainDrops[I].Ch := '.';
        2: RainDrops[I].Ch := ':';
      end;
    end;
  end;

  // Draw a starfield effect
  procedure DrawStarfield;
  var
    StarX, StarY: Integer;
    NumStars, I: Integer;
    StarChar: Char;
    StarColor: string;
    StarDistance: Integer;
    StarAngle: Double;
    TimeValue: Integer;
  begin
    // Create time parameter as integer
    TimeValue := Round(ElapsedMs / 200.0);

    // Center point (origin)
    StarX := ConsoleWidth div 2;
    StarY := ConsoleHeight div 2;

    // Number of stars
    NumStars := 500;

    // Draw each star
    for I := 0 to NumStars - 1 do
    begin
      // Calculate position using parametric equations
      // This creates a zoom-in effect
      StarAngle := (I * 0.1) + (I mod 10) * 0.1;
      StarDistance := 1 + ((I mod 100) + TimeValue) mod 50;

      // Convert to screen coordinates
      X := StarX + Round(Cos(StarAngle) * StarDistance);
      Y := StarY + Round(Sin(StarAngle) * StarDistance / 2); // Half Y to account for character aspect ratio

      // Skip if outside screen
      if (X < 0) or (X >= ConsoleWidth) or (Y < 0) or (Y >= ConsoleHeight) then
        Continue;

      // Determine star appearance based on distance
      if StarDistance > 40 then
      begin
        StarChar := '.';
        StarColor := CSIFGBrightWhite;
      end
      else if StarDistance > 30 then
      begin
        StarChar := 'o';
        StarColor := CSIFGWhite;
      end
      else if StarDistance > 20 then
      begin
        StarChar := 'O';
        StarColor := CSIFGBrightYellow;
      end
      else if StarDistance > 10 then
      begin
        StarChar := '*';
        StarColor := CSIFGYellow;
      end
      else
      begin
        StarChar := '#';
        StarColor := CSIFGBrightYellow;
      end;

      // Draw star
      TConsole.SetCursorPos(X, Y);
      TConsole.SetForegroundColor(StarColor);
      TConsole.Print(StarChar, False);
    end;

    // Draw info text
    TConsole.SetCursorPos(2, ConsoleHeight - 2);
    TConsole.SetForegroundColor(CSIFGWhite);
    TConsole.Print('Starfield Animation - time: %d', [TimeValue], False);
  end;

  // Draw header and footer info
  procedure DrawUIInfo;
  var
    PhaseTimeRemaining: Int64;
  begin
    PhaseTimeRemaining := TotalMs - (ElapsedMs mod TotalMs);

    // Show phase info
    TConsole.SetCursorPos(2, 1);
    TConsole.SetForegroundColor(CSIFGWhite);
    TConsole.Print('TConsole Demo - Phase %d/%d', [DemoPhase + 1, TOTAL_PHASES], False);

    // Show time info
    TConsole.SetCursorPos(2, 2);
    TConsole.SetForegroundColor(CSIFGWhite);

    if CompletedPhases < TOTAL_PHASES - 1 then
      TConsole.Print('Time: %.1fs (Next phase in %.1fs)',
                    [ElapsedMs / 1000.0,
                     PhaseTimeRemaining / 1000.0], False)
    else
      TConsole.Print('Time: %.1fs (Final phase)', [ElapsedMs / 1000.0], False);

    // Show control info
    TConsole.SetCursorPos(2, ConsoleHeight - 1);
    TConsole.SetForegroundColor(CSIFGWhite);
    TConsole.Print('Press any key to exit demo...', False);
  end;

  // Check if the demo sequence is complete (all phases shown)
  function IsSequenceComplete: Boolean;
  begin
    Result := CompletedPhases >= TOTAL_PHASES;
  end;

begin
  ClearInput();

  try
    // Store the original title and set a demo title
    OriginalTitle := TConsole.GetTitle;
    TConsole.SetTitle('TConsole Advanced Effects Demo');

    // Get console dimensions
    TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);

    // Initialize random seed
    Randomize;

    // Hide cursor during animation
    TConsole.HideCursor;

    // Initialize effects
    InitRainDrops;
    InitFireworks;

    // Set up demo phases
    DemoPhase := 0;
    LastDemoPhase := -1; // Force initial clear
    CompletedPhases := 0;
    TotalMs := DURATION_MS;

    // Calculate frame time in milliseconds
    FrameTime := 1000 div FPS;

    // Start timer
    StartTime := Now;
    LastFrameTime := StartTime;
    PhaseStartTime := StartTime;
    //TotalElapsedMs := 0;

    // Clear screen once at the beginning
    TConsole.ClearScreen;

    // Main demo loop
    repeat
      // Get current time
      CurrentTime := Now;
      ElapsedMs := Round((CurrentTime - PhaseStartTime) * 24 * 60 * 60 * 1000);
      //TotalElapsedMs := Round((CurrentTime - StartTime) * 24 * 60 * 60 * 1000);

      // Check if it's time for a new phase
      if ElapsedMs >= TotalMs then
      begin
        // Move to next phase
        Inc(CompletedPhases);
        DemoPhase := (DemoPhase + 1) mod TOTAL_PHASES;

        // Reset phase timer
        PhaseStartTime := CurrentTime;
        ElapsedMs := 0;

        // Force screen clear for new phase
        LastDemoPhase := -1;
      end;

      // Only clear screen when changing demos or after enough time has passed
      if (DemoPhase <> LastDemoPhase) or
         (Round((CurrentTime - LastFrameTime) * 24 * 60 * 60 * 1000) >= FrameTime) then
      begin
        // Clear screen only when changing demos
        if DemoPhase <> LastDemoPhase then
        begin
          TConsole.ClearScreen;
          LastDemoPhase := DemoPhase;
        end;

        // Draw current effect
        case DemoPhase of
          0: DrawSineWave;
          1: DrawDigitalRain;
          2: UpdateFireworks;
          3: DrawStarfield;
        end;

        // Draw UI info
        DrawUIInfo;

        // Update last frame time
        LastFrameTime := CurrentTime;
      end;

      // Process message queue and reduce CPU usage
      Sleep(5);

    until TConsole.AnyKeyPressed or IsSequenceComplete;

    // Clear keyboard buffer
    if TConsole.AnyKeyPressed then
      TConsole.ReadKey;

    // Clean up
    TConsole.ClearScreen;
    TConsole.ResetTextFormat;
    TConsole.ShowCursor;
    TConsole.SetTitle(OriginalTitle);

  except
    on E: Exception do
    begin
      TConsole.ClearScreen;
      TConsole.ResetTextFormat;
      TConsole.ShowCursor;
      TConsole.SetTitle(OriginalTitle);

      TConsole.SetForegroundColor(CSIFGRed);
      TConsole.PrintLn('Error: %s', [E.Message], False);
      TConsole.ResetTextFormat;
    end;
  end;
end;

// Dashboard Demo
procedure Demo_Dashboard();
const
  DEMO_DURATION = 30000; // 30 seconds
  FPS = 10;

  // Simulated data points
  CPU_SAMPLES = 60;
  MEMORY_SAMPLES = 60;
  DISK_SAMPLES = 60;
  NETWORK_SAMPLES = 60;

  // Box drawing characters
  BOX_HORIZ = '─';
  BOX_VERT = '│';
  BOX_TOP_LEFT = '┌';
  BOX_TOP_RIGHT = '┐';
  BOX_BOTTOM_LEFT = '└';
  BOX_BOTTOM_RIGHT = '┘';
  BOX_LEFT_MID = '├';

  // Chart characters
  CHART_DOT = '·';
  CHART_POINT = '●';

  // Bar characters
  BAR_FULL = '█';
  BAR_EMPTY = '░';

type
  TMetric = record
    Values: array of Double;
    MinValue, MaxValue: Double;
    CurrentValue: Double;
    MetricName: string;
    UnitName: string;
    ColorCode: string;
  end;

var
  ConsoleWidth, ConsoleHeight: Integer;
  OriginalTitle: string;
  StartTime, CurrentTime{, LastFrameTime}: TDateTime;
  ElapsedMs{, FrameTimeMs}: Int64;
  CPU, Memory, Disk, Network: TMetric;
  TabIndex: Integer;

  // Use TAsciiBuffer instead of custom buffer implementation
  Buffer: TAsciiBuffer;

  // Initialize metrics with sample data
  procedure InitMetrics;
  begin
    // CPU usage
    SetLength(CPU.Values, CPU_SAMPLES);
    CPU.MinValue := 0;
    CPU.MaxValue := 100;
    CPU.MetricName := 'CPU Usage';
    CPU.UnitName := '%';
    CPU.ColorCode := CSIFGCyan;
    for var i := 0 to CPU_SAMPLES - 1 do
      CPU.Values[i] := Random * 80 + 10;
    CPU.CurrentValue := CPU.Values[CPU_SAMPLES - 1];

    // Memory usage
    SetLength(Memory.Values, MEMORY_SAMPLES);
    Memory.MinValue := 0;
    Memory.MaxValue := 16384; // MB
    Memory.MetricName := 'Memory Usage';
    Memory.UnitName := 'MB';
    Memory.ColorCode := CSIFGGreen;
    for var i := 0 to MEMORY_SAMPLES - 1 do
      Memory.Values[i] := 4096 + Random * 8192;
    Memory.CurrentValue := Memory.Values[MEMORY_SAMPLES - 1];

    // Disk I/O
    SetLength(Disk.Values, DISK_SAMPLES);
    Disk.MinValue := 0;
    Disk.MaxValue := 100;
    Disk.MetricName := 'Disk I/O';
    Disk.UnitName := 'MB/s';
    Disk.ColorCode := CSIFGYellow;
    for var i := 0 to DISK_SAMPLES - 1 do
      Disk.Values[i] := Random * 60;
    Disk.CurrentValue := Disk.Values[DISK_SAMPLES - 1];

    // Network
    SetLength(Network.Values, NETWORK_SAMPLES);
    Network.MinValue := 0;
    Network.MaxValue := 1000;
    Network.MetricName := 'Network';
    Network.UnitName := 'Mbps';
    Network.ColorCode := CSIFGMagenta;
    for var i := 0 to NETWORK_SAMPLES - 1 do
      Network.Values[i] := Random * 500;
    Network.CurrentValue := Network.Values[NETWORK_SAMPLES - 1];
  end;

  // Update metrics with new random values
  procedure UpdateMetrics;
  begin
    // Shift values left
    for var i := 0 to CPU_SAMPLES - 2 do
    begin
      CPU.Values[i] := CPU.Values[i + 1];
      Memory.Values[i] := Memory.Values[i + 1];
      Disk.Values[i] := Disk.Values[i + 1];
      Network.Values[i] := Network.Values[i + 1];
    end;

    // Add new random values
    CPU.Values[CPU_SAMPLES - 1] := Max(0, Min(100, CPU.Values[CPU_SAMPLES - 2] + (Random * 20 - 10)));
    Memory.Values[MEMORY_SAMPLES - 1] := Max(1024, Min(16384, Memory.Values[MEMORY_SAMPLES - 2] + (Random * 1024 - 512)));
    Disk.Values[DISK_SAMPLES - 1] := Max(0, Min(100, Disk.Values[DISK_SAMPLES - 2] + (Random * 15 - 7.5)));
    Network.Values[NETWORK_SAMPLES - 1] := Max(0, Min(1000, Network.Values[NETWORK_SAMPLES - 2] + (Random * 100 - 50)));

    // Update current values
    CPU.CurrentValue := CPU.Values[CPU_SAMPLES - 1];
    Memory.CurrentValue := Memory.Values[MEMORY_SAMPLES - 1];
    Disk.CurrentValue := Disk.Values[DISK_SAMPLES - 1];
    Network.CurrentValue := Network.Values[NETWORK_SAMPLES - 1];
  end;

  // Draw a horizontal bar using TAsciiBuffer
  procedure DrawBar(X, Y, Width: Integer; Value, MaxValue: Double; ColorCode: string);
  var
    BarWidth, i: Integer;
    BarChar: WideChar;
  begin
    BarWidth := Round((Value / MaxValue) * Width);

    for i := 0 to Width - 1 do
    begin
      if i < BarWidth then
        BarChar := BAR_FULL
      else
        BarChar := BAR_EMPTY;

      Buffer.PutChar(X + i, Y, BarChar, ColorCode);
    end;
  end;

  // Draw a line chart using TAsciiBuffer
  procedure DrawLineChart(X, Y, Width, Height: Integer; Values: array of Double;
                         MinValue, MaxValue: Double; ColorCode: string);
  var
    i, PrevX, PrevY, CurrX, CurrY: Integer;
    ValuePoint, Scale: Double;
  begin
    // Draw axes
    Buffer.DrawHLine(X, X + Width - 1, Y + Height - 1, BOX_HORIZ, CSIFGWhite);
    Buffer.DrawVLine(X, Y, Y + Height - 1, BOX_VERT, CSIFGWhite);
    Buffer.PutChar(X, Y + Height - 1, BOX_BOTTOM_LEFT, CSIFGWhite);

    // Draw scale markers
    for i := 0 to 3 do
    begin
      var MarkerY := Y + Height - 1 - (i * (Height - 1) div 3);
      if (MarkerY >= Y) and (MarkerY < Y + Height) then
      begin
        Buffer.PutChar(X, MarkerY, BOX_LEFT_MID, CSIFGWhite);

        // Add scale display
        var ScaleValue := MinValue + (i * (MaxValue - MinValue) / 3);
        var ScaleText := Format('%.0f', [ScaleValue]);
        Buffer.PrintAt(X + 1, MarkerY, ScaleText, CSIFGBrightBlack);
      end;
    end;

    // Calculate scale
    Scale := (Height - 1) / (MaxValue - MinValue);
    if MaxValue = MinValue then Scale := 0; // Protection against division by zero

    // Draw line chart
    PrevX := -1;
    PrevY := -1;

    for i := 0 to Min(Width - 2, Length(Values) - 1) do
    begin
      // Calculate positions
      CurrX := X + Width - 1 - i;
      ValuePoint := Values[Length(Values) - 1 - i];

      // Handle division by zero
      if MaxValue > MinValue then
        CurrY := Y + Height - 1 - Round((ValuePoint - MinValue) * Scale)
      else
        CurrY := Y + Height - 1;

      // Ensure within bounds
      if CurrY < Y then CurrY := Y;
      if CurrY >= Y + Height then CurrY := Y + Height - 1;

      // Draw point
      Buffer.PutChar(CurrX, CurrY, CHART_POINT, ColorCode);

      // Draw line to previous point
      if (PrevX >= 0) and (PrevY >= 0) then
      begin
        // Connect points manually since TAsciiBuffer doesn't have line drawing
        var Steps := Max(Abs(CurrX - PrevX), Abs(CurrY - PrevY));

        if Steps > 0 then
        begin
          var XStep := (CurrX - PrevX) / Steps;
          var YStep := (CurrY - PrevY) / Steps;

          for var j := 1 to Steps - 1 do
          begin
            var LineX := PrevX + Round(j * XStep);
            var LineY := PrevY + Round(j * YStep);

            if (LineX >= X) and (LineX < X + Width) and
               (LineY >= Y) and (LineY < Y + Height) then
            begin
              Buffer.PutChar(LineX, LineY, CHART_DOT, ColorCode);
            end;
          end;
        end;
      end;

      PrevX := CurrX;
      PrevY := CurrY;
    end;
  end;

  // Draw a tab area using TAsciiBuffer
  procedure DrawTabs(X, Y, Width: Integer; TabNames: array of string; Selected: Integer);
  var
    TabWidth, i, j: Integer;
    TabX: Integer;
  begin
    TabWidth := Width div Length(TabNames);
    TabX := X;

    // Draw tab headers
    for i := 0 to High(TabNames) do
    begin
      var TabFg, TabBg: string;

      if i = Selected then
      begin
        TabFg := CSIFGBlack;
        TabBg := CSIBGWhite;
      end
      else
      begin
        TabFg := CSIFGWhite;
        TabBg := CSIBGBlack;
      end;

      // Draw tab with padding
      var TabText := ' ' + TabNames[i] + ' ';
      Buffer.PrintAt(TabX, Y, TabText, TabFg, TabBg);

      // Fill the rest of the tab width with spaces
      for j := Length(TabText) to TabWidth - 1 do
        Buffer.PutChar(TabX + j, Y, ' ', TabFg, TabBg);

      TabX := TabX + TabWidth;
    end;

    // Draw line under tabs
    Buffer.DrawHLine(X, X + Width - 1, Y + 1, BOX_HORIZ, CSIFGWhite);
  end;

  // Draw dashboard
  procedure DrawDashboard;
  var
    MainX, MainY, MainWidth, MainHeight: Integer;
  begin
    // Clear buffer for new frame
    Buffer.Clear();

    // Define main area
    MainX := 2;
    MainY := 5;
    MainWidth := ConsoleWidth - 4;
    MainHeight := ConsoleHeight - 8;

    // Draw header
    Buffer.FillRect(0, 0, ConsoleWidth - 1, 0, ' ', CSIFGWhite, CSIBGBlue);
    Buffer.PrintAt(1, 0, 'TConsole System Dashboard', CSIFGWhite, CSIBGBlue);

    // Draw current time
    var TimeStr := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);
    Buffer.PrintAt(ConsoleWidth - Length(TimeStr) - 1, 0, TimeStr, CSIFGWhite, CSIBGBlue);

    // Draw tabs
    DrawTabs(MainX, 2, MainWidth, ['Overview', 'CPU', 'Memory', 'Disk', 'Network'], TabIndex);

    // Draw content based on selected tab
    case TabIndex of
      0: // Overview
        begin
          // Draw 4 metric boxes
          var BoxWidth := (MainWidth - 3) div 2;
          var BoxHeight := (MainHeight - 3) div 2;

          // CPU Box - Top Left
          var TitleStr := BOX_TOP_LEFT + '─ ' + CPU.MetricName + ' ' + StringOfChar(BOX_HORIZ, BoxWidth - Length(CPU.MetricName) - 4) + BOX_TOP_RIGHT;
          Buffer.PrintAt(MainX, MainY, TitleStr, CSIFGWhite);

          // CPU usage value
          var ValueStr := Format('%.1f%s', [CPU.CurrentValue, CPU.UnitName]);
          Buffer.PrintAt(MainX + 2, MainY + 2, ValueStr, CPU.ColorCode);

          // CPU usage bar
          DrawBar(MainX + 2, MainY + 4, BoxWidth - 4, CPU.CurrentValue, CPU.MaxValue, CPU.ColorCode);

          // Memory Box - Top Right
          TitleStr := BOX_TOP_LEFT + '─ ' + Memory.MetricName + ' ' + StringOfChar(BOX_HORIZ, BoxWidth - Length(Memory.MetricName) - 4) + BOX_TOP_RIGHT;
          Buffer.PrintAt(MainX + BoxWidth + 1, MainY, TitleStr, CSIFGWhite);

          // Memory usage value
          ValueStr := Format('%.1f%s', [Memory.CurrentValue, Memory.UnitName]);
          Buffer.PrintAt(MainX + BoxWidth + 3, MainY + 2, ValueStr, Memory.ColorCode);

          // Memory usage bar
          DrawBar(MainX + BoxWidth + 3, MainY + 4, BoxWidth - 4, Memory.CurrentValue, Memory.MaxValue, Memory.ColorCode);

          // Disk Box - Bottom Left
          TitleStr := BOX_TOP_LEFT + '─ ' + Disk.MetricName + ' ' + StringOfChar(BOX_HORIZ, BoxWidth - Length(Disk.MetricName) - 4) + BOX_TOP_RIGHT;
          Buffer.PrintAt(MainX, MainY + BoxHeight + 1, TitleStr, CSIFGWhite);

          // Disk usage value
          ValueStr := Format('%.1f%s', [Disk.CurrentValue, Disk.UnitName]);
          Buffer.PrintAt(MainX + 2, MainY + BoxHeight + 3, ValueStr, Disk.ColorCode);

          // Disk usage bar
          DrawBar(MainX + 2, MainY + BoxHeight + 5, BoxWidth - 4, Disk.CurrentValue, Disk.MaxValue, Disk.ColorCode);

          // Network Box - Bottom Right
          TitleStr := BOX_TOP_LEFT + '─ ' + Network.MetricName + ' ' + StringOfChar(BOX_HORIZ, BoxWidth - Length(Network.MetricName) - 4) + BOX_TOP_RIGHT;
          Buffer.PrintAt(MainX + BoxWidth + 1, MainY + BoxHeight + 1, TitleStr, CSIFGWhite);

          // Network usage value
          ValueStr := Format('%.1f%s', [Network.CurrentValue, Network.UnitName]);
          Buffer.PrintAt(MainX + BoxWidth + 3, MainY + BoxHeight + 3, ValueStr, Network.ColorCode);

          // Network usage bar
          DrawBar(MainX + BoxWidth + 3, MainY + BoxHeight + 5, BoxWidth - 4, Network.CurrentValue, Network.MaxValue, Network.ColorCode);
        end;

      1: // CPU
        begin
          // Draw title
          Buffer.PrintAt(MainX, MainY, 'CPU Usage History', CSIFGWhite);

          // Draw current value
          var ValueStr := Format('Current: %.1f%s', [CPU.CurrentValue, CPU.UnitName]);
          Buffer.PrintAt(MainX, MainY + 2, ValueStr, CPU.ColorCode);

          // Draw min/max
          var StatsStr := Format('Min: %.1f%s  Max: %.1f%s', [CPU.MinValue, CPU.UnitName, CPU.MaxValue, CPU.UnitName]);
          Buffer.PrintAt(MainX + 20, MainY + 2, StatsStr, CSIFGWhite);

          // Draw chart
          DrawLineChart(MainX, MainY + 4, MainWidth - 2, MainHeight - 8, CPU.Values, CPU.MinValue, CPU.MaxValue, CPU.ColorCode);

          // Draw CPU info (simulated)
          Buffer.PrintAt(MainX, MainY + MainHeight - 3, 'CPU Info:', CSIFGWhite);
          Buffer.PrintAt(MainX, MainY + MainHeight - 2, 'Intel Core i7-9700K @ 3.60GHz, 8 Cores, 8 Logical Processors', CSIFGWhite);
        end;

      2: // Memory
        begin
          // Draw title
          Buffer.PrintAt(MainX, MainY, 'Memory Usage History', CSIFGWhite);

          // Draw current value
          var ValueStr := Format('Current: %.1f%s', [Memory.CurrentValue, Memory.UnitName]);
          Buffer.PrintAt(MainX, MainY + 2, ValueStr, Memory.ColorCode);

          // Draw min/max
          var StatsStr := Format('Min: %.1f%s  Max: %.1f%s', [Memory.MinValue, Memory.UnitName, Memory.MaxValue, Memory.UnitName]);
          Buffer.PrintAt(MainX + 20, MainY + 2, StatsStr, CSIFGWhite);

          // Draw chart
          DrawLineChart(MainX, MainY + 4, MainWidth - 2, MainHeight - 8, Memory.Values, Memory.MinValue, Memory.MaxValue, Memory.ColorCode);

          // Draw Memory info (simulated)
          Buffer.PrintAt(MainX, MainY + MainHeight - 3, 'Memory Info:', CSIFGWhite);
          Buffer.PrintAt(MainX, MainY + MainHeight - 2, '16.0 GB DDR4-3200, 4 DIMMs, Dual-Channel', CSIFGWhite);
        end;

      3: // Disk
        begin
          // Draw title
          Buffer.PrintAt(MainX, MainY, 'Disk I/O History', CSIFGWhite);

          // Draw current value
          var ValueStr := Format('Current: %.1f%s', [Disk.CurrentValue, Disk.UnitName]);
          Buffer.PrintAt(MainX, MainY + 2, ValueStr, Disk.ColorCode);

          // Draw min/max
          var StatsStr := Format('Min: %.1f%s  Max: %.1f%s', [Disk.MinValue, Disk.UnitName, Disk.MaxValue, Disk.UnitName]);
          Buffer.PrintAt(MainX + 20, MainY + 2, StatsStr, CSIFGWhite);

          // Draw chart
          DrawLineChart(MainX, MainY + 4, MainWidth - 2, MainHeight - 8, Disk.Values, Disk.MinValue, Disk.MaxValue, Disk.ColorCode);

          // Draw Disk info (simulated)
          Buffer.PrintAt(MainX, MainY + MainHeight - 3, 'Disk Info:', CSIFGWhite);
          Buffer.PrintAt(MainX, MainY + MainHeight - 2, 'Samsung SSD 970 EVO 1TB, NVMe, 3500/2500 MB/s Read/Write', CSIFGWhite);
        end;

      4: // Network
        begin
          // Draw title
          Buffer.PrintAt(MainX, MainY, 'Network Activity History', CSIFGWhite);

          // Draw current value
          var ValueStr := Format('Current: %.1f%s', [Network.CurrentValue, Network.UnitName]);
          Buffer.PrintAt(MainX, MainY + 2, ValueStr, Network.ColorCode);

          // Draw min/max
          var StatsStr := Format('Min: %.1f%s  Max: %.1f%s', [Network.MinValue, Network.UnitName, Network.MaxValue, Network.UnitName]);
          Buffer.PrintAt(MainX + 20, MainY + 2, StatsStr, CSIFGWhite);

          // Draw chart
          DrawLineChart(MainX, MainY + 4, MainWidth - 2, MainHeight - 8, Network.Values, Network.MinValue, Network.MaxValue, Network.ColorCode);

          // Draw Network info (simulated)
          Buffer.PrintAt(MainX, MainY + MainHeight - 3, 'Network Info:', CSIFGWhite);
          Buffer.PrintAt(MainX, MainY + MainHeight - 2, 'Intel Gigabit Network Connection, 1 Gbps, IP: 192.168.1.100', CSIFGWhite);
        end;
    end;

    // Draw footer with help
    var HelpText := ' [A/D] Change Tab  [ESC] Exit ';
    Buffer.FillRect(0, ConsoleHeight - 1, ConsoleWidth - 1, ConsoleHeight - 1, ' ', CSIFGWhite);
    Buffer.PrintAt(0, ConsoleHeight - 1, HelpText, CSIFGWhite);

    // Render the buffer to the console
    Buffer.Render;
  end;

  // Process keyboard input
  function ProcessInput: Boolean;
  begin
    Result := True; // Continue running

    if TConsole.AnyKeyPressed then
    begin
      var Key := TConsole.ReadKey;

      case Ord(Key) of
        VK_ESC: // ESC
          Result := False; // Exit

        VK_LEFT, Ord('a'), Ord('A'): // Left arrow or 'a'
          begin
            if TabIndex > 0 then
              TabIndex := TabIndex - 1;
          end;

        VK_RIGHT, Ord('d'), Ord('D'): // Right arrow or 'd'
          begin
            if TabIndex < 4 then
              TabIndex := TabIndex + 1;
          end;
      end;
    end;
  end;

  procedure ClearInput;
  begin
    while TConsole.AnyKeyPressed do
      TConsole.ReadKey;
    TConsole.ClearKeyStates;
  end;

begin
  ClearInput;

  // Store original title
  OriginalTitle := TConsole.GetTitle;
  TConsole.SetTitle('TConsole Dashboard Demo');

  // Get console dimensions
  TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);

  // Ensure minimum console size
  if (ConsoleWidth < 80) or (ConsoleHeight < 24) then
  begin
    TConsole.PrintLn('Console window too small for dashboard demo.');
    TConsole.PrintLn('Please resize to at least 80x24 characters and try again.');
    Exit;
  end;

  // Hide cursor
  TConsole.HideCursor;

  // Initialize metrics
  TabIndex := 0;
  Randomize;
  InitMetrics;

  // Create TAsciiBuffer
  Buffer := TAsciiBuffer.Create(ConsoleWidth, ConsoleHeight);
  Buffer.SetFrameRate(FPS); // Set frame rate for buffer

  // Initial clear screen
  TConsole.ClearScreen;

  // Setup timing
  StartTime := Now;
  //LastFrameTime := StartTime;

  // Main loop
  try
    while ProcessInput do
    begin
      // Get current time
      CurrentTime := Now;
      ElapsedMs := Round((CurrentTime - StartTime) * 24 * 60 * 60 * 1000);

      // Check if demo duration exceeded
      if ElapsedMs >= DEMO_DURATION then
        Break;

      // Begin frame - this handles timing
      if Buffer.BeginFrame then
      begin
        // Update metrics
        UpdateMetrics;

        // Draw dashboard
        DrawDashboard;

        // End the frame
        Buffer.EndFrame;
      end;

      // Let the system breathe a bit
      Sleep(5);
    end;
  finally
    // Clean up
    Buffer.Free;
    TConsole.ClearScreen;
    TConsole.ResetTextFormat;
    TConsole.ShowCursor;
    TConsole.SetTitle(OriginalTitle);
  end;
end;


// TConsole Animation Player Demo
// Demonstrates: Color manipulation, cursor positioning, animation timing, and text rendering
procedure Demo_AnimationPlayer;
const
  FRAME_DELAY = 100; // Milliseconds between frames

type
  TFrame = record
    Data: array of string;
    Width, Height: Integer;
    FgColor, BgColor: string;
  end;

  TAnimation = record
    Frames: array of TFrame;
    FrameCount: Integer;
    CurrentFrame: Integer;
    LoopCount: Integer;
    Title: string;
  end;

var
  Animations: array of TAnimation;
  AnimationCount: Integer;
  CurrentAnimation: Integer;
  Playing: Boolean;
  ConsoleWidth, ConsoleHeight: Integer;

  // Initialize a predefined animation of a bouncing ball
  procedure InitBouncingBallAnimation;
  var
    Animation: TAnimation;
    FrameData: array[0..9] of array of string;
    i: Integer;
  begin
    // Set up animation properties
    Animation.Title := 'Bouncing Ball Animation';
    Animation.LoopCount := -1; // Infinite loops
    Animation.CurrentFrame := 0;

    // Define frames
    SetLength(FrameData[0], 10);
    FrameData[0][0] := '          ';
    FrameData[0][1] := '          ';
    FrameData[0][2] := '   ####   ';
    FrameData[0][3] := '  ######  ';
    FrameData[0][4] := '  ######  ';
    FrameData[0][5] := '   ####   ';
    FrameData[0][6] := '          ';
    FrameData[0][7] := '          ';
    FrameData[0][8] := '          ';
    FrameData[0][9] := '##########';

    SetLength(FrameData[1], 10);
    FrameData[1][0] := '          ';
    FrameData[1][1] := '          ';
    FrameData[1][2] := '          ';
    FrameData[1][3] := '   ####   ';
    FrameData[1][4] := '  ######  ';
    FrameData[1][5] := '  ######  ';
    FrameData[1][6] := '   ####   ';
    FrameData[1][7] := '          ';
    FrameData[1][8] := '          ';
    FrameData[1][9] := '##########';

    SetLength(FrameData[2], 10);
    FrameData[2][0] := '          ';
    FrameData[2][1] := '          ';
    FrameData[2][2] := '          ';
    FrameData[2][3] := '          ';
    FrameData[2][4] := '   ####   ';
    FrameData[2][5] := '  ######  ';
    FrameData[2][6] := '  ######  ';
    FrameData[2][7] := '   ####   ';
    FrameData[2][8] := '          ';
    FrameData[2][9] := '##########';

    SetLength(FrameData[3], 10);
    FrameData[3][0] := '          ';
    FrameData[3][1] := '          ';
    FrameData[3][2] := '          ';
    FrameData[3][3] := '          ';
    FrameData[3][4] := '          ';
    FrameData[3][5] := '   ####   ';
    FrameData[3][6] := '  ######  ';
    FrameData[3][7] := '  ######  ';
    FrameData[3][8] := '   ####   ';
    FrameData[3][9] := '##########';

    SetLength(FrameData[4], 10);
    FrameData[4][0] := '          ';
    FrameData[4][1] := '          ';
    FrameData[4][2] := '          ';
    FrameData[4][3] := '          ';
    FrameData[4][4] := '          ';
    FrameData[4][5] := '          ';
    FrameData[4][6] := '   ####   ';
    FrameData[4][7] := '  ######  ';
    FrameData[4][8] := '  ######  ';
    FrameData[4][9] := '###########';

    SetLength(FrameData[5], 10);
    FrameData[5][0] := '          ';
    FrameData[5][1] := '          ';
    FrameData[5][2] := '          ';
    FrameData[5][3] := '          ';
    FrameData[5][4] := '          ';
    FrameData[5][5] := '          ';
    FrameData[5][6] := '          ';
    FrameData[5][7] := '   ####   ';
    FrameData[5][8] := '  ######  ';
    FrameData[5][9] := '##########';

    SetLength(FrameData[6], 10);
    FrameData[6][0] := '          ';
    FrameData[6][1] := '          ';
    FrameData[6][2] := '          ';
    FrameData[6][3] := '          ';
    FrameData[6][4] := '          ';
    FrameData[6][5] := '          ';
    FrameData[6][6] := '   ####   ';
    FrameData[6][7] := '  ######  ';
    FrameData[6][8] := '  ######  ';
    FrameData[6][9] := '##########';

    SetLength(FrameData[7], 10);
    FrameData[7][0] := '          ';
    FrameData[7][1] := '          ';
    FrameData[7][2] := '          ';
    FrameData[7][3] := '          ';
    FrameData[7][4] := '   ####   ';
    FrameData[7][5] := '  ######  ';
    FrameData[7][6] := '  ######  ';
    FrameData[7][7] := '   ####   ';
    FrameData[7][8] := '          ';
    FrameData[7][9] := '##########';

    SetLength(FrameData[8], 10);
    FrameData[8][0] := '          ';
    FrameData[8][1] := '          ';
    FrameData[8][2] := '          ';
    FrameData[8][3] := '   ####   ';
    FrameData[8][4] := '  ######  ';
    FrameData[8][5] := '  ######  ';
    FrameData[8][6] := '   ####   ';
    FrameData[8][7] := '          ';
    FrameData[8][8] := '          ';
    FrameData[8][9] := '##########';

    SetLength(FrameData[9], 10);
    FrameData[9][0] := '          ';
    FrameData[9][1] := '          ';
    FrameData[9][2] := '   ####   ';
    FrameData[9][3] := '  ######  ';
    FrameData[9][4] := '  ######  ';
    FrameData[9][5] := '   ####   ';
    FrameData[9][6] := '          ';
    FrameData[9][7] := '          ';
    FrameData[9][8] := '          ';
    FrameData[9][9] := '##########';

    // Create animation frames
    SetLength(Animation.Frames, 10);
    Animation.FrameCount := 10;

    for i := 0 to 9 do
    begin
      SetLength(Animation.Frames[i].Data, Length(FrameData[i]));
      for var j := 0 to Length(FrameData[i]) - 1 do
        Animation.Frames[i].Data[j] := FrameData[i][j];
      Animation.Frames[i].Width := 10;
      Animation.Frames[i].Height := 10;
      Animation.Frames[i].FgColor := CSIFGBrightCyan;
      Animation.Frames[i].BgColor := CSIBGBlack;
    end;

    // Add to animations array
    AnimationCount := 1;
    SetLength(Animations, AnimationCount);
    Animations[0] := Animation;
  end;

  // Initialize a predefined animation of a spinning star
  procedure InitSpinningStarAnimation;
  var
    Animation: TAnimation;
    FrameData: array[0..7] of array of string;
    i: Integer;
  begin
    // Set up animation properties
    Animation.Title := 'Spinning Star Animation';
    Animation.LoopCount := -1; // Infinite loops
    Animation.CurrentFrame := 0;

    // Define frames for spinning star
    SetLength(FrameData[0], 9);
    FrameData[0][0] := '    *    ';
    FrameData[0][1] := '         ';
    FrameData[0][2] := '         ';
    FrameData[0][3] := '         ';
    FrameData[0][4] := '*       *';
    FrameData[0][5] := '         ';
    FrameData[0][6] := '         ';
    FrameData[0][7] := '         ';
    FrameData[0][8] := '    *    ';

    SetLength(FrameData[1], 9);
    FrameData[1][0] := '         ';
    FrameData[1][1] := '   *     ';
    FrameData[1][2] := '         ';
    FrameData[1][3] := '         ';
    FrameData[1][4] := '*       *';
    FrameData[1][5] := '         ';
    FrameData[1][6] := '         ';
    FrameData[1][7] := '     *   ';
    FrameData[1][8] := '         ';

    SetLength(FrameData[2], 9);
    FrameData[2][0] := '         ';
    FrameData[2][1] := '         ';
    FrameData[2][2] := '  *      ';
    FrameData[2][3] := '         ';
    FrameData[2][4] := '*       *';
    FrameData[2][5] := '         ';
    FrameData[2][6] := '      *  ';
    FrameData[2][7] := '         ';
    FrameData[2][8] := '         ';

    SetLength(FrameData[3], 9);
    FrameData[3][0] := '         ';
    FrameData[3][1] := '         ';
    FrameData[3][2] := '         ';
    FrameData[3][3] := ' *       ';
    FrameData[3][4] := '*       *';
    FrameData[3][5] := '       * ';
    FrameData[3][6] := '         ';
    FrameData[3][7] := '         ';
    FrameData[3][8] := '         ';

    SetLength(FrameData[4], 9);
    FrameData[4][0] := '         ';
    FrameData[4][1] := '         ';
    FrameData[4][2] := '         ';
    FrameData[4][3] := '         ';
    FrameData[4][4] := '* * * * *';
    FrameData[4][5] := '         ';
    FrameData[4][6] := '         ';
    FrameData[4][7] := '         ';
    FrameData[4][8] := '         ';

    SetLength(FrameData[5], 9);
    FrameData[5][0] := '         ';
    FrameData[5][1] := '         ';
    FrameData[5][2] := '         ';
    FrameData[5][3] := '       * ';
    FrameData[5][4] := '*       *';
    FrameData[5][5] := ' *       ';
    FrameData[5][6] := '         ';
    FrameData[5][7] := '         ';
    FrameData[5][8] := '         ';

    SetLength(FrameData[6], 9);
    FrameData[6][0] := '         ';
    FrameData[6][1] := '         ';
    FrameData[6][2] := '      *  ';
    FrameData[6][3] := '         ';
    FrameData[6][4] := '*       *';
    FrameData[6][5] := '         ';
    FrameData[6][6] := '  *      ';
    FrameData[6][7] := '         ';
    FrameData[6][8] := '         ';

    SetLength(FrameData[7], 9);
    FrameData[7][0] := '         ';
    FrameData[7][1] := '     *   ';
    FrameData[7][2] := '         ';
    FrameData[7][3] := '         ';
    FrameData[7][4] := '*       *';
    FrameData[7][5] := '         ';
    FrameData[7][6] := '         ';
    FrameData[7][7] := '   *     ';
    FrameData[7][8] := '         ';

    // Create animation frames
    SetLength(Animation.Frames, 8);
    Animation.FrameCount := 8;

    for i := 0 to 7 do
    begin
      SetLength(Animation.Frames[i].Data, Length(FrameData[i]));
      for var j := 0 to Length(FrameData[i]) - 1 do
        Animation.Frames[i].Data[j] := FrameData[i][j];

      Animation.Frames[i].Width := 9;
      Animation.Frames[i].Height := 9;
      Animation.Frames[i].FgColor := CSIFGBrightYellow;
      Animation.Frames[i].BgColor := CSIBGBlack;
    end;

    // Add to animations array
    Inc(AnimationCount);
    SetLength(Animations, AnimationCount);
    Animations[AnimationCount-1] := Animation;
  end;

  // Initialize a predefined animation of a growing and shrinking heart
  procedure InitPulsingHeartAnimation;
  var
    Animation: TAnimation;
    FrameData: array[0..5] of array of string;
    i: Integer;
  begin
    // Set up animation properties
    Animation.Title := 'Pulsing Heart Animation';
    Animation.LoopCount := -1; // Infinite loops
    Animation.CurrentFrame := 0;

    // Define frames for heart
    SetLength(FrameData[0], 6);
    FrameData[0][0] := '  ♥♥  ♥♥  ';
    FrameData[0][1] := ' ♥♥♥♥♥♥♥♥ ';
    FrameData[0][2] := ' ♥♥♥♥♥♥♥♥ ';
    FrameData[0][3] := '  ♥♥♥♥♥♥  ';
    FrameData[0][4] := '   ♥♥♥♥   ';
    FrameData[0][5] := '    ♥♥    ';

    SetLength(FrameData[1], 6);
    FrameData[1][0] := '   ♥ ♥    ';
    FrameData[1][1] := '  ♥♥♥♥♥   ';
    FrameData[1][2] := '  ♥♥♥♥♥   ';
    FrameData[1][3] := '   ♥♥♥    ';
    FrameData[1][4] := '    ♥     ';
    FrameData[1][5] := '          ';

    SetLength(FrameData[2], 6);
    FrameData[2][0] := '    ♥     ';
    FrameData[2][1] := '   ♥♥♥    ';
    FrameData[2][2] := '   ♥♥♥    ';
    FrameData[2][3] := '    ♥     ';
    FrameData[2][4] := '          ';
    FrameData[2][5] := '          ';

    SetLength(FrameData[3], 6);
    FrameData[3][0] := '   ♥ ♥    ';
    FrameData[3][1] := '  ♥♥♥♥♥   ';
    FrameData[3][2] := '  ♥♥♥♥♥   ';
    FrameData[3][3] := '   ♥♥♥    ';
    FrameData[3][4] := '    ♥     ';
    FrameData[3][5] := '          ';

    SetLength(FrameData[4], 6);
    FrameData[4][0] := '  ♥♥  ♥♥  ';
    FrameData[4][1] := ' ♥♥♥♥♥♥♥♥ ';
    FrameData[4][2] := ' ♥♥♥♥♥♥♥♥ ';
    FrameData[4][3] := '  ♥♥♥♥♥♥  ';
    FrameData[4][4] := '   ♥♥♥♥   ';
    FrameData[4][5] := '    ♥♥    ';

    SetLength(FrameData[5], 6);
    FrameData[5][0] := ' ♥♥♥  ♥♥♥ ';
    FrameData[5][1] := '♥♥♥♥♥♥♥♥♥♥';
    FrameData[5][2] := '♥♥♥♥♥♥♥♥♥♥';
    FrameData[5][3] := ' ♥♥♥♥♥♥♥♥ ';
    FrameData[5][4] := '  ♥♥♥♥♥♥  ';
    FrameData[5][5] := '   ♥♥♥♥   ';

    // Create animation frames
    SetLength(Animation.Frames, 6);
    Animation.FrameCount := 6;

    for i := 0 to 5 do
    begin
      SetLength(Animation.Frames[i].Data, Length(FrameData[i]));
      for var j := 0 to Length(FrameData[i]) - 1 do
        Animation.Frames[i].Data[j] := FrameData[i][j];

      Animation.Frames[i].Width := 10;
      Animation.Frames[i].Height := 6;
      // Cycle through red shades for pulse effect
      case i of
        0: Animation.Frames[i].FgColor := CSIFGRed;
        1: Animation.Frames[i].FgColor := CSIFGRed;
        2: Animation.Frames[i].FgColor := CSIFGRed;
        3: Animation.Frames[i].FgColor := CSIFGBrightRed;
        4: Animation.Frames[i].FgColor := CSIFGBrightRed;
        5: Animation.Frames[i].FgColor := CSIFGBrightRed;
      end;
      Animation.Frames[i].BgColor := CSIBGBlack;
    end;

    // Add to animations array
    Inc(AnimationCount);
    SetLength(Animations, AnimationCount);
    Animations[AnimationCount-1] := Animation;
  end;

  // Draw the UI frame for the animation player
  procedure DrawUI;
  var
    i, CenterX, CenterY: Integer;
    HeaderText, FooterText: string;
  begin
    // Clear screen
    TConsole.ClearScreen;

    // Calculate center position
    CenterX := ConsoleWidth div 2;
    CenterY := ConsoleHeight div 2;

    // Draw header
    HeaderText := 'TConsole Animation Player';
    TConsole.SetCursorPos((ConsoleWidth - Length(HeaderText)) div 2, 1);
    TConsole.SetForegroundColor(CSIFGBrightWhite);
    TConsole.SetBackgroundColor(CSIBGBlue);
    TConsole.PrintLn(HeaderText, False);
    TConsole.ResetTextFormat;

    // Draw current animation title
    TConsole.SetCursorPos((ConsoleWidth - Length(Animations[CurrentAnimation].Title)) div 2, 3);
    TConsole.SetForegroundColor(CSIFGYellow);
    TConsole.PrintLn(Animations[CurrentAnimation].Title, False);
    TConsole.ResetTextFormat;

    // Draw border around animation area
    var MaxFrameWidth := 0;
    var MaxFrameHeight := 0;

    for i := 0 to Animations[CurrentAnimation].FrameCount - 1 do
    begin
      if Animations[CurrentAnimation].Frames[i].Width > MaxFrameWidth then
        MaxFrameWidth := Animations[CurrentAnimation].Frames[i].Width;

      if Animations[CurrentAnimation].Frames[i].Height > MaxFrameHeight then
        MaxFrameHeight := Animations[CurrentAnimation].Frames[i].Height;
    end;

    var BorderWidth := MaxFrameWidth + 4;
    var BorderHeight := MaxFrameHeight + 4;

    var BorderX := CenterX - (BorderWidth div 2);
    var BorderY := CenterY - (BorderHeight div 2);

    TConsole.SetForegroundColor(CSIFGWhite);

    // Draw top border
    TConsole.SetCursorPos(BorderX, BorderY);
    TConsole.Print('┌', False);
    for i := 1 to BorderWidth - 2 do
      TConsole.Print('─', False);
    TConsole.Print('┐', False);

    // Draw side borders
    for i := 1 to BorderHeight - 2 do
    begin
      TConsole.SetCursorPos(BorderX, BorderY + i);
      TConsole.Print('│', False);
      TConsole.SetCursorPos(BorderX + BorderWidth - 1, BorderY + i);
      TConsole.Print('│', False);
    end;

    // Draw bottom border
    TConsole.SetCursorPos(BorderX, BorderY + BorderHeight - 1);
    TConsole.Print('└', False);
    for i := 1 to BorderWidth - 2 do
      TConsole.Print('─', False);
    TConsole.Print('┘', False);

    // Draw footer help text
    FooterText := '[Space] Play/Pause | [A/D] Switch Animation | [ESC] Exit';
    TConsole.SetCursorPos((ConsoleWidth - Length(FooterText)) div 2, ConsoleHeight - 2);
    TConsole.SetForegroundColor(CSIFGBrightBlack);
    TConsole.PrintLn(FooterText, False);
    TConsole.ResetTextFormat;

    // Draw current frame indicator
    var FrameText := Format('Frame: %d/%d',
      [Animations[CurrentAnimation].CurrentFrame + 1,
       Animations[CurrentAnimation].FrameCount]);

    TConsole.SetCursorPos((ConsoleWidth - Length(FrameText)) div 2, ConsoleHeight - 4);
    TConsole.PrintLn(FrameText, False);
  end;

  // Render the current frame of the current animation
  procedure RenderFrame;
  var
    i{, j}: Integer;
    CurrentFrame: Integer;
    FrameWidth, FrameHeight: Integer;
    CenterX, CenterY: Integer;
  begin
    // Get current frame
    CurrentFrame := Animations[CurrentAnimation].CurrentFrame;
    FrameWidth := Animations[CurrentAnimation].Frames[CurrentFrame].Width;
    FrameHeight := Animations[CurrentAnimation].Frames[CurrentFrame].Height;

    // Calculate center position
    CenterX := ConsoleWidth div 2 - (FrameWidth div 2);
    CenterY := ConsoleHeight div 2 - (FrameHeight div 2);

    // Set colors
    TConsole.SetForegroundColor(Animations[CurrentAnimation].Frames[CurrentFrame].FgColor);
    TConsole.SetBackgroundColor(Animations[CurrentAnimation].Frames[CurrentFrame].BgColor);

    // Draw frame
    for i := 0 to FrameHeight - 1 do
    begin
      TConsole.SetCursorPos(CenterX, CenterY + i);
      TConsole.Print(Animations[CurrentAnimation].Frames[CurrentFrame].Data[i], False);
    end;

    // Reset text format
    TConsole.ResetTextFormat;

    // Update frame indicator
    var FrameText := Format('Frame: %d/%d',
      [Animations[CurrentAnimation].CurrentFrame + 1,
       Animations[CurrentAnimation].FrameCount]);

    TConsole.SetCursorPos((ConsoleWidth - Length(FrameText)) div 2, ConsoleHeight - 4);
    TConsole.PrintLn(FrameText, False);
  end;

  // Advance to the next frame
  procedure NextFrame;
  begin
    with Animations[CurrentAnimation] do
    begin
      CurrentFrame := (CurrentFrame + 1) mod FrameCount;
    end;
  end;

  // Switch to the next animation
  procedure NextAnimation;
  begin
    CurrentAnimation := (CurrentAnimation + 1) mod AnimationCount;
    DrawUI;
  end;

  // Switch to the previous animation
  procedure PrevAnimation;
  begin
    if CurrentAnimation > 0 then
      CurrentAnimation := CurrentAnimation - 1
    else
      CurrentAnimation := AnimationCount - 1;

    DrawUI;
  end;

  // Process keyboard input
  function ProcessInput: Boolean;
  begin
    Result := True;

    if TConsole.AnyKeyPressed then
    begin
      var Key := TConsole.ReadKey;

      case Ord(Key) of
        VK_ESC:
          Result := False; // Exit

        VK_SPACE:
          Playing := not Playing; // Toggle play/pause

        VK_LEFT, Ord('a'), Ord('A'):
          PrevAnimation;

        VK_RIGHT, Ord('d'), Ord('D'):
          NextAnimation;
      end;
    end;
  end;

begin
  // Initialize animations
  AnimationCount := 0;
  CurrentAnimation := 0;
  Playing := True;

  // Create predefined animations
  InitBouncingBallAnimation;
  InitSpinningStarAnimation;
  InitPulsingHeartAnimation;

  // Get console dimensions
  TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);

  // Ensure minimum console size
  if (ConsoleWidth < 40) or (ConsoleHeight < 20) then
  begin
    TConsole.PrintLn('Console window too small for animation player.', False);
    TConsole.PrintLn('Please resize to at least 40x20 characters and try again.', False);
    Exit;
  end;

  // Save original title and set new title
  var OriginalTitle := TConsole.GetTitle;
  TConsole.SetTitle('TConsole Animation Player');

  // Hide cursor
  TConsole.HideCursor;

  // Initial UI draw
  DrawUI;

  try
    // Main loop
    while ProcessInput do
    begin
      if Playing then
      begin
        // Render current frame
        RenderFrame;

        // Advance to next frame
        NextFrame;

        // Delay between frames
        Sleep(FRAME_DELAY);
      end;
    end;
  finally
    // Clean up
    TConsole.ClearScreen;
    TConsole.ResetTextFormat;
    TConsole.ShowCursor;
    TConsole.SetTitle(OriginalTitle);

  end;
end;

// TConsole Clock Display Demo with Double Buffering
// Demonstrates: Real-time updates, ASCII art, and color effects
procedure Demo_ClockDisplay;
const
  UPDATE_DELAY = 500; // Milliseconds
  DEMO_DURATION = 30000; // 30 seconds
  MIN_CONSOLE_WIDTH = 80;
  MIN_CONSOLE_HEIGHT = 20;

  // ASCII digits for large display (each digit is 5x7)
  DIGITS: array[0..9, 0..6] of string = (
    (
      ' ███ ',
      '█   █',
      '█   █',
      '█   █',
      '█   █',
      '█   █',
      ' ███ '
    ),
    (
      '  █  ',
      ' ██  ',
      '  █  ',
      '  █  ',
      '  █  ',
      '  █  ',
      ' ███ '
    ),
    (
      ' ███ ',
      '█   █',
      '    █',
      '   █ ',
      '  █  ',
      ' █   ',
      '█████'
    ),
    (
      ' ███ ',
      '█   █',
      '    █',
      '  ██ ',
      '    █',
      '█   █',
      ' ███ '
    ),
    (
      '   █ ',
      '  ██ ',
      ' █ █ ',
      '█  █ ',
      '█████',
      '   █ ',
      '   █ '
    ),
    (
      '█████',
      '█    ',
      '████ ',
      '    █',
      '    █',
      '█   █',
      ' ███ '
    ),
    (
      ' ███ ',
      '█   █',
      '█    ',
      '████ ',
      '█   █',
      '█   █',
      ' ███ '
    ),
    (
      '█████',
      '    █',
      '   █ ',
      '  █  ',
      ' █   ',
      ' █   ',
      ' █   '
    ),
    (
      ' ███ ',
      '█   █',
      '█   █',
      ' ███ ',
      '█   █',
      '█   █',
      ' ███ '
    ),
    (
      ' ███ ',
      '█   █',
      '█   █',
      ' ████',
      '    █',
      '█   █',
      ' ███ '
    )
  );

  // Colon separator for hours:minutes:seconds
  COLON: array[0..6] of string = (
    '     ',
    '  █  ',
    '  █  ',
    '     ',
    '  █  ',
    '  █  ',
    '     '
  );

type
  TScreenCell = record
    Char: Char;
    FgColor: string;
    BgColor: string;
  end;

  TScreenBuffer = array of array of TScreenCell;

var
  ConsoleWidth, ConsoleHeight: Integer;
  StartTime, CurrentTime: TDateTime;
  ElapsedMs: Int64;
  ColorCycle: Integer;
  DisplayMode: Integer; // 0=Digital, 1=Analog, 2=Text
  ScreenBuffer, LastBuffer: TScreenBuffer;
  {FirstFrame: Boolean;}

  // Initialize screen buffers
  procedure InitBuffers;
  var
    X, Y: Integer;
  begin
    SetLength(ScreenBuffer, ConsoleHeight, ConsoleWidth);
    SetLength(LastBuffer, ConsoleHeight, ConsoleWidth);

    for Y := 0 to ConsoleHeight - 1 do
      for X := 0 to ConsoleWidth - 1 do
      begin
        ScreenBuffer[Y][X].Char := ' ';
        ScreenBuffer[Y][X].FgColor := CSIFGWhite;
        ScreenBuffer[Y][X].BgColor := CSIBGBlack;

        LastBuffer[Y][X].Char := #0; // Force initial draw
        LastBuffer[Y][X].FgColor := '';
        LastBuffer[Y][X].BgColor := '';
      end;
  end;

  // Set a character in buffer
  procedure SetBufferChar(X, Y: Integer; Ch: Char; FgColor: string; BgColor: string = CSIBGBlack);
  begin
    if (X >= 0) and (X < ConsoleWidth) and (Y >= 0) and (Y < ConsoleHeight) then
    begin
      ScreenBuffer[Y][X].Char := Ch;
      ScreenBuffer[Y][X].FgColor := FgColor;
      ScreenBuffer[Y][X].BgColor := BgColor;
    end;
  end;

  // Set a string in buffer
  procedure SetBufferStr(X, Y: Integer; const S: string; FgColor: string; BgColor: string = CSIBGBlack);
  var
    i: Integer;
  begin
    for i := 1 to Length(S) do
      if (X + i - 1 < ConsoleWidth) then
        SetBufferChar(X + i - 1, Y, S[i], FgColor, BgColor);
  end;

  // Render buffer to screen
  procedure RenderBuffer;
  var
    X, Y: Integer;
    LastFg, LastBg: string;
  begin
    LastFg := '';
    LastBg := '';

    for Y := 0 to ConsoleHeight - 1 do
      for X := 0 to ConsoleWidth - 1 do
        if (ScreenBuffer[Y][X].Char <> LastBuffer[Y][X].Char) or
           (ScreenBuffer[Y][X].FgColor <> LastBuffer[Y][X].FgColor) or
           (ScreenBuffer[Y][X].BgColor <> LastBuffer[Y][X].BgColor) then
        begin
          // Set cursor position
          TConsole.SetCursorPos(X, Y);

          // Set colors only if changed
          if (ScreenBuffer[Y][X].FgColor <> LastFg) then
          begin
            TConsole.SetForegroundColor(ScreenBuffer[Y][X].FgColor);
            LastFg := ScreenBuffer[Y][X].FgColor;
          end;

          if (ScreenBuffer[Y][X].BgColor <> LastBg) then
          begin
            TConsole.SetBackgroundColor(ScreenBuffer[Y][X].BgColor);
            LastBg := ScreenBuffer[Y][X].BgColor;
          end;

          // Draw character
          TConsole.Print(ScreenBuffer[Y][X].Char, False);

          // Update last buffer
          LastBuffer[Y][X] := ScreenBuffer[Y][X];
        end;
  end;

  // Clear buffer
  procedure ClearBuffer;
  var
    X, Y: Integer;
  begin
    for Y := 0 to ConsoleHeight - 1 do
      for X := 0 to ConsoleWidth - 1 do
      begin
        ScreenBuffer[Y][X].Char := ' ';
        ScreenBuffer[Y][X].FgColor := CSIFGWhite;
        ScreenBuffer[Y][X].BgColor := CSIBGBlack;
      end;
  end;

  // Draw a large digit at specified position in buffer
  procedure DrawDigit(const X, Y: Integer; const Digit: Integer; const Color: string);
  var
    i, j: Integer;
    Ch: Char;
  begin
    for i := 0 to 6 do
      for j := 0 to 4 do
      begin
        if j < Length(DIGITS[Digit, i]) then
          Ch := DIGITS[Digit, i][j+1]
        else
          Ch := ' ';

        SetBufferChar(X + j, Y + i, Ch, Color);
      end;
  end;

  // Draw a colon separator at specified position in buffer
  procedure DrawColon(const X, Y: Integer; const Color: string);
  var
    i, j: Integer;
    Ch: Char;
  begin
    for i := 0 to 6 do
      for j := 0 to 4 do
      begin
        if j < Length(COLON[i]) then
          Ch := COLON[i][j+1]
        else
          Ch := ' ';

        SetBufferChar(X + j, Y + i, Ch, Color);
      end;
  end;

  // Get color based on current cycle
  function GetCycleColor: string;
  begin
    case ColorCycle mod 6 of
      0: Result := CSIFGRed;
      1: Result := CSIFGYellow;
      2: Result := CSIFGGreen;
      3: Result := CSIFGCyan;
      4: Result := CSIFGBlue;
      5: Result := CSIFGMagenta;
    else
      Result := CSIFGWhite;
    end;
  end;

  // Draw digital clock display in buffer
  procedure DrawDigitalClock(const CenterX, CenterY: Integer);
  var
    Hour, Minute, Second, MilliSecond: Word;
    TimeColor: string;
    X: Integer;
  begin
    // Get current time components
    DecodeTime(Now, Hour, Minute, Second, MilliSecond);

    // Calculate starting X position (each digit is 5 chars wide plus spacing)
    X := CenterX - 17;

    // Get current color
    TimeColor := GetCycleColor;

    // Draw hours
    DrawDigit(X, CenterY, Hour div 10, TimeColor);
    DrawDigit(X + 6, CenterY, Hour mod 10, TimeColor);

    // Draw first colon
    DrawColon(X + 12, CenterY, TimeColor);

    // Draw minutes
    DrawDigit(X + 18, CenterY, Minute div 10, TimeColor);
    DrawDigit(X + 24, CenterY, Minute mod 10, TimeColor);

    // Draw second colon
    DrawColon(X + 30, CenterY, TimeColor);

    // Draw seconds
    DrawDigit(X + 36, CenterY, Second div 10, TimeColor);
    DrawDigit(X + 42, CenterY, Second mod 10, TimeColor);
  end;

  // Draw analog clock (text-based) in buffer
  procedure DrawAnalogClock(const CenterX, CenterY: Integer);
  const
    RADIUS = 10;
  var
    Hour, Minute, Second, MilliSecond: Word;
    Angle, RadAngle, X, Y: Double;
    HourHand, MinuteHand, SecondHand: Double;
    ClockColor, HourColor, MinuteColor, SecondColor: string;
    i: Integer;
  begin
    // Get current time components
    DecodeTime(Now, Hour, Minute, Second, MilliSecond);

    // Calculate hand angles (in radians)
    HourHand := (Hour mod 12 + Minute / 60) * 30 * Pi / 180;
    MinuteHand := Minute * 6 * Pi / 180;
    SecondHand := Second * 6 * Pi / 180;

    // Set colors
    ClockColor := CSIFGBrightBlack;
    HourColor := CSIFGBrightWhite;
    MinuteColor := CSIFGCyan;
    SecondColor := CSIFGRed;

    // Draw clock face
    for i := 0 to 59 do
    begin
      Angle := i * 6; // 360 degrees / 60 marks = 6 degrees per mark
      RadAngle := Angle * Pi / 180;
      X := CenterX + RADIUS * Sin(RadAngle);
      Y := CenterY - RADIUS * Cos(RadAngle) * 0.5; // Adjust for console character aspect ratio

      if (i mod 5) = 0 then
        SetBufferChar(Round(X), Round(Y), '○', ClockColor) // Hour markers
      else
        SetBufferChar(Round(X), Round(Y), '·', ClockColor); // Minute markers
    end;

    // Draw hour hand
    X := CenterX + (RADIUS - 3) * Sin(HourHand);
    Y := CenterY - (RADIUS - 3) * Cos(HourHand) * 0.5;
    SetBufferChar(Round(X), Round(Y), '♦', HourColor);

    // Draw minute hand
    X := CenterX + (RADIUS - 1) * Sin(MinuteHand);
    Y := CenterY - (RADIUS - 1) * Cos(MinuteHand) * 0.5;
    SetBufferChar(Round(X), Round(Y), '◆', MinuteColor);

    // Draw second hand
    X := CenterX + RADIUS * Sin(SecondHand);
    Y := CenterY - RADIUS * Cos(SecondHand) * 0.5;
    SetBufferChar(Round(X), Round(Y), '•', SecondColor);

    // Draw center
    SetBufferChar(CenterX, CenterY, '●', HourColor);

    // Draw time as text
    var TimeText := Format('Time: %2d:%02d:%02d', [Hour, Minute, Second]);
    SetBufferStr(CenterX - Length(TimeText) div 2, CenterY + RADIUS + 2, TimeText, CSIFGWhite);
  end;

  // Draw calendar display in buffer
  procedure DrawCalendarDisplay(const CenterX, CenterY: Integer);
  var
    Year, Month, Day: Word;
    DayOfWeek: Integer;
    MonthName: string;
    DateColor: string;
  begin
    // Get current date
    DecodeDate(Date, Year, Month, Day);
    //DayOfWeek := DayOfTheWeek(Date);
    DayOfWeek := System.SysUtils.DayOfWeek(Date);

    // Get month name
    case Month of
      1: MonthName := 'January';
      2: MonthName := 'February';
      3: MonthName := 'March';
      4: MonthName := 'April';
      5: MonthName := 'May';
      6: MonthName := 'June';
      7: MonthName := 'July';
      8: MonthName := 'August';
      9: MonthName := 'September';
      10: MonthName := 'October';
      11: MonthName := 'November';
      12: MonthName := 'December';
    else
      MonthName := '';
    end;

    // Get day of week name
    var DayName := '';
    case DayOfWeek of
      1: DayName := 'Sunday';
      2: DayName := 'Monday';
      3: DayName := 'Tuesday';
      4: DayName := 'Wednesday';
      5: DayName := 'Thursday';
      6: DayName := 'Friday';
      7: DayName := 'Saturday';
    end;

    // Get cycle color
    DateColor := GetCycleColor;

    // Draw calendar frame
    // Top border
    SetBufferStr(CenterX - 15, CenterY - 4, '┌───────────────────────────┐', CSIFGWhite);

    // Side borders & content
    SetBufferChar(CenterX - 15, CenterY - 3, '│', CSIFGWhite);
    SetBufferChar(CenterX + 13, CenterY - 3, '│', CSIFGWhite);  // Fixed position

    SetBufferChar(CenterX - 15, CenterY - 2, '│', CSIFGWhite);
    SetBufferStr(CenterX - 10, CenterY - 2, Format('%s, %s %d', [DayName, MonthName, Day]), DateColor);
    SetBufferChar(CenterX + 13, CenterY - 2, '│', CSIFGWhite);  // Fixed position

    SetBufferChar(CenterX - 15, CenterY - 1, '│', CSIFGWhite);
    SetBufferStr(CenterX - 10, CenterY - 1, Format('%d', [Year]), CSIFGBrightBlack);
    SetBufferChar(CenterX + 13, CenterY - 1, '│', CSIFGWhite);  // Fixed position

    SetBufferChar(CenterX - 15, CenterY, '│', CSIFGWhite);
    SetBufferChar(CenterX + 13, CenterY, '│', CSIFGWhite);  // Fixed position

    // Bottom border
    SetBufferStr(CenterX - 15, CenterY + 1, '└───────────────────────────┘', CSIFGWhite);

    // Get current time
    var Hour, Minute, Second, MilliSecond: Word;
    DecodeTime(Now, Hour, Minute, Second, MilliSecond);

    // Display time below calendar
    SetBufferStr(CenterX - 12, CenterY + 3, Format('Current Time: %2d:%02d:%02d', [Hour, Minute, Second]), DateColor);

    // Display timezone info
    SetBufferStr(CenterX - 12, CenterY + 4, 'Local Timezone: UTC-5', CSIFGBrightBlack);
  end;

  // Draw frame with current display mode
  procedure DrawFrame;
  var
    CenterX, CenterY: Integer;
    HeaderText, FooterText: string;
  begin
    // Center coordinates
    CenterX := ConsoleWidth div 2;
    CenterY := ConsoleHeight div 2;

    // Clear buffer
    ClearBuffer;

    // Draw header
    HeaderText := 'TConsole Clock Demo';
    SetBufferStr((ConsoleWidth - Length(HeaderText)) div 2, 1, HeaderText, CSIFGBrightWhite, CSIBGBlue);

    // Draw the current display mode
    case DisplayMode of
      0: DrawDigitalClock(CenterX, CenterY - 5);
      1: DrawAnalogClock(CenterX, CenterY);
      2: DrawCalendarDisplay(CenterX, CenterY);
    end;

    // Draw mode indicator
    var ModeText := '';
    case DisplayMode of
      0: ModeText := 'Digital Clock';
      1: ModeText := 'Analog Clock';
      2: ModeText := 'Calendar View';
    end;

    SetBufferStr((ConsoleWidth - Length(ModeText)) div 2, 3, ModeText, CSIFGYellow);

    // Draw footer
    FooterText := 'Press ESC to exit | Mode switching in ' +
      IntToStr(10 - (ElapsedMs div 3000)) + ' seconds';
    SetBufferStr((ConsoleWidth - Length(FooterText)) div 2, ConsoleHeight - 2, FooterText, CSIFGBrightBlack);

    // Show elapsed time
    var TimeText := Format('Elapsed: %d seconds', [ElapsedMs div 1000]);
    SetBufferStr(2, ConsoleHeight - 2, TimeText, CSIFGBrightBlack);

    // Render the buffer to screen
    RenderBuffer;
  end;

  // Check for ESC key in a more responsive way
  function CheckForExit: Boolean;
  {var}
    {StartCheck: TDateTime;}
    {CheckDuration: Integer;}
  begin
    Result := False;

    // Check for ESC key
    if TConsole.IsKeyPressed(VK_ESC) then
    begin
      Result := True;
      Exit;
    end;

    // Process pending events to improve responsiveness
    TConsole.ProcessMessages();
  end;

begin
  // Get console dimensions
  TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);

  // Check minimum size
  if (ConsoleWidth < MIN_CONSOLE_WIDTH) or (ConsoleHeight < MIN_CONSOLE_HEIGHT) then
  begin
    TConsole.PrintLn('Console window too small for clock display demo.', False);
    TConsole.PrintLn('Please resize to at least %dx%d characters and try again.',
      [MIN_CONSOLE_WIDTH, MIN_CONSOLE_HEIGHT], False);
    Exit;
  end;

  // Save original title and set new title
  var OriginalTitle := TConsole.GetTitle;
  TConsole.SetTitle('TConsole Clock Display Demo');

  // Hide cursor
  TConsole.HideCursor;

  // Initialize buffers
  InitBuffers;

  // Initialize variables
  DisplayMode := 0;
  ColorCycle := 0;
  //FirstFrame := True;

  // Clear screen once
  TConsole.ClearScreen;

  try
    // Record start time
    StartTime := Now;

    // Main loop
    while True do
    begin
      // Get current time and calculate elapsed milliseconds
      CurrentTime := Now;
      ElapsedMs := Round((CurrentTime - StartTime) * 24 * 60 * 60 * 1000);

      // Check if demo duration is reached
      if ElapsedMs >= DEMO_DURATION then
        Break;

      // Check for exit key
      if CheckForExit then
        Break;

      // Update display mode every 10 seconds
      if (ElapsedMs div 3000) mod 3 <> DisplayMode then
        DisplayMode := (ElapsedMs div 3000) mod 3;

      // Update color cycle every 500ms
      if ElapsedMs mod 1000 < 500 then
      begin
        if ElapsedMs mod 1000 < 100 then
          Inc(ColorCycle);
      end;

      // Draw current frame
      DrawFrame;

      // Check for exit key again during the wait period
      var WaitStartTime := Now;
      while (Round((Now - WaitStartTime) * 24 * 60 * 60 * 1000) < UPDATE_DELAY) do
      begin
        // Check every 50ms during wait
        if CheckForExit then
          Exit;
        Sleep(50);
      end;
    end;
  finally
    // Clean up
    TConsole.ClearScreen;
    TConsole.ResetTextFormat;
    TConsole.ShowCursor;
    TConsole.SetTitle(OriginalTitle);
  end;
end;

end.
