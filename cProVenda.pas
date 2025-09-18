unit cProVenda;


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
      uEnum,
      cControleEstoque,
      System.SysUtils, uUsuarioLogado;

type
  TVenda = class
  private
  ConexaoDB:TZConnection;
  F_desconto: Double;
  F_produtoid: Integer;
  F_vendaid:integer;
  F_clienteid:integer;
  F_dataVenda:TDateTime;
  F_totalVenda: Double;
  F_formaPagamentoid: Integer;
  F_HoraVenda: TTime;
  F_usuarioid: Integer;
    function InserirItens(cds: TClientDataSet; vendaid: integer): Boolean;
    function ApagaItens(cds: TClientDataSet): Boolean;
    function InNot(cds: TClientDataSet): String;
    function EsteItemExiste(vendaid, produtoid: integer): Boolean;
    function AtualizarItem(cds: TClientDataSet): Boolean;
    procedure RetornarEstoque(sCodigo: String; Acao: TAcaoExcluirEstoque);
    procedure BaixarEstoque(produtoid: Integer; quantidade: Double);

public
  constructor Create(aConexao:TZConnection);
  destructor Destroy; override;
  function Inserir(cds:TClientDataSet):Integer;
  function Atualizar(cds: TClientDataSet; AtualizarItens: Boolean):Boolean;
  function Apagar:Boolean;
  function Selecionar(id:Integer; var cds:TClientDataSet):Boolean;
published
  property horavenda         :TTime       read F_HoraVenda        write F_HoraVenda;
  property formaPagamentoid  :Integer     read F_formaPagamentoid write F_formaPagamentoid;
  property desconto          :Double      read F_desconto         write F_desconto;
  property vendaid           :integer     read F_vendaid          write F_vendaid;
  property clienteid         :integer     read F_clienteid        write F_clienteid;
  property dataVenda         :TDateTime   read F_dataVenda        write F_dataVenda;
  property totalVenda        :Double      read F_totalVenda       write F_totalVenda;
  property usuarioid         :Integer     read F_usuarioid        write F_usuarioid;
  end;

implementation

{ TProduto }



{ TVenda }

constructor TVenda.Create(aConexao: TZConnection);
begin
ConexaoDB:=aConexao;
end;

destructor TVenda.Destroy;
begin

  inherited;
end;

function TVenda.Apagar: Boolean;
var Qry: TZQuery;
begin
  if MessageDlg('Deseja cancelar a venda número ' + IntToStr(vendaid) + '?',
                mtConfirmation, [mbYes, mbNo], 0) = mrNo then
  begin
    Result := False;
    Exit;
  end;

  try
    Result := True;
    ConexaoDB.StartTransaction;
    RetornarEstoque(IntToStr(F_vendaid), aeeApagar); // Retorna estoque

    Qry := TZQuery.Create(nil);
    try
      Qry.Connection := ConexaoDB;
      Qry.SQL.Text := 'UPDATE vendas SET status = ''Cancelada'', usuarioid = :usuarioid WHERE vendaid = :vendaid';
      Qry.ParamByName('vendaid').AsInteger := F_vendaid;
      Qry.ParamByName('usuarioid').AsInteger := F_usuarioid;
      Qry.ExecSQL;
      ConexaoDB.Commit;
      MessageDlg('Venda cancelada com sucesso.', mtInformation, [mbOK], 0);
    except
      on E: Exception do
      begin
        ConexaoDB.Rollback;
        ShowMessage('Erro ao cancelar venda: ' + E.Message);
        Result := False;
      end;
    end;
  finally
    FreeAndNil(Qry);
  end;
end;




function TVenda.Atualizar(cds: TClientDataSet; AtualizarItens: Boolean): Boolean;
var
  Qry: TZQuery;
