program platform;

uses
  Forms,
  main in 'main.pas' {fgame};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Platform';
  Application.CreateForm(Tfgame, fgame);
  Application.Run;
end.
