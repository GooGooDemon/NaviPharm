object fmProgress: TfmProgress
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1050#1086#1087#1080#1088#1086#1074#1072#1085#1080#1077' '#1092#1072#1081#1083#1086#1074
  ClientHeight = 221
  ClientWidth = 558
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object LabelFilesCount: TLabel
    Left = 24
    Top = 16
    Width = 70
    Height = 13
    Caption = #1060#1072#1081#1083#1086#1074' 0 '#1080#1079' 0'
  end
  object LabelFileName: TLabel
    Left = 24
    Top = 80
    Width = 513
    Height = 13
    AutoSize = False
    Caption = '< '#1090#1077#1082#1091#1097#1080#1081' '#1092#1072#1081#1083' >'
  end
  object Label3: TLabel
    Left = 24
    Top = 126
    Width = 39
    Height = 13
    Caption = #1056#1072#1079#1084#1077#1088':'
  end
  object LabelFileSize: TLabel
    Left = 69
    Top = 126
    Width = 40
    Height = 13
    Caption = '< 000 >'
  end
  object LabelTiime: TLabel
    Left = 330
    Top = 16
    Width = 207
    Height = 13
    Alignment = taRightJustify
    Caption = #1055#1088#1086#1076#1086#1083#1078#1080#1090#1077#1083#1100#1085#1086#1089#1090#1100' '#1086#1087#1077#1088#1072#1094#1080#1080': 00:00:00'
  end
  object ProgressFile: TProgressBar
    Left = 24
    Top = 95
    Width = 513
    Height = 25
    DoubleBuffered = True
    ParentDoubleBuffered = False
    Position = 50
    Step = 1
    TabOrder = 0
  end
  object ProgressTotal: TProgressBar
    Left = 24
    Top = 35
    Width = 513
    Height = 25
    DoubleBuffered = True
    ParentDoubleBuffered = False
    Position = 50
    Step = 1
    TabOrder = 1
  end
  object btnPause: TButton
    Left = 344
    Top = 163
    Width = 88
    Height = 38
    Caption = #1055#1072#1091#1079#1072
    TabOrder = 2
    OnClick = btnPauseClick
  end
  object Button2: TButton
    Left = 448
    Top = 163
    Width = 89
    Height = 38
    Caption = #1054#1090#1084#1077#1085#1080#1090#1100
    TabOrder = 3
    OnClick = Button2Click
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 500
    OnTimer = Timer1Timer
    Left = 56
    Top = 168
  end
end
