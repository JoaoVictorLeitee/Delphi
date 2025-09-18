unit cCompraProdutos;

interface

uses  System.Classes,
      Vcl.Controls,
      Vcl.ExtCtrls,
      Vcl.Dialogs,
      ZAbstractConnection,
      ZConnection,
      ZAbstractRODataset,
      ZAbstractDataset,
      ZDataset,
      System.SysUtils, uDTMConexao, cControleEstoque, uUsuarioLogado;

type
  TCompraProdutos = class
  private
  ConexaoDB:TZConnection;
  F_produtoid:integer;
  F_descricao:String;
  F_valor: Double;
  F_quantidade: Double;
  F_nota: Double;
  F_data_compra: TDateTime;
  F_CompraProdutosid: Integer;
  F_usuarioid: Integer;

public
  constructor Create(aConexao:TZConnection);
  destructor Destroy; override;
  function Inserir:Boolean;
  function Apagar:Boolean;
  function AtualizarEstoque: Boolean;
  function RetornarEstoque: Boolean;
  function Selecionar(id:Integer):Boolean;
published
  property codigo                 :integer     read F_CompraProdutosid  write F_CompraProdutosid;
  property produtoid              :integer     read F_produtoid         write F_produtoid;
  property descricaocompra        :String      read F_descricao         write F_descricao;
  property valorcompra            :Double      read F_valor             write F_valor;
  property quantidadecompra       :Double      read F_quantidade        write F_quantidade;
  property numeronota             :Double      read F_nota              write F_nota;
  property data_compra            :TDateTime   read F_data_compra       write F_data_compra;
  property usuarioid              :Integer     read F_usuarioid         write F_usuarioid;
  end;

implementation

function TCompraProdutos.Apagar: Boolean;
var Qry:TZQuery;
begin
  if MessageDlg('Apagar o Registro: '+#13+#13+
                  'Código: '+IntToStr(F_CompraProdutosid)+#13+
                  'Número da Nota: '+FloatToStr(F_nota),TMsgDlgType.mtConfirmation,[mbYes, mbNo],0)=mrNo then begin
    Result:=False;
    Abort;
  end;
  Result:=True;
  Qry:=TZQuery.Create(nil);
  try
    Qry.Connection:=ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add('DELETE FROM compras ' + 'WHERE compraid=:compraid ');
    Qry.ParamByName('compraid').AsInteger := F_CompraProdutosid;
  try
    Qry.ExecSQL;
    RetornarEstoque;
    MessageDlg('Apagado com sucesso!', mtConfirmation, [mbOK], 0);
  except
    Result:=False;
  end;
  finally
    FreeAndNil(Qry);
  end;

end;

function TCompraProdutos.AtualizarEstoque: Boolean;
 var oControleEstoque:TControleEstoque;
begin
  try
    oControleEstoque:=TControleEstoque.Create(ConexaoDB);
    oControleEstoque.produtoid          :=produtoid;
    oControleEstoque.quantidadecompra   :=quantidadecompra;
    oControleEstoque.CompraProdutos;
  finally
    if Assigned(oControleEstoque) then
        FreeAndNil(oControleEstoque);
  end;
end;

constructor TCompraProdutos.Create(aConexao: TZConnection);
begin
ConexaoDB:=aConexao;
end;

destructor TCompraProdutos.Destroy;
begin

  inherited;
end;

function TCompraProdutos.Inserir: Boolean;
var
  Qry: TZQuery;
begin
  Result := False;
  Qry := TZQuery.Create(nil);
  try
    Qry.Connection := ConexaoDB;
    Qry.SQL.Text := 'INSERT INTO compras (produtoid, descricaocompra, valorcompra, quantidadecompra, numeronota, data_compra, usuarioid) ' +
                      'VALUES (:produtoid, :descricaocompra, :valorcompra, :quantidadecompra, :numeronota, :data_compra, :usuarioid)';
    Qry.ParamByName('produtoid').AsInteger := F_produtoid;
    Qry.ParamByName('descricaocompra').AsString := F_descricao;
    Qry.ParamByName('valorcompra').AsFloat := F_valor;
    Qry.ParamByName('quantidadecompra').AsFloat := F_quantidade;
    Qry.ParamByName('numeronota').AsFloat := F_nota;
    Qry.ParamByName('data_compra').AsDateTime := F_data_compra;
    Qry.ParamByName('usuarioid').AsInteger := F_usuarioid;

    Qry.ExecSQL;
    AtualizarEstoque;
    Result := True;
    MessageDlg('Gravado com sucesso!', mtConfirmation, [mbOK], 0);

  except
    on E: Exception do
      ShowMessage('Erro ao gravar Produto: ' + E.Message);
  end;
  FreeAndNil(Qry);
end;

function TCompraProdutos.RetornarEstoque: Boolean;
var oControleEstoque:TControleEstoque;
begin
  try
    oControleEstoque:=TControleEstoque.Create(ConexaoDB);
    oControleEstoque.produtoid          :=produtoid;
    oControleEstoque.quantidadecompra   :=quantidadecompra;
    oControleEstoque.RetornarEstoqueCompra;
  finally
    if Assigned(oControleEstoque) then
        FreeAndNil(oControleEstoque);
  end;
end;

function TCompraProdutos.Selecionar(id: Integer): Boolean;
var
  Qry: TZQuery;
begin
  Result := False;
  Qry := TZQuery.Create(nil);
  Qry.Connection := ConexaoDB;
  try
    Qry.SQL.Clear;
    Qry.SQL.Text := 'SELECT compraid, descricaocompra, valorcompra, quantidadecompra, numeronota, produtoid, data_compra ' +
                    'FROM compras ' +
                    'WHERE compraid = :compraid';
    Qry.ParamByName('compraid').AsInteger := id;
    Qry.Open;

    if not Qry.IsEmpty then
    begin
      Self.F_CompraProdutosid := Qry.FieldByName('compraid').AsInteger;
      Self.F_descricao        := Qry.FieldByName('descricaocompra').AsString;
      Self.F_valor            := Qry.FieldByName('valorcompra').AsFloat;
      Self.F_quantidade       := Qry.FieldByName('quantidadecompra').AsFloat;
      Self.F_nota             := Qry.FieldByName('numeronota').AsFloat;
      Self.F_produtoid        := Qry.FieldByName('produtoid').AsInteger;
      Self.F_data_compra      := Qry.FieldByName('data_compra').AsDateTime;
      Result := True;
    end;
  finally
    Qry.Free;
  end;
end;


end.
