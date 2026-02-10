; =============================================
; Royal Charir Installer Script
; Inno Setup 6 - Professional Installer
; =============================================
; Includes:
;   - Application files
;   - VCRedist auto-install if missing
;   - Data persistence on update
;   - Desktop & Start Menu shortcuts
; =============================================

#define MyAppName "Royal Charir"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Royal Charir"
#define MyAppURL "https://royalcharir.com"
#define MyAppExeName "royal_charir_app.exe"
#define MyAppDescription "Sistem Manajemen Gudang & Penjualan"

[Setup]
; Unique App ID - JANGAN diubah antar versi agar update berjalan benar
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} v{#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
AppCopyright=Copyright (C) 2026 {#MyAppPublisher}
VersionInfoVersion={#MyAppVersion}
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription={#MyAppDescription}

; Direktori instalasi
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
DisableProgramGroupPage=yes

; Output installer
OutputDir=dist
OutputBaseFilename=RoyalCharir_Setup_v{#MyAppVersion}
SetupIconFile=windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName}

; Kompresi maksimal
Compression=lzma2/ultra64
SolidCompression=yes
LZMANumBlockThreads=4
LZMAUseSeparateProcess=yes

; Hak akses - user biasa bisa install, tapi admin juga bisa
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog

; UI Modern
WizardStyle=modern
WizardSizePercent=110

; Info tambahan
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

; Update behavior
UsePreviousAppDir=yes
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Types]
Name: "full"; Description: "Instalasi Lengkap (disarankan)"
Name: "compact"; Description: "Instalasi Minimal"
Name: "custom"; Description: "Kustom"; Flags: iscustom

[Components]
Name: "main"; Description: "Aplikasi Royal Charir"; Types: full compact custom; Flags: fixed
Name: "vcredist"; Description: "Visual C++ Redistributable 2015-2022 (diperlukan)"; Types: full
Name: "docs"; Description: "Dokumentasi dan Panduan Pengguna"; Types: full

[Tasks]
Name: "desktopicon"; Description: "Buat ikon di &Desktop"; GroupDescription: "Ikon Tambahan:"
Name: "startmenuicon"; Description: "Buat ikon di menu &Start"; GroupDescription: "Ikon Tambahan:"; Flags: unchecked

[Files]
; ===== Aplikasi Utama =====
Source: "build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion; Components: main
Source: "build\windows\x64\runner\Release\*.dll"; DestDir: "{app}"; Flags: ignoreversion; Components: main
Source: "build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: main

; ===== Visual C++ Redistributable =====
Source: "VC_redist.x64.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall; Components: vcredist

; ===== Dokumentasi =====
Source: "installer\PANDUAN_PENGGUNA.md"; DestDir: "{app}\docs"; Flags: ignoreversion; Components: docs

[Icons]
; Desktop shortcut
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; Comment: "{#MyAppDescription}"
; Start Menu shortcuts
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Comment: "{#MyAppDescription}"; Tasks: startmenuicon
Name: "{group}\Panduan Pengguna"; Filename: "{app}\docs\PANDUAN_PENGGUNA.md"; Tasks: startmenuicon; Components: docs
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"; Tasks: startmenuicon

[Run]
; Install VCRedist secara silent jika dipilih dan dibutuhkan
Filename: "{tmp}\VC_redist.x64.exe"; Parameters: "/install /quiet /norestart"; StatusMsg: "Menginstall Visual C++ Redistributable..."; Flags: waituntilterminated; Components: vcredist; Check: VCRedistNeedsInstall

; Jalankan aplikasi setelah install
Filename: "{app}\{#MyAppExeName}"; Description: "Jalankan {#MyAppName} sekarang"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; Hapus folder data aplikasi (bukan data user)
Type: filesandordirs; Name: "{app}\data"
Type: filesandordirs; Name: "{app}\docs"

[Messages]
BeveledLabel=Royal Charir v{#MyAppVersion}
WelcomeLabel1=Selamat Datang di Installer%n{#MyAppName}
WelcomeLabel2=Installer ini akan menginstall {#MyAppName} v{#MyAppVersion} di komputer Anda.%n%n{#MyAppDescription}%n%nDATA AMAN: Data bisnis Anda tersimpan di folder Documents dan tidak akan terhapus saat update atau reinstall.%n%nDisarankan untuk menutup semua aplikasi lain sebelum melanjutkan.
FinishedHeadingLabel=Instalasi {#MyAppName} Selesai!
FinishedLabel=Installer telah selesai menginstall {#MyAppName} di komputer Anda.%n%nData bisnis tersimpan di:%nDocuments\RoyalCharir%n%nFolder ini AMAN dari update dan reinstall.%n%nBuka Panduan Pengguna di folder instalasi untuk petunjuk lengkap.
SelectDirLabel3=Setup akan menginstall {#MyAppName} ke folder berikut.
SelectComponentsLabel2=Pilih komponen yang ingin diinstall. Klik Lanjut untuk melanjutkan.
SelectTasksLabel2=Pilih tugas tambahan yang ingin dilakukan oleh Setup. Klik Lanjut untuk melanjutkan.
ReadyLabel1=Setup siap mulai menginstall {#MyAppName} di komputer Anda.
ReadyLabel2a=Klik Install untuk melanjutkan instalasi, atau klik Kembali untuk meninjau atau mengubah pengaturan.
StatusInstalling=Menginstall {#MyAppName}...
ExitSetupTitle=Keluar dari Setup
ExitSetupMessage=Instalasi belum selesai. Jika Anda keluar sekarang, program tidak akan terinstall.%n%nYakin ingin keluar?

[Code]
// =============================================
// Cek apakah VCRedist sudah terinstall
// =============================================
function VCRedistNeedsInstall: Boolean;
var
  Version: String;
begin
  // Default: perlu install
  Result := True;

  // Cek VCRedist 2015-2022 x64 di registry
  if RegQueryStringValue(HKEY_LOCAL_MACHINE,
    'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64',
    'Version', Version) then
  begin
    Log('VCRedist sudah terinstall: ' + Version);
    Result := False;
  end;

  // Cek juga path alternatif
  if Result then
  begin
    if RegQueryStringValue(HKEY_LOCAL_MACHINE,
      'SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x64',
      'Version', Version) then
    begin
      Log('VCRedist sudah terinstall (WOW64): ' + Version);
      Result := False;
    end;
  end;

  if Result then
    Log('VCRedist BELUM terinstall - akan diinstall otomatis');
end;

// =============================================
// Cek apakah ini update atau instalasi baru
// =============================================
function IsUpgrade: Boolean;
begin
  Result := RegKeyExists(HKEY_CURRENT_USER,
    'Software\Microsoft\Windows\CurrentVersion\Uninstall\{#SetupSetting("AppId")}_is1') or
    RegKeyExists(HKEY_LOCAL_MACHINE,
    'Software\Microsoft\Windows\CurrentVersion\Uninstall\{#SetupSetting("AppId")}_is1');
end;

// =============================================
// Event: Inisialisasi wizard
// =============================================
procedure InitializeWizard();
var
  DataPath: String;
  BackupPath: String;
begin
  // Buat folder data user jika belum ada
  DataPath := ExpandConstant('{userdocs}\RoyalCharir');
  BackupPath := DataPath + '\Backups';

  if not DirExists(DataPath) then
  begin
    CreateDir(DataPath);
    Log('Membuat folder data: ' + DataPath);
  end;

  if not DirExists(BackupPath) then
  begin
    CreateDir(BackupPath);
    Log('Membuat folder backup: ' + BackupPath);
  end;
end;

// =============================================
// Event: Perubahan halaman wizard
// =============================================
procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpWelcome then
  begin
    if IsUpgrade() then
    begin
      WizardForm.WelcomeLabel1.Caption := 'Update ' + '{#MyAppName}';
      WizardForm.WelcomeLabel2.Caption :=
        'Installer ini akan memperbarui {#MyAppName} ke versi {#MyAppVersion}.' + #13#10 + #13#10 +
        'DATA BISNIS ANDA AMAN!' + #13#10 +
        'Semua data produk, pelanggan, pesanan, dan laporan akan tetap tersimpan di folder Documents.' + #13#10 + #13#10 +
        'Klik Lanjut untuk melanjutkan update.';
    end;
  end;
end;

// =============================================
// Event: Setelah instalasi selesai
// =============================================
procedure CurStepChanged(CurStep: TSetupStep);
var
  DataPath: String;
  InfoFile: String;
begin
  if CurStep = ssPostInstall then
  begin
    // Buat file info di folder data
    DataPath := ExpandConstant('{userdocs}\RoyalCharir');
    InfoFile := DataPath + '\INFO.txt';

    if not FileExists(InfoFile) then
    begin
      SaveStringToFile(InfoFile,
        '==============================================' + #13#10 +
        '  ROYAL CHARIR - Data Folder' + #13#10 +
        '==============================================' + #13#10 +
        '' + #13#10 +
        'Folder ini berisi data bisnis Anda:' + #13#10 +
        '  - Database (royal_charir_v3.db)' + #13#10 +
        '  - File backup' + #13#10 +
        '' + #13#10 +
        'JANGAN hapus folder ini!' + #13#10 +
        'Data Anda akan aman meskipun aplikasi' + #13#10 +
        'di-update atau di-reinstall.' + #13#10 +
        '' + #13#10 +
        '==============================================' + #13#10,
        False);
    end;

    Log('Instalasi selesai - Data disimpan di: ' + DataPath);
  end;
end;

// =============================================
// Event: Konfirmasi sebelum uninstall
// =============================================
function InitializeUninstall(): Boolean;
begin
  Result := MsgBox(
    'Apakah Anda yakin ingin menghapus {#MyAppName}?' + #13#10 + #13#10 +
    'DATA BISNIS ANDA TETAP AMAN!' + #13#10 +
    'Data di folder Documents\RoyalCharir tidak akan dihapus.',
    mbConfirmation, MB_YESNO) = IDYES;
end;
