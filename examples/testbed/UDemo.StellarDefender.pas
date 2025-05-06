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

unit UDemo.StellarDefender;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Math,
  Winapi.Windows,
  Console,
  Console.Buffer,
  Console.Sprite;

procedure Demo_StellarDefender;

implementation

type

  TEntityType = (etPlayer, etEnemy, etAsteroid, etBullet, etExplosion, etPowerup, etBackground);
  
  TCollisionShape = (csNone, csPoint, csRect, csCircle);

  TEntity = class
  private
    FType: TEntityType;
    FX, FY: Double;
    FVelX, FVelY: Double;
    FSprite: TAsciiSprite;
    FAnimation: TAsciiSpriteAnimation;
    FCollisionShape: TCollisionShape;
    FCollisionRadius: Double;
    FCollisionWidth, FCollisionHeight: Integer;
    FActive: Boolean;
    FHealth: Integer;
    FLifetime: Integer;
    FValue: Integer;
    FTag: Integer;
  public
    constructor Create(EntityType: TEntityType; X, Y: Double);
    destructor Destroy; override;
    procedure Update; virtual;
    function CheckCollision(Other: TEntity): Boolean;
    property EntityType: TEntityType read FType;
    property X: Double read FX write FX;
    property Y: Double read FY write FY;
    property VelX: Double read FVelX write FVelX;
    property VelY: Double read FVelY write FVelY;
    property Sprite: TAsciiSprite read FSprite write FSprite;
    property Animation: TAsciiSpriteAnimation read FAnimation write FAnimation;
    property Active: Boolean read FActive write FActive;
    property Health: Integer read FHealth write FHealth;
    property Lifetime: Integer read FLifetime write FLifetime;
    property Value: Integer read FValue write FValue;
    property Tag: Integer read FTag write FTag;
    property CollisionShape: TCollisionShape read FCollisionShape write FCollisionShape;
    procedure DecreaseHealth(Amount: Integer = 1);
    procedure IncreaseHealth(Amount: Integer = 1);
  end;

  TParticleSystem = class
  private
    FParticles: array of record
      X, Y: Double;
      VelX, VelY: Double;
      Char: WideChar;
      Color: string;
      Lifetime: Integer;
      Active: Boolean;
    end;
    FMaxParticles: Integer;
  public
    constructor Create(MaxParticles: Integer);
    procedure Emit(X, Y: Double; Count: Integer; Color: string; VelX, VelY, Spread: Double; Lifetime: Integer);
    procedure Update;
    procedure Render(Buffer: TAsciiBuffer);
  end;

  TGameManager = class
  private
    FBuffer: TAsciiBuffer;
    FEntities: TList;
    FParticleSystem: TParticleSystem;
    FPlayerIndex: Integer;
    FScore: Integer;
    FLevel: Integer;
    FLives: Integer;
    FGameState: Integer;
    FGameTime: Integer;
    FSpawnTimer: Integer;
    FPowerupTimer: Integer;
    
    // Sprites and animations
    FPlayerSprite: TAsciiSprite;
    FEnemySprites: array[0..2] of TAsciiSprite;
    FAsteroidSprites: array[0..2] of TAsciiSprite;
    FBulletSprite: TAsciiSprite;
    FExplosionAnimation: TAsciiSpriteAnimation;
    FPowerupSprite: TAsciiSprite;
    FBackgroundSprites: array[0..9] of TAsciiSprite;

    procedure LoadSprites;
    procedure InitGame;
    procedure UpdateEntities;
    procedure CheckCollisions;
    procedure UpdatePlayer;
    procedure SpawnEnemies;
    procedure RenderGame;
    procedure RenderUI;
    function FindPlayerEntity: TEntity;
    procedure CreateExplosion(X, Y: Double; Size: Integer);
    procedure CreatePlayerBullet(X, Y: Double);
    procedure CreateEnemyBullet(X, Y: Double);
    procedure CreateEnemy(X, Y: Double; EnemyType: Integer);
    procedure CreateAsteroid(X, Y: Double; Size: Integer);
    procedure CreatePowerup(X, Y: Double);
    procedure GameOver;
    procedure NextLevel;
  public
    constructor Create(ABuffer: TAsciiBuffer);
    destructor Destroy; override;
    procedure Run;
  end;

const
  // Game states
  GAME_STATE_TITLE = 0;
  GAME_STATE_PLAYING = 1;
  GAME_STATE_GAME_OVER = 2;
  
  // Colors
  PLAYER_COLOR = CSIFGCyan;
  ENEMY_COLOR_A = CSIFGRed;
  ENEMY_COLOR_B = CSIFGMagenta;
  ENEMY_COLOR_C = CSIFGYellow;
  BULLET_COLOR = CSIFGGreen;
  EXPLOSION_COLOR = CSIFGRed;
  POWERUP_COLOR = CSIFGGreen;
  
  // Sprite definitions
  PLAYER_SPRITE = 
    '  ^  ' + #13#10 +
    ' /|\\ ' + #13#10 +
    '/===\\';
    
  PLAYER_SPRITE_LEFT = 
    '  ^  ' + #13#10 +
    ' //\\ ' + #13#10 +
    '/===\\';
    
  PLAYER_SPRITE_RIGHT = 
    '  ^  ' + #13#10 +
    ' /\\\\ ' + #13#10 +
    '/===\\';
    
  ENEMY_SPRITE_A = 
    '\\===/' + #13#10 +
    ' \\|/ ' + #13#10 +
    '  v  ';
    
  ENEMY_SPRITE_B = 
    ' /-\\ ' + #13#10 +
    '|-O-|' + #13#10 +
    ' \\-/ ';
    
  ENEMY_SPRITE_C = 
    ' /^\\ ' + #13#10 +
    '/| |\\' + #13#10 +
    '\\___/';
    
  ASTEROID_SPRITE_LARGE = 
    '  __  ' + #13#10 +
    ' /  \\ ' + #13#10 +
    '|    |' + #13#10 +
    ' \\__/ ';
    
  ASTEROID_SPRITE_MEDIUM = 
    ' /\\ ' + #13#10 +
    '|  |' + #13#10 +
    ' \\/ ';
    
  ASTEROID_SPRITE_SMALL = 
    '/\\' + #13#10 +
    '\\/';
    
  BULLET_SPRITE = 
    '|' + #13#10 +
    '|';
    
  POWERUP_SPRITE = 
    '/P\\' + #13#10 +
    '\\-/';
    
  // Explosion animation frames
  EXPLOSION_FRAME_1 = 
    ' * ' + #13#10 +
    '* *' + #13#10 +
    ' * ';
    
  EXPLOSION_FRAME_2 = 
    '\\*/' + #13#10 +
    '-*-' + #13#10 +
    '/*\\';
    
  EXPLOSION_FRAME_3 = 
    '\\|/' + #13#10 +
    '-O-' + #13#10 +
    '/|\\';
    
  EXPLOSION_FRAME_4 = 
    ' . ' + #13#10 +
    '. .' + #13#10 +
    ' . ';

