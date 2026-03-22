{
  ע��: RAD Studio 11 ����64λ����ʱ���������Ŀ������Ϊ�������޷����е��ԡ�
}

unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Imaging.jpeg, System.ImageList, Vcl.ImgList, Vcl.Buttons, Vcl.ComCtrls,
  ActiveX, ComObj, GList, System.IniFiles, Vcl.Menus, System.JSON;

type

  TProtectRecord = record
    filename, filePath: string;
  end;
  PTProtectRecord = ^TProtectRecord;

  TDebugger = TProtectRecord;
  PTDebugger = ^TDebugger;


  TConfigWnd = class(TForm)
    memoLog1: TRichEdit;
    grpBox1: TGroupBox;
    lblSysName: TLabel;
    lblSysVer: TLabel;
    lblCpu: TLabel;
    grpBox2: TGroupBox;
    chkFlag1: TCheckBox;
    chkFlag2: TCheckBox;
    chkFlag3: TCheckBox;
    chkFlag4: TCheckBox;
    chkFlag5: TCheckBox;
    chkFlag6: TCheckBox;
    btnAction1: TButton;
    pageMain1: TPageControl;
    TabSheet1: TTabSheet;
    listItems1: TListView;
    dlgOpen1: TOpenDialog;
    popMenu1: TPopupMenu;
    mnuCmd1: TMenuItem;
    mnuCmd2: TMenuItem;
    mnuCmd3: TMenuItem;
    TabSheet2: TTabSheet;
    pageSub1: TPageControl;
    TabSheet3: TTabSheet;
    chkOpt7: TCheckBox;
    imgPick1: TImage;
    lblDrag: TLabel;
    grpBox3: TGroupBox;
    chkOpt8: TCheckBox;
    chkOpt9: TCheckBox;
    lblNote: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnAction1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mnuCmd2Click(Sender: TObject);
    procedure mnuCmd3Click(Sender: TObject);
    procedure listItems1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mnuCmd1Click(Sender: TObject);
    procedure imgPick1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgPick1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgPick1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure chkOpt7Click(Sender: TObject);
    procedure chkOpt8Click(Sender: TObject);
    procedure chkOpt9Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    procedure AppOnIdle(Sender: TObject; var Done: Boolean);
  public
    { Public declarations }
    lastHandle: HWND;
    m_SelectedProcessId: DWORD;
    m_targetProcessId: DWORD;

    procedure GetWindowsNTVer;
    procedure RefCheckBoxState;
    procedure RefDebuggerListView;
    procedure LoadCheckBoxState;
    procedure SaveCheckBoxState;
    procedure LoadDebuggerList;
    procedure SaveDebuggerList;
    function StartDebugger(szExe: string): Boolean;
    procedure Enabled_TL_Confrontation;
    procedure LoadCopyright;
  private
    m_Caption: string;
    m_Log1: string;
  end;

  procedure PrintLog(lpData: Pointer); stdcall;

exports
  PrintLog;

var
  AppWnd: TConfigWnd;
  g_DebuggerList: TGList;

const
  _STR_KEY = '9dd14d00f5dd71bd';  {��õ�������16λmd5����õ�}
  _STR_COPYRIGHT = 'copyright.db';
  _STR_TL_EXE = '[TL.exe]';
  _STR_DEBUGGER_INI = 'DebuggerList.ini';
  _STR_CONFIG_INI = 'Config.ini';
  _STR_STARTUP_INFO_INI = 'StartupInfo.ini';
  crScope = 1;  //Delphi�Ĺ��״̬���Ǹ��������Զ��������Ϳ��Ա�����ϵͳ�Ĺ���ͻ

implementation

uses Log, UnrealDbgDll, Grobal, LockThread, HandlerTLDetection, EventHandlerThread,
  GlobalVar, KeyVerification, VMProtectSDK, D_encryptionDll;

{$R *.dfm}

//�����������ⲿģ�����
procedure PrintLog(lpData: Pointer); stdcall;
begin
  try
    sLog.outInfo(WideCharToString(lpData));
  except on e:Exception do
    sLog.outError('[PrintLog]===>' + e.Message);
  end;
