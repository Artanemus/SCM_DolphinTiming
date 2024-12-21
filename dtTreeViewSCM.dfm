object TreeViewSCM: TTreeViewSCM
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'QUICK SELECT...'
  ClientHeight = 598
  ClientWidth = 492
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  TextHeight = 21
  object TreeViewSCM: TTreeView
    Left = 0
    Top = 0
    Width = 492
    Height = 541
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Segoe UI'
    Font.Style = []
    HideSelection = False
    Images = DTData.vimglistDTEvent
    Indent = 30
    ParentFont = False
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    Items.NodeData = {
      070300000009540054007200650065004E006F00640065002D00000000000000
      00000000FFFFFFFFFFFFFFFF0000000000000000000300000001074500760065
      006E0074002000310000002B000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFF000000000000000000010648006500610074002000310000002B000000
      0000000000000000FFFFFFFFFFFFFFFF00000000000000000000000000010648
      006500610074002000320000002B0000000000000000000000FFFFFFFFFFFFFF
      FF00000000000000000000000000010648006500610074002000330000002D00
      00000100000001000000FFFFFFFFFFFFFFFF0100000000000000000100000001
      074500760065006E0074002000320000002B000000FFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFF0000000000000000000106480065006100740020003100
      00002D0000000300000003000000FFFFFFFFFFFFFFFF03000000000000000000
      00000001074500760065006E00740020003300}
  end
  object pnlFooter: TPanel
    Left = 0
    Top = 541
    Width = 492
    Height = 57
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnClose: TButton
      Left = 189
      Top = 16
      Width = 100
      Height = 34
      Caption = 'Close'
      TabOrder = 0
    end
  end
  object qryEvent: TFDQuery
    Left = 136
    Top = 248
  end
  object qryHeat: TFDQuery
    Left = 136
    Top = 320
  end
  object dsEvent: TDataSource
    Left = 224
    Top = 248
  end
  object dsHeat: TDataSource
    Left = 224
    Top = 320
  end
end
