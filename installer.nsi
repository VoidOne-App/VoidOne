!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "x64.nsh"
!include "WinVer.nsh"
!include "FileFunc.nsh"
!include "Sections.nsh"

; -----------------------------------------------------------------------------
; Application identity
; -----------------------------------------------------------------------------
!define APP_NAME "VoidOne"
!define COMPANY_NAME "VoidOne"
!define EXE_NAME "VoidOne.exe"
!define PUBLISHER "VoidOne"
!define WEB_SITE "https://github.com/VoidOne-App/VoidOne"
!define FILE_EXT "vone"
!define PROTOCOL_SCHEME "voidone"
!define INSTALL_BIN_DIR "$INSTDIR\bin"
!define APP_EXE_PATH "${INSTALL_BIN_DIR}\${EXE_NAME}"
!define START_MENU_DIR "$SMPROGRAMS\${APP_NAME}"
!define UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"

; VERSION is supplied by CI from the Git tag. WINDOWS_VERSION is the numeric
; PE version derived from that same tag for Windows version-resource rules.
!ifndef VERSION
  !define VERSION "0.0.0-dev"
!endif
!ifndef WINDOWS_VERSION
  !define WINDOWS_VERSION "0.0.0.0"
!endif

; -----------------------------------------------------------------------------
; Installer identity / Windows metadata
; -----------------------------------------------------------------------------
Name "${APP_NAME} ${VERSION}"
Caption "${APP_NAME} ${VERSION} Setup"
OutFile "dist\VoidOne-Setup-x64.exe"
InstallDir "$PROGRAMFILES64\${APP_NAME}"
InstallDirRegKey HKLM "Software\${COMPANY_NAME}\${APP_NAME}" "InstallDir"
RequestExecutionLevel admin
Unicode True
ManifestSupportedOS win10

VIProductVersion "${WINDOWS_VERSION}"
VIAddVersionKey "ProductName" "${APP_NAME}"
VIAddVersionKey "CompanyName" "${PUBLISHER}"
VIAddVersionKey "FileDescription" "${APP_NAME} Windows Installer"
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey "ProductVersion" "${VERSION}"
VIAddVersionKey "LegalCopyright" "Copyright (c) 2026 ${PUBLISHER}"
VIAddVersionKey "OriginalFilename" "VoidOne-Setup-x64.exe"

; -----------------------------------------------------------------------------
; Modern UI / UX
; -----------------------------------------------------------------------------
!define MUI_ICON "app-icon.ico"
!define MUI_UNICON "app-icon.ico"
!define MUI_ABORTWARNING
!define MUI_COMPONENTSPAGE_SMALLDESC
!define MUI_COMPONENTSPAGE_TEXT_TOP "Choose the VoidOne shortcuts you want. The application itself is always installed."
!define MUI_COMPONENTSPAGE_TEXT_DESCRIPTION_TITLE "Installation options"
!define MUI_COMPONENTSPAGE_TEXT_DESCRIPTION_INFO "Select an option to see what it does."

!define MUI_WELCOMEPAGE_TITLE "Welcome to VoidOne"
!define MUI_WELCOMEPAGE_TEXT "Install VoidOne ${VERSION} on your Windows PC.\r\n\r\nA native, open-source PC gaming platform built around your games — not around a store.\r\n\r\nThe installer will check your system, preserve an existing installation path when upgrading, and give you control over optional shortcuts."

!define MUI_DIRECTORYPAGE_TEXT_TOP "Choose where VoidOne should be installed. Your existing VoidOne installation directory will be reused automatically when possible."
!define MUI_DIRECTORYPAGE_TEXT_DESTINATION "Installation folder"

!define MUI_INSTFILESPAGE_HEADER "Installing VoidOne"
!define MUI_INSTFILESPAGE_TEXT "Please wait while VoidOne is installed. The installer will register VoidOne with Windows and configure its shortcuts and file integrations."

!define MUI_FINISHPAGE_TITLE "VoidOne is ready"
!define MUI_FINISHPAGE_TEXT "VoidOne ${VERSION} has been installed successfully.\r\n\r\nLaunch VoidOne now, or close this installer and start it later from the Start Menu."
!define MUI_FINISHPAGE_RUN "${APP_EXE_PATH}"
!define MUI_FINISHPAGE_RUN_TEXT "Launch VoidOne"
!define MUI_FINISHPAGE_LINK "Visit the VoidOne project on GitHub"
!define MUI_FINISHPAGE_LINK_LOCATION "${WEB_SITE}"

