object TreeViewDT: TTreeViewDT
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'QUICK SELECT...'
  ClientHeight = 620
  ClientWidth = 492
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  TextHeight = 21
  object TV: TTreeView
    Left = 0
    Top = 0
    Width = 492
    Height = 563
    Align = alClient
    Indent = 19
    TabOrder = 0
    Items.NodeData = {
      070200000009540054007200650065004E006F00640065002F00000000000000
      00000000FFFFFFFFFFFFFFFF0000000000000000000200000001085300650073
      00730069006F006E0031000000310000000000000000000000FFFFFFFFFFFFFF
      FF000000000000000000000000000109460069006C0065004E0061006D006500
      31000000310000000000000000000000FFFFFFFFFFFFFFFF0000000000000000
      00000000000109460069006C0065004E0061006D006500320000002F00000000
      00000000000000FFFFFFFFFFFFFFFF0000000000000000000200000001085300
      65007300730069006F006E0032000000310000000000000000000000FFFFFFFF
      FFFFFFFF000000000000000000000000000109460069006C0065004E0061006D
      00650033000000310000000000000000000000FFFFFFFFFFFFFFFF0000000000
      00000000000000000109460069006C0065004E0061006D0065003400}
  end
  object pnlFooter: TPanel
    Left = 0
    Top = 563
    Width = 492
    Height = 57
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      492
      57)
    object btnClose: TButton
      Left = 391
      Top = 12
      Width = 100
      Height = 34
      Anchors = [akTop, akRight]
      Caption = 'OK'
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 285
      Top = 12
      Width = 100
      Height = 34
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
  object tblDT: TFDMemTable
    Active = True
    FieldDefs = <
      item
        Name = 'DTID'
        DataType = ftInteger
      end
      item
        Name = 'CreatedDT'
        DataType = ftDateTime
      end
      item
        Name = 'FileName'
        DataType = ftString
        Size = 512
      end
      item
        Name = 'fSession'
        DataType = ftInteger
      end
      item
        Name = 'fEvent'
        DataType = ftInteger
      end
      item
        Name = 'fHeat'
        DataType = ftInteger
      end
      item
        Name = 'fGender'
        DataType = ftString
        Size = 1
      end
      item
        Name = 'fGUID'
        DataType = ftString
        Size = 8
      end>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvPersistent, rvSilentMode]
    ResourceOptions.Persistent = True
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    UpdateOptions.KeyFields = 'DTID'
    StoreDefs = True
    Left = 304
    Top = 216
    Content = {
      414442531000000046030000FF00010001FF02FF0304000A000000740062006C
      004400540005000A000000740062006C00440054000600000000000700000800
      32000000090000FF0AFF0B040008000000440054004900440005000800000044
      005400490044000C00010000000E000D000F0001100001110001120001130001
      1400011500011600080000004400540049004400FEFF0B040012000000430072
      0065006100740065006400440054000500120000004300720065006100740065
      006400440054000C00020000000E0017000F0001100001110001120001130001
      140001160012000000430072006500610074006500640044005400FEFF0B0400
      10000000460069006C0065004E0061006D006500050010000000460069006C00
      65004E0061006D0065000C00030000000E0018001900000200000F0001100001
      110001120001130001140001160010000000460069006C0065004E0061006D00
      65001A0000020000FEFF0B0400100000006600530065007300730069006F006E
      000500100000006600530065007300730069006F006E000C00040000000E000D
      000F000110000111000112000113000114000116001000000066005300650073
      00730069006F006E00FEFF0B04000C00000066004500760065006E0074000500
      0C00000066004500760065006E0074000C00050000000E000D000F0001100001
      11000112000113000114000116000C00000066004500760065006E007400FEFF
      0B04000A0000006600480065006100740005000A000000660048006500610074
      000C00060000000E000D000F000110000111000112000113000114000116000A
      00000066004800650061007400FEFF0B04000E0000006600470065006E006400
      6500720005000E0000006600470065006E006400650072000C00070000000E00
      18001900010000000F000110000111000112000113000114000116000E000000
      6600470065006E006400650072001A0001000000FEFF0B04000A000000660047
      0055004900440005000A000000660047005500490044000C00080000000E0018
      001900080000000F000110000111000112000113000114000116000A00000066
      0047005500490044001A0008000000FEFEFF1BFEFF1CFEFF1DFEFEFEFF1EFEFF
      1FFF20FEFEFE0E004D0061006E0061006700650072001E005500700064006100
      7400650073005200650067006900730074007200790012005400610062006C00
      65004C006900730074000A005400610062006C00650008004E0061006D006500
      140053006F0075007200630065004E0061006D0065000A005400610062004900
      4400240045006E0066006F0072006300650043006F006E007300740072006100
      69006E00740073001E004D0069006E0069006D0075006D004300610070006100
      6300690074007900180043006800650063006B004E006F0074004E0075006C00
      6C00140043006F006C0075006D006E004C006900730074000C0043006F006C00
      75006D006E00100053006F007500720063006500490044000E00640074004900
      6E00740033003200100044006100740061005400790070006500140053006500
      6100720063006800610062006C006500120041006C006C006F0077004E007500
      6C006C000800420061007300650014004F0041006C006C006F0077004E007500
      6C006C0012004F0049006E0055007000640061007400650010004F0049006E00
      570068006500720065000C004F0049006E004B00650079001A004F0072006900
      670069006E0043006F006C004E0061006D006500140064007400440061007400
      6500540069006D00650018006400740041006E00730069005300740072006900
      6E0067000800530069007A006500140053006F00750072006300650053006900
      7A0065001C0043006F006E00730074007200610069006E0074004C0069007300
      7400100056006900650077004C006900730074000E0052006F0077004C006900
      730074001800520065006C006100740069006F006E004C006900730074001C00
      55007000640061007400650073004A006F00750072006E0061006C000E004300
      680061006E00670065007300}
    object tblDTDTID: TIntegerField
      FieldName = 'DTID'
      Origin = 'DTID'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
    end
    object tblDTCreatedDT: TDateTimeField
      FieldName = 'CreatedDT'
      Origin = 'CreatedDT'
    end
    object tblDTFileName: TStringField
      FieldName = 'FileName'
      Origin = 'FileName'
      Size = 512
    end
    object tblDTfSession: TIntegerField
      FieldName = 'fSession'
      Origin = 'fSession'
    end
    object tblDTfEvent: TIntegerField
      FieldName = 'fEvent'
      Origin = 'fEvent'
    end
    object tblDTfHeat: TIntegerField
      FieldName = 'fHeat'
      Origin = 'fHeat'
    end
    object tblDTfGender: TStringField
      FieldName = 'fGender'
      Origin = 'fGender'
      Size = 1
    end
    object tblDTfGUID: TStringField
      FieldName = 'fGUID'
      Origin = 'fGUID'
      Size = 8
    end
  end
  object dsDT: TDataSource
    DataSet = tblDT
    Left = 352
    Top = 216
  end
end