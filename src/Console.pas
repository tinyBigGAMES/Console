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

{
  About CSI and Terminal Emulation

  In terminal emulation, CSI stands for Control Sequence Introducer. It is part of the
  ANSI escape code standard, which defines a set of character sequences used to control
  cursor movement, text formatting, color changes, and other console behaviors in text-based terminals.

  A CSI sequence always begins with the Escape (ESC) character, followed by the left square
  bracket '[' — together forming the sequence ESC + '['. What follows is a combination of
  optional parameters and a final command character that tells the terminal what action to perform.

  For example:

    CSICursorPos = ESC + '[%d;%dH';

  This sequence moves the cursor to a specific location on the screen. The %d placeholders
  represent the row (Y) and column (X) values, respectively. So when formatted and written
  to the console, this might look like:

    ESC [10;5H

  This would position the cursor at row 10, column 5.

  CSI sequences are highly versatile and include operations such as:

    - Cursor movement (e.g., up, down, left, right, absolute position)
    - Screen clearing (e.g., clear line, clear screen)
    - Text styling (e.g., bold, underline, colors)
    - Saving and restoring cursor position

  CSI commands are supported in most modern terminal emulators, including the Windows Console
  when Virtual Terminal Processing is enabled.
}

const

  /// <summary>
  ///   Line Feed (LF) character (ASCII 10). Moves the cursor down to the next line.
  /// </summary>
  LF   = AnsiChar(#10);

  /// <summary>
  ///   Carriage Return (CR) character (ASCII 13). Moves the cursor to the beginning of the current line.
  /// </summary>
  CR   = AnsiChar(#13);

  /// <summary>
  ///   Carriage Return + Line Feed combination. Used to mark line endings in Windows text output.
  /// </summary>
  CRLF = LF+CR;

  /// <summary>
  ///   Escape (ESC) character (ASCII 27). Used to start ANSI escape sequences or detect ESC key input.
  /// </summary>
  ESC  = AnsiChar(#27);

  /// <summary>
  ///   Virtual key code for the ESC key (decimal 27).
  /// </summary>
  VK_ESC = 27;

  // Cursor Movement
  CSICursorPos       = ESC + '[%d;%dH';     // Set cursor to (row, col)
  CSICursorUp        = ESC + '[%dA';        // Move cursor up by n lines
  CSICursorDown      = ESC + '[%dB';        // Move cursor down by n lines
  CSICursorForward   = ESC + '[%dC';        // Move cursor forward (right) by n columns
  CSICursorBack      = ESC + '[%dD';        // Move cursor back (left) by n columns
  CSISaveCursorPos   = ESC + '[s';          // Save current cursor position
  CSIRestoreCursorPos= ESC + '[u';          // Restore previously saved cursor position
  CSICursorHomePos   = ESC + '[H';          // Move cursor to home position (1,1)

  // Cursor Visibility
  CSIShowCursor      = ESC + '[?25h';       // Show cursor
  CSIHideCursor      = ESC + '[?25l';       // Hide cursor
  CSIBlinkCursor     = ESC + '[?12h';       // Enable blinking cursor
  CSISteadyCursor    = ESC + '[?12l';       // Disable blinking cursor (steady)

  // Screen Manipulation
  CSIClearScreen     = ESC + '[2J';         // Clear entire screen and move cursor to home
  CSIClearLine       = ESC + '[2K';         // Clear entire current line
  CSIClearToEndOfLine= ESC + '[K';          // Clear from cursor to end of line
  CSIScrollUp        = ESC + '[%dS';        // Scroll screen up by n lines
  CSIScrollDown      = ESC + '[%dT';        // Scroll screen down by n lines

  // Text Formatting
  CSIBold            = ESC + '[1m';         // Enable bold text
  CSIUnderline       = ESC + '[4m';         // Enable underline
  CSIResetFormat     = ESC + '[0m';         // Reset all text attributes
  CSIResetBackground = #27'[49m';           // Reset background color to default
  CSIResetForeground = #27'[39m';           // Reset foreground color to default
  CSIInvertColors    = ESC + '[7m';         // Invert foreground and background colors
  CSINormalColors    = ESC + '[27m';        // Disable inverted colors

  CSIDim             = ESC + '[2m';         // Dim (faint) text
  CSIItalic          = ESC + '[3m';         // Italic text
  CSIBlink           = ESC + '[5m';         // Blinking text
  CSIFramed          = ESC + '[51m';        // Framed text
  CSIEncircled       = ESC + '[52m';        // Encircled text

  // Text Modification
  CSIInsertChar      = ESC + '[%d@';        // Insert n blank characters at cursor
  CSIDeleteChar      = ESC + '[%dP';        // Delete n characters at cursor
  CSIEraseChar       = ESC + '[%dX';        // Erase n characters at cursor (replaces with space)

  // Colors (Foreground)
  CSIFGBlack         = ESC + '[30m';        // Set foreground to black
  CSIFGRed           = ESC + '[31m';        // Set foreground to red
  CSIFGGreen         = ESC + '[32m';        // Set foreground to green
  CSIFGYellow        = ESC + '[33m';        // Set foreground to yellow
  CSIFGBlue          = ESC + '[34m';        // Set foreground to blue
  CSIFGMagenta       = ESC + '[35m';        // Set foreground to magenta
  CSIFGCyan          = ESC + '[36m';        // Set foreground to cyan
  CSIFGWhite         = ESC + '[37m';        // Set foreground to white

  // Colors (Background)
  CSIBGBlack         = ESC + '[40m';        // Set background to black
  CSIBGRed           = ESC + '[41m';        // Set background to red
  CSIBGGreen         = ESC + '[42m';        // Set background to green
  CSIBGYellow        = ESC + '[43m';        // Set background to yellow
  CSIBGBlue          = ESC + '[44m';        // Set background to blue
  CSIBGMagenta       = ESC + '[45m';        // Set background to magenta
  CSIBGCyan          = ESC + '[46m';        // Set background to cyan
  CSIBGWhite         = ESC + '[47m';        // Set background to white

  // Bright Foreground Colors
  CSIFGBrightBlack   = ESC + '[90m';        // Set bright foreground to black (gray)
  CSIFGBrightRed     = ESC + '[91m';        // Set bright foreground to red
  CSIFGBrightGreen   = ESC + '[92m';        // Set bright foreground to green
  CSIFGBrightYellow  = ESC + '[93m';        // Set bright foreground to yellow
  CSIFGBrightBlue    = ESC + '[94m';        // Set bright foreground to blue
  CSIFGBrightMagenta = ESC + '[95m';        // Set bright foreground to magenta
  CSIFGBrightCyan    = ESC + '[96m';        // Set bright foreground to cyan
  CSIFGBrightWhite   = ESC + '[97m';        // Set bright foreground to white

  // Bright Background Colors
  CSIBGBrightBlack   = ESC + '[100m';       // Set bright background to black (gray)
  CSIBGBrightRed     = ESC + '[101m';       // Set bright background to red
  CSIBGBrightGreen   = ESC + '[102m';       // Set bright background to green
  CSIBGBrightYellow  = ESC + '[103m';       // Set bright background to yellow
  CSIBGBrightBlue    = ESC + '[104m';       // Set bright background to blue
  CSIBGBrightMagenta = ESC + '[105m';       // Set bright background to magenta
  CSIBGBrightCyan    = ESC + '[106m';       // Set bright background to cyan
  CSIBGBrightWhite   = ESC + '[107m';       // Set bright background to white

  // RGB Colors
  CSIFGRGB           = ESC + '[38;2;%d;%d;%dm'; // Set foreground to RGB color
  CSIBGRGB           = ESC + '[48;2;%d;%d;%dm'; // Set background to RGB color

type
  /// <summary>
  ///   Defines a set of <c>AnsiChar</c> values used for character filtering or matching.
  /// </summary>
  /// <remarks>
  ///   <c>TCharSet</c> is commonly used in methods that process or validate user input,
  ///   such as restricting accepted characters during console input or text parsing operations.
  ///   Example: <c>['0'..'9']</c> allows only numeric input.
  /// </remarks>
  TCharSet = set of AnsiChar;

  /// <summary>
  ///   <c>TConsole</c> provides a rich set of utility methods for console-based applications,
  ///   including formatted output, cursor control, screen management, keyboard input, and visual effects.
  /// </summary>
  /// <remarks>
  ///   This class is entirely static and is not intended to be instantiated.
  ///   It encapsulates platform-specific features such as ANSI escape codes and Windows console APIs,
  ///   while offering a high-level interface for building robust and interactive console applications.
  ///
  ///   Key features include:
  ///   <list type="bullet">
  ///     <item>Formatted text printing with optional colors</item>
  ///     <item>Cursor position and visibility control</item>
  ///     <item>Screen and line clearing utilities</item>
  ///     <item>Input polling and key state tracking</item>
  ///     <item>Customizable teletype (typewriter-style) output</item>
  ///     <item>Console size and title management</item>
  ///   </list>
  /// </remarks>
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

    /// <summary>
    ///   Retrieves the version string of the <c>TConsole</c> class.
    /// </summary>
    /// <returns>
    ///   A string representing the current version of the <c>TConsole</c> implementation.
    /// </returns>
    class function GetVersion(): string; static;

    /// <summary>
    ///   Prints the ASCII art logo representing <c>TConsole</c> to the standard output.
    /// </summary>
    /// <param name="AColor">
    ///   The ANSI escape color code (e.g., <c>CSIFGGreen</c>) used to render the logo text.
    ///   This must be a valid ANSI-compatible console color string.
    /// </param>
    class procedure PrintLogo(const AColor: string); static;

    /// <summary>
    ///   Processes any pending Windows messages to keep the application responsive.
    /// </summary>
    /// <remarks>
    ///   This is useful in console applications that require message pumping,
    ///   such as those interacting with forms, threads, or asynchronous operations.
    /// </remarks>
    class procedure ProcessMessages(); static;

    /// <summary>
    ///   Writes a string to the console without appending a newline character.
    /// </summary>
    /// <param name="AMsg">
    ///   The message string to write to the console.
    /// </param>
    /// <remarks>
    ///   This method does not move the cursor to a new line after writing.
    ///   Use <c>PrintLn</c> if you want to include a newline automatically.
    /// </remarks>
    class procedure Print(const AMsg: string); overload; static;

    /// <summary>
    ///   Writes a string to the console and appends a newline character at the end.
    /// </summary>
    /// <param name="AMsg">
    ///   The message string to write to the console.
    /// </param>
    /// <remarks>
    ///   This method is equivalent to calling <c>Print</c> followed by a line break.
    /// </remarks>
    class procedure PrintLn(const AMsg: string); overload; static;

    /// <summary>
    ///   Writes a formatted message to the console without appending a newline.
    /// </summary>
    /// <param name="AMsg">
    ///   A format string containing placeholders for argument substitution, similar to <c>Format</c>.
    /// </param>
    /// <param name="AArgs">
    ///   An array of values to insert into the placeholders defined in <c>AMsg</c>.
    /// </param>
    /// <remarks>
    ///   This method supports Delphi-style formatting using format specifiers (e.g., <c>%s</c>, <c>%d</c>).
    ///   The cursor remains on the same line after output.
    /// </remarks>
    class procedure Print(const AMsg: string; const AArgs: array of const); overload; static;

    /// <summary>
    ///   Writes a formatted message to the console and appends a newline at the end.
    /// </summary>
    /// <param name="AMsg">
    ///   A format string containing placeholders for argument substitution, similar to <c>Format</c>.
    /// </param>
    /// <param name="AArgs">
    ///   An array of values to insert into the placeholders defined in <c>AMsg</c>.
    /// </param>
    /// <remarks>
    ///   This method behaves like <c>Print</c> but moves the cursor to the next line after writing.
    /// </remarks>
    class procedure PrintLn(const AMsg: string; const AArgs: array of const); overload; static;

    /// <summary>
    ///   Writes an empty string to the console without appending a newline.
    /// </summary>
    /// <remarks>
    ///   This method performs no visible output but can be used to trigger side effects or formatting behavior.
    /// </remarks>
    class procedure Print(); overload; static;

    /// <summary>
    ///   Writes an empty line to the console by outputting a newline character.
    /// </summary>
    /// <remarks>
    ///   This is useful for creating spacing between blocks of text or output sections.
    /// </remarks>
    class procedure PrintLn(); overload; static;

    /// <summary>
    ///   Retrieves the current position of the console cursor.
    /// </summary>
    /// <param name="X">
    ///   A pointer to an integer that will receive the horizontal (column) position of the cursor, zero-based.
    /// </param>
    /// <param name="Y">
    ///   A pointer to an integer that will receive the vertical (row) position of the cursor, zero-based.
    /// </param>
    /// <remarks>
    ///   Both <c>X</c> and <c>Y</c> must be valid pointers. The method does not allocate memory for them.
    /// </remarks>
    class procedure GetCursorPos(X, Y: PInteger); static;

    /// <summary>
    ///   Sets the console cursor position to the specified coordinates.
    /// </summary>
    /// <param name="X">
    ///   The zero-based horizontal (column) position.
    /// </param>
    /// <param name="Y">
    ///   The zero-based vertical (row) position.
    /// </param>
    /// <remarks>
    ///   Values that exceed the current console buffer size may be clamped or ignored, depending on system behavior.
    /// </remarks>
    class procedure SetCursorPos(const X, Y: Integer); static;

    /// <summary>
    ///   Sets the visibility of the console cursor.
    /// </summary>
    /// <param name="AVisible">
    ///   A boolean value indicating whether the cursor should be visible (<c>True</c>) or hidden (<c>False</c>).
    /// </param>
    /// <remarks>
    ///   Use this method to show or hide the blinking cursor in the console window.
    /// </remarks>
    class procedure SetCursorVisible(const AVisible: Boolean); static;

    /// <summary>
    ///   Hides the console cursor.
    /// </summary>
    /// <remarks>
    ///   Equivalent to calling <c>SetCursorVisible(False)</c>.
    ///   Useful in scenarios like progress displays, animations, or teletype output.
    /// </remarks>
    class procedure HideCursor(); static;

    /// <summary>
    ///   Makes the console cursor visible.
    /// </summary>
    /// <remarks>
    ///   Equivalent to calling <c>SetCursorVisible(True)</c>.
    ///   This is typically used to restore cursor visibility after it has been hidden.
    /// </remarks>
    class procedure ShowCursor(); static;

    /// <summary>
    ///   Saves the current position of the console cursor.
    /// </summary>
    /// <remarks>
    ///   The saved position can later be restored using <c>RestoreCursorPos</c>.
    ///   Useful for temporary cursor movement where the original location should be retained.
    /// </remarks>
    class procedure SaveCursorPos(); static;

    /// <summary>
    ///   Restores the console cursor to the position previously saved by <c>SaveCursorPos</c>.
    /// </summary>
    /// <remarks>
    ///   If no position has been saved, the behavior may be undefined or ignored depending on the system.
    /// </remarks>
    class procedure RestoreCursorPos(); static;

    /// <summary>
    ///   Moves the console cursor up by a specified number of lines.
    /// </summary>
    /// <param name="ALines">
    ///   The number of lines to move the cursor upward.
    ///   Must be a non-negative integer.
    /// </param>
    /// <remarks>
    ///   If the cursor moves above the top of the screen buffer, its position may be clamped to the top.
    /// </remarks>
    class procedure MoveCursorUp(const ALines: Integer); static;

    /// <summary>
    ///   Moves the console cursor down by a specified number of lines.
    /// </summary>
    /// <param name="ALines">
    ///   The number of lines to move the cursor downward.
    ///   Must be a non-negative integer.
    /// </param>
    /// <remarks>
    ///   If the new position exceeds the bottom of the screen buffer, it may be clamped or cause scrolling,
    ///   depending on the system behavior.
    /// </remarks>
    class procedure MoveCursorDown(const ALines: Integer); static;

    /// <summary>
    ///   Moves the console cursor forward (right) by a specified number of columns.
    /// </summary>
    /// <param name="ACols">
    ///   The number of columns to move the cursor forward.
    ///   Must be a non-negative integer.
    /// </param>
    /// <remarks>
    ///   Cursor movement is relative to the current position.
    ///   If the new position exceeds the console buffer width, it may wrap or be clamped.
    /// </remarks>
    class procedure MoveCursorForward(const ACols: Integer); static;

    /// <summary>
    ///   Moves the console cursor backward (left) by a specified number of columns.
    /// </summary>
    /// <param name="ACols">
    ///   The number of columns to move the cursor backward.
    ///   Must be a non-negative integer.
    /// </param>
    /// <remarks>
    ///   Movement is relative to the current cursor position. If the result would move the cursor
    ///   beyond the left edge of the screen buffer, it may be clamped to column zero.
    /// </remarks>
    class procedure MoveCursorBack(const ACols: Integer); static;

    /// <summary>
    ///   Clears the entire console screen and resets the cursor to the top-left position.
    /// </summary>
    /// <remarks>
    ///   This method clears all visible text in the console buffer and positions the cursor at (0,0).
    /// </remarks>
    class procedure ClearScreen(); static;

    /// <summary>
    ///   Clears the entire current line in the console.
    /// </summary>
    /// <remarks>
    ///   This method erases all characters on the line where the cursor is currently positioned
    ///   and resets the cursor to the beginning of that line.
    /// </remarks>
    class procedure ClearLine(); static;

    /// <summary>
    ///   Clears the console content from the current cursor position to the end of the line.
    /// </summary>
    /// <remarks>
    ///   Characters before the cursor position remain untouched. This is useful for selectively
    ///   clearing dynamic or trailing content while preserving the rest of the line.
    /// </remarks>
    class procedure ClearToEndOfLine(); static;

    /// <summary>
    ///   Clears the console content from the current cursor position to the end of the line
    ///   and fills the cleared space with the specified foreground color.
    /// </summary>
    /// <param name="AColor">
    ///   The ANSI escape color code to apply to the cleared area, e.g., <c>CSIFGWhite</c> or <c>CSIFGRed</c>.
    /// </param>
    /// <remarks>
    ///   This method is useful when visually clearing part of a line with consistent styling.
    ///   The color remains active after the call, so reset it using <c>ResetTextFormat</c> if needed.
    /// </remarks>
    class procedure ClearLineFromCursor(const AColor: string); static;

    /// <summary>
    ///   Enables bold text formatting in the console output.
    /// </summary>
    /// <remarks>
    ///   This uses ANSI escape sequences to render subsequent text in bold.
    ///   To revert to normal formatting, call <c>ResetTextFormat</c>.
    ///   Behavior may depend on the terminal's support for bold styling.
    /// </remarks>
    class procedure SetBoldText(); static;

    /// <summary>
    ///   Resets the console text formatting to default.
    /// </summary>
    /// <remarks>
    ///   This clears any previously set styles such as bold, color, or background settings.
    ///   It is good practice to call this after styled output to avoid affecting later output unintentionally.
    /// </remarks>
    class procedure ResetTextFormat(); static;

    /// <summary>
    ///   Sets the foreground (text) color of the console output using an ANSI color code.
    /// </summary>
    /// <param name="AColor">
    ///   A string representing the ANSI escape sequence for the desired foreground color,
    ///   such as <c>CSIFGWhite</c>, <c>CSIFGGreen</c>, etc.
    /// </param>
    /// <remarks>
    ///   This affects all subsequent text output until the formatting is reset or changed.
    ///   The exact appearance may vary depending on the terminal emulator or Windows console configuration.
    /// </remarks>
    class procedure SetForegroundColor(const AColor: string); static;

    /// <summary>
    ///   Sets the background color of the console output using an ANSI color code.
    /// </summary>
    /// <param name="AColor">
    ///   A string representing the ANSI escape sequence for the desired background color,
    ///   such as <c>CSIBGBlack</c>, <c>CSIBGBlue</c>, etc.
    /// </param>
    /// <remarks>
    ///   This color will apply to all characters printed after the call, until changed or reset.
    /// </remarks>
    class procedure SetBackgroundColor(const AColor: string); static;

    /// <summary>
    ///   Sets the console text (foreground) color using RGB values.
    /// </summary>
    /// <param name="ARed">
    ///   The red component of the color (0–255).
    /// </param>
    /// <param name="AGreen">
    ///   The green component of the color (0–255).
    /// </param>
    /// <param name="ABlue">
    ///   The blue component of the color (0–255).
    /// </param>
    /// <remarks>
    ///   This method uses ANSI 24-bit (truecolor) escape codes to provide precise color control.
    ///   Supported only in terminals or consoles that recognize truecolor sequences.
    /// </remarks>
    class procedure SetForegroundRGB(const ARed, AGreen, ABlue: Byte); static;

    /// <summary>
    ///   Sets the console background color using RGB values.
    /// </summary>
    /// <param name="ARed">
    ///   The red component of the color (0–255).
    /// </param>
    /// <param name="AGreen">
    ///   The green component of the color (0–255).
    /// </param>
    /// <param name="ABlue">
    ///   The blue component of the color (0–255).
    /// </param>
    /// <remarks>
    ///   This method uses ANSI 24-bit (truecolor) escape codes to render backgrounds in full RGB.
    ///   Requires terminal support for truecolor output.
    /// </remarks>
    class procedure SetBackgroundRGB(const ARed, AGreen, ABlue: Byte); static;

    /// <summary>
    ///   Retrieves the current size of the console window in character columns and rows.
    /// </summary>
    /// <param name="AWidth">
    ///   A pointer to an integer that will receive the width of the console (number of columns).
    /// </param>
    /// <param name="AHeight">
    ///   A pointer to an integer that will receive the height of the console (number of rows).
    /// </param>
    /// <remarks>
    ///   Both <c>AWidth</c> and <c>AHeight</c> must be valid pointers to writable integers.
    ///   This method queries the current visible buffer size, not the full scrollback buffer.
    /// </remarks>
    class procedure GetSize(AWidth: PInteger; AHeight: PInteger); static;

    /// <summary>
    ///   Sets the title of the console window.
    /// </summary>
    /// <param name="ATitle">
    ///   The new title to display in the console window's title bar.
    /// </param>
    /// <remarks>
    ///   This method updates the visible title of the console, typically shown at the top of the window.
    ///   Long titles may be truncated depending on the system's title bar limitations.
    /// </remarks>
    class procedure SetTitle(const ATitle: string); static;

    /// <summary>
    ///   Retrieves the current title of the console window.
    /// </summary>
    /// <returns>
    ///   A string containing the text currently displayed in the console window's title bar.
    /// </returns>
    /// <remarks>
    ///   The title returned reflects any changes made by <c>SetTitle</c> or other system-level updates.
    /// </remarks>
    class function GetTitle(): string; static;

    /// <summary>
    ///   Determines whether the application currently has access to console output.
    /// </summary>
    /// <returns>
    ///   <c>True</c> if standard output (stdout) is connected to a valid console or redirected stream;
    ///   otherwise, <c>False</c>.
    /// </returns>
    /// <remarks>
    ///   This method is useful for detecting whether console output is available, such as when running in
    ///   a terminal, a redirected pipe, or launched from a GUI environment.
    /// </remarks>
    class function HasOutput(): Boolean; static;

    /// <summary>
    ///   Determines whether the application was launched from a console (command prompt or terminal).
    /// </summary>
    /// <returns>
    ///   <c>True</c> if the application was started from a console; <c>False</c> if started from a GUI environment like Explorer or the Delphi IDE.
    /// </returns>
    /// <remarks>
    ///   This can be used to adjust behavior when running interactively vs. non-interactively.
    /// </remarks>
    class function WasRunFrom(): Boolean; static;

    /// <summary>
    ///   Waits for the user to press any key before continuing execution.
    /// </summary>
    /// <remarks>
    ///   This method blocks execution until a key is detected in the input buffer.
    ///   It is commonly used to pause console applications at the end of execution or between steps.
    /// </remarks>
    class procedure WaitForAnyKey(); static;

    /// <summary>
    ///   Checks whether any key is currently pressed.
    /// </summary>
    /// <returns>
    ///   <c>True</c> if any key is pressed at the moment of the call; otherwise, <c>False</c>.
    /// </returns>
    /// <remarks>
    ///   Unlike <c>WaitForAnyKey</c>, this method is non-blocking and can be polled during loops or idle cycles.
    /// </remarks>
    class function AnyKeyPressed(): Boolean; static;

    /// <summary>
    ///   Clears all internal key state flags used to track key press and release events.
    /// </summary>
    /// <remarks>
    ///   This resets the state data used by <c>WasKeyPressed</c> and <c>WasKeyReleased</c>,
    ///   effectively discarding any previous key state history.
    ///   Use this at the beginning of a frame or logic cycle to ensure accurate input tracking.
    /// </remarks>
    class procedure ClearKeyStates(); static;

    /// <summary>
    ///   Clears the operating system keyboard input buffer.
    /// </summary>
    /// <remarks>
    ///   This discards all unread key presses from the system input queue.
    ///   Useful for ensuring no residual input affects logic after a pause or interaction.
    /// </remarks>
    class procedure ClearKeyboardBuffer(); static;

    /// <summary>
    ///   Determines whether the specified key is currently being held down.
    /// </summary>
    /// <param name="AKey">
    ///   The virtual key code to check, typically a <c>VK_</c> constant such as <c>VK_ESCAPE</c> or <c>VK_RETURN</c>.
    /// </param>
    /// <returns>
    ///   <c>True</c> if the key is currently down; otherwise, <c>False</c>.
    /// </returns>
    /// <remarks>
    ///   This reflects the real-time key state as of the moment the method is called.
    /// </remarks>
    class function IsKeyPressed(AKey: Byte): Boolean; static;

    /// <summary>
    ///   Determines whether the specified key was released since the last key state check.
    /// </summary>
    /// <param name="AKey">
    ///   The virtual key code to check, such as <c>VK_SPACE</c> or <c>Ord('A')</c>.
    /// </param>
    /// <returns>
    ///   <c>True</c> if the key was released (i.e., transitioned from down to up) since the previous update; otherwise, <c>False</c>.
    /// </returns>
    /// <remarks>
    ///   Internally tracked key state must be cleared with <c>ClearKeyStates</c> for accurate frame-by-frame detection.
    /// </remarks>
    class function WasKeyReleased(AKey: Byte): Boolean; static;

    /// <summary>
    ///   Determines whether the specified key was pressed since the last key state check.
    /// </summary>
    /// <param name="AKey">
    ///   The virtual key code to check, such as <c>VK_LEFT</c>, <c>VK_RETURN</c>, or <c>Ord('Z')</c>.
    /// </param>
    /// <returns>
    ///   <c>True</c> if the key was newly pressed (i.e., transitioned from up to down) since the previous update; otherwise, <c>False</c>.
    /// </returns>
    /// <remarks>
    ///   For accurate detection across frames or input cycles, reset states using <c>ClearKeyStates</c>.
    /// </remarks>
    class function WasKeyPressed(AKey: Byte): Boolean; static;

    /// <summary>
    ///   Reads a single key press from the console input without echoing it to the screen.
    /// </summary>
    /// <returns>
    ///   The character corresponding to the key pressed, as a <c>WideChar</c>.
    /// </returns>
    /// <remarks>
    ///   This method waits (blocks) until a key is pressed. It is typically used for secure or interactive input
    ///   where echoing is not desired.
    /// </remarks>
    class function ReadKey(): WideChar; static;

    /// <summary>
    ///   Reads a line of input from the user with input filtering, length limits, and optional color formatting.
    /// </summary>
    /// <param name="AAllowedChars">
    ///   A set of characters that are allowed to be entered (e.g., <c>['0'..'9']</c> for numeric input).
    /// </param>
    /// <param name="AMaxLength">
    ///   The maximum number of characters allowed in the input line.
    /// </param>
    /// <param name="AColor">
    ///   Optional ANSI color string used to display the input text. Defaults to <c>CSIFGWhite</c>.
    /// </param>
    /// <returns>
    ///   A string containing the user-entered line that matches the allowed characters and length.
    /// </returns>
    /// <remarks>
    ///   Characters not in <c>AAllowedChars</c> are ignored at input time. Useful for controlled user prompts.
    /// </remarks>
    class function ReadLnX(const AAllowedChars: TCharSet; AMaxLength: Integer; const AColor: string = CSIFGWhite): string; static;

    /// <summary>
    ///   Pauses program execution and waits for the user to press any key to continue.
    /// </summary>
    /// <param name="AForcePause">
    ///   If <c>True</c>, the pause prompt is always shown, even when the application was not launched from a console.
    ///   If <c>False</c>, the pause only occurs when appropriate (e.g., when run from a terminal).
    /// </param>
    /// <param name="AColor">
    ///   Optional ANSI color string used to format the pause message. Defaults to <c>CSIFGWhite</c>.
    /// </param>
    /// <param name="AMsg">
    ///   An optional custom message to display. If left empty, a default message such as "Press any key to continue..." will be shown.
    /// </param>
    /// <remarks>
    ///   Unlike <c>ReadLn</c>-style pauses, this method waits for any key press, not just ENTER.
    ///   This is commonly used at the end of a program or between steps to ensure the user has acknowledged output.
    /// </remarks>
    class procedure Pause(const AForcePause: Boolean = False; AColor: string = CSIFGWhite; const AMsg: string = ''); static;

    /// <summary>
    ///   Wraps a single line of text into multiple lines based on a specified maximum column width and break characters.
    /// </summary>
    /// <param name="ALine">
    ///   The input string to be wrapped.
    /// </param>
    /// <param name="AMaxCol">
    ///   The maximum number of characters per line before a wrap is attempted.
    /// </param>
    /// <param name="ABreakChars">
    ///   A set of characters where line breaks are allowed. Defaults to common word boundaries like space, dash, comma, colon, and tab.
    /// </param>
    /// <returns>
    ///   A new string with line breaks inserted so that each line does not exceed the specified column width.
    /// </returns>
    /// <remarks>
    ///   This method preserves word boundaries where possible and avoids breaking words across lines unless necessary.
    ///   It is useful for formatting console output to fit within terminal windows or text buffers with fixed width.
    /// </remarks>
    class function WrapTextEx(const ALine: string; AMaxCol: Integer; const ABreakChars: TCharSet = [' ', '-', ',', ':', #9]): string; static;

    /// <summary>
    ///   Simulates teletype-style output by printing text one character at a time with randomized delays.
    /// </summary>
    /// <param name="AText">
    ///   The text to output to the console using a teletype effect.
    /// </param>
    /// <param name="AColor">
    ///   Optional ANSI color string used to display the text. Defaults to <c>CSIFGWhite</c>.
    /// </param>
    /// <param name="AMargin">
    ///   The left margin (in character columns) to indent each line of output.
    /// </param>
    /// <param name="AMinDelay">
    ///   The minimum delay (in milliseconds) between each character.
    /// </param>
    /// <param name="AMaxDelay">
    ///   The maximum delay (in milliseconds) between each character.
    /// </param>
    /// <param name="ABreakKey">
    ///   The virtual key code that allows the user to skip the teletype effect when pressed (e.g., <c>VK_ESCAPE</c>).
    /// </param>
    /// <remarks>
    ///   The method adds a human-like typing delay between characters and allows skipping by pressing the break key.
    ///   Useful for cinematic output, storytelling, or enhanced user engagement in console applications.
    /// </remarks>
    class procedure Teletype(const AText: string; const AColor: string = CSIFGWhite; const AMargin: Integer = 10; const AMinDelay: Integer = 0; const AMaxDelay: Integer = 3; const ABreakKey: Byte = VK_ESCAPE); static;
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