!define MUI_UNCONFIRMPAGE_TEXT_TOP "VoidOne will be removed from this computer. Personal library data stored outside the installation directory is not intentionally removed."
!define MUI_UNCONFIRMPAGE_TEXT_CHECKBOX "Remove VoidOne and its Windows integrations"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "Farsi"

; -----------------------------------------------------------------------------
; Installation components
; -----------------------------------------------------------------------------
Section "VoidOne" SEC_MAIN
    SectionIn RO

    SetOutPath "${INSTALL_BIN_DIR}"
    SetOverwrite on
    File /r "package\*"

    ; Create the uninstaller before registering it with Windows.
    WriteUninstaller "$INSTDIR\Uninstall.exe"

    ; Windows Apps & Features metadata.
    WriteRegStr HKLM "${UNINST_KEY}" "DisplayName" "${APP_NAME}"
    WriteRegStr HKLM "${UNINST_KEY}" "DisplayVersion" "${VERSION}"
    WriteRegStr HKLM "${UNINST_KEY}" "Publisher" "${PUBLISHER}"
    WriteRegStr HKLM "${UNINST_KEY}" "URLInfoAbout" "${WEB_SITE}"
    WriteRegStr HKLM "${UNINST_KEY}" "DisplayIcon" "${APP_EXE_PATH},0"
    WriteRegStr HKLM "${UNINST_KEY}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
    WriteRegStr HKLM "${UNINST_KEY}" "QuietUninstallString" '"$INSTDIR\Uninstall.exe" /S'
    WriteRegStr HKLM "${UNINST_KEY}" "InstallLocation" "$INSTDIR"
    WriteRegStr HKLM "${UNINST_KEY}" "InstallSource" "$EXEDIR"
    WriteRegStr HKLM "${UNINST_KEY}" "HelpLink" "${WEB_SITE}/issues"
    WriteRegDword HKLM "${UNINST_KEY}" "NoModify" 1
    WriteRegDword HKLM "${UNINST_KEY}" "NoRepair" 1
    ${GetSize} "$INSTDIR" "/S=0K" $2 $3 $4
    WriteRegDWORD HKLM "${UNINST_KEY}" "EstimatedSize" $2
    WriteRegStr HKLM "${UNINST_KEY}" "InstallDate" "${__DATE__}"
    WriteRegStr HKLM "Software\${COMPANY_NAME}\${APP_NAME}" "InstallDir" "$INSTDIR"

    ; URL protocol: voidone://...
    WriteRegStr HKCR "${PROTOCOL_SCHEME}" "" "URL:${APP_NAME} Protocol"
    WriteRegStr HKCR "${PROTOCOL_SCHEME}" "URL Protocol" ""
    WriteRegStr HKCR "${PROTOCOL_SCHEME}\DefaultIcon" "" "${APP_EXE_PATH},0"
    WriteRegStr HKCR "${PROTOCOL_SCHEME}\shell\open\command" "" '"${APP_EXE_PATH}" "%1"'

    ; VoidOne project files: .vone
    WriteRegStr HKCR ".${FILE_EXT}" "" "${APP_NAME}.ProjectFile"
    WriteRegStr HKCR "${APP_NAME}.ProjectFile" "" "${APP_NAME} Project File"
    WriteRegStr HKCR "${APP_NAME}.ProjectFile\DefaultIcon" "" "${APP_EXE_PATH},0"
    WriteRegStr HKCR "${APP_NAME}.ProjectFile\shell\open\command" "" '"${APP_EXE_PATH}" "%1"'

    ; Explorer context menu for game directories.
    WriteRegStr HKCR "Directory\shell\VoidOne" "" "Open with VoidOne"
    WriteRegStr HKCR "Directory\shell\VoidOne" "Icon" "${APP_EXE_PATH},0"
    WriteRegStr HKCR "Directory\shell\VoidOne\command" "" '"${APP_EXE_PATH}" "--game-path=%1"'
SectionEnd