end;

function GetWMIOperatingSystem(WMIProperty: string): string;
var
  Wmi, Objs, Obj: OleVariant;
  Enum: IEnumVariant;
  C: Cardinal;
begin
  Wmi := CreateOleObject('WbemScripting.SWbemLocator');
  Objs := Wmi.ConnectServer('.','root/cimv2').ExecQuery('Select ' + WMIProperty + ' from Win32_OperatingSystem');
  Enum := IEnumVariant(IUnknown(Objs._NewEnum));
  Enum.Reset;
  Enum.Next(1, Obj, C);
  Obj := Obj.Properties_.Item(WMIProperty, 0).Value;
  Result := Obj;
end;

function GetWMIProcessor(WMIProperty: string): string;
var
  Wmi, Objs, Obj: OleVariant;
  Enum: IEnumVariant;
  C: Cardinal;
begin
  Wmi := CreateOleObject('WbemScripting.SWbemLocator');
  Objs := Wmi.ConnectServer('.','root/cimv2').ExecQuery('Select ' + WMIProperty + ' from Win32_Processor');
  Enum := IEnumVariant(IUnknown(Objs._NewEnum));
  Enum.Reset;
  Enum.Next(1, Obj, C);
  Obj := Obj.Properties_.Item(WMIProperty, 0).Value;
  Result := Obj;
end;

procedure TConfigWnd.GetWindowsNTVer;
var
  VerInfo: array[0..64] of Char;
  WinDir: array[0..255] of Char;
  ntoskrnl, OSText: string;
