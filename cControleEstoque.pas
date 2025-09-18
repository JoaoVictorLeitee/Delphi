unit cControleEstoque;

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
      Data.DB,
      DataSnap.DBClient,
      System.SysUtils;


type
TControleEstoque = class
  private
    ConexaoDB:TZConnection;
    F_Produtoid:integer;
    F_Quantidade:Double;
    F_quantidadecompra: Double;


  public
    constructor Create(aConexao:TZConnection);
    destructor Destroy; override;
    function BaixarEstoque: Boolean;
    function RetornarEstoque: Boolean;
    function CompraProdutos: Boolean;
    function RetornarEstoqueCompra: Boolean;
  published
    property produtoid        :Integer      read F_produtoid         write F_produtoid;
    property quantidade       :Double       read F_quantidade        write F_quantidade;
    property quantidadecompra :Double       read F_quantidadecompra  write F_quantidadecompra;
  end;

implementation

{ TControleEstoque }

constructor TControleEstoque.Create(aConexao: TZConnection);
begin
  ConexaoDB:=aConexao;
end;

destructor TControleEstoque.Destroy;
begin

  inherited;
end;

function TControleEstoque.BaixarEstoque: Boolean;
var Qry:TZQuery;
begin
try
  Result := True;
  Qry := TZQuery.Create(nil);
  Qry.Connection := ConexaoDB;
  Qry.SQL.Clear;
  Qry.SQL.Text := ' UPDATE produtos ' +
                  ' SET quantidade = quantidade - :qtdeBaixa ' +
                  ' WHERE produtoid =:produtoid ';

   Qry.ParamByName('produtoid').AsInteger     :=produtoid;
   Qry.ParamByname('qtdeBaixa').AsFloat       :=quantidade;

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

function TControleEstoque.RetornarEstoque: Boolean;
var Qry:TZQuery;
begin
try
  Result := True;
  Qry := TZQuery.Create(nil);
  Qry.Connection := ConexaoDB;
  Qry.SQL.Clear;
  Qry.SQL.Text := ' UPDATE produtos ' +
                  ' SET quantidade = quantidade + :qtdeRetorno ' +
                  ' WHERE produtoid =:produtoid ';

   Qry.ParamByName('produtoid').AsInteger     :=produtoid;
   Qry.ParamByname('qtdeRetorno').AsFloat     :=quantidade;

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

function TControleEstoque.CompraProdutos: Boolean;
var Qry:TZQuery;
begin
  Result := True;
  Qry := TZQuery.Create(nil);
  Qry.Connection := ConexaoDB;
try
  Qry.Connection := ConexaoDB;
  Qry.SQL.Clear;
  Qry.SQL.Text := ' UPDATE produtos ' +
                  ' SET quantidade = quantidade + :qtdeCompra ' +
                  ' WHERE produtoid =:produtoid ';

   Qry.ParamByName('produtoid').AsInteger     :=produtoid;
   Qry.ParamByname('qtdeCompra').AsFloat      :=quantidadecompra;

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

function TControleEstoque.RetornarEstoqueCompra: Boolean;
var Qry:TZQuery;
begin
try
  Result := True;
  Qry := TZQuery.Create(nil);
  Qry.Connection := ConexaoDB;
  Qry.SQL.Clear;
  Qry.SQL.Text := ' UPDATE produtos ' +
                  ' SET quantidade = quantidade - :qtdeRetorno ' +
                  ' WHERE produtoid =:produtoid ';

   Qry.ParamByName('produtoid').AsInteger     :=produtoid;
   Qry.ParamByname('qtdeRetorno').AsFloat     :=quantidadecompra;

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


end.
