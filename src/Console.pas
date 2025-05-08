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

{$I Console.Defines.inc}

interface

uses
  WinApi.Windows,
  WinApi.Messages,
  System.SysUtils,
  System.Math;

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

  /// <summary>
  ///   Special constant used to indicate that the console window should be centered
  ///   on screen horizontally or vertically.
  /// </summary>
  /// <remarks>
  ///   When passed as the <c>X</c> or <c>Y</c> position to <c>TConsole.Init</c>,
  ///   this value causes the window to be automatically centered in that dimension.
  /// </remarks>
  POS_CENTER = -1;

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
    FIsInit: Boolean;
    class function EnableVirtualTerminalProcessing(): DWORD; static;
    class function IsStartedFromDelphiIDE(): Boolean; static;
    class function  RandomBool(): Boolean; static;
  private
    class constructor Create();
    class destructor Destroy();
  public

    /// <summary>
    ///   Initializes the console window with a specific title, position, size, font, and font size.
    /// </summary>
    /// <param name="ATitle">
    ///   The title to display in the console window's title bar.
    /// </param>
    /// <param name="X">
    ///   The horizontal screen position (in pixels) of the console window.
    ///   If <c>X &lt; 0</c>, the window will be horizontally centered.
    ///   You may also use the <c>POS_CENTER</c> constant to center the window.
    /// </param>
    /// <param name="Y">
    ///   The vertical screen position (in pixels) of the console window.
    ///   If <c>Y &lt; 0</c>, the window will be vertically centered.
    ///   You may also use the <c>POS_CENTER</c> constant to center the window.
    /// </param>
    /// <param name="AWidth">
    ///   The width of the console in character columns.
    /// </param>
    /// <param name="AHeight">
    ///   The height of the console in character rows.
    /// </param>
    /// <param name="AFontSize">
    ///   The size (height) of the console font in pixels.
    /// </param>
    /// <param name="AFontName">
    ///   The name of the font to use. If the font is not found or the string is empty,
    ///   the default console font will be used.
    ///   Defaults to <c>'Cascadia Mono'</c>.
    /// </param>
    /// <returns>
    ///   <c>True</c> if the console was successfully initialized; otherwise, <c>False</c>.
    /// </returns>
    /// <remarks>
    ///   This method must be called before most <c>TConsole</c> features will function correctly.
    ///   It creates and configures a dedicated console window under full programmatic control.
    /// </remarks>
    class function Init(const ATitle: string; const X, Y, AWidth, AHeight, AFontSize: Integer; const AFontName: string = 'Cascadia Mono'): Boolean; static;

    /// <summary>
    ///   Indicates whether the console has been successfully initialized using <c>Init</c>.
    /// </summary>
    /// <returns>
    ///   <c>True</c> if the console is active; otherwise, <c>False</c>.
    /// </returns>
    /// <remarks>
    ///   Useful for conditionally executing console-related logic.
    /// </remarks>
    class function IsInit(): Boolean; static;

    /// <summary>
    ///   Shuts down the console and releases all associated system resources.
    /// </summary>
    /// <remarks>
    ///   After calling <c>Shutdown</c>, the console can no longer be used unless reinitialized.
    ///   Call this method at the end of your application to clean up properly.
    /// </remarks>
    class procedure Shutdown(); static;

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
    ///   Returns a random integer between the specified inclusive range.
    /// </summary>
    /// <param name="aFrom">
    ///   The lower bound of the range (inclusive).
    /// </param>
    /// <param name="aTo">
    ///   The upper bound of the range (inclusive).
    /// </param>
    /// <returns>
    ///   A pseudo-random integer in the range <c>aFrom</c> to <c>aTo</c>.
    /// </returns>
    /// <remarks>
    ///   Internally uses the standard Delphi random number generator.
    /// </remarks>
    class function RandomRange(const aFrom, aTo: Integer): Integer; static;

    /// <summary>
    ///   Delays execution for a specified duration in milliseconds.
    /// </summary>
    /// <param name="AMilliseconds">
    ///   The number of milliseconds to wait. Can be fractional.
    /// </param>
    /// <remarks>
    ///   This is a blocking delay and is suitable for animations or pacing output,
    ///   but not recommended in performance-sensitive loops.
    /// </remarks>
    class procedure Wait(const AMilliseconds: Double); static;

    /// <summary>
    ///   Attempts to set the console screen buffer size.
    /// </summary>
    /// <param name="AWidth">
    ///   The number of character columns for the console buffer.
    /// </param>
    /// <param name="AHeight">
    ///   The number of character rows for the console buffer.
    /// </param>
    /// <remarks>
    ///   Actual support depends on the operating system and console host.
    ///   May fail or clamp if the requested size exceeds system limits.
    /// </remarks>
    class procedure SetSize(const AWidth, AHeight: Integer);

    /// <summary>
    ///   Writes a string to the console without appending a newline character.
    /// </summary>
    /// <param name="AMsg">
    ///   The message string to output.
    /// </param>
    /// <param name="AResetColor">
    ///   If <c>True</c>, the text formatting will be reset to default after printing.
    ///   If <c>False</c>, the current console formatting (e.g., color) is preserved.
    /// </param>
    /// <remarks>
    ///   Useful when printing styled text with the option to automatically reset the color afterward.
    /// </remarks>
    class procedure Print(const AMsg: string; const AResetFormat: Boolean = True); overload; static;

    /// <summary>
    ///   Writes a string to the console and appends a newline character.
    /// </summary>
    /// <param name="AMsg">
    ///   The message string to output.
    /// </param>
    /// <param name="AResetColor">
    ///   If <c>True</c>, the text formatting will be reset to default after printing.
    ///   If <c>False</c>, the current console formatting (e.g., color) is preserved.
    /// </param>
    /// <remarks>
    ///   This behaves like <c>Print</c>, but moves the cursor to the next line afterward.
    ///   Ideal for structured output where styled text needs cleanup.
    /// </remarks>
    class procedure PrintLn(const AMsg: string; const AResetFormat: Boolean = True); overload; static;

    /// <summary>
    ///   Writes a formatted message to the console without appending a newline.
    /// </summary>
    /// <param name="AMsg">
    ///   A format string containing placeholders for argument substitution (e.g., '%s', '%d').
    /// </param>
    /// <param name="AArgs">
    ///   An array of values to be inserted into the format string.
    /// </param>
    /// <param name="AResetFormat">
    ///   If <c>True</c>, text formatting (e.g., color, style) is reset to default after output.
    ///   If <c>False</c>, the current formatting remains unchanged.
    /// </param>
    /// <remarks>
    ///   This method supports dynamic text styling with optional automatic formatting reset,
    ///   making it ideal for partial or styled console output.
    /// </remarks>
    class procedure Print(const AMsg: string; const AArgs: array of const; const AResetFormat: Boolean = True); overload; static;

    /// <summary>
    ///   Writes a formatted message to the console and appends a newline.
    /// </summary>
    /// <param name="AMsg">
    ///   A format string containing placeholders for argument substitution (e.g., '%s', '%d').
    /// </param>
    /// <param name="AArgs">
    ///   An array of values to be inserted into the format string.
    /// </param>
    /// <param name="AResetFormat">
    ///   If <c>True</c>, text formatting (e.g., color, style) is reset to default after output.
    ///   If <c>False</c>, the current formatting remains unchanged.
    /// </param>
    /// <remarks>
    ///   This method combines formatted output with line advancement,
    ///   and optionally resets text appearance after writing.
    /// </remarks>
    class procedure PrintLn(const AMsg: string; const AArgs: array of const; const AResetFormat: Boolean = True); overload; static;

    /// <summary>
    ///   Writes an empty string to the console without appending a newline.
    /// </summary>
    /// <param name="AResetFormat">
    ///   If <c>True</c>, resets console formatting (e.g., colors, styles) after printing.
    ///   If <c>False</c>, preserves the current formatting state.
    /// </param>
    /// <remarks>
    ///   Useful as a formatting or state-reset operation without visual output.
    /// </remarks>
    class procedure Print(const AResetFormat: Boolean = True); overload; static;

    /// <summary>
    ///   Writes an empty line (newline only) to the console.
    /// </summary>
    /// <param name="AResetFormat">
    ///   If <c>True</c>, resets console formatting (e.g., colors, styles) after printing.
    ///   If <c>False</c>, preserves the current formatting state.
    /// </param>
    /// <remarks>
    ///   Typically used to insert spacing or separate content blocks, with optional formatting reset.
    /// </remarks>
    class procedure PrintLn(const AResetFormat: Boolean = True); overload; static;

    /// <summary>
    ///   Writes a formatted string to the console by interpreting BBC-style pipe codes.
    /// </summary>
    /// <param name="AMsg">
    ///   The message string containing embedded pipe codes (e.g., <c>|01</c>, <c>|#B</c>, <c>|@10,5</c>).
    /// </param>
    /// <remarks>
    ///   This method parses and translates embedded formatting codes into ANSI escape sequences
    ///   to control color, style, and cursor behavior in the console.
    ///
    ///   Supported pipe codes include:
    ///   <list type="bullet">
    ///     <item><c>|00</c> through <c>|15</c> — Foreground color codes</item>
    ///     <item><c>|B0</c> through <c>|B7</c> — Background color codes</item>
    ///     <item><c>|#B</c>, <c>|#I</c>, <c>|#U</c> — Bold, Italic, Underline text styles</item>
    ///     <item><c>|@X,Y</c> — Cursor positioning</item>
    ///     <item><c>|CL</c>, <c>|CE</c> — Clear screen or clear to end of line</item>
    ///     <item><c>||</c> — Escaped literal pipe character</item>
    ///   </list>
    ///
    ///   This allows for readable and compact markup of richly styled console output.
    /// </remarks>
    class procedure PipeWrite(const AMsg: string); overload; static;

    /// <summary>
    ///   Writes a formatted string to the console using pipe codes and appends a newline at the end.
    /// </summary>
    /// <param name="AMsg">
    ///   The message string containing embedded pipe codes (e.g., <c>|#B</c>, <c>|12</c>, <c>|@5,2</c>).
    /// </param>
    /// <remarks>
    ///   Behaves identically to <c>PipeWrite</c> but automatically appends a line break.
    ///   This makes it convenient for structured output where each call ends a line.
    /// </remarks>
    class procedure PipeWriteLn(const AMsg: string); overload; static;

    /// <summary>
    ///   Writes a formatted string to the console using pipe codes and format arguments.
    /// </summary>
    /// <param name="AMsg">
    ///   A message string containing BBC-style pipe codes (e.g., <c>|#B</c>, <c>|12</c>, <c>|@X,Y</c>)
    ///   along with Delphi-style format placeholders (e.g., <c>%s</c>, <c>%d</c>).
    /// </param>
    /// <param name="AArgs">
    ///   An array of values to substitute into the format placeholders in <c>AMsg</c>.
    /// </param>
    /// <remarks>
    ///   This method first applies Delphi-style formatting (via <c>Format</c>), then processes
    ///   the result for pipe codes, converting them into ANSI escape sequences.
    ///   Allows for dynamically styled output using values at runtime.
    /// </remarks>
    class procedure PipeWrite(const AMsg: string; const AArgs: array of const); overload; static;

    /// <summary>
    ///   Writes a formatted string to the console using pipe codes and format arguments,
    ///   and appends a newline character.
    /// </summary>
    /// <param name="AMsg">
    ///   A message string with pipe codes and format placeholders.
    /// </param>
    /// <param name="AArgs">
    ///   An array of values to substitute into the format placeholders in <c>AMsg</c>.
    /// </param>
    /// <remarks>
    ///   This behaves like <c>PipeWrite</c> but automatically moves the cursor to a new line
    ///   after output. Useful for structured or multiline output with formatting.
    /// </remarks>
    class procedure PipeWriteLn(const AMsg: string; const AArgs: array of const); overload; static;

    /// <summary>
    ///   Retrieves the current text content of the system clipboard.
    /// </summary>
    /// <returns>
    ///   A string containing the clipboard text, or an empty string if the clipboard is empty or contains non-text data.
    /// </returns>
    /// <remarks>
    ///   This method accesses the Windows clipboard and returns Unicode text if available.
    ///   Use cautiously in high-frequency polling loops, as clipboard access is a shared system resource.
    /// </remarks>
    class function GetClipboardText(): string; static;

    /// <summary>
    ///   Sets the specified text to the system clipboard.
    /// </summary>
    /// <param name="AText">
    ///   The string to place into the clipboard.
    /// </param>
    /// <remarks>
    ///   Replaces any existing clipboard content with the specified text in Unicode format.
    ///   Can be used to programmatically copy text from a console application.
    /// </remarks>
    class procedure SetClipboardText(const AText: string); static;

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
  inherited;

  FTeletypeDelay := 0;
  FIsInit := False;
  QueryPerformanceFrequency(FPerformanceFrequency);
