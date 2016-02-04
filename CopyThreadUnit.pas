unit CopyThreadUnit;

interface

uses
   System.Classes, Winapi.Windows, Winapi.Messages, System.SysUtils, Vcl.Forms;

type
   TCopyThread = class(TThread)
   private
      FSourcePath: string;
      FDestPath: string;
      FForm: TForm;
   protected
      procedure Execute; override;
      procedure PrepareDstFileList(SrcList, DstList: TStringList);
      procedure StartedFile;
      procedure FinishedFile;
      procedure ProgressStarted;
      procedure ProgressFinished;
   public
      constructor Create(ProgressForm: TForm; Src, Dst: string);
      procedure OnTerminate(Sender: TObject);
      property SourcePath: string read FSourcePath write FSourcePath;
      property DestPath: string read FDestPath write FDestPath;
      property Form: TForm read FForm write FForm;
   end;

   function CopyFileProgress(TotalFileSize, TotalBytesTransferred, StreamSize, StreamBytesTransferred: LARGE_INTEGER;
                             dwStreamNumber, dwCallbackReason, hSourceFile, hDestinationFile: DWORD; lpData: Pointer): DWORD; stdcall;

var
   CancelCopy: Boolean = False;

   TotalFiles: Integer;
   TotalStartTime: TDateTime;

   CurrentFileNumber: Integer;
   CurrentFileName: string;
   CurrentFileStartTime: TDateTime;
   CurrentFileSize: LARGE_INTEGER;

implementation

uses UtilitesUnit, ProgressFormUnit, MainUnit;

{ TCopyThread }

constructor TCopyThread.Create(ProgressForm: TForm; Src, Dst: string);
begin
   FForm       := ProgressForm;
   FSourcePath := IncludeTrailingPathDelimiter(Src);
   FDestPath   := IncludeTrailingPathDelimiter(Dst);
   FreeOnTerminate := True;
   inherited Create(True);
end;

procedure TCopyThread.Execute;
var
   SrcFilesList: TStringList;
   DstFilesList: TStringList;
   i: Integer;
   Cancel : PBool;
begin
   SrcFilesList := TStringList.Create;
   DstFilesList := TStringList.Create;
   // ��������� �������� ����� (������� ��������)
   EnumFilesInFolder(FSourcePath, SrcFilesList, true);
   // ��������� ������ ��� � ����� �����������
   PrepareDstFileList(SrcFilesList, DstFilesList);

   CurrentFileNumber := 0;
   TotalFiles := SrcFilesList.Count;
   Synchronize(ProgressStarted);

   for i := 0 to SrcFilesList.Count - 1 do
   begin
      if CancelCopy or Terminated then Break;

      CurrentFileNumber := i;
      CurrentFileName := SrcFilesList[i];

      Synchronize(StartedFile);

      ForceDirectories(ExtractFilePath(DstFilesList[i]));

      Cancel := PBOOL(False);
      CopyFileEx(PChar(SrcFilesList[i]), PChar(DstFilesList[i]), @CopyFileProgress, Pointer(Handle), Cancel,
                  COPY_FILE_ALLOW_DECRYPTED_DESTINATION + COPY_FILE_RESTARTABLE (*+ COPY_FILE_FAIL_IF_EXISTS*));

      Synchronize(FinishedFile);
   end;

   Synchronize(ProgressFinished);
end;

procedure TCopyThread.FinishedFile;
begin
   fmProgress.ProgressFile.Position := 100;

   with fmMain do
   begin
      if not IBTransaction1.InTransaction then IBTransaction1.StartTransaction;
      if not IBTable1.Active then IBTable1.Active := True;

      IBTable1.Append;
      IBTable1FNAME.Value     := CurrentFileName;
      IBTable1FSIZE.Value     := CurrentFileSize.QuadPart;
      IBTable1TIMESTART.Value := CurrentFileStartTime;
      IBTable1TIMEEND.Value   := Now;
      IBTable1.Post;

      IBTransaction1.Commit;
   end;
end;

procedure TCopyThread.StartedFile;
var
   FileInformation: TWin32FileAttributeData;
begin
   fmProgress.LabelFileName.Caption := CurrentFileName;

   // ������ ����� �����
   ZeroMemory(@FileInformation, SizeOf(FileInformation));
   GetFileAttributesEx(PChar(CurrentFileName), GetFileExInfoStandard, @FileInformation);
   CurrentFileSize.HighPart := FileInformation.nFileSizeHigh;
   CurrentFileSize.LowPart  := FileInformation.nFileSizeLow;
   fmProgress.LabelFileSize.Caption := FormatFileSize(CurrentFileSize.QuadPart);

   fmProgress.ProgressFile.Position := 0;
   fmProgress.LabelFilesCount.Caption := Format('���� %d �� %d', [CurrentFileNumber, TotalFiles]);
   fmProgress.ProgressTotal.Position := Round(CurrentFileNumber / TotalFiles * 100);

   CurrentFileStartTime := Now;
end;

procedure TCopyThread.OnTerminate(Sender: TObject);
begin

end;

procedure TCopyThread.PrepareDstFileList(SrcList, DstList: TStringList);
var
   i: Integer;
   FileName: string;
begin
   for i := 0 to SrcList.Count - 1 do
   begin
      FileName := StringReplace(SrcList[i], FSourcePath, FDestPath, [rfIgnoreCase]);
      DstList.Add(FileName);
   end;
end;

procedure TCopyThread.ProgressFinished;
begin
   // ��������������, ��� � ������ ��� ����� ���������� (������ ��� ���)
   fmProgress.LabelFilesCount.Caption := Format('���� %d �� %d', [TotalFiles, TotalFiles]);
   fmProgress.ProgressTotal.Position := 100;
   fmProgress.ProgressFile.Position  := 100;
   fmProgress.Timer1.Enabled := false;
   fmProgress.Close;
   fmMain.ShowLog;
end;

procedure TCopyThread.ProgressStarted;
begin
   CancelCopy := False;
   TotalStartTime := Now;
   fmProgress.LabelFilesCount.Caption := Format('���� %d �� %d', [CurrentFileNumber, TotalFiles]);
   fmProgress.ProgressTotal.Position := 0;
   fmProgress.ProgressFile.Position  := 0;
   fmProgress.Timer1.Enabled := true;
end;

function CopyFileProgress(TotalFileSize, TotalBytesTransferred, StreamSize, StreamBytesTransferred: LARGE_INTEGER;
                          dwStreamNumber, dwCallbackReason, hSourceFile, hDestinationFile: DWORD; lpData: Pointer): DWORD; stdcall;
begin
   if CancelCopy = True then
   begin
      result := PROGRESS_CANCEL;
      Exit;
   end;

   case dwCallbackReason of
      CALLBACK_CHUNK_FINISHED:
         begin
            result := PROGRESS_CONTINUE;

            if TotalFileSize.QuadPart > 0 then
               fmProgress.ProgressFile.Position := Round(TotalBytesTransferred.QuadPart / TotalFileSize.QuadPart * 100)
            else
               fmProgress.ProgressFile.Position := 50; // ��� ������ �������� �������, ������ ��������� ������ �����������
         end;
      CALLBACK_STREAM_SWITCH:
         begin
            result := PROGRESS_CONTINUE;
         end;
   else
      result := PROGRESS_CONTINUE;
   end;
end;

end.