begin
  Result := False;
  try
    if not ConexaoDB.InTransaction then
      ConexaoDB.StartTransaction;

    Qry := TZQuery.Create(nil);
    Qry.Connection := ConexaoDB;

    Qry.SQL.Text := 'UPDATE vendas SET ' +
                    'clienteid = :clienteid, ' +
                    'usuarioid = :usuarioid, ' +
                    'datavenda = :datavenda, ';

    if AtualizarItens then
    begin
      Qry.SQL.Add('totalvenda = :totalvenda, ');
      Qry.SQL.Add('desconto = :desconto, ');
    end;

    Qry.SQL.Add('formaspagamentoid = :formaspagamentoid ' +
                'WHERE vendaid = :vendaid');

    Qry.ParamByName('vendaid').AsInteger := Self.F_vendaid;
    Qry.ParamByName('clienteid').AsInteger := Self.F_clienteid;
    Qry.ParamByName('usuarioid').AsInteger :=Self.F_usuarioid;
    Qry.ParamByName('datavenda').AsDateTime := Self.F_dataVenda;
    Qry.ParamByName('formaspagamentoid').AsInteger := Self.F_formaPagamentoid;

    if AtualizarItens then
    begin
      Qry.ParamByName('totalvenda').AsFloat := Self.F_totalVenda;
      Qry.ParamByName('desconto').AsFloat := Self.F_desconto;
    end;

    Qry.ExecSQL;

    if AtualizarItens then
    begin
      ApagaItens(cds);

      cds.First;
      while not cds.Eof do
      begin
        if EsteItemExiste(Self.F_vendaid, cds.FieldByName('produtoid').AsInteger) then
          AtualizarItem(cds)
        else
          InserirItens(cds, Self.F_vendaid);

        cds.Next;
      end;
    end;

    ConexaoDB.Commit;
    Result := True;
    MessageDlg('Venda Atualizada com Sucesso!', TMsgDlgType.mtConfirmation, [mbOK], 0);
  except
    on E: Exception do
    begin
      ConexaoDB.Rollback;
      ShowMessage('Erro ao atualizar venda: ' + E.Message);
    end;
  end;
end;


function TVenda.AtualizarItem(cds:TClientDataSet): Boolean;
var
  Qry: TZQuery;
  quantidadeAnterior: Double;
begin
  Result := True;
  Qry := TZQuery.Create(nil);
  try
    Qry.Connection := ConexaoDB;

    // Pega a quantidade anterior no banco
    Qry.SQL.Text := 'SELECT quantidade FROM vendasitens WHERE vendaid = :vendaid AND produtoid = :produtoid';
    Qry.ParamByName('vendaid').AsInteger := Self.F_vendaid;
    Qry.ParamByName('produtoid').AsInteger := cds.FieldByName('produtoid').AsInteger;
    Qry.Open;

    quantidadeAnterior := Qry.FieldByName('quantidade').AsFloat;

    Qry.Close;

    // Atualiza os dados do item
    Qry.SQL.Text :=
      'UPDATE vendasitens ' +
      'SET valorunitario = :valorunitario, ' +
      '    quantidade = :quantidade, ' +
      '    totalproduto = :totalproduto ' +
      'WHERE vendaid = :vendaid AND produtoid = :produtoid';

    Qry.ParamByName('vendaid').AsInteger := Self.F_vendaid;
    Qry.ParamByName('produtoid').AsInteger := cds.FieldByName('produtoid').AsInteger;
    Qry.ParamByName('valorunitario').AsFloat := cds.FieldByName('valorunitario').AsFloat;
    Qry.ParamByName('quantidade').AsFloat := cds.FieldByName('quantidade').AsFloat;
    Qry.ParamByName('totalproduto').AsFloat := cds.FieldByName('totalproduto').AsFloat;
    Qry.ExecSQL;

    // Ajuste de estoque apenas se a quantidade foi alterada
    if quantidadeAnterior <> cds.FieldByName('quantidade').AsFloat then
    begin
      // Retorna o estoque da quantidade anterior
      BaixarEstoque(cds.FieldByName('produtoid').AsInteger, -quantidadeAnterior);
      // Baixa a nova quantidade
      BaixarEstoque(cds.FieldByName('produtoid').AsInteger, cds.FieldByName('quantidade').AsFloat);
    end;
  except
    on E: Exception do
    begin
      Result := False;
      ShowMessage('Erro ao atualizar item da venda: ' + E.Message);
    end;
  end;
  FreeAndNil(Qry);
end;


function TVenda.EsteItemExiste(vendaid: Integer; produtoid: integer): Boolean;
var
  Qry: TZQuery;
begin
  Result := False;
  try
    Qry := TZQuery.Create(nil);
    Qry.Connection := ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add('SELECT COUNT(vendaid) AS Qtde ' +
                'FROM vendasitens ' +
                'WHERE vendaid = :vendaid AND produtoid = :produtoid');
    Qry.ParamByName('vendaid').AsInteger := vendaid;  // Usando o parâmetro correto
    Qry.ParamByName('produtoid').AsInteger := produtoid;  // Usando o parâmetro correto
    Qry.Open;

    if Qry.FieldByName('Qtde').AsInteger > 0 then
      Result := True
    else
      Result := False;
  except
    on E: Exception do
    begin
      ShowMessage('Erro ao verificar existência de item: ' + E.Message);
      Result := False;
    end;
  end;
  if Assigned(Qry) then
    FreeAndNil(Qry);
end;

function TVenda.ApagaItens(cds:TClientDataSet): Boolean;
var Qry:TZQuery;
    sCodNoCds:String;
