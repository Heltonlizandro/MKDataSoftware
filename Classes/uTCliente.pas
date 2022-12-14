unit uTCliente;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uFrmCadPadrao, Provider, DBClient, DB, FireDAC.Comp.Client,
  Grids, DBGrids, StdCtrls, Buttons, ExtCtrls, JPEG,
  System.Generics.Collections;

type
  TEndereco = class
    LOGRADOURO : String;
    BAIRRO : String;
    CIDADE: String;
    UF: String;
  end;

  TCliente = class
  private
    FCODIGO: Integer;
    FNOME: String;
    FATIVO: String;
    FCPF_CNPJ: String;
    FTIPO_PESSOA: String;
    FRG_IE: String;
    FEndereco: TEndereco;

    procedure SetCODIGO(const Value: Integer);
    procedure SetNOME(const Value: String);
    procedure SetCPF_CNPJ(const Value: String);
    procedure SetTIPO_PESSOA(const Value: String);
    procedure SetRG_IE(const Value: String);
    procedure SetATIVO(const Value: String);

    procedure InserirFones(cdsTelefones : TClientDataSet);
    procedure AlterarFones(cdsTelefones : TClientDataSet);
    procedure ExcluirFones(cdsTelefones : TClientDataSet);

    procedure InserirEndereco(cdsEndereco : TClientDataSet);
    procedure AlterarEndereco(cdsEndereco : TClientDataSet);
    procedure ExcluirEndereco(cdsEndereco : TClientDataSet);
    procedure SetEndereco(const Value: TEndereco);
  public
    SqlAuxiliar : TFDQuery;

    property CODIGO         : Integer   read FCODIGO       write SetCODIGO;
    property NOME           : String    read FNOME         write SetNOME;
    property ATIVO          : String    read FATIVO        write SetATIVO;
    property TIPO_PESSOA    : String    read FTIPO_PESSOA  write SetTIPO_PESSOA;
    property CPF_CNPJ       : String    read FCPF_CNPJ     write SetCPF_CNPJ;
    property RG_IE          : String    read FRG_IE        write SetRG_IE;
    property Endereco       : TEndereco read FEndereco     write SetEndereco;

    procedure CarregaDataSet(sDataSet : TFDQuery);
    procedure CarregaFones(cdsTelefones : TClientDataSet);
    procedure CarregaEnderecos(cdsEndereco : TClientDataSet);

    procedure ConsultaCEP(Cep: String);

    procedure ProximoCodigo;
    procedure Incluir(cdsTelefones, cdsEnderecos : TClientDataSet);
    procedure Alterar(cdsTelefones, cdsEnderecos : TClientDataSet);
    procedure Excluir;

    procedure Commit;
    procedure Rollback;

    constructor Create(Sql : TFDQuery);
    destructor  Destroy;
  end;

implementation

uses uFrmPrincipal, F_Funcao, uDM,
   Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc;

{ TCliente }