{ TEntity Implementation }

constructor TEntity.Create(EntityType: TEntityType; X, Y: Double);
begin
  inherited Create;
  FType := EntityType;
  FX := X;
  FY := Y;
  FVelX := 0;
  FVelY := 0;
  FSprite := nil;
  FAnimation := nil;
  FCollisionShape := csNone;
  FCollisionRadius := 0;
  FCollisionWidth := 0;
  FCollisionHeight := 0;
  FActive := True;
  FHealth := 1;
  FLifetime := -1; // -1 means infinite lifetime
  FValue := 0;
  FTag := 0;
end;

destructor TEntity.Destroy;
begin
  // Note: We don't free FSprite or FAnimation here as they're shared resources
  inherited;
end;

procedure TEntity.Update;
begin
  // Update position based on velocity
  FX := FX + FVelX;
  FY := FY + FVelY;
  
  // Update animation if present
  if Assigned(FAnimation) then
    FAnimation.Update;
    
  // Update lifetime if set
  if FLifetime > 0 then
  begin
    Dec(FLifetime);
    if FLifetime <= 0 then
      FActive := False;
  end;
end;

procedure TEntity.DecreaseHealth(Amount: Integer = 1);
begin
  FHealth := FHealth - Amount;
end;

procedure TEntity.IncreaseHealth(Amount: Integer = 1);
begin
  FHealth := FHealth + Amount;
end;

function TEntity.CheckCollision(Other: TEntity): Boolean;
var
  Distance, RadiusSum: Double;
  Dx, Dy: Double;
begin
  Result := False;

  // Skip if either entity has no collision shape
  if (FCollisionShape = csNone) or (Other.FCollisionShape = csNone) then
    Exit;

  // Get distance between entities - used by many collision checks
  Dx := FX - Other.FX;
  Dy := FY - Other.FY;
  Distance := Sqrt(Dx * Dx + Dy * Dy);

  // Special case for bullets - be more lenient
  if (EntityType = etBullet) or (Other.EntityType = etBullet) then
  begin
    // More forgiving bullet collision - if close enough, count as hit
    Result := Distance < 2.5; // Increased from 2.0 for better hit detection
    Exit;
  end;

  case FCollisionShape of
    csPoint:
      begin
        case Other.FCollisionShape of
          csPoint:
            Result := (Round(FX) = Round(Other.FX)) and (Round(FY) = Round(Other.FY));

          csRect:
            Result := (FX >= Other.FX - Other.FCollisionWidth / 2) and
                     (FX <= Other.FX + Other.FCollisionWidth / 2) and
                     (FY >= Other.FY - Other.FCollisionHeight / 2) and
                     (FY <= Other.FY + Other.FCollisionHeight / 2);

          csCircle:
            Result := Distance <= Other.FCollisionRadius + 0.5; // Add small buffer
        end;
      end;

    csRect:
      begin
        case Other.FCollisionShape of
          csPoint:
            Result := (Other.FX >= FX - FCollisionWidth / 2) and
                     (Other.FX <= FX + FCollisionWidth / 2) and
                     (Other.FY >= FY - FCollisionHeight / 2) and
                     (Other.FY <= FY + FCollisionHeight / 2);

          csRect:
            Result := not ((FX + FCollisionWidth / 2 < Other.FX - Other.FCollisionWidth / 2) or
                          (FX - FCollisionWidth / 2 > Other.FX + Other.FCollisionWidth / 2) or
                          (FY + FCollisionHeight / 2 < Other.FY - Other.FCollisionHeight / 2) or
                          (FY - FCollisionHeight / 2 > Other.FY + Other.FCollisionHeight / 2));

          csCircle:
            begin
              // Simplified rect vs circle collision
              Result := Distance <= Other.FCollisionRadius +
                        (FCollisionWidth + FCollisionHeight) / 4 + 0.5; // Add buffer
            end;
        end;
      end;

    csCircle:
      begin
        case Other.FCollisionShape of
          csPoint:
            Result := Distance <= FCollisionRadius + 0.5; // Add small buffer

          csRect:
            begin
              // Simplified circle vs rect collision
              Result := Distance <= FCollisionRadius +
                        (Other.FCollisionWidth + Other.FCollisionHeight) / 4 + 0.5; // Add buffer
            end;

          csCircle:
            begin
              RadiusSum := FCollisionRadius + Other.FCollisionRadius + 0.5; // Add buffer
              Result := Distance <= RadiusSum;
            end;
        end;
      end;
  end;
end;

{ TParticleSystem Implementation }

constructor TParticleSystem.Create(MaxParticles: Integer);
var
  I: Integer;
begin
  inherited Create;
  FMaxParticles := MaxParticles;
  SetLength(FParticles, FMaxParticles);

  for I := 0 to FMaxParticles - 1 do
    FParticles[I].Active := False;
end;

procedure TParticleSystem.Emit(X, Y: Double; Count: Integer; Color: string; VelX, VelY, Spread: Double; Lifetime: Integer);
var
  I, J: Integer;
  Angle: Double;
  Speed: Double;
  ParticleChars: array[0..5] of WideChar;
begin
  // Define possible particle characters
  ParticleChars[0] := '.';
  ParticleChars[1] := '*';
  ParticleChars[2] := '+';
  ParticleChars[3] := 'o';
  ParticleChars[4] := 'x';
  ParticleChars[5] := '#';
  
  // Find inactive particles and activate them
  J := 0;
  for I := 0 to FMaxParticles - 1 do
  begin
    if not FParticles[I].Active then
    begin
      // Set particle properties
      FParticles[I].X := X;
      FParticles[I].Y := Y;
      
      // Calculate random velocity direction within spread
      Angle := TConsole.RandomRange(0, 628) / 100;
      Speed := 0.5 + TConsole.RandomRange(0, 50) / 100;
      
      FParticles[I].VelX := VelX + Cos(Angle) * Speed * Spread;
      FParticles[I].VelY := VelY + Sin(Angle) * Speed * Spread;
      
      // Set random character and color
      FParticles[I].Char := ParticleChars[TConsole.RandomRange(0, Length(ParticleChars))];
      FParticles[I].Color := Color;
      
      // Set lifetime with some randomness
      FParticles[I].Lifetime := Lifetime + TConsole.RandomRange(-3, 4);
      FParticles[I].Active := True;
      
      // Count particles created
      Inc(J);
      if J >= Count then
        Break;
    end;
  end;
