unit umthread;

{$mode objfpc}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, TAGraph, TASeries, Math;

type

  vec2 = record
    x,y:real;
    public
    constructor Init(vx,vy:real);
    procedure Setup(vx,vy:real);
  end;

  TThrClass = class (TThread)
    myPstate:integer;
    done:boolean;
    mymin:vec2;
    tx1,tx2,ta,tb,tc:real;
    procedure Execute; Override;
  end;

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Chart1: TChart;
    edN: TEdit;
    edX1: TEdit;
    edX2: TEdit;
    edA: TEdit;
    edB: TEdit;
    edC: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Memo1: TMemo;
    Panel1: TPanel;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  processstate:integer;
  demx1,demx2:real;
  demA,demB,demC:real;
  demn:integer;

  mins:array of vec2;
  threads:array of TThrClass;

implementation

{$R *.lfm}

function calcData(a,b,c,x1,x2:real;n:integer;pstate:PInteger):vec2; forward;
procedure drawCharts; forward;
{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  demx1:=strtofloat(edX1.Text);
  demx2:=strtofloat(edX2.Text);
  demn:= strtoint(edN.Text);
  demA:=strtofloat(edA.Text);
  demB:=strtofloat(edB.Text);
  demC:=strtofloat(edC.Text);
  setlength(threads,Length(threads)+1);
  threads[Length(threads)-1]:=TThrClass.Create(true);
  threads[Length(threads)-1].Start;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  Memo1.Clear;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var i,l:integer;
begin
  Memo1.Clear;
  l:=Length(threads);
  if l>0 then
  for i:=0 to l-1 do
  begin
    if threads[i].done then
    begin
      Memo1.Lines.Add('Thread '+inttostr(i)+': min = '+floattostr(threads[i].mymin.y));
    end
    else
    begin
      Memo1.Lines.Add('Thread '+inttostr(i)+': done '+inttostr(threads[i].myPstate)+'%');
    end;
  end;
  drawCharts;
end;

constructor vec2.Init(vx,vy:real);
begin
  x:=vx; y:=vy;
end;

procedure vec2.Setup(vx,vy:real);
begin
  x:=vx; y:=vy;
end;

procedure TThrClass.Execute;
var mmin:vec2;
begin
  tx1:=demx1; tx2:=demx2;
  ta:=dema; tb:=demb; tc:=demc;
  done:=false;
  mmin:=calcData(ta,tb,tc,tx1,tx2,demn,@myPstate);
  setlength(mins,Length(mins)+1);
  mymin:=mmin;
  mins[high(mins)]:=mmin;
  done:=true;
end;

function calcFunc(a,b,c,x:real):real;
begin
  result:=a*power(x,2)+b*x+c;
end;

function calcData(a,b,c,x1,x2:real;n:integer;pstate:PInteger):vec2;
var i:integer;
    d:real;
    stp:real;
    cx,cy:real;
    min:vec2;
begin
  d:=x2-x1; stp:=d/n;
  cx:=x1;
  cy:=calcFunc(a,b,c,cx);
  min.Init(cx,cy);
  for i:=0 to n-1 do
  begin
    cx:=x1+stp*i;
    cy:=calcFunc(a,b,c,cx);
    if (cy<min.y) then min.Setup(cx,cy);
    pstate^:=round(((stp*i)/d)*100);
  end;
  Result:=min;
end;

procedure drawCharts;
var i,j,l:integer;
    lines:array of TLineSeries;
    stp:real;
begin
  l:=Length(threads);
  SetLength(lines,0);
  if (l>0) then
  begin
    for i:=0 to l-1 do
    begin
      Form1.Chart1.Series.Clear;
      SetLength(lines,l);
      for j:=0 to 19 do
      begin
        lines[i]:=TLineSeries.Create(Form1);
        TLineSeries(lines[i]).LinePen.Color:=clRed;
        TLineSeries(lines[i]).LineType:=ltFromPrevious;
        stp:=(threads[i].tx2-threads[i].tx1)/20;
        lines[i].AddXY(
          threads[i].tx1+stp*j,
          calcFunc(threads[i].ta,threads[i].tb,threads[i].tc,
                   threads[i].tx1+stp*j)
                       );
      end;
      Form1.Chart1.AddSeries(lines[i]);
    end;
  end;
end;

end.

