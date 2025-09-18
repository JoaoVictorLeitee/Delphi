unit uProVendas;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTelaHeranca, Data.DB,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, Vcl.Buttons, Vcl.DBCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls, Vcl.ComCtrls,
  uDTMConexao, uDTMVenda, RxToolEdit, RxCurrEdit, uEnum, cProVenda, uRelProVenda,
  cFormasPagamento,  uLogin, uUsuarioLogado;

type
  TfrmProVenda = class(TfrmTelaHeranca)
    QryListagemvendaid: TZIntegerField;
    QryListagemclienteid: TZIntegerField;
    QryListagemnome: TZUnicodeStringField;
    QryListagemdatavenda: TZDateTimeField;
    QryListagemtotalvenda: TZFMTBCDField;
    edtVendaId: TLabeledEdit;
    lkpCliente: TDBLookupComboBox;
    Label5: TLabel;
    Label4: TLabel;
    edtDataVenda: TDateEdit;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    edtValorTotal: TCurrencyEdit;
    Label3: TLabel;
    dbgridItensVenda: TDBGrid;
    Label2: TLabel;
    lkpProduto: TDBLookupComboBox;
    edtValorUnitario: TCurrencyEdit;
    Label6: TLabel;
    edtQuantidade: TCurrencyEdit;
    edtTotalProduto: TCurrencyEdit;
    Label7: TLabel;
    Label8: TLabel;
    btnAdicionarItem: TBitBtn;
    btnApagarItem: TBitBtn;
    edtDesconto: TCurrencyEdit;
    Label9: TLabel;
    QryListagemdesconto: TZBCDField;
    lkpFormasPagamento: TDBLookupComboBox;
    Label10: TLabel;
    QryFormaPagamento: TZQuery;
    DataSource2: TDataSource;
    btnImprimir: TBitBtn;
    QryListagemdescricao: TZUnicodeStringField;
    Label11: TLabel;
    HoraVenda: TMaskEdit;
    QryListagemnome_usuario: TZUnicodeStringField;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnFecharClick(Sender: TObject);
    procedure btnAlterarClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnAdicionarItemClick(Sender: TObject);
    procedure lkpProdutoExit(Sender: TObject);
    procedure edtQuantidadeExit(Sender: TObject);
    procedure edtQuantidadeEnter(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
    procedure btnApagarItemClick(Sender: TObject);
    procedure dbgridItensVendaDblClick(Sender: TObject);
    procedure btnImprimirClick(Sender: TObject);
  private
    { Private declarations }
    dtmVenda:tdtmVenda;
    oVenda:TVenda;
    F_usuarioid: Integer;
    function Gravar(EstadoDoCadastro:TEstadoDoCadastro):Boolean; override;
    function Apagar:Boolean; override;
    function TotalizarProduto(valorUnitario, Quantidade: Double): Double;
    procedure LimparComponenteItem;
    procedure LimparCds;
    procedure CarregarRegistroSelecionado;
    procedure LimparComponenteCliente;
    function TotalizarVenda: Double;
    procedure LimparValorVenda;
    procedure LimparComponenteFormasPagamento;
    procedure PreencherDadosVenda;
    procedure SetUsuarioid(usuarioid: Integer);
  public
    { Public declarations }
  end;

var
  frmProVenda: TfrmProVenda;


implementation

{$R *.dfm}
//SELECT   vendas.vendaid,
//                vendas.clienteid,
//	clientes.nome,
//	vendas.datavenda,
//	vendas.totalvenda,
//                vendas.desconto

//FROM vendas
//INNER JOIN clientes ON clientes.clienteid = vendas.clienteid

//procedure TfrmProVenda.FormShow(Sender: TObject);
//begin
//  inherited;
//  oUsuarioLogado := TUsuarioLogado.Create;
//  StpVenda.Panels[0].Text := 'Usuário: ' + oUsuarioLogado.nome;
//end;

function TfrmProVenda.Apagar: Boolean;
begin
  if oVenda.Selecionar(QryListagem.FieldByName('vendaid').AsInteger, dtmVenda.cdsItensVenda) then begin
    oVenda.usuarioid := oUsuarioLogado.codigo;
    Result:=oVenda.Apagar;
  end;
end;

function TfrmProVenda.Gravar(EstadoDoCadastro: TEstadoDoCadastro): Boolean;
var
  valorFinal: Double;
begin
  if (lkpCliente.KeyValue = Null) then
    begin
      MessageDlg('Selecione um Cliente.', mtWarning, [mbOK], 0);
      Exit(False);
    end;

  if (lkpFormasPagamento.KeyValue = Null) then
    begin
      MessageDlg('Selecione uma Forma de Pagamento.', mtWarning, [mbOK], 0);
      Exit(False);
    end;
  if edtVendaId.Text <> EmptyStr then
    oVenda.vendaid := StrToInt(edtVendaId.Text)
  else
    oVenda.vendaid := 0;

  oVenda.clienteid  := lkpCliente.KeyValue;
  oVenda.formaPagamentoid := lkpFormasPagamento.KeyValue;
  oVenda.dataVenda  := edtDataVenda.Date;
  oVenda.totalVenda := edtValorTotal.Value;
  oVenda.HoraVenda := Time;
  oVenda.usuarioid := oUsuarioLogado.codigo;
  oVenda.desconto := edtDesconto.Value;
  valorFinal := edtValorTotal.Value - oVenda.desconto;

  // Garante que o valor final não seja negativo
  if valorFinal < 0 then
    valorFinal := 0;

  oVenda.totalVenda := valorFinal;

  if (EstadoDoCadastro = ecInserir) then
    oVenda.vendaid := oVenda.Inserir(dtmVenda.cdsItensVenda)
  else if (EstadoDoCadastro = ecAlterar) then
    oVenda.Atualizar(dtmVenda.cdsItensVenda, True);

  // Verifica se o ID da venda foi gerado corretamente
  if oVenda.vendaid <= 0 then
  begin
    ShowMessage('Erro: ID da venda inválido.');
    Exit;
  end;

  frmRelProVenda:=TfrmRelProVenda.Create(Self);
  frmRelProVenda.QryProVenda.Close;
  frmRelProVenda.QryProVenda.ParamByName('vendaid').AsInteger:=oVenda.vendaid;
  frmRelProVenda.QryProVenda.Open;

  if frmRelProVenda.QryProVenda.IsEmpty then
  begin
    ShowMessage('Nenhum dado encontrado para a venda ID ' + IntToStr(oVenda.vendaid));
    frmRelProVenda.Free;
    Exit;
  end;

  frmRelProVenda.qryVendasItens.Close;
  frmRelProVenda.qryVendasItens.ParamByName('vendaid').AsInteger:=oVenda.vendaid;
  frmRelProVenda.qryVendasItens.Open;

  frmRelProVenda.RelatorioProVenda.PreviewModal;
  frmRelProVenda.Release;

  Result:=True;
end;



procedure TfrmProVenda.btnImprimirClick(Sender: TObject);
begin
  frmRelProVenda:=TfrmRelProVenda.Create(Self);
  frmRelProVenda.QryProVenda.Close;
  frmRelProVenda.QryProVenda.ParamByName('vendaid').AsInteger:=oVenda.vendaid;
  frmRelProVenda.QryProVenda.Open;
  frmRelProVenda.qryVendasItens.Close;
  frmRelProVenda.qryVendasItens.ParamByName('vendaid').AsInteger:=oVenda.vendaid;
  frmRelProVenda.qryVendasItens.Open;
  frmRelProVenda.RelatorioProVenda.PreviewModal;
  frmRelProVenda.Release;

end;



procedure TfrmProVenda.lkpProdutoExit(Sender: TObject);
begin
  inherited;
  if TDBLookupComboBox(Sender).KeyValue<>Null then begin
       edtValorUnitario.Value:=dtmVenda.qryProdutos.FieldByName('valor').AsFloat;
       edtQuantidade.Value:=1;
       edtTotalProduto.Value:=TotalizarProduto(edtValorUnitario.Value, edtQuantidade.Value);
  end;

end;

procedure TfrmProVenda.btnAdicionarItemClick(Sender: TObject);
var
  QryEstoque: TZQuery;
  produtoID: Integer;
  quantidadeSolicitada, quantidadeDisponivel: Double;
begin
  inherited;

  if lkpProduto.KeyValue = Null then
  begin
    MessageDlg('O Produto é um campo obrigatório', mtInformation, [mbOK], 0);
    lkpProduto.SetFocus;
    Abort;
  end;

  if edtValorUnitario.Value <= 0 then
  begin
    MessageDlg('O Valor Unitário não pode ser zero', mtInformation, [mbOK], 0);
    edtValorUnitario.SetFocus;
    Abort;
  end;

  if edtQuantidade.Value <= 0 then
  begin
    MessageDlg('Quantidade não pode ser zero', mtInformation, [mbOK], 0);
    edtQuantidade.SetFocus;
    Abort;
  end;

  if dtmVenda.cdsItensVenda.Locate('produtoid', lkpProduto.KeyValue, []) then
  begin
    MessageDlg('Este Produto já foi selecionado', mtInformation, [mbOK], 0);
    lkpProduto.SetFocus;
    Abort;
  end;

  // Verificação de estoque (coluna 'quantidade')
  QryEstoque := TZQuery.Create(nil);
  try
    QryEstoque.Connection := dtmConexao.ConexaoDB;
    QryEstoque.SQL.Text := 'SELECT quantidade FROM produtos WHERE produtoid = :produtoid';
    QryEstoque.ParamByName('produtoid').AsInteger := lkpProduto.KeyValue;
    QryEstoque.Open;

    if not QryEstoque.IsEmpty then
    begin
      quantidadeDisponivel := QryEstoque.FieldByName('quantidade').AsFloat;
      quantidadeSolicitada := edtQuantidade.Value;

      if quantidadeSolicitada > quantidadeDisponivel then
      begin
        MessageDlg(
          'Estoque insuficiente para este produto!' + sLineBreak +
          'Quantidade disponível: ' + FloatToStr(quantidadeDisponivel),
          mtWarning, [mbOK], 0
        );
        edtQuantidade.SetFocus;
        Abort;
      end;
    end
    else
    begin
      MessageDlg('Produto não encontrado na base de dados.', mtError, [mbOK], 0);
      Abort;
    end;
  finally
    QryEstoque.Free;
  end;

  // Adiciona o item normalmente
  edtTotalProduto.Value := TotalizarProduto(edtValorUnitario.Value, edtQuantidade.Value);

  dtmVenda.cdsItensVenda.Append;
  dtmVenda.cdsItensVenda.FieldByName('produtoid').AsString := lkpProduto.KeyValue;
  dtmVenda.cdsItensVenda.FieldByName('nomeproduto').AsString := dtmVenda.qryProdutos.FieldByName('nome').AsString;
  dtmVenda.cdsItensVenda.FieldByName('quantidade').AsFloat := edtQuantidade.Value;
  dtmVenda.cdsItensVenda.FieldByName('valorunitario').AsFloat := edtValorUnitario.Value;
  dtmVenda.cdsItensVenda.FieldByName('totalproduto').AsFloat := edtTotalProduto.Value;
  dtmVenda.cdsItensVenda.Post;

  edtValorTotal.Value := TotalizarVenda;
  LimparComponenteItem;
  lkpProduto.SetFocus;
end;


procedure TfrmProVenda.LimparComponenteItem;
begin
  lkpProduto.KeyValue     :=null;
  edtQuantidade.Value     :=0;
  edtValorUnitario.Value  :=0;
  edtTotalProduto.Value   :=0;
end;
procedure TfrmProVenda.LimparComponenteCliente;
begin
  lkpCliente.KeyValue     :=null;
end;

procedure TfrmProVenda.LimparComponenteFormasPagamento;
begin
  lkpFormasPagamento.KeyValue     :=null;
end;


procedure TfrmProVenda.LimparValorVenda;
begin
  edtValorTotal.Value     :=0;
end;


function TfrmProVenda.TotalizarProduto(valorUnitario, Quantidade:Double):Double;
begin
  Result:=valorUnitario * Quantidade;
end;

procedure TfrmProVenda.LimparCds;
begin
  dtmVenda.cdsItensVenda.First;
  while not dtmVenda.cdsItensVenda.Eof do
    dtmVenda.cdsItensVenda.Delete;
    dtmVenda.cdsItensVenda.EmptyDataSet;
    dtmVenda.cdsItensVenda.Open;
end;

procedure TfrmProVenda.btnAlterarClick(Sender: TObject);
begin
  if oVenda.Selecionar(QryListagem.FieldByName('vendaid').AsInteger, dtmVenda.cdsItensVenda) then
  begin
    edtVendaId.Text    := IntToStr(oVenda.vendaid);
    lkpCliente.KeyValue := oVenda.clienteid;
    edtDataVenda.Date  := oVenda.dataVenda;
    edtValorTotal.Value := oVenda.totalVenda;
    edtDesconto.Value := oVenda.desconto; // Carregar o desconto correto
    lkpFormasPagamento.KeyValue := oVenda.formaPagamentoid;

    PreencherDadosVenda; // Atualiza a hora corretamente
  end
  else
  begin
    btnCancelar.Click;
    Abort;
  end;
  inherited;
end;

procedure TfrmProVenda.PreencherDadosVenda;
begin
  if oVenda.HoraVenda > 0 then
    HoraVenda.Text := FormatDateTime('HH:NN:SS', oVenda.HoraVenda) // Usa a hora do banco
  else
    HoraVenda.Text := FormatDateTime('HH:NN:SS', Now); // Usa a hora atual apenas se estiver vazia
end;



procedure TfrmProVenda.SetUsuarioid(usuarioid: Integer);
begin
  F_usuarioid := usuarioid;
end;


procedure TfrmProVenda.btnApagarItemClick(Sender: TObject);
begin
  inherited;
  if lkpProduto.KeyValue=Null then begin
    MessageDlg('Selecione o Produto a ser excluído' ,TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], 0);
    dbgridItensVenda.SetFocus;
    Abort;
  end;
  if dtmVenda.cdsItensVenda.Locate('produtoid', lkpProduto.KeyValue, []) then begin
    dtmVenda.cdsItensVenda.Delete;
    edtValorTotal.Value:=TotalizarVenda;
    LimparComponenteItem;
  end;
