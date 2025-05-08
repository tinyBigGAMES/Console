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

unit UDemo.SpaceInvaders;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  Winapi.Windows,
  Console,
  Console.Buffer;

procedure Demo_SpaceInvaders;

implementation

const
  // Game constants
  PLAYER_CHAR = 'A';
  ENEMY_CHAR = 'W';
  BULLET_CHAR = '|';
  EXPLOSION_CHAR = '*';
  SHIELD_CHAR = '#';
  
  // Game colors
  PLAYER_COLOR = CSIFGGreen;
  ENEMY_COLOR = CSIFGRed;
  BULLET_COLOR = CSIFGYellow;
  EXPLOSION_COLOR = CSIFGMagenta;
  SHIELD_COLOR = CSIFGCyan;
  SCORE_COLOR = CSIFGWhite;
  
  // Game states
  GAME_STATE_TITLE = 0;
  GAME_STATE_PLAYING = 1;
  GAME_STATE_GAME_OVER = 2;

type
  TEntity = record
    X, Y: Integer;
    Width, Height: Integer;
    Char: WideChar;
    Color: string;
    BgColor: string;
    Active: Boolean;
    Speed: Integer;
    Direction: Integer;
    Health: Integer;
  end;
  
  TBullet = record
    X, Y: Integer;
    Active: Boolean;
    PlayerBullet: Boolean;
  end;
  
  TExplosion = record
    X, Y: Integer;
    Timer: Integer;
    Active: Boolean;
  end;
  
  TShield = record
    X, Y: Integer;
    Health: Integer;
    Active: Boolean;
  end;