begin
  try
    Result:=True;
    sCodNoCds:= InNot(cds);
    RetornarEstoque(sCodNoCds, aeeApagar);
    Qry:=TZQuery.Create(nil);
    Qry.Connection:=ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add(' DELETE '+
                ' FROM vendasitens '+
                ' WHERE vendaid=:vendaid '+
                'AND produtoid NOT IN ('+sCodNoCds+') ');
    Qry.ParamByName('vendaid').AsInteger        :=Self.F_vendaid;
  try
    Qry.ExecSQL;
  except
  Result:=False;
  end;

  finally
  if Assigned(Qry) then
  FreeAndNil(Qry)
  end;
end;

function TVenda.InNot(cds:TClientDataSet): String;
var sInNot:String;
begin
  sInNot:=EmptyStr;
  cds.First;
  while not cds.Eof do begin
    if sInNot=EmptyStr then
      sInNot := cds.FieldByName('produtoid').AsString
    else
      sInNot := sInNot +','+cds.FieldByName('produtoid').AsString;

    cds.Next;
  end;
  Result:=sInNot;
end;

function TVenda.Inserir(cds:TClientDataSet): Integer;
var
  Qry: TZQuery;
begin
  try
    // Verificar se a conexão com o banco de dados foi estabelecida
    if (not Assigned(ConexaoDB)) then
    begin
      ShowMessage('Erro: Conexão não inicializada.');
      Exit(-1);
    end;
    Qry := TZQuery.Create(nil);
    try
      Qry.Connection := ConexaoDB;
      ConexaoDB.StartTransaction;
      Qry.SQL.Text := 'INSERT INTO vendas (clienteid, datavenda, totalvenda, desconto, formaspagamentoid, usuarioid, horariovenda) ' +
                      'VALUES (:clienteid, :datavenda, :totalvenda, :desconto, :formaspagamentoid, :usuarioid, :horariovenda) RETURNING vendaid;';

      Qry.ParamByName('clienteid').AsInteger          := Self.F_clienteid;
      Qry.ParamByName('datavenda').AsDateTime         := Self.F_dataVenda;
      Qry.ParamByName('totalvenda').AsFloat           := Self.F_totalVenda;
      Qry.ParamByName('desconto').AsFloat             := Self.F_desconto;
      qry.ParamByName('formaspagamentoid').AsInteger  := Self.F_formaPagamentoid;
      Qry.ParamByName('usuarioid').AsInteger          := Self.F_usuarioid;
      Qry.ParamByName('horariovenda').AsTime          := Self.F_HoraVenda;
      Qry.Open;

      if not Qry.IsEmpty then
        Self.F_vendaid := Qry.FieldByName('vendaid').AsInteger;

      cds.First;
      while not cds.Eof do begin
        InserirItens(cds, Self.F_vendaid);
        cds.Next;
      end;

      ConexaoDB.Commit;
      Result:=F_vendaid;
      MessageDlg('Venda Salva com Sucesso!', TMsgDlgType.mtConfirmation, [mbOK], 0);
    except
      on E: Exception do
      begin
        ConexaoDB.Rollback;
        Result := -1;
        ShowMessage('Erro ao inserir venda: ' + E.Message);
      end;
    end;
  finally
    Qry.Free;
  end;
end;


function TVenda.InserirItens(cds:TClientDataSet; vendaid:integer): Boolean;
var
  Qry: TZQuery;
begin
  Result := True;
  Qry := nil;  // Inicializa Qry como nil

  try
    Qry := TZQuery.Create(nil);  // Criação do objeto Qry
    Qry.Connection := ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add('INSERT INTO vendasitens (vendaid, produtoid, valorunitario, quantidade, totalproduto) ' +
                 'VALUES (:vendaid, :produtoid, :valorunitario, :quantidade, :totalproduto)');

    Qry.ParamByName('vendaid').AsInteger      := vendaid;
    Qry.ParamByName('produtoid').AsInteger    := cds.FieldByName('produtoid').AsInteger;
    Qry.ParamByName('valorunitario').AsFloat  := cds.FieldByName('valorunitario').AsFloat;
    Qry.ParamByName('quantidade').AsFloat     := cds.FieldByName('quantidade').AsFloat;
    Qry.ParamByName('totalproduto').AsFloat   := cds.FieldByName('totalproduto').AsFloat;

    try
      Qry.ExecSQL;  // Executa a inserção
      BaixarEstoque(cds.FieldByName('produtoid').AsInteger, cds.FieldByName('quantidade').AsFloat);
    except
      on E: Exception do
      begin
        Result := False;
        ShowMessage('Erro ao inserir itens da venda: ' + E.Message);
      end;
    end;

  finally
    if Assigned(Qry) then  // Verifica se Qry foi criado antes de tentar liberar
      FreeAndNil(Qry);
  end;
end;




function TVenda.Selecionar(id: Integer; var cds: TClientDataSet): Boolean;
var
  Qry: TZQuery;
