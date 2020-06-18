unit rfDonutGauge;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Controls, Graphics, Dialogs, BGRABitmap, BGRABitmapTypes, Types, ExtCtrls;

type
  TCircleGaugeGen2 = class(TGraphicControl)
  private
     xc, yc, lpos, lposfix, fixposition : single;
     posfill : TBGRAPixel;

     FDefaultBitmap : TBGRABitmap;
     FSetBitmap : TBGRABitmap;
     FParent : TWinControl;
     FFont:       TFont;
     FLeftMargin,
     CharWidth:   integer;
     FTicksMargin : integer;
     FLTicksSize : integer;
     FMaxAngle : integer;
     FMinAngle : integer;
     FLTicks : integer;
     FMax : Extended;
     FMin : Extended;
     FOffsetAngle : integer;
     FLTicksWidth : integer;
     FShowValues : Boolean;
     FValuesMargin : integer;
     FSTicks : integer;
     FSTicksSize : integer;
     FPosition: Extended;
     FProgressColor : TColor;
     FProgressSubColor : TColor;
     FCircleColor : TColor;
     F_Font_Color : TColor;
     FDecimalPlaces : Word;
     FLineWidth : Word;
     procedure SetLeftMargin(Value: integer);
     procedure SetupParent(Value: TWinControl);
     function PosToAngle(Pos: Extended): integer;
     procedure SetMax(const AValue: Extended);
     procedure SetMaxAngle(const AValue: Integer);
     procedure SetMin(const AValue: Extended);
     procedure SetMinAngle(const AValue: Integer);
     procedure SetOffsetAngle(AValue: integer);
     procedure SetTicksMargin(const AValue: integer);
     procedure SetLargeTicks(const AValue: integer);
     procedure SetLTicksSize(const AValue: integer);
     procedure SetLTicksWidth(AValue: integer);
     procedure SetSTicks(const AValue: integer);
     procedure SetSTicksSize(const AValue: integer);
     procedure SetShowValues(const AValue: Boolean);
     procedure SetValueMargin(const AValue: integer);
     procedure SetPosition(const value: Extended);
     procedure SetProgressColor(value: TColor);
     procedure SetProgressSubColor(value: TColor);
     procedure SetCircleColor(value: TColor);
     procedure DrawLineArc;
     procedure SetFontColor(value: TColor);
     procedure SetDecimalPlaces(value:Word);
     procedure SetLineWidth(const value: Word);
  protected
     procedure Paint; override;
     procedure DoOnResize; override;
     procedure ClearBitMap(var BitMap: TBGRABitmap);
     procedure ForcePosition(const AValue: Extended); virtual;
  public
     constructor Create(AOwner: TComponent); override;
  published
     property Align;
     property Color;
     property Enabled;
     property Font;
     property Height;
     property PopupMenu;
     property Visible;
     property Width;
     property ProgessColor: TColor read FProgressColor  write SetProgressColor;
     property ProgessSubColor: TColor read FProgressSubColor  write SetProgressSubColor;
     property CircleColor: TColor read FCircleColor  write SetCircleColor;
     property Position: Extended read FPosition write SetPosition;
     property Max: Extended read FMax write SetMax;
     property MaxAngle: Integer read FMaxAngle write SetMaxAngle;
     property Min: Extended read FMin write SetMin;
     property MinAngle: Integer read FMinAngle write SetMinAngle;
     property OffsetAngle: integer read FOffsetAngle write SetOffsetAngle;
     property TicksMargin:integer read FTicksMargin write SetTicksMargin;
     property LTicks:integer read FLTicks write SetLargeTicks;
     property LTicksSize:integer read FLTicksSize write SetLTicksSize;
     property LTicksWidth:integer read FLTicksWidth write SetLTicksWidth;
     property STicks:integer read FSTicks write SetSTicks;
     property STicksSize:integer read FSTicksSize write SetSTicksSize;
     property ShowValues:Boolean read FShowValues write SetShowValues;
     property ValuesMargin:integer read FValuesMargin write SetValueMargin;
     property LeftMargin: integer read FLeftMargin write SetLeftMargin;
     property DecimalPlaces: Word read FDecimalPlaces write SetDecimalPlaces;
     property FontColor: TColor read F_Font_Color write SetFontColor;
     property LineWidth: Word read FLineWidth write SetLineWidth;
     property Parent: TWinControl read FParent write SetupParent;
     property OnResize;
     property OnClick;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Armtronics',[TCircleGaugeGen2]);