end;

procedure TfrmProVenda.btnCancelarClick(Sender: TObject);
begin
  inherited;
LimparCds;
LimparComponenteCliente;
end;

procedure TfrmProVenda.btnFecharClick(Sender: TObject);
begin
  inherited;
Close;
end;

procedure TfrmProVenda.btnGravarClick(Sender: TObject);
begin
  inherited;
LimparCds;
LimparComponenteCliente;
LimparComponenteFormasPagamento;
end;



procedure TfrmProVenda.btnNovoClick(Sender: TObject);
begin
  inherited;
  edtDataVenda.Date:=Date;
  lkpCliente.SetFocus;
  LimparCds;
  LimparComponenteCliente;
  LimparValorVenda;
  edtDesconto.Clear;
  LimparComponenteFormasPagamento;
end;

procedure TfrmProVenda.edtQuantidadeEnter(Sender: TObject);
begin
  inherited;
  edtTotalProduto.Value:=TotalizarProduto(edtValorUnitario.Value, edtQuantidade.Value);
end;

procedure TfrmProVenda.edtQuantidadeExit(Sender: TObject);
begin
  inherited;
   edtTotalProduto.Value:=TotalizarProduto(edtValorUnitario.Value, edtQuantidade.Value);
end;

procedure TfrmProVenda.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if Assigned(dtmVenda) then
    FreeAndNil(dtmVenda);
  if Assigned(oVenda) then
    FreeAndNil(oVenda);
