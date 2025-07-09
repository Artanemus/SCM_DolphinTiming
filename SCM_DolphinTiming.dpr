program SCM_DolphinTiming;

uses
  Vcl.Forms,
  XSuperJSON in '..\x-superobject\XSuperJSON.pas',
  XSuperObject in '..\x-superobject\XSuperObject.pas',
  tdSetting in 'tdSetting.pas',
  Vcl.PlatformVclStylesActnCtrls in '..\SCM_SHARED\Vcl.PlatformVclStylesActnCtrls.pas',
  SCMDefines in '..\SCM_SHARED\SCMDefines.pas',
  SCMSimpleConnect in '..\SCM_SHARED\SCMSimpleConnect.pas',
  frmMain in 'frmMain.pas' {Main},
  uAppUtils in 'uAppUtils.pas',
  DirectoryWatcher in 'DirectoryWatcher.pas',
  Vcl.Themes,
  Vcl.Styles,
  dlgOptions in 'dlgOptions.pas' {Options},
  dlgPostData in 'dlgPostData.pas' {PostData},
  dlgTreeViewData in 'dlgTreeViewData.pas' {TreeViewData},
  dlgTreeViewSCM in 'dlgTreeViewSCM.pas' {TreeViewSCM},
  dlgDataDebug in 'dlgDataDebug.pas' {DataDebug},
  dlgUserRaceTime in 'dlgUserRaceTime.pas' {UserRaceTime},
  SCMUtility in '..\SCM_SHARED\SCMUtility.pas',
  dlgSessionPicker in 'dlgSessionPicker.pas' {SessionPicker},
  dlgExportCSV in 'dlgExportCSV.pas' {ExportCSV},
  uWatchTime in 'uWatchTime.pas',
  tdLogin in 'tdLogin.pas' {Login},
  dlgFDExplorer in 'dlgFDExplorer.pas' {FDExplorer},
  dmIMG in 'dmIMG.pas' {IMG: TDataModule},
  dmSCM in 'dmSCM.pas' {SCM: TDataModule},
  dmTDS in 'dmTDS.pas' {TDS: TDataModule},
  dlgScanOptions in 'dlgScanOptions.pas' {ScanOptions},
  rptReportsSCM in 'rptReportsSCM.pas' {ReportsSCM: TDataModule},
  uNoodle in 'uNoodle.pas',
  uNoodleFrame in 'uNoodleFrame.pas' {NoodleFrame: TFrame},
  uNoodleData in 'uNoodleData.pas',
  uNoodleInfo in 'uNoodleInfo.pas' {NoodleInfo},
  dlgSwimClubPicker in 'dlgSwimClubPicker.pas' {SwimClubPicker},
  dlgAbout in 'dlgAbout.pas' {About},
  tdResultsCTSFile in 'tdResultsCTSFile.pas',
  uExport_CSV in 'uExport_CSV.pas',
  tdResultsCTS in 'tdResultsCTS.pas',
  dtReConstruct in 'ReConstruct\dtReConstruct.pas',
  dtReConstructDlg in 'ReConstruct\dtReConstructDlg.pas' {ReConstructDlg};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10 SlateGray');
  Application.CreateForm(TMain, Main);
  Application.Run;
end.