end;

constructor TCircleGaugeGen2.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFont := TFont.Create;
  Align := alNone;
  Color := clBtnFace;
  Enabled := true;
  Visible := true;
  Height := 300;
  Width := 300;
  Font.Height := 15;
  FLeftMargin := 3;
  CharWidth := 8;
  FTicksMargin := 80;
  FLTicksSize := 8;
  FMaxAngle:=3300;
  FMinAngle:=300;
  FLTicks:=8;
  FMax:=8000;
  FMin:=0;
  FOffsetAngle := 10;
  FLTicksWidth := 1;
  FShowValues:=true;
  FSTicks := 3;
  FValuesMargin:=12;
  FSTicksSize := 4;
  FPosition := FMin;
  FProgressColor:= BGRAToColor(BGRA(2, 180, 252,250));
  FProgressSubColor:= BGRAToColor(BGRA(0, 154, 216,180));
  FCircleColor:= clWhite;
  FDecimalPlaces := 1;
  FLineWidth := 40;
  DrawLineArc();
  Parent := TWinControl(AOwner);
end;

procedure TCircleGaugeGen2.ClearBitMap(var BitMap: TBGRABitmap);
begin
  BitMap.Fill(BGRA(0, 0, 0, 0));
end;

procedure TCircleGaugeGen2.DrawLineArc;
var
  i, j : integer;
  lc, sc : TBGRAPixel;
  x1, y1, x2, y2 : Single;
  langle, sn, cn : Single;
  ss : boolean;
  la : string;
  ts : TSize;
begin
  xc:= Width / 2;
  yc:= Height / 2;
  lc:= ColorToBGRA(FCircleColor);
  sc:= ColorToBGRA(FCircleColor);

  FreeAndNil(FDefaultBitmap);
  FDefaultBitmap := TBGRABitmap.Create(Width, Height);
  ss:=((FMaxAngle-FMinAngle) mod 3600)=0;

  lposfix:= round((0 / FLTicks) * (FMax - FMin) + FMin);
  fixposition := ((PosToAngle(lposfix)+FOffsetAngle) * PI/1800 + PI/2);
  posfill := ColorToBGRA(FProgressColor);

  if (FLTicks > 0) then
  begin
    for i := 0 to FLTicks do
    begin
      lpos:=(i/FLTicks)*(FMax-FMin)+FMin;
      langle:=(PosToAngle(lpos) + FOffsetAngle) * PI / 1800 + PI /2 ;
      sn:=sin(langle);
      cn:=cos(langle);
      x1 := xc+FTicksMargin*cn;
      y1 := yc+FTicksMargin*sn;
      x2 := xc+(FTicksMargin+FLTicksSize)*cn;
      y2 := yc+(FTicksMargin+FLTicksSize)*sn;
      FDefaultBitmap.DrawLineAntialias(x1, y1, x2, y2, lc, FLTicksWidth);

      if FShowValues and not(ss and (i=0)) then
      begin
        x2 := xc + ((FTicksMargin + FLTicksSize + FValuesMargin) * cn);
        y2 := yc + (FTicksMargin + FLTicksSize + FValuesMargin) * sn;
        la := floattostrF(lpos/ FDecimalPlaces,ffGeneral,5,2);
        ts := FDefaultBitmap.TextSize(la);
        FDefaultBitmap.FontAntialias := False;
        FDefaultBitmap.FontHeight := Font.Size;
        FDefaultBitmap.FontName := Font.Name;
        FDefaultBitmap.FontStyle := Font.Style;
        FDefaultBitmap.FontOrientation := Font.Orientation;
        FDefaultBitmap.TextOut(trunc(x2+1), trunc(y2-ts.cy/2+1),la,F_Font_Color, taCenter);
      end;

      if (lpos < Fmax) then
      begin
        for j := 1 to FSTicks do
        begin
          lpos:=(i / FLTicks)*(FMax - FMin) + FMin + j * ((FMax-FMin) / FLTicks) / (FSTicks + 1);
          langle:=(PosToAngle(lpos) + FOffsetAngle) * PI / 1800 + PI / 2;
          sn:=sin(langle);
          cn:=cos(langle);
          x1 := (xc + FTicksMargin * cn);
          y1 := (yc + FTicksMargin * sn);
          x2 := (xc + (FTicksMargin + FSTicksSize) * cn);
          y2 := (yc + (FTicksMargin + FSTicksSize) * sn);
          FDefaultBitmap.DrawLineAntialias(x1,y1,x2,y2,sc,1);
        end;
      end;
    end;
  end;