end;

procedure TfrmProVenda.FormCreate(Sender: TObject);
begin
  inherited;
  dtmVenda := tdtmVenda.Create(Self);
  oVenda := TVenda.Create(dtmConexao.ConexaoDB);

  IndiceAtual := 'clienteid';
end;


procedure TfrmProVenda.CarregarRegistroSelecionado;
begin
  lkpProduto.KeyValue :=dtmVenda.cdsItensVenda.FieldByName('produtoid').AsString;
  edtQuantidade.Value :=dtmVenda.cdsItensVenda.FieldByName('quantidade').AsFloat;
  edtValorunitario.Value :=dtmVenda.cdsItensVenda.FieldByName('valorunitario').AsFloat;
  edtTotalProduto.Value :=dtmVenda.cdsItensVenda.FieldByName('totalproduto').AsFloat;
  edtDesconto.Value :=dtmVenda.cdsItensVenda.FieldByName('desconto').AsFloat;
end;

procedure TfrmProVenda.dbgridItensVendaDblClick(Sender: TObject);
begin
  inherited;
  CarregarRegistroSelecionado;
end;

function TfrmProVenda.TotalizarVenda: Double;
begin
  Result := 0;
  dtmVenda.cdsItensVenda.First;
  while not dtmVenda.cdsItensVenda.Eof do
  begin
    Result := Result + dtmVenda.cdsItensVenda.FieldByName('totalproduto').AsFloat;
    dtmVenda.cdsItensVenda.Next;
  end;

  // Aplicar o desconto ao total da venda
  Result := Result - edtDesconto.Value;
end;


end.