procedure Demo_SpaceInvaders;
var
  Buffer: TAsciiBuffer;
  MaxW, MaxH: Integer;
  GameRunning: Boolean;
  //KeyPressed: Boolean;
  Player: TEntity;
  Enemies: array[0..29] of TEntity;  // 6 rows of 5 enemies
  Bullets: array[0..19] of TBullet;
  Explosions: array[0..9] of TExplosion;
  Shields: array[0..11] of TShield;
  EnemyMoveTimer: Integer;
  EnemyFireTimer: Integer;
  Score: Integer;
  Lives: Integer;
  GameState: Integer;
  Title: string;
  GameOverMessage: string;
  //KeyboardInput: Byte;
  EnemiesDirection: Integer;
  EnemySpeed: Integer;
  EnemiesRemaining: Integer;
  Level: Integer;

  // Initialize game entities
  procedure InitGame;
  var
    I, X, Y, Row, Col: Integer;
  begin
    // Clear all entities
    for I := 0 to High(Bullets) do
      Bullets[I].Active := False;
      
    for I := 0 to High(Explosions) do
      Explosions[I].Active := False;
    
    // Initialize player
    Player.X := MaxW div 2;
    Player.Y := MaxH - 4;
    Player.Width := 1;
    Player.Height := 1;
    Player.Char := PLAYER_CHAR;
    Player.Color := PLAYER_COLOR;
    Player.BgColor := CSIBGBlack;
    Player.Active := True;
    Player.Speed := 1;
    Player.Health := 3;
    
    // Initialize enemies in a grid
    EnemiesRemaining := 0;
    for Row := 0 to 4 do
    begin
      for Col := 0 to 5 do
      begin
        I := Row * 6 + Col;
        if I <= High(Enemies) then
        begin
          Enemies[I].X := 10 + Col * 5;
          Enemies[I].Y := 5 + Row * 2;
          Enemies[I].Width := 1;
          Enemies[I].Height := 1;
          Enemies[I].Char := ENEMY_CHAR;
          Enemies[I].Color := ENEMY_COLOR;
          Enemies[I].BgColor := CSIBGBlack;
          Enemies[I].Active := True;
          Enemies[I].Health := 1;
          Inc(EnemiesRemaining);
        end;
      end;
    end;
    
    // Initialize shields (3 shields with 4 blocks each)
    for I := 0 to High(Shields) do
    begin
      X := (I mod 4);
      Y := (I div 4);
      
      Shields[I].X := 10 + Y * (MaxW div 4) + X;
      Shields[I].Y := MaxH - 8;
      Shields[I].Health := 3;
      Shields[I].Active := True;
    end;
    
    // Initialize timers and game state
    EnemyMoveTimer := 0;
    EnemyFireTimer := 0;
    Score := 0;
    Lives := 3;
    GameState := GAME_STATE_TITLE;
    EnemiesDirection := 1;
    EnemySpeed := 30;
    Level := 1;
  end;
  
  // Update player movement
  procedure UpdatePlayer;
  begin
    // Handle player input
    if TConsole.IsKeyPressed(VK_LEFT) and (Player.X > 1) then
      Player.X := Player.X - Player.Speed;
      
    if TConsole.IsKeyPressed(VK_RIGHT) and (Player.X < MaxW - 2) then
      Player.X := Player.X + Player.Speed;
      
    // Fire bullet
    if TConsole.WasKeyPressed(VK_SPACE) then
    begin
      // Find inactive bullet
      for var I := 0 to High(Bullets) do
      begin
        if not Bullets[I].Active then
        begin
          Bullets[I].X := Player.X;
          Bullets[I].Y := Player.Y - 1;
          Bullets[I].Active := True;
          Bullets[I].PlayerBullet := True;
          Break;
        end;
      end;
    end;
  end;
  
  // Update enemy movement and firing
  procedure UpdateEnemies;
  var
    I, LowestX, HighestX, LowestY: Integer;
    ShouldChangeDirection: Boolean;
  begin
    // Update enemy movement timer
    Inc(EnemyMoveTimer);
    if EnemyMoveTimer >= EnemySpeed then
    begin
      EnemyMoveTimer := 0;
      
      // Find boundaries of enemy group
      LowestX := MaxW;
      HighestX := 0;
      LowestY := 0;
      
      for I := 0 to High(Enemies) do
      begin
        if Enemies[I].Active then
        begin
          if Enemies[I].X < LowestX then LowestX := Enemies[I].X;
          if Enemies[I].X > HighestX then HighestX := Enemies[I].X;
          if Enemies[I].Y > LowestY then LowestY := Enemies[I].Y;
        end;
      end;
      
      // Check if enemies need to change direction
      ShouldChangeDirection := (LowestX <= 2) or (HighestX >= MaxW - 2);
      
      // Move each enemy
      for I := 0 to High(Enemies) do
      begin
        if Enemies[I].Active then
        begin
          if ShouldChangeDirection then
          begin
            Enemies[I].Y := Enemies[I].Y + 1;
            
            // End game if enemies reach bottom
            if Enemies[I].Y >= Player.Y - 1 then
            begin
              GameState := GAME_STATE_GAME_OVER;
              GameOverMessage := 'INVASION SUCCESSFUL! GAME OVER!';
            end;
          end
          else
          begin
            Enemies[I].X := Enemies[I].X + EnemiesDirection;
          end;
        end;
      end;
      
      // Change direction if needed
      if ShouldChangeDirection then
        EnemiesDirection := -EnemiesDirection;
    end;
    
    // Update enemy firing timer
    Inc(EnemyFireTimer);
    if EnemyFireTimer >= 15 then
    begin
      EnemyFireTimer := 0;
      
      // Randomly select an active enemy to fire
      if EnemiesRemaining > 0 then
      begin
        var RandomEnemyIndex := TConsole.RandomRange(0, High(Enemies));
        var AttemptsLeft := Length(Enemies);
        
        while (not Enemies[RandomEnemyIndex].Active) and (AttemptsLeft > 0) do
        begin
          RandomEnemyIndex := (RandomEnemyIndex + 1) mod Length(Enemies);
          Dec(AttemptsLeft);
        end;
        
        if Enemies[RandomEnemyIndex].Active then
        begin
          // Find inactive bullet
          for I := 0 to High(Bullets) do
          begin
            if not Bullets[I].Active then
            begin
              Bullets[I].X := Enemies[RandomEnemyIndex].X;
              Bullets[I].Y := Enemies[RandomEnemyIndex].Y + 1;
              Bullets[I].Active := True;
              Bullets[I].PlayerBullet := False;
              Break;
            end;
          end;
        end;
      end;
    end;
  end;
  
  // Update bullets
  procedure UpdateBullets;
  var
    I, J: Integer;
    HitDetected: Boolean;
  begin
    for I := 0 to High(Bullets) do
    begin
      if Bullets[I].Active then
      begin
        // Move bullet
        if Bullets[I].PlayerBullet then
          Bullets[I].Y := Bullets[I].Y - 1
        else
          Bullets[I].Y := Bullets[I].Y + 1;
          
        // Check if bullet is out of bounds
        if (Bullets[I].Y < 0) or (Bullets[I].Y >= MaxH) then
        begin
          Bullets[I].Active := False;
          Continue;
        end;
        
        // Check collisions
        HitDetected := False;
        
        // Player bullet vs enemies
        if Bullets[I].PlayerBullet then
        begin
          // Check enemy collisions
          for J := 0 to High(Enemies) do
          begin
            if Enemies[J].Active and (Bullets[I].X = Enemies[J].X) and (Bullets[I].Y = Enemies[J].Y) then
            begin
              Enemies[J].Active := False;
              Bullets[I].Active := False;
              Dec(EnemiesRemaining);
              Inc(Score, 10);
              HitDetected := True;
              
              // Create explosion
              for var K := 0 to High(Explosions) do
              begin
                if not Explosions[K].Active then
                begin
                  Explosions[K].X := Enemies[J].X;
                  Explosions[K].Y := Enemies[J].Y;
                  Explosions[K].Timer := 5;
                  Explosions[K].Active := True;
                  Break;
                end;
              end;
              
              Break;
            end;
          end;
          
          // Check if all enemies defeated
          if EnemiesRemaining = 0 then
          begin
            // Start next level
            Inc(Level);
            EnemySpeed := Max(5, EnemySpeed - 5); // Speed up enemies
            InitGame;
          end;
        end
        // Enemy bullet vs player
        else if (Bullets[I].X = Player.X) and (Bullets[I].Y = Player.Y) then
        begin
          Bullets[I].Active := False;
          Dec(Lives);
          HitDetected := True;
          
          // Create explosion
          for var K := 0 to High(Explosions) do
          begin
            if not Explosions[K].Active then
            begin
              Explosions[K].X := Player.X;
              Explosions[K].Y := Player.Y;
              Explosions[K].Timer := 5;
              Explosions[K].Active := True;
              Break;
            end;
          end;
          
          if Lives <= 0 then
          begin
            GameState := GAME_STATE_GAME_OVER;
            GameOverMessage := 'YOU LOST ALL YOUR SHIPS! GAME OVER!';
          end;
        end;
        
        // Check shield collisions
        if not HitDetected then
        begin
          for J := 0 to High(Shields) do
          begin
            if Shields[J].Active and (Bullets[I].X = Shields[J].X) and (Bullets[I].Y = Shields[J].Y) then
            begin
              Bullets[I].Active := False;
              Dec(Shields[J].Health);
              //HitDetected := True;
              
              if Shields[J].Health <= 0 then
                Shields[J].Active := False;
                
              Break;
            end;
          end;
        end;
      end;
    end;
  end;
  
  // Update explosions
  procedure UpdateExplosions;
  var
    I: Integer;
  begin
    for I := 0 to High(Explosions) do
    begin
      if Explosions[I].Active then
      begin
        Dec(Explosions[I].Timer);
        if Explosions[I].Timer <= 0 then
          Explosions[I].Active := False;
      end;
    end;
  end;
  
  // Render game entities to buffer
  procedure RenderGame;
  var
    I: Integer;
    StatusLine: string;
  begin
    // Clear buffer
    Buffer.Clear(' ', CSIDim+CSIFGWhite, CSIBGBlack);
    
    // Render game state
    case GameState of
      GAME_STATE_TITLE:
      begin
        // Draw title screen
        Title := 'SPACE INVADERS';
        for I := 0 to Length(Title) - 1 do
          Buffer.PutChar(MaxW div 2 - Length(Title) div 2 + I, MaxH div 2 - 5, Title[I+1], CSIFGGreen, CSIBGBlack);
          
        Title := 'Press [S] to Start';
        for I := 0 to Length(Title) - 1 do
          Buffer.PutChar(MaxW div 2 - Length(Title) div 2 + I, MaxH div 2, Title[I+1], CSIFGYellow, CSIBGBlack);
          
        Title := 'Use LEFT/RIGHT to move, SPACE to fire';
        for I := 0 to Length(Title) - 1 do
          Buffer.PutChar(MaxW div 2 - Length(Title) div 2 + I, MaxH div 2 + 2, Title[I+1], CSIFGWhite, CSIBGBlack);
          
        Title := 'ESC to quit';
        for I := 0 to Length(Title) - 1 do
          Buffer.PutChar(MaxW div 2 - Length(Title) div 2 + I, MaxH div 2 + 4, Title[I+1], CSIFGWhite, CSIBGBlack);
      end;
      
      GAME_STATE_PLAYING:
      begin
        // Render player
        Buffer.PutChar(Player.X, Player.Y, Player.Char, Player.Color, Player.BgColor);
        
        // Render enemies
        for I := 0 to High(Enemies) do
        begin
          if Enemies[I].Active then
            Buffer.PutChar(Enemies[I].X, Enemies[I].Y, Enemies[I].Char, Enemies[I].Color, Enemies[I].BgColor);
        end;
        
        // Render bullets
        for I := 0 to High(Bullets) do
        begin
          if Bullets[I].Active then
          begin
            if Bullets[I].PlayerBullet then
              Buffer.PutChar(Bullets[I].X, Bullets[I].Y, BULLET_CHAR, BULLET_COLOR, CSIBGBlack)
            else
              Buffer.PutChar(Bullets[I].X, Bullets[I].Y, BULLET_CHAR, ENEMY_COLOR, CSIBGBlack);
          end;
        end;
        
        // Render explosions
        for I := 0 to High(Explosions) do
        begin
          if Explosions[I].Active then
            Buffer.PutChar(Explosions[I].X, Explosions[I].Y, EXPLOSION_CHAR, EXPLOSION_COLOR, CSIBGBlack);
        end;
        
        // Render shields
        for I := 0 to High(Shields) do
        begin
          if Shields[I].Active then
          begin
            var ShieldColor := SHIELD_COLOR;
            if Shields[I].Health = 2 then
              ShieldColor := CSIFGCyan + CSIDim
            else if Shields[I].Health = 1 then
              ShieldColor := CSIFGBlue + CSIDim;
              
            Buffer.PutChar(Shields[I].X, Shields[I].Y, SHIELD_CHAR, ShieldColor, CSIBGBlack);
          end;
        end;
        
        // Render status line
        StatusLine := Format('LEVEL: %d  SCORE: %d  LIVES: %d  FPS: %.1f', 
                            [Level, Score, Lives, Buffer.ActualFPS]);
        
        for I := 0 to Length(StatusLine) - 1 do
          Buffer.PutChar(2 + I, 1, StatusLine[I+1], SCORE_COLOR, CSIBGBlack);
      end;
      
      GAME_STATE_GAME_OVER:
      begin
        // Render game over screen
        Title := 'GAME OVER';
        for I := 0 to Length(Title) - 1 do
          Buffer.PutChar(MaxW div 2 - Length(Title) div 2 + I, MaxH div 2 - 5, Title[I+1], CSIFGRed, CSIBGBlack);
          
        for I := 0 to Length(GameOverMessage) - 1 do
          Buffer.PutChar(MaxW div 2 - Length(GameOverMessage) div 2 + I, MaxH div 2 - 2, GameOverMessage[I+1], CSIFGYellow, CSIBGBlack);
          
        Title := Format('Final Score: %d', [Score]);
        for I := 0 to Length(Title) - 1 do
          Buffer.PutChar(MaxW div 2 - Length(Title) div 2 + I, MaxH div 2, Title[I+1], CSIFGWhite, CSIBGBlack);
          
        Title := 'Press [S] to Play Again, ESC to Quit';
        for I := 0 to Length(Title) - 1 do
          Buffer.PutChar(MaxW div 2 - Length(Title) div 2 + I, MaxH div 2 + 3, Title[I+1], CSIFGWhite, CSIBGBlack);
      end;
    end;
  end;