end;

procedure TParticleSystem.Update;
var
  I: Integer;
begin
  for I := 0 to FMaxParticles - 1 do
  begin
    if FParticles[I].Active then
    begin
      // Update position
      FParticles[I].X := FParticles[I].X + FParticles[I].VelX;
      FParticles[I].Y := FParticles[I].Y + FParticles[I].VelY;
      
      // Apply gravity
      FParticles[I].VelY := FParticles[I].VelY + 0.01;
      
      // Reduce lifetime
      Dec(FParticles[I].Lifetime);
      if FParticles[I].Lifetime <= 0 then
        FParticles[I].Active := False;
    end;
  end;
end;

procedure TParticleSystem.Render(Buffer: TAsciiBuffer);
var
  I: Integer;
  X, Y: Integer;
begin
  for I := 0 to FMaxParticles - 1 do
  begin
    if FParticles[I].Active then
    begin
      X := Round(FParticles[I].X);
      Y := Round(FParticles[I].Y);
      
      Buffer.PutChar(X, Y, FParticles[I].Char, FParticles[I].Color, CSIBGBlack);
    end;
  end;
end;

{ TGameManager Implementation }

constructor TGameManager.Create(ABuffer: TAsciiBuffer);
begin
  inherited Create;
  FBuffer := ABuffer;
  FEntities := TList.Create;
  FParticleSystem := TParticleSystem.Create(300);
  
  LoadSprites;
  InitGame;
end;

destructor TGameManager.Destroy;
var
  I: Integer;
begin
  // Free all entities
  for I := 0 to FEntities.Count - 1 do
    TEntity(FEntities[I]).Free;
  FEntities.Free;
  
  // Free particle system
  FParticleSystem.Free;
  
  // Free sprites
  FPlayerSprite.Free;
  for I := 0 to Length(FEnemySprites) - 1 do
    FEnemySprites[I].Free;
  for I := 0 to Length(FAsteroidSprites) - 1 do
    FAsteroidSprites[I].Free;
  FBulletSprite.Free;
  FExplosionAnimation.Free;
  FPowerupSprite.Free;
  for I := 0 to Length(FBackgroundSprites) - 1 do
    if Assigned(FBackgroundSprites[I]) then
      FBackgroundSprites[I].Free;
      
  inherited;
end;

procedure TGameManager.LoadSprites;
var
  ExplosionFrame: TAsciiSprite;
  I: Integer;
begin
  // Player sprite
  FPlayerSprite := TAsciiSprite.Create(5, 3);
  FPlayerSprite.LoadFromString(PLAYER_SPRITE, PLAYER_COLOR, CSIBGBlack);
  
  // Enemy sprites
  FEnemySprites[0] := TAsciiSprite.Create(5, 3);
  FEnemySprites[0].LoadFromString(ENEMY_SPRITE_A, ENEMY_COLOR_A, CSIBGBlack);
  
  FEnemySprites[1] := TAsciiSprite.Create(5, 3);
  FEnemySprites[1].LoadFromString(ENEMY_SPRITE_B, ENEMY_COLOR_B, CSIBGBlack);
  
  FEnemySprites[2] := TAsciiSprite.Create(5, 3);
  FEnemySprites[2].LoadFromString(ENEMY_SPRITE_C, ENEMY_COLOR_C, CSIBGBlack);
  
  // Asteroid sprites
  FAsteroidSprites[0] := TAsciiSprite.Create(6, 4);
  FAsteroidSprites[0].LoadFromString(ASTEROID_SPRITE_LARGE, CSIFGWhite, CSIBGBlack);
  
  FAsteroidSprites[1] := TAsciiSprite.Create(4, 3);
  FAsteroidSprites[1].LoadFromString(ASTEROID_SPRITE_MEDIUM, CSIFGWhite, CSIBGBlack);
  
  FAsteroidSprites[2] := TAsciiSprite.Create(2, 2);
  FAsteroidSprites[2].LoadFromString(ASTEROID_SPRITE_SMALL, CSIFGWhite, CSIBGBlack);
  
  // Bullet sprite
  FBulletSprite := TAsciiSprite.Create(1, 2);
  FBulletSprite.LoadFromString(BULLET_SPRITE, BULLET_COLOR, CSIBGBlack);
  
  // Explosion animation
  FExplosionAnimation := TAsciiSpriteAnimation.Create(3, False);
  
  ExplosionFrame := TAsciiSprite.Create(3, 3);
  ExplosionFrame.LoadFromString(EXPLOSION_FRAME_1, EXPLOSION_COLOR, CSIBGBlack);
  FExplosionAnimation.AddFrame(ExplosionFrame);
  
  ExplosionFrame := TAsciiSprite.Create(3, 3);
  ExplosionFrame.LoadFromString(EXPLOSION_FRAME_2, EXPLOSION_COLOR, CSIBGBlack);
  FExplosionAnimation.AddFrame(ExplosionFrame);
  
  ExplosionFrame := TAsciiSprite.Create(3, 3);
  ExplosionFrame.LoadFromString(EXPLOSION_FRAME_3, EXPLOSION_COLOR, CSIBGBlack);
  FExplosionAnimation.AddFrame(ExplosionFrame);
  
  ExplosionFrame := TAsciiSprite.Create(3, 3);
  ExplosionFrame.LoadFromString(EXPLOSION_FRAME_4, EXPLOSION_COLOR, CSIBGBlack);
  FExplosionAnimation.AddFrame(ExplosionFrame);
  
  // Powerup sprite
  FPowerupSprite := TAsciiSprite.Create(3, 2);
  FPowerupSprite.LoadFromString(POWERUP_SPRITE, POWERUP_COLOR, CSIBGBlack);
  
  // Background sprites (stars)
  for I := 0 to Length(FBackgroundSprites) - 1 do
    FBackgroundSprites[I] := nil;
