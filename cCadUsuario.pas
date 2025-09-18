unit cCadUsuario;

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
      System.SysUtils,
      uDTMConexao,
      uFuncaoCriptografia;

type
TUsuario = class
private
    ConexaoDB:TZConnection;
    F_usuarioid:integer;
    F_nome:String;
    F_senha:String;
    function getSenha: String;
    procedure setSenha(const Value: string);

public
    constructor Create(aConexao:TZConnection);
    destructor Destroy; override;
    function Inserir:Boolean;
    function Atualizar:Boolean;
    function Apagar:Boolean;
    function Selecionar(id:Integer):Boolean;
    function Logar(aUsuario, aSenha: String): Boolean;
    function UsuarioExiste(aUsuario: String): Boolean;

published
  property codigo       :integer   read F_usuarioid     write F_usuarioid;
  property nome         :string    read F_nome          write F_nome;
  property senha        :string    read getSenha        write setSenha;
end;

implementation

{ TUsuario }

constructor TUsuario.Create(aConexao: TZConnection);
begin
  ConexaoDB:=aConexao;
end;

function TUsuario.Apagar: Boolean;
var Qry:TZQuery;
begin
  if MessageDlg('Apagar o Registro: '+#13+#13+
                  'Código: '+IntToStr(F_usuarioid)+#13+
                  'Descrição: '+F_nome,TMsgDlgType.mtConfirmation,[mbYes, mbNo],0)=mrNo then begin
    Result:=False;
    Abort;
  end;
  try
    Result:=True;
    Qry:=TZQuery.Create(nil);
    Qry.Connection:=ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add('DELETE FROM usuarios ' + 'WHERE usuarioid=:usuarioid ');
    Qry.ParamByName('usuarioid').AsInteger := F_usuarioid;
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

function TUsuario.Atualizar: Boolean;
var
  Qry: TZQuery;
begin
  Result := False;
  Qry := TZQuery.Create(nil);
  try
    Qry.Connection := ConexaoDB;
    Qry.SQL.Text := 'UPDATE usuarios SET nome = :nome, senha = :senha WHERE usuarioid = :usuarioid';
    Qry.ParamByName('usuarioid').AsInteger  := Self.F_usuarioid;
    Qry.ParamByName('nome').AsString        := Self.F_nome;
    Qry.ParamByName('senha').AsString       := Self.F_senha;

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


function TUsuario.Inserir: Boolean;
var
  Qry: TZQuery;
begin
  Result := False;
  Qry := TZQuery.Create(nil);
  try
    Qry.Connection := ConexaoDB;

    // Exibe os valores antes de inserir para depuração
    ShowMessage('Descrição: ' + Self.F_nome );

    Qry.SQL.Text := 'INSERT INTO usuarios (nome, senha) VALUES (:nome, :senha)';
    Qry.ParamByName('nome').AsString  := Self.F_nome;
    Qry.ParamByName('senha').AsString := Self.F_senha;

    Qry.ExecSQL;
    Result := True;
    MessageDlg('Gravado com sucesso!', mtConfirmation, [mbOK], 0);

  except
    on E: Exception do
      ShowMessage('Erro ao gravar categoria: ' + E.Message);
  end;
  FreeAndNil(Qry);
end;



function TUsuario.Selecionar(id: Integer): Boolean;
var
  Qry: TZQuery;
begin
try
  Result := True;
  Qry := TZQuery.Create(nil);
  Qry.Connection := ConexaoDB;
  Qry.SQL.Clear;
  Qry.SQL.Text := 'SELECT usuarioid, nome, senha FROM usuarios WHERE usuarioid = :usuarioid';
  Qry.ParamByName('usuarioid').AsInteger := id;



  try
    Qry.Open;
    Self.F_usuarioid      :=Qry.FieldByName('usuarioid').AsInteger;
    Self.F_nome           :=Qry.FieldByName('nome').AsString;
    Self.F_senha          :=Qry.FieldByName('senha').AsString;
  except
    Result:=False;
  end;
finally
  if  Assigned(Qry) then
      FreeAndNil(Qry);
  end;
end;

function TUsuario.UsuarioExiste(aUsuario:String): Boolean;
var Qry:TZQuery;
begin
  try
    Qry:=TZQuery.Create(nil);
    Qry.Connection:=ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add('SELECT COUNT(usuarioid) AS Qtde '+
                ' FROM usuarios '+
                ' WHERE nome=:nome');
    Qry.ParamByName('nome').AsString:=aUsuario;
  try
    Qry.Open;

    if Qry.FieldByName('Qtde').AsInteger>0 then
      Result:= True
    else
    Result:=False;
  except
  Result:=False;
  end;
  finally
    if Assigned(Qry) then
    FreeAndNil(Qry);
  end;
end;

function TUsuario.Logar(aUsuario, aSenha: String): Boolean;
var
  Qry: TZQuery;
begin
  Result := False; // Definir valor inicial como False

  try
    Qry := TZQuery.Create(nil);
    Qry.Connection := ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add('SELECT usuarioid, nome FROM usuarios ' +
                'WHERE nome = :nome AND senha = :senha');
    Qry.ParamByName('nome').AsString := aUsuario;
    Qry.ParamByName('senha').AsString := Criptografar(aSenha);
    Qry.Open;

    if not Qry.IsEmpty then
    begin
      Self.F_usuarioid := Qry.FieldByName('usuarioid').AsInteger;
      Self.F_nome      := Qry.FieldByName('nome').AsString;
      Result := True;
    end;
  except
    on E: Exception do
      ShowMessage('Erro ao autenticar usuário: ' + E.Message);
  end;

  if Assigned(Qry) then
    FreeAndNil(Qry);
end;


function TUsuario.getSenha: String;
begin
  Result := Descriptografar(Self.F_senha);
end;


procedure TUsuario.setSenha(const Value: string);
begin
  Self.F_senha := Criptografar(Value);
end;

destructor TUsuario.Destroy;
begin

  inherited;
end;



end.
