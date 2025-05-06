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

unit UTestbed;

interface

uses
  WinApi.Windows,
  System.SysUtils,
  Console,
  UCommon,
  UDemo.Effects,
  UDemo.Buffer,
  UDemo.Sprite,
  UDemo.SpaceInvaders,
  UDemo.StellarAssault,
  UDemo.StellarDefender;

procedure RunTests();

implementation

procedure RunTests();
const
  // Menu constants
  MENU_ITEMS_COUNT = 20;
  MENU_START_Y = 7;

  // Colors
  TITLE_COLOR = CSIFGCyan;
  NORMAL_ITEM_COLOR = CSIFGWhite;
  SELECTED_ITEM_COLOR = CSIFGBrightYellow;
  SELECTED_ITEM_BG = CSIBGBlue;

type
  TDemoType = (
    dtClockDisplay,
    dtDashboard,
    dtAnimationPlayer,
    dtBouncingText,
    dtWaveText,
    dtKaleidoscope,
    dtFractalTree,
    dtRainEffect,
    dtFireEffect,
    dtParticleSystem,
    dtColorTunnel,
    dtFlowingText,
    dtAdvancedAnimations,
    dtAdvancedEffects,
    dtAsciiBuffer,
    dtSprite,
    dtStellarAssault,
    dtSpaceInvaders,
    dtStellarDefender,
    dtQuit
  );

  TMenuItem = record
    Title: string;
    DemoType: TDemoType;
    ShortcutKey: Char;
  end;

