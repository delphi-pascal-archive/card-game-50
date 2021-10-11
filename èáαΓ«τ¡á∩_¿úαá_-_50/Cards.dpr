program Cards;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Main},
  Unit3 in 'Unit3.pas' {About},
  Unit2 in 'Unit2.pas' {Option};

{$R WindowsXp.res}
{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
