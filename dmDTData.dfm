object DTData: TDTData
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 480
  Width = 640
  object scmConnection: TFDConnection
    Left = 64
    Top = 40
  end
end
