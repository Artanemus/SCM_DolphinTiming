unit dtTreeViewSCM;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, dmDTData, Vcl.StdCtrls,
  Vcl.ExtCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, dmSCM, System.Generics.Collections;

type

  TIdentData = class(TObject)
  private
    FID: integer; // EventID or HeatID - rootNode or SubNode
    FValue: Integer;  // EventNum or HeatNum - rootNode or SubNode
  public
    constructor Create(AID: integer; AValue: Integer);
    property Value: Integer read FValue write FValue;
    property ID: Integer read FID write FID;
  end;


type
  TTreeViewSCM = class(TForm)
    TreeViewSCM: TTreeView;
    pnlFooter: TPanel;
    btnClose: TButton;
    qryEvent: TFDQuery;
    qryHeat: TFDQuery;
    dsEvent: TDataSource;
    dsHeat: TDataSource;
    btnCancel: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FConnection: TFDConnection;
    FSessionID: integer;
    IdentList: TList<TIdentData>;
    FSelectedEventID: integer;
    FSelectedHeatID: integer;
    procedure PopulateTree;
    procedure LocateTreeItem(EventNum, HeatNum: integer);
    procedure LocateEventID(AEventID: integer);
    procedure LocateHeatID(AHeatID: integer);
  public
    { Public declarations }
    procedure Prepare(AConnectionID: TFDConnection; ASessionID, AEventID, AHeatID: integer);
    property SelectedEventID: integer read FSelectedEventID write FSelectedEventID;
    property SelectedHeatID: integer read FSelectedHeatID write FSelectedHeatID;
    property SessionID: integer read FSessionID write FSessionID;
    property Connection: TFDConnection read FConnection write FConnection;
  end;

var
  TreeViewSCM: TTreeViewSCM;

implementation

{$R *.dfm}

{ TIdentData }
constructor TIdentData.Create(AID: integer; AValue: Integer);
begin
  FID := AID;
  FValue := AValue;
end;

procedure TTreeViewSCM.btnCancelClick(Sender: TObject);
begin
    FSelectedEventID := 0;
    FSelectedHeatID := 0;
    ModalResult := mrCancel;
end;

procedure TTreeViewSCM.btnCloseClick(Sender: TObject);
var
node: TTreeNode;
obj : TIdentData;
begin
  FSelectedEventID := 0;
  FSelectedHeatID := 0;
  node := TreeViewSCM.Selected;
  if (node <> nil) then
  begin
    { ROOT NODE }
    if (node.Level = 0) then
    begin
      obj := node.Data;
      if (obj <> nil) then
      begin
        FSelectedEventID := obj.FID;  // EVENT ID.
        node := node.getFirstChild;
        if (node <> nil) then
        begin
          obj := node.Data;
          if (obj <> nil) then
          begin
            FSelectedHeatID := obj.FID; // HEAT ID.
          end;
        end;
      end;
    end
    { CHILD NODE }
    else
    begin
      obj := node.Data;
      if (obj <> nil) then
      begin
        FSelectedHeatID := obj.FID;  // HEAT ID.
        if (node.Parent <> nil) then
        begin
          node := TTreeNode(node.Parent);
          obj := node.Data;
          if (obj <> nil) then
          begin
            FSelectedEventID := obj.FID; // HEAT ID.
          end;
        end;
      end;
    end;
  end;
  ModalResult := mrOk;
end;

procedure TTreeViewSCM.FormDestroy(Sender: TObject);
begin
  while IdentList.Count > 0 do
  begin
    TIdentData(IdentList[0]).Free;
    IdentList.Delete(0);
  end;
  IdentList.Free; // free TIdentData objects ...
end;

{ TTreeViewSCM }
procedure TTreeViewSCM.FormCreate(Sender: TObject);
begin
  // Empty the TreeView.
  FConnection := nil;
  SessionID := 0;
  TreeViewSCM.Items.Clear;
  IdentList := TList<TIdentData>.Create; // A list of ptrs to TIdentData objects.
end;

