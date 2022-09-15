unit segmentationUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnUpload: TButton;
    btnSave: TButton;
    btnBinary: TButton;
    btnSegmentation: TButton;
    btnGray: TButton;
    imgMod: TImage;
    imgSrc: TImage;
    Label1: TLabel;
    Label2: TLabel;
    openDialog: TOpenDialog;
    saveDialog: TSaveDialog;
    procedure btnGrayClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnUploadClick(Sender: TObject);
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
  bmpR, bmpG, bmpB, bmpBinary: array[0..1000, 0..1000] of integer;

procedure TForm1.btnUploadClick(Sender: TObject);
var
  i, j: integer;
begin
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
      end;
    end;
  end;
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
      imgMod.Canvas.Pixels[x, y] := RGB(gray, gray, gray);
    end;
  end;
end;

end.