begin
  TConsole.SetTitle('TConsole: Space Invaders Demo');
  TConsole.ClearKeyStates();
  TConsole.ClearScreen();
  TConsole.SetCursorVisible(False);
  TConsole.GetSize(@MaxW, @MaxH);
  
  Buffer := TAsciiBuffer.Create(MaxW, MaxH);
  try
    // Set target frame rate
    Buffer.TargetFPS := 60;
    
    // Initialize game
    InitGame;
    
    // Main game loop
    GameRunning := True;
    while GameRunning do
    begin
      // Process input
      if TConsole.WasKeyPressed(VK_ESCAPE) then
      begin
        if GameState = GAME_STATE_PLAYING then
        begin
          InitGame();
          GameState := GAME_STATE_TITLE
        end

        else
          GameRunning := False;
      end;
      
      // Wait for next frame
      if Buffer.BeginFrame then
      begin
        // Handle game state
        case GameState of
          GAME_STATE_TITLE:
          begin
            if TConsole.WasKeyPressed(Ord('S')) then
              GameState := GAME_STATE_PLAYING;
          end;
          
          GAME_STATE_PLAYING:
          begin
            // Update game entities
            UpdatePlayer;
            UpdateEnemies;
            UpdateBullets;
            UpdateExplosions;
          end;
          
          GAME_STATE_GAME_OVER:
          begin
            if TConsole.WasKeyPressed(Ord('S')) then
            begin
              // Reset game
              InitGame;
              GameState := GAME_STATE_PLAYING;
            end;
          end;
        end;
        
        // Render game
        RenderGame;
        
        // Complete frame
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