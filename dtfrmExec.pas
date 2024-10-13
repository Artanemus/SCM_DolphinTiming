unit dtfrmExec;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.ControlList, Vcl.VirtualImage, Vcl.Buttons, Vcl.BaseImageCollection,
  Vcl.ImageCollection, Vcl.Menus, dmSCM, dmDTData, dtuSetting, FireDAC.Comp.Client,
  Data.DB, Vcl.Grids, Vcl.DBGrids, SCMDefines, System.StrUtils, AdvUtil, AdvObj,
  BaseGrid, AdvGrid, DBAdvGrid;

type
  TdtExec = class(TForm)
    btnPrevEvent: TButton;
    btnNextEvent: TButton;
    btnPrevDTFile: TButton;
    btnNextDTFile: TButton;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    File2: TMenuItem;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Setup1: TMenuItem;
    Button1: TButton;
    btnRefresh: TButton;
    dbgridSCM: TDBGrid;
    dbgridDT: TDBGrid;
    sbtnSync: TSpeedButton;
    vimgStrokeBug: TVirtualImage;
    vimgHeatStatus: TVirtualImage;
    lblHeatNum: TLabel;
    lblEventDetails: TLabel;
    lblDTFileName: TLabel;
    vimgHeatNum: TVirtualImage;
    vimgRelayBug: TVirtualImage;
    scmGrid: TDBAdvGrid;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FConnection: TFDConnection;

  protected
    procedure MSG_AfterHeatScroll(var Msg: TMessage); message SCM_HEATSCROLL;
    procedure MSG_AfterEventScroll(var Msg: TMessage); message SCM_EVENTSCROLL;


  public
    { Public declarations }
    procedure Prepare(AConnection: TFDConnection; aSessionID: Integer = 0);

  end;

var
  dtExec: TdtExec;

implementation

{$R *.dfm}

procedure TdtExec.FormCreate(Sender: TObject);
begin
  { test for and connect to DTData}
  // C R E A T E   T H E   D A T A M O D U L E .
  if NOT Assigned(DTData) then
    DTData := TDTData.Create(Self);
end;

procedure TdtExec.MSG_AfterEventScroll(var Msg: TMessage);
var
i: integer;
s, s2: string;
begin
  // update EVENT UI elements.
  if Assigned(DTData) AND DTData.IsActive then
  begin
    i := DTData.qryEvent.FieldByName('EventNum').AsInteger;
    if i = 0 then
      lblEventDetails.Caption := ''
    else
      begin
        // build the event detail string...  Distance Stroke (OPT: Caption)
        s := DTData.qryDistance.FieldByName('Caption').AsString;
        s := s + ' ' + DTData.qryStroke.FieldByName('Caption').AsString;
        s2 := DTData.qryEvent.FieldByName('Caption').AsString;
        if (length(s2) > 0) then
        begin
          if (length(s2) > 17) then
            s2 := s2.Substring(0, 14) + '...';
          s := s +  ' - ' +  s2;
        end;
        if Length(s) > 0 then
          lblEventDetails.Caption := s;
      end;
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

  end;
end;

procedure TdtExec.MSG_AfterHeatScroll(var Msg: TMessage);
var
i: integer;
begin
  // update HEATUI elements.
  if Assigned(DTData) AND DTData.IsActive then
  begin
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
end;

end.