end;

procedure TGameManager.InitGame;
var
  I: Integer;
  ConsoleWidth, ConsoleHeight: Integer;
begin
  // Get console dimensions
  TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);
  
  // Clear all existing entities
  for I := 0 to FEntities.Count - 1 do
    TEntity(FEntities[I]).Free;
  FEntities.Clear;
  
  // Reset game state
  FScore := 0;
  FLevel := 1;
  FLives := 3;
  //FGameState := GAME_STATE_TITLE;
  FGameTime := 0;
  FSpawnTimer := 0;
  FPowerupTimer := 0;
  
  // Create player entity
  FPlayerIndex := FEntities.Add(TEntity.Create(etPlayer, ConsoleWidth / 2, ConsoleHeight - 5));
  TEntity(FEntities[FPlayerIndex]).Sprite := FPlayerSprite;
  TEntity(FEntities[FPlayerIndex]).Health := 3;
  TEntity(FEntities[FPlayerIndex]).CollisionShape := csRect;
  TEntity(FEntities[FPlayerIndex]).FCollisionWidth := 5;
  TEntity(FEntities[FPlayerIndex]).FCollisionHeight := 3;
  
  // Create background stars
  for I := 0 to 30 do
  begin
    var StarEntity := TEntity.Create(etBackground, TConsole.RandomRange(0, ConsoleWidth), 
                                  TConsole.RandomRange(0, ConsoleHeight));
    StarEntity.Sprite := TAsciiSprite.Create(1, 1);
    StarEntity.Sprite.SetChar(0, 0, '.', CSIFGWhite + CSIDim, CSIBGBlack);
    StarEntity.VelY := 0.1 + TConsole.RandomRange(0, 20) / 100;
    FEntities.Add(StarEntity);
  end;
end;

function TGameManager.FindPlayerEntity: TEntity;
begin
  if (FPlayerIndex >= 0) and (FPlayerIndex < FEntities.Count) then
    Result := TEntity(FEntities[FPlayerIndex])
  else
    Result := nil;
end;

procedure TGameManager.CreateExplosion(X, Y: Double; Size: Integer);
var
  Explosion: TEntity;
  I: Integer;
begin
  // Create explosion entity
  Explosion := TEntity.Create(etExplosion, X, Y);
  Explosion.Animation := FExplosionAnimation;
  Explosion.Animation.Reset;
  Explosion.Lifetime := 12;
  FEntities.Add(Explosion);
  
  // Create particle effects
  FParticleSystem.Emit(X, Y, 10 + Size * 5, EXPLOSION_COLOR, 0, 0, 1.0, 15);
  
  // Add explosion effects for large explosions
  if Size >= 2 then
  begin
    for I := 0 to 2 do
    begin
      var OffsetX := TConsole.RandomRange(-2, 3);
      var OffsetY := TConsole.RandomRange(-2, 3);
      
      Explosion := TEntity.Create(etExplosion, X + OffsetX, Y + OffsetY);
      Explosion.Animation := FExplosionAnimation;
      Explosion.Animation.Reset;
      Explosion.Lifetime := 8 + TConsole.RandomRange(0, 5);
      FEntities.Add(Explosion);
    end;
  end;
end;

procedure TGameManager.CreatePlayerBullet(X, Y: Double);
var
  Bullet: TEntity;
begin
  Bullet := TEntity.Create(etBullet, X, Y);
  Bullet.Sprite := FBulletSprite;
  Bullet.VelY := -0.8; // Fast upward movement
  Bullet.Tag := 1; // Player bullet

  // Fix collision detection for bullets
  Bullet.CollisionShape := csPoint; // Point-based collision for better detection

  FEntities.Add(Bullet);

  // Add thruster particles
  FParticleSystem.Emit(X, Y + 1, 3, BULLET_COLOR, 0, 0.2, 0.3, 5);
end;

procedure TGameManager.CreateEnemyBullet(X, Y: Double);
var
  Bullet: TEntity;
begin
  Bullet := TEntity.Create(etBullet, X, Y);
  Bullet.Sprite := FBulletSprite;
  Bullet.VelY := 0.5;
  Bullet.Tag := 2; // Enemy bullet
  Bullet.CollisionShape := csRect;
  Bullet.FCollisionWidth := 1;
  Bullet.FCollisionHeight := 2;
  FEntities.Add(Bullet);
end;

procedure TGameManager.CreateEnemy(X, Y: Double; EnemyType: Integer);
var
  Enemy: TEntity;
begin
  Enemy := TEntity.Create(etEnemy, X, Y);
  Enemy.Sprite := FEnemySprites[EnemyType mod 3];
  Enemy.Tag := EnemyType;
  Enemy.Health := 1 + (EnemyType div 3);
  Enemy.Value := 10 * (EnemyType + 1);

  // Different movement patterns based on type
  case EnemyType mod 3 of
    0: begin
         Enemy.VelY := 0.2;
         Enemy.VelX := 0;
       end;
    1: begin
         Enemy.VelY := 0.15;
         Enemy.VelX := 0.1 * Sin(FGameTime / 20);
       end;
    2: begin
         Enemy.VelY := 0.12;
         Enemy.VelX := 0.2;
         Enemy.Tag := EnemyType + 10; // Special tag for tracking sine movement
       end;
  end;

  // Improve collision detection
  Enemy.CollisionShape := csCircle; // Circle for better detection
  Enemy.FCollisionRadius := 2.5;    // About half the width of enemy sprites

  FEntities.Add(Enemy);
end;

procedure TGameManager.CreateAsteroid(X, Y: Double; Size: Integer);
var
  Asteroid: TEntity;
begin
  Asteroid := TEntity.Create(etAsteroid, X, Y);
  Asteroid.Sprite := FAsteroidSprites[Size];
  Asteroid.Tag := Size;
  Asteroid.Health := Size + 1;
  Asteroid.Value := 5 * (3 - Size);
  
  // Random velocity based on size
  Asteroid.VelX := (TConsole.RandomRange(-20, 21) / 100) * (3 - Size);
  Asteroid.VelY := 0.1 + (TConsole.RandomRange(0, 20) / 100) * (3 - Size);
  
  Asteroid.CollisionShape := csCircle;
  case Size of
    0: Asteroid.FCollisionRadius := 3;
    1: Asteroid.FCollisionRadius := 2;
    2: Asteroid.FCollisionRadius := 1;
  end;
  
  FEntities.Add(Asteroid);
