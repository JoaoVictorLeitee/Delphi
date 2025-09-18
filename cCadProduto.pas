unit cCadProduto;

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
      System.SysUtils;

type
  TProduto = class
  private
  ConexaoDB:TZConnection;
  F_produtoid:integer;
  F_nome:String;
  F_descricao:String;
  F_valor: Double;
  F_quantidade: Double;
  F_categoriaid: Integer;
  F_quantidademinima: Double;
  F_valorcusto: Double;

public
  constructor Create(aConexao:TZConnection);
  destructor Destroy; override;
  function Inserir:Boolean;
  function Atualizar:Boolean;
  function Apagar:Boolean;
  function Selecionar(id:Integer):Boolean;
published
  property codigo           :integer     read F_produtoid         write F_produtoid;
  property nome             :String      read F_nome              write F_nome;
  property descricao        :String      read F_descricao         write F_descricao;
  property valor            :Double      read F_valor             write F_valor;
  property quantidade       :Double      read F_quantidade        write F_quantidade;
  property categoriaid      :integer     read F_categoriaid       write F_categoriaid;
  property quantidademinima :Double      read F_quantidademinima  write F_quantidademinima;
  property valorcusto       :Double      read F_valorcusto        write F_valorcusto;
  end;

implementation

{ TProduto }

constructor TProduto.Create(aConexao: TZConnection);
begin
  ConexaoDB:=aConexao;
end;

destructor TProduto.Destroy;
begin

  inherited;
end;



function TProduto.Apagar: Boolean;
var Qry:TZQuery;
begin
  if MessageDlg('Apagar o Registro: '+#13+#13+
                  'Código: '+IntToStr(F_produtoid)+#13+
                  'Descrição: '+F_nome,TMsgDlgType.mtConfirmation,[mbYes, mbNo],0)=mrNo then begin
    Result:=False;
    Abort;
  end;
  try
    Result:=True;
    Qry:=TZQuery.Create(nil);
    Qry.Connection:=ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add('DELETE FROM produtos ' + 'WHERE produtoid=:produtoid ');
    Qry.ParamByName('produtoid').AsInteger := F_produtoid;
  try
    Qry.ExecSQL;
  except
    Result:=False;
  end;
  finally
    if Assigned(Qry) then
      FreeAndNil(Qry);
  end;

end;

function TProduto.Atualizar: Boolean;
var
  Qry: TZQuery;
begin
  try
    Result := True;
    Qry := TZQuery.Create(nil);
    Qry.Connection := ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Text := 'UPDATE produtos ' +  // Note o espaço após 'clientes'
                    'SET nome =:nome, ' +
                    'descricao =:descricao, ' +
                    'valor =:valor, ' +
                    'quantidade =:quantidade, ' +
                    'categoriaid =:categoriaid, ' +
                    'quantidademinima =:quantidademinima, ' +
                    'valorcusto =:valorcusto ' +
                    'WHERE produtoid =:produtoid';
    // Atribuição dos parâmetros
    Qry.ParamByName('produtoid').AsInteger      :=Self.F_produtoid;
    Qry.ParamByname('nome').AsString            :=Self.F_nome;
    Qry.ParamByName('descricao').AsString       :=Self.F_descricao;
    Qry.ParamByName('valor').AsFloat            :=Self.F_valor;
    Qry.ParamByName('quantidade').AsFloat       :=Self.F_quantidade;
    Qry.ParamByName('categoriaid').AsInteger    :=Self.F_categoriaid;
    Qry.ParamByName('quantidademinima').AsFloat :=Self.F_quantidademinima;
    Qry.ParamByName('valorcusto').AsFloat       :=Self.F_valorcusto;
    Qry.ExecSQL;

    // Verificar se o registro foi realmente atualizado
    if Qry.RowsAffected > 0 then
    begin
      Result := True;
      MessageDlg('Registro atualizado com sucesso!', mtInformation, [mbOK], 0);
    end
    else
    begin
      MessageDlg('Nenhum registro foi alterado. Verifique os dados.', mtWarning, [mbOK], 0);
    end;

  except
    on E: Exception do
      ShowMessage('Erro ao atualizar cliente: ' + E.Message);
  end;
  FreeAndNil(Qry);
end;


function TProduto.Inserir: Boolean;
var
  Qry: TZQuery;
begin
  try
  Result := True;
  Qry := TZQuery.Create(nil);
  Qry.Connection := ConexaoDB;
  Qry.SQL.Text := 'INSERT INTO produtos (nome,' +
                       'descricao,' +
                       'valor,' +
                       'quantidade,' +
                       'quantidademinima,' +
                       'valorcusto,' +
                       'categoriaid)' +
                  'VALUES (:nome,' +
                       ':descricao,' +
                       ':valor,' +
                       ':quantidade,' +
                       ':quantidademinima,' +
                       ':valorcusto,' +
                       ':categoriaid)';
    Qry.ParamByname('nome').AsString            :=Self.F_nome;
    Qry.ParamByName('descricao').AsString       :=Self.F_descricao;
    Qry.ParamByName('valor').AsFloat            :=Self.F_valor;
    Qry.ParamByName('quantidade').AsFloat       :=Self.F_quantidade;
    Qry.ParamByName('quantidademinima').AsFloat :=Self.F_quantidademinima;
    Qry.ParamByName('valorcusto').AsFloat       :=Self.F_valorcusto;
    Qry.ParamByName('categoriaid').AsInteger    :=Self.F_categoriaid;

    Qry.ExecSQL;

    Result := True;
    MessageDlg('Gravado com sucesso!', mtConfirmation, [mbOK], 0);

  except
    on E: Exception do
      ShowMessage('Erro ao gravar Produto: ' + E.Message);
  end;
  FreeAndNil(Qry);
end;

function TProduto.Selecionar(id: Integer): Boolean;
var
  Qry: TZQuery;
begin
  try
    Result := True;
    Qry := TZQuery.Create(nil);
    Qry.Connection := ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Text := 'SELECT produtoid, "nome", "descricao", "valor", "quantidade", "quantidademinima", "valorcusto", "categoriaid"' +
                ' FROM produtos ' +
                ' WHERE produtoid = :produtoid';
    Qry.ParamByName('produtoid').AsInteger := id;
    try
    Qry.Open;
    Self.F_produtoid        :=Qry.FieldByName('produtoid').AsInteger;
    Self.F_nome             :=Qry.FieldByName('nome').AsString;
    Self.F_descricao        :=Qry.FieldByName('descricao').AsString;
    Self.F_valor            :=Qry.FieldByName('valor').AsFloat;
    Self.F_quantidade       :=Qry.FieldByName('quantidade').AsFloat;
    Self.F_quantidademinima :=Qry.FieldByName('quantidademinima').AsFloat;
    Self.F_valorcusto       :=Qry.FieldByName('valorcusto').AsFloat;
    Self.F_categoriaid      :=Qry.FieldByName('categoriaid').AsInteger;
  Except
      Result:=False
    end;
  finally
    if Assigned(Qry) then
      FreeAndNil(Qry);

  end;
end;

end.
