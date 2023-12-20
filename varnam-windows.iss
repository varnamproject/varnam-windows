#define MyAppName "Varnam Windows"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Varnam Project"
#define MyAppURL "https://varnamproject.com/"

[Setup]
AppId={{16D493F4-EAE7-4A0D-A86A-CCB580A6310C}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
LicenseFile=LICENSE.md
PrivilegesRequired=admin
OutputBaseFilename=Install Varnam Windows
SetupIconFile=.assets\varnam.ico
UninstallDisplayIcon=.assets\varnam.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
AlwaysRestart = yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "govarnam/LICENSE.txt"; Flags: dontcopy
Source: "cpp\x64\Debug\libgovarnam.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "cpp\x64\Debug\libgovarnam.lib"; DestDir: "{app}"; Flags: ignoreversion
Source: "cpp\x64\Debug\Varnam Windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "cpp\x64\Debug\Varnam Windows.exp"; DestDir: "{app}"; Flags: ignoreversion
Source: "cpp\x64\Debug\Varnam Windows.lib"; DestDir: "{app}"; Flags: ignoreversion
Source: "cpp\x64\Debug\Varnam Windows.pdb"; DestDir: "{app}"; Flags: ignoreversion
Source: "cpp\x64\Debug\vlf_import.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "cpp\x64\Debug\configure_languages.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "cpp\x64\Debug\schemes_bundle_for_installer\*"; DestDir: "{app}\schemes"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "cpp\x64\Debug\languages_enabled_config.json"; DestDir: "{app}"; Flags: ignoreversion

[Code]
var
  LanguagesEnabled: TStrings;
  EnableLanguagesCalled: Boolean;
  EnableLanguagesExecuted: Boolean;

  SecondLicensePage: TOutputMsgMemoWizardPage;
  License2AcceptedRadio: TRadioButton;
  License2NotAcceptedRadio: TRadioButton;

function InitializeSetup(): Boolean;
begin
  Result := True;
end;

procedure CheckLicense2Accepted(Sender: TObject);
begin
  WizardForm.NextButton.Enabled := License2AcceptedRadio.Checked;
end;

function CloneLicenseRadioButton(Source: TRadioButton): TRadioButton;
begin
  Result := TRadioButton.Create(WizardForm);
  Result.Parent := SecondLicensePage.Surface;
  Result.Caption := Source.Caption;
  Result.Left := Source.Left;
  Result.Top := Source.Top;
  Result.Width := Source.Width;
  Result.Height := Source.Height;
  Result.Anchors := Source.Anchors;
  Result.OnClick := @CheckLicense2Accepted;
end;

procedure InitializeWizard();
var
  LicenseFileName: string;
  LicenseFilePath: string;
begin
  LanguagesEnabled := TStringList.Create;
  EnableLanguagesCalled := False;

  SecondLicensePage :=
    CreateOutputMsgMemoPage(
      wpLicense, SetupMessage(msgWizardLicense), SetupMessage(msgLicenseLabel),
      SetupMessage(msgLicenseLabel3), '');

  SecondLicensePage.RichEditViewer.Height := WizardForm.LicenseMemo.Height;

  LicenseFileName := 'LICENSE.txt';
  ExtractTemporaryFile(LicenseFileName);
  LicenseFilePath := ExpandConstant('{tmp}\' + LicenseFileName);
  SecondLicensePage.RichEditViewer.Lines.LoadFromFile(LicenseFilePath);
  DeleteFile(LicenseFilePath);

  License2AcceptedRadio :=
    CloneLicenseRadioButton(WizardForm.LicenseAcceptedRadio);
  License2NotAcceptedRadio :=
    CloneLicenseRadioButton(WizardForm.LicenseNotAcceptedRadio);

  License2NotAcceptedRadio.Checked := True;  
end;

procedure DeinitializeSetup();
begin
  LanguagesEnabled.Free;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;

  if (CurPageID = wpSelectTasks) and not EnableLanguagesCalled then
  begin
    // Clear any previous selections
    LanguagesEnabled.Clear;

    // Check each language task and add to the list if selected
    if WizardIsTaskSelected('malayalam') then
      LanguagesEnabled.Add('malayalam');
    if WizardIsTaskSelected('assamese') then
      LanguagesEnabled.Add('assamese');
    if WizardIsTaskSelected('marathi') then
      LanguagesEnabled.Add('marathi');
    if WizardIsTaskSelected('bengali') then
      LanguagesEnabled.Add('bengali');
    if WizardIsTaskSelected('nepali') then
      LanguagesEnabled.Add('nepali');
    if WizardIsTaskSelected('gujarati') then
      LanguagesEnabled.Add('gujarati');
    if WizardIsTaskSelected('odia') then
      LanguagesEnabled.Add('odia');
    if WizardIsTaskSelected('hindi') then
      LanguagesEnabled.Add('hindi');
    if WizardIsTaskSelected('punjabi') then
      LanguagesEnabled.Add('punjabi');
    if WizardIsTaskSelected('kannada') then
      LanguagesEnabled.Add('kannada');
    if WizardIsTaskSelected('sanskrit') then
      LanguagesEnabled.Add('sanskrit');
    if WizardIsTaskSelected('tamil') then
      LanguagesEnabled.Add('tamil');
    if WizardIsTaskSelected('telugu') then
      LanguagesEnabled.Add('telugu');
  end;
end;

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

function EnableLanguages(): Boolean;
var
  I: Integer;
  ErrorCode: Integer;
begin
  // Execute configure_languages.exe for each enabled language
  for I := 0 to LanguagesEnabled.Count - 1 do
  begin
    ShellExec('open', ExpandConstant('{app}\configure_languages.exe'), LanguagesEnabled[I], '', SW_SHOW, ewWaitUntilTerminated, ErrorCode);
  end;

  Result := True;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  // Update Next button when user gets to second license page
  if CurPageID = SecondLicensePage.ID then
  begin
    CheckLicense2Accepted(nil);
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    AddToPath(ExpandConstant('{app}'));
    EnableLanguagesExecuted := False;
  end;
end;

procedure RunEnableLanguagesSetup;
begin
  if not EnableLanguagesExecuted then
  begin
    EnableLanguages();
    EnableLanguagesExecuted := True;
  end;
end;

[Icons]
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"

[Tasks]
Name: "languages"; Description: "Select the languages you want to use Varnam with"; GroupDescription: "Languages:"; Flags: exclusive
Name: "malayalam"; Description: "Malayalam (മലയാളം)"; GroupDescription: "Languages:"; Flags: unchecked
Name: "assamese"; Description: "Assamese (অসমীয়া)"; GroupDescription: "Languages:"; Flags: unchecked
Name: "marathi"; Description: "Marathi (मराठी)"; GroupDescription: "Languages:"; Flags: unchecked
Name: "bengali"; Description: "Bengali (বাংলা)"; GroupDescription: "Languages:"; Flags: unchecked
Name: "nepali"; Description: "Nepali (नेपाली)"; GroupDescription: "Languages:"; Flags: unchecked
Name: "gujarati"; Description: "Gujarati (ગુજરાતી)"; GroupDescription: "Languages:"; Flags: unchecked
Name: "odia"; Description: "Odia (ଓଡ଼ିଆ)"; GroupDescription: "Languages:"; Flags: unchecked
Name: "hindi"; Description: "Hindi (हिन्दी)"; GroupDescription: "Languages:"; Flags: unchecked
Name: "punjabi"; Description: "Punjabi (ਪੰਜਾਬੀ)"; GroupDescription: "Languages:"; Flags: unchecked
Name: "kannada"; Description: "Kannada (ಕನ್ನಡ)"; GroupDescription: "Languages:"; Flags: unchecked
Name: "sanskrit"; Description: "Sanskrit (संस्कृतम्)"; GroupDescription: "Languages:"; Flags: unchecked
Name: "tamil"; Description: "Tamil (தமிழ்)"; GroupDescription: "Languages:"; Flags: unchecked
Name: "telugu"; Description: "Telugu (తెలుగు)"; GroupDescription: "Languages:"; Flags: unchecked

[Run]
Filename: "{sys}\regsvr32.exe"; Parameters: "/s ""{app}\Varnam Windows.dll"""; Flags: runhidden; StatusMsg: "Registering Varnam IME Windows DLL..."; BeforeInstall: RunEnableLanguagesSetup
Filename: "{app}\vlf_import.exe"; Parameters: "schemes"; Flags: runhidden; StatusMsg: "Importing words from VLF for Varnam Schemes..."

[UninstallRun]
Filename: "{sys}\regsvr32.exe"; Parameters: "/s /u ""{app}\Varnam Windows.dll"""; Flags: runhidden; StatusMsg: "Unregistering Varnam IME Windows DLL..."