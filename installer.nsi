!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "x64.nsh"

; ============================================
; Application & CI-Driven Version Configuration
; ============================================
!define APP_NAME "VoidOne"
!define COMPANY_NAME "VoidOne_app"
!define EXE_NAME "VoidOne.exe"
!define PUBLISHER "VoidOne_app"
!define WEB_SITE "https://github.com/VoidOne-App/VoidOne"
!define FILE_EXT "vone"
!define PROTOCOL_SCHEME "voidone"
!define INSTALL_BIN_DIR "$INSTDIR\bin"
!define APP_EXE_PATH "${INSTALL_BIN_DIR}\${EXE_NAME}"

; CI passes /DVERSION=... . Keep a local fallback for manual builds.
!ifndef VERSION
  !define VERSION "0.0.0-dev"
!endif

Name "${APP_NAME} ${VERSION}"
OutFile "dist\VoidOne-Setup-${VERSION}-x64.exe"

InstallDir "$PROGRAMFILES64\${APP_NAME}"
InstallDirRegKey HKLM "Software\${COMPANY_NAME}\${APP_NAME}" "InstallDir"
RequestExecutionLevel admin

; ============================================
; Modern UI (MUI2) Visuals & Multi-Language
; ============================================
!define MUI_ICON "app-icon.ico"
!define MUI_UNICON "app-icon.ico"
!define MUI_ABORTWARNING

!define MUI_FINISHPAGE_RUN "${APP_EXE_PATH}"
!define MUI_FINISHPAGE_RUN_TEXT "Run ${APP_NAME} Now"
!define MUI_FINISHPAGE_SHOWREADME ""
!define MUI_FINISHPAGE_SHOWREADME_TEXT "Create Desktop Shortcut"
!define MUI_FINISHPAGE_SHOWREADME_FUNCTION CreateDesktopShortcut

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "Farsi"

; ============================================
; Logic & Architecture Checks
; ============================================
Function .onInit
    ${If} ${RunningX64}
        SetRegView 64
    ${Else}
        MessageBox MB_ICONSTOP "This application requires a 64-bit version of Windows 10/11."
        Abort
    ${EndIf}
FunctionEnd

Function un.onInit
    SetRegView 64
FunctionEnd

Function CreateDesktopShortcut
    CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "${APP_EXE_PATH}" "" "${APP_EXE_PATH}" 0
FunctionEnd

