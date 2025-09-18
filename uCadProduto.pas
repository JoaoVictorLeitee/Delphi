unit uCadProduto;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTelaHeranca, Data.DB,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, Vcl.Buttons, Vcl.DBCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls, Vcl.ComCtrls,
  RxToolEdit, RxCurrEdit, uEnum, uDtmConexao, cCadProduto;


type
  TfrmCadProduto = class(TfrmTelaHeranca)
    QryListagemprodutoid: TZIntegerField;
    QryListagemnome: TZUnicodeStringField;
    QryListagemdescricao: TZUnicodeStringField;
    QryListagemvalor: TZFMTBCDField;
    QryListagemquantidade: TZFMTBCDField;
    QryListagemcategoriaid: TZIntegerField;
    QryListagemdescricaocategoria: TZUnicodeStringField;
    edtProdutoid: TLabeledEdit;
    edtNome: TLabeledEdit;
    edtDescricao: TMemo;
    Label2: TLabel;
    edtValor: TCurrencyEdit;
    edtQuantidade: TCurrencyEdit;
    Label3: TLabel;
    Label4: TLabel;
    lkpCategoria: TDBLookupComboBox;
    qryCategoria: TZQuery;
    dtsCategoria: TDataSource;
    qryCategoriacategoriaid: TZIntegerField;
    qryCategoriadescricao: TZUnicodeStringField;
    Label5: TLabel;
    edtQuantidadeMinima: TCurrencyEdit;
    Label6: TLabel;
    QryListagemquantidademinima: TZFMTBCDField;
    Label7: TLabel;
    Label8: TLabel;
    edtValorCusto: TCurrencyEdit;
    QryListagemvalorcusto: TZFMTBCDField;
    procedure btnAlterarClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
  private
    { Private declarations }
    oProduto:TProduto;
    function Apagar:Boolean; override;
    function Gravar (EstadoDoCadastro:TEstadoDoCadastro):Boolean; override;
  public
    { Public declarations }
  end;

var
  frmCadProduto: TfrmCadProduto;

implementation
{$R *.dfm}

function TfrmCadProduto.Apagar: Boolean;
begin
  if oProduto.Selecionar(QryListagem.FieldByName('produtoid').AsInteger) then begin
     Result:=oProduto.Apagar;
     //QryListagem.Refresh;
  end;
end;




procedure TfrmCadProduto.btnAlterarClick(Sender: TObject);
begin

if oProduto.Selecionar(QryListagem.FieldByName('produtoid').AsInteger) then
begin
  edtProdutoid.Text           :=IntToStr(oProduto.codigo);
  edtNome.Text                :=oProduto.nome;
  edtDescricao.Text           :=oProduto.descricao;
  lkpCategoria.KeyValue       :=oProduto.categoriaid;
  edtValor.Value              :=oProduto.valor;
  edtQuantidade.Value         :=oProduto.quantidade;
  edtQuantidadeMinima.Value   :=oProduto.quantidademinima;
  edtValorCusto.Value         :=oProduto.valorcusto
end
  else begin
    btnCancelar.Click;
    Abort;
  end;

  inherited;

end;

procedure TfrmCadProduto.btnFecharClick(Sender: TObject);
begin
  inherited;
Close;
end;

procedure TfrmCadProduto.btnNovoClick(Sender: TObject);
begin
  inherited;
edtValorCusto.Clear;
edtProdutoid.Clear;
edtNome.Clear;
edtDescricao.Clear;
edtValor.Clear;
edtQuantidade.Clear;
edtQuantidadeMinima.Clear;
edtNome.SetFocus;
end;

procedure TfrmCadProduto.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
qryCategoria.Close;
if Assigned(oProduto) then
    FreeAndNil(oProduto);
end;

procedure TfrmCadProduto.FormCreate(Sender: TObject);
begin
  inherited;
oProduto:=TProduto.Create(dtmConexao.ConexaoDB);
IndiceAtual:='nome';
end;

procedure TfrmCadProduto.FormShow(Sender: TObject);
begin
  inherited;
qryCategoria.Open;
end;

function TfrmCadProduto.Gravar(EstadoDoCadastro: TEstadoDoCadastro): Boolean;
begin
  if edtProdutoid.Text <> EmptyStr then
    oProduto.codigo := StrToInt(edtProdutoid.Text)
  else
  oProduto.codigo := 0;

  oProduto.nome := edtnome.Text;
  oProduto.descricao := edtDescricao.Text;
  oProduto.categoriaid := lkpCategoria.KeyValue;
  oProduto.valor := edtValor.Value;
  oProduto.quantidade := edtQuantidade.Value;
  oProduto.quantidademinima := edtQuantidadeMinima.Value;
  oProduto.valorcusto := edtValorCusto.Value;

  if (EstadoDoCadastro = ecInserir) then
    Result := oProduto.Inserir
  else if (EstadoDoCadastro = ecAlterar) then
    Result := oProduto.Atualizar;
end;

end.