var
  LDone: Boolean;
  CurrentSelection, LastSelection: Integer; // Added LastSelection to track changes
  MenuItems: array[0..MENU_ITEMS_COUNT-1] of TMenuItem;
  //i: Integer;
  InitialDraw: Boolean; // Flag for initial draw

  // Draw the menu - Initial full draw or selective update
  procedure DrawMenu(FullDraw: Boolean);
  var
    i: Integer;
  begin
    if FullDraw then
    begin
      // Clear screen and draw header only on full draw
      TConsole.ClearScreen();
      TConsole.PrintLogo(CSIFGMagenta);
      TConsole.Print(TITLE_COLOR+'         Version %s'+CRLF, [TConsole.GetVersion()], False);

      // Draw menu items
      for i := 0 to MENU_ITEMS_COUNT-1 do
      begin
        // Set cursor position
        TConsole.SetCursorPos(2, MENU_START_Y + i);

        // Draw item
        if i = CurrentSelection then
        begin
          TConsole.SetForegroundColor(SELECTED_ITEM_COLOR);
          TConsole.SetBackgroundColor(SELECTED_ITEM_BG);
          TConsole.Print(' → ' + MenuItems[i].ShortcutKey + ') ' + MenuItems[i].Title + ' ', False);
        end
        else
        begin
          TConsole.SetForegroundColor(NORMAL_ITEM_COLOR);
          TConsole.Print('   ' + MenuItems[i].ShortcutKey + ') ' + MenuItems[i].Title + ' ', False);
        end;

        // Reset formatting
        TConsole.ResetTextFormat();
      end;

      // Draw footer
      TConsole.SetCursorPos(2, MENU_START_Y + MENU_ITEMS_COUNT + 2);
      TConsole.SetForegroundColor(CSIFGBrightBlack);
      TConsole.Print('Use ↑/↓ to navigate, Enter to select, Q to quit', False);
      TConsole.ResetTextFormat();
    end
    else
    begin
      // Selective update - Only redraw the items that changed
      // Redraw previous selection (now unselected)
      TConsole.SetCursorPos(2, MENU_START_Y + LastSelection);
      TConsole.SetForegroundColor(NORMAL_ITEM_COLOR);
      TConsole.Print('   ' + MenuItems[LastSelection].ShortcutKey + ') ' + MenuItems[LastSelection].Title + ' ', False);
      TConsole.ResetTextFormat();

      // Redraw new selection (now selected)
      TConsole.SetCursorPos(2, MENU_START_Y + CurrentSelection);
      TConsole.SetForegroundColor(SELECTED_ITEM_COLOR);
      TConsole.SetBackgroundColor(SELECTED_ITEM_BG);
      TConsole.Print(' → ' + MenuItems[CurrentSelection].ShortcutKey + ') ' + MenuItems[CurrentSelection].Title + ' ', False);
      TConsole.ResetTextFormat();
    end;
  end;

  // Initialize menu items
  procedure InitMenuItems();
  begin
    MenuItems[0].Title := 'Clock Display Demo';
    MenuItems[0].DemoType := dtClockDisplay;
    MenuItems[0].ShortcutKey := '1';

    MenuItems[1].Title := 'Dashboard Demo';
    MenuItems[1].DemoType := dtDashboard;
    MenuItems[1].ShortcutKey := '2';

    MenuItems[2].Title := 'Animation Player Demo';
    MenuItems[2].DemoType := dtAnimationPlayer;
    MenuItems[2].ShortcutKey := '3';

    MenuItems[3].Title := 'Bouncing Text Demo';
    MenuItems[3].DemoType := dtBouncingText;
    MenuItems[3].ShortcutKey := '4';

    MenuItems[4].Title := 'Wave Text Demo';
    MenuItems[4].DemoType := dtWaveText;
    MenuItems[4].ShortcutKey := '5';

    MenuItems[5].Title := 'Kaleidoscope Demo';
    MenuItems[5].DemoType := dtKaleidoscope;
    MenuItems[5].ShortcutKey := '6';

    MenuItems[6].Title := 'Fractal Tree Demo';
    MenuItems[6].DemoType := dtFractalTree;
    MenuItems[6].ShortcutKey := '7';

    MenuItems[7].Title := 'Rain Effect Demo';
    MenuItems[7].DemoType := dtRainEffect;
    MenuItems[7].ShortcutKey := '8';

    MenuItems[8].Title := 'Fire Effect Demo';
    MenuItems[8].DemoType := dtFireEffect;
    MenuItems[8].ShortcutKey := '9';

    MenuItems[9].Title := 'Particle System Demo';
    MenuItems[9].DemoType := dtParticleSystem;
    MenuItems[9].ShortcutKey := 'A';

    MenuItems[10].Title := 'Color Tunnel Demo';
    MenuItems[10].DemoType := dtColorTunnel;
    MenuItems[10].ShortcutKey := 'B';

    MenuItems[11].Title := 'Flowing Text Demo';
    MenuItems[11].DemoType := dtFlowingText;
    MenuItems[11].ShortcutKey := 'C';

    MenuItems[12].Title := 'Advanced Animations Demo';
    MenuItems[12].DemoType := dtAdvancedAnimations;
    MenuItems[12].ShortcutKey := 'D';

    MenuItems[13].Title := 'Advanced Effects Demo';
    MenuItems[13].DemoType := dtAdvancedEffects;
    MenuItems[13].ShortcutKey := 'E';

    MenuItems[14].Title := 'ASCII Buffer Demo';
    MenuItems[14].DemoType := dtAsciiBuffer;
    MenuItems[14].ShortcutKey := 'F';

    MenuItems[15].Title := 'Sprite Demo';
    MenuItems[15].DemoType := dtSprite;
    MenuItems[15].ShortcutKey := 'G';

    MenuItems[16].Title := 'Stellar Assault Demo';
    MenuItems[16].DemoType := dtStellarAssault;
    MenuItems[16].ShortcutKey := 'H';

    MenuItems[17].Title := 'Space Invaders Demo';
    MenuItems[17].DemoType := dtSpaceInvaders;
    MenuItems[17].ShortcutKey := 'I';

    MenuItems[18].Title := 'Stellar Defender Demo';
    MenuItems[18].DemoType := dtStellarDefender;
    MenuItems[18].ShortcutKey := 'J';

    MenuItems[19].Title := 'Quit';
    MenuItems[19].DemoType := dtQuit;
    MenuItems[19].ShortcutKey := 'Q';
  end;

  // Run the selected demo
  procedure RunSelectedDemo();
  begin
    // Clear screen
    TConsole.ClearScreen();
    TConsole.ResetTextFormat();

    // Run the selected demo
    case MenuItems[CurrentSelection].DemoType of
      dtClockDisplay:      Demo_ClockDisplay();
      dtDashboard:         Demo_Dashboard();
      dtAnimationPlayer:   Demo_AnimationPlayer();
      dtBouncingText:      Demo_BouncingText();
      dtWaveText:          Demo_WaveText();
      dtKaleidoscope:      Demo_Kaleidoscope();
      dtFractalTree:       Demo_FractalTree();
      dtRainEffect:        Demo_RainEffect();
      dtFireEffect:        Demo_FireEffect();
      dtParticleSystem:    Demo_ParticleSystem();
      dtColorTunnel:       Demo_ColorTunnel();
      dtFlowingText:       Demo_FlowingText();
      dtAdvancedAnimations: Demo_AdvancedAnimations();
      dtAdvancedEffects:    Demo_AdvancedEffects();
      dtAsciiBuffer:       Demo_AsciiBuffer();
      dtSprite:            Demo_Sprite();
      dtStellarAssault:    Demo_StellarAssault();
      dtSpaceInvaders:     Demo_SpaceInvaders();
      dtStellarDefender:   Demo_StellarDefender();
      dtQuit:
      begin
       LDone := True;
       Exit;
      end;
    end;

    TConsole.ClearKeyStates();

    // Need to redraw the full menu after returning from a demo
    InitialDraw := True;
  end;

  // Process keyboard input
  procedure ProcessInput();
  var
    i: Integer;
  begin
    while not TConsole.AnyKeyPressed() do
    begin
      Sleep(50); // To reduce CPU usage
    end;

    // Save current selection to know what to redraw
    LastSelection := CurrentSelection;

    // Check arrow keys
    if TConsole.WasKeyPressed(VK_UP) then
    begin
      if CurrentSelection > 0 then
      begin
        Dec(CurrentSelection);
        // Selective redraw - only when selection changes
        DrawMenu(False);
      end;
    end
    else if TConsole.WasKeyPressed(VK_DOWN) then
    begin
      if CurrentSelection < MENU_ITEMS_COUNT-1 then
      begin
        Inc(CurrentSelection);
        // Selective redraw - only when selection changes
        DrawMenu(False);
      end;
    end
    else if TConsole.WasKeyPressed(VK_RETURN) then
    begin
      ClearInput();
      RunSelectedDemo();
    end
    else if TConsole.WasKeyPressed(Ord('Q')) or TConsole.WasKeyPressed(Ord('q')) then
    begin
      LDone := True;
    end
    else
    begin
      // Check for shortcut keys
      for i := 0 to MENU_ITEMS_COUNT-1 do
      begin
        // Check for both uppercase and lowercase of the shortcut key
        if TConsole.WasKeyPressed(Ord(MenuItems[i].ShortcutKey)) or
           TConsole.WasKeyPressed(Ord(LowerCase(MenuItems[i].ShortcutKey)[1])) then
        begin
          CurrentSelection := i;
          RunSelectedDemo();
          Break;
        end;
      end;
    end;
  end;

begin
  // Initialize
  LDone := False;
  CurrentSelection := 0;
  LastSelection := 0;
  InitialDraw := True;
  InitMenuItems();

  // Hide cursor
  TConsole.HideCursor();

  // Main menu loop
  while not LDone do
  begin
    if InitialDraw then
    begin
      DrawMenu(True);  // Full redraw
      InitialDraw := False;
    end;
    ProcessInput();
  end;

  // Clean up
  TConsole.ShowCursor();
  TConsole.ClearScreen();
  TConsole.ResetTextFormat();
end;

end.

