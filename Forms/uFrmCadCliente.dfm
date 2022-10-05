inherited FrmCadCliente: TFrmCadCliente
  Caption = 'Cadastro dos Clientes'
  ClientHeight = 496
  ClientWidth = 799
  OnDestroy = FormDestroy
  OnShow = FormShow
  ExplicitWidth = 799
  ExplicitHeight = 496
  PixelsPerInch = 96
  TextHeight = 13
  inherited PanelBotoes: TPanel
    Width = 799
    ExplicitWidth = 799
  end
  inherited PanelFiltro: TPanel
    Width = 799
    ExplicitWidth = 799
    object Label1: TLabel
      Left = 32
      Top = 16
      Width = 33
      Height = 13
      Caption = 'C'#243'digo'
    end
    object Label2: TLabel
      Left = 32
      Top = 45
      Width = 27
      Height = 13
      Caption = 'Nome'
    end
    object lbCPF_CNPJ: TLabel
      Left = 176
      Top = 16
      Width = 59
      Height = 13
      AutoSize = False
      Caption = 'CPF / CNPJ'
    end
    object EdtCodigo: TEdit
      Left = 76
      Top = 13
      Width = 47
      Height = 21
      TabOrder = 0
      OnChange = AtualizaDadosGrid
    end
    object EdtNome: TEdit
      Left = 76
      Top = 42
      Width = 341
      Height = 21
      CharCase = ecUpperCase
      TabOrder = 1
      OnChange = AtualizaDadosGrid
    end
    object EdtCPF_CNPJ: TMaskEdit
      Left = 240
      Top = 13
      Width = 177
      Height = 21
      TabOrder = 2
      Text = ''
      OnChange = AtualizaDadosGrid
    end
  end
  inherited PanelGrid: TPanel
    Width = 799
    Height = 378
    ExplicitWidth = 799
    ExplicitHeight = 378
    inherited GridDados: TRxDBGrid
      Width = 797
      Height = 376
      DataSource = dsDados
      Columns = <
        item
          Expanded = False
          FieldName = 'NOME'
          Title.Caption = 'Nome'
          Width = 360
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'CPF_CNPJ'
          Title.Caption = 'CPF/CNPJ'
          Width = 210
          Visible = True
        end>
    end
  end
  inherited dsDados: TDataSource
    DataSet = SqlDados
  end
end
