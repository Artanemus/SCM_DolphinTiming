unit frmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.ControlList, Vcl.VirtualImage, Vcl.Buttons, Vcl.BaseImageCollection,
  Vcl.ImageCollection, Vcl.Menus;

type
  TMain = class(TForm)
    ControlList1: TControlList;
    Label1: TLabel;
    VirtualImage1: TVirtualImage;
    Label2: TLabel;
    ControlListButton1: TControlListButton;
    ControlListButton2: TControlListButton;
    ControlList2: TControlList;
    Label3: TLabel;
    VirtualImage2: TVirtualImage;
    Label4: TLabel;
    ControlListButton3: TControlListButton;
    ControlListButton4: TControlListButton;
    btnPrevEvent: TButton;
    btnNextEvent: TButton;
    btnPrevDTFile: TButton;
    btnNextDTFile: TButton;
    PaintBox1: TPaintBox;
    MainMenu1: TMainMenu;
    Label5: TLabel;
    Label6: TLabel;
    File1: TMenuItem;
    File2: TMenuItem;
    ImageCollection1: TImageCollection;
    SpeedButton1: TSpeedButton;
    CheckBox1: TCheckBox;
    SpeedButton2: TSpeedButton;
    Setup1: TMenuItem;
    Button1: TButton;
    btnRefresh: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Main: TMain;

implementation

{$R *.dfm}

end.
