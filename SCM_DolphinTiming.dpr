program SCM_DolphinTiming;

uses
  Vcl.Forms,
  dtfrmExec in 'dtfrmExec.pas' {dtExec},
  dmSCM in 'dmSCM.pas' {SCM: TDataModule},
  dtuSetting in 'dtuSetting.pas',
  XSuperJSON in '..\x-superobject\XSuperJSON.pas',
  XSuperObject in '..\x-superobject\XSuperObject.pas',
  dtfrmBoot in 'dtfrmBoot.pas' {dtBoot},
  Vcl.Themes,
  Vcl.Styles,
  SCMDefines in '..\SCM_SHARED\SCMDefines.pas',
  SCMSimpleConnect in '..\SCM_SHARED\SCMSimpleConnect.pas',
  SCMUtility in '..\SCM_SHARED\SCMUtility.pas',
  exeinfo in '..\SCM_SHARED\exeinfo.pas',
  dmDTData in 'dmDTData.pas' {DTData: TDataModule},
  dtUtils in 'dtUtils.pas',
  dlgSessionPicker in 'dlgSessionPicker.pas' {SessionPicker},
  dtDlgOptions in 'dtDlgOptions.pas' {dlgOptions},
  dtReConstruct in 'dtReConstruct.pas',
  Vcl.PlatformVclStylesActnCtrls in '..\SCM_SHARED\Vcl.PlatformVclStylesActnCtrls.pas',
  dtTreeViewSCM in 'dtTreeViewSCM.pas' {TreeViewSCM},
  dtTreeViewDT in 'dtTreeViewDT.pas' {TreeViewDT},
  dlgDataDebug in 'dlgDataDebug.pas' {DataDebug},
  dlgUserRaceTime in 'dlgUserRaceTime.pas' {UserRaceTime};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10 SlateGray');
  Application.CreateForm(TdtBoot, dtBoot);
  Application.Run;
end.
