unit cAcaoAcesso;

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
      Vcl.Forms,
      Vcl.Buttons, uUsuarioLogado;

type
  TAcaoAcesso = class
    private
      ConexaoDB: TZConnection;
      F_acaoacessoid: Integer;
      F_descricao: String;
      F_chave: String;

      class procedure PreencherAcoes (aForm: TForm; aConexao:TZConnection); static;
      class procedure VerificarUsuarioAcao (aUsuarioId, aAcaoAcessoId: integer; aConexao: TZConnection); static;
    public
      constructor Create(aConexao:TZConnection);
      destructor Destroy; override;
      function Inserir:Boolean;
      function Atualizar:Boolean;
      function Apagar:Boolean;
      function Selecionar(id:Integer):Boolean;
      function ChaveExiste(aChave:String; aId:integer=0): Boolean;
      class procedure CriarAcoes (aNomeForm: TFormClass; aConexao: TZConnection); static;
      class procedure PreencherPermissaoUsuarios (aConexao: TZConnection); static;
    published
      property codigo     :integer      read F_acaoacessoid     write F_acaoacessoid;
      property descricao  :string       read F_descricao        write F_descricao;
      property chave      :string       read F_chave            write F_chave;
  end;

implementation

{ TAcaoAcesso }

function TAcaoAcesso.Apagar: Boolean;
var Qry:TZQuery;
begin
  if MessageDlg('Apagar o Registro: '+#13+#13+
                  'Código: '+IntToStr(F_acaoacessoid)+#13+
                  'Descrição: '+F_descricao,TMsgDlgType.mtConfirmation,[mbYes, mbNo],0)= mrNo then begin
    Result:=False;
    Abort;
  end;
  try
    Result:=True;
    Qry:=TZQuery.Create(nil);
    Qry.Connection:= ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add('DELETE FROM acaoacesso ' + 'WHERE acaoacessoid=:acaoacessoid ');
    Qry.ParamByName('acaoacessoid').AsInteger := F_acaoacessoid;
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


function TAcaoAcesso.Atualizar: Boolean;
var
  Qry: TZQuery;
begin
  Result := False;
  Qry := TZQuery.Create(nil);
  try
    Qry.Connection := ConexaoDB;
    Qry.SQL.Text := 'UPDATE acaoacesso SET descricao = :descricao, chave = :chave WHERE acaoacessoid = :acaoacessoid';
    Qry.ParamByName('acaoacessoid').AsInteger := Self.F_acaoacessoid;
    Qry.ParamByName('descricao').AsString := Self.F_descricao;
    Qry.ParamByName('chave').AsString := Self.F_chave;

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
      ShowMessage('Erro ao atualizar: ' + E.Message);
  end;
  FreeAndNil(Qry);
end;


function TAcaoAcesso.Inserir: Boolean;
var
  Qry: TZQuery;
begin
  try
  Result := True;
  Qry := TZQuery.Create(nil);
  Qry.Connection := ConexaoDB;
  Qry.SQL.Text := 'INSERT INTO acaoacesso (descricao, '+ 'chave)' +
                  'VALUES (:descricao, '+ ':chave)';
    Qry.ParamByName('descricao').AsString          := Self.F_descricao;
    Qry.ParamByName('chave').AsString              := Self.F_chave;

    Qry.ExecSQL;

    Result := True;
    //MessageDlg('Gravado com sucesso!', mtConfirmation, [mbOK], 0);

  except
    on E: Exception do
      ShowMessage('Erro ao gravar: ' + E.Message);
  end;
  FreeAndNil(Qry);
end;

class procedure TAcaoAcesso.PreencherAcoes(aForm: TForm; aConexao: TZConnection);
var
  i: Integer;
  oAcaoAcesso: TAcaoAcesso;
begin
  try
    oAcaoAcesso := TAcaoAcesso.Create(aConexao);
    oAcaoAcesso.descricao := aForm.Caption;
    oAcaoAcesso.chave := aForm.Name;

    // Verificar e registrar a permissão do formulário
    if aForm.Tag = 99 then
    begin
      if not oAcaoAcesso.ChaveExiste(oAcaoAcesso.chave) then
        oAcaoAcesso.Inserir;
    end;

    // Verificar e registrar a permissão dos botões
    for i := 0 to aForm.ComponentCount - 1 do
    begin
      if aForm.Components[i] is TBitBtn then
      begin
        if TBitBtn(aForm.Components[i]).Tag = 99 then
        begin
          oAcaoAcesso.descricao := '    - BOTÃO ' + TBitBtn(aForm.Components[i]).Caption;
          oAcaoAcesso.chave := aForm.Name + '_' + TBitBtn(aForm.Components[i]).Name;
          if not oAcaoAcesso.ChaveExiste(oAcaoAcesso.chave) then
            oAcaoAcesso.Inserir;
        end;
      end;
    end;

  finally
    if Assigned(oAcaoAcesso) then
      FreeAndNil(oAcaoAcesso);
  end;
