object SCM: TSCM
  Height = 480
  Width = 640
  object scmConnection: TFDConnection
    Params.Strings = (
      'ConnectionDef=MSSQL_SwimClubMeet')
    Connected = True
    LoginPrompt = False
    Left = 120
    Top = 120
  end
  object tblSwimClub: TFDTable
    ActiveStoredUsage = [auDesignTime]
    Connection = scmConnection
    TableName = 'SwimClubMeet.dbo.SwimClub'
    Left = 96
    Top = 192
  end
  object dsSwimClub: TDataSource
    DataSet = tblSwimClub
    Left = 192
    Top = 192
  end
  object qrySCMSystem: TFDQuery
    ActiveStoredUsage = [auDesignTime]
    Connection = scmConnection
    SQL.Strings = (
      'SELECT * FROM SCMSystem WHERE SCMSystemID = 1;')
    Left = 96
    Top = 256
  end
end