; ============================================
; Main Installation Process
; ============================================
Section "MainSection" SEC01
    SetOutPath "$INSTDIR"

    DetailPrint "Checking for running VoidOne instances..."
    nsExec::ExecToLog 'taskkill /F /IM "${EXE_NAME}" /T'
    Sleep 1000

    DetailPrint "Backing up user configurations..."
    CreateDirectory "$PLUGINSDIR\UserDataBackup"
    ${If} ${FileExists} "$APPDATA\VoidOne\config.json"
        CopyFiles "$APPDATA\VoidOne\config.json" "$PLUGINSDIR\UserDataBackup\"
    ${EndIf}

    DetailPrint "Extracting VoidOne core files..."
    File /r "package\*"

    ${If} ${FileExists} "$PLUGINSDIR\UserDataBackup\config.json"
        CreateDirectory "$APPDATA\VoidOne"
        CopyFiles "$PLUGINSDIR\UserDataBackup\config.json" "$APPDATA\VoidOne\"
    ${EndIf}

    ClearErrors
    ReadRegDword $0 HKLM "SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" "Installed"
    ${If} $0 != 1
        ${If} ${FileExists} "$INSTDIR\VC_redist.x64.exe"
            DetailPrint "Installing Visual C++ Redistributable Runtime..."
            nsExec::ExecToLog '"$INSTDIR\VC_redist.x64.exe" /install /quiet /norestart'
            Delete "$INSTDIR\VC_redist.x64.exe"
        ${EndIf}
    ${Else}
        DetailPrint "Visual C++ Runtime already installed. Skipping..."
        ${If} ${FileExists} "$INSTDIR\VC_redist.x64.exe"
            Delete "$INSTDIR\VC_redist.x64.exe"
        ${EndIf}
    ${EndIf}

    DetailPrint "Configuring Windows Firewall rules..."
    nsExec::ExecToLog 'netsh advfirewall firewall add rule name="VoidOne Engine Service" dir=in action=allow program="${APP_EXE_PATH}" enable=yes'

    DetailPrint "Optimizing system preferences for VoidOne Engine..."
    WriteRegStr HKCU "Software\Microsoft\DirectX\UserGpuPreferences" "${APP_EXE_PATH}" "GpuPreference=2;"
    WriteRegDword HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" "GPU Priority" 8

    WriteUninstaller "$INSTDIR\Uninstall.exe"

    CreateDirectory "$SMPROGRAMS\${APP_NAME}"
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "${APP_EXE_PATH}" "" "${APP_EXE_PATH}" 0
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\Uninstall ${APP_NAME}.lnk" "$INSTDIR\Uninstall.exe"

    WriteRegStr HKCR "${PROTOCOL_SCHEME}" "" "URL:${APP_NAME} Protocol"
    WriteRegStr HKCR "${PROTOCOL_SCHEME}" "URL Protocol" ""
    WriteRegStr HKCR "${PROTOCOL_SCHEME}\DefaultIcon" "" "${APP_EXE_PATH},0"
    WriteRegStr HKCR "${PROTOCOL_SCHEME}\shell\open\command" "" '"${APP_EXE_PATH}" "%1"'

    WriteRegStr HKCR ".${FILE_EXT}" "" "${APP_NAME}.ProjectFile"
    WriteRegStr HKCR "${APP_NAME}.ProjectFile" "" "${APP_NAME} Project File"
    WriteRegStr HKCR "${APP_NAME}.ProjectFile\DefaultIcon" "" "${APP_EXE_PATH},0"
    WriteRegStr HKCR "${APP_NAME}.ProjectFile\shell\open\command" "" '"${APP_EXE_PATH}" "%1"'

    WriteRegStr HKCR "Directory\shell\VoidOne" "" "Open with VoidOne"
    WriteRegStr HKCR "Directory\shell\VoidOne" "Icon" "${APP_EXE_PATH},0"
    WriteRegStr HKCR "Directory\shell\VoidOne\command" "" '"${APP_EXE_PATH}" "--game-path=%1"'

    ; Auto-start is opt-in from application settings; installer does not enable it silently.

    !define UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
    WriteRegStr HKLM "${UNINST_KEY}" "DisplayName" "${APP_NAME}"
    WriteRegStr HKLM "${UNINST_KEY}" "DisplayVersion" "${VERSION}"
    WriteRegStr HKLM "${UNINST_KEY}" "Publisher" "${PUBLISHER}"
    WriteRegStr HKLM "${UNINST_KEY}" "URLInfoAbout" "${WEB_SITE}"
    WriteRegStr HKLM "${UNINST_KEY}" "DisplayIcon" "${APP_EXE_PATH},0"
    WriteRegStr HKLM "${UNINST_KEY}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
    WriteRegStr HKLM "${UNINST_KEY}" "InstallLocation" "$INSTDIR"
    WriteRegDword HKLM "${UNINST_KEY}" "NoModify" 1
    WriteRegDword HKLM "${UNINST_KEY}" "NoRepair" 1

    WriteRegStr HKLM "Software\${COMPANY_NAME}\${APP_NAME}" "InstallDir" "$INSTDIR"
    System::Call 'shell32::SHChangeNotify(i 0x08000000, i 0, i 0, i 0)'
SectionEnd

; ============================================
; Completely Clean Uninstaller
; ============================================
Section "Uninstall"
    DetailPrint "Closing running instances..."
    nsExec::ExecToLog 'taskkill /F /IM "${EXE_NAME}" /T'
    Sleep 500

    DetailPrint "Removing Windows Firewall rules..."
    nsExec::ExecToLog 'netsh advfirewall firewall delete rule name="VoidOne Engine Service"'

    Delete "$DESKTOP\${APP_NAME}.lnk"
    RMDir /r "$SMPROGRAMS\${APP_NAME}"

    DeleteRegKey HKCR "${PROTOCOL_SCHEME}"
    DeleteRegKey HKCR ".${FILE_EXT}"
    DeleteRegKey HKCR "${APP_NAME}.ProjectFile"
    DeleteRegKey HKCR "Directory\shell\VoidOne"
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
    DeleteRegKey HKLM "Software\${COMPANY_NAME}\${APP_NAME}"
    DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${APP_NAME}"
    DeleteRegValue HKCU "Software\Microsoft\DirectX\UserGpuPreferences" "${APP_EXE_PATH}"

    RMDir /r "$INSTDIR"
    System::Call 'shell32::SHChangeNotify(i 0x08000000, i 0, i 0, i 0)'
SectionEnd
