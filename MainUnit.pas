unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Winapi.ShlObj, Winapi.ShellAPI,
  Vcl.Grids, Vcl.DBGrids, Data.DB, IBDatabase, IBCustomDataSet, IBTable,
  Vcl.ImgList;

type
  TfmMain = class(TForm)
    StatusBar1: TStatusBar;
    GroupBox1: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    SourceLabel: TLabel;
    Label3: TLabel;
    DestLabel: TLabel;
    Button3: TButton;
    IBTable1: TIBTable;
    IBDatabase1: TIBDatabase;
    IBTransaction1: TIBTransaction;
    DataSource1: TDataSource;
    ListView1: TListView;
    SysImageList: TImageList;
    IBTable1ID: TIntegerField;
    IBTable1FNAME: TIBStringField;
    IBTable1FSIZE: TLargeintField;
    IBTable1TIMESTART: TDateTimeField;
    IBTable1TIMEEND: TDateTimeField;
    IBTable1TIMEDURATION: TTimeField;
    Button4: TButton;
    Button5: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
    SrcPath, DstPath: string;
    procedure InitSystemImageList;
  public
    { Public declarations }
    procedure ShowLog;
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

uses UtilitesUnit, ProgressFormUnit, CopyThreadUnit;

procedure TfmMain.Button1Click(Sender: TObject);
var
   Path: string;
begin
   Path := FolderDialogExecute(Handle, BIF_NEWDIALOGSTYLE + BIF_NONEWFOLDERBUTTON + BIF_RETURNONLYFSDIRS);
   if DirectoryExists(Path) then
   begin
      SrcPath := IncludeTrailingPathDelimiter(Path);
      SourceLabel.Caption := SrcPath;
   end;
end;

procedure TfmMain.Button2Click(Sender: TObject);
var
   Path: string;
begin
   Path := FolderDialogExecute(Handle, BIF_NEWDIALOGSTYLE + BIF_RETURNONLYFSDIRS);
   if DirectoryExists(Path) then
   begin
      DstPath := IncludeTrailingPathDelimiter(Path);
      DestLabel.Caption := Path;
   end;
end;

procedure TfmMain.Button3Click(Sender: TObject);
begin
   if not DirectoryExists(SrcPath) then
      raise Exception.Create('���������� ������� �����-��������!');

   if not DirectoryExists(DstPath) then
      raise Exception.Create('���������� ������� ����� - ����� �����������!');

   // ��������� ������� ����������� ������
   fmProgress.ShowProgress(SrcPath, DstPath);
end;

procedure TfmMain.Button4Click(Sender: TObject);
begin
   ShowLog;
end;

procedure TfmMain.Button5Click(Sender: TObject);
begin
   if not IBTransaction1.InTransaction then IBTransaction1.StartTransaction;
   if not IBTable1.Active then IBTable1.Open;

   IBTable1.Open;
   IBTable1.EmptyTable;

   IBTransaction1.Commit;

   ShowLog;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
   IBDatabase1.Connected  := false;
   IBDatabase1.LoginPrompt := false;
   try
      IBDatabase1.DatabaseName := 'localhost:' + IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'DATABASE.FDB';
      IBDatabase1.Params.Clear;
      IBDatabase1.Params.Add('user_name=SYSDBA');
      IBDatabase1.Params.Add('password=masterkey');
      IBDatabase1.Params.Add('lc_ctype=WIN1251');
      IBDatabase1.Connected := true;

      StatusBar1.SimpleText := '�� ���������� (' + IBDatabase1.DatabaseName + ')';
   except on E: Exception do
      MessageBox(Handle, '������ ����������� � ���� ������.'#$D#$A'��������� ������ � ����� "DATABASE.FDB"!', PChar(Caption), MB_ICONERROR);
   end;

   InitSystemImageList;
end;

procedure TfmMain.InitSystemImageList;
var
  SHFileInfo: TSHFileInfo;
  Buff: PChar;
begin
  Buff := StrAlloc(MAX_PATH);
  try
    GetWindowsDirectory(Buff, MAX_PATH);
    SysImageList.Handle := SHGetFileInfo(Buff, 0, SHFileInfo, SizeOf(SHFileInfo), SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
    SysImageList.ShareImages := True;
    SysImageList.BlendColor := clHighLight;
  finally
    StrDispose(Buff);
  end;
end;

procedure TfmMain.ShowLog;
var
   Item: TListItem;
   FileName: string;
begin
   Screen.Cursor := crHourGlass;
   try
      ListView1.Items.BeginUpdate;
      ListView1.Items.Clear;

      if not IBTransaction1.InTransaction then IBTransaction1.StartTransaction;
      if not IBTable1.Active then IBTable1.Open;

      IBTable1.First;
      while not IBTable1.Eof do
      begin
         Item := ListView1.Items.Add;
         FileName := TrimRight(IBTable1FNAME.Value);
         Item.Caption := FileName;
         Item.ImageIndex := GetSysIconIndexByName(FileName);

         Item.SubItems.Add(FormatFileSize(IBTable1FSIZE.Value));
         Item.SubItems.Add(IBTable1TIMESTART.AsString);
         Item.SubItems.Add(IBTable1TIMEEND.AsString);
         Item.SubItems.Add(TimeToStr(IBTable1TIMEDURATION.Value));

         IBTable1.Next;
      end;

      IBTransaction1.Commit;
      ListView1.Items.EndUpdate;
   finally
      Screen.Cursor := crDefault;
   end;
end;

end.
