unit cCadCategoria;

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
  TCategoria = class

private
ConexaoDB:TZConnection;
F_categoriaid:integer;
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


function TCategoria.Gravar: Boolean;
var
  Qry: TZQuery;
begin
  Result := False;
  Qry := TZQuery.Create(nil);
  try
    Qry.Connection := ConexaoDB;

    // Exibe os valores antes de inserir para depuração
    ShowMessage('Descrição: ' + Self.F_descricao );

    Qry.SQL.Text := 'INSERT INTO categorias (descricao) VALUES (:descricao)';
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




function TCategoria.Selecionar(id: Integer): Boolean;
var
  Qry: TZQuery;
begin
  Result := False;
  Qry := TZQuery.Create(nil);
  try
    Qry.Connection := ConexaoDB;
    Qry.SQL.Text := 'SELECT categoriaid, descricao FROM categorias WHERE categoriaid = :categoriaid';
    Qry.ParamByName('categoriaid').AsInteger := id;
    Qry.Open;

    if not Qry.IsEmpty then
    begin
      F_categoriaid := Qry.FieldByName('categoriaid').AsInteger;
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




function TCategoria.Apagar: Boolean;
var Qry:TZQuery;
begin
  if MessageDlg('Apagar o Registro: '+#13+#13+
                  'Código: '+IntToStr(F_categoriaid)+#13+
                  'Descrição: '+F_descricao,TMsgDlgType.mtConfirmation,[mbYes, mbNo],0)=mrNo then begin
    Result:=False;
    Abort;
  end;
  try
    Result:=True;
    Qry:=TZQuery.Create(nil);
    Qry.Connection:=ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add('DELETE FROM categorias ' + 'WHERE categoriaid=:categoriaid ');
    Qry.ParamByName('categoriaid').AsInteger := F_categoriaid;
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

function TCategoria.Atualizar: Boolean;
var
  Qry: TZQuery;
begin
  Result := False;
  Qry := TZQuery.Create(nil);
  try
    Qry.Connection := ConexaoDB;
    Qry.SQL.Text := 'UPDATE categorias SET descricao = :descricao WHERE categoriaid = :categoriaid';
    Qry.ParamByName('descricao').AsString := Self.F_descricao;
    Qry.ParamByName('categoriaid').AsInteger := Self.F_categoriaid;

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


constructor TCategoria.Create(aConexao:TZConnection);
begin
  ConexaoDB:=aConexao;
end;

destructor TCategoria.Destroy;
begin

  inherited;
end;

function TCategoria.GetCodigo: integer;
begin
  Result := Self.F_categoriaid;
end;

function TCategoria.getDescricao: string;
begin
  Result := Self.F_descricao
end;


procedure TCategoria.setCodigo(const Value: integer);
begin
  Self.F_categoriaid:= Value;
end;

procedure TCategoria.setDescricao(const Value: string);
begin
  Self.F_descricao:= Value;
end;


end.