end;

procedure TGameManager.CreatePowerup(X, Y: Double);
var
  Powerup: TEntity;
begin
  Powerup := TEntity.Create(etPowerup, X, Y);
  Powerup.Sprite := FPowerupSprite;
  Powerup.VelY := 0.2;
  Powerup.Tag := TConsole.RandomRange(0, 3); // Random powerup type
  Powerup.CollisionShape := csRect;
  Powerup.FCollisionWidth := 3;
  Powerup.FCollisionHeight := 2;
  
  FEntities.Add(Powerup);
end;

procedure TGameManager.UpdateEntities;
var
  I{, J}: Integer;
  Entity: TEntity;
  ConsoleWidth, ConsoleHeight: Integer;
begin
  TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);
  
  // Update all entities
  I := 0;
  while I < FEntities.Count do
  begin
    Entity := TEntity(FEntities[I]);
    
    if Entity.Active then
    begin
      // Update entity
      Entity.Update;
      
      // Special handling based on entity type
      case Entity.EntityType of
        etEnemy:
          begin
            // Check if enemy is out of bounds
            if (Entity.Y > ConsoleHeight + 2) or 
               (Entity.X < -5) or (Entity.X > ConsoleWidth + 5) then
            begin
              Entity.Active := False;
            end
            else
            begin
              // Special movement patterns
              if (Entity.Tag >= 10) then
              begin
                // Sine wave movement
                Entity.VelX := 0.2 * Sin(FGameTime / 20);
              end;
              
              // Fire bullets randomly
              if (TConsole.RandomRange(0, 100) < 1 + FLevel) and (Entity.Y < ConsoleHeight - 10) then
                CreateEnemyBullet(Entity.X, Entity.Y + 2);
            end;
          end;
          
        etAsteroid:
          begin
            // Check if asteroid is out of bounds
            if (Entity.Y > ConsoleHeight + 5) then
            begin
              Entity.Active := False;
            end
            else
            begin
              // Screen wrapping for asteroids
              if Entity.X < -5 then
                Entity.X := ConsoleWidth + 4
              else if Entity.X > ConsoleWidth + 5 then
                Entity.X := -4;
            end;
          end;
          
        etBullet:
          begin
            // Check if bullet is out of bounds
            if (Entity.Y < -2) or (Entity.Y > ConsoleHeight + 2) then
              Entity.Active := False;
          end;
          
        etPowerup:
          begin
            // Check if powerup is out of bounds
            if Entity.Y > ConsoleHeight + 2 then
              Entity.Active := False;
          end;
          
        etBackground:
          begin
            // Wrap around screen for background elements
            if Entity.Y > ConsoleHeight then
            begin
              Entity.Y := 0;
              Entity.X := TConsole.RandomRange(0, ConsoleWidth);
            end;
          end;
      end;
      
      Inc(I);
    end
    else
    begin
      // Remove inactive entities
      Entity.Free;
      FEntities.Delete(I);
      
      // Adjust player index if needed
      if I <= FPlayerIndex then
        Dec(FPlayerIndex);
    end;
  end;
end;

procedure TGameManager.UpdatePlayer;
var
  Player: TEntity;
  ConsoleWidth, ConsoleHeight: Integer;
begin
  Player := FindPlayerEntity;
  if not Assigned(Player) or not Player.Active then
    Exit;
    
  TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);
  
  // Handle player movement
  if TConsole.IsKeyPressed(VK_LEFT) then
  begin
    Player.VelX := Player.VelX - 0.1;
    if Player.VelX < -0.6 then
      Player.VelX := -0.6;
      
    // Change sprite to left-tilting ship
    Player.Sprite := TAsciiSprite.Create(5, 3);
    Player.Sprite.LoadFromString(PLAYER_SPRITE_LEFT, PLAYER_COLOR, CSIBGBlack);
  end
  else if TConsole.IsKeyPressed(VK_RIGHT) then
  begin
    Player.VelX := Player.VelX + 0.1;
    if Player.VelX > 0.6 then
      Player.VelX := 0.6;
      
    // Change sprite to right-tilting ship
    Player.Sprite := TAsciiSprite.Create(5, 3);
    Player.Sprite.LoadFromString(PLAYER_SPRITE_RIGHT, PLAYER_COLOR, CSIBGBlack);
  end
  else
  begin
    // Decelerate when no keys pressed
    Player.VelX := Player.VelX * 0.9;
    
    // Restore normal sprite
    Player.Sprite := FPlayerSprite;
  end;
  
  // Fire bullet with spacebar
  if TConsole.WasKeyPressed(VK_SPACE) then
  begin
    CreatePlayerBullet(Player.X, Player.Y - 2);
    
    // Add thruster particles
    FParticleSystem.Emit(Player.X, Player.Y + 2, 5, CSIFGYellow, 0, 0.2, 0.8, 10);
  end;
  
  // Screen boundary checks
  if Player.X < 3 then
  begin
    Player.X := 3;
    Player.VelX := 0;
  end
  else if Player.X > ConsoleWidth - 3 then
  begin
    Player.X := ConsoleWidth - 3;
    Player.VelX := 0;
  end;
  
  // Add engine particle effects
  if FGameTime mod 5 = 0 then
    FParticleSystem.Emit(Player.X, Player.Y + 2, 1, CSIFGYellow, 0, 0.2, 0.4, 10);
end;

procedure TGameManager.CheckCollisions;
var
  I, J, K: Integer;
  EntityA, EntityB: TEntity;
  //Player: TEntity;
  //Split: Boolean;
  Bullet, Target, Enemy, PlayerEntity: TEntity;
