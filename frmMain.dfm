object Main: TMain
  Left = 0
  Top = 0
  Caption = 'SwimClubMeet - Dolphin Timing.'
  ClientHeight = 537
  ClientWidth = 943
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu1
  TextHeight = 15
  object PaintBox1: TPaintBox
    Left = 344
    Top = 24
    Width = 64
    Height = 59
  end
  object Label5: TLabel
    Left = 26
    Top = 73
    Width = 249
    Height = 25
    Caption = 'Current Event Distance Stroke'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label6: TLabel
    Left = 427
    Top = 73
    Width = 148
    Height = 25
    Caption = 'Dolphin Filename'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object SpeedButton1: TSpeedButton
    Left = 816
    Top = 25
    Width = 112
    Height = 48
    Caption = 'AutoConnect Selected'
  end
  object SpeedButton2: TSpeedButton
    Left = 816
    Top = 79
    Width = 112
    Height = 48
    Caption = 'Post Selected RaceTimes'
  end
  object ControlList1: TControlList
    Left = 24
    Top = 104
    Width = 354
    Height = 331
    ItemMargins.Left = 0
    ItemMargins.Top = 0
    ItemMargins.Right = 0
    ItemMargins.Bottom = 0
    ItemSelectionOptions.HotColorAlpha = 50
    ItemSelectionOptions.SelectedColorAlpha = 70
    ItemSelectionOptions.FocusedColorAlpha = 80
    ParentColor = False
    TabOrder = 0
    object Label1: TLabel
      AlignWithMargins = True
      Left = 75
      Top = 25
      Width = 188
      Height = 38
      Margins.Left = 10
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoSize = False
      Caption = 
        'This is example of item with multi-line text. You can put any TG' +
        'raphicControl on it and adjust properties.'
      EllipsisPosition = epEndEllipsis
      ShowAccelChar = False
      Transparent = True
      WordWrap = True
      ExplicitWidth = 131
    end
    object VirtualImage1: TVirtualImage
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 62
      Height = 62
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alLeft
      ImageWidth = 0
      ImageHeight = 0
      ImageIndex = -1
    end
    object Label2: TLabel
      Left = 75
      Top = 6
      Width = 25
      Height = 13
      Caption = 'Title'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object ControlListButton1: TControlListButton
      AlignWithMargins = True
      Left = 284
      Top = 20
      Width = 30
      Height = 30
      Margins.Left = 2
      Margins.Top = 20
      Margins.Right = 2
      Margins.Bottom = 20
      Align = alRight
      Style = clbkToolButton
      ExplicitLeft = 227
    end
    object ControlListButton2: TControlListButton
      AlignWithMargins = True
      Left = 318
      Top = 20
      Width = 30
      Height = 30
      Margins.Left = 2
      Margins.Top = 20
      Margins.Right = 2
      Margins.Bottom = 20
      Align = alRight
      Style = clbkToolButton
      ExplicitLeft = 261
    end
  end
  object ControlList2: TControlList
    Left = 427
    Top = 104
    Width = 366
    Height = 331
    ItemMargins.Left = 0
    ItemMargins.Top = 0
    ItemMargins.Right = 0
    ItemMargins.Bottom = 0
    ItemSelectionOptions.HotColorAlpha = 50
    ItemSelectionOptions.SelectedColorAlpha = 70
    ItemSelectionOptions.FocusedColorAlpha = 80
    ParentColor = False
    TabOrder = 1
    object Label3: TLabel
      AlignWithMargins = True
      Left = 75
      Top = 25
      Width = 123
      Height = 38
      Margins.Left = 10
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoSize = False
      Caption = 
        'This is example of item with multi-line text. You can put any TG' +
        'raphicControl on it and adjust properties.'
      EllipsisPosition = epEndEllipsis
      ShowAccelChar = False
      Transparent = True
      WordWrap = True
      ExplicitWidth = 131
    end
    object VirtualImage2: TVirtualImage
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 62
      Height = 62
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alLeft
      ImageWidth = 0
      ImageHeight = 0
      ImageIndex = -1
    end
    object Label4: TLabel
      Left = 75
      Top = 6
      Width = 25
      Height = 13
      Caption = 'Title'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object ControlListButton3: TControlListButton
      AlignWithMargins = True
      Left = 296
      Top = 20
      Width = 30
      Height = 30
      Margins.Left = 2
      Margins.Top = 20
      Margins.Right = 2
      Margins.Bottom = 20
      Align = alRight
      Style = clbkToolButton
      ExplicitLeft = 227
    end
    object ControlListButton4: TControlListButton
      AlignWithMargins = True
      Left = 330
      Top = 20
      Width = 30
      Height = 30
      Margins.Left = 2
      Margins.Top = 20
      Margins.Right = 2
      Margins.Bottom = 20
      Align = alRight
      Style = clbkToolButton
      ExplicitLeft = 261
    end
  end
  object btnPrevEvent: TButton
    Left = 24
    Top = 24
    Width = 289
    Height = 25
    Caption = 'Previous Event'
    TabOrder = 2
  end
  object btnNextEvent: TButton
    Left = 24
    Top = 441
    Width = 289
    Height = 25
    Caption = 'Next Event'
    TabOrder = 3
  end
  object btnPrevDTFile: TButton
    Left = 427
    Top = 42
    Width = 290
    Height = 25
    Caption = 'Previous Dolphin Timer File '
    TabOrder = 4
  end
  object btnNextDTFile: TButton
    Left = 423
    Top = 441
    Width = 289
    Height = 25
    Caption = 'Next Dolphin Timer File'
    TabOrder = 5
  end
  object CheckBox1: TCheckBox
    Left = 32
    Top = 56
    Width = 97
    Height = 17
    Caption = 'Toggle Selection'
    TabOrder = 6
  end
  object Button1: TButton
    Left = 832
    Top = 504
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 7
  end
  object btnRefresh: TButton
    Left = 751
    Top = 504
    Width = 75
    Height = 25
    Caption = 'Refresh'
    TabOrder = 8
  end
  object MainMenu1: TMainMenu
    Left = 112
    Top = 192
    object File1: TMenuItem
      Caption = 'File'
    end
    object File2: TMenuItem
      Caption = 'Session'
    end
    object Setup1: TMenuItem
      Caption = 'Setup'
    end
  end
  object ImageCollection1: TImageCollection
    Images = <>
    Left = 112
    Top = 256
  end
end
