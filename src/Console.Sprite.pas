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

unit Console.Sprite;

{$I Console.Defines.inc}

interface

uses
  System.SysUtils,
  System.Classes,
  Console;

type
  { TAsciiSprite }
  TAsciiSprite = class
  private
    FWidth, FHeight: Integer;
    FChars: array of array of WideChar;
    FFGColors: array of array of string;
    FBGColors: array of array of string;
  public
    constructor Create(const AWidth, AHeight: Integer);
    destructor Destroy; override;
    procedure SetChar(const X, Y: Integer; const Ch: WideChar; const AFG: string = CSIFGWhite; const ABG: string = CSIBGBlack);
    procedure LoadFromString(const ASpriteStr: string; const AFG: string = CSIFGWhite; const ABG: string = CSIBGBlack);
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    function GetChar(const X, Y: Integer): WideChar;
    function GetFGColor(const X, Y: Integer): string;
    function GetBGColor(const X, Y: Integer): string;
  end;

  { TSpriteAnimation }
  TAsciiSpriteAnimation = class
  private
    FFrames: array of TAsciiSprite;
    FCurrentFrame: Integer;
    FFrameDelay: Integer;
    FFrameTimer: Integer;
    FLooping: Boolean;
    FFinished: Boolean;
    function GetCurrentFrame: TAsciiSprite;
  public
    constructor Create(const AFrameDelay: Integer; const ALooping: Boolean);
    destructor Destroy; override;
    procedure AddFrame(const ASprite: TAsciiSprite);
    procedure Update;
    procedure Reset;
    property CurrentFrame: TAsciiSprite read GetCurrentFrame;
    property Finished: Boolean read FFinished;
  end;

implementation

{ TAsciiSprite }
constructor TAsciiSprite.Create(const AWidth, AHeight: Integer);
var
  X, Y: Integer;
begin
  inherited Create;
  FWidth := AWidth;
  FHeight := AHeight;

  // Allocate sprite arrays
  SetLength(FChars, FHeight, FWidth);
  SetLength(FFGColors, FHeight, FWidth);
  SetLength(FBGColors, FHeight, FWidth);

  // Initialize with spaces
  for Y := 0 to FHeight - 1 do
    for X := 0 to FWidth - 1 do
    begin
      FChars[Y][X] := ' ';
      FFGColors[Y][X] := CSIFGWhite;
      FBGColors[Y][X] := CSIBGBlack;
    end;
end;

destructor TAsciiSprite.Destroy;
begin
  FChars := nil;
  FFGColors := nil;
  FBGColors := nil;
  inherited;
end;

procedure TAsciiSprite.SetChar(const X, Y: Integer; const Ch: WideChar; const AFG: string; const ABG: string);
begin
  if (X >= 0) and (X < FWidth) and (Y >= 0) and (Y < FHeight) then
  begin
    FChars[Y][X] := Ch;
    FFGColors[Y][X] := AFG;
    FBGColors[Y][X] := ABG;
  end;
end;

procedure TAsciiSprite.LoadFromString(const ASpriteStr: string; const AFG: string = CSIFGWhite; const ABG: string = CSIBGBlack);
var
  Lines: TStringList;
  X, Y: Integer;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := ASpriteStr;

    // Adjust sprite dimensions if needed
    if Lines.Count > FHeight then
      FHeight := Lines.Count;

    for Y := 0 to Lines.Count - 1 do
      if Length(Lines[Y]) > FWidth then
        FWidth := Length(Lines[Y]);

    // Reallocate if size changed
    SetLength(FChars, FHeight, FWidth);
    SetLength(FFGColors, FHeight, FWidth);
    SetLength(FBGColors, FHeight, FWidth);

    // Fill with spaces first
    for Y := 0 to FHeight - 1 do
      for X := 0 to FWidth - 1 do
      begin
        FChars[Y][X] := ' ';
        FFGColors[Y][X] := AFG;
        FBGColors[Y][X] := ABG;
      end;

    // Load characters from string
    for Y := 0 to Lines.Count - 1 do
      for X := 0 to Length(Lines[Y]) - 1 do
      begin
        if X < FWidth then
        begin
          FChars[Y][X] := Lines[Y][X+1];
          FFGColors[Y][X] := AFG;
          FBGColors[Y][X] := ABG;
        end;
      end;
  finally
    Lines.Free;
  end;
end;

function TAsciiSprite.GetChar(const X, Y: Integer): WideChar;
begin
  if (X >= 0) and (X < FWidth) and (Y >= 0) and (Y < FHeight) then
    Result := FChars[Y][X]
  else
    Result := ' ';
end;

function TAsciiSprite.GetFGColor(const X, Y: Integer): string;
begin
  if (X >= 0) and (X < FWidth) and (Y >= 0) and (Y < FHeight) then
    Result := FFGColors[Y][X]
  else
    Result := CSIFGWhite;
end;

function TAsciiSprite.GetBGColor(const X, Y: Integer): string;
begin
  if (X >= 0) and (X < FWidth) and (Y >= 0) and (Y < FHeight) then
    Result := FBGColors[Y][X]
  else
    Result := CSIBGBlack;
end;

{ TSpriteAnimation }
function TAsciiSpriteAnimation.GetCurrentFrame: TAsciiSprite;
begin
  if (Length(FFrames) > 0) and (FCurrentFrame >= 0) and (FCurrentFrame < Length(FFrames)) then
    Result := FFrames[FCurrentFrame]
  else
    Result := nil;
end;

constructor TAsciiSpriteAnimation.Create(const AFrameDelay: Integer; const ALooping: Boolean);
begin
  inherited Create;
  FFrameDelay := AFrameDelay;
  FLooping := ALooping;
  FCurrentFrame := 0;
  FFrameTimer := 0;
  FFinished := False;
  SetLength(FFrames, 0);
end;

destructor TAsciiSpriteAnimation.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(FFrames) - 1 do
    FFrames[I].Free;
  inherited;
end;

procedure TAsciiSpriteAnimation.AddFrame(const ASprite: TAsciiSprite);
begin
  SetLength(FFrames, Length(FFrames) + 1);
  FFrames[Length(FFrames) - 1] := ASprite;
end;

procedure TAsciiSpriteAnimation.Update;
begin
  if (Length(FFrames) = 0) or FFinished then
    Exit;

  Inc(FFrameTimer);

  if FFrameTimer >= FFrameDelay then
  begin
    FFrameTimer := 0;
    Inc(FCurrentFrame);

    if FCurrentFrame >= Length(FFrames) then
    begin
      if FLooping then
        FCurrentFrame := 0
      else
      begin
        FCurrentFrame := Length(FFrames) - 1;
        FFinished := True;
      end;
    end;
  end;
end;

procedure TAsciiSpriteAnimation.Reset;
begin
  FCurrentFrame := 0;
  FFrameTimer := 0;
  FFinished := False;
end;


end.