begin
  //Player := FindPlayerEntity;

  for I := 0 to FEntities.Count - 1 do
  begin
    EntityA := TEntity(FEntities[I]);
    if not EntityA.Active then
      Continue;

    for J := I + 1 to FEntities.Count - 1 do
    begin
      EntityB := TEntity(FEntities[J]);
      if not EntityB.Active then
        Continue;

      // Skip collision checks between certain types
      if (EntityA.EntityType = etBackground) or (EntityB.EntityType = etBackground) or
         (EntityA.EntityType = etExplosion) or (EntityB.EntityType = etExplosion) then
        Continue;

      // Check for collision
      if EntityA.CheckCollision(EntityB) then
      begin
        // Player bullets vs enemies/asteroids
        if ((EntityA.EntityType = etBullet) and (EntityA.Tag = 1) and
           ((EntityB.EntityType = etEnemy) or (EntityB.EntityType = etAsteroid))) or
           ((EntityB.EntityType = etBullet) and (EntityB.Tag = 1) and
           ((EntityA.EntityType = etEnemy) or (EntityA.EntityType = etAsteroid))) then
        begin
          // Determine which entity is the bullet and which is the target
          if (EntityA.EntityType = etBullet) then
          begin
            Bullet := EntityA;
            Target := EntityB;
          end
          else
          begin
            Bullet := EntityB;
            Target := EntityA;
          end;

          // Damage enemy/asteroid
          Target.DecreaseHealth;
          Bullet.Active := False;

          // Create hit effect
          FParticleSystem.Emit(Bullet.X, Bullet.Y, 5, CSIFGWhite, 0, 0, 0.7, 8);

          if Target.Health <= 0 then
          begin
            // Add score
            Inc(FScore, Target.Value);

            // Create explosion
            CreateExplosion(Target.X, Target.Y, 1);

            // Split asteroids into smaller ones
            //Split := False;
            if (Target.EntityType = etAsteroid) and (Target.Tag < 2) then
            begin
              for K := 0 to 1 do
              begin
                CreateAsteroid(Target.X, Target.Y, Target.Tag + 1);
                //Split := True;
              end;
            end;

            // Small chance of powerup from enemies
            if (Target.EntityType = etEnemy) and (TConsole.RandomRange(0, 10) < 2) then
              CreatePowerup(Target.X, Target.Y);

            Target.Active := False;
          end
          else
          begin
            // Flash effect for hit
            if Target.EntityType = etEnemy then
              FParticleSystem.Emit(Bullet.X, Bullet.Y, 3, ENEMY_COLOR_A, 0, 0, 0.5, 5)
            else
              FParticleSystem.Emit(Bullet.X, Bullet.Y, 3, CSIFGWhite, 0, 0, 0.5, 5);
          end;
        end
        // Enemy bullets vs player
        else if ((EntityA.EntityType = etBullet) and (EntityA.Tag = 2) and (EntityB.EntityType = etPlayer)) or
                ((EntityB.EntityType = etBullet) and (EntityB.Tag = 2) and (EntityA.EntityType = etPlayer)) then
        begin
          // Determine which entity is the bullet and which is the player
          if (EntityA.EntityType = etBullet) then
          begin
            Bullet := EntityA;
            PlayerEntity := EntityB;
          end
          else
          begin
            Bullet := EntityB;
            PlayerEntity := EntityA;
          end;

          // Damage player
          PlayerEntity.DecreaseHealth;
          Bullet.Active := False;

          // Create small explosion
          CreateExplosion(Bullet.X, Bullet.Y, 1);

          if PlayerEntity.Health <= 0 then
          begin
            // Player destroyed
            CreateExplosion(PlayerEntity.X, PlayerEntity.Y, 2);
            PlayerEntity.Active := False;

            Dec(FLives);
            if FLives <= 0 then
              GameOver
            else
            begin
              // Respawn player
              var ConsoleWidth, ConsoleHeight: Integer;
              TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);

              FPlayerIndex := FEntities.Add(TEntity.Create(etPlayer, ConsoleWidth / 2, ConsoleHeight - 5));
              TEntity(FEntities[FPlayerIndex]).Sprite := FPlayerSprite;
              TEntity(FEntities[FPlayerIndex]).Health := 3;
              TEntity(FEntities[FPlayerIndex]).CollisionShape := csRect;
              TEntity(FEntities[FPlayerIndex]).FCollisionWidth := 5;
              TEntity(FEntities[FPlayerIndex]).FCollisionHeight := 3;
            end;
          end;
        end
        // Enemy or asteroid vs player
        else if (((EntityA.EntityType = etEnemy) or (EntityA.EntityType = etAsteroid)) and
                (EntityB.EntityType = etPlayer)) or
                (((EntityB.EntityType = etEnemy) or (EntityB.EntityType = etAsteroid)) and
                (EntityA.EntityType = etPlayer)) then
        begin
          // Determine which entity is the enemy/asteroid and which is the player
          if (EntityA.EntityType = etPlayer) then
          begin
            PlayerEntity := EntityA;
            Enemy := EntityB;
          end
          else
          begin
            PlayerEntity := EntityB;
            Enemy := EntityA;
          end;

          // Major collision - damage both
          Enemy.DecreaseHealth;
          PlayerEntity.DecreaseHealth(2);

          // Create explosion
          CreateExplosion((Enemy.X + PlayerEntity.X) / 2, (Enemy.Y + PlayerEntity.Y) / 2, 2);

          if Enemy.Health <= 0 then
            Enemy.Active := False;

          if PlayerEntity.Health <= 0 then
          begin
            // Player destroyed
            CreateExplosion(PlayerEntity.X, PlayerEntity.Y, 2);
            PlayerEntity.Active := False;

            Dec(FLives);
            if FLives <= 0 then
              GameOver
            else
            begin
              // Respawn player
              var ConsoleWidth, ConsoleHeight: Integer;
              TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);

              FPlayerIndex := FEntities.Add(TEntity.Create(etPlayer, ConsoleWidth / 2, ConsoleHeight - 5));
              TEntity(FEntities[FPlayerIndex]).Sprite := FPlayerSprite;
              TEntity(FEntities[FPlayerIndex]).Health := 3;
              TEntity(FEntities[FPlayerIndex]).CollisionShape := csRect;
              TEntity(FEntities[FPlayerIndex]).FCollisionWidth := 5;
              TEntity(FEntities[FPlayerIndex]).FCollisionHeight := 3;
            end;
          end;
        end
        // Powerup vs player
        else if ((EntityA.EntityType = etPowerup) and (EntityB.EntityType = etPlayer)) or
                ((EntityB.EntityType = etPowerup) and (EntityA.EntityType = etPlayer)) then
        begin
          // Determine which entity is the powerup
          var Powerup: TEntity;
          if (EntityA.EntityType = etPowerup) then
            Powerup := EntityA
          else
            Powerup := EntityB;

          // Apply powerup effect
          case Powerup.Tag of
            0: begin // Extra points
                 Inc(FScore, 50);
                 FParticleSystem.Emit(Powerup.X, Powerup.Y, 10, CSIFGGreen, 0, -0.2, 0.5, 15);
               end;
            1: begin // Extra health
                 if (EntityA.EntityType = etPlayer) then
                   EntityA.IncreaseHealth
                 else
                   EntityB.IncreaseHealth;

                 FParticleSystem.Emit(Powerup.X, Powerup.Y, 10, CSIFGCyan, 0, -0.2, 0.5, 15);
               end;
            2: begin // Extra life
                 Inc(FLives);
                 FParticleSystem.Emit(Powerup.X, Powerup.Y, 10, CSIFGMagenta, 0, -0.2, 0.5, 15);
               end;
          end;

          Powerup.Active := False;
        end;
      end;
    end;
  end;
