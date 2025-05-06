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

unit UDemo.StellarAssault;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  Winapi.Windows,
  Console,
  Console.Buffer;

procedure Demo_StellarAssault;

implementation

const
  // Game constants
  PLAYER_SHIP = '^';
  PLAYER_SHIP_LEFT = '<';
  PLAYER_SHIP_RIGHT = '>';
  PLAYER_THRUSTER = '|';
  
  ASTEROID_CHARS: array[0..3] of WideChar = ('O', '@', '0', 'Q');
  
  ENEMY_SHIP_A = 'M';
  ENEMY_SHIP_B = 'W';
  ENEMY_SHIP_C = 'X';
  
  PLAYER_BULLET = '|';
  ENEMY_BULLET = '.';
  
  EXPLOSION_CHARS: array[0..4] of WideChar = ('*', '+', '#', 'x', 'X');
  
  STAR_CHARS: array[0..2] of WideChar = ('.', '·', '*');
  
  // Game colors
  PLAYER_COLOR = CSIFGCyan;
  PLAYER_THRUSTER_COLOR = CSIFGYellow;
  ASTEROID_COLOR = CSIFGWhite;
  ENEMY_COLOR_A = CSIFGRed;
  ENEMY_COLOR_B = CSIFGMagenta;
  ENEMY_COLOR_C = CSIFGYellow;
  PLAYER_BULLET_COLOR = CSIFGGreen;
  ENEMY_BULLET_COLOR = CSIFGRed;
  EXPLOSION_COLOR = CSIFGMagenta;
  STAR_COLORS: array[0..3] of string = (CSIFGWhite + CSIDim, CSIFGCyan + CSIDim, CSIFGYellow + CSIDim, CSIFGBlue + CSIDim);
  
  // Game states
  GAME_STATE_TITLE = 0;
  GAME_STATE_PLAYING = 1;
  GAME_STATE_GAME_OVER = 2;
  
  // Enemy movement patterns
  ENEMY_PATTERN_STRAIGHT = 0;
  ENEMY_PATTERN_SINE = 1;
  ENEMY_PATTERN_CIRCLE = 2;
  ENEMY_PATTERN_DIVE = 3;

type
  TEntityType = (etPlayer, etEnemy, etAsteroid, etPlayerBullet, etEnemyBullet, etExplosion, etPowerup, etStar);
  
  TEntity = record
    EntityType: TEntityType;
    X, Y: Double;
    VelX, VelY: Double;
    Char: WideChar;
    Color: string;
    BgColor: string;
    Active: Boolean;
    Health: Integer;
    Size: Integer;
    AnimFrame: Integer;
    AnimTimer: Integer;
    Pattern: Integer;
    PatternParam: Double;
    Value: Integer;
  end;
  
  TParticle = record
    X, Y: Double;
    VelX, VelY: Double;
    Life: Integer;
    Color: string;
    Char: WideChar;
    Active: Boolean;
  end;

// We'll implement a pooled entity system for better performance
const
  MAX_ENTITIES = 200;
  MAX_PARTICLES = 100;
  