end;

procedure TCircleGaugeGen2.Paint;
var
  prog : Single;
begin
  FSetBitmap := TBGRABitmap.Create(Width, Height);
  try
    lpos := (FPosition / (FMax-FMin))*(FMax-FMin);
    prog := (PosToAngle(lpos)+FOffsetAngle) * PI/1800 + PI/2;
    FSetBitmap.Canvas2D.antialiasing := False;
    FSetBitmap.Canvas2D.linearBlend := True;
    FSetBitmap.LinearAntialiasing := False;
    FSetBitmap.Canvas2D.gradientGammaCorrection := False;
    FSetBitmap.Canvas2D.pixelCenteredCoordinates := False;
    if FPosition >= FMax then
    begin
      FSetBitmap.Canvas2D.beginPath;
      FSetBitmap.Canvas2D.arc(xc, yc, xc-50, yc-50, 0, fixposition, prog, false);
      FSetBitmap.Canvas2D.lineWidth := FLineWidth;
      FSetBitmap.Canvas2D.strokeStyle(clRed);
      FSetBitmap.Canvas2D.stroke;
    end
    else
    begin
      FSetBitmap.Canvas2D.beginPath;
      FSetBitmap.Canvas2D.arc(xc, yc, xc-50, yc-50, 0, fixposition, prog, false);
      FSetBitmap.Canvas2D.lineWidth := FLineWidth;
      FSetBitmap.Canvas2D.strokeStyle(posfill);
      FSetBitmap.Canvas2D.stroke;
    end;
    FSetBitmap.BlendImage(0,0,FDefaultBitmap,TBlendOperation.boLinearBlend);
    FSetBitmap.Draw(Self.Canvas,0,0,false);
  finally
    FreeAndNil(FSetBitmap);
  end;
end;

procedure TCircleGaugeGen2.SetLineWidth(const value: Word);
begin
  FLineWidth := value;
  Invalidate;
end;

procedure TCircleGaugeGen2.SetPosition(const value: Extended);
begin
  if ([csLoading,csDestroying]*ComponentState<>[]) or
     (csCreating in FControlState) then Exit;
  if FPosition = value then Exit;
  FPosition := value;
  ForcePosition(FPosition);
  Invalidate;
end;

procedure TCircleGaugeGen2.ForcePosition(const AValue: Extended);
begin
  if FPosition < FMin then FPosition := FMin
  else if FPosition > FMax then Exit
  else FPosition := AValue;
end;

procedure TCircleGaugeGen2.SetMax(const AValue: Extended);
begin
  if (FMax=AValue) and (AValue<=FMin) then exit;
  FMax:=AValue;
  DrawLineArc;
  Invalidate;
end;

procedure TCircleGaugeGen2.SetMaxAngle(const AValue: Integer);
begin
  if FMaxAngle=AValue then exit;
  FMaxAngle:=AValue;
  DrawLineArc;
  Invalidate;
end;

procedure TCircleGaugeGen2.SetMin(const AValue: Extended);
begin
  if (FMin=AValue) and (AValue>=FMax) then exit;
  FMin:=AValue;
  DrawLineArc;
  Invalidate;
