unit dtTreeViewDT;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.StorageBin, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  dtUtils, dmDTData, Datasnap.DBClient, Datasnap.Provider, dtuSetting;

type

  TTVDTData = class(TObject)
  private
    { IDENTIFIER :
      node level 0 : SessionID,
      node level 1 : EventID,
      node level 2 : HeatID.
    }
    FID: integer;
    { stores - EventNum or HeatNum }
    FValue: integer;

    // Is filename REQUIRED?
    // Only node level 2 stores a filename.
    FFileName: string;
  public
    constructor Create(AID: integer; AValue: integer);
    property ID: Integer read FID write FID;
    property FileName: string read FFileName write FFileName;
  end;

type
  TTreeViewDT = class(TForm)
    btnCancel: TButton;
    btnClose: TButton;
    pnlFooter: TPanel;
    TV: TTreeView;
    procedure btnCancelClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure LoadFromSettings; // JSON Program Settings
    procedure LoadSettings; // JSON Program Settings
    procedure LocateTVSessionID(ASessionID: integer);
    procedure LocateTVEventID(AEventID: integer);
    procedure LocateTVHeatID(AHeatID: integer);
    procedure TVDblClick(Sender: TObject);


  private
    { Private declarations }
    FSelectedSessionID: integer;
    FSelectedEventID: integer;
    FSelectedHeatID: integer;
    FSelectedFileName: string;
    fPrecedence: dtPrecedence;
    procedure FreeTreeViewData;
    procedure PopulateTree;

  public
    procedure Prepare(ASessionID, AEventID, AHeatID: integer);
    property SelectedSessionID: integer read FSelectedSessionID;
    property SelectedEventID: integer read FSelectedEventID;
    property SelectedHeatID: integer read FSelectedHeatID;


  end;

var
  TreeViewDT: TTreeViewDT;

implementation

{$R *.dfm}


{ TTVDTData }

constructor TTVDTData.Create(AID: integer; AValue: integer);
begin
    FID := AID; // SessionID, EventID or HeatID.
    FValue := AValue; // zero, EventNum or HeatNum.
end;

{ TTreeViewDT }

procedure TTreeViewDT.btnCancelClick(Sender: TObject);
begin
    FSelectedSessionID := 0;
    FSelectedEventID := 0;
    FSelectedHeatID := 0;
    FSelectedFileName := '';
    ModalResult := mrCancel;
end;

procedure TTreeViewDT.btnCloseClick(Sender: TObject);
var
node, nodeSess, nodeEv, nodeHt, nodeLane: TTreeNode;
obj : TTVDTData;
begin
  FSelectedSessionID := 0;
  FSelectedEventID := 0;
  FSelectedHeatID := 0;

  node := TV.Selected;

  if (node <> nil) then
  begin
    case node.level of
    0: { ROOT NODE - LEVEL 0 - SESSION}
      begin
        obj := node.Data;
        if (obj <> nil) then
        begin
          // S e s s i o n .
          FSelectedSessionID := obj.FID;
          nodeEv := node.getFirstChild;
          if (nodeEv <> nil) then
          begin
            obj := nodeEv.Data;
            if (obj <> nil) then
            begin
              // E v e n t .
              FSelectedEventID := obj.FID;
              nodeHt := nodeEv.getFirstChild;
              if (nodeHt <> nil) then
              begin
                obj := nodeHt.Data;
                if (obj <> nil) then
                begin
                  // H e a t .
                  FSelectedHeatID := obj.FID;
                end;
              end;
            end;
          end;
        end;
      end;

    1: { LEVEL 1 NODE - EVENT}
       begin
        obj := node.Data;
        if (obj <> nil) then
        begin
          // E v e n t .
          FSelectedEventID := obj.FID;
          if (node.Parent <> nil) then
          begin
            nodeSess := TTreeNode(node.Parent);
            obj := nodeSess.Data;
            if (obj <> nil) then
            begin
              // S e s s i o n .
              FSelectedSessionID := obj.FID;
            end;
          end;
          nodeHt := node.getFirstChild;
          if (nodeHt <> nil) then
          begin
            obj := nodeHt.Data;
            if (obj <> nil) then
            begin
              // H e a t .
              FSelectedHeatID := obj.FID;
            end;
          end;
        end;
      end;

    2: { LEVEL 2 NODE - HEAT}
       begin
        obj := node.Data;
        if (obj <> nil) then
        begin
          // H e a t .
          FSelectedHeatID := obj.FID;
          if (node.Parent <> nil) then
          begin
            nodeEv := TTreeNode(node.Parent);
            obj := nodeEv.Data;
            if (obj <> nil) then
            begin
              // E v e n t .
              FSelectedEventID := obj.FID;
              if (nodeEv.Parent <> nil) then
              begin
                nodeSess := TTreeNode(nodeEv.Parent);
                obj := nodeSess.Data;
                if (obj <> nil) then
                begin
                  // S e s s i o n .
                  FSelectedSessionID := obj.FID;
                end;
              end;
            end;
          end;
        end;
      end
    end;
  end;

  ModalResult := mrOk;