end;

class destructor TConsole.Destroy();
begin
  Shutdown();

  inherited;
end;

 (*
class function TConsole.Init(const ATitle: string; const X, Y, AWidth, AHeight, AFontSize: Integer; const AFontName: string): Boolean;
var
  hConsole, hInput, hWnd: THandle;
  BufferSize, MaxSize: TCoord;
  WindowSize, TempWindowSize: TSmallRect;
  Style: NativeInt;
  Mode: DWORD;
  FontInfo: TConsoleFontInfoEx; // Correct type from Windows unit
  ColsRows: Boolean;
  ChosenFontName: string;
  FontSetSuccess: Boolean;
  ConsoleCPSet, OutputCPSet: Boolean;
  InitialWindowRect: TRect;
  ActualWidth, ActualHeight: Integer;
begin
  Result := False;

  // 1. Handle existing console for this process
  if GetConsoleWindow <> 0 then
  begin
    // Attempt to free it. If this process owns it, it should be freed.
    // If it's inherited and shared, FreeConsole might not be what you want,
    // but for a new, dedicated console, this is usually the first step.
    if FreeConsole then
    begin
      // Successfully detached.
      // Give a moment for the system to process this, though usually not needed.
      // Sleep(10);
    end;

    // If GetConsoleWindow is still not 0, we couldn't detach or there's another issue.
    if GetConsoleWindow <> 0 then
    begin
      // Consider logging this: 'TConsole.Init: Could not free existing console.'
      Exit;
    end;
  end;

  // 2. Create new private console
  if not AllocConsole then
  begin
    // Consider logging: 'TConsole.Init: AllocConsole failed. Error: ' + SysErrorMessage(GetLastError)
    Exit; // Cannot proceed without a console
  end;

  try
    // 3. Get handles
    hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
    hInput := GetStdHandle(STD_INPUT_HANDLE);
    if (hConsole = INVALID_HANDLE_VALUE) or (hInput = INVALID_HANDLE_VALUE) then
    begin
      // Consider logging: 'TConsole.Init: GetStdHandle failed. Error: ' + SysErrorMessage(GetLastError)
      Exit; // Critical failure
    end;

    SetConsoleCP(CP_UTF8);
    SetConsoleOutputCP(CP_UTF8);


    // 4. Set Font (CRUCIAL for UTF-8 character rendering)
    ZeroMemory(@FontInfo, SizeOf(FontInfo));
    FontInfo.cbSize := SizeOf(FontInfo);
    FontInfo.dwFontSize.X := 0; // Auto-width based on height for TrueType fonts
    FontInfo.dwFontSize.Y := AFontSize;
    FontInfo.FontFamily := FF_MODERN; // Fixed-pitch is generally desired for consoles
    FontInfo.FontWeight := FW_NORMAL;

    if Trim(AFontName) <> '' then
      ChosenFontName := AFontName
    else
      ChosenFontName := 'Consolas'; // Good default for Unicode, widely available

    StringToWideChar(ChosenFontName, FontInfo.FaceName, LF_FACESIZE);

    FontSetSuccess := SetCurrentConsoleFontEx(hConsole, False, FontInfo);
    if not FontSetSuccess then
    begin
      // Consider logging: 'TConsole.Init: Failed to set font ' + ChosenFontName + '. Error: ' + SysErrorMessage(GetLastError)
      // Try a known fallback if the primary choice fails
      if SameText(ChosenFontName, 'Consolas') then // If Consolas itself failed, try Lucida
        ChosenFontName := 'Lucida Console'
      else // If user font failed, try Consolas as primary fallback
        ChosenFontName := 'Consolas';

      StringToWideChar(ChosenFontName, FontInfo.FaceName, LF_FACESIZE);
      FontSetSuccess := SetCurrentConsoleFontEx(hConsole, False, FontInfo);
      if not FontSetSuccess then
      begin
         // Consider logging: 'TConsole.Init: Failed to set fallback font ' + ChosenFontName + '. Error: ' + SysErrorMessage(GetLastError)
         // If font setting fails, UTF-8 display will likely be poor. Proceeding, but expect issues.
      end;
    end;

    // 5. Set Console Code Pages to UTF-8
    ConsoleCPSet := SetConsoleCP(CP_UTF8); // For input
    if not ConsoleCPSet then
    begin
      // Consider logging: 'TConsole.Init: SetConsoleCP(CP_UTF8) failed. Error: ' + SysErrorMessage(GetLastError)
    end;

    OutputCPSet := SetConsoleOutputCP(CP_UTF8); // For output
    if not OutputCPSet then
    begin
      // Consider logging: 'TConsole.Init: SetConsoleOutputCP(CP_UTF8) failed. Error: ' + SysErrorMessage(GetLastError)
      // If setting output CP to UTF-8 fails, character display will be incorrect. This is a major issue.
      // You might want to Exit or raise an exception here if UTF-8 is mandatory.
    end;

    // 6. Hook up standard I/O AFTER setting code pages
    // This ensures Delphi's RTL uses the correct encoding for WriteLn, ReadLn, etc.
    AssignFile(Output, 'CONOUT$'); {$WARNINGS OFF} // Suppress warning about open file
    Rewrite(Output); {$WARNINGS ON}
    AssignFile(Input, 'CONIN$'); {$WARNINGS OFF}
    Reset(Input); {$WARNINGS ON}
    AssignFile(ErrOutput, 'CONOUT$'); {$WARNINGS OFF}
    Rewrite(ErrOutput); {$WARNINGS ON}

    // 7. Apply Console Mode Settings
    if GetConsoleMode(hConsole, Mode) then
    begin
      Mode := Mode or ENABLE_PROCESSED_OUTPUT or ENABLE_WRAP_AT_EOL_OUTPUT;
      // Attempt to enable virtual terminal processing for ANSI escape codes (Win10+)
      Mode := Mode or ENABLE_VIRTUAL_TERMINAL_PROCESSING; // $0004
      if not SetConsoleMode(hConsole, Mode) then
      begin
        // If setting with VT processing failed, try without it (older Windows)
        if GetConsoleMode(hConsole, Mode) then // Get mode again
        begin
           Mode := (Mode and not ENABLE_VIRTUAL_TERMINAL_PROCESSING) // Remove VT flag
                    or ENABLE_PROCESSED_OUTPUT or ENABLE_WRAP_AT_EOL_OUTPUT; // Ensure basics
           SetConsoleMode(hConsole, Mode); // Try setting basic modes
           // Log failure if desired, but proceed
        end;
      end;
    end
    else
    begin
      // Consider logging: 'TConsole.Init: GetConsoleMode failed. Error: ' + SysErrorMessage(GetLastError)
    end;

    // 8. Set console buffer size and window size
    // Determine if AWidth/AHeight are columns/rows or pixels
    // Heuristic: small values are likely columns/rows.
    // Max console dimensions: MaxSize.X columns, MaxSize.Y rows.
    MaxSize := GetLargestConsoleWindowSize(hConsole);
    if (AWidth > 0) and (AWidth <= MaxSize.X) and (AHeight > 0) and (AHeight <= MaxSize.Y) and (AWidth <= 300) and (AHeight <= 200) then // Adjusted heuristic
      ColsRows := True // Assume AWidth/AHeight are columns/rows
    else
      ColsRows := False; // Assume AWidth/AHeight are pixels

    if ColsRows then
    begin
      BufferSize.X := AWidth;
      BufferSize.Y := AHeight;
    end
    else // AWidth, AHeight are pixels, estimate columns/rows
    begin
      // This estimation is very rough. Font metrics would be better but complex.
      // Using AFontSize is a basic approach.
      // For X: common ratio is height/2 for monospaced fonts. If dwFontSize.X was set, use it.
      var CharWidthEst, CharHeightEst: Integer;
      CharHeightEst := AFontSize; // Y is directly AFontSize
      if FontInfo.dwFontSize.X <> 0 then // If font system provided a width
         CharWidthEst := FontInfo.dwFontSize.X
      else // Estimate width
         CharWidthEst := Max(1, AFontSize div 2); // Ensure at least 1

      if CharWidthEst <= 0 then CharWidthEst := 8;   // Fallback if estimation is bad
      if CharHeightEst <= 0 then CharHeightEst := 16; // Fallback

      BufferSize.X := Min(AWidth div CharWidthEst, MaxSize.X);
      BufferSize.Y := Min(AHeight div CharHeightEst, MaxSize.Y);
    end;

    // Ensure buffer size is at least 1x1
    if BufferSize.X < 1 then BufferSize.X := 80; // Default width
    if BufferSize.Y < 1 then BufferSize.Y := 25; // Default height

    // The console window size cannot be larger than the screen buffer size.
    // And buffer cannot be smaller than window. This is tricky.
    // Strategy:
    // 1. Shrink window to minimum.
    // 2. Set desired buffer size.
    // 3. Set desired window size (must be <= buffer size).

    TempWindowSize.Left := 0;
    TempWindowSize.Top := 0;
    TempWindowSize.Right := 0;  // Smallest possible window (1x1 column/row)
    TempWindowSize.Bottom := 0;
    SetConsoleWindowInfo(hConsole, True, @TempWindowSize); // Shrink window

    // Set the screen buffer size
    if not SetConsoleScreenBufferSize(hConsole, BufferSize) then
    begin
      // If setting buffer failed, try to get current buffer and adapt or log
      // GetConsoleScreenBufferInfo(hConsole, ScreenBufferInfo); BufferSize := ScreenBufferInfo.dwSize;
      // Consider logging: 'SetConsoleScreenBufferSize failed. Error: ' + SysErrorMessage(GetLastError)
    end else begin
      // Buffer set, now ensure window is not larger than this new buffer
    end;

    // Define desired window size in terms of columns and rows
    WindowSize.Left := 0;
    WindowSize.Top := 0;
    WindowSize.Right := BufferSize.X - 1;
    WindowSize.Bottom := BufferSize.Y - 1;

    // Ensure window is not larger than current buffer (might have changed if SetConsoleScreenBufferSize failed)
    var CurrentBufferInfo: TConsoleScreenBufferInfo;
    if GetConsoleScreenBufferInfo(hConsole, CurrentBufferInfo) then
    begin
      if WindowSize.Right >= CurrentBufferInfo.dwSize.X then
        WindowSize.Right := CurrentBufferInfo.dwSize.X - 1;
      if WindowSize.Bottom >= CurrentBufferInfo.dwSize.Y then
        WindowSize.Bottom := CurrentBufferInfo.dwSize.Y - 1;
    end;
    // Ensure rect is valid
    if WindowSize.Right < WindowSize.Left then WindowSize.Right := WindowSize.Left;
    if WindowSize.Bottom < WindowSize.Top then WindowSize.Bottom := WindowSize.Top;


    if not SetConsoleWindowInfo(hConsole, True, @WindowSize) then
    begin
      // Consider logging: 'SetConsoleWindowInfo failed. Error: ' + SysErrorMessage(GetLastError)
    end;

    // 9. Position the window and set style
    hWnd := GetConsoleWindow;
    if hWnd <> 0 then
    begin
      if (X >= 0) and (Y >= 0) then // If X, Y are specified for top-left corner
      begin
        if ColsRows then // AWidth/AHeight were cols/rows, so window size is already set by WindowSize
        begin
          // Get current window pixel dimensions to preserve them if not changing size
          GetWindowRect(hWnd, InitialWindowRect);
          ActualWidth := InitialWindowRect.Right - InitialWindowRect.Left;
          ActualHeight := InitialWindowRect.Bottom - InitialWindowRect.Top;
          SetWindowPos(hWnd, 0, X, Y, ActualWidth, ActualHeight, SWP_NOZORDER); // Use X,Y as screen coords
        end
        else // AWidth/AHeight were pixels, use them for window size
        begin
          SetWindowPos(hWnd, 0, X, Y, AWidth, AHeight, SWP_NOZORDER);
        end;
      end;

      // Disable window resize/maximize (as per original code)
      Style := GetWindowLong(hWnd, GWL_STYLE);
      Style := Style and not (WS_SIZEBOX or WS_MAXIMIZEBOX);
      SetWindowLong(hWnd, GWL_STYLE, Style);
      // Force frame change to apply style
      SetWindowPos(hWnd, 0, 0, 0, 0, 0,
        SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED);
    end;

    // 10. Flush to ensure settings are applied
    FlushFileBuffers(hConsole);

    FIsInit := True;

    if not ATitle.IsEmpty then
      SetTitle(ATitle);

    Result := True;

  except
    on E: Exception do
    begin
      // Consider logging: 'TConsole.Init: Exception - ' + E.Message
      // If AllocConsole succeeded, we should free it on failure here
      if GetStdHandle(STD_OUTPUT_HANDLE) <> INVALID_HANDLE_VALUE then // A basic check if we got far enough
      begin
         // Attempt to clean up standard I/O if they were assigned
         // CloseFile(Output); CloseFile(Input); CloseFile(ErrOutput); // Be cautious with this
      end;
      FreeConsole; // Free the console we allocated
      Result := False;
      // Optionally re-raise to notify caller of the problem:
      // raise;
    end;
  end;
end;
*)

