#define MyAppName "Varnam Windows"
#define MyAppVersion "0.1.0"
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
PrivilegesRequired=lowest
OutputBaseFilename=Install Varnam Windows
SetupIconFile=.assets\varnam.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "govarnam\windows-build.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "cpp\x64\Debug\libgovarnam.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "cpp\x64\Debug\libgovarnam.lib"; DestDir: "{app}"; Flags: ignoreversion
Source: "cpp\x64\Debug\Varnam Windows.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "cpp\x64\Debug\Varnam Windows.exp"; DestDir: "{app}"; Flags: ignoreversion
Source: "cpp\x64\Debug\Varnam Windows.lib"; DestDir: "{app}"; Flags: ignoreversion
Source: "cpp\x64\Debug\Varnam Windows.pdb"; DestDir: "{app}"; Flags: ignoreversion
Source: "cpp\x64\Debug\vlf_import.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "cpp\x64\Debug\schemes\*"; DestDir: "{app}\schemes"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "cpp\x64\Debug\languages_enabled_config.json"; DestDir: "{app}"; Flags: ignoreversion

[Run]
Filename: "{app}\windows-build.bat"; Parameters: ""; Flags: runhidden; StatusMsg: "Updating Varnam schemes..."
Filename: "{sys}\regsvr32.exe"; Parameters: """{app}\Varnam Windows.dll"""; Flags: runhidden; StatusMsg: "Registering Varnam IME Windows DLL..."

[Tasks]
Name: "languages"; Description: "Select languages"; GroupDescription: "Languages:"; Flags: exclusive
Name: "languages\malayalam"; Description: "Malayalam"; GroupDescription: "Languages:"; Flags: unchecked
Name: "languages\assamese"; Description: "Assamese"; GroupDescription: "Languages:"; Flags: unchecked
Name: "languages\marathi"; Description: "Marathi"; GroupDescription: "Languages:"; Flags: unchecked
Name: "languages\bengali"; Description: "Bengali"; GroupDescription: "Languages:"; Flags: unchecked
Name: "languages\nepali"; Description: "Nepali"; GroupDescription: "Languages:"; Flags: unchecked
Name: "languages\gujarati"; Description: "Gujarati"; GroupDescription: "Languages:"; Flags: unchecked
Name: "languages\odia"; Description: "Odia"; GroupDescription: "Languages:"; Flags: unchecked
Name: "languages\hindi"; Description: "Hindi"; GroupDescription: "Languages:"; Flags: unchecked
Name: "languages\punjabi"; Description: "Punjabi"; GroupDescription: "Languages:"; Flags: unchecked
Name: "languages\kannada"; Description: "Kannada"; GroupDescription: "Languages:"; Flags: unchecked
Name: "languages\sanskrit"; Description: "Sanskrit"; GroupDescription: "Languages:"; Flags: unchecked
Name: "languages\tamil"; Description: "Tamil"; GroupDescription: "Languages:"; Flags: unchecked
Name: "languages\telugu"; Description: "Telugu"; GroupDescription: "Languages:"; Flags: unchecked

[Code]
procedure InitializeWizard();
var
  JsonFile: String;
  JsonSL: TStringList;
  JsonParser: TJSONParser;
  JsonRootObject: TJSONObject;
  JsonLanguages: TJSONObject;
  i: Integer;
  LanguageName, LanguageValue: String;
begin
  JsonSL := TStringList.Create;
  try
    // Load the JSON file
    JsonFile := ExpandConstant('{app}\languages_enabled_config.json');
    JsonSL.LoadFromFile(JsonFile);
    JsonParser := TJSONParser.Create;
    try
      // Parse the JSON
      JsonRootObject := JsonParser.Parse(JsonSL.Text);
      if JsonRootObject <> nil then
      begin
        try
          JsonLanguages := JsonRootObject.Get('languages').JSONValue as TJSONObject;
          for i := 0 to JsonLanguages.Count - 1 do
          begin
            LanguageName := JsonLanguages.Names[i];
            LanguageValue := JsonLanguages.Items[i].Value;
            // Update the task states based on the JSON values
            WizardForm.TasksList.CheckItem(WizardForm.TasksList.Items.IndexOfCaption(LanguageName, True), coCheckWithChildren, StrToBool(LanguageValue));
          end;
        finally
          JsonRootObject.Free;
        end;
      end;
    finally
      JsonParser.Free;
    end;
  finally
    JsonSL.Free;
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

function InitializeSetup(): Boolean;
begin
  AddToPath({app});
  Result := True;
end;

[Icons]
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