end;

procedure TTreeViewDT.FormCreate(Sender: TObject);
begin
    FSelectedSessionID := 0;
    FSelectedEventID := 0;
    FSelectedHeatID := 0;
    FSelectedFileName := '';;
    // remove all design-time layout items.
    TV.Items.Clear;
    // get the dtPrecedence from the JSON settings file.
    LoadFromSettings;
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

procedure TTreeViewDT.LoadFromSettings;
begin
  if not FileExists(Settings.GetDefaultSettingsFilename()) then
  begin
    ForceDirectories(Settings.GetSettingsFolder());
    Settings.SaveToFile();
  end;
  Settings.LoadFromFile();
  LoadFromSettings();
end;

procedure TTreeViewDT.LoadSettings;
begin
  fPrecedence := Settings.DolphinPrecedence;
end;

procedure TTreeViewDT.LocateTVEventID(AEventID: integer);
var
  NodeSess, NodeEv: TTreeNode;
  obj : TTVDTData;
  found : boolean;
begin
  found := false;
  NodeSess := TV.Items.GetFirstNode;
  while NodeSess <> nil do
  begin
    NodeEv := NodeSess.GetFirstChild;
    while NodeEv <> nil do
    begin
      obj := NodeEv.Data;
      if (obj <> nil) and (obj.FID = AEventID) then
      begin
        // Expand NodeSess if it's collapsed
        if not NodeSess.Expanded then
          NodeSess.Expanded := True;
        TV.Selected := NodeEv;
        NodeEv.Focused := true;
        break;
      end;
      NodeEv := NodeEv.GetNextSibling;
    end;
    if Found  then break;
    NodeSess := NodeSess.GetNextSibling;
  end;
end;

procedure TTreeViewDT.LocateTVHeatID(AHeatID: integer);
var
  NodeSess, NodeEv, NodeHt: TTreeNode;
  obj : TTVDTData;
  found : boolean;
begin
  found := false;
  NodeSess := TV.Items.GetFirstNode;
  while NodeSess <> nil do
  begin
    NodeEv := NodeSess.GetFirstChild;
    while NodeEv <> nil do
    begin
      NodeHt := NodeEv.GetFirstChild;
      while (NodeHt <> nil) do
      begin
        obj := NodeHt.Data;
        if (obj <> nil) and (obj.FID = AHeatID) then
        begin
          // Expand the sess node, if it's collapsed.
          if not NodeSess.Expanded then
            NodeSess.Expanded := True;
          // Expand the ev node, if it's collapsed.
          if not NodeEv.Expanded then
            NodeEv.Expanded := True;

          TV.Selected := NodeHt;
          NodeHt.Focused := true;
          found := true;
          break;
        end;
        NodeEv := NodeHt.GetNextSibling;
      end;
      if Found  then break;
      NodeEv := NodeEv.GetNextSibling;
    end;
    if Found  then break;
    NodeSess := NodeSess.GetNextSibling;
  end;
end;

procedure TTreeViewDT.LocateTVSessionID(ASessionID: integer);
var
  NodeSess, NodeEv: TTreeNode;
  obj : TTVDTData;
begin
  NodeSess := TV.Items.GetFirstNode;
  while NodeSess <> nil do
  begin
    obj := NodeSess.Data;
    if (obj <> nil) and (obj.FID = ASessionID) then
    begin
      NodeEv := NodeSess.GetFirstChild;
      if (NodeEv <> nil) then
      begin
        // Expand the parent NodeSess if it's collapsed.
        if not NodeEv.Parent.Expanded then
          NodeEv.Parent.Expanded := True;
        // Focus on first heat in event.
        TV.Selected := NodeEv;
        NodeEv.Focused := true;
        break;
      end;
    end;
    NodeSess := NodeSess.GetNextSibling;
  end;
end;

procedure TTreeViewDT.PopulateTree;
var
  nodeSess, nodeEv, nodeHt: TTreeNode;
  s: string;
  i, id, storeSess, storeEv, storeHt: integer;
  ident: TTVDTData;