// Callback function for font enumeration - stops on first match
function EnumFontFamExProc(var LogFont: TLogFont; var TextMetric: TTextMetric;
  FontType: DWORD; Data: LPARAM): Integer; stdcall;
begin
  // Set the boolean pointer to True (font found)
  PBoolean(Data)^ := True;

  // Return 0 to stop enumeration since we found what we wanted
  Result := 0;
end;

// Helper function to check if a font is available
function IsFontAvailable(const AFontName: string): Boolean;
var
  LDC: HDC;
  LLogFont: TLogFont;
  LFontExists: Boolean;
begin
  Result := False;

  LDC := CreateDC('DISPLAY', nil, nil, nil);
  if LDC <> 0 then
  try
    // Setup logfont for the font we want to check
    FillChar(LLogFont, SizeOf(LLogFont), 0);
    StrPCopy(LLogFont.lfFaceName, AFontName);
    LLogFont.lfCharSet := DEFAULT_CHARSET;

    // Initially not found
    LFontExists := False;

    // Call EnumFontFamiliesEx to check if the font exists
    EnumFontFamiliesEx(LDC, LLogFont, @EnumFontFamExProc, LPARAM(@LFontExists), 0);

    // Return result
    Result := LFontExists;
  finally
    DeleteDC(LDC);
  end;