Section "Start Menu shortcut" SEC_STARTMENU
    CreateDirectory "${START_MENU_DIR}"
    CreateShortCut "${START_MENU_DIR}\${APP_NAME}.lnk" "${APP_EXE_PATH}" "" "${APP_EXE_PATH}" 0
    CreateShortCut "${START_MENU_DIR}\Uninstall ${APP_NAME}.lnk" "$INSTDIR\Uninstall.exe"
SectionEnd

Section /o "Desktop shortcut" SEC_DESKTOP
    CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "${APP_EXE_PATH}" "" "${APP_EXE_PATH}" 0
SectionEnd

; -----------------------------------------------------------------------------
; Initialization / upgrade handling
; -----------------------------------------------------------------------------
Function .onInit
    ${IfNot} ${RunningX64}
        MessageBox MB_ICONSTOP|MB_OK "VoidOne requires a 64-bit version of Windows 10 or Windows 11."
        Abort
    ${EndIf}

    ${IfNot} ${AtLeastWin10}
        MessageBox MB_ICONSTOP|MB_OK "VoidOne requires Windows 10 or later."
        Abort
    ${EndIf}

    SetRegView 64
    SetShellVarContext all

    ; Preserve the user's existing installation location during upgrades.
    ReadRegStr $0 HKLM "${UNINST_KEY}" "InstallLocation"
    ${If} $0 != ""
        StrCpy $INSTDIR $0
    ${EndIf}

    ; Avoid replacing a running executable or locked Qt files.
    FindWindow $1 "" "${APP_NAME}"
    ${If} $1 != 0
        MessageBox MB_ICONEXCLAMATION|MB_OKCANCEL "VoidOne is currently running.\r\n\r\nPlease close VoidOne before continuing the installation." IDOK continue IDABORT cancel
        Abort
        continue:
    ${EndIf}

    cancel:
FunctionEnd

Function un.onInit
    SetRegView 64
    SetShellVarContext all
FunctionEnd

Function un.onUninstSuccess
    HideWindow
    MessageBox MB_ICONINFORMATION|MB_OK "VoidOne has been removed successfully."
FunctionEnd

; -----------------------------------------------------------------------------
; Uninstall
; -----------------------------------------------------------------------------
Section "Uninstall"
    ShowUninstDetails show

    ; Remove shortcuts and Windows integrations first.
    Delete "$DESKTOP\${APP_NAME}.lnk"
    RMDir /r "${START_MENU_DIR}"

    DeleteRegKey HKCR "${PROTOCOL_SCHEME}"
    DeleteRegKey HKCR ".${FILE_EXT}"
    DeleteRegKey HKCR "${APP_NAME}.ProjectFile"
    DeleteRegKey HKCR "Directory\shell\VoidOne"
    DeleteRegKey HKLM "${UNINST_KEY}"
    DeleteRegKey HKLM "Software\${COMPANY_NAME}\${APP_NAME}"

    ; The installation directory is owned by the installer.
    RMDir /r "$INSTDIR"
SectionEnd

; -----------------------------------------------------------------------------
; Installer descriptions / localization
; -----------------------------------------------------------------------------
LangString DESC_SEC_MAIN ${LANG_ENGLISH} "Required VoidOne application files and runtime dependencies."
LangString DESC_SEC_STARTMENU ${LANG_ENGLISH} "Create a Start Menu folder with launch and uninstall shortcuts."
LangString DESC_SEC_DESKTOP ${LANG_ENGLISH} "Create a shortcut to VoidOne on the desktop."

LangString DESC_SEC_MAIN ${LANG_FARSI} "فایل‌های اصلی VoidOne و وابستگی‌های موردنیاز."
LangString DESC_SEC_STARTMENU ${LANG_FARSI} "ساخت پوشه‌ای در منوی Start برای اجرای VoidOne و حذف نصب."
LangString DESC_SEC_DESKTOP ${LANG_FARSI} "ساخت میانبر VoidOne روی دسکتاپ."

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_MAIN} $(DESC_SEC_MAIN)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_STARTMENU} $(DESC_SEC_STARTMENU)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_DESKTOP} $(DESC_SEC_DESKTOP)
!insertmacro MUI_FUNCTION_DESCRIPTION_END