begin
  { p o p u l a t e   t h e   T r e e V i e w . . .
    TABLES HAVE MASTER-DETAIL RELATIONSHIP
  }
  DTData.tblDTEntrant.DisableControls;
  DTData.tblDTHeat.DisableControls;
  DTData.tblDTEvent.DisableControls;
  DTData.tblDTSession.DisableControls;

  storeSess := DTData.tblDTSession.FieldByName('SessionID').AsInteger;
  storeEv := DTData.tblDTEvent.FieldByName('EventID').AsInteger;
  storeHt := DTData.tblDTHeat.FieldByName('HeatID').AsInteger;

  // R O O T   N O D E    -   LEVEL 0 - S E S S I O N   . . .
  DTData.tblDTSession.First;
  while not DTData.tblDTSession.Eof do
  begin
    s := DTData.tblDTSession.FieldByName('Caption').AsString;
    if fPrecedence = dtPrecFileName then
      i := DTData.tblDTSession.FieldByName('fnSessionNum').AsInteger
    else
      i := DTData.tblDTSession.FieldByName('SessionNum').AsInteger;
    id := DTData.tblDTSession.FieldByName('SessionID').AsInteger;

    { CREATE NodeSess : EventID, EventNum.}
    ident := TTVDTData.Create(id, i); // object to hold event and even number.
    // Level 0 .
    NodeSess := TV.Items.AddObject(nil, s, ident); // assign data ptr.

    // ------------------------------------------------------------
    // Level 1  -   E V E N T S  ...  SESSION CHILD NODES.
    DTData.tblDTEvent.First;
    while not DTData.tblDTEvent.Eof do
    begin
      s := DTData.tblDTEvent.FieldByName('Caption').AsString;
      if fPrecedence = dtPrecFileName then
        i := DTData.tblDTEvent.FieldByName('fnEventNum').AsInteger
      else
        i := DTData.tblDTEvent.FieldByName('EventNum').AsInteger;
      id := DTData.tblDTEvent.FieldByName('EventID').AsInteger;

      { CREATE nodeEv : EventID, EventNum.}
      ident := TTVDTData.Create(id, i);
      nodeEv := TV.Items.AddChildObject(NodeSess, s, ident);

      // ICON ORDERED heat numbers ...
      if (i > 9) then
        nodeEv.ImageIndex := 0
      else
        // heat number icons 1 thru 9..
        nodeEv.ImageIndex := i + 14;
      nodeEv.SelectedIndex := nodeEv.ImageIndex;

      // ------------------------------------------------------------
      // Level 2  -   H E A T S  ...   EVENT CHILD NODES.
      DTData.tblDTHeat.First;
      while not DTData.tblDTHeat.Eof do
      begin
        s := DTData.tblDTHeat.FieldByName('Caption').AsString;
        if fPrecedence = dtPrecFileName then
          i := DTData.tblDTHeat.FieldByName('fnHeatNum').AsInteger
        else
          i := DTData.tblDTHeat.FieldByName('HeatNum').AsInteger;
        id := DTData.tblDTHeat.FieldByName('HeatID').AsInteger;

        { CREATE nodeHt : HeatID, HeatNum.}
        ident := TTVDTData.Create(id, i);
        nodeHt := TV.Items.AddChildObject(NodeEv, s, ident);

        // ICON ORDERED heat numbers ...
        if (i > 9) then
          nodeHt.ImageIndex := 0
        else
          // heat number icons 1 thru 9..
          nodeHt.ImageIndex := i + 14;
        nodeHt.SelectedIndex := nodeHt.ImageIndex;
        DTData.tblDTHeat.Next;
      end;
      DTData.tblDTEvent.Next;
    end;
    // ------------------------------------------------------------
    DTData.tblDTSession.Next;
  end;

  // restore location
  if DTData.LocateDTSessionID(storeSess) then
    if DTData.LocateDTEventID(storeEv) then
      DTData.LocateDTHeatID(storeht);

  DTData.tblDTSession.EnableControls;
  DTData.tblDTEvent.EnableControls;
  DTData.tblDTHeat.EnableControls;
  DTData.tblDTEntrant.EnableControls;


end;


procedure TTreeViewDT.Prepare(ASessionID, AEventID, AHeatID: integer);
var
  node: TTreeNode;
begin
  if not Assigned(DTData) then exit;
  if not DTData.IsActive then exit;
  // File the tree view with nodes deom the Dolphin Timing data tables.
  PopulateTree;
  // Attempt to cue-to-node ... order is important.
  if (AHeatID <> 0) then
    LocateTVHeatID(AHeatID)
  else if (AEventID <> 0) then
    LocateTVEventID(AEventID)
  else if (ASessionID <> 0) then
    LocateTVSessionID(ASessionID)
  else
  begin
    node := TV.Items.GetFirstNode;
    if (node <> nil) then
      TV.Select(Node);
  end;
end;

procedure TTreeViewDT.TVDblClick(Sender: TObject);
begin
  btnClose.Click;
end;

end.