end;

(*
class function TConsole.Init(const ATitle: string; const X, Y, AWidth, AHeight, AFontSize: Integer; const AFontName: string): Boolean;
var
  hConsole, hInput, hWnd: THandle;
  BufferSize, MaxSize: TCoord;
  WindowSize, TempWindowSize: TSmallRect;
  Style: NativeInt;
  Mode: DWORD;
  FontInfo: TConsoleFontInfoEx;
  ColsRows: Boolean;
  FontSetSuccess: Boolean;
  ConsoleCPSet, OutputCPSet: Boolean;
  InitialWindowRect: TRect;
  ActualWidth, ActualHeight: Integer;
begin
  Result := False;

  // 1. Handle existing console for this process
if GetConsoleWindow <> 0 then
begin
  MessageBox(0,
    'Fatal Error: A console window is already attached to this process.' + sLineBreak +
    'TConsole requires full control of its own console window.' + sLineBreak +
    'Please ensure the application is not launched in console mode.',
    'TConsole Initialization Failure',
    MB_ICONERROR);
  Halt(1);
end;

  // 2. Create new private console
  if not AllocConsole then
  begin
    // Consider logging: 'TConsole.Init: AllocConsole failed. Error: ' + SysErrorMessage(GetLastError)
    Exit; // Cannot proceed without a console
  end;

  try
    // 3. Get handles
    hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
    hInput := GetStdHandle(STD_INPUT_HANDLE);
    if (hConsole = INVALID_HANDLE_VALUE) or (hInput = INVALID_HANDLE_VALUE) then
    begin
      // Consider logging: 'TConsole.Init: GetStdHandle failed. Error: ' + SysErrorMessage(GetLastError)
      Exit; // Critical failure
    end;

    SetConsoleCP(CP_UTF8);
    SetConsoleOutputCP(CP_UTF8);

    // 4. Set Font (ONLY if a font name is specified)
    if Trim(AFontName) <> '' then
    begin
      // Only try to set a font if a name was specified
      if IsFontAvailable(AFontName) then
      begin
        ZeroMemory(@FontInfo, SizeOf(FontInfo));
        FontInfo.cbSize := SizeOf(FontInfo);
        FontInfo.dwFontSize.X := 0; // Auto-width based on height for TrueType fonts
        FontInfo.dwFontSize.Y := AFontSize;
        FontInfo.FontFamily := FF_MODERN; // Fixed-pitch is generally desired for consoles
        FontInfo.FontWeight := FW_NORMAL;

        StringToWideChar(AFontName, FontInfo.FaceName, LF_FACESIZE);

        FontSetSuccess := SetCurrentConsoleFontEx(hConsole, False, FontInfo);
        if not FontSetSuccess then
        begin
          // Consider logging: 'TConsole.Init: Failed to set font ' + AFontName +
          // ' even though it exists. Error: ' + SysErrorMessage(GetLastError)
          // If font setting fails, we just proceed with default font
        end;
      end;
      // If font not available, do nothing and let console use default font
    end;
    // If no font specified, do nothing and let console use default font

    // 5. Set Console Code Pages to UTF-8
    ConsoleCPSet := SetConsoleCP(CP_UTF8); // For input
    if not ConsoleCPSet then
    begin
      // Consider logging: 'TConsole.Init: SetConsoleCP(CP_UTF8) failed. Error: ' + SysErrorMessage(GetLastError)
    end;

    OutputCPSet := SetConsoleOutputCP(CP_UTF8); // For output
    if not OutputCPSet then
    begin
      // Consider logging: 'TConsole.Init: SetConsoleOutputCP(CP_UTF8) failed. Error: ' + SysErrorMessage(GetLastError)
      // If setting output CP to UTF-8 fails, character display will be incorrect. This is a major issue.
      // You might want to Exit or raise an exception here if UTF-8 is mandatory.
    end;

    // 6. Hook up standard I/O AFTER setting code pages
    // This ensures Delphi's RTL uses the correct encoding for WriteLn, ReadLn, etc.
    AssignFile(Output, 'CONOUT$'); {$WARNINGS OFF} // Suppress warning about open file
    Rewrite(Output); {$WARNINGS ON}
    AssignFile(Input, 'CONIN$'); {$WARNINGS OFF}
    Reset(Input); {$WARNINGS ON}
    AssignFile(ErrOutput, 'CONOUT$'); {$WARNINGS OFF}
    Rewrite(ErrOutput); {$WARNINGS ON}

    // 7. Apply Console Mode Settings
    if GetConsoleMode(hConsole, Mode) then
    begin
      Mode := Mode or ENABLE_PROCESSED_OUTPUT or ENABLE_WRAP_AT_EOL_OUTPUT;
      // Attempt to enable virtual terminal processing for ANSI escape codes (Win10+)
      Mode := Mode or ENABLE_VIRTUAL_TERMINAL_PROCESSING; // $0004
      if not SetConsoleMode(hConsole, Mode) then
      begin
        // If setting with VT processing failed, try without it (older Windows)
        if GetConsoleMode(hConsole, Mode) then // Get mode again
        begin
           Mode := (Mode and not ENABLE_VIRTUAL_TERMINAL_PROCESSING) // Remove VT flag
                    or ENABLE_PROCESSED_OUTPUT or ENABLE_WRAP_AT_EOL_OUTPUT; // Ensure basics
           SetConsoleMode(hConsole, Mode); // Try setting basic modes
           // Log failure if desired, but proceed
        end;
      end;
    end
    else
    begin
      // Consider logging: 'TConsole.Init: GetConsoleMode failed. Error: ' + SysErrorMessage(GetLastError)
    end;

    // 8. Set console buffer size and window size
    // Determine if AWidth/AHeight are columns/rows or pixels
    // Heuristic: small values are likely columns/rows.
    // Max console dimensions: MaxSize.X columns, MaxSize.Y rows.
    MaxSize := GetLargestConsoleWindowSize(hConsole);
    if (AWidth > 0) and (AWidth <= MaxSize.X) and (AHeight > 0) and (AHeight <= MaxSize.Y) and (AWidth <= 300) and (AHeight <= 200) then // Adjusted heuristic
      ColsRows := True // Assume AWidth/AHeight are columns/rows
    else
      ColsRows := False; // Assume AWidth/AHeight are pixels

    if ColsRows then
    begin
      BufferSize.X := AWidth;
      BufferSize.Y := AHeight;
    end
    else // AWidth, AHeight are pixels, estimate columns/rows
    begin
      // This estimation is very rough. Font metrics would be better but complex.
      // Using AFontSize is a basic approach.
      // For X: common ratio is height/2 for monospaced fonts. If dwFontSize.X was set, use it.
      var CharWidthEst, CharHeightEst: Integer;
      CharHeightEst := AFontSize; // Y is directly AFontSize
      if (Trim(AFontName) <> '') and FontSetSuccess and (FontInfo.dwFontSize.X <> 0) then
         CharWidthEst := FontInfo.dwFontSize.X
      else // Estimate width
         CharWidthEst := Max(1, AFontSize div 2); // Ensure at least 1

      if CharWidthEst <= 0 then CharWidthEst := 8;   // Fallback if estimation is bad
      if CharHeightEst <= 0 then CharHeightEst := 16; // Fallback

      BufferSize.X := Min(AWidth div CharWidthEst, MaxSize.X);
      BufferSize.Y := Min(AHeight div CharHeightEst, MaxSize.Y);
    end;

    // Ensure buffer size is at least 1x1
    if BufferSize.X < 1 then BufferSize.X := 80; // Default width
    if BufferSize.Y < 1 then BufferSize.Y := 25; // Default height

    // The console window size cannot be larger than the screen buffer size.
    // And buffer cannot be smaller than window. This is tricky.
    // Strategy:
    // 1. Shrink window to minimum.
    // 2. Set desired buffer size.
    // 3. Set desired window size (must be <= buffer size).

    TempWindowSize.Left := 0;
    TempWindowSize.Top := 0;
    TempWindowSize.Right := 0;  // Smallest possible window (1x1 column/row)
    TempWindowSize.Bottom := 0;
    SetConsoleWindowInfo(hConsole, True, @TempWindowSize); // Shrink window

    // Set the screen buffer size
    if not SetConsoleScreenBufferSize(hConsole, BufferSize) then
    begin
      // If setting buffer failed, try to get current buffer and adapt or log
      // GetConsoleScreenBufferInfo(hConsole, ScreenBufferInfo); BufferSize := ScreenBufferInfo.dwSize;
      // Consider logging: 'SetConsoleScreenBufferSize failed. Error: ' + SysErrorMessage(GetLastError)
    end else begin
      // Buffer set, now ensure window is not larger than this new buffer
    end;

    // Define desired window size in terms of columns and rows
    WindowSize.Left := 0;
    WindowSize.Top := 0;
    WindowSize.Right := BufferSize.X - 1;
    WindowSize.Bottom := BufferSize.Y - 1;

    // Ensure window is not larger than current buffer (might have changed if SetConsoleScreenBufferSize failed)
    var CurrentBufferInfo: TConsoleScreenBufferInfo;
    if GetConsoleScreenBufferInfo(hConsole, CurrentBufferInfo) then
    begin
      if WindowSize.Right >= CurrentBufferInfo.dwSize.X then
        WindowSize.Right := CurrentBufferInfo.dwSize.X - 1;
      if WindowSize.Bottom >= CurrentBufferInfo.dwSize.Y then
        WindowSize.Bottom := CurrentBufferInfo.dwSize.Y - 1;
    end;
    // Ensure rect is valid
    if WindowSize.Right < WindowSize.Left then WindowSize.Right := WindowSize.Left;
    if WindowSize.Bottom < WindowSize.Top then WindowSize.Bottom := WindowSize.Top;


    if not SetConsoleWindowInfo(hConsole, True, @WindowSize) then
    begin
      // Consider logging: 'SetConsoleWindowInfo failed. Error: ' + SysErrorMessage(GetLastError)
    end;

    // 9. Position the window and set style
    hWnd := GetConsoleWindow;
    if hWnd <> 0 then
    begin
      if (X >= 0) and (Y >= 0) then // If X, Y are specified for top-left corner
      begin
        if ColsRows then // AWidth/AHeight were cols/rows, so window size is already set by WindowSize
        begin
          // Get current window pixel dimensions to preserve them if not changing size
          GetWindowRect(hWnd, InitialWindowRect);
          ActualWidth := InitialWindowRect.Right - InitialWindowRect.Left;
          ActualHeight := InitialWindowRect.Bottom - InitialWindowRect.Top;
          SetWindowPos(hWnd, 0, X, Y, ActualWidth, ActualHeight, SWP_NOZORDER); // Use X,Y as screen coords
        end
        else // AWidth/AHeight were pixels, use them for window size
        begin
          SetWindowPos(hWnd, 0, X, Y, AWidth, AHeight, SWP_NOZORDER);
        end;
      end;

      // Disable window resize/maximize (as per original code)
      Style := GetWindowLong(hWnd, GWL_STYLE);
      Style := Style and not (WS_SIZEBOX or WS_MAXIMIZEBOX);
      SetWindowLong(hWnd, GWL_STYLE, Style);
      // Force frame change to apply style
      SetWindowPos(hWnd, 0, 0, 0, 0, 0,
        SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED);
    end;

    // 10. Flush to ensure settings are applied
    FlushFileBuffers(hConsole);

    FIsInit := True;

    if not ATitle.IsEmpty then
      SetTitle(ATitle);

    Result := True;

  except
    on E: Exception do
    begin
      // Consider logging: 'TConsole.Init: Exception - ' + E.Message
      // If AllocConsole succeeded, we should free it on failure here
      if GetStdHandle(STD_OUTPUT_HANDLE) <> INVALID_HANDLE_VALUE then // A basic check if we got far enough
      begin
         // Attempt to clean up standard I/O if they were assigned
         // CloseFile(Output); CloseFile(Input); CloseFile(ErrOutput); // Be cautious with this
      end;
      FreeConsole; // Free the console we allocated
      Result := False;
      // Optionally re-raise to notify caller of the problem:
      // raise;
    end;
  end;
end;
*)