end;

procedure TGameManager.SpawnEnemies;
var
  ConsoleWidth: Integer;
begin
  Inc(FSpawnTimer);
  Inc(FPowerupTimer);
  
  TConsole.GetSize(@ConsoleWidth, nil);
  
  // Spawn rate decreases as level increases
  if FSpawnTimer >= Max(60 - FLevel * 5, 20) then
  begin
    FSpawnTimer := 0;
    
    // Random enemy or asteroid
    if TConsole.RandomRange(0, 10) < 7 then
    begin
      // Spawn enemy
      CreateEnemy(TConsole.RandomRange(10, ConsoleWidth - 10), 0, TConsole.RandomRange(0, 3));
    end
    else
    begin
      // Spawn asteroid
      CreateAsteroid(TConsole.RandomRange(5, ConsoleWidth - 5), 0, 0);
    end;
  end;
  
  // Spawn powerups occasionally
  if FPowerupTimer >= 500 then
  begin
    FPowerupTimer := 0;
    
    CreatePowerup(TConsole.RandomRange(10, ConsoleWidth - 10), 0);
  end;
end;

procedure TGameManager.GameOver;
begin
  FGameState := GAME_STATE_GAME_OVER;
end;

procedure TGameManager.NextLevel;
begin
  Inc(FLevel);
  
  // Increase difficulty
  FSpawnTimer := 0;
  FPowerupTimer := 0;
  
  // Bonus points for completing level
  Inc(FScore, FLevel * 100);
  
  // Spawn wave of asteroids
  var ConsoleWidth: Integer;
  TConsole.GetSize(@ConsoleWidth, nil);
  
  var I: Integer;
  for I := 0 to 3 + FLevel do
    CreateAsteroid(TConsole.RandomRange(5, ConsoleWidth - 5), 0, 0);
end;

procedure TGameManager.RenderGame;
var
  I: Integer;
  Entity: TEntity;
  ConsoleWidth, ConsoleHeight: Integer;
begin
  TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);

  // Clear the buffer
  FBuffer.Clear(' ', CSIDim + CSIFGWhite, CSIBGBlack);

  // Handle different game states
  case FGameState of
    GAME_STATE_TITLE:
      begin
        // Draw title screen
        var Title := '* STELLAR DEFENDER *';
        for I := 0 to Length(Title) - 1 do
          FBuffer.PutChar((ConsoleWidth div 2) - (Length(Title) div 2) + I, ConsoleHeight div 2 - 8,
                         Title[I+1], CSIFGCyan, CSIBGBlack);

        Title := 'A Space Shooter Adventure';
        for I := 0 to Length(Title) - 1 do
          FBuffer.PutChar((ConsoleWidth div 2) - (Length(Title) div 2) + I, ConsoleHeight div 2 - 6,
                         Title[I+1], CSIFGWhite, CSIBGBlack);

        Title := 'Controls:';
        for I := 0 to Length(Title) - 1 do
          FBuffer.PutChar((ConsoleWidth div 2) - (Length(Title) div 2) + I, ConsoleHeight div 2 - 3,
                         Title[I+1], CSIFGYellow, CSIBGBlack);

        Title := 'LEFT/RIGHT - Move Ship';
        for I := 0 to Length(Title) - 1 do
          FBuffer.PutChar((ConsoleWidth div 2) - (Length(Title) div 2) + I, ConsoleHeight div 2 - 1,
                         Title[I+1], CSIFGWhite, CSIBGBlack);

        Title := 'SPACE - Fire Weapon';
        for I := 0 to Length(Title) - 1 do
          FBuffer.PutChar((ConsoleWidth div 2) - (Length(Title) div 2) + I, ConsoleHeight div 2,
                         Title[I+1], CSIFGWhite, CSIBGBlack);

        Title := 'ESC - Quit Game';
        for I := 0 to Length(Title) - 1 do
          FBuffer.PutChar((ConsoleWidth div 2) - (Length(Title) div 2) + I, ConsoleHeight div 2 + 1,
                         Title[I+1], CSIFGWhite, CSIBGBlack);

        Title := 'Press [S] to Start!';
        for I := 0 to Length(Title) - 1 do
          FBuffer.PutChar((ConsoleWidth div 2) - (Length(Title) div 2) + I, ConsoleHeight div 2 + 4,
                         Title[I+1], CSIFGMagenta, CSIBGBlack);

        // Draw background stars
        for I := 0 to FEntities.Count - 1 do
        begin
          Entity := TEntity(FEntities[I]);
          if Entity.EntityType = etBackground then
            FBuffer.PutSprite(Round(Entity.X), Round(Entity.Y), Entity.Sprite);
        end;
      end;

    GAME_STATE_PLAYING, GAME_STATE_GAME_OVER:
      begin
        // Draw all entities
        for I := 0 to FEntities.Count - 1 do
        begin
          Entity := TEntity(FEntities[I]);

          if Entity.Active then
          begin
            if Assigned(Entity.Animation) then
              FBuffer.PutSprite(Round(Entity.X), Round(Entity.Y), Entity.Animation.CurrentFrame)
            else if Assigned(Entity.Sprite) then
              FBuffer.PutSprite(Round(Entity.X), Round(Entity.Y), Entity.Sprite);

            // Add debug health display for enemies and asteroids
            if (Entity.EntityType = etEnemy) or (Entity.EntityType = etAsteroid) then
            begin
              var HealthChar: WideChar;
              HealthChar := Chr(Ord('0') + Entity.Health);
              FBuffer.PutChar(Round(Entity.X), Round(Entity.Y) - 1, HealthChar, CSIFGRed, CSIBGBlack);
            end;
          end;
        end;

        // Draw particles
        FParticleSystem.Render(FBuffer);

        // Render UI
        RenderUI;

        // Draw game over screen if needed
        if FGameState = GAME_STATE_GAME_OVER then
        begin
          var GameOverTitle := 'GAME OVER';
          for I := 0 to Length(GameOverTitle) - 1 do
            FBuffer.PutChar((ConsoleWidth div 2) - (Length(GameOverTitle) div 2) + I, ConsoleHeight div 2 - 5,
                           GameOverTitle[I+1], CSIFGRed, CSIBGBlack);

          var ScoreText := Format('Final Score: %d', [FScore]);
          for I := 0 to Length(ScoreText) - 1 do
            FBuffer.PutChar((ConsoleWidth div 2) - (Length(ScoreText) div 2) + I, ConsoleHeight div 2 - 2,
                           ScoreText[I+1], CSIFGWhite, CSIBGBlack);

          var LevelText := Format('Levels Completed: %d', [FLevel - 1]);
          for I := 0 to Length(LevelText) - 1 do
            FBuffer.PutChar((ConsoleWidth div 2) - (Length(LevelText) div 2) + I, ConsoleHeight div 2,
                           LevelText[I+1], CSIFGWhite, CSIBGBlack);

          var ReplayText := 'Press [S] to Play Again';
          for I := 0 to Length(ReplayText) - 1 do
            FBuffer.PutChar((ConsoleWidth div 2) - (Length(ReplayText) div 2) + I, ConsoleHeight div 2 + 3,
                           ReplayText[I+1], CSIFGYellow, CSIBGBlack);

          var QuitText := 'Press ESC to Quit';
          for I := 0 to Length(QuitText) - 1 do
            FBuffer.PutChar((ConsoleWidth div 2) - (Length(QuitText) div 2) + I, ConsoleHeight div 2 + 5,
                           QuitText[I+1], CSIFGWhite, CSIBGBlack);
        end;
      end;
  end;
