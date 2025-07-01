object ScanOptions: TScanOptions
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Time Drops Scan.'
  ClientHeight = 427
  ClientWidth = 360
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  TextHeight = 21
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 360
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblHeader: TLabel
      AlignWithMargins = True
      Left = 10
      Top = 10
      Width = 340
      Height = 45
      Margins.Left = 10
      Margins.Top = 10
      Margins.Right = 10
      Margins.Bottom = 10
      Align = alClient
      Alignment = taCenter
      Caption = 
        'Scan for '#39'results'#39' files in  the '#39'meets'#39' folder. Search for modi' +
        'fied or new '#39'results'#39' files.'
      Layout = tlCenter
      WordWrap = True
      ExplicitHeight = 55
    end
  end
  object pnlBody: TPanel
    Left = 0
    Top = 65
    Width = 360
    Height = 313
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 97
    ExplicitHeight = 160
    object lblSessionID: TLabel
      Left = 173
      Top = 120
      Width = 72
      Height = 21
      Alignment = taRightJustify
      Caption = 'Session ID'
    end
    object rgrpScanOptions: TRadioGroup
      Left = 43
      Top = 6
      Width = 273
      Height = 105
      Caption = 'Scan options ...'
      ItemIndex = 0
      Items.Strings = (
        'Scan ALL.'
        'Scan for a specific session.')
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object edtSessionID: TEdit
      Left = 251
      Top = 117
      Width = 65
      Height = 29
      NumbersOnly = True
      TabOrder = 1
      Text = '9999'
    end
    object rgrpFileType: TRadioGroup
      Left = 43
      Top = 155
      Width = 134
      Height = 137
      Caption = 'File types ...'
      Items.Strings = (
        'Both'
        '.DO3'
        '.DO4')
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
    end
  end
  object pnlFooter: TPanel
    Left = 0
    Top = 378
    Width = 360
    Height = 49
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitTop = 257
    object btnOk: TButton
      Left = 183
      Top = 8
      Width = 83
      Height = 33
      Caption = 'OK'
      TabOrder = 0
      OnClick = btnOkClick
    end
    object btnCancel: TButton
      Left = 94
      Top = 8
      Width = 83
      Height = 33
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
end