class function TConsole.Init(const ATitle: string; const X, Y, AWidth, AHeight, AFontSize: Integer; const AFontName: string): Boolean;
var
  hConsole, hInput, hWnd: THandle;
  BufferSize, MaxSize: TCoord;
  WindowSize, TempWindowSize: TSmallRect;
  Style: NativeInt;
  Mode: DWORD;
  FontInfo: TConsoleFontInfoEx;
  ColsRows: Boolean;
  FontSetSuccess: Boolean;
  ConsoleCPSet, OutputCPSet: Boolean;
  WindowRect: TRect;
  ActualWidth, ActualHeight: Integer;
  DesktopRect: TRect;
  CenterX, CenterY: Integer;
  CharWidthEst, CharHeightEst: Integer;
  CurrentBufferInfo: TConsoleScreenBufferInfo;
begin
  Result := False;

  // 1. Handle existing console for this process
  if GetConsoleWindow <> 0 then
  begin
    MessageBox(0,
      'Fatal Error: A console window is already attached to this process.' + sLineBreak +
      'TConsole requires full control of its own console window.' + sLineBreak +
      'Please ensure the application is not launched in console mode.',
      'TConsole Initialization Failure',
      MB_ICONERROR);
    Halt(1);
  end;

  // 2. Create new private console
  if not AllocConsole then
  begin
    // Consider logging: 'TConsole.Init: AllocConsole failed. Error: ' + SysErrorMessage(GetLastError)
    Exit; // Cannot proceed without a console
  end;

  try
    // 3. Get handles
    hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
    hInput := GetStdHandle(STD_INPUT_HANDLE);
    if (hConsole = INVALID_HANDLE_VALUE) or (hInput = INVALID_HANDLE_VALUE) then
    begin
      // Consider logging: 'TConsole.Init: GetStdHandle failed. Error: ' + SysErrorMessage(GetLastError)
      Exit; // Critical failure
    end;

    SetConsoleCP(CP_UTF8);
    SetConsoleOutputCP(CP_UTF8);

    // 4. Set Font (ONLY if a font name is specified)
    if Trim(AFontName) <> '' then
    begin
      // Only try to set a font if a name was specified
      if IsFontAvailable(AFontName) then
      begin
        ZeroMemory(@FontInfo, SizeOf(FontInfo));
        FontInfo.cbSize := SizeOf(FontInfo);
        FontInfo.dwFontSize.X := 0; // Auto-width based on height for TrueType fonts
        FontInfo.dwFontSize.Y := AFontSize;
        FontInfo.FontFamily := FF_MODERN; // Fixed-pitch is generally desired for consoles
        FontInfo.FontWeight := FW_NORMAL;

        StringToWideChar(AFontName, FontInfo.FaceName, LF_FACESIZE);

        FontSetSuccess := SetCurrentConsoleFontEx(hConsole, False, FontInfo);
        if not FontSetSuccess then
        begin
          // Consider logging: 'TConsole.Init: Failed to set font ' + AFontName +
          // ' even though it exists. Error: ' + SysErrorMessage(GetLastError)
          // If font setting fails, we just proceed with default font
        end;
      end;
      // If font not available, do nothing and let console use default font
    end;
    // If no font specified, do nothing and let console use default font

    // 5. Set Console Code Pages to UTF-8
    ConsoleCPSet := SetConsoleCP(CP_UTF8); // For input
    if not ConsoleCPSet then
    begin
      // Consider logging: 'TConsole.Init: SetConsoleCP(CP_UTF8) failed. Error: ' + SysErrorMessage(GetLastError)
    end;

    OutputCPSet := SetConsoleOutputCP(CP_UTF8); // For output
    if not OutputCPSet then
    begin
      // Consider logging: 'TConsole.Init: SetConsoleOutputCP(CP_UTF8) failed. Error: ' + SysErrorMessage(GetLastError)
      // If setting output CP to UTF-8 fails, character display will be incorrect. This is a major issue.
      // You might want to Exit or raise an exception here if UTF-8 is mandatory.
    end;

    // 6. Hook up standard I/O AFTER setting code pages
    // This ensures Delphi's RTL uses the correct encoding for WriteLn, ReadLn, etc.
    AssignFile(Output, 'CONOUT$'); {$WARNINGS OFF} // Suppress warning about open file
    Rewrite(Output); {$WARNINGS ON}
    AssignFile(Input, 'CONIN$'); {$WARNINGS OFF}
    Reset(Input); {$WARNINGS ON}
    AssignFile(ErrOutput, 'CONOUT$'); {$WARNINGS OFF}
    Rewrite(ErrOutput); {$WARNINGS ON}

    // 7. Apply Console Mode Settings
    if GetConsoleMode(hConsole, Mode) then
    begin
      Mode := Mode or ENABLE_PROCESSED_OUTPUT or ENABLE_WRAP_AT_EOL_OUTPUT;
      // Attempt to enable virtual terminal processing for ANSI escape codes (Win10+)
      Mode := Mode or ENABLE_VIRTUAL_TERMINAL_PROCESSING; // $0004
      if not SetConsoleMode(hConsole, Mode) then
      begin
        // If setting with VT processing failed, try without it (older Windows)
        if GetConsoleMode(hConsole, Mode) then // Get mode again
        begin
           Mode := (Mode and not ENABLE_VIRTUAL_TERMINAL_PROCESSING) // Remove VT flag
                    or ENABLE_PROCESSED_OUTPUT or ENABLE_WRAP_AT_EOL_OUTPUT; // Ensure basics
           SetConsoleMode(hConsole, Mode); // Try setting basic modes
           // Log failure if desired, but proceed
        end;
      end;
    end
    else
    begin
      // Consider logging: 'TConsole.Init: GetConsoleMode failed. Error: ' + SysErrorMessage(GetLastError)
    end;

    // 8. Set console buffer size and window size
    // Determine if AWidth/AHeight are columns/rows or pixels
    // Heuristic: small values are likely columns/rows.
    // Max console dimensions: MaxSize.X columns, MaxSize.Y rows.
    MaxSize := GetLargestConsoleWindowSize(hConsole);
    if (AWidth > 0) and (AWidth <= MaxSize.X) and (AHeight > 0) and (AHeight <= MaxSize.Y) and (AWidth <= 300) and (AHeight <= 200) then // Adjusted heuristic
      ColsRows := True // Assume AWidth/AHeight are columns/rows
    else
      ColsRows := False; // Assume AWidth/AHeight are pixels

    if ColsRows then
    begin
      BufferSize.X := AWidth;
      BufferSize.Y := AHeight;
    end
    else // AWidth, AHeight are pixels, estimate columns/rows
    begin
      // This estimation is very rough. Font metrics would be better but complex.
      // Using AFontSize is a basic approach.
      // For X: common ratio is height/2 for monospaced fonts. If dwFontSize.X was set, use it.
      CharHeightEst := AFontSize; // Y is directly AFontSize
      if (Trim(AFontName) <> '') and FontSetSuccess and (FontInfo.dwFontSize.X <> 0) then
         CharWidthEst := FontInfo.dwFontSize.X
      else // Estimate width
         CharWidthEst := Max(1, AFontSize div 2); // Ensure at least 1

      if CharWidthEst <= 0 then CharWidthEst := 8;   // Fallback if estimation is bad
      if CharHeightEst <= 0 then CharHeightEst := 16; // Fallback

      BufferSize.X := Min(AWidth div CharWidthEst, MaxSize.X);
      BufferSize.Y := Min(AHeight div CharHeightEst, MaxSize.Y);
    end;

    // Ensure buffer size is at least 1x1
    if BufferSize.X < 1 then BufferSize.X := 80; // Default width
    if BufferSize.Y < 1 then BufferSize.Y := 25; // Default height

    // The console window size cannot be larger than the screen buffer size.
    // And buffer cannot be smaller than window. This is tricky.
    // Strategy:
    // 1. Shrink window to minimum.
    // 2. Set desired buffer size.
    // 3. Set desired window size (must be <= buffer size).

    TempWindowSize.Left := 0;
    TempWindowSize.Top := 0;
    TempWindowSize.Right := 0;  // Smallest possible window (1x1 column/row)
    TempWindowSize.Bottom := 0;
    SetConsoleWindowInfo(hConsole, True, @TempWindowSize); // Shrink window

    // Set the screen buffer size
    if not SetConsoleScreenBufferSize(hConsole, BufferSize) then
    begin
      // If setting buffer failed, try to get current buffer and adapt or log
      // GetConsoleScreenBufferInfo(hConsole, ScreenBufferInfo); BufferSize := ScreenBufferInfo.dwSize;
      // Consider logging: 'SetConsoleScreenBufferSize failed. Error: ' + SysErrorMessage(GetLastError)
    end else begin
      // Buffer set, now ensure window is not larger than this new buffer
    end;

    // Define desired window size in terms of columns and rows
    WindowSize.Left := 0;
    WindowSize.Top := 0;
    WindowSize.Right := BufferSize.X - 1;
    WindowSize.Bottom := BufferSize.Y - 1;

    // Ensure window is not larger than current buffer (might have changed if SetConsoleScreenBufferSize failed)
    if GetConsoleScreenBufferInfo(hConsole, CurrentBufferInfo) then
    begin
      if WindowSize.Right >= CurrentBufferInfo.dwSize.X then
        WindowSize.Right := CurrentBufferInfo.dwSize.X - 1;
      if WindowSize.Bottom >= CurrentBufferInfo.dwSize.Y then
        WindowSize.Bottom := CurrentBufferInfo.dwSize.Y - 1;
    end;
    // Ensure rect is valid
    if WindowSize.Right < WindowSize.Left then WindowSize.Right := WindowSize.Left;
    if WindowSize.Bottom < WindowSize.Top then WindowSize.Bottom := WindowSize.Top;

    if not SetConsoleWindowInfo(hConsole, True, @WindowSize) then
    begin
      // Consider logging: 'SetConsoleWindowInfo failed. Error: ' + SysErrorMessage(GetLastError)
    end;

    // 9. Position the window and set style
    hWnd := GetConsoleWindow;
    if hWnd <> 0 then
    begin
      // Apply window style changes
      Style := GetWindowLong(hWnd, GWL_STYLE);
      Style := Style and not (WS_SIZEBOX or WS_MAXIMIZEBOX);
      SetWindowLong(hWnd, GWL_STYLE, Style);

      // Force frame change to apply style
      SetWindowPos(hWnd, 0, 0, 0, 0, 0,
        SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED);

      // If using pixel dimensions, apply them now
      if not ColsRows and (AWidth > 0) and (AHeight > 0) then
      begin
        SetWindowPos(hWnd, 0, 0, 0, AWidth, AHeight, SWP_NOMOVE or SWP_NOZORDER);
      end;

      // Allow the window to fully update before proceeding
      Sleep(50);

      // Now position the window, using its actual size
      GetWindowRect(hWnd, WindowRect);
      ActualWidth := WindowRect.Right - WindowRect.Left;
      ActualHeight := WindowRect.Bottom - WindowRect.Top;

      // Calculate position for centering if needed
      if (X < 0) or (Y < 0) then
      begin
        SystemParametersInfo(SPI_GETWORKAREA, 0, @DesktopRect, 0);

        if X < 0 then
          CenterX := ((DesktopRect.Right - DesktopRect.Left) - ActualWidth) div 2 + DesktopRect.Left
        else
          CenterX := X;

        if Y < 0 then
          CenterY := ((DesktopRect.Bottom - DesktopRect.Top) - ActualHeight) div 2 + DesktopRect.Top
        else
          CenterY := Y;

        // Move the window to the desired position (preserve existing size)
        SetWindowPos(hWnd, 0, CenterX, CenterY, 0, 0, SWP_NOSIZE or SWP_NOZORDER);
      end
      else if (X >= 0) and (Y >= 0) then
      begin
        // Move to specified position (preserve existing size)
        SetWindowPos(hWnd, 0, X, Y, 0, 0, SWP_NOSIZE or SWP_NOZORDER);
      end;
    end;

    // 10. Flush to ensure settings are applied
    FlushFileBuffers(hConsole);

    FIsInit := True;

    if not ATitle.IsEmpty then
      SetTitle(ATitle);

    Result := True;

  except
    on E: Exception do
    begin
      // Consider logging: 'TConsole.Init: Exception - ' + E.Message
      // If AllocConsole succeeded, we should free it on failure here
      if GetStdHandle(STD_OUTPUT_HANDLE) <> INVALID_HANDLE_VALUE then // A basic check if we got far enough
      begin
         // Attempt to clean up standard I/O if they were assigned
         // CloseFile(Output); CloseFile(Input); CloseFile(ErrOutput); // Be cautious with this
      end;
      FreeConsole; // Free the console we allocated
      Result := False;
      // Optionally re-raise to notify caller of the problem:
      // raise;
    end;
  end;
