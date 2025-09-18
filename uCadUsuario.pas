unit uCadUsuario;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTelaHeranca, Data.DB,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, Vcl.Buttons, Vcl.DBCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls, Vcl.ComCtrls,
  cCadUsuario, uEnum, uDTMConexao, cAcaoAcesso;

type
  TfrmCadusuario = class(TfrmTelaHeranca)
    QryListagemusuarioid: TZIntegerField;
    QryListagemnome: TZUnicodeStringField;
    QryListagemsenha: TZUnicodeStringField;
    edtUsuarioid: TLabeledEdit;
    edtNome: TLabeledEdit;
    edtSenha: TLabeledEdit;
    procedure btnAlterarClick(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
  private
    { Private declarations }
    oUsuario : TUsuario;
    function Apagar:Boolean; override;
    function Gravar (EstadoDoCadastro:TEstadoDoCadastro):Boolean; override;
  public
    { Public declarations }
  end;

var
  frmCadusuario: TfrmCadusuario;

implementation

{$R *.dfm}

{ TfrmTCadusuario }

function TfrmCadusuario.Apagar: Boolean;
begin
  if oUsuario.Selecionar(QryListagem.FieldByName('usuarioid').AsInteger) then begin
      Result:=oUsuario.Apagar
  end;
end;

procedure TfrmCadusuario.btnAlterarClick(Sender: TObject);
begin
  if oUsuario.Selecionar(QryListagem.FieldByName('usuarioid').AsInteger) then begin
    edtUsuarioid.Text :=IntToStr(oUsuario.codigo);
    edtNome.Text      :=oUsuario.nome;
    edtSenha.Text     :=oUsuario.senha;
  end
  else begin
    btnCancelar.Click;
    Abort
  end;
  inherited
end;


procedure TfrmCadusuario.btnFecharClick(Sender: TObject);
begin
  inherited;
Close;
end;

procedure TfrmCadusuario.btnGravarClick(Sender: TObject);
begin
  if oUsuario.UsuarioExiste(edtNome.Text) then begin
  MessageDlg('Usuário já cadastrado!', TMsgDlgType.mtInformation, [mbok], 0);
  edtNome.SetFocus;
  Abort;
  end;

  if edtUsuarioid.Text <> EmptyStr then
    oUsuario.codigo := StrToInt(edtUsuarioid.Text)
  else
  oUsuario.codigo := 0;

  oUsuario.nome := edtNome.Text;
  oUsuario.senha := edtSenha.Text;

  inherited
end;


procedure TfrmCadusuario.btnNovoClick(Sender: TObject);
begin
  inherited;
edtNome.SetFocus;
end;

procedure TfrmCadusuario.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if Assigned(oUsuario) then
      FreeAndNil(oUsuario);
end;

procedure TfrmCadusuario.FormCreate(Sender: TObject);
begin
  inherited;
  oUsuario := TUsuario.Create(dtmConexao.ConexaoDB);
  indiceAtual := 'nome';
end;

function TfrmCadusuario.Gravar(EstadoDoCadastro: TEstadoDoCadastro): Boolean;
begin
  if EstadoDoCadastro=ecInserir then
    Result:= oUsuario.Inserir
  else if EstadoDoCadastro=ecAlterar then
        Result:=oUsuario.Atualizar;
  TAcaoAcesso.PreencherPermissaoUsuarios(dtmConexao.ConexaoDB);
end;

end.
