unit dtTreeViewDT;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.StorageBin, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  dtUtils;

type

  TTVDTData = class(TObject)
  private
    FSessionID: integer;
    FEventID: integer;
    FHeatID: integer;
    FFileName: string;
  public
    constructor Create(AFileName: string);
    property SessionID: Integer read FSessionID write FSessionID;
    property FileName: string read FFileName write FFileName;
  end;

type
  TTreeViewDT = class(TForm)
    btnCancel: TButton;
    btnClose: TButton;
    dsDT: TDataSource;
    pnlFooter: TPanel;
    tblDT: TFDMemTable;
    tblDTCreatedDT: TDateTimeField;
    tblDTDTID: TIntegerField;
    tblDTfEvent: TIntegerField;
    tblDTfGender: TStringField;
    tblDTfGUID: TStringField;
    tblDTfHeat: TIntegerField;
    tblDTFileName: TStringField;
    tblDTfSession: TIntegerField;
    TV: TTreeView;
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    FSelectedEventID: integer;
    FSelectedFileName: string;
    FSelectedHeatID: integer;
    FSelectedSessionID: integer;
    procedure FreeTreeViewData;
  end;

var
  TreeViewDT: TTreeViewDT;

implementation

{$R *.dfm}

{ TTVDTData }

constructor TTVDTData.Create(AFileName: string);
var
Gender, RaceID: string;
begin
    FFileName := AFileName;
    // if DO4 type ....
    ExtractFileNameFieldsDO4(FFileName, FSessionID, FEventID, FHeatID,
    Gender, RaceID);
end;

{ TTreeViewDT }

procedure TTreeViewDT.btnCancelClick(Sender: TObject);
begin
    fSelectedSessionID := 0;
    FSelectedEventID := 0;
    FSelectedHeatID := 0;
    fSelectedFileName := '';
    ModalResult := mrCancel;
end;

procedure TTreeViewDT.FormCreate(Sender: TObject);
begin
    FSelectedSessionID := 0;
    FSelectedEventID := 0;
    FSelectedHeatID := 0;
    FSelectedFileName := '';;
    TV.Items.Clear; // remove all design-time layout items.
end;

procedure TTreeViewDT.FormDestroy(Sender: TObject);
begin
  FreeTreeViewData;
  TV.Items.Clear;
end;

procedure TTreeViewDT.FormKeyDown(Sender: TObject; var Key: Word; Shift:
    TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    fSelectedSessionID := 0;
    FSelectedEventID := 0;
    FSelectedHeatID := 0;
    fSelectedFileName := '';
    ModalResult := mrCancel;
  end;
end;

procedure TTreeViewDT.FreeTreeViewData;
var
ident: TTVDTData;
Node: TTreeNode;
begin
  for Node in TV.Items do
  begin
    ident := Node.Data;
    if Assigned(ident) then
    begin
      ident.Free;
      Node.Data := nil;
    end;
  end;
end;

end.
