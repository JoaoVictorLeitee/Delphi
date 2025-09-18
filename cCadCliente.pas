unit cCadCliente;

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
      System.SysUtils, uDTMConexao, uTelaHeranca, uCadCategoria;

type
  TCliente = class
  private
  ConexaoDB:TZConnection;
  F_clienteid:integer;
  F_nome:String;
  F_cpf:String;
  F_endereco:String;
  F_cidade:String;
  F_bairro:String;
  F_estado:String;
  F_cep:String;
  F_telefone:String;
  F_email:String;
  F_dataNascimento: TDateTime;

public
  constructor Create(aConexao:TZConnection);
  destructor Destroy; override;
  function Inserir:Boolean;
  function Atualizar:Boolean;
  function Apagar:Boolean;
  function Selecionar(id:Integer):Boolean;
published
  property codigo        :integer     read F_clienteid        write F_clienteid;
  property nome          :String      read F_nome             write F_nome;
  property cpf           :String      read F_cpf              write F_cpf;
  property endereco      :String      read F_endereco         write F_endereco;
  property cidade        :String      read F_cidade           write F_cidade;
  property bairro        :String      read F_bairro           write F_bairro;
  property estado        :String      read F_estado           write F_estado;
  property cep           :String      read F_cep              write F_cep;
  property telefone      :String      read F_telefone         write F_telefone;
  property email         :String      read F_email            write F_email;
  property dataNascimento:TDateTime   read F_dataNascimento   write F_dataNascimento;
  end;


  implementation

{ TCliente }

constructor TCliente.Create(aConexao: TZConnection);
begin
  ConexaoDB:=aConexao;
end;


destructor TCliente.Destroy;
begin

  inherited;
end;

function TCliente.Apagar: Boolean;
var Qry:TZQuery;
begin
  if MessageDlg('Apagar o Registro: '+#13+#13+
                  'Código: '+IntToStr(F_clienteid)+#13+
                  'Descrição: '+F_nome,TMsgDlgType.mtConfirmation,[mbYes, mbNo],0)=mrNo then begin
    Result:=False;
    Abort;
  end;
  try
    Result:=True;
    Qry:=TZQuery.Create(nil);
    Qry.Connection:=ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add('DELETE FROM clientes ' + 'WHERE clienteid=:clienteid ');
    Qry.ParamByName('clienteid').AsInteger := F_clienteid;
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






function TCliente.Atualizar: Boolean;
var
  Qry: TZQuery;
begin
  try
    Result := True;
    Qry := TZQuery.Create(nil);
    Qry.Connection := ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Text := 'UPDATE clientes ' +  // Note o espaço após 'clientes'
                    'SET nome = :nome, ' +
                    'cpf = :cpf, ' +
                    'cep = :cep, ' +
                    'endereco = :endereco, ' +
                    'bairro = :bairro, ' +
                    'cidade = :cidade, ' +
                    'telefone = :telefone, ' +
                    'email = :email, ' +
                    'estado = :estado, ' +
                    'dataNascimento = :dataNascimento ' +
                    'WHERE clienteid = :clienteid';
    // Atribuição dos parâmetros
    Qry.ParamByName('clienteid').AsInteger := Self.F_clienteid;
    Qry.ParamByName('nome').AsString := Self.F_nome;
    Qry.ParamByName('cpf').AsString := Self.F_cpf;
    Qry.ParamByName('cep').AsString := Self.F_cep;
    Qry.ParamByName('endereco').AsString := Self.F_endereco;
    Qry.ParamByName('bairro').AsString := Self.F_bairro;
    Qry.ParamByName('cidade').AsString := Self.F_cidade;
    Qry.ParamByName('telefone').AsString := Self.F_telefone;
    Qry.ParamByName('email').AsString := Self.F_email;
    Qry.ParamByName('estado').AsString := Self.F_estado;
    Qry.ParamByName('dataNascimento').AsDateTime := Self.F_dataNascimento;


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




function TCliente.Inserir: Boolean;
var
  Qry: TZQuery;
begin
  try
  Result := True;
  Qry := TZQuery.Create(nil);
  Qry.Connection := ConexaoDB;
  Qry.SQL.Text := 'INSERT INTO clientes (nome,'+
                        'cpf,' +
                       'cep,' +
                       'endereco,' +
                       'bairro,' +
                       'cidade,' +
                       'telefone,' +
                       'email,' +
                       'estado,' +
                       'datanascimento)' +
                  'VALUES (:nome, '+
                        ':cpf,' +
                       ':cep,' +
                       ':endereco,' +
                       ':bairro,' +
                       ':cidade,' +
                       ':telefone,' +
                       ':email,' +
                       ':estado,' +
                       ':datanascimento)';
    Qry.ParamByName('nome').AsString             := Self.F_nome;
    Qry.ParamByName('cpf').AsString              := Self.F_cpf;
    Qry.ParamByName('cep').AsString              := Self.F_cep;
    Qry.ParamByName('endereco').AsString         := Self.F_endereco;
    Qry.ParamByName('bairro').AsString           := Self.F_bairro;
    Qry.ParamByName('cidade').AsString           := Self.F_cidade;
    Qry.ParamByName('telefone').AsString         := Self.F_telefone;
    Qry.ParamByName('email').AsString            := Self.F_email;
    Qry.ParamByName('estado').AsString           := Self.F_estado;
    Qry.ParamByName('datanascimento').AsDateTime := Self.F_dataNascimento;
    Qry.ExecSQL;

    Result := True;
    MessageDlg('Gravado com sucesso!', mtConfirmation, [mbOK], 0);

  except
    on E: Exception do
      ShowMessage('Erro ao gravar cliente: ' + E.Message);
  end;
  FreeAndNil(Qry);
end;


function TCliente.Selecionar(id: Integer): Boolean;
var
  Qry: TZQuery;
begin
  try
    Result := True;
    Qry := TZQuery.Create(nil);
    Qry.Connection := ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Text := 'SELECT clienteid, "nome",  "cpf", "endereco", "cidade", "bairro", "estado", "cep", "telefone", "email", "datanascimento" ' +
                ' FROM clientes ' +
                ' WHERE clienteid = :clienteid';
    Qry.ParamByName('clienteid').AsInteger := id;
    try
    Qry.Open;
    Self.F_clienteid        :=Qry.FieldByName('clienteid').AsInteger;
    Self.F_nome             :=Qry.FieldByName('nome').AsString;
    Self.F_cpf              :=Qry.FieldByName('cpf').AsString;
    Self.F_endereco         :=Qry.FieldByName('endereco').AsString;
    Self.F_cidade           :=Qry.FieldByName('cidade').AsString;
    Self.F_bairro           :=Qry.FieldByName('bairro').AsString;
    Self.F_estado           :=Qry.FieldByName('estado').AsString;
    Self.F_cep              :=Qry.FieldByName('cep').AsString;
    Self.F_telefone         :=Qry.FieldByName('telefone').AsString;
    Self.F_email            :=Qry.FieldByName('email').AsString;
    Self.F_dataNascimento   :=Qry.FieldByName('datanascimento').AsDateTime;
  Except
      Result:=False
    end;
  finally
    if Assigned(Qry) then
      FreeAndNil(Qry);

  end;
end;

end.