end;

class function  TConsole.IsInit(): Boolean;
begin
  Result := FIsInit;
end;

// The TConsole.Shutdown method remains the same as you provided.
class procedure TConsole.Shutdown;
begin
  if not FIsInit then Exit;

  try
    // Close files first to ensure proper cleanup
    try CloseFile(Input); except end;
    try CloseFile(Output); except end;
    try CloseFile(ErrOutput); except end;
  finally
    // Free the console as the very last step
    // Only free if this class/instance "owns" the console.
    // If Init failed to create one, or if one was pre-existing and not managed by this class,
    // this could be problematic. Assuming Init either creates or takes ownership.
    FreeConsole;
  end;

  FIsInit := False;
end;


class function  TConsole.GetVersion(): string;
begin
  Result := '0.3.0';
end;

class procedure TConsole.PrintLogo(const AColor: string);
begin
  PrintLn(AColor+'    ___                  _');
  PrintLn(AColor+'   / __|___ _ _  ___ ___| |___™');
  PrintLn(AColor+'  | (__/ _ \ '' \(_-</ _ \ / -_)');
  PrintLn(AColor+'   \___\___/_||_/__/\___/_\___|');
  PrintLn(AColor+'       Delphi CSI Console');
end;

class procedure TConsole.SetSize(const AWidth, AHeight: Integer);
var
  HOut: THandle;
  //Info: CONSOLE_SCREEN_BUFFER_INFO;
  Rect: TSmallRect;
  LSize: TCoord;
