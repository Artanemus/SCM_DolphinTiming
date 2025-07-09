object ReConstructDlg: TReConstructDlg
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'ReConstruct & Export Time-Drops Results.'
  ClientHeight = 306
  ClientWidth = 658
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poOwnerFormCenter
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 21
  object pnlFooter: TPanel
    Left = 0
    Top = 249
    Width = 658
    Height = 57
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitTop = 145
    object btnOk: TButton
      Left = 256
      Top = 6
      Width = 240
      Height = 33
      Caption = 'Re-Construct && Export Results'
      Default = True
      TabOrder = 0
      OnClick = btnOkClick
    end
    object btnCancel: TButton
      Left = 162
      Top = 6
      Width = 88
      Height = 33
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
  object pnlBody: TPanel
    Left = 0
    Top = 0
    Width = 658
    Height = 249
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitHeight = 145
    object lblEventCSV: TLabel
      Left = 3
      Top = 33
      Width = 98
      Height = 21
      Caption = 'Export folder...'
    end
    object vimgInfo1: TVirtualImage
      Left = 622
      Top = 60
      Width = 28
      Height = 29
      ImageCollection = IMG.imgcolDT
      ImageWidth = 0
      ImageHeight = 0
      ImageIndex = 77
      ImageName = 'info'
      OnMouseEnter = vimgInfo1MouseEnter
      OnMouseLeave = vimgInfo1MouseLeave
    end
    object lblInfo: TLabel
      Left = 3
      Top = 95
      Width = 344
      Height = 21
      Caption = '(Export will include a "Timing System" status file.) '
      Enabled = False
    end
    object btnedtExportFolder: TButtonedEdit
      Left = 3
      Top = 60
      Width = 613
      Height = 29
      Images = IMG.vimglistDTGrid
      RightButton.ImageIndex = 1
      RightButton.ImageName = 'Folders'
      RightButton.Visible = True
      TabOrder = 0
      Text = 'c:\CTSDolphin\ReConstruct\'
      OnClick = btnedtExportFolderClick
    end
    object rgrpFileType: TRadioGroup
      Left = 3
      Top = 136
      Width = 247
      Height = 49
      Caption = 'Select file type to export...'
      Columns = 2
      ItemIndex = 1
      Items.Strings = (
        '.DO3'
        '.DO4')
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
  end
  object BrowseFolderDlg: TFileOpenDialog
    DefaultExtension = '.DO3'
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'CTS Dolphin result files (DO3, DO4)'
        FileMask = '*.DO?'
      end
      item
        DisplayName = 'DO3 files '
        FileMask = '*.DO3'
      end
      item
        DisplayName = 'DO4 files'
        FileMask = '*.DO4'
      end
      item
        DisplayName = 'All Files'
        FileMask = '*.*'
      end>
    OkButtonLabel = 'Select Folder'
    Options = [fdoPickFolders, fdoDontAddToRecent]
    Title = 'Select ReContruct folder...'
    Left = 364
    Top = 19
  end
  object BalloonHint1: TBalloonHint
    Left = 456
    Top = 17
  end
end
