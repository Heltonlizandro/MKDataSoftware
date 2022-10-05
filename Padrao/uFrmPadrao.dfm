object FrmPadrao: TFrmPadrao
  Left = 0
  Top = 0
  Caption = 'FrmPadrao'
  ClientHeight = 296
  ClientWidth = 589
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object Transaction: TFDTransaction
    Connection = DM.Banco
    Left = 48
    Top = 32
  end
  object SqlAuxiliar: TFDQuery
    Connection = DM.Banco
    Transaction = Transaction
    Left = 128
    Top = 32
  end
end
