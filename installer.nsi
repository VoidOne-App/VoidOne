!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "x64.nsh"

; ============================================
; Application & Company Configuration
; ============================================
!define APP_NAME "VoidOne"
!define COMPANY_NAME "VoidOne_app"
!define EXE_NAME "VoidOne.exe"
!define PUBLISHER "VoidOne_app"
!define WEB_SITE "https://github.com/VoidOne-App/NeonLauncher-Qt"
!define FILE_EXT "vone"
!define PROTOCOL_SCHEME "voidone"

!ifndef VERSION
  !define VERSION "0.1.0"
!endif

Name "${APP_NAME} ${VERSION}"
OutFile "dist\VoidOne-Setup-x64.exe"

InstallDir "$PROGRAMFILES64\${APP_NAME}"
InstallDirRegKey HKLM "Software\${COMPANY_NAME}\${APP_NAME}" "InstallDir"
RequestExecutionLevel admin

; ============================================
; Modern UI (MUI2) Visuals & Multi-Language
; ============================================
!define MUI_ICON "app-icon.ico"
!define MUI_UNICON "app-icon.ico"
!define MUI_ABORTWARNING

; Finish Page Settings
!define MUI_FINISHPAGE_RUN "$INSTDIR\${EXE_NAME}"
!define MUI_FINISHPAGE_RUN_TEXT "Run ${APP_NAME} Now"
!define MUI_FINISHPAGE_SHOWREADME ""
!define MUI_FINISHPAGE_SHOWREADME_TEXT "Create Desktop Shortcut"
!define MUI_FINISHPAGE_SHOWREADME_FUNCTION CreateDesktopShortcut

; Installer Pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Uninstaller Pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Languages (English & Farsi Support)
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
    CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${EXE_NAME}" "" "$INSTDIR\${EXE_NAME}" 0
FunctionEnd

; ============================================
; Main Installation Process
; ============================================
Section "MainSection" SEC01
    SetOutPath "$INSTDIR"

    ; 1. Soft-Close Running Instances
    DetailPrint "Checking for running VoidOne instances..."
    nsExec::Exec 'taskkill /IM "${EXE_NAME}" /T'
    Sleep 1000

    ; 2. Smart Backup of User Settings (AppData)
    DetailPrint "Backing up user configurations..."
    CreateDirectory "$PLUGINSDIR\UserDataBackup"
    ${If} ${FileExists} "$APPDATA\VoidOne\config.json"
        CopyFiles "$APPDATA\VoidOne\config.json" "$PLUGINSDIR\UserDataBackup\"
    ${EndIf}

    ; 3. Extract Payload Files
    DetailPrint "Extracting VoidOne core files..."
    File /r "package\*"

    ; 4. Restore User Settings
    ${If} ${FileExists} "$PLUGINSDIR\UserDataBackup\config.json"
        CreateDirectory "$APPDATA\VoidOne"
        CopyFiles "$PLUGINSDIR\UserDataBackup\config.json" "$APPDATA\VoidOne\"
    ${EndIf}

    ; 5. VC++ Redistributable Silent Setup
    ${If} ${FileExists} "$INSTDIR\VC_redist.x64.exe"
        DetailPrint "Installing Microsoft Visual C++ Redistributable (Silent)..."
        nsExec::ExecToLog '"$INSTDIR\VC_redist.x64.exe" /install /quiet /norestart'
        Delete "$INSTDIR\VC_redist.x64.exe"
    ${EndIf}

    ; 6. Create Uninstaller Executable
    WriteUninstaller "$INSTDIR\Uninstall.exe"

    ; 7. Create Start Menu Shortcuts
    CreateDirectory "$SMPROGRAMS\${APP_NAME}"
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "$INSTDIR\${EXE_NAME}" "" "$INSTDIR\${EXE_NAME}" 0
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\Uninstall ${APP_NAME}.lnk" "$INSTDIR\Uninstall.exe"

    ; 8. Register Custom URI Protocol (voidone://)
    WriteRegStr HKCR "${PROTOCOL_SCHEME}" "" "URL:${APP_NAME} Protocol"
    WriteRegStr HKCR "${PROTOCOL_SCHEME}" "URL Protocol" ""
    WriteRegStr HKCR "${PROTOCOL_SCHEME}\DefaultIcon" "" "$INSTDIR\${EXE_NAME},0"
    WriteRegStr HKCR "${PROTOCOL_SCHEME}\shell\open\command" "" '"$INSTDIR\${EXE_NAME}" "%1"'

    ; 9. Register Custom File Extension (.vone)
    WriteRegStr HKCR ".${FILE_EXT}" "" "${APP_NAME}.ProjectFile"
    WriteRegStr HKCR "${APP_NAME}.ProjectFile" "" "${APP_NAME} Project File"
    WriteRegStr HKCR "${APP_NAME}.ProjectFile\DefaultIcon" "" "$INSTDIR\${EXE_NAME},0"
    WriteRegStr HKCR "${APP_NAME}.ProjectFile\shell\open\command" "" '"$INSTDIR\${EXE_NAME}" "%1"'

    ; 10. Register in Windows Add/Remove Programs (Control Panel)
    !define UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
    WriteRegStr HKLM "${UNINST_KEY}" "DisplayName" "${APP_NAME}"
    WriteRegStr HKLM "${UNINST_KEY}" "DisplayVersion" "${VERSION}"
    WriteRegStr HKLM "${UNINST_KEY}" "Publisher" "${PUBLISHER}"
    WriteRegStr HKLM "${UNINST_KEY}" "URLInfoAbout" "${WEB_SITE}"
    WriteRegStr HKLM "${UNINST_KEY}" "DisplayIcon" "$INSTDIR\${EXE_NAME},0"
    WriteRegStr HKLM "${UNINST_KEY}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
    WriteRegStr HKLM "${UNINST_KEY}" "InstallLocation" "$INSTDIR"
    WriteRegDword HKLM "${UNINST_KEY}" "NoModify" 1
    WriteRegDword HKLM "${UNINST_KEY}" "NoRepair" 1

    WriteRegStr HKLM "Software\${COMPANY_NAME}\${APP_NAME}" "InstallDir" "$INSTDIR"

    ; Refresh Windows Explorer Shell Icons
    System::Call 'shell32::SHChangeNotify(i 0x08000000, i 0, i 0, i 0)'
SectionEnd

; ============================================
; Completely Clean Uninstaller
; ============================================
Section "Uninstall"
    DetailPrint "Closing running instances..."
    nsExec::Exec 'taskkill /F /IM "${EXE_NAME}" /T'
    Sleep 500

    ; Delete Shortcuts
    Delete "$DESKTOP\${APP_NAME}.lnk"
    RMDir /r "$SMPROGRAMS\${APP_NAME}"

    ; Clean Registry Entries
    DeleteRegKey HKCR "${PROTOCOL_SCHEME}"
    DeleteRegKey HKCR ".${FILE_EXT}"
    DeleteRegKey HKCR "${APP_NAME}.ProjectFile"
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
    DeleteRegKey HKLM "Software\${COMPANY_NAME}\${APP_NAME}"
    DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${APP_NAME}"

    ; Remove Application Files
    RMDir /r "$INSTDIR"

    ; Refresh Icons
    System::Call 'shell32::SHChangeNotify(i 0x08000000, i 0, i 0, i 0)'
SectionEnd
