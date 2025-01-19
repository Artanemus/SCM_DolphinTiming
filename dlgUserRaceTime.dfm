object UserRaceTime: TUserRaceTime
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Enter a Race-Time ...'
  ClientHeight = 188
  ClientWidth = 454
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 21
  object pnlFooter: TPanel
    Left = 0
    Top = 123
    Width = 454
    Height = 65
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitTop = 376
    ExplicitWidth = 624
    object btnOk: TButton
      Left = 287
      Top = 24
      Width = 106
      Height = 34
      Caption = 'OK'
      TabOrder = 0
      OnClick = btnOkClick
    end
    object btnCancel: TButton
      Left = 175
      Top = 24
      Width = 106
      Height = 34
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
  object pnlBody: TPanel
    Left = 0
    Top = 0
    Width = 454
    Height = 123
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitLeft = 216
    ExplicitTop = 152
    ExplicitWidth = 185
    ExplicitHeight = 41
    object edtUserRaceTime: TEdit
      Left = 120
      Top = 48
      Width = 169
      Height = 38
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      Text = '00:00.000'
    end
  end
end
