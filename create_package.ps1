# Royal Charir - Create Complete Distribution Package
# Uses Inno Setup for professional .exe installer
# Creates: Installer(.exe), Portable folder, Documentation, and ZIP archive

param(
    [string]$Version = "1.0.0"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Royal Charir Package Builder" -ForegroundColor Cyan
Write-Host "  Version: $Version" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Paths
$ProjectRoot = $PSScriptRoot
$BuildDir = Join-Path $ProjectRoot "build\windows\x64\runner\Release"
$DistDir = Join-Path $ProjectRoot "dist"
$PortableDir = Join-Path $DistDir "portable"
$DocsDir = Join-Path $DistDir "dokumentasi"
$FinalPackage = "RoyalCharir_v$Version"
$InnoSetup = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"

# Check build exists
if (-not (Test-Path "$BuildDir\royal_charir_app.exe")) {
    Write-Host "ERROR: Build not found!" -ForegroundColor Red
    Write-Host "Run 'flutter build windows --release' first." -ForegroundColor Yellow
    exit 1
}

# Check Inno Setup
if (-not (Test-Path $InnoSetup)) {
    Write-Host "ERROR: Inno Setup not found at $InnoSetup" -ForegroundColor Red
    exit 1
}

# ===== Step 1: Clean dist =====
Write-Host "`n[1/6] Cleaning distribution directory..." -ForegroundColor Yellow
if (Test-Path $DistDir) {
    Remove-Item $DistDir -Recurse -Force
}
New-Item -ItemType Directory -Path $DistDir -Force | Out-Null
New-Item -ItemType Directory -Path $PortableDir -Force | Out-Null
New-Item -ItemType Directory -Path $DocsDir -Force | Out-Null

# ===== Step 2: Build Inno Setup Installer =====
Write-Host "[2/6] Building Inno Setup Installer (.exe)..." -ForegroundColor Yellow
& $InnoSetup "installer.iss"
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Inno Setup compilation failed!" -ForegroundColor Red
    exit 1
}
Write-Host "  Installer .exe created successfully!" -ForegroundColor Green

# ===== Step 3: Create Portable =====
Write-Host "[3/6] Creating portable version..." -ForegroundColor Yellow
Copy-Item "$BuildDir\*" -Destination $PortableDir -Recurse

$PortableLauncher = @"
@echo off
chcp 65001 >nul
echo Menjalankan Royal Charir (Mode Portable)...
start "" "%~dp0royal_charir_app.exe"
"@
$PortableLauncher | Out-File -FilePath "$PortableDir\Jalankan Royal Charir.bat" -Encoding UTF8

$PortableReadme = @"
=====================================
  ROYAL CHARIR v$Version (PORTABLE)
=====================================

MODE PORTABLE:
- Tidak perlu instalasi
- Bisa dijalankan langsung dari USB
- Data tersimpan di Documents\RoyalCharir

CARA MENJALANKAN:
1. Double-click 'Jalankan Royal Charir.bat'
   atau
2. Double-click 'royal_charir_app.exe'

SYARAT:
- Windows 10/11 64-bit
- Visual C++ Redistributable 2015-2022
  (install dari VC_redist.x64.exe jika belum ada)

=====================================
"@
$PortableReadme | Out-File -FilePath "$PortableDir\README.txt" -Encoding UTF8

# ===== Step 4: Copy Documentation =====
Write-Host "[4/6] Copying documentation..." -ForegroundColor Yellow
$DocsSource = Join-Path $ProjectRoot "installer"
if (Test-Path "$DocsSource\PANDUAN_PENGGUNA.md") {
    Copy-Item "$DocsSource\PANDUAN_PENGGUNA.md" -Destination $DocsDir
}

# ===== Step 5: Create main README =====
Write-Host "[5/6] Creating package README..." -ForegroundColor Yellow
$MainReadme = @"
=============================================
       ROYAL CHARIR v$Version
  Sistem Manajemen Gudang & Penjualan
=============================================

ISI PAKET INI:

  RoyalCharir_Setup_v$Version.exe
      Installer resmi (.exe)
      Sudah termasuk VCRedist
      otomatis terinstall jika belum ada

  portable/
      Versi portable (tanpa install)
      Jalankan langsung dari folder ini

  dokumentasi/
      PANDUAN_PENGGUNA.md
      Panduan lengkap penggunaan aplikasi

=============================================
  CARA INSTALL (DISARANKAN)
=============================================

1. Double-click 'RoyalCharir_Setup_v$Version.exe'
2. Ikuti wizard instalasi
3. Selesai! Shortcut ada di Desktop

Installer secara otomatis akan:
- Menginstall Visual C++ jika belum ada
- Membuat shortcut di Desktop
- Menyiapkan folder data di Documents
- Menjaga data saat update/reinstall

=============================================
  CARA PORTABLE
=============================================

1. Buka folder 'portable'
2. Double-click 'Jalankan Royal Charir.bat'
3. Pastikan VCRedist sudah terinstall

=============================================
  REQUIREMENTS
=============================================

- Windows 10 atau Windows 11 (64-bit)
- Visual C++ Redistributable 2015-2022
  (otomatis terinstall via installer)

=============================================
  LOKASI DATA
=============================================

Data bisnis tersimpan di:
  Documents\RoyalCharir\

Folder ini AMAN dan TIDAK akan terhapus
saat update atau reinstall aplikasi.

=============================================
       (c) 2026 Royal Charir
=============================================
"@
$MainReadme | Out-File -FilePath "$DistDir\BACA INI.txt" -Encoding UTF8

# ===== Step 6: Create ZIP =====
Write-Host "[6/6] Creating ZIP archive..." -ForegroundColor Yellow
$ZipPath = Join-Path $ProjectRoot "$FinalPackage.zip"
if (Test-Path $ZipPath) {
    Remove-Item $ZipPath -Force
}
Compress-Archive -Path "$DistDir\*" -DestinationPath $ZipPath -CompressionLevel Optimal

# ===== Summary =====
$ExeSize = [math]::Round((Get-Item "$DistDir\RoyalCharir_Setup_v$Version.exe").Length / 1MB, 2)
$PortableSize = [math]::Round(((Get-ChildItem $PortableDir -Recurse | Measure-Object -Property Length -Sum).Sum) / 1MB, 2)
$ZipSize = [math]::Round((Get-Item $ZipPath).Length / 1MB, 2)

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  PACKAGE BUILD COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "File yang dihasilkan:" -ForegroundColor White
Write-Host "  Installer EXE  : dist\RoyalCharir_Setup_v$Version.exe  ($ExeSize MB)" -ForegroundColor Gray
Write-Host "  Portable        : dist\portable\  ($PortableSize MB)" -ForegroundColor Gray
Write-Host "  Dokumentasi     : dist\dokumentasi\" -ForegroundColor Gray
Write-Host "  ZIP Package     : $FinalPackage.zip  ($ZipSize MB)" -ForegroundColor Gray
Write-Host ""
Write-Host "Untuk distribusi, kirimkan:" -ForegroundColor Yellow
Write-Host "  1. $FinalPackage.zip (paket lengkap)" -ForegroundColor White
Write-Host "  atau" -ForegroundColor DarkGray
Write-Host "  2. dist\RoyalCharir_Setup_v$Version.exe (installer saja)" -ForegroundColor White
Write-Host ""
