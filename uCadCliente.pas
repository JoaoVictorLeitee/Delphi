unit uCadCliente;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTelaHeranca, Data.DB,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, Vcl.Buttons, Vcl.DBCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls, Vcl.Mask, uDTMConexao , Vcl.ExtCtrls, Vcl.ComCtrls,
  RxToolEdit, cCadCliente, uENum;

type
  TfrmCadCliente = class(TfrmTelaHeranca)
    edtNome: TLabeledEdit;
    edtClienteId: TLabeledEdit;
    Label2: TLabel;
    edtEndereco: TLabeledEdit;
    edtBairro: TLabeledEdit;
    edtCidade: TLabeledEdit;
    Label3: TLabel;
    edtEmail: TLabeledEdit;
    edtestado: TLabeledEdit;
    edtDataNascimento: TDateEdit;
    edtCep: TMaskEdit;
    edtTelefone: TMaskEdit;
    dbGridCliente: TDBGrid;
    QryListagemclienteid: TZIntegerField;
    QryListagemnome: TZUnicodeStringField;
    QryListagemendereco: TZUnicodeStringField;
    QryListagemcidade: TZUnicodeStringField;
    QryListagembairro: TZUnicodeStringField;
    QryListagemestado: TZUnicodeStringField;
    QryListagemcep: TZUnicodeStringField;
    QryListagemtelefone: TZUnicodeStringField;
    QryListagememail: TZUnicodeStringField;
    QryListagemdatanascimento: TZDateTimeField;
    edtCpf: TMaskEdit;
    Label5: TLabel;
    QryListagemcpf: TZUnicodeStringField;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnNovoClick(Sender: TObject);
    procedure btnAlterarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
  private
    { Private declarations }
    oCliente:Tcliente;
    function Apagar:Boolean; override;
    function Gravar (EstadoDoCadastro:TEstadoDoCadastro):Boolean; override;
  public
    { Public declarations }
  end;

var
  frmCadCliente: TfrmCadCliente;

implementation

{$R *.dfm}

{ TfrmCadCliente }


function TfrmCadCliente.Apagar: Boolean;
begin
  if oCliente.Selecionar(QryListagem.FieldByName('clienteid').AsInteger) then begin
     Result:=oCliente.Apagar;
     QryListagem.Refresh;
  end;
end;

procedure TfrmCadCliente.btnAlterarClick(Sender: TObject);
begin
  if oCliente.Selecionar(QryListagem.FieldByName('clienteid').AsInteger) then
  begin
    edtClienteid.Text             := IntToStr(oCliente.codigo);
    edtNome.Text                  := oCliente.nome;
    edtCpf.Text                   := oCliente.cpf;
    edtCep.Text                   := oCliente.cep;
    edtEndereco.Text              := oCliente.endereco;
    edtBairro.Text                := oCliente.bairro;
    edtCidade.Text                := oCliente.cidade;
    edtTelefone.Text              := oCliente.telefone;
    edtEmail.Text                 := oCliente.email;
    edtestado.Text                := oCliente.estado;
    edtDataNascimento.Date        := oCliente.dataNascimento;

  end
  else begin
    btnCancelar.Click;
    Abort;
  end;
  inherited;
end;



procedure TfrmCadCliente.btnFecharClick(Sender: TObject);
begin
  inherited;
Close;
end;

procedure TfrmCadCliente.btnNovoClick(Sender: TObject);
begin
  inherited;
  //edtDataNascimento.Date:=Date;
  edtClienteid.Clear;
  edtNome.Clear;
  edtCpf.Clear;
  edtCep.Clear;
  edtEndereco.Clear;
  edtBairro.Clear;
  edtCidade.Clear;
  edtTelefone.Clear;
  edtEmail.Clear;
  edtestado.Clear;
  edtDataNascimento.Clear;
  edtNome.SetFocus;
end;

procedure TfrmCadCliente.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if Assigned(oCliente) then
    FreeAndNil(oCliente);
end;

procedure TfrmCadCliente.FormCreate(Sender: TObject);
begin
  inherited;
  oCliente := TCliente.Create(dtmConexao.ConexaoDB);
  indiceAtual := 'nome';
end;

function TfrmCadCliente.Gravar(EstadoDoCadastro: TEstadoDoCadastro): Boolean;
begin
  if edtclienteid.Text <> EmptyStr then
    oCliente.codigo := StrToInt(edtClienteid.Text)
  else
  oCliente.codigo := 0;

  oCliente.nome := edtnome.Text;
  oCliente.cpf := edtCpf.Text;
  oCliente.cep := edtcep.Text;
  oCliente.endereco := edtendereco.Text;
  oCliente.bairro := edtbairro.Text;
  oCliente.cidade := edtcidade.Text;
  oCliente.telefone := edttelefone.Text;
  oCliente.email := edtemail.Text;
  oCliente.estado := edtestado.Text;
  oCliente.datanascimento := edtdatanascimento.Date;

  if (EstadoDoCadastro = ecInserir) then
    Result := oCliente.Inserir
  else if (EstadoDoCadastro = ecAlterar) then
    Result := oCliente.Atualizar;
end;

end.
