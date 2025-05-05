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

unit Console;

{$Z4}
{$A8}

{$INLINE AUTO}

{$IFNDEF WIN64}
  {$MESSAGE Error 'Unsupported platform'}
{$ENDIF}

interface

uses
  WinApi.Windows,
  WinApi.Messages,
  System.SysUtils;

const
  LF   = AnsiChar(#10);
  CR   = AnsiChar(#13);
  CRLF = LF+CR;
  ESC  = AnsiChar(#27);

  VK_ESC = 27;

  // Cursor Movement
  CSICursorPos = ESC + '[%d;%dH';         // Set cursor position
  CSICursorUp = ESC + '[%dA';             // Move cursor up
  CSICursorDown = ESC + '[%dB';           // Move cursor down
  CSICursorForward = ESC + '[%dC';        // Move cursor forward
  CSICursorBack = ESC + '[%dD';           // Move cursor backward
  CSISaveCursorPos = ESC + '[s';          // Save cursor position
  CSIRestoreCursorPos = ESC + '[u';       // Restore cursor position
  CSICursorHomePos = ESC + '[H';          // Move cursor to home position

  // Cursor Visibility
  CSIShowCursor = ESC + '[?25h';          // Show cursor
  CSIHideCursor = ESC + '[?25l';          // Hide cursor
  CSIBlinkCursor = ESC + '[?12h';         // Enable cursor blinking
  CSISteadyCursor = ESC + '[?12l';        // Disable cursor blinking

  // Screen Manipulation
  CSIClearScreen = ESC + '[2J';           // Clear screen
  CSIClearLine = ESC + '[2K';             // Clear line
  CSIClearToEndOfLine = ESC + '[K';       // Clear from cusor to end of line
  CSIScrollUp = ESC + '[%dS';             // Scroll up by n lines
  CSIScrollDown = ESC + '[%dT';           // Scroll down by n lines

  // Text Formatting
  CSIBold = ESC + '[1m';                  // Bold text
  CSIUnderline = ESC + '[4m';             // Underline text
  CSIResetFormat = ESC + '[0m';           // Reset text formatting
  CSIResetBackground = #27'[49m';         // Reset background text formatting
  CSIResetForeground = #27'[39m';         // Reset forground text formatting
  CSIInvertColors = ESC + '[7m';          // Invert foreground/background
  CSINormalColors = ESC + '[27m';         // Normal colors

  CSIDim = ESC + '[2m';
  CSIItalic = ESC + '[3m';
  CSIBlink = ESC + '[5m';
  CSIFramed = ESC + '[51m';
  CSIEncircled = ESC + '[52m';

  // Text Modification
  CSIInsertChar = ESC + '[%d@';           // Insert n spaces at cursor position
  CSIDeleteChar = ESC + '[%dP';           // Delete n characters at cursor position
  CSIEraseChar = ESC + '[%dX';            // Erase n characters at cursor position

  // Colors (Foreground and Background)
  CSIFGBlack = ESC + '[30m';
  CSIFGRed = ESC + '[31m';
  CSIFGGreen = ESC + '[32m';
  CSIFGYellow = ESC + '[33m';
  CSIFGBlue = ESC + '[34m';
  CSIFGMagenta = ESC + '[35m';
  CSIFGCyan = ESC + '[36m';
  CSIFGWhite = ESC + '[37m';

  CSIBGBlack = ESC + '[40m';
  CSIBGRed = ESC + '[41m';
  CSIBGGreen = ESC + '[42m';
  CSIBGYellow = ESC + '[43m';
  CSIBGBlue = ESC + '[44m';
  CSIBGMagenta = ESC + '[45m';
  CSIBGCyan = ESC + '[46m';
  CSIBGWhite = ESC + '[47m';

  CSIFGBrightBlack = ESC + '[90m';
  CSIFGBrightRed = ESC + '[91m';
  CSIFGBrightGreen = ESC + '[92m';
  CSIFGBrightYellow = ESC + '[93m';
  CSIFGBrightBlue = ESC + '[94m';
  CSIFGBrightMagenta = ESC + '[95m';
  CSIFGBrightCyan = ESC + '[96m';
  CSIFGBrightWhite = ESC + '[97m';

  CSIBGBrightBlack = ESC + '[100m';
  CSIBGBrightRed = ESC + '[101m';
  CSIBGBrightGreen = ESC + '[102m';
  CSIBGBrightYellow = ESC + '[103m';
  CSIBGBrightBlue = ESC + '[104m';
  CSIBGBrightMagenta = ESC + '[105m';
  CSIBGBrightCyan = ESC + '[106m';
  CSIBGBrightWhite = ESC + '[107m';

  CSIFGRGB = ESC + '[38;2;%d;%d;%dm';        // Foreground RGB
  CSIBGRGB = ESC + '[48;2;%d;%d;%dm';        // Backg

type
  { TCharSet }
  TCharSet = set of AnsiChar;

  { TConsole }
  TConsole = class
  private class var
    FInputCodePage: Cardinal;
    FOutputCodePage: Cardinal;
    FTeletypeDelay: Integer;
    FKeyState: array [0..1, 0..255] of Boolean;
    FPerformanceFrequency: Int64;
    class function EnableVirtualTerminalProcessing(): DWORD; static;
    class function IsStartedFromDelphiIDE(): Boolean; static;

    class function  RandomRange(const aFrom, aTo: Integer): Integer; static;
    class function  RandomBool(): Boolean; static;
    class procedure Wait(const AMilliseconds: Double); static;
  private
    class constructor Create();
    class destructor Destroy();
    constructor CreateInstance();
  public

    class function  GetVersion(): string; static;

    class procedure PrintLogo(const AColor: string); static;

    class procedure ProcessMessages(); static;

    class procedure Print(const AMsg: string); overload; static;
    class procedure PrintLn(const AMsg: string); overload; static;
    class procedure Print(const AMsg: string; const AArgs: array of const); overload; static;
    class procedure PrintLn(const AMsg: string; const AArgs: array of const); overload; static;
    class procedure Print(); overload; static;
    class procedure PrintLn(); overload; static;

    class procedure GetCursorPos(X, Y: PInteger); static;
    class procedure SetCursorPos(const X, Y: Integer); static;
    class procedure SetCursorVisible(const AVisible: Boolean); static;
    class procedure HideCursor(); static;
    class procedure ShowCursor(); static;
    class procedure SaveCursorPos(); static;
    class procedure RestoreCursorPos(); static;
    class procedure MoveCursorUp(const ALines: Integer); static;
    class procedure MoveCursorDown(const ALines: Integer); static;
    class procedure MoveCursorForward(const ACols: Integer); static;
    class procedure MoveCursorBack(const ACols: Integer); static;

    class procedure ClearScreen(); static;

    class procedure ClearLine(); static;
    class procedure ClearToEndOfLine(); static;

    class procedure ClearLineFromCursor(const AColor: string); static;

    class procedure SetBoldText(); static;
    class procedure ResetTextFormat(); static;
    class procedure SetForegroundColor(const AColor: string); static;
    class procedure SetBackgroundColor(const AColor: string); static;
    class procedure SetForegroundRGB(const ARed, AGreen, ABlue: Byte); static;
    class procedure SetBackgroundRGB(const ARed, AGreen, ABlue: Byte); static;

    class procedure GetSize(AWidth: PInteger; AHeight: PInteger); static;

    class procedure SetTitle(const ATitle: string); static;
    class function  GetTitle(): string; static;

    class function  HasOutput(): Boolean; static;
    class function  WasRunFrom(): Boolean; static;
    class procedure WaitForAnyKey(); static;
    class function  AnyKeyPressed(): Boolean; static;

    class procedure ClearKeyStates(); static;
    class procedure ClearKeyboardBuffer(); static;

    class function  IsKeyPressed(AKey: Byte): Boolean; static;
    class function  WasKeyReleased(AKey: Byte): Boolean; static;
    class function  WasKeyPressed(AKey: Byte): Boolean; static;

    class function  ReadKey(): WideChar; static;
    class function  ReadLnX(const AAllowedChars: TCharSet; AMaxLength: Integer; const AColor: string=CSIFGWhite): string; static;

    class procedure Pause(const AForcePause: Boolean = False; AColor: string = CSIFGWhite; const AMsg: string = ''); static;

    class function  WrapTextEx(const ALine: string; AMaxCol: Integer; const ABreakChars: TCharSet=[' ', '-', ',', ':', #9]): string; static;

    class procedure Teletype(const AText: string; const AColor: string=CSIFGWhite; const AMargin: Integer=10; const AMinDelay: Integer=0; const AMaxDelay: Integer=3; const ABreakKey: Byte=VK_ESCAPE); static;
  end;

implementation

{ TConsole }
class function TConsole.EnableVirtualTerminalProcessing(): DWORD;
var
  HOut: THandle;
  LMode: DWORD;
begin
  HOut := GetStdHandle(STD_OUTPUT_HANDLE);
  if HOut = INVALID_HANDLE_VALUE then
  begin
    Result := GetLastError;
    Exit;
  end;

  if not GetConsoleMode(HOut, LMode) then
  begin
    Result := GetLastError;
    Exit;
  end;

  LMode := LMode or ENABLE_VIRTUAL_TERMINAL_PROCESSING;
  if not SetConsoleMode(HOut, LMode) then
  begin
    Result := GetLastError;
    Exit;
  end;

  Result := 0;  // Success
end;

class function TConsole.IsStartedFromDelphiIDE(): Boolean;
begin
  // Check if the IDE environment variable is present
  Result := (GetEnvironmentVariable('BDS') <> '');
end;

class procedure TConsole.ProcessMessages();
var
  LMsg: TMsg;
begin
  while Integer(PeekMessage(LMsg, 0, 0, 0, PM_REMOVE)) <> 0 do
  begin
    TranslateMessage(LMsg);
    DispatchMessage(LMsg);
  end;
end;

class function TConsole.RandomRange(const aFrom, aTo: Integer): Integer;
var
  LFrom: Integer;
  LTo: Integer;
begin
  LFrom := aFrom;
  LTo := aTo;

  if AFrom > ATo then
    Result := Random(LFrom - LTo) + ATo
  else
    Result := Random(LTo - LFrom) + AFrom;
end;

class function  TConsole.RandomBool(): Boolean;
begin
  Result := Boolean(RandomRange(0, 2) = 1);
end;


class procedure TConsole.Wait(const AMilliseconds: Double);
var
  LStartCount, LCurrentCount: Int64;
  LElapsedTime: Double;

begin
  // Get the starting value of the performance counter
  QueryPerformanceCounter(LStartCount);

  // Convert milliseconds to seconds for precision timing
  repeat
    QueryPerformanceCounter(LCurrentCount);
    LElapsedTime := (LCurrentCount - LStartCount) / FPerformanceFrequency * 1000.0; // Convert to milliseconds
  until LElapsedTime >= AMilliseconds;
end;

class constructor TConsole.Create();
begin
  FTeletypeDelay := 0;

  // save current console codepage
  FInputCodePage := GetConsoleCP();
  FOutputCodePage := GetConsoleOutputCP();

  // set code page to UTF8
  SetConsoleCP(CP_UTF8);
  SetConsoleOutputCP(CP_UTF8);

  EnableVirtualTerminalProcessing();

  QueryPerformanceFrequency(FPerformanceFrequency);
end;

class destructor TConsole.Destroy();
begin
  // restore code page
  SetConsoleCP(FInputCodePage);
  SetConsoleOutputCP(FOutputCodePage);
end;

constructor TConsole.CreateInstance();
begin
end;

class function  TConsole.GetVersion(): string;
begin
  Result := '0.1.0';
end;

class procedure TConsole.PrintLogo(const AColor: string);
begin
  PrintLn(AColor+'    ___                  _');
  PrintLn(AColor+'   / __|___ _ _  ___ ___| |___™');
  PrintLn(AColor+'  | (__/ _ \ '' \(_-</ _ \ / -_)');
  PrintLn(AColor+'   \___\___/_||_/__/\___/_\___|');
  PrintLn(AColor+'       Delphi CSI Console');
end;

class procedure TConsole.Print(const AMsg: string);
begin
  if not HasOutput() then Exit;
  Write(AMsg+CSIResetFormat);
end;

class procedure TConsole.PrintLn(const AMsg: string);
begin
  if not HasOutput() then Exit;
  WriteLn(AMsg+CSIResetFormat);
end;

class procedure TConsole.Print(const AMsg: string; const AArgs: array of const);
begin
  if not HasOutput() then Exit;
  Write(Format(AMsg, AArgs)+CSIResetFormat);
end;

class procedure TConsole.PrintLn(const AMsg: string; const AArgs: array of const);
begin
  if not HasOutput() then Exit;
  WriteLn(Format(AMsg, AArgs)+CSIResetFormat);
end;

class procedure TConsole.Print();
begin
  if not HasOutput() then Exit;
  Write(CSIResetFormat);
end;

class procedure TConsole.PrintLn();
begin
  if not HasOutput() then Exit;
  WriteLn(CSIResetFormat);
end;

class procedure TConsole.GetCursorPos(X, Y: PInteger);
var
  hConsole: THandle;
  BufferInfo: TConsoleScreenBufferInfo;
begin
  hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  if hConsole = INVALID_HANDLE_VALUE then
    Exit;

  if not GetConsoleScreenBufferInfo(hConsole, BufferInfo) then
    Exit;

  if Assigned(X) then
    X^ := BufferInfo.dwCursorPosition.X;
  if Assigned(Y) then
    Y^ := BufferInfo.dwCursorPosition.Y;
end;

class procedure TConsole.SetCursorPos(const X, Y: Integer);
begin
  if not HasOutput() then Exit;
  // CSICursorPos expects Y parameter first, then X
  Write(Format(CSICursorPos, [Y + 1, X + 1])); // +1 because ANSI is 1-based
end;

class procedure TConsole.SetCursorVisible(const AVisible: Boolean);
var
  ConsoleInfo: TConsoleCursorInfo;
  ConsoleHandle: THandle;
begin
  ConsoleHandle := GetStdHandle(STD_OUTPUT_HANDLE);
  ConsoleInfo.dwSize := 25; // You can adjust cursor size if needed
  ConsoleInfo.bVisible := AVisible;
  SetConsoleCursorInfo(ConsoleHandle, ConsoleInfo);
end;

class procedure TConsole.HideCursor();
begin
  if not HasOutput() then Exit;
  Write(CSIHideCursor);
end;

class procedure TConsole.ShowCursor();
begin
  if not HasOutput() then Exit;
  Write(CSIShowCursor);
end;

class procedure TConsole.SaveCursorPos();
begin
  if not HasOutput() then Exit;
  Write(CSISaveCursorPos);
end;

class procedure TConsole.RestoreCursorPos();
begin
  if not HasOutput() then Exit;
  Write(CSIRestoreCursorPos);
end;

class procedure TConsole.MoveCursorUp(const ALines: Integer);
begin
  if not HasOutput() then Exit;
  Write(Format(CSICursorUp, [ALines]));
end;

class procedure TConsole.MoveCursorDown(const ALines: Integer);
begin
  if not HasOutput() then Exit;
  Write(Format(CSICursorDown, [ALines]));
end;

class procedure TConsole.MoveCursorForward(const ACols: Integer);
begin
  if not HasOutput() then Exit;
  Write(Format(CSICursorForward, [ACols]));
end;

class procedure TConsole.MoveCursorBack(const ACols: Integer);
begin
  if not HasOutput() then Exit;
  Write(Format(CSICursorBack, [ACols]));
end;

class procedure TConsole.ClearScreen();
begin
  if not HasOutput() then Exit;
  Write(#12);
  Write(CSIClearScreen);
  Write(CSICursorHomePos);
end;

class procedure TConsole.ClearLine();
begin
  if not HasOutput() then Exit;
  Write(CR);
  Write(CSIClearLine);
end;

class procedure TConsole.ClearToEndOfLine();
begin
  if not HasOutput() then Exit;
  Write(CSIClearToEndOfLine);
end;

class procedure TConsole.ClearLineFromCursor(const AColor: string);
var
  LConsoleOutput: THandle;
  LConsoleInfo: TConsoleScreenBufferInfo;
  LNumCharsWritten: DWORD;
  LCoord: TCoord;
begin
  LConsoleOutput := GetStdHandle(STD_OUTPUT_HANDLE);

  if GetConsoleScreenBufferInfo(LConsoleOutput, LConsoleInfo) then
  begin
    LCoord.X := 0;
    LCoord.Y := LConsoleInfo.dwCursorPosition.Y;

    Print(AColor, []);
    FillConsoleOutputCharacter(LConsoleOutput, ' ', LConsoleInfo.dwSize.X
      - LConsoleInfo.dwCursorPosition.X, LCoord, LNumCharsWritten);
    SetConsoleCursorPosition(LConsoleOutput, LCoord);
  end;
end;

class procedure TConsole.SetBoldText();
begin
  if not HasOutput() then Exit;
  Write(CSIBold);
end;

class procedure TConsole.ResetTextFormat();
begin
  if not HasOutput() then Exit;
  Write(CSIResetFormat);
end;

class procedure TConsole.SetForegroundColor(const AColor: string);
begin
  if not HasOutput() then Exit;
  Write(AColor);
end;

class procedure TConsole.SetBackgroundColor(const AColor: string);
begin
  if not HasOutput() then Exit;
  Write(AColor);
end;

class procedure TConsole.SetForegroundRGB(const ARed, AGreen, ABlue: Byte);
begin
  if not HasOutput() then Exit;
  Write(Format(CSIFGRGB, [ARed, AGreen, ABlue]));
end;

class procedure TConsole.SetBackgroundRGB(const ARed, AGreen, ABlue: Byte);
begin
  if not HasOutput() then Exit;
  Write(Format(CSIBGRGB, [ARed, AGreen, ABlue]));
end;

class procedure TConsole.GetSize(AWidth: PInteger; AHeight: PInteger);
var
  LConsoleInfo: TConsoleScreenBufferInfo;
begin
  if not HasOutput() then Exit;

  GetConsoleScreenBufferInfo(GetStdHandle(STD_OUTPUT_HANDLE), LConsoleInfo);
  if Assigned(AWidth) then
    AWidth^ := LConsoleInfo.dwSize.X;

  if Assigned(AHeight) then
  AHeight^ := LConsoleInfo.dwSize.Y;
end;

class procedure TConsole.SetTitle(const ATitle: string);
begin
  WinApi.Windows.SetConsoleTitle(PChar(ATitle));
end;

class function  TConsole.GetTitle(): string;
const
  MAX_TITLE_LENGTH = 1024;
var
  LTitle: array[0..MAX_TITLE_LENGTH] of WideChar;
  LTitleLength: DWORD;
begin
  // Get the console title and store it in LTitle
  LTitleLength := GetConsoleTitleW(LTitle, MAX_TITLE_LENGTH);

  // If the title is retrieved, assign it to the result
  if LTitleLength > 0 then
    Result := string(LTitle)
  else
    Result := '';
end;

class function  TConsole.HasOutput(): Boolean;
var
  LStdHandle: THandle;
begin
  LStdHandle := GetStdHandle(STD_OUTPUT_HANDLE);
  Result := (LStdHandle <> INVALID_HANDLE_VALUE) and
            (GetFileType(LStdHandle) = FILE_TYPE_CHAR);
end;

class function  TConsole.WasRunFrom(): Boolean;
var
  LStartupInfo: TStartupInfo;
begin
  LStartupInfo.cb := SizeOf(TStartupInfo);
  GetStartupInfo(LStartupInfo);
  Result := ((LStartupInfo.dwFlags and STARTF_USESHOWWINDOW) = 0);
end;

class procedure TConsole.WaitForAnyKey();
var
  LInputRec: TInputRecord;
  LNumRead: Cardinal;
  LOldMode: DWORD;
  LStdIn: THandle;
begin
  LStdIn := GetStdHandle(STD_INPUT_HANDLE);
  GetConsoleMode(LStdIn, LOldMode);
  SetConsoleMode(LStdIn, 0);
  repeat
    ReadConsoleInput(LStdIn, LInputRec, 1, LNumRead);
  until (LInputRec.EventType and KEY_EVENT <> 0) and
    LInputRec.Event.KeyEvent.bKeyDown;
  SetConsoleMode(LStdIn, LOldMode);
end;

class function  TConsole.AnyKeyPressed(): Boolean;
var
  LNumberOfEvents     : DWORD;
  LBuffer             : TInputRecord;
  LNumberOfEventsRead : DWORD;
  LStdHandle           : THandle;
begin
  Result:=false;
  //get the console handle
  LStdHandle := GetStdHandle(STD_INPUT_HANDLE);
  LNumberOfEvents:=0;
  //get the number of events
  GetNumberOfConsoleInputEvents(LStdHandle,LNumberOfEvents);
  if LNumberOfEvents<> 0 then
  begin
    //retrieve the event
    PeekConsoleInput(LStdHandle,LBuffer,1,LNumberOfEventsRead);
    if LNumberOfEventsRead <> 0 then
    begin
      if LBuffer.EventType = KEY_EVENT then //is a Keyboard event?
      begin
        if LBuffer.Event.KeyEvent.bKeyDown then //the key was pressed?
          Result:=true
        else
          FlushConsoleInputBuffer(LStdHandle); //flush the buffer
      end
      else
      FlushConsoleInputBuffer(LStdHandle);//flush the buffer
    end;
  end;
end;

class procedure TConsole.ClearKeyStates();
begin
  FillChar(FKeyState, SizeOf(FKeyState), 0);
  ClearKeyboardBuffer();
end;

class procedure TConsole.ClearKeyboardBuffer();
var
  LInputRecord: TInputRecord;
  LEventsRead: DWORD;
  LMsg: TMsg;
begin
  while PeekConsoleInput(GetStdHandle(STD_INPUT_HANDLE), LInputRecord, 1, LEventsRead) and (LEventsRead > 0) do
  begin
    ReadConsoleInput(GetStdHandle(STD_INPUT_HANDLE), LInputRecord, 1, LEventsRead);
  end;

  while PeekMessage(LMsg, 0, WM_KEYFIRST, WM_KEYLAST, PM_REMOVE) do
  begin
    // No operation; just removing messages from the queue
  end;
end;

class function  TConsole.IsKeyPressed(AKey: Byte): Boolean;
begin
  Result := (GetAsyncKeyState(AKey) and $8000) <> 0;
end;

class function  TConsole.WasKeyReleased(AKey: Byte): Boolean;
begin
  Result := False;
  if IsKeyPressed(AKey) and (not FKeyState[1, AKey]) then
  begin
    FKeyState[1, AKey] := True;
    Result := True;
  end
  else if (not IsKeyPressed(AKey)) and (FKeyState[1, AKey]) then
  begin
    FKeyState[1, AKey] := False;
    Result := False;
  end;
end;

class function  TConsole.WasKeyPressed(AKey: Byte): Boolean;
begin
  Result := False;
  if IsKeyPressed(AKey) and (not FKeyState[1, AKey]) then
  begin
    FKeyState[1, AKey] := True;
    Result := False;
  end
  else if (not IsKeyPressed(AKey)) and (FKeyState[1, AKey]) then
  begin
    FKeyState[1, AKey] := False;
    Result := True;
  end;
end;

class function  TConsole.ReadKey(): WideChar;
var
  LInputRecord: TInputRecord;
  LEventsRead: DWORD;
begin
  repeat
    ReadConsoleInput(GetStdHandle(STD_INPUT_HANDLE), LInputRecord, 1, LEventsRead);
  until (LInputRecord.EventType = KEY_EVENT) and LInputRecord.Event.KeyEvent.bKeyDown;
  Result := LInputRecord.Event.KeyEvent.UnicodeChar;
end;

class function  TConsole.ReadLnX(const AAllowedChars: TCharSet; AMaxLength: Integer; const AColor: string): string;
var
  LInputChar: Char;
begin
  Result := '';

  repeat
    LInputChar := ReadKey;

    if CharInSet(LInputChar, AAllowedChars) then
    begin
      if Length(Result) < AMaxLength then
      begin
        if not CharInSet(LInputChar, [#10, #0, #13, #8])  then
        begin
          //Print(LInputChar, AColor);
          Print('%s%s', [AColor, LInputChar]);
          Result := Result + LInputChar;
        end;
      end;
    end;
    if LInputChar = #8 then
    begin
      if Length(Result) > 0 then
      begin
        //Print(#8 + ' ' + #8);
        Print(#8 + ' ' + #8, []);
        Delete(Result, Length(Result), 1);
      end;
    end;
  until (LInputChar = #13);

  PrintLn();
end;

class procedure TConsole.Pause(const AForcePause: Boolean; AColor: string; const AMsg: string);
var
  LDoPause: Boolean;
begin
  if not HasOutput then Exit;

  ClearKeyStates();
  ClearKeyboardBuffer();

  if not AForcePause then
  begin
    LDoPause := True;
    if WasRunFrom() then LDoPause := False;
    if IsStartedFromDelphiIDE() then LDoPause := True;
    if not LDoPause then Exit;
  end;

  WriteLn;
  if AMsg = '' then
    Print('%sPress any key to continue... ', [aColor])
  else
    Print('%s%s', [aColor, AMsg]);

  WaitForAnyKey();
  WriteLn;
end;

class function  TConsole.WrapTextEx(const ALine: string; AMaxCol: Integer; const ABreakChars: TCharSet): string;
var
  LText: string;
  LPos: integer;
  LChar: Char;
  LLen: Integer;
  I: Integer;
begin
  LText := ALine.Trim;

  LPos := 0;
  LLen := 0;

  while LPos < LText.Length do
  begin
    Inc(LPos);

    LChar := LText[LPos];

    if LChar = #10 then
    begin
      LLen := 0;
      continue;
    end;

    Inc(LLen);

    if LLen >= AMaxCol then
    begin
      for I := LPos downto 1 do
      begin
        LChar := LText[I];

        if CharInSet(LChar, ABreakChars) then
        begin
          LText.Insert(I, #10);
          Break;
        end;
      end;

      LLen := 0;
    end;
  end;

  Result := LText;
end;

class procedure TConsole.Teletype(const AText: string; const AColor: string; const AMargin: Integer; const AMinDelay: Integer; const AMaxDelay: Integer; const ABreakKey: Byte);
var
  LText: string;
  LMaxCol: Integer;
  LChar: Char;
  LWidth: Integer;
begin
  GetSize(@LWidth, nil);
  LMaxCol := LWidth - AMargin;

  LText := WrapTextEx(AText, LMaxCol);

  for LChar in LText do
  begin
    ProcessMessages();
    Print('%s%s', [AColor, LChar]);
    if not RandomBool() then
      FTeletypeDelay := RandomRange(AMinDelay, AMaxDelay);
    Wait(FTeletypeDelay);
    if IsKeyPressed(ABreakKey) then
    begin
      ClearKeyboardBuffer;
      Break;
    end;
  end;
end;

initialization
  ReportMemoryLeaksOnShutdown := True;
  TConsole.CreateInstance();

finalization

end.