begin
  try
    OSText := GetWMIOperatingSystem('Caption') + GetWMIOperatingSystem('Version') + '  ' + GetWMIProcessor('AddressWidth') + 'λ����ϵͳ';
    lblSysName.Caption := lblSysName.Caption + '  ' + OSText;

    FillChar(WinDir[0],Length(WinDir) * 2,#0);
    GetSystemDirectory(WinDir,Length(WinDir));
    ntoskrnl := WinDir + '\ntoskrnl.exe';
    FillChar(VerInfo[0],Length(VerInfo) * 2,#0);
    Unreal_GetFileVersion(ntoskrnl, @VerInfo);
    lblSysVer.Caption := lblSysVer.Caption + '  ntoskrnl.exe  ' + VerInfo;

    lblCpu.Caption := lblCpu.Caption + '  ' + GetWMIProcessor('Name');

  except on e:Exception do
    sLog.outError('[TConfigWnd.GetWindowsNTVer]===>' + e.Message);
  end;
end;

procedure HighlightWindowBorder(Handle: HWND);
var
  DC: HDC;
  Rect: TRect;
  Pen: HGDIOBJ;
  Rgn: HRGN;
  Brush: HBRUSH;
  SysColor: DWORD;
  original_pen: HGDIOBJ;
  original_brush: HGDIOBJ;
  WndWidth: Integer;
  WndHeight: Integer;
  frameWidth: Integer;
  frameHeight: Integer;
  screen_Width: Integer;
  screen_height: Integer;
begin
  if Handle <> 0 then begin
    DC := GetWindowDC(Handle);
    if DC <> 0 then begin
      try
        WndWidth := GetSystemMetrics(SM_CXBORDER); // ���ڱ߿�Ŀ�ȣ�������Ϊ��λ��
        WndHeight := GetSystemMetrics(SM_CYBORDER); // ���ڱ߿�ĸ߶ȣ�������Ϊ��λ��

        Rgn := CreateRectRgn(0, 0, 0, 0);
        Pen := CreatePen(PS_INSIDEFRAME, 3 * WndWidth, RGB(0, 0, 0));  //��������
        original_pen := SelectObject(DC, Pen);
        original_brush := SelectObject(DC, GetStockObject(NULL_BRUSH)); // ѡ��һ�����Ļ�ˢ NULL_BRUSH
        SetROP2(DC, R2_NOT);
        if GetWindowRgn(Handle,Rgn) <> 0 then begin
          SysColor := GetSysColor(COLOR_WINDOWFRAME);
          Brush := CreateHatchBrush(HS_DIAGCROSS, SysColor); //45 �Ƚ���Ӱ��
          FrameRgn(DC, Rgn, Brush, 3 * WndWidth, 3 * WndHeight);
          DeleteObject(Brush);
        end else begin
          frameWidth := GetSystemMetrics(SM_CXFRAME);        // SM_CXFRAME �߿�Ŀ�ȣ�������Ϊ��λ��
          frameHeight := GetSystemMetrics(SM_CYFRAME);       // SM_CYFRAME �߿�ĸ߶ȣ�������Ϊ��λ��
          screen_Width := GetSystemMetrics(SM_CXSCREEN);       // SM_CXSCREEN ����ʾ������Ļ��ȣ�������Ϊ��λ��
          screen_height := GetSystemMetrics(SM_CYSCREEN);      // SM_CYSCREEN ����ʾ������Ļ�߶ȣ�������Ϊ��λ��
          GetWindowRect(Handle, Rect);               // ��ȡ���ڳߴ�

          //��鴰���Ƿ����
          if IsZoomed(Handle) then begin
            Rectangle(DC, frameWidth, frameHeight, frameWidth + screen_Width, screen_height + frameHeight);
          end else begin
            Rectangle(DC, 0, 0, Rect.right - Rect.left, Rect.bottom - Rect.top);// ���ƾ��α߿� ʹ�õ�ǰ�ʹ��վ���������ʹ�õ�ǰ��ˢ�����Ρ�
          end;
        end;
        SelectObject(DC, original_brush);          // ��ԭ��ˢ
        SelectObject(DC, original_pen);            // ��ԭ����
        DeleteObject(Pen);
        DeleteObject(Rgn);

      finally
        ReleaseDC(Handle, DC);
      end;
    end;
  end;
end;

//����߿�
procedure CleanBorder(Handle: HWND);
begin
  HighlightWindowBorder(Handle);
end;

procedure TConfigWnd.imgPick1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ResourceStream: TResourceStream;
begin
  if (ssLeft in Shift) then begin
    // ����Դ���ص�һ��ͼƬ
    ResourceStream := TResourceStream.Create(HInstance, 'Empty', RT_RCDATA);
    try
      imgPick1.Picture.Graphic.LoadFromStream(ResourceStream);
      SetCursor(Screen.Cursors[crScope]);
    finally
      ResourceStream.Free;
    end;
  end;
end;

procedure TConfigWnd.imgPick1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  Handle: HWND;
  Point: TPoint;
  SelfProcessId: DWORD;
  targetProcessId: DWORD;
begin
  // ����������Ƿ񱻰���
  if (ssLeft in Shift) then begin

    // ��ȡ��굱ǰλ��
    if GetCursorPos(Point) then begin
      // ���������ȡ���ھ��
      Handle := WindowFromPoint(Point);
      if (Handle <> 0) and (Handle <> lastHandle) then begin
        GetWindowThreadProcessId(Application.Handle,@SelfProcessId);
        GetWindowThreadProcessId(Handle,@targetProcessId);
        if targetProcessId <> SelfProcessId then begin
          CleanBorder(lastHandle);
          HighlightWindowBorder(Handle);
          lastHandle := Handle;
          m_SelectedProcessId := targetProcessId;
        end;
      end;
    end;
  end;
end;

procedure TConfigWnd.imgPick1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ResourceStream: TResourceStream;
  sText: string;
  btn: Integer;
  MsgRcd: TMsgRcd;
begin
  try
    if Button = mbLeft then begin
      // �л�ͼƬ
      if Assigned(imgPick1.Picture.Graphic) then
      begin
        ResourceStream := TResourceStream.Create(HInstance, 'Original', RT_RCDATA);
        try
          imgPick1.Picture.Graphic.LoadFromStream(ResourceStream);
        finally
          ResourceStream.Free;
        end;
      end;

      CleanBorder(lastHandle);
      lastHandle := 0;

      if m_SelectedProcessId <> 0 then begin
        if g_boEnabled_tl_confrontation_TL then begin
          sText := 'pid: ' + m_SelectedProcessId.ToString + ' ��TL�Ľ�����';
          btn := MessageBox(0,PChar(sText),'ѡ��Ŀ�����:', MB_YESNO or MB_SYSTEMMODAL);
          if btn = IDYES then begin
            m_targetProcessId := m_SelectedProcessId;
            sLog.outInfo(_STR_TL_EXE + ' pid: ' + m_targetProcessId.ToString);
            MsgRcd.nAction := EVENT_ENABLED_TL_CONFRONTATION;
            g_EventHandlerThread.SendMsg(MsgRcd);
          end;
        end;
      end;
      m_SelectedProcessId := 0;
    end;
  except on e:Exception do
    sLog.outError('[TConfigWnd.imgPick1MouseUp]===>' + e.Message);
  end;
end;

//���TL�Կ�
procedure TConfigWnd.Enabled_TL_Confrontation;
var
  base: DWORD_PTR;
begin
  if m_targetProcessId <> 0 then begin
    if g_boEnabled_tl_confrontation_TL then begin
      if g_boHandlerGetTickCountCheck_TL then begin
        sLog.outDebug(_STR_TL_EXE + ' ���ڴ���GetTickCount���...');

        //�ж�֮ǰ�Ƿ��Ѿ�����
        if Assigned(g_LockThread) then begin
          g_LockThread.Stop;
          g_LockThread.WaitFor;
          g_LockThread.Free;
          g_LockThread := nil;
        end;
        base := GetProcessModuleBase(m_targetProcessId,'TL.exe');
        Handler_TLDetection(base); //����TL�ļ��
      end;

      if g_boBlockResumeThread_TL then begin
        sLog.outDebug(_STR_TL_EXE + ' ��ֹ��Ϸ�ָ��߳�');
        Unreal_TL_BlockGameResumeThread(m_targetProcessId);
      end;
    end;
  end;
end;

procedure TConfigWnd.btnAction1Click(Sender: TObject);
begin
  VMProtectBeginVirtualization('VMP');
  try
    if g_boLoginSuccess then begin
      g_boStartService := True;
      btnAction1.Enabled := False;
      if not Unreal_Initialize($9dd14d00f5dd71bd) then begin
        sLog.outError('�豸δ�ܳɹ�����!');
      end;
    end else begin
      sLog.outError('δͨ����Ȩ��֤!');
    end;
  except on e:Exception do
    sLog.outError('[TConfigWnd.btnAction1Click]===>' + e.Message);
  end;
  VMProtectEnd;
end;

procedure TConfigWnd.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  btn: Integer;
begin
  try
    if g_boStartService then begin
      btn := Application.MessageBox('��ȷ��Ҫ�رճ��򴰿���ֻ��������Բ�����ȫ�˳�VT����ģʽ!', '����:', MB_YESNO or MB_ICONWARNING or MB_SYSTEMMODAL);
      if btn = ID_YES then begin
        CanClose := True;
      end else begin
        CanClose := False;
      end;
    end else begin
      CanClose := True;
    end;
  except on e:Exception do
    sLog.outError('[TConfigWnd.FormCloseQuery]===>' + e.Message);
  end;
end;

procedure TConfigWnd.LoadCopyright;
var
  sFileName, sPath: string;
  decryptedDataLen: Integer;
  PlainText: array of Char;
  PlainTextLen: Integer;
  jsonStr: string;
  json: TJSONObject;
begin
  try
    m_Caption := '��õ�����   by: Bug����ʦ   QQȺ:740336586';
    m_Log1 := '��õ����� QQȺ:740336586';

    sPath := ExtractFilePath(Application.ExeName);
    if sPath <> '' then begin
      sFileName := sPath + _STR_COPYRIGHT;
      if FileExists(sFileName) then begin
        //���ص����ֽ�����������β���ַ�
        decryptedDataLen := D_encryption_DecryptDataFromFile(sFileName,_STR_KEY,nil);
        if decryptedDataLen > 0 then begin
          PlainTextLen := (decryptedDataLen div 2) + 1;
          SetLength(PlainText,PlainTextLen); //�������ַ�����
          FillChar(PlainText[0],Length(PlainText) * SizeOf(Char),#0);
          decryptedDataLen := D_encryption_DecryptDataFromFile(sFileName,_STR_KEY,@PlainText[0]);
          jsonStr := string(PChar(@PlainText[0]));
          json := json.ParseJSONValue(jsonStr) as TJSONObject;     //����json
          m_Caption := json.Values['��õ���������'].AsType<string>;
          m_Log1 := json.Values['QQȺ��־'].AsType<string>;
          json.Free;
          SetLength(PlainText,0);
        end;
      end;
    end;
  except on e:Exception do begin
    MessageBox(0,'��ȡ��Ȩ��Ϣʧ��!','����:',MB_ICONERROR);
    ExitProcess(0);
  end;
  end;
end;

procedure TConfigWnd.FormCreate(Sender: TObject);
begin
  memoLog1.Clear;
  sLog.setLog(memoLog1);
  Application.OnIdle := AppOnIdle;


  LoadCopyright;
  Caption := m_Caption;

  sLog.outDebug('��л��΢���ʺ��ģ�����ο���HvmDbg��');
  sLog.outDebug('ʹ�ñ������������ɵ�ֱ�ӻ��߼�ӵ���ʧ���������ге���');
  sLog.outDebug('by: Bug����ʦ');
  sLog.outDebug(m_Log1);
  sLog.outDebug('֧��Win10-Win11');
  sLog.outDebug('������Դ��ɳ��ۣ������ǹ��߷���Դ���ṩ�̣�');
  GetWindowsNTVer;

  Screen.Cursors[crScope] := LoadCursor(HInstance,'Cursor_1');

  g_boStartService := False;
  g_boLoginSuccess := False;

  VMProtectBeginVirtualization('VMP');
  g_Authentication := TAuthentication.Create;
  if g_Authentication.cdkeyLogin then begin
    {������Ȩ}
    SetPrivilege;
    g_DebuggerList := TGList.Create;
    g_EventHandlerThread := TEventHandlerThread.Create(False);
    LoadDebuggerList;
    LoadCheckBoxState;
  end;
  VMProtectEnd;
end;

//�ͷ���Դ֮ǰ��һ��Ҫ���ͷ��߳�
procedure TConfigWnd.FormDestroy(Sender: TObject);
var
  I: Integer;
begin
  if g_boLoginSuccess then begin
    if g_LockThread <> nil then begin
      g_LockThread.Stop;
      g_LockThread.WaitFor;
      g_LockThread.Free;
    end;

    if g_EventHandlerThread <> nil then begin
      g_EventHandlerThread.Stop;
      g_EventHandlerThread.WaitFor;
      g_EventHandlerThread.Free;
    end;

    for I := 0 to g_DebuggerList.Count - 1 do
      Dispose(PTDebugger(g_DebuggerList.Items[I]));
    g_DebuggerList.Free;
  end;

  g_Authentication.Free;
end;

procedure TConfigWnd.AppOnIdle(Sender: TObject; var Done: Boolean);
begin
  try
    sLog.OutputMsg;
    Done := False;
  except on e:Exception do
  end;
end;

procedure TConfigWnd.RefCheckBoxState;
begin
  try
    chkOpt7.Checked := g_boEnabled_tl_confrontation_TL;
    chkOpt8.Checked := g_boHandlerGetTickCountCheck_TL;
    chkOpt9.Checked := g_boBlockResumeThread_TL;
  except on e:Exception do
    sLog.outError('[TConfigWnd.RefCheckBoxState]===>' + e.Message);
  end;
end;

procedure TConfigWnd.RefDebuggerListView;
var
  I: Integer;
  pTemp: PTDebugger;
  item: TListItem;
begin
  try
    listItems1.Clear;
    g_DebuggerList.Lock;
    try
      for I := 0 to g_DebuggerList.Count - 1 do begin
        pTemp := g_DebuggerList.Items[I];
        if Assigned(pTemp) then begin
          item := listItems1.Items.Add;
          item.Caption := IntToStr(listItems1.Items.Count);  //���
          item.SubItems.Add(pTemp.filename);      //�ļ���
          item.SubItems.Add(pTemp.filePath);      //Ŀ¼
        end;
      end;
    finally
      g_DebuggerList.UnLock;
    end;
  except on e:Exception do
    sLog.outError('[TConfigWnd.RefDebuggerListView]===>' + e.Message);
  end;
end;

//����Ƿ��Ѿ�������ͬ����
function DebuggerItemExists(filename, filePath: string): Boolean;
var
  I: Integer;
  pTemp: PTDebugger;
begin
  try
    Result := False;
    if (filename <> '') and (filePath <> '') then begin
      g_DebuggerList.Lock;
      try
        for I := 0 to g_DebuggerList.Count - 1 do begin
          pTemp := g_DebuggerList.Items[I];
          if pTemp <> nil then begin
            if (pTemp.filename = filename) and (pTemp.filePath = filePath) then begin
              Result := True;
              Break;
            end;
          end;
        end;
      finally
        g_DebuggerList.UnLock;
      end;
    end;
  except on e:Exception do
    sLog.outError('[DebuggerItemExists]===>' + e.Message);
  end;
end;


procedure TConfigWnd.LoadDebuggerList;
var
  Config: TIniFile;
  sPath, sText: string;
  ItemCount: Integer;
  I: Integer;
  filename, filePath: string;
  pTemp: PTDebugger;
begin
  try
    sPath := ExtractFilePath(Application.ExeName);
    if sPath <> '' then begin
      sPath := sPath + _STR_DEBUGGER_INI;
      if FileExists(sPath) then begin
        Config := TIniFile.Create(sPath);
        ItemCount := Config.ReadString('����','Count','0').ToInteger;
        for I := 0 to ItemCount - 1 do begin
          sText := Config.ReadString('����','Debugger' + I.ToString,'');
          if sText <> '' then begin
            sText := GetValidStr3(sText,filename,['&']);
            sText := GetValidStr3(sText,filePath,['&']);

            if (filename <> '') and (filePath <> '') then begin
              New(pTemp);
              FillChar(pTemp^,SizeOf(TDebugger),#0);
              pTemp.filename := filename;
              pTemp.filePath := filePath;

              g_DebuggerList.Lock;
              try
                g_DebuggerList.Add(pTemp);
              finally
                g_DebuggerList.UnLock;
              end;
              RefDebuggerListView;
            end;
          end;
        end;
        Config.Free;
      end;
    end;
  except on e:Exception do
    sLog.outError('[TConfigWnd.LoadDebuggerList]===>' + e.Message);
  end;
end;

procedure TConfigWnd.SaveDebuggerList;
var
  Config: TIniFile;
  sPath: string;
  I: Integer;
  pTemp: PTDebugger;
begin
  try
    sPath := ExtractFilePath(Application.ExeName);
    if sPath <> '' then begin
      sPath := sPath + _STR_DEBUGGER_INI;
      if FileExists(sPath) then begin
        DeleteFile(sPath);
      end;

      Config := TIniFile.Create(sPath);
      g_DebuggerList.Lock;
      try
        Config.WriteString('����','Count',g_DebuggerList.Count.ToString);
        for I := 0 to g_DebuggerList.Count - 1 do begin
          pTemp := g_DebuggerList.Items[I];
          if Assigned(pTemp) then begin
            Config.WriteString('����','Debugger' + I.ToString,pTemp.filename + '&' + pTemp.filePath);
          end;
        end;
      finally
        g_DebuggerList.UnLock;
      end;
      Config.Free;
    end;
  except on e:Exception do
    sLog.outError('[TConfigWnd.SaveDebuggerList]===>' + e.Message);
  end;
end;

procedure TConfigWnd.LoadCheckBoxState;
var
  Config: TIniFile;
  sPath: string;
begin
  try
    sPath := ExtractFilePath(Application.ExeName);
    if sPath <> '' then begin
      sPath := sPath + _STR_CONFIG_INI;
      if FileExists(sPath) then begin
        Config := TIniFile.Create(sPath);
        g_boEnabled_tl_confrontation_TL := Config.ReadBool('TL','enabled_tl_confrontation', g_boEnabled_tl_confrontation_TL);
        g_boHandlerGetTickCountCheck_TL := Config.ReadBool('TL','handler_gettickcount_check', g_boHandlerGetTickCountCheck_TL);
        g_boBlockResumeThread_TL := Config.ReadBool('TL','BlockResumeThread', g_boBlockResumeThread_TL);
        Config.Free;
      end;
    end;
    RefCheckBoxState;
  except on e:Exception do
    sLog.outError('[TConfigWnd.LoadCheckBoxState]===>' + e.Message);
  end;
end;

procedure TConfigWnd.SaveCheckBoxState;
var
  Config: TIniFile;
  sPath: string;
begin
  try
    sPath := ExtractFilePath(Application.ExeName);
    if sPath <> '' then begin
      sPath := sPath + _STR_CONFIG_INI;

      Config := TIniFile.Create(sPath);
      Config.WriteBool('TL','enabled_tl_confrontation', g_boEnabled_tl_confrontation_TL);
      Config.WriteBool('TL','handler_gettickcount_check', g_boHandlerGetTickCountCheck_TL);
      Config.WriteBool('TL','BlockResumeThread', g_boBlockResumeThread_TL);
      Config.Free;
    end;
  except on e:Exception do
    sLog.outError('[TConfigWnd.SaveCheckBoxState]===>' + e.Message);
  end;
end;

function TConfigWnd.StartDebugger(szExe: string): Boolean;
begin
  Result := False;
  if Unreal_StartProcess(szExe,GetApplicationPath) then begin
    Result := True;
  end;
end;

//�����ļ�����
function CreateCopyFile(fileName: string; filePath: string): string;
var
  iniFile: TIniFile;
  sPath,sfixedPath: string;
  PrefixName,suffixName,sName: string;
begin
  try
    Result := '';
    sPath := ExtractFilePath(filePath);
    sfixedPath := sPath;
    if sPath <> '' then begin
      sPath := sPath + _STR_STARTUP_INFO_INI;

      iniFile := TIniFile.Create(sPath);
      if FileExists(sPath) then begin
        //ȡ��ԭ�ļ���
        sName := iniFile.ReadString(fileName,'fileName','');
        sName := sfixedPath + sName;
        DeleteFile(sName);  //ɾ�����ļ�
      end;

      PrefixName := GenerateRandomString(8);
      suffixName := GenerateRandomString(3);
      sName := PrefixName + '.' + suffixName;
      iniFile.WriteString(fileName,'fileName',sName);

      sName := sfixedPath + sName;
      CopyFile(PChar(filePath),PChar(sName),False);
      Result := sName;
      iniFile.Free;
    end;
  except on e:Exception do
    sLog.outError('[CreateCopyFile]===>' + e.Message);
  end;
end;

procedure TConfigWnd.mnuCmd1Click(Sender: TObject);
var
  pTemp: PTDebugger;
  I: Integer;
  sNewFile, fileName, filePath: string;
  item: TListItem;
begin
  try
    if Assigned(listItems1.Selected) then begin
      item := listItems1.Items.Item[listItems1.ItemIndex];
      if Assigned(item) then begin
        fileName := item.SubItems.Strings[0];
        filePath := item.SubItems.Strings[1];
        if (fileName <> '') and (filePath <> '') then begin
          StartDebugger(filePath);
//          sNewFile := CreateCopyFile(fileName,filePath);
//          if sNewFile <> '' then begin
//            StartDebugger(sNewFile);
//          end;
        end;
      end;
    end;
  except on e:Exception do
    sLog.outError('[TConfigWnd.mnuCmd1Click]===>' + e.Message);
  end;
end;


procedure TConfigWnd.chkOpt9Click(Sender: TObject);
begin
  g_boBlockResumeThread_TL := chkOpt9.Checked;
  SaveCheckBoxState;
end;

procedure TConfigWnd.chkOpt7Click(Sender: TObject);
begin
  g_boEnabled_tl_confrontation_TL := chkOpt7.Checked;
  SaveCheckBoxState;
end;

procedure TConfigWnd.chkOpt8Click(Sender: TObject);
begin
  g_boHandlerGetTickCountCheck_TL := chkOpt8.Checked;
  SaveCheckBoxState;
end;

procedure TConfigWnd.listItems1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  curpos: TPoint;
begin
  try
    if (Button = mbRight) then begin
      if Assigned(TListView(Sender).Selected) then begin
        mnuCmd3.Enabled := True;
      end else begin
        mnuCmd3.Enabled := False;
      end;
      GetCursorPos(curpos);
      popMenu1.Popup(curpos.X + 10,curpos.Y);
    end;
  except on e:Exception do
    sLog.outError('[TConfigWnd.listItems1MouseDown]===>' + e.Message);
  end;
end;


procedure TConfigWnd.mnuCmd3Click(Sender: TObject);
var
  pTemp: PTDebugger;
  I: Integer;
  sText, fileName, filePath: string;
  item: TListItem;
begin
  try
    if Assigned(listItems1.Selected) then begin
      item := listItems1.Items.Item[listItems1.ItemIndex];
      if Assigned(item) then begin
        fileName := item.SubItems.Strings[0];
        filePath := item.SubItems.Strings[1];
        if (fileName <> '') and (filePath <> '') then begin
          if Application.MessageBox('�Ƿ�ȷ���Ƴ�ѡ�е��', 'ȷ����Ϣ', MB_YESNO + MB_ICONQUESTION) = IDYES then begin
            g_DebuggerList.Lock;
            try
              for I := g_DebuggerList.Count - 1 downto 0 do begin
                pTemp := g_DebuggerList.Items[I];
                if pTemp <> nil then begin
                  if (pTemp.filename = fileName) and (pTemp.filePath = filePath) then begin
                    g_DebuggerList.Remove(pTemp);
                    Dispose(pTemp);
                    Break;
                  end;
                end else begin
                  g_DebuggerList.Delete(I);
                end;
              end;
            finally
              g_DebuggerList.UnLock;
            end;
            SaveDebuggerList;
            RefDebuggerListView;
          end;
        end;
      end;
    end;
  except on e:Exception do
    sLog.outError('[TConfigWnd.mnuCmd3Click]===>' + e.Message);
  end;
end;

procedure TConfigWnd.mnuCmd2Click(Sender: TObject);
var
  filename, filePath: string;
  pTemp: PTDebugger;
begin
  try
    dlgOpen1.Title := '��ѡ�������';
    dlgOpen1.FileName := '';
    dlgOpen1.Execute;
    filename := ExtractFileName(dlgOpen1.FileName);  //��ȡ�ļ���
    filePath := dlgOpen1.FileName;  //��ȡ�ļ�·��

    if (filename <> '') and (filePath <> '') then begin
      if not DebuggerItemExists(filename,filePath) then begin
        New(pTemp);
        FillChar(pTemp^,SizeOf(TDebugger),#0);
        pTemp.filename := filename;
        pTemp.filePath := filePath;

        g_DebuggerList.Lock;
        try
          g_DebuggerList.Add(pTemp);
        finally
          g_DebuggerList.UnLock;
        end;
        SaveDebuggerList;
        RefDebuggerListView;
      end else begin
        Application.MessageBox('���������Ѿ��������б���..', '����:', MB_ICONWARNING);
      end;
    end;
  except on e:Exception do
    sLog.outError('[TConfigWnd.mnuCmd2Click]===>' + e.Message);
  end;
end;

end.