begin
  HOut := GetStdHandle(STD_OUTPUT_HANDLE);

  // Resize screen buffer
  LSize.X := AWidth;
  LSize.Y := AHeight;
  SetConsoleScreenBufferSize(HOut, LSize);

  // Resize window
  Rect.Left := 0;
  Rect.Top := 0;
  Rect.Right := AWidth - 1;
  Rect.Bottom := AHeight - 1;
  SetConsoleWindowInfo(HOut, True, Rect);
end;

class procedure TConsole.Print(const AMsg: string; const AResetFormat: Boolean);
var
  hConsole: THandle;
  WideS: WideString;
  Written: DWORD;
  LResetFormat: string;
begin
  if not HasOutput() then Exit;
  if AResetFormat then
    LREsetFormat := CSIResetFormat
  else
    LResetFormat := '';
  hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  WideS := AMsg+LResetFormat;
  WriteConsoleW(hConsole, PWideChar(WideS), Length(WideS), Written, nil);
end;

class procedure TConsole.PrintLn(const AMsg: string; const AResetFormat: Boolean);
var
  hConsole: THandle;
  WideS: WideString;
  Written: DWORD;
  LResetFormat: string;
begin
  if not HasOutput() then Exit;
  if AResetFormat then
    LREsetFormat := CSIResetFormat
  else
    LResetFormat := '';
  hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  WideS := AMsg + sLineBreak + LResetFormat;
  WriteConsoleW(hConsole, PWideChar(WideS), Length(WideS), Written, nil);
end;

class procedure TConsole.Print(const AMsg: string; const AArgs: array of const; const AResetFormat: Boolean);
var
  hConsole: THandle;
  WideS: WideString;
  Written: DWORD;
  LResetFormat: string;
begin
  if not HasOutput() then Exit;
  if AResetFormat then
    LREsetFormat := CSIResetFormat
  else
    LResetFormat := '';
  hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  WideS := Format(AMsg, AArgs)+LResetFormat;
  WriteConsoleW(hConsole, PWideChar(WideS), Length(WideS), Written, nil);
end;

