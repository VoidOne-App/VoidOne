!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "x64.nsh"

!define APP_NAME "VoidOne"
!define COMPANY_NAME "VoidOne_app"
!define EXE_NAME "VoidOne.exe"
!define PUBLISHER "VoidOne_app"
!define WEB_SITE "https://github.com/VoidOne-App/VoidOne"
!define FILE_EXT "vone"
!define PROTOCOL_SCHEME "voidone"
!define INSTALL_BIN_DIR "$INSTDIR\bin"
!define APP_EXE_PATH "${INSTALL_BIN_DIR}\${EXE_NAME}"

!ifndef VERSION
  !define VERSION "0.0.0-dev"
!endif

Name "${APP_NAME} ${VERSION}"
OutFile "dist\VoidOne-Setup-${VERSION}-x64.exe"
InstallDir "$PROGRAMFILES64\${APP_NAME}"
InstallDirRegKey HKLM "Software\${COMPANY_NAME}\${APP_NAME}" "InstallDir"
RequestExecutionLevel admin

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

Section "MainSection" SEC01
    SetOutPath "$INSTDIR"

    ; Ask the existing process to exit without /F so user data is not
    ; force-terminated while it may still be writing to SQLite/save files.
    DetailPrint "Requesting VoidOne to close..."
    nsExec::ExecToLog 'taskkill /IM "${EXE_NAME}" /T'
    Sleep 1000

    DetailPrint "Backing up user configuration..."
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
            Pop $1
            ${If} $1 != 0
                DetailPrint "VC++ Redistributable installer returned exit code $1."
            ${EndIf}
            Delete "$INSTDIR\VC_redist.x64.exe"
        ${EndIf}
    ${Else}
        DetailPrint "Visual C++ Runtime already installed."
        ${If} ${FileExists} "$INSTDIR\VC_redist.x64.exe"
            Delete "$INSTDIR\VC_redist.x64.exe"
        ${EndIf}
    ${EndIf}

    ; VoidOne does not require inbound network access. Do not silently add
    ; a machine-wide Windows Firewall exception from the installer.
    ; Application networking remains governed by normal Windows policy.

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

Section "Uninstall"
    DetailPrint "Requesting VoidOne to close..."
    nsExec::ExecToLog 'taskkill /IM "${EXE_NAME}" /T'
    Sleep 500

    ; No firewall rule is created by current installers, so there is no
    ; machine-wide firewall state to remove here.
    Delete "$DESKTOP\${APP_NAME}.lnk"
    RMDir /r "$SMPROGRAMS\${APP_NAME}"
    DeleteRegKey HKCR "${PROTOCOL_SCHEME}"
    DeleteRegKey HKCR ".${FILE_EXT}"
    DeleteRegKey HKCR "${APP_NAME}.ProjectFile"
    DeleteRegKey HKCR "Directory\shell\VoidOne"
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
    DeleteRegKey HKLM "Software\${COMPANY_NAME}\${APP_NAME}"
    DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${APP_NAME}"
    RMDir /r "$INSTDIR"
    System::Call 'shell32::SHChangeNotify(i 0x08000000, i 0, i 0, i 0)'
SectionEnd
