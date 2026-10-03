; Super Launcher installer (NSIS 3.x). Build with:
;   dotnet publish SuperLauncher/SuperLauncher.csproj -c Release -r win-x64 --self-contained false -o publish
;   makensis -DBUILD_DIR=../publish SuperLauncherInstaller/SuperLauncher.nsi
; Requires the .NET 9 Desktop Runtime (x64) on the target PC.
!ifndef BUILD_DIR
  !define BUILD_DIR "../SuperLauncher/bin/Release/net9.0-windows/win-x64/publish"
!endif
!define ICON "../SuperLauncherAssets/logo.ico"
!define LICENSE "../LICENSE"
Unicode true
!define APP "Super Launcher"
!define VER "2.1.5.0"
Name "${APP}"
OutFile "SuperLauncher-Setup.exe"
InstallDir "$PROGRAMFILES64\${APP}"
InstallDirRegKey HKLM "Software\${APP}" "InstallDir"
RequestExecutionLevel admin
SetCompressor /SOLID lzma
Icon "${ICON}"
UninstallIcon "${ICON}"
!include "MUI2.nsh"
!define MUI_ICON "${ICON}"
!define MUI_UNICON "${ICON}"
!define MUI_FINISHPAGE_RUN "$INSTDIR\SuperLauncher.exe"
!insertmacro MUI_PAGE_LICENSE "${LICENSE}"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"

Function .onInit
  SetRegView 64
  EnumRegValue $0 HKLM "SOFTWARE\dotnet\Setup\InstalledVersions\x64\sharedfx\Microsoft.WindowsDesktop.App" 0
  StrCpy $1 $0 2
  ${If} $1 != "9."
    ; fallback: scan for any 9.x entry
    StrCpy $2 0
    loop:
      EnumRegValue $0 HKLM "SOFTWARE\dotnet\Setup\InstalledVersions\x64\sharedfx\Microsoft.WindowsDesktop.App" $2
      StrCmp $0 "" missing
      StrCpy $1 $0 2
      StrCmp $1 "9." done
      IntOp $2 $2 + 1
      Goto loop
    missing:
      MessageBox MB_YESNO|MB_ICONEXCLAMATION "The .NET 9 Desktop Runtime (x64) was not found. ${APP} needs it to run.$\n$\nOpen the download page now? (You can still continue installing.)" IDNO done
      ExecShell "open" "https://dotnet.microsoft.com/download/dotnet/9.0"
    done:
  ${EndIf}
FunctionEnd

Section "Install"
  SetRegView 64
  SetOutPath "$INSTDIR"
  File "${BUILD_DIR}/SuperLauncher.exe"
  File "${BUILD_DIR}/SuperLauncher.dll"
  File "${BUILD_DIR}/SuperLauncherCommon.dll"
  File "${BUILD_DIR}/SuperLauncher.deps.json"
  File "${BUILD_DIR}/SuperLauncher.runtimeconfig.json"
  File "${ICON}"
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  CreateDirectory "$SMPROGRAMS\${APP}"
  CreateShortcut "$SMPROGRAMS\${APP}\${APP}.lnk" "$INSTDIR\SuperLauncher.exe"
  CreateShortcut "$SMPROGRAMS\${APP}\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
  WriteRegStr HKLM "Software\${APP}" "InstallDir" "$INSTDIR"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "DisplayName" "${APP}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "DisplayVersion" "${VER}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "DisplayIcon" "$INSTDIR\logo.ico"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "Publisher" "below average"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}" "NoRepair" 1
SectionEnd

Section "Uninstall"
  SetRegView 64
  ExecWait 'taskkill /F /IM SuperLauncher.exe'
  Delete "$INSTDIR\*.*"
  RMDir "$INSTDIR"
  Delete "$SMPROGRAMS\${APP}\*.*"
  RMDir "$SMPROGRAMS\${APP}"
  DeleteRegKey HKLM "Software\${APP}"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP}"
SectionEnd
