unit cFormasPagamento;

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
  TFormasPagamento = class

private
ConexaoDB:TZConnection;
F_FormasPagamentoid:integer;
F_descricao:String;
    function GetCodigo: integer;
    function getDescricao: string;
    procedure setCodigo(const Value: integer);
    procedure setDescricao(const Value: string);
public
    constructor Create(aConexao:TZConnection);
    destructor Destroy; override;
    function Gravar:Boolean;
    function Atualizar:Boolean;
    function Apagar:Boolean;
    function Selecionar(id:Integer):Boolean;

published
  property codigo:integer   read GetCodigo    write setCodigo;
  property descricao:string read getDescricao write setDescricao;
end;

implementation

{ TCategoria }


function TFormasPagamento.Gravar: Boolean;
var
  Qry: TZQuery;
begin
  Result := False;
  Qry := TZQuery.Create(nil);
  try
    Qry.Connection := ConexaoDB;

    // Exibe os valores antes de inserir para depuração
    ShowMessage('Descrição: ' + Self.F_descricao );

    Qry.SQL.Text := 'INSERT INTO formaspagamento (descricao) VALUES (:descricao)';
    Qry.ParamByName('descricao').AsString := Self.F_descricao;

    Qry.ExecSQL;
    Result := True;
    MessageDlg('Gravado com sucesso!', mtConfirmation, [mbOK], 0);

  except
    on E: Exception do
      ShowMessage('Erro ao gravar categoria: ' + E.Message);
  end;
  FreeAndNil(Qry);
end;




function TFormasPagamento.Selecionar(id: Integer): Boolean;
var
  Qry: TZQuery;
begin
  Result := False;
  Qry := TZQuery.Create(nil);
  try
    Qry.Connection := ConexaoDB;
    Qry.SQL.Text := 'SELECT formaspagamentoid, descricao FROM formaspagamento WHERE formaspagamentoid = :formaspagamentoid';
    Qry.ParamByName('formaspagamentoid').AsInteger := id;
    Qry.Open;

    if not Qry.IsEmpty then
    begin
      F_FormasPagamentoid := Qry.FieldByName('formaspagamentoid').AsInteger;
      F_descricao := Qry.FieldByName('descricao').AsString;

      Result := True;
    end
    else
      ShowMessage('Nenhum registro encontrado para o ID: ' + IntToStr(id));

  except
    on E: Exception do
      ShowMessage('Erro ao selecionar: ' + E.Message);
  end;
  FreeAndNil(Qry);
end;




function TFormasPagamento.Apagar: Boolean;
var Qry:TZQuery;
begin
  if MessageDlg('Apagar o Registro: '+#13+#13+
                  'Código: '+IntToStr(F_FormasPagamentoid)+#13+
                  'Descrição: '+F_descricao,TMsgDlgType.mtConfirmation,[mbYes, mbNo],0)=mrNo then begin
    Result:=False;
    Abort;
  end;
  try
    Result:=True;
    Qry:=TZQuery.Create(nil);
    Qry.Connection:=ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add('DELETE FROM formaspagamento ' + 'WHERE formaspagamentoid=:formaspagamentoid ');
    Qry.ParamByName('formaspagamentoid').AsInteger := F_FormasPagamentoid;
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

function TFormasPagamento.Atualizar: Boolean;
var
  Qry: TZQuery;
begin
  Result := False;
  Qry := TZQuery.Create(nil);
  try
    Qry.Connection := ConexaoDB;
    Qry.SQL.Text := 'UPDATE formaspagamento SET descricao = :descricao WHERE formaspagamentoid = :formaspagamentoid';
    Qry.ParamByName('descricao').AsString := Self.F_descricao;
    Qry.ParamByName('formaspagamentoid').AsInteger := Self.F_FormasPagamentoid;

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
      ShowMessage('Erro ao atualizar categoria: ' + E.Message);
  end;
  FreeAndNil(Qry);
end;


constructor TFormasPagamento.Create(aConexao:TZConnection);
begin
  ConexaoDB:=aConexao;
end;

destructor TFormasPagamento.Destroy;
begin

  inherited;
end;

function TFormasPagamento.GetCodigo: integer;
begin
  Result := Self.F_FormasPagamentoid;
end;

function TFormasPagamento.getDescricao: string;
begin
  Result := Self.F_descricao
end;


procedure TFormasPagamento.setCodigo(const Value: integer);
begin
  Self.F_FormasPagamentoid:= Value;
end;

procedure TFormasPagamento.setDescricao(const Value: string);
begin
  Self.F_descricao:= Value;
end;


end.