begin
  Result := False;

  if cds = nil then
    Exit; // Se cds não estiver inicializado, evita erro

  try
    Qry := TZQuery.Create(nil);
    try
      Qry.Connection := ConexaoDB;
      Qry.SQL.Text := 'SELECT vendaid, clienteid, datavenda, totalvenda, desconto, formaspagamentoid, horariovenda FROM vendas WHERE vendaid = :vendaid';
      Qry.ParamByName('vendaid').AsInteger := id;
      Qry.Open;

      if Qry.IsEmpty then
        Exit; // Nenhum registro encontrado

      // Atribuir valores à classe
      Self.F_vendaid := Qry.FieldByName('vendaid').AsInteger;
      Self.F_clienteid := Qry.FieldByName('clienteid').AsInteger;
      Self.F_dataVenda := Qry.FieldByName('datavenda').AsDateTime;
      Self.F_totalVenda := Qry.FieldByName('totalvenda').AsFloat;
      Self.F_desconto := Qry.FieldByName('desconto').AsFloat; // Adicionado o desconto
      Self.F_formaPagamentoid := Qry.FieldByName('formaspagamentoid').AsInteger;

      Self.F_HoraVenda := Frac(Qry.FieldByName('horariovenda').AsDateTime);






      // Limpa o cds antes de inserir novos dados
      cds.EmptyDataSet;

      // Consulta os itens da venda
      Qry.Close;
      Qry.SQL.Text :=
        'SELECT v.produtoid, p.nome, v.valorunitario, v.quantidade, v.totalproduto, ve.desconto ' +
        'FROM vendasitens v ' +
        'INNER JOIN produtos p ON p.produtoid = v.produtoid ' +
        'INNER JOIN vendas ve ON ve.vendaid = v.vendaid ' +
        'WHERE v.vendaid = :vendaid';

      Qry.ParamByName('vendaid').AsInteger := Self.F_vendaid;
      Qry.Open;

      Qry.First;
      while not Qry.Eof do begin
        cds.Append;
        cds.FieldByName('produtoid').AsInteger := Qry.FieldByName('produtoid').AsInteger;
        cds.FieldByName('nomeproduto').AsString := Qry.FieldByName('nome').AsString;
        cds.FieldByName('valorunitario').AsFloat := Qry.FieldByName('valorunitario').AsFloat;
        cds.FieldByName('quantidade').AsFloat := Qry.FieldByName('quantidade').AsFloat;
        cds.FieldByName('totalproduto').AsFloat := Qry.FieldByName('totalproduto').AsFloat;
        cds.Post;
        Qry.Next;
      end;

      Result := True; // Se chegou até aqui, a seleção foi bem-sucedida
    except
      on E: Exception do
        ShowMessage('Erro ao selecionar venda: ' + E.Message);
    end;
  finally
    FreeAndNil(Qry);
  end;
end;

Procedure TVenda.RetornarEstoque(sCodigo:String; Acao:TAcaoExcluirEstoque);
var Qry:TZQuery;
    oControleEstoque:TControleEstoque;
begin
  Qry := TZQuery.Create(nil);
  Qry.Connection := ConexaoDB;
  Qry.SQL.Clear;
  Qry.SQL.Text := ' SELECT produtoid, quantidade ' +
                  ' FROM vendasitens ' +
                  ' WHERE vendaid =:vendaid ';

  if Acao=aeeApagar then
    Qry.SQL.Add('  AND produtoid NOT IN ('+sCodigo+') ')
  else
    Qry.SQL.Add('  AND produtoid = ('+sCodigo+') ');

  Qry.ParamByName('vendaid').AsInteger    :=Self.F_vendaid;
  try
    oControleEstoque:=TControleEstoque.Create(ConexaoDB);
    Qry.Open;
    Qry.First;
    while not Qry.Eof do begin
    oControleEstoque.produtoid    :=Qry.FieldByName('produtoid').AsInteger;
    oControleEstoque.quantidade   :=Qry.FieldByName('quantidade').AsFloat;
    oControleEstoque.RetornarEstoque;
    Qry.Next;
    end;
  finally
    if Assigned(oControleEstoque) then
        FreeAndNil(oControleEstoque);
  end;
end;

procedure TVenda.BaixarEstoque(produtoid:Integer; quantidade:Double);
var oControleEstoque:TControleEstoque;
begin
  try
    oControleEstoque:=TControleEstoque.Create(ConexaoDB);
    oControleEstoque.produtoid    :=produtoid;
    oControleEstoque.quantidade   :=quantidade;
    oControleEstoque.BaixarEstoque;
  finally
    if Assigned(oControleEstoque) then
        FreeAndNil(oControleEstoque);
  end;

end;

end.
