#define MyAppName "Varnam Windows"
#define MyAppVersion "0.1.0"
#define MyAppPublisher "Varnam Project"
#define MyAppURL "https://varnamproject.com/"

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{16D493F4-EAE7-4A0D-A86A-CCB580A6310C}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
LicenseFile=C:\Users\doxop\Downloads\LICENSE.txt
; Uncomment the following line to run in non administrative install mode (install for current user only.)
PrivilegesRequired=lowest
OutputBaseFilename=varnam-windows-install
SetupIconFile=C:\Users\doxop\Downloads\7657126.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "varnam-windows\govarnam\windows-build.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\lib\libgovarnam.dll"; DestDir: "C:\lib"; Flags: ignoreversion
Source: "C:\lib\libgovarnam.lib"; DestDir: "C:\lib"; Flags: ignoreversion
Source: "varnam-windows\cpp\x64\Debug\Varnam Windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "varnam-windows\cpp\x64\Debug\Varnam Windows.exp"; DestDir: "{app}"; Flags: ignoreversion
Source: "varnam-windows\cpp\x64\Debug\Varnam Windows.lib"; DestDir: "{app}"; Flags: ignoreversion
Source: "varnam-windows\cpp\x64\Debug\Varnam Windows.pdb"; DestDir: "{app}"; Flags: ignoreversion

[Run]
Filename: "{app}\windows-build.bat"; Parameters: ""; Flags: runhidden; StatusMsg: "Updating Govarnam schemes..."
; Register the DLL
Filename: "{sys}\regsvr32.exe"; Parameters: """{app}\Govarnam Windows.dll"""; Flags: runhidden; StatusMsg: "Registering Govarnam Windows DLL..."

[Code]
procedure AddToPath(NewPath: String);
var
  Path: String;
begin
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE, 'System\CurrentControlSet\Control\Session Manager\Environment', 'Path', Path) then
    Path := '';
  if (Pos(LowerCase(NewPath), LowerCase(Path)) = 0) then
    if Path <> '' then
      Path := Path + ';' + NewPath
    else
      Path := NewPath;
  RegWriteStringValue(HKEY_LOCAL_MACHINE, 'System\CurrentControlSet\Control\Session Manager\Environment', 'Path', Path);
end;

function InitializeSetup(): Boolean;
begin
  AddToPath('C:\lib');
  Result := True;
end;

[Icons]
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"

