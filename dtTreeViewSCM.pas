unit dtTreeViewSCM;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, dmDTData, Vcl.StdCtrls,
  Vcl.ExtCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TTreeViewSCM = class(TForm)
    TreeViewSCM: TTreeView;
    pnlFooter: TPanel;
    btnClose: TButton;
    qryEvent: TFDQuery;
    qryHeat: TFDQuery;
    dsEvent: TDataSource;
    dsHeat: TDataSource;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TreeViewSCM: TTreeViewSCM;

implementation

{$R *.dfm}

procedure TTreeViewSCM.FormCreate(Sender: TObject);
begin
  // Empty the TreeView.
//  TreeViewSCM.Items.Clear;


  TreeViewSCM.FullExpand
end;

end.
