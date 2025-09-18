unit uCadFormaPagamento;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTelaHeranca, Data.DB,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, Vcl.Buttons, Vcl.DBCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls, Vcl.ComCtrls, uDTMConexao, uEnum,
  cFormasPagamento;

type
  TfrmFormasPagamento = class(TfrmTelaHeranca)
    edtDescricao: TLabeledEdit;
    edtFormaPagamentoid: TLabeledEdit;
    QryListagemformaspagamentoid: TZIntegerField;
    QryListagemdescricao: TZUnicodeStringField;
    procedure btnFecharClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnAlterarClick(Sender: TObject);
  private
    { Private declarations }
    oFormaPagamento:TFormasPagamento;
    function Apagar:Boolean; override;
    function Gravar(EstadoDoCadastro:TEstadoDoCadastro):Boolean; override;
  public
    { Public declarations }
  end;

var
  frmFormasPagamento: TfrmFormasPagamento;

implementation

{$R *.dfm}


procedure TfrmFormasPagamento.btnAlterarClick(Sender: TObject);
begin
  // Verifique se o registro foi selecionado com sucesso
  if oFormaPagamento.Selecionar(QryListagem.FieldByName('formaspagamentoid').AsInteger) then
  begin
    // Atribua os valores aos campos
    edtFormaPagamentoid.Text := IntToStr(oFormaPagamento.codigo); // Atualiza o campo CategoriaID
    edtDescricao.Text := oFormaPagamento.descricao;           // Atualiza o campo Descrição
   // Atualiza o campo Valor com 2 casas decimais

    // Exibe para depuração (certifique-se de que os valores estão sendo atribuídos corretamente)
    //ShowMessage('CategoriaID: ' + edtCategoriaid.Text + ', Descrição: ' + edtDescricao.Text + ', Valor: ' + editValorId.Text);
  end
  else
  begin
    // Se não encontrar o registro, cancela a operação
    ShowMessage('Nenhum registro encontrado.');
    btnCancelar.Click;
    Abort;
  end;

  inherited;
end;



procedure TfrmFormasPagamento.btnFecharClick(Sender: TObject);
begin
  inherited;
Close;
end;

procedure TfrmFormasPagamento.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if Assigned(oFormaPagamento) then
  FreeAndNil(oFormaPagamento);
end;

procedure TfrmFormasPagamento.FormCreate(Sender: TObject);
begin
  inherited;
  oFormaPagamento:=TFormasPagamento.Create(dtmConexao.ConexaoDB);
end;

function TfrmFormasPagamento.Apagar: Boolean;
begin
  if oFormaPagamento.Selecionar(QryListagem.FieldByName('formaspagamentoid').AsInteger) then begin
     Result:=oFormaPagamento.Apagar;
  end;
end;

function TfrmFormasPagamento.Gravar(EstadoDoCadastro: TEstadoDoCadastro): Boolean;
begin
  if edtFormaPagamentoid.Text <> EmptyStr then
    oFormaPagamento.codigo := StrToInt(edtFormaPagamentoid.Text)
  else
    oFormaPagamento.codigo := 0;

  oFormaPagamento.descricao := edtDescricao.Text;

  // Atribuição correta do valor ao objeto


  if (EstadoDoCadastro = ecInserir) then
    Result := oFormaPagamento.Gravar
  else if (EstadoDoCadastro = ecAlterar) then
    Result := oFormaPagamento.Atualizar;
end;


end.