class procedure TConsole.PrintLn(const AMsg: string; const AArgs: array of const; const AResetFormat: Boolean);
var
  hConsole: THandle;
  WideS: WideString;
  Written: DWORD;
  LResetFormat: string;
begin
  if not HasOutput() then Exit;
  if AResetFormat then
    LREsetFormat := CSIResetFormat
  else
    LResetFormat := '';
  hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  WideS := Format(AMsg, AArgs) + sLineBreak + LResetFormat;
  WriteConsoleW(hConsole, PWideChar(WideS), Length(WideS), Written, nil);
end;

class procedure TConsole.Print(const AResetFormat: Boolean);
var
  hConsole: THandle;
  WideS: WideString;
  Written: DWORD;
  LResetFormat: string;
begin
  if not HasOutput() then Exit;
  if AResetFormat then
    LREsetFormat := CSIResetFormat
  else
    LResetFormat := '';
  hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  WideS := LResetFormat;
  WriteConsoleW(hConsole, PWideChar(WideS), Length(WideS), Written, nil);
end;

class procedure TConsole.PrintLn(const AResetFormat: Boolean);
var
  hConsole: THandle;
  WideS: WideString;
  Written: DWORD;
  LResetFormat: string;
begin
  if not HasOutput() then Exit;
  if AResetFormat then
    LREsetFormat := CSIResetFormat
  else
    LResetFormat := '';
  hConsole := GetStdHandle(STD_OUTPUT_HANDLE);
  WideS :=  sLineBreak + LResetFormat;
  WriteConsoleW(hConsole, PWideChar(WideS), Length(WideS), Written, nil);
end;

class procedure TConsole.PipeWrite(const AMsg: string);
const
  // Foreground colors (regular 0-7, bright 8-15)
  FGMap: array[0..15] of string = (
    '30', '34', '32', '36', '31', '35', '33', '37',
    '90', '94', '92', '96', '91', '95', '93', '97'
  );
  // Background colors
  BGMap: array[0..7] of string = (
    '40', '44', '42', '46', '41', '45', '43', '47'
  );
var
  i, j, commaPos, ColorNum: Integer;
  Ch: Char;
  Code, xStr, yStr: string;
  Output: string;
  x, y: Integer;
  DigitSet: TSysCharSet;
begin
  if not HasOutput() then Exit;

  DigitSet := ['0'..'9'];
  i := 1;
  Output := '';

  while i <= Length(AMsg) do
  begin
    Ch := AMsg[i];
    if (Ch = '|') and (i < Length(AMsg)) then
    begin
      // Lookahead
      if AMsg[i + 1] = '|' then
      begin
        Output := Output + '|'; // literal |
        Inc(i, 2);
        Continue;
      end
      else if (i + 2 <= Length(AMsg)) then
      begin
        Code := Copy(AMsg, i + 1, 2);

        // Reset: |00 - Reset all attributes
        if (Code = '00') then
        begin
          Output := Output + #27 + '[0m';
          Inc(i, 3);
          Continue;
        end
        // Foreground: |01 to |15
        else if TryStrToInt(Code, ColorNum) and (ColorNum >= 0) and (ColorNum <= 15) then
        begin
          Output := Output + #27 + '[' + FGMap[ColorNum] + 'm';
          Inc(i, 3);
          Continue;
        end
        // Background: |B0 to |B7
        else if (UpCase(Code[1]) = 'B') and CharInSet(Code[2], ['0'..'7']) then
        begin
          Output := Output + #27 + '[' + BGMap[Ord(Code[2]) - Ord('0')] + 'm';
          Inc(i, 3);
          Continue;
        end
        // Bold: |#B
        else if (Code = '#B') then
        begin
          Output := Output + #27 + '[1m';
          Inc(i, 3);
          Continue;
        end
        // Dim: |#D
        else if (Code = '#D') then
        begin
          Output := Output + #27 + '[2m';
          Inc(i, 3);
          Continue;
        end
        // Italic: |#I
        else if (Code = '#I') then
        begin
          Output := Output + #27 + '[3m';
          Inc(i, 3);
          Continue;
        end
        // Underline: |#U
        else if (Code = '#U') then
        begin
          Output := Output + #27 + '[4m';
          Inc(i, 3);
          Continue;
        end
        // Blink: |#F (Flash)
        else if (Code = '#F') then
        begin
          Output := Output + #27 + '[5m';
          Inc(i, 3);
          Continue;
        end
        // Inverse: |#R (Reverse)
        else if (Code = '#R') then
        begin
          Output := Output + #27 + '[7m';
          Inc(i, 3);
          Continue;
        end
        // Strikethrough: |#S
        else if (Code = '#S') then
        begin
          Output := Output + #27 + '[9m';
          Inc(i, 3);
          Continue;
        end
        // Cursor positioning: |@X,Y
        else if (Code[1] = '@') and (i + 2 < Length(AMsg)) then
        begin
          // Look for the Y coordinate after the comma
          j := i + 2;
          //commaPos := 0;
          while (j <= Length(AMsg)) and (AMsg[j] <> ',') do
            Inc(j);

          if (j < Length(AMsg)) then
          begin
            commaPos := j;
            xStr := Copy(AMsg, i + 2, commaPos - (i + 2));
            y := j + 1;
            j := y;

            while (j <= Length(AMsg)) and CharInSet(AMsg[j], DigitSet) do
              Inc(j);

            yStr := Copy(AMsg, y, j - y);

            if TryStrToInt(xStr, x) and TryStrToInt(yStr, y) then
            begin
              Output := Output + #27 + '[' + IntToStr(y) + ';' + IntToStr(x) + 'H';
              i := j;
              Continue;
            end;
          end;
        end
        // Clear screen: |CL
        else if (Code = 'CL') then
        begin
          Output := Output + #27 + '[2J' + #27 + '[H';  // Clear screen and home cursor
          Inc(i, 3);
          Continue;
        end
        // Clear to end of line: |CE
        else if (Code = 'CE') then
        begin
          Output := Output + #27 + '[K';
          Inc(i, 3);
          Continue;
        end;
      end;
    end;
    Output := Output + Ch;
    Inc(i);
  end;
  Print(Output);
end;

class procedure TConsole.PipeWriteLn(const AMsg: string);
begin
  PipeWrite(AMsg + sLineBreak);
end;

class procedure TConsole.PipeWrite(const AMsg: string; const AArgs: array of const);
begin
  PipeWrite(Format(AMsg, AArgs));
end;

class procedure TConsole.PipeWriteLn(const AMsg: string; const AArgs: array of const);
begin
  PipeWriteLn(Format(AMsg, AArgs));
end;

class function TConsole.GetClipboardText: string;
var
  Handle: THandle;
  Ptr: PChar;
begin
  Result := '';
  if not OpenClipboard(0) then Exit;
  try
    Handle := GetClipboardData(CF_TEXT);
    if Handle <> 0 then
    begin
      Ptr := GlobalLock(Handle);
      if Ptr <> nil then
      begin
        Result := Ptr;
        GlobalUnlock(Handle);
      end;
    end;
  finally
    CloseClipboard;
  end;
end;

class procedure TConsole.SetClipboardText(const AText: string);
var
  Handle: THandle;
  Ptr: PChar;
  Size: Integer;
begin
  if not OpenClipboard(0) then Exit;
  try
    EmptyClipboard;
    Size := (Length(AText) + 1) * SizeOf(Char);
    Handle := GlobalAlloc(GMEM_MOVEABLE, Size);
    if Handle <> 0 then
    begin
      Ptr := GlobalLock(Handle);
      if Ptr <> nil then
      begin
        Move(PChar(AText)^, Ptr^, Size);
        GlobalUnlock(Handle);
        SetClipboardData(CF_TEXT, Handle);
      end else
        GlobalFree(Handle);
    end;
  finally
    CloseClipboard;
  end;
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

  ShowCursor();

  PrintLn();
  if AMsg = '' then
    Print('%sPress any key to continue... ', [aColor])
  else
    Print('%s%s', [aColor, AMsg]);

  WaitForAnyKey();
  PrintLn();
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

finalization

end.