procedure TTreeViewSCM.FormKeyDown(Sender: TObject; var Key: Word; Shift:
    TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    FSelectedEventID := 0;
    FSelectedHeatID := 0;
    ModalResult := mrCancel;
  end;
end;

procedure TTreeViewSCM.FormShow(Sender: TObject);
var
Event, Heat: integer;
begin
  if Assigned(fConnection) then
  begin
    qryEvent.Connection := FConnection;
    qryEvent.ParamByName('SESSIONID').AsInteger := FSessionID;
    qryEvent.Prepare;
    qryEvent.Open;
    if qryEvent.Active then
    begin
      qryHeat.Connection :=FConnection;
      qryHeat.Open; // Master : Detail relationship ...
    end;

    PopulateTree;
    Event := qryEvent.ParamByName('EventID').AsInteger;
    Heat := qryHeat.ParamByName('HeatID').AsInteger;
    LocateTreeItem(Event, Heat);
  end;

  TreeViewSCM.FullExpand

end;

procedure TTreeViewSCM.LocateEventID(AEventID: integer);
var
  Node: TTreeNode;
  obj : TIdentData;
begin
  Node := TreeViewSCM.Items.GetFirstNode;
  while Node <> nil do
  begin
    obj := Node.Data;
    if (obj <> nil) and (obj.FID = AEventID) then
    begin
      Node := Node.GetFirstChild;
      // Expand the parent node if it's collapsed.
      if not Node.Parent.Expanded then
        Node.Parent.Expanded := True;
      // Focus on first heat in event.
      TreeViewSCM.Selected := Node;
      Node.Focused := true;
      break;
    end;
    Node := Node.GetNextSibling;
  end;
end;

procedure TTreeViewSCM.LocateHeatID(AHeatID: integer);
var
  Node, ChildNode: TTreeNode;
  obj : TIdentData;
begin
  Node := TreeViewSCM.Items.GetFirstNode;
  while Node <> nil do
  begin
    ChildNode := Node.GetFirstChild;
    while ChildNode <> nil do
    begin
      obj := ChildNode.Data;
      if (obj <> nil) and (obj.FID = AHeatID) then
      begin
        // Expand the parent node if it's collapsed
        if not Node.Expanded then
          Node.Expanded := True;
        TreeViewSCM.Selected := ChildNode;
        ChildNode.Focused := true;
        break;
      end;
      ChildNode := ChildNode.GetNextSibling;
    end;
    Node := Node.GetNextSibling;
  end;
end;

procedure TTreeViewSCM.LocateTreeItem(EventNum, HeatNum: integer);
var
  Node: TTreeNode;
  Found: Boolean;
  obj : TIdentData;
begin
  Found := False;
  Node := TreeViewSCM.Items.GetFirstNode;
  while Node <> nil do
  begin
    obj := Node.Data;
    if (obj <> nil) and (obj.FValue = EventNum) then
    begin
      Found := True;
      break;
    end;
    Node := Node.GetNextSibling;
  end;

  if Found then
  begin
    Node := Node.GetFirstChild;
    while Node <> nil do
    begin
      obj := Node.Data;
      if (obj <> nil) and (obj.FValue = HeatNum) then
      begin
        // Expand the parent node if it's collapsed
        if not Node.Parent.Expanded then
          Node.Parent.Expanded := True;
        TreeViewSCM.Selected := Node;
        Node.Focused := true;
        break;
      end;
      Node := Node.GetNextSibling;
    end;
  end;
end;

procedure TTreeViewSCM.PopulateTree;
var
  node, subnode: TTreeNode;
  s: string;
  i, j, id: integer;
  ident: TIdentData;
begin

  { p o p u l a t e   t h e   T r e e V i e w . . .   }

  TreeViewSCM.Items.Clear; // Clear the tree view

  // R O O T   N O D E S    -   E V E N T S   . . .
  while not qryEvent.Eof do
  begin
    s := qryEvent.FieldByName('EventCaption').AsString;
    i := qryEvent.FieldByName('StrokeID').AsInteger;
    j := qryEvent.FieldByName('EventNum').AsInteger;
    id := qryEvent.FieldByName('EventID').AsInteger;
    { CREATE NODE }
    ident := TIdentData.Create(id, j); // object to hold event and even number.
    IdentList.Add(ident); // add object to local list.
    Node := TreeViewSCM.Items.AddObject(nil, s, ident); // assign data ptr.

    if (qryEvent.FieldByName('EventTypeID').AsInteger = 1) then
    begin
      case i of
        1: // Freestyle
          Node.ImageIndex := 1;
        2: // BreastStroke
          Node.ImageIndex := 3;
        3: // BackStroke
          Node.ImageIndex := 2;
        4: // Butterfly
          Node.ImageIndex := 4;
        5: // Medley
          Node.ImageIndex := 5;
      end;
    end;

    if (qryEvent.FieldByName('EventTypeID').AsInteger = 2) then
    begin
      case i of
        1: // Freestyle
          Node.ImageIndex := 6;
        2: // BreastStroke
          Node.ImageIndex := 8;
        3: // BackStroke
          Node.ImageIndex := 7;
        4: // Butterfly
          Node.ImageIndex := 9;
        5: // Medley
          Node.ImageIndex := 10;
      end;
    end;

    // ------------------------------------------------------------
    // C H I L D   N O D E S   -   H E A T S  ...
    qryHeat.First;
    while not qryHeat.Eof do
    begin
      // Add child nodes
      s := qryHeat.FieldByName('HeatCaption').AsString;
      i := qryHeat.FieldByName('HeatNum').AsInteger;
      j := qryHeat.FieldByName('HeatStatusID').AsInteger;

      { CREATE SUBNODE }
      subnode := TreeViewSCM.Items.AddChild(Node, s);

      // ICON ORDERED heat numbers ...
      if (i > 9) then
        subnode.ImageIndex := 0
      else
        // heat number icons 1 thru 9..
        subnode.ImageIndex := i + 14;

      // ICON Heat status : Open, Raced, Closed.
      case j of
        1:
          subnode.StateIndex := 11;
        2:
          subnode.StateIndex := 12;
        3:
          subnode.StateIndex := 13;
      end;
    end;
    // ------------------------------------------------------------
  end;

end;

procedure TTreeViewSCM.Prepare(AConnectionID: TFDConnection;
  ASessionID, AEventID, AHeatID: integer);
var
Event, Heat: integer;
node: TTreeNode;
begin
  if Assigned(fConnection) then
  begin
    qryEvent.Connection := FConnection;
    qryEvent.ParamByName('SESSIONID').AsInteger := ASessionID;
    qryEvent.Prepare;
    qryEvent.Open;
    if qryEvent.Active then
    begin
      qryHeat.Connection :=FConnection;
      qryHeat.Open; // Master : Detail relationship ...
    end;

    PopulateTree;

    if (AHeatID <> 0) then
      LocateHeatID(AHeatID)
    else if (AEventID <> 0) then
      LocateEventID(AEventID)
    else
    begin
      node := TreeViewSCM.Items.GetFirstNode;
      if (node <> nil) then
        TreeViewSCM.Select(Node);
    end;
  end;
end;

end.
