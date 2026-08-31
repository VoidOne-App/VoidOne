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
OutFile "dist\VoidOne-Setup-x64.exe"
InstallDir "$PROGRAMFILES64\${APP_NAME}"
InstallDirRegKey HKLM "Software\${COMPANY_NAME}\${APP_NAME}" "InstallDir"
RequestExecutionLevel admin

!define MUI_ICON "app-icon.ico"
!define MUI_UNICON "app-icon.ico"
!define MUI_ABORTWARNING
!define MUI_FINISHPAGE_RUN "${APP_EXE_PATH}"
!define MUI_FINISHPAGE_RUN_TEXT "Run ${APP_NAME} Now"

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
        SetShellVarContext all
    ${Else}
        MessageBox MB_ICONSTOP "This application requires a 64-bit version of Windows 10/11."
        Abort
    ${EndIf}
FunctionEnd

Function un.onInit
    SetRegView 64
    SetShellVarContext all
FunctionEnd

Section "MainSection" SEC01
    SetOutPath "${INSTALL_BIN_DIR}"
    File /r "package\*"

    WriteUninstaller "$INSTDIR\Uninstall.exe"
    CreateDirectory "$SMPROGRAMS\${APP_NAME}"
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "${APP_EXE_PATH}" "" "${APP_EXE_PATH}" 0
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\Uninstall ${APP_NAME}.lnk" "$INSTDIR\Uninstall.exe"
    CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "${APP_EXE_PATH}" "" "${APP_EXE_PATH}" 0

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
SectionEnd

Section "Uninstall"
    Delete "$DESKTOP\${APP_NAME}.lnk"
    RMDir /r "$SMPROGRAMS\${APP_NAME}"
    DeleteRegKey HKCR "${PROTOCOL_SCHEME}"
    DeleteRegKey HKCR ".${FILE_EXT}"
    DeleteRegKey HKCR "${APP_NAME}.ProjectFile"
    DeleteRegKey HKCR "Directory\shell\VoidOne"
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
    DeleteRegKey HKLM "Software\${COMPANY_NAME}\${APP_NAME}"
    RMDir /r "$INSTDIR"
SectionEnd
