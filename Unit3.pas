unit Unit3;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Bluetooth, FMX.Controls.Presentation, FMX.StdCtrls,
  System.Bluetooth.Components, IPPeerClient, IPPeerServer, System.Tether.Manager,
  FMX.ListBox, FMX.ScrollBox, FMX.Memo;

type
  TServerConnectionTH = class(TThread)
  private
    { Private declarations }
    FServerSocket: TBluetoothServerSocket;
    FSocket: TBluetoothSocket;
    FData: TBytes;
  protected
    procedure Execute; override;
  public
    { Public declarations }
    constructor Create(ACreateSuspended: Boolean);
    destructor Destroy; override;
  end;
  TForm3 = class(TForm)
    Button1: TButton;
    ComboBox1: TComboBox;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
     FBluetoothManager: TBluetoothManager;
    FDiscoverDevices: TBluetoothDeviceList;
    FPairedDevices: TBluetoothDeviceList;
    FAdapter: TBluetoothAdapter;
    FData: TBytes;
    FSocket: TBluetoothSocket;
    ItemIndex: Integer;
    ServerConnectionTH: TServerConnectionTH;
      procedure PairedDevices;
  end;


var
  Form3: TForm3;

implementation

{$R *.fmx}

 procedure TForm3.PairedDevices;
var
  I: Integer;
begin
  ComboBox1.Items.Clear;
  FPairedDevices := FBluetoothManager.GetPairedDevices;
  if FPairedDevices.Count > 0 then
    for I:= 0 to FPairedDevices.Count - 1 do
      ComboBox1.Items.Add(FPairedDevices[I].DeviceName)

end;

procedure TForm3.Button1Click(Sender: TObject);
begin
      try

    FBluetoothManager := TBluetoothManager.Current;
    FAdapter := FBluetoothManager.CurrentAdapter;
     if FBluetoothManager.ConnectionState = TBluetoothConnectionState.Connected then
     begin
         PairedDevices;
     end
     else
     begin
        showmessage('no device');
     end;

  except
    on E : Exception do
    begin
      ShowMessage(E.Message);
    end;
  end;
end;

{TServerConnection}

constructor TServerConnectionTH.Create(ACreateSuspended: Boolean);
begin
  inherited;
end;

destructor TServerConnectionTH.Destroy;
begin
  FSocket.Free;
  FServerSocket.Free;
  inherited;
end;

procedure TServerConnectionTH.execute;
var
  ASocket: TBluetoothSocket;
  Msg: string;
begin
  while not Terminated do
    try
      ASocket := nil;
      while not Terminated and (ASocket = nil) do
        ASocket := FServerSocket.Accept(100);
      if(ASocket <> nil) then
      begin
        FSocket := ASocket;
        while not Terminated do
        begin
          FData := ASocket.ReadData;
          if length(FData) > 0 then
            Synchronize(procedure
              begin
                Form3.memo1.Lines.Add(TEncoding.UTF8.GetString(FData));
              end);
          sleep(100);
        end;
      end;
    except
      on E : Exception do
      begin
        Msg := E.Message;
        Synchronize(procedure
          begin
            Form3.memo1.Lines.Add('Server Socket closed: ' + Msg);
          end);
      end;
    end;
end;


end.