end;

procedure TGameManager.RenderUI;
var
  I: Integer;
  ConsoleWidth, ConsoleHeight: Integer;
  StatusText, HealthBar: string;
  Player: TEntity;
begin
  TConsole.GetSize(@ConsoleWidth, @ConsoleHeight);

  // Render top status bar
  StatusText := Format('LEVEL: %d  SCORE: %d  LIVES: %d', [FLevel, FScore, FLives]);
  for I := 0 to Length(StatusText) - 1 do
    FBuffer.PutChar(2 + I, 1, StatusText[I+1], CSIFGWhite, CSIBGBlack);

  // Render health bar
  Player := FindPlayerEntity;
  if Assigned(Player) and Player.Active then
  begin
    HealthBar := Format('HEALTH: [%s]', [StringOfChar('=', Player.Health) + 
                                        StringOfChar('-', 5 - Player.Health)]);
                                        
    for I := 0 to Length(HealthBar) - 1 do
    begin
      if (I >= 8) and (I < 8 + Player.Health) then
        FBuffer.PutChar(ConsoleWidth - Length(HealthBar) - 2 + I, 1, HealthBar[I+1], CSIFGGreen, CSIBGBlack)
      else if I >= 8 then
        FBuffer.PutChar(ConsoleWidth - Length(HealthBar) - 2 + I, 1, HealthBar[I+1], CSIFGRed, CSIBGBlack)
      else
        FBuffer.PutChar(ConsoleWidth - Length(HealthBar) - 2 + I, 1, HealthBar[I+1], CSIFGWhite, CSIBGBlack);
    end;
  end;
  
  // Show FPS in debug corner
  var FPSText := Format('FPS: %.1f', [FBuffer.ActualFPS]);
  for I := 0 to Length(FPSText) - 1 do
    FBuffer.PutChar(ConsoleWidth - Length(FPSText) - 1 + I, ConsoleHeight - 1, FPSText[I+1], 
                   CSIFGWhite + CSIDim, CSIBGBlack);
end;

procedure TGameManager.Run;
begin
  // Main game loop
  var Running := True;
  
  while Running do
  begin
    TConsole.ProcessMessages();

    // Process input
    if TConsole.IsKeyPressed(VK_ESCAPE) then
      Running := False;

    // Wait for next frame
    if FBuffer.BeginFrame then
    begin
      // Increment game time
      Inc(FGameTime);

      // Handle state-specific updates
      case FGameState of
        GAME_STATE_TITLE:
          begin
            // Update background stars
            UpdateEntities;

            // Start game on space
            if TConsole.WasKeyPressed(Ord('S')) then
            begin
              FGameState := GAME_STATE_PLAYING;
              InitGame;
            end;
          end;
          
        GAME_STATE_PLAYING:
          begin
            // Update player
            UpdatePlayer;
            
            // Update all entities
            UpdateEntities;
            
            // Particle system update
            FParticleSystem.Update;
            
            // Check for collisions
            CheckCollisions;
            
            // Spawn new enemies
            SpawnEnemies;
            
            // Check for level advancement
            if (FGameTime mod 2000 = 0) and (FGameTime > 0) then
              NextLevel;
          end;
          
        GAME_STATE_GAME_OVER:
          begin
            // Update background elements
            UpdateEntities;
            
            // Particle system update
            FParticleSystem.Update;
            
            // Restart game on space
            if TConsole.WasKeyPressed(Ord('S')) then
            begin
              InitGame;
              FGameState := GAME_STATE_PLAYING;
            end;
          end;
      end;
      
      // Render the game
      RenderGame;
      
      // Complete the frame
      FBuffer.EndFrame;
    end;
  end;
end;

procedure Demo_StellarDefender;
var
  Buffer: TAsciiBuffer;
  MaxW, MaxH: Integer;
  GameManager: TGameManager;
begin
  TConsole.SetTitle('TConsole: Stellar Defender Demo');

  TConsole.ClearKeyStates();
  TConsole.ClearScreen();
  TConsole.SetCursorVisible(False);
  TConsole.GetSize(@MaxW, @MaxH);
  
  Buffer := TAsciiBuffer.Create(MaxW, MaxH);
  try
    // Set target frame rate
    Buffer.TargetFPS := 60;
    
    // Create and run game manager
    GameManager := TGameManager.Create(Buffer);
    try
      GameManager.Run;
    finally
      GameManager.Free;
    end;
  finally
    Buffer.Free;
    TConsole.SetCursorVisible(True);
    TConsole.ClearScreen();
  end;
end;

end.