var
  // Game entities
  Entities: array[0..MAX_ENTITIES-1] of TEntity;
  Particles: array[0..MAX_PARTICLES-1] of TParticle;
  
  // Game variables
  Score: Integer;
  Level: Integer;
  Lives: Integer;
  GameState: Integer;
  SpawnTimer: Integer;
  PowerupTimer: Integer;
  GameTime: Integer;
  PlayerInvulnerable: Boolean;
  PlayerInvulnerableTimer: Integer;
  
  // Global references
  PlayerIndex: Integer;
  
  // Create a new entity
  function CreateEntity(EntityType: TEntityType; X, Y: Double): Integer;
  var
    I: Integer;
  begin
    Result := -1;
    
    // Find an inactive entity slot
    for I := 0 to MAX_ENTITIES-1 do
    begin
      if not Entities[I].Active then
      begin
        Result := I;
        FillChar(Entities[I], SizeOf(TEntity), 0);
        Entities[I].EntityType := EntityType;
        Entities[I].X := X;
        Entities[I].Y := Y;
        Entities[I].Active := True;
        Entities[I].Health := 1;
        Entities[I].Size := 1;
        Entities[I].BgColor := CSIBGBlack;
        
        // Initialize entity based on type
        case EntityType of
          etPlayer:
          begin
            Entities[I].Char := PLAYER_SHIP;
            Entities[I].Color := PLAYER_COLOR;
            Entities[I].Health := 3;
            PlayerIndex := I;
          end;
          
          etEnemy:
          begin
            // Random enemy type
            case TConsole.RandomRange(0, 3) of
              0:
              begin
                Entities[I].Char := ENEMY_SHIP_A;
                Entities[I].Color := ENEMY_COLOR_A;
                Entities[I].Pattern := ENEMY_PATTERN_STRAIGHT;
                Entities[I].VelY := 0.1 + 0.05 * Level;
                Entities[I].Value := 10;
              end;
              1:
              begin
                Entities[I].Char := ENEMY_SHIP_B;
                Entities[I].Color := ENEMY_COLOR_B;
                Entities[I].Pattern := ENEMY_PATTERN_SINE;
                Entities[I].VelY := 0.08 + 0.03 * Level;
                Entities[I].PatternParam := TConsole.RandomRange(0, 628) / 100; // Random phase
                Entities[I].Value := 20;
              end;
              2:
              begin
                Entities[I].Char := ENEMY_SHIP_C;
                Entities[I].Color := ENEMY_COLOR_C;
                Entities[I].Pattern := ENEMY_PATTERN_DIVE;
                Entities[I].VelY := 0.05 + 0.03 * Level;
                Entities[I].PatternParam := 0; // Dive timer
                Entities[I].Value := 30;
              end;
            end;
          end;
          
          etAsteroid:
          begin
            Entities[I].Char := ASTEROID_CHARS[TConsole.RandomRange(0, Length(ASTEROID_CHARS))];
            Entities[I].Color := ASTEROID_COLOR;
            Entities[I].VelX := (TConsole.RandomRange(-20, 20) / 100);
            Entities[I].VelY := 0.1 + (TConsole.RandomRange(0, 10) / 100);
            Entities[I].Value := 5;
          end;
          
          etPlayerBullet:
          begin
            Entities[I].Char := PLAYER_BULLET;
            Entities[I].Color := PLAYER_BULLET_COLOR;
            Entities[I].VelY := -0.8; // Fast upward movement
          end;
          
          etEnemyBullet:
          begin
            Entities[I].Char := ENEMY_BULLET;
            Entities[I].Color := ENEMY_BULLET_COLOR;
            Entities[I].VelY := 0.3 + 0.05 * Level; // Downward movement
          end;
          
          etExplosion:
          begin
            Entities[I].Char := EXPLOSION_CHARS[0];
            Entities[I].Color := EXPLOSION_COLOR;
            Entities[I].AnimTimer := 3; // Frames between animation changes
            Entities[I].AnimFrame := 0;
            Entities[I].Health := 15; // Life of explosion
          end;
          
          etPowerup:
          begin
            Entities[I].Char := 'P';
            Entities[I].Color := CSIFGGreen;
            Entities[I].VelY := 0.1;
            Entities[I].Value := TConsole.RandomRange(0, 3); // Powerup type
          end;
          
          etStar:
          begin
            Entities[I].Char := STAR_CHARS[TConsole.RandomRange(0, Length(STAR_CHARS))];
            Entities[I].Color := STAR_COLORS[TConsole.RandomRange(0, Length(STAR_COLORS))];
            Entities[I].VelY := 0.05 + (TConsole.RandomRange(0, 10) / 100);
          end;
        end;
        
        Break;
      end;
    end;
  end;
  
  // Create a particle effect
  procedure CreateParticle(X, Y: Double; Color: string; VelX, VelY: Double; Life: Integer);
  var
    I: Integer;
  begin
    for I := 0 to MAX_PARTICLES-1 do
    begin
      if not Particles[I].Active then
      begin
        Particles[I].X := X;
        Particles[I].Y := Y;
        Particles[I].VelX := VelX + (TConsole.RandomRange(-20, 20) / 100);
        Particles[I].VelY := VelY + (TConsole.RandomRange(-20, 20) / 100);
        Particles[I].Color := Color;
        Particles[I].Char := EXPLOSION_CHARS[TConsole.RandomRange(0, Length(EXPLOSION_CHARS))];
        Particles[I].Life := Life;
        Particles[I].Active := True;
        Break;
      end;
    end;
  end;
  
  // Create an explosion effect
  procedure CreateExplosion(X, Y: Double; Size: Integer);
  var
    I, ExplosionIndex: Integer;
  begin
    // Create main explosion entity
    ExplosionIndex := CreateEntity(etExplosion, X, Y);
    
    // Create particle effects
    if ExplosionIndex >= 0 then
    begin
      for I := 0 to 5 + Size * 3 do
      begin
        CreateParticle(X, Y, EXPLOSION_COLOR, 0, 0, 10 + TConsole.RandomRange(0, 10));
      end;
    end;
  end;
  
  // Initialize the game
  procedure InitGame;
  var
    I{, J}: Integer;
    ConsoleWidth, ConsoleHeight: Integer;
  begin
    // Reset game state
    Score := 0;
    Level := 1;
    Lives := 3;
    GameState := GAME_STATE_TITLE;
    SpawnTimer := 0;
    PowerupTimer := 0;
    GameTime := 0;
    PlayerInvulnerable := False;
    PlayerInvulnerableTimer := 0;
    
    // Clear all entities
    for I := 0 to MAX_ENTITIES-1 do
      Entities[I].Active := False;
      
    // Clear all particles
    for I := 0 to MAX_PARTICLES-1 do
      Particles[I].Active := False;
      
    // Get console dimensions
    TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);
    
    // Create player ship
    PlayerIndex := CreateEntity(etPlayer, ConsoleWidth / 2, ConsoleHeight - 5);
    
    // Create initial star field
    for I := 0 to 50 do
    begin
      CreateEntity(etStar, TConsole.RandomRange(0, ConsoleWidth), TConsole.RandomRange(0, ConsoleHeight));
    end;
  end;
  
  // Start a new game level
  procedure StartLevel;
  var
    I, ConsoleWidth: Integer;
  begin
    TConsole.GetSize(@ConsoleWidth, nil);
    
    // Clear enemies and bullets
    for I := 0 to MAX_ENTITIES-1 do
    begin
      if Entities[I].Active and
         ((Entities[I].EntityType = etEnemy) or
          (Entities[I].EntityType = etEnemyBullet) or
          (Entities[I].EntityType = etAsteroid) or
          (Entities[I].EntityType = etPowerup)) then
      begin
        Entities[I].Active := False;
      end;
    end;
    
    // Create initial asteroids
    for I := 0 to 4 + Level do
    begin
      CreateEntity(etAsteroid, TConsole.RandomRange(0, ConsoleWidth), TConsole.RandomRange(2, 10));
    end;
    
    // Reset timers
    SpawnTimer := 0;
    PowerupTimer := 0;
    
    // Make player temporarily invulnerable
    PlayerInvulnerable := True;
    PlayerInvulnerableTimer := 60;
  end;
  
  // Update player movement and actions
  procedure UpdatePlayer(var Buffer: TAsciiBuffer);
  var
    ConsoleWidth, ConsoleHeight: Integer;
    ThrusterX, ThrusterY: Integer;
  begin
    if (PlayerIndex >= 0) and Entities[PlayerIndex].Active then
    begin
      TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);
      
      // Handle player input
      if TConsole.IsKeyPressed(VK_LEFT) then
      begin
        Entities[PlayerIndex].VelX := Max(Entities[PlayerIndex].VelX - 0.04, -0.5);
        Entities[PlayerIndex].Char := PLAYER_SHIP_LEFT;
      end
      else if TConsole.IsKeyPressed(VK_RIGHT) then
      begin
        Entities[PlayerIndex].VelX := Min(Entities[PlayerIndex].VelX + 0.04, 0.5);
        Entities[PlayerIndex].Char := PLAYER_SHIP_RIGHT;
      end
      else
      begin
        // Gradual slow down if no keys pressed
        Entities[PlayerIndex].VelX := Entities[PlayerIndex].VelX * 0.9;
        Entities[PlayerIndex].Char := PLAYER_SHIP;
      end;
      
      // Apply velocity
      Entities[PlayerIndex].X := Entities[PlayerIndex].X + Entities[PlayerIndex].VelX;
      
      // Boundary checking
      if Entities[PlayerIndex].X < 1 then
      begin
        Entities[PlayerIndex].X := 1;
        Entities[PlayerIndex].VelX := 0;
      end
      else if Entities[PlayerIndex].X > ConsoleWidth - 2 then
      begin
        Entities[PlayerIndex].X := ConsoleWidth - 2;
        Entities[PlayerIndex].VelX := 0;
      end;
      
      // Fire bullet with space
      if TConsole.WasKeyPressed(VK_SPACE) then
      begin
        CreateEntity(etPlayerBullet, Entities[PlayerIndex].X, Entities[PlayerIndex].Y - 1);
        
        // Add thruster particles
        for var K := 0 to 2 do
        begin
          CreateParticle(Entities[PlayerIndex].X, Entities[PlayerIndex].Y + 1, 
                         PLAYER_THRUSTER_COLOR, 0, 0.1, 5);
        end;
      end;
      
      // Draw thruster
      if GameTime mod 4 < 2 then
      begin
        ThrusterX := Round(Entities[PlayerIndex].X);
        ThrusterY := Round(Entities[PlayerIndex].Y) + 1;
        
        if (ThrusterX >= 0) and (ThrusterX < ConsoleWidth) and 
           (ThrusterY >= 0) and (ThrusterY < ConsoleHeight) then
        begin
          Buffer.PutChar(ThrusterX, ThrusterY, PLAYER_THRUSTER, PLAYER_THRUSTER_COLOR, CSIBGBlack);
        end;
      end;
      
      // Handle invulnerability timer
      if PlayerInvulnerable then
      begin
        Dec(PlayerInvulnerableTimer);
        if PlayerInvulnerableTimer <= 0 then
          PlayerInvulnerable := False;
      end;
    end;
  end;
  
  // Update all entities
  procedure UpdateEntities;
  var
    I, J: Integer;
    ConsoleWidth, ConsoleHeight: Integer;
    DX, DY, Distance: Double;
  begin
    TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);
    
    // Update all active entities
    for I := 0 to MAX_ENTITIES-1 do
    begin
      if Entities[I].Active then
      begin
        case Entities[I].EntityType of
          etPlayer:
            ; // Player is updated separately
            
          etEnemy:
          begin
            // Apply movement pattern
            case Entities[I].Pattern of
              ENEMY_PATTERN_STRAIGHT:
              begin
                Entities[I].Y := Entities[I].Y + Entities[I].VelY;
              end;
              
              ENEMY_PATTERN_SINE:
              begin
                Entities[I].PatternParam := Entities[I].PatternParam + 0.1;
                Entities[I].X := Entities[I].X + Sin(Entities[I].PatternParam) * 0.2;
                Entities[I].Y := Entities[I].Y + Entities[I].VelY;
              end;
              
              ENEMY_PATTERN_CIRCLE:
              begin
                Entities[I].PatternParam := Entities[I].PatternParam + 0.05;
                Entities[I].X := Entities[I].X + Cos(Entities[I].PatternParam) * 0.3;
                Entities[I].Y := Entities[I].Y + Sin(Entities[I].PatternParam) * 0.3 + 0.05;
              end;
              
              ENEMY_PATTERN_DIVE:
              begin
                //Inc(Entities[I].PatternParam);
                Entities[I].PatternParam := Entities[I].PatternParam + 1;
                if (Entities[I].PatternParam > 30) and (PlayerIndex >= 0) and Entities[PlayerIndex].Active then
                begin
                  // Calculate direction to player
                  DX := Entities[PlayerIndex].X - Entities[I].X;
                  DY := Entities[PlayerIndex].Y - Entities[I].Y;
                  Distance := Sqrt(DX * DX + DY * DY);
                  
                  if Distance > 0 then
                  begin
                    Entities[I].VelX := DX / Distance * 0.3;
                    Entities[I].VelY := DY / Distance * 0.3;
                  end;
                  
                  Entities[I].Pattern := ENEMY_PATTERN_STRAIGHT;
                end
                else
                begin
                  Entities[I].Y := Entities[I].Y + Entities[I].VelY;
                end;
              end;
            end;
            
            // Fire bullets randomly
            if (TConsole.RandomRange(0, 100) < 1 + Level) and 
               (Entities[I].Y < ConsoleHeight - 10) then
            begin
              CreateEntity(etEnemyBullet, Entities[I].X, Entities[I].Y + 1);
            end;
            
            // Apply velocity for enemies with explicit velocity
            Entities[I].X := Entities[I].X + Entities[I].VelX;
            Entities[I].Y := Entities[I].Y + Entities[I].VelY;
            
            // Remove if out of bounds
            if (Entities[I].Y > ConsoleHeight + 1) or
               (Entities[I].X < -2) or (Entities[I].X > ConsoleWidth + 1) then
            begin
              Entities[I].Active := False;
            end;
          end;
          
          etAsteroid:
          begin
            // Rotate asteroid character for visual effect
            if GameTime mod 10 = 0 then
            begin
              Entities[I].Char := ASTEROID_CHARS[TConsole.RandomRange(0, Length(ASTEROID_CHARS))];
            end;
            
            // Apply velocity
            Entities[I].X := Entities[I].X + Entities[I].VelX;
            Entities[I].Y := Entities[I].Y + Entities[I].VelY;
            
            // Wrap around screen horizontally
            if Entities[I].X < -1 then
              Entities[I].X := ConsoleWidth
            else if Entities[I].X > ConsoleWidth then
              Entities[I].X := 0;
              
            // Remove if out of bounds vertically
            if Entities[I].Y > ConsoleHeight + 1 then
              Entities[I].Active := False;
          end;
          
          etPlayerBullet:
          begin
            // Move upward
            Entities[I].Y := Entities[I].Y + Entities[I].VelY;
            
            // Remove if out of bounds
            if Entities[I].Y < 0 then
              Entities[I].Active := False;
              
            // Check collisions with enemies and asteroids
            for J := 0 to MAX_ENTITIES-1 do
            begin
              if Entities[J].Active and
                 ((Entities[J].EntityType = etEnemy) or
                  (Entities[J].EntityType = etAsteroid)) then
              begin
                // Simple collision detection
                if (Round(Entities[I].X) = Round(Entities[J].X)) and
                   (Round(Entities[I].Y) = Round(Entities[J].Y)) then
                begin
                  // Hit!
                  Dec(Entities[J].Health);
                  
                  if Entities[J].Health <= 0 then
                  begin
                    // Entity destroyed
                    Inc(Score, Entities[J].Value);
                    CreateExplosion(Entities[J].X, Entities[J].Y, 1);
                    Entities[J].Active := False;
                    
                    // Small chance of powerup when enemy destroyed
                    if (Entities[J].EntityType = etEnemy) and 
                       (TConsole.RandomRange(0, 10) < 2) then
                    begin
                      CreateEntity(etPowerup, Entities[J].X, Entities[J].Y);
                    end;
                  end;
                  
                  // Remove bullet
                  Entities[I].Active := False;
                  Break;
                end;
              end;
            end;
          end;
          
          etEnemyBullet:
          begin
            // Move downward
            Entities[I].Y := Entities[I].Y + Entities[I].VelY;
            
            // Remove if out of bounds
            if Entities[I].Y > ConsoleHeight then
              Entities[I].Active := False;
              
            // Check collision with player
            if (PlayerIndex >= 0) and Entities[PlayerIndex].Active and 
               (not PlayerInvulnerable) and
               (Round(Entities[I].X) = Round(Entities[PlayerIndex].X)) and
               (Round(Entities[I].Y) = Round(Entities[PlayerIndex].Y)) then
            begin
              // Hit player!
              Entities[I].Active := False;
              Dec(Entities[PlayerIndex].Health);
              
              // Create small explosion
              CreateExplosion(Entities[PlayerIndex].X, Entities[PlayerIndex].Y, 1);
              
              if Entities[PlayerIndex].Health <= 0 then
              begin
                // Player destroyed!
                CreateExplosion(Entities[PlayerIndex].X, Entities[PlayerIndex].Y, 2);
                Entities[PlayerIndex].Active := False;
                
                Dec(Lives);
                if Lives <= 0 then
                begin
                  GameState := GAME_STATE_GAME_OVER;
                end
                else
                begin
                  // Respawn player
                  PlayerIndex := CreateEntity(etPlayer, ConsoleWidth / 2, ConsoleHeight - 5);
                  PlayerInvulnerable := True;
                  PlayerInvulnerableTimer := 60;
                end;
              end
              else
              begin
                // Make player temporarily invulnerable
                PlayerInvulnerable := True;
                PlayerInvulnerableTimer := 60;
              end;
            end;
          end;
          
          etExplosion:
          begin
            // Animate explosion
            Dec(Entities[I].AnimTimer);
            if Entities[I].AnimTimer <= 0 then
            begin
              Entities[I].AnimTimer := 2;
              Inc(Entities[I].AnimFrame);
              
              if Entities[I].AnimFrame < Length(EXPLOSION_CHARS) then
                Entities[I].Char := EXPLOSION_CHARS[Entities[I].AnimFrame]
              else
                Entities[I].AnimFrame := 0;
            end;
            
            // Reduce health (lifetime)
            Dec(Entities[I].Health);
            if Entities[I].Health <= 0 then
            begin
              Entities[I].Active := False;
            end;
          end;
          
          etPowerup:
          begin
            // Move downward
            Entities[I].Y := Entities[I].Y + Entities[I].VelY;
            
            // Remove if out of bounds
            if Entities[I].Y > ConsoleHeight then
              Entities[I].Active := False;
              
            // Check collision with player
            if (PlayerIndex >= 0) and Entities[PlayerIndex].Active and
               (Round(Entities[I].X) = Round(Entities[PlayerIndex].X)) and
               (Round(Entities[I].Y) = Round(Entities[PlayerIndex].Y)) then
            begin
              // Power up!
              case Entities[I].Value of
                0: Inc(Score, 50); // Extra points
                1: Inc(Entities[PlayerIndex].Health); // Extra health
                2: Inc(Lives); // Extra life
              end;
              
              // Create particles
              for J := 0 to 10 do
              begin
                CreateParticle(Entities[I].X, Entities[I].Y, 
                             CSIFGGreen, 0, 0, 10);
              end;
              
              Entities[I].Active := False;
            end;
          end;
          
          etStar:
          begin
            // Move stars downward for parallax effect
            Entities[I].Y := Entities[I].Y + Entities[I].VelY;
            
            // Wrap around screen
            if Entities[I].Y > ConsoleHeight then
            begin
              Entities[I].Y := 0;
              Entities[I].X := TConsole.RandomRange(0, ConsoleWidth);
            end;
          end;
        end;
      end;
    end;
  end;
  
  // Update all particles
  procedure UpdateParticles;
  var
    I: Integer;
  begin
    for I := 0 to MAX_PARTICLES-1 do
    begin
      if Particles[I].Active then
      begin
        // Apply velocity
        Particles[I].X := Particles[I].X + Particles[I].VelX;
        Particles[I].Y := Particles[I].Y + Particles[I].VelY;
        
        // Reduce life
        Dec(Particles[I].Life);
        if Particles[I].Life <= 0 then
          Particles[I].Active := False;
      end;
    end;
  end;
  
  // Spawn new enemies and asteroids
  procedure SpawnEnemies;
  var
    ConsoleWidth: Integer;
    //EnemyType: Integer;
  begin
    Inc(SpawnTimer);
    
    // Spawn rate decreases as level increases
    if SpawnTimer >= Max(30 - Level * 2, 10) then
    begin
      SpawnTimer := 0;
      
      TConsole.GetSize(@ConsoleWidth, nil);
      
      // Random enemy or asteroid
      if TConsole.RandomRange(0, 10) < 7 then
      begin
        // Spawn enemy
        CreateEntity(etEnemy, TConsole.RandomRange(5, ConsoleWidth - 5), 0);
      end
      else
      begin
        // Spawn asteroid
        CreateEntity(etAsteroid, TConsole.RandomRange(0, ConsoleWidth), 0);
      end;
    end;
    
    // Spawn powerups occasionally
    Inc(PowerupTimer);
    if PowerupTimer >= 500 then
    begin
      PowerupTimer := 0;
      
      TConsole.GetSize(@ConsoleWidth, nil);
      CreateEntity(etPowerup, TConsole.RandomRange(5, ConsoleWidth - 5), 0);
    end;
  end;
  
  // Render all entities to buffer
  procedure RenderEntities(var Buffer: TAsciiBuffer);
  var
    I: Integer;
    X, Y: Integer;
    ConsoleWidth, ConsoleHeight: Integer;
    Title: string;
    StatusLine: string;
  begin
    TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);
    
    // Clear buffer
    Buffer.Clear(' ', CSIDim + CSIFGWhite, CSIBGBlack);
    
    // Handle different game states
    case GameState of
      GAME_STATE_TITLE:
      begin
        // Draw title screen
        Title := '* STELLAR ASSAULT *';
        for I := 0 to Length(Title) - 1 do
          Buffer.PutChar((ConsoleWidth div 2) - (Length(Title) div 2) + I, ConsoleHeight div 2 - 8, 
                       Title[I+1], CSIFGCyan, CSIBGBlack);
          
        Title := 'A Space Shooter Adventure';
        for I := 0 to Length(Title) - 1 do
          Buffer.PutChar((ConsoleWidth div 2) - (Length(Title) div 2) + I, ConsoleHeight div 2 - 6, 
                       Title[I+1], CSIFGWhite, CSIBGBlack);
          
        Title := 'Controls:';
        for I := 0 to Length(Title) - 1 do
          Buffer.PutChar((ConsoleWidth div 2) - (Length(Title) div 2) + I, ConsoleHeight div 2 - 3, 
                       Title[I+1], CSIFGYellow, CSIBGBlack);
                       
        Title := 'LEFT/RIGHT - Move Ship';
        for I := 0 to Length(Title) - 1 do
          Buffer.PutChar((ConsoleWidth div 2) - (Length(Title) div 2) + I, ConsoleHeight div 2 - 1, 
                       Title[I+1], CSIFGWhite, CSIBGBlack);
                       
        Title := 'SPACE - Fire Weapon';
        for I := 0 to Length(Title) - 1 do
          Buffer.PutChar((ConsoleWidth div 2) - (Length(Title) div 2) + I, ConsoleHeight div 2, 
                       Title[I+1], CSIFGWhite, CSIBGBlack);
                       