end;



class procedure TAcaoAcesso.CriarAcoes(aNomeForm: TFormClass;aConexao: TZConnection);
var form: TForm;
begin
  try
    form := aNomeForm.Create(Application);
    PreencherAcoes(form,aConexao);
  finally
    if Assigned(form) then
      Form.Release;
  end;

end;

function TAcaoAcesso.Selecionar(id: Integer): Boolean;
var
  Qry: TZQuery;
begin
  Result := False;
  Qry := TZQuery.Create(nil);
  try
    Qry.Connection := ConexaoDB;
    Qry.SQL.Text := 'SELECT acaoacessoid, descricao, chave FROM acaoacesso WHERE acaoacessoid = :acaoacessoid';
    Qry.ParamByName('acaoacessoid').AsInteger := id;
    Qry.Open;

    if not Qry.IsEmpty then
    begin
      Self.F_acaoacessoid         :=Qry.FieldByName('acaoacessoid').AsInteger;
      Self.F_descricao            :=Qry.FieldByName('descricao').AsString;
      Self.F_chave                :=Qry.FieldByName('chave').AsString;

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


class procedure TAcaoAcesso.VerificarUsuarioAcao(aUsuarioId, aAcaoAcessoId: integer; aConexao: TZConnection);
var Qry:TZQuery;
begin
  try
    Qry:=TZQuery.Create(nil);
    Qry.Connection:=aConexao;
    Qry.SQL.Clear;
    Qry.SQL.Add(' SELECT usuarioid '+
                ' FROM usuariosacaoacesso '+
                ' WHERE usuarioid=:usuarioid '+
                ' AND acaoacessoid=:acaoacessoid ');
    Qry.ParamByName('usuarioid').AsInteger:=aUsuarioId;
    Qry.ParamByName('acaoacessoid').AsInteger:=aAcaoAcessoId;
    Qry.Open;

    if Qry.IsEmpty then
    begin
      Qry.Close;
      Qry.SQL.Clear;
      Qry.SQL.Add('INSERT INTO usuariosacaoacesso (usuarioid, acaoacessoid, ativo) '+
                  'VALUES (:usuarioid, :acaoacessoid, :ativo) ');
      Qry.ParamByName('usuarioid').AsInteger:=aUsuarioId;
      Qry.ParamByName('acaoacessoid').AsInteger:=aAcaoAcessoId;
      Qry.ParamByName('ativo').AsBoolean:=True;
      Qry.ExecSQL;
    end;

  finally
  if Assigned(Qry) then
    FreeAndNil(Qry);

  end;
end;

class procedure TAcaoAcesso.PreencherPermissaoUsuarios(aConexao: TZConnection);
var Qry:TZQuery;
    QryAcaoAcesso:TZQuery;
begin
  try
    Qry:=TZQuery.Create(nil);
    Qry.Connection:=aConexao;
    Qry.SQL.Clear;

    QryAcaoAcesso:=TZQuery.Create(nil);
    QryAcaoAcesso.Connection:=aConexao;
    QryAcaoAcesso.SQL.Clear;

    Qry.SQL.Add('SELECT usuarioid FROM usuarios');
    Qry.Open;
    QryAcaoAcesso.SQL.Add('SELECT acaoacessoid FROM acaoacesso');
    QryAcaoAcesso.Open;

    Qry.First;
    while not Qry.Eof do
    begin
      QryAcaoAcesso.First;

      while not QryAcaoAcesso.Eof do
      begin
        VerificarUsuarioAcao(Qry.FieldByName('usuarioid').AsInteger, QryAcaoAcesso.FieldByName('acaoacessoid').AsInteger, aConexao);
        QryAcaoAcesso.Next;
      end;
      Qry.Next;
    end;
  finally
    if Assigned(Qry) then
        FreeAndNil(Qry);
    if Assigned(QryAcaoAcesso) then
        FreeAndNil(QryAcaoAcesso);
  end;

end;


function TAcaoAcesso.ChaveExiste(aChave: String; aId:integer): Boolean;
var Qry:TZQuery;
begin
  try
    Qry:=TZQuery.Create(nil);
    Qry.Connection:=ConexaoDB;
    Qry.SQL.Clear;
    Qry.SQL.Add('SELECT COUNT(acaoacessoid) AS Qtde '+
                ' FROM acaoacesso '+
                ' WHERE chave=:chave');

    if aId > 0 then
    begin
      Qry.SQL.Add('AND acaoacessoid<>:acaoacessoid');
      Qry.ParamByName('acaoacessoid').AsInteger := aId;
    end;
    Qry.ParamByName('chave').AsString:=aChave;
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




constructor TAcaoAcesso.Create(aConexao: TZConnection);
begin
  ConexaoDB:=aConexao;
end;



destructor TAcaoAcesso.Destroy;
begin

  inherited;
end;



end.
