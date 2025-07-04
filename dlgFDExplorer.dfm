object FDExplorer: TFDExplorer
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'FireDAC'#39's Explorer Application.'
  ClientHeight = 417
  ClientWidth = 598
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnKeyDown = FormKeyDown
  TextHeight = 21
  object pnlBody: TPanel
    Left = 0
    Top = 0
    Width = 598
    Height = 360
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitHeight = 399
    object memoInfo: TMemo
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 592
      Height = 354
      Align = alClient
      EditMargins.Left = 10
      EditMargins.Right = 10
      Lines.Strings = (
        'Press Ok to start the stand-alone FireDAC'#39's Connection Explorer.'
        ''
        'To modify the application'#39's FDConnectionDef.ini file,'
        '1. Press the '#39'Open ConnDef File'#39'  button and...'
        '2. Enter into the filename editbox... %AppData%\Artanemus\SCM'
        '3. Select the file FDConnectionDefs.ini'
        '4. Press Open.'
        
          '5. Listed are the available connection definitions. Select MSSQL' +
          '_SwimClubMeet.'
        ''
        
          'Here you can modify, delete and create connection parameters. Sa' +
          've your'
        'changes and test the connection.'
        ''
        
          'NOTE: AppData is a hidden system file. FDConnectionDef.ini full ' +
          'file path is...'
        '    %SYSTEMDRIVE%\Users\%USERNAME%\AppData\Roaming\Artanemus\SCM'
        '')
      ReadOnly = True
      TabOrder = 0
      ExplicitHeight = 358
    end
  end
  object pnlFooter: TPanel
    Left = 0
    Top = 360
    Width = 598
    Height = 57
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 399
    object btnOk: TButton
      Left = 302
      Top = 12
      Width = 89
      Height = 33
      Caption = 'Ok'
      TabOrder = 0
      OnClick = btnOkClick
    end
    object btnCancel: TButton
      Left = 207
      Top = 12
      Width = 89
      Height = 33
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
end
