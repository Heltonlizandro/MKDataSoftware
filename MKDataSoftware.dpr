program MKDataSoftware;

uses
  Vcl.Forms,
  uFrmPrincipal in 'uFrmPrincipal.pas' {FrmPrincipal},
  uFrmPadrao in 'Padrao\uFrmPadrao.pas' {FrmPadrao},
  F_Funcao in 'Objetos\F_Funcao.pas',
  uTCliente in 'Classes\uTCliente.pas',
  Form_DialogoPadrao in 'Objetos\Form_DialogoPadrao.pas' {Frm_DialogoPadrao},
  Form_DialogoMensagem in 'Objetos\Form_DialogoMensagem.pas',
  uDM in 'DM\uDM.pas' {DM: TDataModule},
  uFrmCadPadrao in 'Padrao\uFrmCadPadrao.pas' {FrmCadPadrao},
  uFrmCadCliente in 'Forms\uFrmCadCliente.pas' {FrmCadCliente},
  uFrmMenuPadrao in 'Padrao\uFrmMenuPadrao.pas' {FrmMenuPadrao},
  uFrmMntPadrao in 'Padrao\uFrmMntPadrao.pas' {FrmMntPadrao},
  uFrmMntCliente in 'Forms\uFrmMntCliente.pas' {FrmMntCliente};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.
