unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls;

type
  TAbout = class(TForm)
    Label1: TLabel;
    Bevel1: TBevel;
    Image1: TImage;
    Label2: TLabel;
    Label4: TLabel;
    Bevel2: TBevel;
    Button1: TButton;
    Label5: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label3: TLabel;
    Label6: TLabel;
    Label9: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  About: TAbout;

implementation

{$R *.dfm}

procedure TAbout.Button1Click(Sender: TObject);
begin
  Close;
end;

end.
