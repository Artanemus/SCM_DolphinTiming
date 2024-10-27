unit dtfrmExec;

{
(Typical Meet Manager)  ... will read the data into the proper lanes.
- If there is one watch per lane, that time will also be placed in the result
column.
- If there are 3 watch times for a given lane, the middle time will be placed in
  the result column.
- If there are two watches for a given lane, the average will be computed and
  placed in the result column. Please note that if there is .3 or more seconds
  difference between the two watch times, the average result time will NOT be
  computed and a yellow line will show for this lane. Decide whether to throw out one
  of the watch times if you determine one of them is way off. If you are OK with the
  two times, then click Ctrl-K to display the watch averaging menu and it will compute
  the average for you and place it in the result column. If one of the times is no good,
  delete it and use Ctrl-K, or simply type in the time of the one good watch.
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.ControlList, Vcl.VirtualImage, Vcl.Buttons, Vcl.BaseImageCollection,
  Vcl.ImageCollection, Vcl.Menus, dmSCM, dmDTData, dtuSetting, FireDAC.Comp.Client,
  Data.DB, Vcl.Grids, Vcl.DBGrids, SCMDefines, System.StrUtils, AdvUtil, AdvObj,
  BaseGrid, AdvGrid, DBAdvGrid, System.Actions, Vcl.ActnList, Vcl.ToolWin,
  Vcl.ActnMan, Vcl.ActnCtrls, Vcl.ActnMenus, Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ExtDlgs, FireDAC.Stan.Param;

type
  TdtExec = class(TForm)
    btnPrevEvent: TButton;
    btnNextEvent: TButton;
    btnPrevDTFile: TButton;
    btnNextDTFile: TButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Button1: TButton;
    btnRefresh: TButton;
    sbtnSync: TSpeedButton;
    vimgStrokeBug: TVirtualImage;
    vimgHeatStatus: TVirtualImage;
    lblHeatNum: TLabel;
    lblEventDetails: TLabel;
    lblDTFileName: TLabel;
    vimgHeatNum: TVirtualImage;
    vimgRelayBug: TVirtualImage;
    scmGrid: TDBAdvGrid;
    actnManager: TActionManager;
    actnMenuBar: TActionMainMenuBar;
    actnSetDTFolder: TAction;
    actnPickSession: TAction;
    actnCreateDTCSV: TAction;
    FileSaveDlgCSV: TFileSaveDialog;
    lblMeters: TLabel;
    advgrid1: TDBAdvGrid;
    sbtnLoadDO3: TSpeedButton;
    sbtnLoadDO4: TSpeedButton;
    PickDTFolderDlg: TFileOpenDialog;
    procedure actnCreateDTCSVExecute(Sender: TObject);
    procedure actnCreateDTCSVUpdate(Sender: TObject);
    procedure actnPickSessionExecute(Sender: TObject);
    procedure actnSetDTFolderExecute(Sender: TObject);
    procedure btnNextEventClick(Sender: TObject);
    procedure btnPrevEventClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sbtnLoadDO3Click(Sender: TObject);
  private
    { Private declarations }
    FConnection: TFDConnection;
    fDolphinFolder: string;
    procedure UpdateEventDetailsLabel();
    procedure UpdateCaption();
    procedure SetSession(ASessionID: integer);

  protected
    procedure MSG_AfterHeatScroll(var Msg: TMessage); message SCM_HEATSCROLL;
    procedure MSG_AfterEventScroll(var Msg: TMessage); message SCM_EVENTSCROLL;


  public
    { Public declarations }
    procedure Prepare(AConnection: TFDConnection; aSessionID: Integer = 0);
    property DolphinFolder: string read FDolphinFolder write FDolphinFolder;

const
  AcceptedTimeKeeperDeviation = 0.3;

  end;

var
  dtExec: TdtExec;

implementation

{$R *.dfm}

uses dtUtils, UITypes, DateUtils ,dlgSessionPicker;

procedure TdtExec.actnCreateDTCSVExecute(Sender: TObject);
var
  fn: TFileName;
begin
  if FileSaveDlgCSV.Execute then
    fn := FileSaveDlgCSV.FileName
  else
    Exit; // User cancelled.
  // Build CSV Event Data and save to file.
  BuildCSVEventData(fn);
end;

procedure TdtExec.actnCreateDTCSVUpdate(Sender: TObject);
begin
  if Assigned(DTData) then
  begin
    if not TAction(Sender).Enabled then
      TAction(Sender).Enabled := true;
  end
  else
      TAction(Sender).Enabled := false;
end;

procedure TdtExec.actnPickSessionExecute(Sender: TObject);
var
  dlg: TSessionPicker;
  mr: TModalResult;
begin
  dlg := TSessionPicker.Create(Self);
  // the picker will locate to the given session id.
  dlg.SessionID := DTData.qrySession.FieldByName('SessionID').AsInteger;
  mr := dlg.ShowModal;
  if IsPositiveResult(mr) and (dlg.SessionID > 0) then
    SetSession(dlg.SessionID);
  dlg.Free;
  UpdateCaption;
end;

procedure TdtExec.actnSetDTFolderExecute(Sender: TObject);
var
  fn: TFileName;
begin
  if PickDTFolderDlg.Execute then
    fn := PickDTFolderDlg.FileName
  else
    Exit; // User cancelled.
  // Make the path persistent in JSON.
  fDolphinFolder := fn;
  // SavePreferencesToJSON.
end;

procedure TdtExec.btnNextEventClick(Sender: TObject);
begin
  if (GetKeyState(VK_CONTROL) < 0) then
  begin
      DTData.dsEvent.DataSet.next;
      DTData.dsHeat.DataSet.First;
  end
  else
  begin
    if DTData.dsHeat.DataSet.EOF then
    begin
      DTData.dsEvent.DataSet.next;
      DTData.dsHeat.DataSet.First;
    end
    else
      DTData.dsHeat.DataSet.next;
  end;
end;

procedure TdtExec.btnPrevEventClick(Sender: TObject);
begin
  if (GetKeyState(VK_CONTROL) < 0) then
  begin
      DTData.dsEvent.DataSet.prior;
      DTData.dsHeat.DataSet.first;
  end
  else
  begin
  if DTData.dsHeat.DataSet.BOF then
  begin
      DTData.dsEvent.DataSet.prior;
      DTData.dsHeat.DataSet.Last;
    end
    else
      DTData.dsHeat.DataSet.prior;
  end;
end;

procedure TdtExec.FormCreate(Sender: TObject);
begin
  { test for and connect to DTData}
  // C R E A T E   T H E   D A T A M O D U L E .
  if NOT Assigned(DTData) then
    DTData := TDTData.Create(Self);
end;

procedure TdtExec.MSG_AfterEventScroll(var Msg: TMessage);
var
  i: Integer;
begin
  // update EVENT UI elements.
  if Assigned(DTData) AND DTData.IsActive then
  begin
    UpdateEventDetailsLabel;
    i := DTData.qryEvent.FieldByName('StrokeID').AsInteger;
    case i of
      1:
        vimgStrokeBug.ImageName := 'StrokeFS';
      2:
        vimgStrokeBug.ImageName := 'StrokeBS';
      3:
        vimgStrokeBug.ImageName := 'StrokeBK';
      4:
        vimgStrokeBug.ImageName := 'StrokeBF';
      5:
        vimgStrokeBug.ImageName := 'StrokeIM';
    else
      vimgStrokeBug.ImageIndex := -1;

    end;
    i := DTData.qryDistance.FieldByName('EventTypeID').AsInteger;
    case i of
      2:
        vimgRelayBug.ImageName := 'RELAY_DOT'; // RELAY.
    else
      vimgRelayBug.ImageIndex := -1; // INDV or Swim-O-Thon.
    end;
    lblMeters.Caption := UpperCase(DTData.qryDistance.FieldByName('Caption').AsString);
  end;
end;

procedure TdtExec.MSG_AfterHeatScroll(var Msg: TMessage);
var
i: integer;
begin
  // update HEATUI elements.
  if Assigned(DTData) AND DTData.IsActive then
  begin
    UpdateEventDetailsLabel; // append heat number to label
    i := DTData.qryHeat.FieldByName('HeatNum').AsInteger;
    if i = 0 then
      lblHeatNum.Caption := ''
    else
      lblHeatNum.Caption := IntToStr(i);
    i := DTData.qryHeat.FieldByName('HeatStatusID').AsInteger;
    case i of
    1:
      vimgHeatStatus.ImageName := 'HeatOpen';
    2:
      vimgHeatStatus.ImageName := 'HeatRaced';
    3:
      vimgHeatStatus.ImageName := 'HeatClosed';
    else
      vimgHeatStatus.ImageIndex := -1;
    end;
  end;
end;

procedure TdtExec.Prepare(AConnection: TFDConnection; aSessionID: Integer);
begin
  FConnection := AConnection;
  if Assigned(DTData) then
  begin
    DTData.Connection := FConnection;
    DTData.SessionID := aSessionID;
    DTData.ActivateData;
  end;
  UpdateCaption;
end;

procedure TdtExec.sbtnLoadDO3Click(Sender: TObject);
begin
  if DirectoryExists(fDolphinFolder) then
    ExtractDataDO3Files(fDolphinFolder)
  else
    MessageBox(0, PChar('The Dolphin Timing folder could not be found.'+#13+#10+'Use the File menu to setup the folder''s location.'), PChar('Missing DT Folder '), MB_ICONERROR or MB_OK);
end;

procedure TdtExec.SetSession(ASessionID: integer);
begin
    DTData.qrySession.DisableControls;
    DTData.qrySession.Close;
    DTData.qrysession.ParamByName('SESSIONID').AsInteger := ASessionID;
    DTData.qrysession.Prepare;
    DTData.qrysession.Open;
    DTData.qrySession.EnableControls;
end;

procedure TdtExec.UpdateCaption;
var
s, s2: string;
i: integer;
v: variant;
dt: TDateTime;
begin
  if not DTData.qrysession.Active then
    Caption := 'SwimClubMeet - Dolphin Timing. ' // error ...
  else
  begin
    s2 := 'SwimClubMeet';
    v := DTData.qrysession.FieldByName('SessionStart').AsVariant;
    if not VarIsNull(v) then
    begin
      dt := TDateTime(v);
      s2 := s2 + ' - Session: ' + DateToStr(dt);
    end;
    s := DTData.qrysession.FieldByName('Caption').AsString;
    if Length(s) > 0 then s2 := s2 + ' ' + s;
    Caption := s2;
  end;
end;

procedure TdtExec.UpdateEventDetailsLabel;
var
i: integer;
s, s2: string;
begin
    i := DTData.qryEvent.FieldByName('EventNum').AsInteger;
    if i = 0 then
      lblEventDetails.Caption := ''
    else
      begin
        // build the event detail string...  Distance Stroke (OPT: Caption)
        s := DTData.qryDistance.FieldByName('Caption').AsString;
        s := s + ' ' + DTData.qryStroke.FieldByName('Caption').AsString;
        // event description - entered in core app's grid extension mode.
        s2 := DTData.qryEvent.FieldByName('Caption').AsString;
        if (length(s2) > 0) then
        begin
          if (length(s2) > 17) then
            s2 := s2.Substring(0, 14) + '...';
          s := s +  ' - ' +  s2;
        end;
        // heat number...
        i:=DTData.qryHeat.FieldByName('HeatNum').AsInteger;
        s := s + ' - Heat: ' + IntToStr(i);
        if Length(s) > 0 then
          lblEventDetails.Caption := s;
      end;
end;

end.
