unit uCadCategoria;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTelaHeranca, Data.DB,
  ZAbstractRODataset, ZAbstractDataset, ZDataset, Vcl.Buttons, Vcl.DBCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls, Vcl.ComCtrls, uDTMConexao, cCadCategoria, uEnum;

type
  TfrmCadCategoria = class(TfrmTelaHeranca)
    edtCategoriaid: TLabeledEdit;
    edtDescricao: TLabeledEdit;
    QryListagemcategoriaid: TZIntegerField;
    QryListagemdescricao: TZUnicodeStringField;
    procedure btnFecharClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnAlterarClick(Sender: TObject);
  private
    { Private declarations }
    oCategoria:TCategoria;
    function Apagar:Boolean; override;
    function Gravar(EstadoDoCadastro:TEstadoDoCadastro):Boolean; override;

  public
    { Public declarations }
  end;

var
  frmCadCategoria: TfrmCadCategoria;

implementation

{$R *.dfm}





procedure TfrmCadCategoria.btnAlterarClick(Sender: TObject);
begin
  // Verifique se o registro foi selecionado com sucesso
  if oCategoria.Selecionar(QryListagem.FieldByName('categoriaid').AsInteger) then
  begin
    // Atribua os valores aos campos
    edtCategoriaid.Text := IntToStr(oCategoria.codigo); // Atualiza o campo CategoriaID
    edtDescricao.Text := oCategoria.descricao;           // Atualiza o campo Descrição
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



procedure TfrmCadCategoria.btnFecharClick(Sender: TObject);
begin
  inherited;
Close;
end;

procedure TfrmCadCategoria.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if Assigned(oCategoria) then
  FreeAndNil(oCategoria);
end;

procedure TfrmCadCategoria.FormCreate(Sender: TObject);
begin
  inherited;
  oCategoria:=TCategoria.Create(dtmConexao.ConexaoDB);
end;

function TfrmCadCategoria.Apagar: Boolean;
begin
  if oCategoria.Selecionar(QryListagem.FieldByName('categoriaid').AsInteger) then begin
     Result:=oCategoria.Apagar;
  end;
end;

function TfrmCadCategoria.Gravar(EstadoDoCadastro: TEstadoDoCadastro): Boolean;
begin
  if edtCategoriaid.Text <> EmptyStr then
    oCategoria.codigo := StrToInt(edtCategoriaid.Text)
  else
    oCategoria.codigo := 0;

  oCategoria.descricao := edtDescricao.Text;

  // Atribuição correta do valor ao objeto


  if (EstadoDoCadastro = ecInserir) then
    Result := oCategoria.Gravar
  else if (EstadoDoCadastro = ecAlterar) then
    Result := oCategoria.Atualizar;
end;


end.