end;

procedure TCircleGaugeGen2.SetMinAngle(const AValue: Integer);
begin
  if FMinAngle=AValue then exit;
  FMinAngle:=AValue;
  DrawLineArc;
  Invalidate;
end;

procedure TCircleGaugeGen2.SetOffsetAngle(AValue: integer);
begin
  if FOffsetAngle=AValue then Exit;
  FOffsetAngle:=AValue;
  DrawLineArc;
  Invalidate;
end;

procedure TCircleGaugeGen2.SetTicksMargin(const AValue: integer);
begin
  if FTicksMargin=AValue then exit;
  FTicksMargin:=AValue;
  DrawLineArc;
  Invalidate;
end;

procedure TCircleGaugeGen2.SetLargeTicks(const AValue: integer);
begin
  if FLTicks = AValue then exit
  else if FLTicks <= 0 then FLTicks := 1
  else FLTicks := AValue;
  DrawLineArc;
  Invalidate;
end;

procedure TCircleGaugeGen2.SetLTicksSize(const AValue: integer);
begin
  if FLTicksSize=AValue then exit;
  FLTicksSize:=AValue;
  DrawLineArc;
  invalidate;
end;

procedure TCircleGaugeGen2.SetLTicksWidth(AValue: integer);
begin
  if FLTicksWidth=AValue then Exit;
  FLTicksWidth:=AValue;
  DrawLineArc;
  invalidate;
end;

procedure TCircleGaugeGen2.SetSTicks(const AValue: integer);
begin
  if FSTicks=AValue then exit;
  FSTicks:=AValue;
  DrawLineArc;
  Invalidate;
end;

procedure TCircleGaugeGen2.SetSTicksSize(const AValue: integer);
begin
  if FSTicksSize=AValue then exit;
  FSTicksSize:=AValue;
  DrawLineArc;
  Invalidate;
end;

procedure TCircleGaugeGen2.SetShowValues(const AValue: Boolean);
begin
  if FShowValues=AValue then exit;
  FShowValues:=AValue;
  DrawLineArc;
  Invalidate;
end;

procedure TCircleGaugeGen2.SetValueMargin(const AValue: integer);
begin
  if FValuesMargin=AValue then exit;
  FValuesMargin:=AValue;
  DrawLineArc;
  Invalidate;
end;

function TCircleGaugeGen2.PosToAngle(Pos: Extended): integer;
begin
  Result := FMinAngle + Round((FMaxAngle - FMinAngle) * (Pos - FMin) / (FMax - FMin));
end;

procedure TCircleGaugeGen2.SetupParent(Value: TWinControl);
begin
  FParent := Value;
  inherited SetParent(FParent);
end;

procedure TCircleGaugeGen2.SetLeftMargin(Value: integer);
begin
  FLeftMargin := Value + 3;
  DrawLineArc;
  Invalidate;
end;

procedure TCircleGaugeGen2.SetProgressColor(value: TColor);
begin
  FProgressColor:=value;
  DrawLineArc;
  Invalidate;
end;

procedure TCircleGaugeGen2.SetProgressSubColor(value: TColor);
begin
  FProgressSubColor:=value;
  DrawLineArc;
  Invalidate;
end;

procedure TCircleGaugeGen2.SetCircleColor(value: TColor);
begin
  FCircleColor:=value;
  DrawLineArc;
  Invalidate;
end;

procedure TCircleGaugeGen2.SetFontColor(value: TColor);
begin
  F_Font_Color := value;
  DrawLineArc;
  Invalidate;
end;

procedure TCircleGaugeGen2.DoOnResize;
begin
  FDefaultBitmap.SetSize(width,height);
  DrawLineArc;
  Invalidate;
  inherited DoOnResize;
end;

procedure TCircleGaugeGen2.setDecimalPlaces(value : Word);
begin
  FDecimalPlaces:=value;
  if FDecimalPlaces <= 0 then FDecimalPlaces := 1;
  DrawLineArc;
  Invalidate;
end;
end.

