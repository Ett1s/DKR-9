unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, DB, Forms, Controls, Graphics, Dialogs,
  StdCtrls, DBGrids, ExtCtrls, edit;

type

  { TfMain }

  TfMain = class(TForm)
    ButOpenBd: TButton;
    ButAdd: TButton;
    ButChange: TButton;
    ButDel: TButton;
    ButSearch: TButton;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    eSearch: TEdit;
    Image1: TImage;
    SearchLB: TLabel;
    SQLite3Connection1: TSQLite3Connection;
    SQLQuery1: TSQLQuery;
    SQLQuery2: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    procedure ButOpenBdClick(Sender: TObject);
    procedure ButAddClick(Sender: TObject);
    procedure ButChangeClick(Sender: TObject);
    procedure ButDelClick(Sender: TObject);
    procedure ButSearchClick(Sender: TObject);
    procedure eSearchChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  fMain: TfMain;

implementation

{$R *.lfm}

{ TfMain }

procedure TfMain.ButOpenBdClick(Sender: TObject);
begin
  Image1.Visible:=False;
  DBGrid1.Visible:= True;
  SQLQuery1.Close;
  SQLQuery1.SQL.Text:='select * from Toys';
  SQLQuery1.Open;
  SQLQuery2.Close;
  SQLQuery2.SQL.Text:='select * from Toys';
  SQLQuery2.Open;
  DBGrid1.Columns.Items[0].Width:=30;
  DBGrid1.Columns.Items[1].Width:=120;
  DBGrid1.Columns.Items[2].Width:=180;
  DBGrid1.Columns.Items[3].Width:=120;
  DBGrid1.Columns.Items[4].Width:=120;
end;

procedure TfMain.ButAddClick(Sender: TObject);
begin

  fEdit := TfEdit.Create(Self);
  fEdit.eManufactured.Text:= '';
  fEdit.eModel.Text:= '';
  fEdit.eMaterial.Text:= '';
  fEdit.ePrice.Text:= '';
  //устанавливаем ModalResult редактора в mrNone:
  fEdit.ModalResult:= mrNone;
  //теперь выводим форму:
  fEdit.ShowModal;
  //если пользователь ничего не ввел - выходим:
  if (fEdit.eManufactured.Text= '') or (fEdit.eModel.Text= '') or (fEdit.eMaterial.Text= '')
  or (fEdit.ePrice.Text= '') then exit;
  //если пользователь не нажал "Сохранить" - выходим:
  if fEdit.ModalResult <> mrOk then exit;
  SQLQuery1.Close;  // выключаем компонент
  SQLQuery1.SQL.Text := 'insert into toys (manufactured, model, material, price) values(:b,:m,:e,:p);';  // добавляем sql запрос для добавления данных
  SQLQuery1.ParamByName('b').AsString := fEdit.eManufactured.text;// присваиваем записи текстовое значение
  SQLQuery1.ParamByName('m').AsString := fEdit.eModel.text;
  SQLQuery1.ParamByName('e').AsString := fEdit.eMaterial.text;
  SQLQuery1.ParamByName('p').AsString := fEdit.ePrice.text;
  SQLQuery1.ExecSQL; // выполняем запрос
  SQLTransaction1.Commit; //подтверждаем изменения в базе

  try  // пробуем подключится к базе
    SQLite3Connection1.Open;
    SQLTransaction1.Active := True;
  except   // если не удалось то выводим сообщение о ошибке
    ShowMessage('Ошибка подключения к базе!');
  end;
  SQLQuery1.Close;
  SQLQuery1.SQL.Text:='select * from Toys';
  SQLQuery1.Open;
  DBGrid1.Columns.Items[0].Width:=30;
  DBGrid1.Columns.Items[1].Width:=120;
  DBGrid1.Columns.Items[2].Width:=180;
  DBGrid1.Columns.Items[3].Width:=120;
  DBGrid1.Columns.Items[4].Width:=120;
end;

