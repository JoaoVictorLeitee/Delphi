unit uCadAcaoAcesso;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTelaHeranca, Data.DB,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, Vcl.Buttons, Vcl.DBCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls, Vcl.ComCtrls,
  cAcaoAcesso, uEnum, uDTMConexao;

type
  TfrmCadAcaoAcesso = class(TfrmTelaHeranca)
    QryListagemacaoacessoid: TZIntegerField;
    QryListagemdescricao: TZUnicodeStringField;
    QryListagemchave: TZUnicodeStringField;
    edtDescricao: TLabeledEdit;
    edtChave: TLabeledEdit;
    edtAcaoID: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnNovoClick(Sender: TObject);
    procedure btnAlterarClick(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    oAcaoAcesso:TAcaoAcesso;
    function Apagar:Boolean; override;
    function Gravar(EstadoDoCadastro:TEstadoDoCadastro):Boolean; override;
  end;

var
  frmCadAcaoAcesso: TfrmCadAcaoAcesso;

implementation

{$R *.dfm}

function TfrmCadAcaoAcesso.Apagar: Boolean;
begin
  if oAcaoAcesso.Selecionar(QryListagem.FieldByName('acaoacessoid').AsInteger) then begin
     Result:=oAcaoAcesso.Apagar;
  end;
end;

procedure TfrmCadAcaoAcesso.btnAlterarClick(Sender: TObject);
begin
  if oAcaoAcesso.Selecionar(QryListagem.FieldByName('acaoacessoid').AsInteger) then begin
    edtAcaoID.text  :=IntToStr(oAcaoAcesso.codigo);
    edtDescricao.Text     :=oAcaoAcesso.descricao;
    edtChave.Text         :=oAcaoAcesso.chave;
  end;
  inherited;
end;

procedure TfrmCadAcaoAcesso.btnFecharClick(Sender: TObject);
begin
  inherited;
Close;
end;

procedure TfrmCadAcaoAcesso.btnGravarClick(Sender: TObject);
begin

  if edtAcaoID.Text <> EmptyStr then
    oAcaoAcesso.codigo := StrToInt(edtAcaoID.Text)
  else
    oAcaoAcesso.codigo := 0;

  oAcaoAcesso.descricao := edtDescricao.Text;
  oAcaoAcesso.chave     := edtChave.text;

    if oAcaoAcesso.ChaveExiste(edtChave.Text, oAcaoAcesso.codigo) then begin
      MessageDlg('Chave já Cadastrada', TMsgDlgType.mtInformation, [mbok], 0);
      edtChave.SetFocus;
      Abort;
    end;

    inherited
end;

procedure TfrmCadAcaoAcesso.btnNovoClick(Sender: TObject);
begin
  inherited;
  edtDescricao.SetFocus;
end;

procedure TfrmCadAcaoAcesso.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  if Assigned(oAcaoAcesso) then
  FreeAndNil(oAcaoAcesso);
end;

procedure TfrmCadAcaoAcesso.FormCreate(Sender: TObject);
begin
  inherited;
  oAcaoAcesso:=TAcaoAcesso.Create(dtmConexao.ConexaoDB);
  IndiceAtual:='descricao';
end;

function TfrmCadAcaoAcesso.Gravar(EstadoDoCadastro: TEstadoDoCadastro): Boolean;
begin
  if (EstadoDoCadastro = ecInserir) then
    Result := oAcaoAcesso.Inserir
  else if (EstadoDoCadastro = ecAlterar) then
    Result := oAcaoAcesso.Atualizar;
end;

end.