procedure TCliente.Alterar(cdsTelefones, cdsEnderecos : TClientDataSet);
begin
  try
    ExcluirFones(cdsTelefones);
    AlterarFones(cdsTelefones);
    InserirFones(cdsTelefones);

    ExcluirEndereco(cdsEnderecos);
    AlterarEndereco(cdsEnderecos);
    InserirEndereco(cdsEnderecos);

    SqlAuxiliar.Close;
    SqlAuxiliar.sql.clear;
    SqlAuxiliar.SQL.Add(' UPDATE CLIENTES SET '+
                        ' NOME         = '+QuotedStr(FNOME)+','+
                        ' TIPO_PESSOA  = '+QuotedStr(FTIPO_PESSOA)+','+
                        ' CPF_CNPJ     = '+QuotedStr(FCPF_CNPJ)+','+
                        ' RG_IE        = '+QuotedStr(FRG_IE)+','+
                        ' ATIVO        = '+QuotedStr(FATIVO)+
                        ' WHERE CODIGO = '+IntToStr(FCODIGO));
    SqlAuxiliar.ExecSQL;

    Commit;
    MessageDlg('Dados Alterados com Sucesso.', mtInformation, [mbOk],0);
  except
    MessageDlg('Erro ao Alterar os Dados'+#13+'Entre em contato com o Administrador do Sistema', mtInformation, [mbOk],0);
  end;
end;

procedure TCliente.AlterarEndereco(cdsEndereco: TClientDataSet);
begin
  cdsEndereco.Filtered := False;
  cdsEndereco.Filter   := 'STATUS = ''A''';
  cdsEndereco.Filtered := True;

  cdsEndereco.First;
  while not cdsEndereco.Eof do
  begin
    with SqlAuxiliar do
    begin
      Close;
      SQL.Text := 'UPDATE CLIENTE_ENDERECO SET '+
                  '       CEP         =:CEP, '+
                  '       LOGRADOURO  =:LOGRADOURO, '+
                  '       NUMERO      =:NUMERO, '+
                  '       BAIRRO      =:BAIRRO, '+
                  '       ESTADO      =:ESTADO, '+
                  '       CIDADE      =:CIDADE, '+
                  '       PAIS        =:PAIS '+
                  ' WHERE COD_CLIENTE =:COD_CLIENTE '+
                  '   AND CEP =:CEP_OLD ';


      ParamByName('COD_CLIENTE').AsString := IntToStr(FCODIGO);
      ParamByName('CEP').AsString         := cdsEndereco.FieldByName('CEP').AsString;
      ParamByName('CEP_OLD').AsString     := cdsEndereco.FieldByName('CEP').OldValue;
      ParamByName('LOGRADOURO').AsString  := cdsEndereco.FieldByName('LOGRADOURO').AsString;
      ParamByName('NUMERO').AsString      := cdsEndereco.FieldByName('NUMERO').AsString;
      ParamByName('BAIRRO').AsString      := cdsEndereco.FieldByName('BAIRRO').AsString;
      ParamByName('ESTADO').AsString      := cdsEndereco.FieldByName('ESTADO').AsString;
      ParamByName('CIDADE').AsString      := cdsEndereco.FieldByName('CIDADE').AsString;
      ParamByName('PAIS').AsString        := cdsEndereco.FieldByName('PAIS').AsString;

      ExecSQL;
    end;
    cdsEndereco.Next;
  end;
end;


procedure TCliente.AlterarFones(cdsTelefones: TClientDataSet);
begin
  cdsTelefones.Filtered := False;
  cdsTelefones.Filter   := 'STATUS = ''A''';
  cdsTelefones.Filtered := True;

  cdsTelefones.First;
  while not cdsTelefones.Eof do
  begin
    with SqlAuxiliar do
    begin
      Close;
      SQL.Text := 'UPDATE CLIENTE_FONE SET '+
                  '       TELEFONE    =:TELEFONE, '+
                  '       OBSERVACAO  =:OBSERVACAO '+
                  ' WHERE COD_CLIENTE =:COD_CLIENTE '+
                  '   AND TELEFONE    =:TELEFONE_OLD ';

      ParamByName('COD_CLIENTE').AsString        := IntToStr(FCODIGO);
      ParamByName('TELEFONE').AsString          := cdsTelefones.FieldByName('TELEFONE').AsString;
      ParamByName('TELEFONE_OLD').AsString      := cdsTelefones.FieldByName('TELEFONE').OldValue;
      ParamByName('OBSERVACAO').AsString        := cdsTelefones.FieldByName('OBSERVACAO').AsString;
      ExecSQL;
    end;
    cdsTelefones.Next;
  end;
end;

procedure TCliente.CarregaEnderecos(cdsEndereco: TClientDataSet);
begin
  cdsEndereco.EmptyDataSet;
  with SqlAuxiliar do
  begin
    Close;
    SQL.Clear;
    SQL.TEXT := ' SELECT CEP, LOGRADOURO, NUMERO, BAIRRO, CIDADE, ESTADO, PAIS '+
                '   FROM CLIENTE_ENDERECO '+
                '  WHERE COD_CLIENTE  = '+IntToStr(FCODIGO);
    Open;

    if not IsEmpty then
    begin
      while not Eof do
      begin
        cdsEndereco.Insert;
//        cdsEndereco.FieldByName('CODIGO').AsString     := FieldByName('CODIGO').AsString;
        cdsEndereco.FieldByName('CEP').AsString        := FieldByName('CEP').AsString;
        cdsEndereco.FieldByName('LOGRADOURO').AsString := FieldByName('LOGRADOURO').AsString;
        cdsEndereco.FieldByName('NUMERO').AsString     := FieldByName('NUMERO').AsString;
        cdsEndereco.FieldByName('BAIRRO').AsString     := FieldByName('BAIRRO').AsString;
        cdsEndereco.FieldByName('CIDADE').AsString     := FieldByName('CIDADE').AsString;
        cdsEndereco.FieldByName('ESTADO').AsString     := FieldByName('ESTADO').AsString;
        cdsEndereco.FieldByName('PAIS').AsString       := FieldByName('PAIS').AsString;
        cdsEndereco.Post;
        Next;
      end;
    end;
  end;
end;

procedure TCliente.CarregaDataSet(sDataSet: TFDQuery);
begin
  sDataSet.Close;
  sDataSet.SQL.Clear;
  sDataSet.SQL.Add(' SELECT DISTINCT '+
                   ' CLIENTES.* '+
                   ' FROM CLIENTES '+
                   ' WHERE 1 = 1 ');

  if (FCODIGO > 0) then
    sDataSet.SQL.Add(' AND CLIENTES.CODIGO = '+IntToStr(FCODIGO));

  if (FNOME <> EmptyStr) then
    sDataSet.SQL.Add(' AND NOME LIKE '+QuotedStr('%'+FNOME+'%'));

  if FCPF_CNPJ <> EmptyStr then
    sDataSet.SQL.Add(' AND CPF_CNPJ LIKE '+QuotedStr('%'+FCPF_CNPJ+'%'));

  sDataSet.SQL.Add('ORDER BY NOME');
  sDataSet.Open;
end;


procedure TCliente.CarregaFones(cdsTelefones: TClientDataSet);
begin
  //cdsTelefones.EmptyDataSet;
  with SqlAuxiliar do
  begin
    Close;
    SQL.Clear;
    SQL.TEXT := ' SELECT COD_CLIENTE, TELEFONE, OBSERVACAO '+
                '   FROM CLIENTE_FONE '+
                '  WHERE COD_CLIENTE  = '+IntToStr(FCODIGO);
    Open;

    if not IsEmpty then
    begin
      while not Eof do
      begin
        cdsTelefones.Insert;
        cdsTelefones.FieldByName('TELEFONE').AsString       := FieldByName('TELEFONE').AsString;
        cdsTelefones.FieldByName('OBSERVACAO').AsString     := FieldByName('OBSERVACAO').AsString;
        cdsTelefones.Post;
        Next;
      end;
    end;
  end;                                                                                         
end;

procedure TCliente.Commit;
begin
  if SqlAuxiliar.Transaction.Active then
    SqlAuxiliar.Transaction.Commit;
end;

constructor TCliente.Create(Sql: TFDQuery);
begin
  FEndereco := TEndereco.Create;

  //Instanciando o objeto para ser usado na classe
  try
    SqlAuxiliar             := TFDQuery.Create(nil);
    SqlAuxiliar.Connection  := Sql.Connection;
    SqlAuxiliar.Transaction := Sql.Transaction;

    if not SqlAuxiliar.Transaction.Active then
      SqlAuxiliar.Transaction.StartTransaction;
  except
    MessageDlg('Erro.'+#13+'Entre em contato com o Administrador do Sistema', mtInformation, [mbOk],0);
  end;
end;

destructor TCliente.Destroy;
begin
  FreeAndNil(SqlAuxiliar);
end;

procedure TCliente.Excluir;
var
  sair : word;
begin
  try
    sair := MessageDlg('Confirma a Exclus?o do Registro Selecionado?', mtConfirmation, mbOKCancel,0);
    if sair = 1 then
    begin
      //Excluindo os telefones do cliente
      SqlAuxiliar.Close;
      SqlAuxiliar.SQL.Text := 'DELETE FROM CLIENTE_FONE WHERE COD_CLIENTE ='+ IntToStr(FCODIGO);
      SqlAuxiliar.ExecSQL;

      //Excluindo os Endere?os do cliente
      SqlAuxiliar.Close;
      SqlAuxiliar.SQL.Text := 'DELETE FROM CLIENTE_ENDERECO WHERE COD_CLIENTE ='+ IntToStr(FCODIGO);
      SqlAuxiliar.ExecSQL;

      //Excluindo o Cliente
      SqlAuxiliar.Close;
      SqlAuxiliar.SQL.Text := 'DELETE FROM CLIENTES WHERE CODIGO ='+ IntToStr(FCODIGO);
      SqlAuxiliar.ExecSQL;

      Commit;
      MessageDlg('Dados Excluidos com Sucesso.', mtInformation, [mbOk],0);
    end;
  except
    MessageDlg('N?o ? poss?vel a exclus?o dos Dados.'+#13+'Entre em contato com o Administrador do Sistema', mtInformation, [mbOk],0);
    Rollback;
  end;
end;

procedure TCliente.ExcluirEndereco(cdsEndereco: TClientDataSet);
begin
  cdsEndereco.Filtered := False;
  cdsEndereco.Filter   := 'STATUS = ''E''';
  cdsEndereco.Filtered := True;

  cdsEndereco.First;
  while not cdsEndereco.Eof do
  begin
    with SqlAuxiliar do
    begin
      Close;
      SQL.Text := 'DELETE FROM CLIENTE_ENDERECO '+
                  ' WHERE COD_CLIENTE =:COD_CLIENTE '+
                  '   AND CEP         =:CEP ';

      ParamByName('COD_CLIENTE').AsString := IntToStr(FCODIGO);
      ParamByName('CEP').AsString := cdsEndereco.FieldByName('CEP').AsString;
      ExecSQL;
    end;
    cdsEndereco.Next;
  end;
end;

procedure TCliente.ExcluirFones(cdsTelefones: TClientDataSet);
begin
  cdsTelefones.Filtered := False;
  cdsTelefones.Filter   := 'STATUS = ''E''';
  cdsTelefones.Filtered := True;

  cdsTelefones.First;
  while not cdsTelefones.Eof do
  begin
    with SqlAuxiliar do
    begin
      Close;
      SQL.Text := 'DELETE FROM CLIENTE_FONE '+
                  ' WHERE COD_CLIENTE =:COD_CLIENTE '+
                  '   AND TELEFONE    =:TELEFONE ';

      ParamByName('COD_CLIENTE').AsString := IntToStr(FCODIGO);
      ParamByName('TELEFONE').AsString    := cdsTelefones.FieldByName('TELEFONE').AsString;
      ExecSQL;
    end;
    cdsTelefones.Next;
  end;
end;

procedure TCliente.Incluir(cdsTelefones, cdsEnderecos : TClientDataSet);
begin
  SqlAuxiliar.Close;
  SqlAuxiliar.SQL.Clear;
  SqlAuxiliar.SQL.Add(' INSERT INTO CLIENTES ('+
                            ' CODIGO,'+
                            ' NOME, '+
                            ' TIPO_PESSOA, '+
                            ' CPF_CNPJ, '+
                            ' RG_IE, '+
                            ' ATIVO '+
                          ') VALUES (   '+
                            ' :CODIGO,'+
                            ' :NOME, '+
                            ' :TIPO_PESSOA, '+
                            ' :CPF_CNPJ, '+
                            ' :RG_IE, '+
                            ' :ATIVO) ');

  SqlAuxiliar.ParamByName('CODIGO').AsInteger     := FCODIGO;
  SqlAuxiliar.ParamByName('NOME').AsString        := FNOME;
  SqlAuxiliar.ParamByName('TIPO_PESSOA').AsString := FTIPO_PESSOA;
  SqlAuxiliar.ParamByName('CPF_CNPJ').AsString    := FCPF_CNPJ;
  SqlAuxiliar.ParamByName('RG_IE').AsString       := FRG_IE;
  SqlAuxiliar.ParamByName('ATIVO').AsString       := FATIVO;

  SqlAuxiliar.ExecSQL;

  InserirFones(cdsTelefones);
  InserirEndereco(cdsEnderecos);

  Commit;

  MessageDlg('Dados Incluidos com Sucesso.', mtInformation, [mbOk],0);
end;

procedure TCliente.InserirEndereco(cdsEndereco: TClientDataSet);
begin
  cdsEndereco.Filtered := False;
  cdsEndereco.Filter   := 'STATUS = ''I''';
  cdsEndereco.Filtered := True;

  cdsEndereco.First;
  with SqlAuxiliar do
  begin
    while not cdsEndereco.Eof do
    begin
      try
        Close;
        SQL.Text := 'INSERT INTO CLIENTE_ENDERECO ('+
                    'COD_CLIENTE,' +
                    'CEP,' +
                    'LOGRADOURO, '+
                    'NUMERO,'+
                    'BAIRRO,' +
                    'ESTADO,' +
                    'CIDADE,' +
                    'PAIS '+
                    ') VALUES (' +
                    ':COD_CLIENTE,' +
                    ':CEP,' +
                    ':LOGRADOURO, '+
                    ':NUMERO,'+
                    ':BAIRRO,' +
                    ':ESTADO,' +
                    ':CIDADE, ' +
                    ':PAIS)';

        ParamByName('COD_CLIENTE').AsString := IntToStr(FCODIGO);
        ParamByName('CEP').AsString         := cdsEndereco.FieldByName('CEP').AsString;
        ParamByName('LOGRADOURO').AsString  := cdsEndereco.FieldByName('LOGRADOURO').AsString;
        ParamByName('NUMERO').AsString      := cdsEndereco.FieldByName('NUMERO').AsString;
        ParamByName('BAIRRO').AsString      := cdsEndereco.FieldByName('BAIRRO').AsString;
        ParamByName('ESTADO').AsString      := cdsEndereco.FieldByName('ESTADO').AsString;
        ParamByName('CIDADE').AsString      := cdsEndereco.FieldByName('CIDADE').AsString;
        ParamByName('PAIS').AsString        := cdsEndereco.FieldByName('PAIS').AsString;

        ExecSQL;

        cdsEndereco.Next;
      except
        Close;
        SQL.Text := 'UPDATE CLIENTE_FONE SET '+
                    '       OCORRENCIA   = OCORRENCIA + :OCORRENCIA '+
                    ' WHERE COD_CLIENTE   =:COD_CLIENTE '+
                    '   AND CEP =:CEP '+
                    '   AND DT_ANOTACAO  =:DT_ANOTACAO '+
                    '   AND COD_PERIODO_LETIVO =:COD_PERIODO_LETIVO';

        ParamByName('COD_CLIENTE').AsString    := IntToStr(FCODIGO);
        ParamByName('CEP').AsString  := cdsEndereco.FieldByName('COD_TIPO_ANOT').AsString;
        ParamByName('OCORRENCIA').AsString    := cdsEndereco.FieldByName('OCORRENCIA').AsString;
        ParamByName('DT_ANOTACAO').AsDateTime := cdsEndereco.FieldByName('DATA_OCORRENCIA').AsDateTime;
        ExecSQL;
        
        cdsEndereco.Next;
      end;
    end;
  end;

  cdsEndereco.Filtered := False;
  cdsEndereco.Filter   := '(STATUS <> ''E'') or (STATUS IS NULL)';
  cdsEndereco.Filtered := True;
end;


procedure TCliente.InserirFones(cdsTelefones: TClientDataSet);
begin
  cdsTelefones.Filtered := False;
  cdsTelefones.Filter   := 'STATUS = ''I''';
  cdsTelefones.Filtered := True;

  cdsTelefones.First;
  while not cdsTelefones.Eof do
  begin
    try
      with SqlAuxiliar do
      begin
        Close;
        SQL.Text := 'INSERT INTO CLIENTE_FONE ('+
                    '       COD_CLIENTE,' +
                    '       TELEFONE,' +
                    '       OBSERVACAO '+
                    '  ) VALUES (' +
                    '       :COD_CLIENTE,' +
                    '       :TELEFONE, '+
                    '       :OBSERVACAO)';

        ParamByName('COD_CLIENTE').AsString := IntToStr(FCODIGO);
        ParamByName('TELEFONE').AsString    := cdsTelefones.FieldByName('TELEFONE').AsString;
        ParamByName('OBSERVACAO').AsString  := cdsTelefones.FieldByName('OBSERVACAO').AsString;
        ExecSQL;
      end;
      cdsTelefones.Next;
    except
      cdsTelefones.Next;
    end;
  end;

  cdsTelefones.Filtered := False;
  cdsTelefones.Filter   := '(STATUS <> ''E'') or (STATUS IS NULL)';
  cdsTelefones.Filtered := True;
end;

procedure TCliente.ProximoCodigo;
begin
  with SqlAuxiliar do
  begin
    Close;
    SQL.Text := 'SELECT GEN_ID(GEN_CLIENTES_ID,1) CODIGO FROM RDB$DATABASE';
    Open;

    CODIGO := FieldByName('CODIGO').AsInteger;
  end;                                    
end;

procedure TCliente.Rollback;
begin
  if SqlAuxiliar.Transaction.Active then
    SqlAuxiliar.Transaction.Rollback;
end;

procedure TCliente.SetCODIGO(const Value: Integer);
begin
  FCODIGO := Value;
end;

procedure TCliente.SetCPF_CNPJ(const Value: String);
begin
  FCPF_CNPJ := Value;
end;

procedure TCliente.SetEndereco(const Value: TEndereco);
begin
  FEndereco := Value;
end;

procedure TCliente.SetNOME(const Value: String);
begin
  FNOME := Trim(Value);
end;

procedure TCliente.SetRG_IE(const Value: String);
begin
  FRG_IE := Value;
end;

procedure TCliente.SetATIVO(const Value: String);
begin
  FATIVO := Value;
end;

procedure TCliente.SetTIPO_PESSOA(const Value: String);
begin
  FTIPO_PESSOA := Value;
end;

procedure TCliente.ConsultaCEP(Cep: String);
var
  tempXML :IXMLNode;
  tempNodePAI :IXMLNode;
  tempNodeFilho :IXMLNode;
  I :Integer;
begin
   DM.XMLDocument1.FileName := 'https://viacep.com.br/ws/'+Trim(Cep)+ '/xml/';
   DM.XMLDocument1.Active := true;
   tempXML := DM.XMLDocument1.DocumentElement;

   tempNodePAI := tempXML.ChildNodes.FindNode('logradouro');

   for i := 0 to tempNodePAI.ChildNodes.Count - 1 do
   begin
     tempNodeFilho := tempNodePAI.ChildNodes[i];
     Endereco.LOGRADOURO := tempNodeFilho.Text;
   end;

   tempNodePAI := tempXML.ChildNodes.FindNode('bairro');
   for i := 0 to tempNodePAI.ChildNodes.Count - 1 do
   begin
     tempNodeFilho := tempNodePAI.ChildNodes[i];
     Endereco.BAIRRO := tempNodeFilho.Text;
   end;

   tempNodePAI := tempXML.ChildNodes.FindNode('localidade');
   for i := 0 to tempNodePAI.ChildNodes.Count - 1 do
   begin
     tempNodeFilho := tempNodePAI.ChildNodes[i];
     Endereco.CIDADE := tempNodeFilho.Text;
   end;

   tempNodePAI := tempXML.ChildNodes.FindNode('uf');
   for i := 0 to tempNodePAI.ChildNodes.Count - 1 do
   begin
     tempNodeFilho := tempNodePAI.ChildNodes[i];
     Endereco.UF := tempNodeFilho.Text;
   end;

end;

end.