Title := 'ESC - Quit Game';
        for I := 0 to Length(Title) - 1 do
          Buffer.PutChar((ConsoleWidth div 2) - (Length(Title) div 2) + I, ConsoleHeight div 2 + 1, 
                       Title[I+1], CSIFGWhite, CSIBGBlack);
                       
        Title := 'Press [S] to Start!';
        for I := 0 to Length(Title) - 1 do
          Buffer.PutChar((ConsoleWidth div 2) - (Length(Title) div 2) + I, ConsoleHeight div 2 + 4, 
                       Title[I+1], CSIFGMagenta, CSIBGBlack);
                       
        // Draw stars for background
        for I := 0 to MAX_ENTITIES-1 do
        begin
          if Entities[I].Active and (Entities[I].EntityType = etStar) then
          begin
            X := Round(Entities[I].X);
            Y := Round(Entities[I].Y);
            
            if (X >= 0) and (X < ConsoleWidth) and 
               (Y >= 0) and (Y < ConsoleHeight) then
            begin
              Buffer.PutChar(X, Y, Entities[I].Char, Entities[I].Color, CSIBGBlack);
            end;
          end;
        end;
      end;
      
      GAME_STATE_PLAYING:
      begin
        // Render stars first (background)
        for I := 0 to MAX_ENTITIES-1 do
        begin
          if Entities[I].Active and (Entities[I].EntityType = etStar) then
          begin
            X := Round(Entities[I].X);
            Y := Round(Entities[I].Y);
            
            if (X >= 0) and (X < ConsoleWidth) and 
               (Y >= 0) and (Y < ConsoleHeight) then
            begin
              Buffer.PutChar(X, Y, Entities[I].Char, Entities[I].Color, CSIBGBlack);
            end;
          end;
        end;
        
        // Render particles
        for I := 0 to MAX_PARTICLES-1 do
        begin
          if Particles[I].Active then
          begin
            X := Round(Particles[I].X);
            Y := Round(Particles[I].Y);
            
            if (X >= 0) and (X < ConsoleWidth) and 
               (Y >= 0) and (Y < ConsoleHeight) then
            begin
              Buffer.PutChar(X, Y, Particles[I].Char, Particles[I].Color, CSIBGBlack);
            end;
          end;
        end;
        
        // Render other entities
        for I := 0 to MAX_ENTITIES-1 do
        begin
          if Entities[I].Active and (Entities[I].EntityType <> etStar) then
          begin
            // Skip rendering player if flashing during invulnerability
            if (Entities[I].EntityType = etPlayer) and 
               PlayerInvulnerable and (GameTime mod 6 < 3) then
              Continue;
              
            X := Round(Entities[I].X);
            Y := Round(Entities[I].Y);
            
            if (X >= 0) and (X < ConsoleWidth) and 
               (Y >= 0) and (Y < ConsoleHeight) then
            begin
              Buffer.PutChar(X, Y, Entities[I].Char, Entities[I].Color, Entities[I].BgColor);
            end;
          end;
        end;
        
        // Render UI
        // Status line at top
        StatusLine := Format('LEVEL: %d  SCORE: %d  LIVES: %d  HEALTH: %d', 
                            [Level, Score, Lives, Entities[PlayerIndex].Health]);
        
        for I := 0 to Length(StatusLine) - 1 do
          Buffer.PutChar(2 + I, 1, StatusLine[I+1], CSIFGWhite, CSIBGBlack);
        
        // Health bar
        if PlayerIndex >= 0 then
        begin
          Buffer.PutChar(ConsoleWidth - 12, 1, '[', CSIFGWhite, CSIBGBlack);
          
          for I := 0 to 9 do
          begin
            if I < Entities[PlayerIndex].Health then
              Buffer.PutChar(ConsoleWidth - 11 + I, 1, '=', CSIFGGreen, CSIBGBlack)
            else
              Buffer.PutChar(ConsoleWidth - 11 + I, 1, '-', CSIFGRed, CSIBGBlack);
          end;
          
          Buffer.PutChar(ConsoleWidth - 1, 1, ']', CSIFGWhite, CSIBGBlack);
        end;
        
        // Level indicator
        for I := 0 to Min(Level, 10) - 1 do
          Buffer.PutChar(ConsoleWidth - 2 - I, ConsoleHeight - 2, '*', CSIFGYellow, CSIBGBlack);
      end;
      
      GAME_STATE_GAME_OVER:
      begin
        // Draw stars for background
        for I := 0 to MAX_ENTITIES-1 do
        begin
          if Entities[I].Active and (Entities[I].EntityType = etStar) then
          begin
            X := Round(Entities[I].X);
            Y := Round(Entities[I].Y);
            
            if (X >= 0) and (X < ConsoleWidth) and 
               (Y >= 0) and (Y < ConsoleHeight) then
            begin
              Buffer.PutChar(X, Y, Entities[I].Char, Entities[I].Color, CSIBGBlack);
            end;
          end;
        end;
        
        // Draw game over screen
        Title := 'GAME OVER';
        for I := 0 to Length(Title) - 1 do
          Buffer.PutChar((ConsoleWidth div 2) - (Length(Title) div 2) + I, ConsoleHeight div 2 - 5, 
                       Title[I+1], CSIFGRed, CSIBGBlack);
                       
        Title := Format('Final Score: %d', [Score]);
        for I := 0 to Length(Title) - 1 do
          Buffer.PutChar((ConsoleWidth div 2) - (Length(Title) div 2) + I, ConsoleHeight div 2 - 3, 
                       Title[I+1], CSIFGWhite, CSIBGBlack);
                       
        Title := Format('Levels Completed: %d', [Level - 1]);
        for I := 0 to Length(Title) - 1 do
          Buffer.PutChar((ConsoleWidth div 2) - (Length(Title) div 2) + I, ConsoleHeight div 2 - 2, 
                       Title[I+1], CSIFGWhite, CSIBGBlack);
                       
        Title := 'Press [S] to Play Again';
        for I := 0 to Length(Title) - 1 do
          Buffer.PutChar((ConsoleWidth div 2) - (Length(Title) div 2) + I, ConsoleHeight div 2 + 1, 
                       Title[I+1], CSIFGYellow, CSIBGBlack);
                       
        Title := 'Press ESC to Quit';
        for I := 0 to Length(Title) - 1 do
          Buffer.PutChar((ConsoleWidth div 2) - (Length(Title) div 2) + I, ConsoleHeight div 2 + 3, 
                       Title[I+1], CSIFGWhite, CSIBGBlack);
      end;
    end;
  end;

