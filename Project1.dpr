program Project1;

uses
  Vcl.Forms,
  MainUnit in 'MainUnit.pas' {fmMain},
  ProgressFormUnit in 'ProgressFormUnit.pas' {fmProgress},
  UtilitesUnit in 'UtilitesUnit.pas',
  CopyThreadUnit in 'CopyThreadUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Тестовое задание для НавиФарм';
  Application.CreateForm(TfmMain, fmMain);
  Application.CreateForm(TfmProgress, fmProgress);
  Application.Run;
end.
