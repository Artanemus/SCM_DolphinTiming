object dtExec: TdtExec
  Left = 0
  Top = 0
  Caption = 'SwimClubMeet - Dolphin Timing.'
  ClientHeight = 583
  ClientWidth = 1002
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu1
  OnCreate = FormCreate
  TextHeight = 21
  object SpeedButton1: TSpeedButton
    Left = 84
    Top = 535
    Width = 112
    Height = 41
    Caption = 'AutoConnect'
  end
  object SpeedButton2: TSpeedButton
    Left = 202
    Top = 535
    Width = 112
    Height = 41
    Caption = 'Post'
  end
  object btnPrevEvent: TButton
    Left = 24
    Top = 24
    Width = 290
    Height = 36
    Caption = 'PREVIOUS'
    TabOrder = 0
  end
  object btnNextEvent: TButton
    Left = 24
    Top = 439
    Width = 290
    Height = 36
    Caption = 'NEXT'
    TabOrder = 1
  end
  object btnPrevDTFile: TButton
    Left = 427
    Top = 24
    Width = 290
    Height = 36
    Caption = 'PREVIOUS'
    TabOrder = 2
  end
  object btnNextDTFile: TButton
    Left = 427
    Top = 439
    Width = 289
    Height = 36
    Caption = 'NEXT'
    TabOrder = 3
  end
  object Button1: TButton
    Left = 641
    Top = 535
    Width = 75
    Height = 41
    Caption = 'Close'
    TabOrder = 4
  end
  object btnRefresh: TButton
    Left = 642
    Top = 488
    Width = 75
    Height = 41
    Caption = 'Refresh'
    TabOrder = 5
  end
  object dbgridSCM: TDBGrid
    Left = 24
    Top = 66
    Width = 290
    Height = 367
    TabOrder = 6
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -16
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object dbgridDT: TDBGrid
    Left = 427
    Top = 66
    Width = 290
    Height = 367
    TabOrder = 7
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -16
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object MainMenu1: TMainMenu
    Left = 928
    Top = 16
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
    Left = 928
    Top = 88
  end
end