// Main game procedure
procedure Demo_StellarAssault;
var
  Buffer: TAsciiBuffer;
  MaxW, MaxH: Integer;
  GameRunning: Boolean;
begin
  TConsole.SetTitle('TConsole: Stellar Assault Demo');

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
      if TConsole.IsKeyPressed(VK_ESCAPE) then
        GameRunning := False;
      
      // Wait for next frame
      if Buffer.BeginFrame then
      begin
        // Increment game time
        Inc(GameTime);
        
        // Handle game state
        case GameState of
          GAME_STATE_TITLE:
          begin
            // Update stars for background effect
            UpdateEntities;

            if TConsole.WasKeyPressed(Ord('S')) then
            begin
              GameState := GAME_STATE_PLAYING;
              StartLevel;
            end;
          end;
          
          GAME_STATE_PLAYING:
          begin
            // Update player
            UpdatePlayer(Buffer);
            
            // Update game entities
            UpdateEntities;
            
            // Update particles
            UpdateParticles;
            
            // Spawn new enemies
            SpawnEnemies;
            
            // Check if level complete
            if (GameTime mod 1000 = 0) and (GameTime > 0) then
            begin
              Inc(Level);
              StartLevel;
            end;
          end;
          
          GAME_STATE_GAME_OVER:
          begin
            // Update stars for background effect
            UpdateEntities;

            if TConsole.WasKeyPressed(Ord('S')) then
            begin
              // Reset game
              InitGame;
              GameState := GAME_STATE_PLAYING;
              StartLevel;
            end;
          end;
        end;
        
        // Render game
        RenderEntities(Buffer);
        
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