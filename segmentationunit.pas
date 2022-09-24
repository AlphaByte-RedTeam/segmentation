unit segmentationUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnUpload: TButton;
    btnSave: TButton;
    btnBinary: TButton;
    btnSegmentation: TButton;
    btnGray: TButton;
    btnDeteksiTepi: TButton;
    btnErosi: TButton;
    btnDilasi: TButton;
    imgMod: TImage;
    imgSrc: TImage;
    Label1: TLabel;
    Label2: TLabel;
    openDialog: TOpenDialog;
    saveDialog: TSaveDialog;
    tbBiner: TTrackBar;
    procedure btnBinaryClick(Sender: TObject);
    procedure btnDeteksiTepiClick(Sender: TObject);
    procedure btnDilasiClick(Sender: TObject);
    procedure btnErosiClick(Sender: TObject);
    procedure btnGrayClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnUploadClick(Sender: TObject);
    procedure imgSrcClick(Sender: TObject);
    procedure tbBinerChange(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

uses Windows;

var
  bmpR, bmpG, bmpB, bmpRR, bmpGG, bmpBB, bmpBinary, BitmapGray, hasilGray, hasilBiner: array[-1..1000, -1..1000] of integer;
  SE : array [-1..1,-1..1] of Integer;

procedure TForm1.btnUploadClick(Sender: TObject);
var
  i, j: integer;
begin
  imgMod.Height := imgSrc.Height;
  imgMod.Width := imgSrc.Width;

  if (openDialog.Execute) then
  begin
    imgSrc.Picture.LoadFromFile(openDialog.FileName);
    for j:=0 to imgSrc.Height-1 do
    begin
      for i:=0 to imgSrc.Width-1 do
      begin
        bmpR[i, j] := getRValue(imgSrc.Canvas.Pixels[i, j]);
        bmpG[i, j] := getGValue(imgSrc.Canvas.Pixels[i, j]);
        bmpB[i, j] := getBValue(imgSrc.Canvas.Pixels[i, j]);

        //bmpRR[i, j] := getRValue(imgMod.Canvas.Pixels[i, j]);
        //bmpGG[i, j] := getGValue(imgMod.Canvas.Pixels[i, j]);
        //bmpBB[i, j] := getBValue(imgMod.Canvas.Pixels[i, j]);
      end;
    end;
  end;
end;

procedure TForm1.imgSrcClick(Sender: TObject);
begin

end;

procedure TForm1.tbBinerChange(Sender: TObject);
begin

end;

procedure TForm1.btnSaveClick(Sender: TObject);
begin
  if (saveDialog.Execute) then
  begin
    imgMod.Picture.SaveToFile(saveDialog.FileName);
  end;
end;

procedure TForm1.btnGrayClick(Sender: TObject);
var
  x, y: integer;
  gray: byte;
begin
  for y:=0 to imgMod.Height-1 do
  begin
    for x:=0 to imgMod.Width-1 do
    begin
      gray := (bmpR[x, y] + bmpG[x, y] + bmpB[x, y]) div 3;
      BitmapGray[x,y] := gray;
      imgMod.Canvas.Pixels[x, y] := RGB(gray, gray, gray);
    end;
  end;
end;

procedure TForm1.btnBinaryClick(Sender: TObject);
var
  x, y, i, j: integer;
  gray: byte;
begin
  for y:=0 to imgSrc.Height-1 do
  begin
    for x:=0 to imgSrc.Width-1 do
    begin
      gray := (bmpR[x, y] + bmpG[x, y] + bmpB[x, y]) div 3;
      if (gray <= tbBiner.Position) then
      begin
        bmpBinary[x, y] := 0;
        imgMod.Canvas.Pixels[x, y] := RGB(0, 0, 0);
      end

      else
      begin
        bmpBinary[x, y] := 1;
        imgMod.Canvas.Pixels[x, y] := RGB(255, 255, 255);
      end;
    end;
  end;

  for j:=0 to imgSrc.Height-1 do
  begin
    for i:=0 to imgSrc.Width-1 do
    begin
      if j=0 then
      begin
        bmpBinary[i,-1] := bmpBinary[i,j];
      end;
      if j=imgSrc.Height-1 then
      begin
        bmpBinary[i,j+1] := bmpBinary[i,j];
      end;
      if i=0 then
      begin
        bmpBinary[-1,j] := bmpBinary[i,j];
      end;
      if i=imgSrc.Width-1 then
      begin
        bmpBinary[i+1,j] := bmpBinary[i,j];
      end;
    end;
  end;

end;

procedure TForm1.btnDeteksiTepiClick(Sender: TObject);
var
  i, j, k, l  : integer;
  temp : double;

begin
  //objek berwarna hitam

  for j := -1 to 1 do
  begin
    for i := -1 to 1 do
    begin
      SE[i,j] := -1;
    end;
  end;

  SE[0,0] := 8;

  for j:=0 to imgSrc.Height-1 do
  begin
    BitmapGray[-1,j] := BitmapGray[0,j];
    BitmapGray[imgSrc.Width,j] := BitmapGray[imgSrc.Width-1,j];
  end;
  for i:=-1 to imgSrc.Width do
  begin
    BitmapGray[i,-1] := BitmapGray[i,0];
    BitmapGray[i,imgSrc.Height] := BitmapGray[i,imgSrc.Height-1];
  end;
  for j:=0 to imgSrc.Height-1 do
  begin
    for i:=0 to imgSrc.Width-1 do
    begin
      temp := 0;
      for l:=-1 to 1 do
      begin
        for k:=-1 to 1 do
        begin
          Temp := Temp + BitmapGray[i-k,j-l] * SE[k,l];
        end;
      end;
      hasilGray[i,j] := Round(temp);

    end;
  end;
   end;

procedure TForm1.btnDilasiClick(Sender: TObject);
var
  i, j, k, l  : integer;
  temp : boolean;
  objek, latar : integer;
begin
  //objek berwarna hitam
  objek := 1;
  latar := 0;

  for j := -1 to 1 do
  begin
    for i := -1 to 1 do
    begin
      SE[i,j] := 1;
    end;
  end;

  for j:=0 to imgSrc.Height-1 do
  begin
    for i:=0 to imgSrc.Width-1 do
    begin
          temp := True;
          for l:=-1 to 1 do
          begin
            for k:=-1 to 1 do
            begin
              if (SE[k,l]>=0) then
              begin
                Temp := Temp AND (bmpBinary[i+k,j+l]=SE[k,l]);
              end;
            end;
          end;
          if temp then
            hasilBiner[i,j] := objek
          else
            hasilBiner[i,j] := latar;
          imgMod.Canvas.Pixels[i,j]:= RGB(hasilBiner[i,j]*255, hasilBiner[i,j]*255, hasilBiner[i,j]*255);
          end;
    end;

  for j:=0 to imgSrc.Height-1 do
  begin
    for i:=0 to imgSrc.Width-1 do
    begin
      bmpBinary[i,j] := hasilBiner[i,j];
      if j=0 then
      begin
        bmpR[i,-1] := bmpR[i,j];
        bmpG[i,-1] := bmpG[i,j];
        bmpB[i,-1] := bmpB[i,j];
      end;
      if j=imgSrc.Height-1 then
      begin
        bmpR[i,j+1] := bmpR[i,j];
        bmpG[i,j+1] := bmpG[i,j];
        bmpB[i,j+1] := bmpB[i,j];
      end;
      if i=0 then
      begin
        bmpR[-1,j] := bmpR[i,j];
        bmpG[-1,j] := bmpG[i,j];
        bmpB[-1,j] := bmpB[i,j];
      end;
      if i=imgSrc.Width-1 then
      begin
        bmpR[i+1,j] := bmpR[i,j];
        bmpG[i+1,j] := bmpG[i,j];
        bmpB[i+1,j] := bmpB[i,j];
      end;
    end;
  end;
end;

procedure TForm1.btnErosiClick(Sender: TObject);
var
  i, j, k, l  : integer;
  temp : boolean;
  objek, latar : integer;
begin
  //objek berwarna hitam
  objek := 1;
  latar := 0;

  for j := -1 to 1 do
  begin
    for i := -1 to 1 do
    begin
      SE[i,j] := 1;
    end;
  end;

  for j:=0 to imgSrc.Height-1 do
  begin
    for i:=0 to imgSrc.Width-1 do
    begin
          temp := False;
          for l:=-1 to 1 do
          begin
            for k:=-1 to 1 do
            begin
              if (SE[k,l]>=0) then
              begin
                Temp := Temp OR (bmpBinary[i+k,j+l]=SE[k,l]);
              end;
            end;
          end;
          if temp then
            hasilBiner[i,j] := objek
          else
            hasilBiner[i,j] := latar;
          imgMod.Canvas.Pixels[i,j]:= RGB(hasilBiner[i,j]*255, hasilBiner[i,j]*255, hasilBiner[i,j]*255);
          end;
    end;

  for j:=0 to imgSrc.Height-1 do
  begin
    for i:=0 to imgSrc.Width-1 do
    begin
      bmpBinary[i,j] := hasilBiner[i,j];
      if j=0 then
      begin
        bmpR[i,-1] := bmpR[i,j];
        bmpG[i,-1] := bmpG[i,j];
        bmpB[i,-1] := bmpB[i,j];
      end;
      if j=imgSrc.Height-1 then
      begin
        bmpR[i,j+1] := bmpR[i,j];
        bmpG[i,j+1] := bmpG[i,j];
        bmpB[i,j+1] := bmpB[i,j];
      end;
      if i=0 then
      begin
        bmpR[-1,j] := bmpR[i,j];
        bmpG[-1,j] := bmpG[i,j];
        bmpB[-1,j] := bmpB[i,j];
      end;
      if i=imgSrc.Width-1 then
      begin
        bmpR[i+1,j] := bmpR[i,j];
        bmpG[i+1,j] := bmpG[i,j];
        bmpB[i+1,j] := bmpB[i,j];
      end;
    end;
  end;
end;
end.
