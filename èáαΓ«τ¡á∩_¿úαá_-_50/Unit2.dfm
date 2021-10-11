object Option: TOption
  Left = 414
  Top = 371
  BorderStyle = bsDialog
  Caption = ' '#1053#1072#1089#1090#1088#1086#1081#1082#1072
  ClientHeight = 332
  ClientWidth = 417
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox2: TGroupBox
    Left = 8
    Top = 59
    Width = 401
    Height = 162
    Caption = #1056#1091#1073#1072#1096#1082#1072
    TabOrder = 0
    TabStop = True
    DesignSize = (
      401
      162)
    object ListBox1: TListBox
      Left = 8
      Top = 18
      Width = 385
      Height = 135
      Style = lbOwnerDrawFixed
      AutoComplete = False
      Anchors = [akLeft, akTop, akRight]
      BorderStyle = bsNone
      Color = clBtnFace
      Columns = 5
      ExtendedSelect = False
      ItemHeight = 110
      TabOrder = 0
      OnDrawItem = ListBox1DrawItem
    end
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 228
    Width = 401
    Height = 65
    Caption = #1054#1089#1085#1086#1074#1085#1086#1077
    TabOrder = 1
    object CheckBox1: TCheckBox
      Left = 24
      Top = 39
      Width = 217
      Height = 17
      Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100' '#1085#1072#1095#1080#1085#1072#1077#1090' '#1080#1075#1088#1091' '#1087#1077#1088#1074#1099#1084
      TabOrder = 0
    end
    object CheckBox2: TCheckBox
      Left = 24
      Top = 19
      Width = 249
      Height = 17
      Caption = #1042#1099#1076#1072#1074#1072#1090#1100' '#1082#1072#1088#1090#1091' '#1080#1079' '#1082#1086#1083#1086#1076#1099' '#1087#1088#1080' '#1093#1086#1076#1077' '#1080#1075#1088#1086#1082#1072
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
  end
  object Button1: TButton
    Left = 335
    Top = 298
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 256
    Top = 298
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 3
    OnClick = Button2Click
  end
  object GroupBox4: TGroupBox
    Left = 8
    Top = 8
    Width = 401
    Height = 47
    Caption = #1052#1072#1089#1090#1100' '#1082#1072#1088#1090
    TabOrder = 4
    DesignSize = (
      401
      47)
    object ComboBox1: TComboBox
      Left = 8
      Top = 17
      Width = 385
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 0
      Text = #1063#1077#1088#1074#1080
      Items.Strings = (
        #1063#1077#1088#1074#1080
        #1055#1080#1082#1080
        #1058#1088#1077#1092#1099
        #1041#1091#1073#1085#1099
        #1042#1089#1077)
    end
  end
end
