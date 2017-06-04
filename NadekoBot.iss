#define sysfolder "system"
#define version "1.41"
#define target "win7-x64"

[Setup]
AppName=NadekoBot
AppVersion={#version}
AppPublisher=Kwoth
DefaultDirName={pf}\NadekoBot
DefaultGroupName=NadekoBot
UninstallDisplayIcon={app}\{#sysfolder}\nadeko_icon.ico
Compression=lzma2
SolidCompression=yes
OutputDir=userdocs:projekti/NadekoInstallerOutput
OutputBaseFilename=NadekoBot-setup-{#version}
AppReadmeFile=http://nadekobot.readthedocs.io/en/1.4/Commands%20List/
ArchitecturesInstallIn64BitMode=x64

[Files]
;install 
Source: "src\NadekoBot\bin\Release\PublishOutput\{#target}\*"; DestDir: "{app}\{#sysfolder}"; Permissions: users-full; Flags: recursesubdirs onlyifdoesntexist ignoreversion createallsubdirs; Excludes: "*.pdb, *.db"
;rename credentials example to credentials, but don't overwrite if it exists
Source: "src\NadekoBot\bin\Release\PublishOutput\{#target}\credentials_example.json"; DestName: "credentials.json"; DestDir: "{app}\{#sysfolder}"; Permissions: users-full; Flags: skipifsourcedoesntexist onlyifdoesntexist;

;reinstall - i want to copy all files, but i don't want to overwrite any data files because users will lose their customization if they don't have a backup, 
;            and i don't want them to have to backup and then copy-merge into data folder themselves, or lose their currency images due to overwrite.
Source: "src\NadekoBot\bin\Release\PublishOutput\{#target}\*"; DestDir: "{app}\{#sysfolder}"; Permissions: users-full; Flags: recursesubdirs onlyifdestfileexists createallsubdirs; Excludes: "*.pdb, *.db, data\*, credentials.json";
Source: "src\NadekoBot\bin\Release\PublishOutput\{#target}\data\*"; DestDir: "{app}\{#sysfolder}\data"; Permissions: users-full; Flags: recursesubdirs onlyifdoesntexist createallsubdirs;

;readme   
;Source: "readme"; DestDir: "{app}"; Flags: isreadme

[Run]
Filename: "http://nadekobot.readthedocs.io/en/1.4/JSON%20Explanations/"; Flags: postinstall shellexec runasoriginaluser; Description: "Open setup guide"
Filename: "{app}\{#sysfolder}\credentials.json"; Flags: postinstall shellexec runasoriginaluser; Description: "Open credentials file"

[Icons]
; for pretty install directory
Name: "{app}\NadekoBot"; Filename: "{app}\{#sysfolder}\NadekoBot.exe"; IconFilename: "{app}\{#sysfolder}\nadeko_icon.ico"
Name: "{app}\credentials"; Filename: "{app}\{#sysfolder}\credentials.json" 
Name: "{app}\data"; Filename: "{app}\{#sysfolder}\data" 
; desktop shortcut 
Name: "{commondesktop}\NadekoBot"; Filename: "{app}\NadekoBot";

[Registry]
;make the app run as administrator
Root: "HKLM"; Subkey: "SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"; \
    ValueType: String; ValueName: "{app}\{#sysfolder}\NadekoBot.exe"; ValueData: "RUNASADMIN"; \
    Flags: uninsdeletekeyifempty uninsdeletevalue;
Root: "HKCU"; Subkey: "SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"; \
    ValueType: String; ValueName: "{app}\{#sysfolder}\NadekoBot.exe"; ValueData: "RUNASADMIN"; \
    Flags: uninsdeletekeyifempty uninsdeletevalue;

;ask the user if they want to delete all settings
[Code]
var
X: string;
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usPostUninstall then
  begin
    X := ExpandConstant('{app}');
    if FileExists(X + '\{#sysfolder}\data\NadekoBot.db') then begin
      if MsgBox('Do you want to delete all settings associated with this bot?', mbConfirmation, MB_YESNO) = IDYES then begin
        DelTree(X + '\{#sysfolder}', True, True, True);
      end
    end else begin
      MsgBox(X + '\{#sysfolder}\data\NadekoBot.db doesn''t exist', mbConfirmation, MB_YESNO)
    end
  end;
end;