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
    ControlListButton1: TControlListButton;
    ControlListButton2: TControlListButton;
    ControlList2: TControlList;
    Label3: TLabel;
    VirtualImage2: TVirtualImage;
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
    SpeedButton2: TSpeedButton;
    Setup1: TMenuItem;
    Button1: TButton;
    btnRefresh: TButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    VirtualImage3: TVirtualImage;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    SpeedButton5: TSpeedButton;
    Label2: TLabel;
    Shape1: TShape;
    SpeedButton6: TSpeedButton;
    Shape2: TShape;
    Shape3: TShape;
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