procedure TfMain.ButChangeClick(Sender: TObject);
begin
  fEdit := TfEdit.Create(Self);
  fEdit.eManufactured.Text:= SQLQuery1.Fields.FieldByName('manufactured').AsString;
  fEdit.eModel.Text:= SQLQuery1.Fields.FieldByName('model').AsString;
  fEdit.eMaterial.Text:= SQLQuery1.Fields.FieldByName('material').AsString;
  fEdit.ePrice.Text:= SQLQuery1.Fields.FieldByName('price').AsString;
  //устанавливаем ModalResult редактора в mrNone:
  fEdit.ModalResult:= mrNone;
  //теперь выводим форму:
  fEdit.ShowModal;
  //если пользователь не нажал "Сохранить" - выходим:
  if fEdit.ModalResult <> mrOk then exit;

  SQLQuery1.Edit; // открываем процедуру добавления данных
  if not (fEdit.eManufactured.Text= '') then SQLQuery1.Fields.FieldByName('manufactured').AsString := fEdit.eManufactured.Text;
  // присваиваем записи текстовое значение
  if not (fEdit.eModel.Text= '') then SQLQuery1.Fields.FieldByName('model').AsString := fEdit.eModel.Text;
  if not (fEdit.eMaterial.Text= '') then SQLQuery1.Fields.FieldByName('material').AsString := fEdit.eMaterial.Text;
  if not (fEdit.ePrice.Text= '') then SQLQuery1.Fields.FieldByName('price').AsString := fEdit.ePrice.Text;
  Sqlquery1.Post; // записываем данные
  sqlquery1.ApplyUpdates;// отправляем изменения в базу
  SQLTransaction1.Commit; // подтверждаем изменения в базе

  try  // пробуем подключится к базе
    SQLite3Connection1.Open;
    SQLTransaction1.Active := True;
  except   // если не удалось то выводим сообщение о ошибке
    ShowMessage('Ошибка подключения к базе!');
  end;
  SQLQuery1.Close;
  SQLQuery1.SQL.Text:='select * from Toys';
  SQLQuery1.Open;
  DBGrid1.Columns.Items[0].Width:=30;
  DBGrid1.Columns.Items[1].Width:=120;
  DBGrid1.Columns.Items[2].Width:=180;
  DBGrid1.Columns.Items[3].Width:=120;
  DBGrid1.Columns.Items[4].Width:=120;
end;

procedure TfMain.ButDelClick(Sender: TObject);
begin
  if not SQLQuery1.Text:='':
  begin
  SQLQuery1.Delete;
  DBGrid1.Columns.Items[0].Width:=30;
  DBGrid1.Columns.Items[1].Width:=120;
  DBGrid1.Columns.Items[2].Width:=180;
  DBGrid1.Columns.Items[3].Width:=120;
  DBGrid1.Columns.Items[4].Width:=120;
  end
  else
  Showmessage('И так пусто')
end;

procedure TfMain.ButSearchClick(Sender: TObject);
begin
  if not (eSearch.text = '') then begin
  SQLQuery1.Close;// закрываем датасет
  SQLQuery1.SQL.Text := 'select * from Toys where model = :m'; // добавляем наш запрос
  SQLQuery1.ParamByName('m').AsString:= eSearch.text;// присваиваем требуемый параметр
  SQLQuery1.Open;// открываем запрос
  end
  else ShowMessage('Введите модель игрушки для поиска записи!');
  DBGrid1.Columns.Items[0].Width:=30;
  DBGrid1.Columns.Items[1].Width:=120;
  DBGrid1.Columns.Items[2].Width:=180;
  DBGrid1.Columns.Items[3].Width:=120;
  DBGrid1.Columns.Items[4].Width:=120;
end;

procedure TfMain.eSearchChange(Sender: TObject);
begin

end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  fMain.width:=600;
  SQLite3Connection1.DatabaseName := 'Toys.db'; // указывает путь к базе
  SQLite3Connection1.CharSet := 'UTF8'; // указываем рабочую кодировку
  SQLite3Connection1.Transaction := SQLTransaction1; // указываем менеджер транзакций
  try  // пробуем подключится к базе
    SQLite3Connection1.Open;
    SQLTransaction1.Active := True;
  except   // если не удалось то выводим сообщение о ошибке
    ShowMessage('Ошибка подключения к базе!');
  end;
end;


end.

