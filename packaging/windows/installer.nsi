; ============================================================================
; VoidOne Windows Installer
; Professional NSIS / Modern UI 2 build
; ============================================================================

!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "nsDialogs.nsh"
!include "x64.nsh"
!include "WinVer.nsh"
!include "FileFunc.nsh"
!include "Sections.nsh"

; Resolve all repository-relative inputs from this script's location.
!define PROJECT_ROOT "${__FILEDIR__}\..\.."
!define PACKAGE_DIR "${PROJECT_ROOT}\package"
!define DIST_DIR "${PROJECT_ROOT}\dist"
!define APP_ICON_PATH "${PROJECT_ROOT}\assets\app-icon.ico"
!define LICENSE_PATH "${PROJECT_ROOT}\LICENSE"

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
!define APP_REG_KEY "Software\${COMPANY_NAME}\${APP_NAME}"
!define INSTALLER_MUTEX_NAME "Global\VoidOneInstaller-{7B8A4C2F-2D57-4E6B-9B4B-VOIDONE2026}"
!define VC_REDIST_URL "https://aka.ms/vc14/vc_redist.x64.exe"
!define VC_REDIST_FILE "$PLUGINSDIR\vc_redist.x64.exe"

; The official Microsoft VC++ Redistributable is embedded into the installer
; at build time. A caller may provide /DVC_REDIST_SOURCE=<path> to reuse a
; pre-downloaded copy; otherwise NSIS fetches the latest Microsoft package into
; a temporary compiler file and embeds it in the generated installer.
!ifndef VC_REDIST_SOURCE
  !tempfile VC_REDIST_SOURCE
  !system '"%WINDIR%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$ErrorActionPreference=''Stop''; Invoke-WebRequest -UseBasicParsing -Uri ''${VC_REDIST_URL}'' -OutFile ''${VC_REDIST_SOURCE}''"' = 0
  !define VC_REDIST_SOURCE_TEMP
!endif
!if /FileExists "${VC_REDIST_SOURCE}"
!else
  !error "VC++ Redistributable source is missing. Set VC_REDIST_SOURCE or allow the build to download the official Microsoft package."
!endif

!ifndef NSIS_PTR_SIZE & SYSTYPE_PTR
  !define SYSTYPE_PTR i
!else
  !define /ifndef SYSTYPE_PTR p
!endif

!ifndef VERSION
  !define VERSION "0.0.0-dev"
!endif
!ifndef WINDOWS_VERSION
  !define WINDOWS_VERSION "0.0.0.0"
!endif

Name "${APP_NAME} ${VERSION}"
Caption "${APP_NAME} ${VERSION} Setup"
OutFile "${DIST_DIR}\VoidOne-Setup-x64.exe"
InstallDir "$PROGRAMFILES64\${APP_NAME}"
InstallDirRegKey HKLM "${APP_REG_KEY}" "InstallDir"
RequestExecutionLevel admin
Unicode True
ManifestSupportedOS Win10
BrandingText "VoidOne • Open Source PC Gaming Platform"
ShowInstDetails show
ShowUninstDetails show
CRCCheck force
SetDatablockOptimize on
SetCompressor /SOLID lzma
SetCompressorDictSize 32
SetDateSave on

VIProductVersion "${WINDOWS_VERSION}"
VIAddVersionKey "ProductName" "${APP_NAME}"
VIAddVersionKey "CompanyName" "${PUBLISHER}"
VIAddVersionKey "FileDescription" "${APP_NAME} Windows Installer"
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey "ProductVersion" "${VERSION}"
VIAddVersionKey "LegalCopyright" "Copyright (c) 2026 ${PUBLISHER}"
VIAddVersionKey "OriginalFilename" "VoidOne-Setup-x64.exe"
VIAddVersionKey "Comments" "Open-source native PC gaming platform"

!define MUI_ICON "${APP_ICON_PATH}"
!define MUI_UNICON "${APP_ICON_PATH}"
!define MUI_ABORTWARNING
!define MUI_COMPONENTSPAGE_SMALLDESC
!define MUI_COMPONENTSPAGE_TEXT_TOP "Choose the VoidOne shortcuts you want. The application itself is always installed."
!define MUI_COMPONENTSPAGE_TEXT_DESCRIPTION_TITLE "Installation options"
!define MUI_COMPONENTSPAGE_TEXT_DESCRIPTION_INFO "Select an option to see what it does."
!define MUI_WELCOMEPAGE_TITLE "Welcome to VoidOne"
!define MUI_WELCOMEPAGE_TEXT "Install VoidOne ${VERSION} on your Windows PC.$\r$\n$\r$\nA native, open-source PC gaming platform built around your games — not around a store.$\r$\n$\r$\nThe installer will validate your system, install or repair the required Microsoft Visual C++ runtime when needed, preserve an existing installation path when upgrading, register VoidOne with Windows, and give you control over optional shortcuts."
!define MUI_DIRECTORYPAGE_TEXT_TOP "Choose where VoidOne should be installed. Your existing VoidOne installation directory will be reused automatically when possible."
!define MUI_DIRECTORYPAGE_TEXT_DESTINATION "Installation folder"
!define MUI_INSTFILESPAGE_HEADER "Installing VoidOne"
!define MUI_INSTFILESPAGE_TEXT "Please wait while VoidOne is installed. Required Microsoft Visual C++ runtime components, Windows integration, shortcuts, file associations, and the VoidOne protocol are being configured."
!define MUI_FINISHPAGE_TITLE "VoidOne is ready"
!define MUI_FINISHPAGE_TEXT "VoidOne ${VERSION} has been installed successfully.$\r$\n$\r$\nLaunch VoidOne now, or close this installer and start it later from Windows."
!define MUI_FINISHPAGE_RUN "${APP_EXE_PATH}"
!define MUI_FINISHPAGE_RUN_TEXT "Launch VoidOne"
!define MUI_FINISHPAGE_RUN_NOTCHECKED
!define MUI_FINISHPAGE_LINK "Visit the VoidOne project on GitHub"
!define MUI_FINISHPAGE_LINK_LOCATION "${WEB_SITE}"
!define MUI_UNCONFIRMPAGE_TEXT_TOP "VoidOne will be removed from this computer. Personal library data stored outside the installation directory is not intentionally removed."
!define MUI_UNCONFIRMPAGE_TEXT_CONFIRM "Click Uninstall to remove VoidOne from this computer."

Var SystemCheckDialog
Var SystemCheckStatus
Var SystemCheckLabel
Var SystemCheckInstallLabel
Var SystemCheckDiskLabel
Var SystemCheckArchitectureLabel
Var RepairMode
Var CommandLineParameters

!define MUI_PAGE_CUSTOMFUNCTION_PRE SkipRepairPage
!insertmacro MUI_PAGE_WELCOME
Page custom SystemCheckPage SystemCheckPageLeave
!define MUI_PAGE_CUSTOMFUNCTION_PRE SkipRepairPage
!insertmacro MUI_PAGE_LICENSE "${LICENSE_PATH}"
!define MUI_PAGE_CUSTOMFUNCTION_PRE SkipRepairPage
!insertmacro MUI_PAGE_DIRECTORY
!define MUI_PAGE_CUSTOMFUNCTION_PRE SkipRepairPage
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "Farsi"

; Hidden payload section: the Microsoft redistributable is shipped inside the
; VoidOne installer so a target machine does not need internet access to get
; the runtime dependency.
Section -VCRuntimePayload
    SectionIn RO
    SetOutPath "$PLUGINSDIR"
    File /oname=vc_redist.x64.exe "${VC_REDIST_SOURCE}"
SectionEnd

Section "VoidOne" SEC_MAIN
    SectionIn RO
    ${If} $RepairMode == "1"
        DetailPrint "Repair mode: reinstalling VoidOne in the existing installation directory."
    ${Else}
        DetailPrint "Installing VoidOne ${VERSION}."
    ${EndIf}

    Call EnsureVCRuntime

    SetOutPath "${INSTALL_BIN_DIR}"
    SetOverwrite on
    File /r "${PACKAGE_DIR}\*"
    WriteUninstaller "$INSTDIR\Uninstall.exe"

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
    WriteRegStr HKLM "${UNINST_KEY}" "PublisherUrl" "${WEB_SITE}"
    WriteRegStr HKLM "${UNINST_KEY}" "ReleaseNotes" "${WEB_SITE}/releases"
    WriteRegDword HKLM "${UNINST_KEY}" "NoModify" 1
    WriteRegDword HKLM "${UNINST_KEY}" "NoRepair" 1
    ${GetSize} "$INSTDIR" "/S=0K" $2 $3 $4
    WriteRegDWORD HKLM "${UNINST_KEY}" "EstimatedSize" $2
    ${GetTime} "" "L" $0 $1 $2 $3 $4 $5 $6
    WriteRegStr HKLM "${UNINST_KEY}" "InstallDate" "$2$1$0"

    WriteRegStr HKLM "${APP_REG_KEY}" "InstallDir" "$INSTDIR"
    WriteRegStr HKLM "${APP_REG_KEY}" "Version" "${VERSION}"
    WriteRegStr HKLM "${APP_REG_KEY}" "InstallerVersion" "${VERSION}"

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
SectionEnd

Section /o "Start Menu shortcut" SEC_STARTMENU
    CreateDirectory "${START_MENU_DIR}"
    CreateShortCut "${START_MENU_DIR}\${APP_NAME}.lnk" "${APP_EXE_PATH}" "" "${APP_EXE_PATH}" 0
    CreateShortCut "${START_MENU_DIR}\Uninstall ${APP_NAME}.lnk" "$INSTDIR\Uninstall.exe"
SectionEnd

Section /o "Desktop shortcut" SEC_DESKTOP
    CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "${APP_EXE_PATH}" "" "${APP_EXE_PATH}" 0
SectionEnd

!macro SingleInstanceMutex
    System::Call 'KERNEL32::CreateMutex(${SYSTYPE_PTR}0, i1, t"${INSTALLER_MUTEX_NAME}")?e'
    Pop $0
    IntCmpU $0 183 mutex_existing mutex_ready mutex_ready
mutex_existing:
    IfSilent mutex_abort mutex_message
mutex_message:
    MessageBox MB_ICONEXCLAMATION|MB_OK "Another VoidOne installer or uninstaller is already running. Please finish it before starting another one."
mutex_abort:
    Abort
mutex_ready:
!macroend

Function EnsureVCRuntime
    ; VoidOne is x64. Check the actual runtime DLLs first so a partially
    ; installed/corrupted VC++ runtime is repaired instead of being skipped.
    ${If} ${FileExists} "$SYSDIR\MSVCP140.dll"
    ${AndIf} ${FileExists} "$SYSDIR\VCRUNTIME140.dll"
    ${AndIf} ${FileExists} "$SYSDIR\VCRUNTIME140_1.dll"
        DetailPrint "Microsoft Visual C++ runtime is already available."
        Return
    ${EndIf}

    DetailPrint "Microsoft Visual C++ runtime is missing or incomplete."

    ClearErrors
    ReadRegStr $0 HKLM "SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" "Version"
    ${If} $0 != ""
        StrCpy $1 "/repair /quiet /norestart"
        DetailPrint "Existing VC++ runtime registration found; repair mode will be used."
    ${Else}
        StrCpy $1 "/install /quiet /norestart"
        DetailPrint "No VC++ runtime registration found; install mode will be used."
    ${EndIf}

    ; The redistributable is bundled into the installer. The online download
    ; below remains as a defensive fallback for externally customized builds.
    ${If} ${FileExists} "${VC_REDIST_FILE}"
        DetailPrint "Using the bundled Microsoft Visual C++ x64 Redistributable."
    ${Else}
        DetailPrint "Bundled VC++ Redistributable payload is unavailable; downloading from Microsoft."
        ClearErrors
        ExecWait `"$WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "Invoke-WebRequest -UseBasicParsing -Uri ''${VC_REDIST_URL}'' -OutFile ''${VC_REDIST_FILE}''"` $2
        ${If} $2 != 0
            DetailPrint "VC++ Redistributable download failed with exit code $2."
            IfSilent vc_download_failed_silent vc_download_failed_message
vc_download_failed_message:
            MessageBox MB_ICONSTOP|MB_RETRYCANCEL "VoidOne needs the Microsoft Visual C++ runtime to run.$\r$\n$\r$\nThe bundled runtime could not be used and the fallback download failed. Please check your internet connection and click Retry, or cancel the installation." IDRETRY vc_retry_download IDCANCEL vc_download_abort
            Goto vc_retry_download
vc_download_failed_silent:
            Abort
vc_retry_download:
            Delete "${VC_REDIST_FILE}"
            ClearErrors
            ExecWait `"$WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "Invoke-WebRequest -UseBasicParsing -Uri ''${VC_REDIST_URL}'' -OutFile ''${VC_REDIST_FILE}''"` $2
            ${If} $2 != 0
                Goto vc_download_abort
            ${EndIf}
        ${EndIf}
    ${EndIf}

    ${IfNot} ${FileExists} "${VC_REDIST_FILE}"
        Goto vc_download_abort
    ${EndIf}

    DetailPrint "Installing Microsoft Visual C++ runtime."
    ExecWait '"${VC_REDIST_FILE}" $1' $3
    Delete "${VC_REDIST_FILE}"

    ; 0 = success, 3010 = success with reboot required.
    ${If} $3 != 0
    ${AndIf} $3 != 3010
        DetailPrint "VC++ Redistributable installation failed with exit code $3."
        IfSilent vc_install_failed_silent vc_install_failed_message
vc_install_failed_message:
        MessageBox MB_ICONSTOP|MB_OK "VoidOne could not install the Microsoft Visual C++ runtime (exit code $3). The installation cannot continue."
vc_install_failed_silent:
        Abort
    ${EndIf}

    ${IfNot} ${FileExists} "$SYSDIR\MSVCP140.dll"
        Goto vc_verify_failed
    ${EndIf}
    ${IfNot} ${FileExists} "$SYSDIR\VCRUNTIME140.dll"
        Goto vc_verify_failed
    ${EndIf}
    ${IfNot} ${FileExists} "$SYSDIR\VCRUNTIME140_1.dll"
        Goto vc_verify_failed
    ${EndIf}

    DetailPrint "Microsoft Visual C++ runtime verified successfully."
    Return

vc_verify_failed:
    DetailPrint "VC++ Redistributable completed, but required runtime DLLs are still missing."
    IfSilent vc_verify_failed_silent vc_verify_failed_message
vc_verify_failed_message:
    MessageBox MB_ICONSTOP|MB_OK "VoidOne could not verify the Microsoft Visual C++ runtime after installation. Please restart Windows and run the installer again."
vc_verify_failed_silent:
    Abort

vc_download_abort:
    Delete "${VC_REDIST_FILE}"
    IfSilent vc_download_abort_silent vc_download_abort_message
vc_download_abort_message:
    MessageBox MB_ICONSTOP|MB_OK "VoidOne requires the Microsoft Visual C++ runtime. The installer cannot continue without the required runtime payload."
vc_download_abort_silent:
    Abort
FunctionEnd

Function .onInit
    !insertmacro SingleInstanceMutex

    SetRegView 64
    SetShellVarContext all

    ${GetParameters} $CommandLineParameters
    StrCpy $RepairMode "0"
    ClearErrors
    ${GetOptions} $CommandLineParameters "/REPAIR" $0
    ${IfNot} ${Errors}
        StrCpy $RepairMode "1"
    ${EndIf}
    ClearErrors

    ${If} $RepairMode == "1"
        ReadRegStr $0 HKLM "${UNINST_KEY}" "InstallLocation"
        ${If} $0 == ""
            ReadRegStr $0 HKLM "${APP_REG_KEY}" "InstallDir"
        ${EndIf}
        ${If} $0 == ""
            IfSilent repair_no_install_silent repair_no_install_message
repair_no_install_message:
            MessageBox MB_ICONSTOP|MB_OK "Repair mode requires an existing VoidOne installation. Run the normal installer first."
repair_no_install_silent:
            Abort
        ${EndIf}
        StrCpy $INSTDIR $0
    ${Else}
        ReadRegStr $0 HKLM "${UNINST_KEY}" "InstallLocation"
        ${If} $0 == ""
            ReadRegStr $0 HKLM "${APP_REG_KEY}" "InstallDir"
        ${EndIf}
        ${If} $0 != ""
            StrCpy $INSTDIR $0
        ${EndIf}
    ${EndIf}

    ${IfNot} ${RunningX64}
        IfSilent x64_fail_silent x64_fail_message
x64_fail_message:
        MessageBox MB_ICONSTOP|MB_OK "VoidOne requires a 64-bit version of Windows 10 or Windows 11."
x64_fail_silent:
        Abort
    ${EndIf}
    ${IfNot} ${AtLeastWin10}
        IfSilent win_fail_silent win_fail_message
win_fail_message:
        MessageBox MB_ICONSTOP|MB_OK "VoidOne requires Windows 10 or later."
win_fail_silent:
        Abort
    ${EndIf}

    FindWindow $1 "" "${APP_NAME}"
    ${If} $1 != 0
        IfSilent running_fail_silent running_fail_message
running_fail_message:
        MessageBox MB_ICONEXCLAMATION|MB_OKCANCEL "VoidOne is currently running.$\r$\n$\r$\nPlease close VoidOne before continuing the installation." IDOK continue IDCANCEL cancel
        Abort
running_fail_silent:
        Abort
cancel:
        Abort
continue:
    ${EndIf}
FunctionEnd

Function SkipRepairPage
    ${If} $RepairMode == "1"
        Abort
    ${EndIf}
FunctionEnd

Function SystemCheckPage
    ${If} $RepairMode == "1"
        Abort
    ${EndIf}
    !insertmacro MUI_HEADER_TEXT "System check" "Verify that this PC is ready for VoidOne."
    nsDialogs::Create 1018
    Pop $SystemCheckDialog
    ${If} $SystemCheckDialog == error
        Abort
    ${EndIf}
    ${NSD_CreateLabel} 0 0 100% 18u "VoidOne will run a quick pre-installation check before copying files."
    Pop $SystemCheckLabel
    ${NSD_CreateLabel} 0 28u 100% 18u "Architecture: checking..."
    Pop $SystemCheckArchitectureLabel
    ${NSD_CreateLabel} 0 50u 100% 18u "Windows: checking..."
    Pop $SystemCheckStatus
    ${NSD_CreateLabel} 0 72u 100% 18u "Install location: checking..."
    Pop $SystemCheckInstallLabel
    ${NSD_CreateLabel} 0 94u 100% 18u "Disk space: checking..."
    Pop $SystemCheckDiskLabel
    ${If} ${RunningX64}
        ${NSD_SetText} $SystemCheckArchitectureLabel "Architecture: 64-bit Windows detected ✓"
    ${Else}
        ${NSD_SetText} $SystemCheckArchitectureLabel "Architecture: 64-bit Windows required ✗"
    ${EndIf}
    ${If} ${AtLeastWin10}
        ${NSD_SetText} $SystemCheckStatus "Windows: Windows 10/11 compatible ✓"
    ${Else}
        ${NSD_SetText} $SystemCheckStatus "Windows: Windows 10 or later required ✗"
    ${EndIf}
    ${NSD_SetText} $SystemCheckInstallLabel "Install location: $INSTDIR"
    ${GetRoot} "$INSTDIR" $0
    ${DriveSpace} "$0" "/D=F /S=M" $1
    ${If} $1 == ""
        ${NSD_SetText} $SystemCheckDiskLabel "Disk space: unable to determine free space"
    ${Else}
        ${NSD_SetText} $SystemCheckDiskLabel "Disk space: $1 MB free on $0 (recommended: 512 MB+)"
    ${EndIf}
    ReadRegStr $0 HKLM "${UNINST_KEY}" "DisplayVersion"
    ${If} $0 != ""
        ${NSD_SetText} $SystemCheckLabel "Existing installation detected: VoidOne $0 — this installer will upgrade it in place."
    ${EndIf}
    nsDialogs::Show
FunctionEnd

Function SystemCheckPageLeave
    ${IfNot} ${RunningX64}
        IfSilent systemcheck_x64_silent systemcheck_x64_message
systemcheck_x64_message:
        MessageBox MB_ICONSTOP|MB_OK "This PC is not compatible with the x64 VoidOne build."
        Abort
systemcheck_x64_silent:
        Abort
    ${EndIf}
    ${IfNot} ${AtLeastWin10}
        IfSilent systemcheck_win_silent systemcheck_win_message
systemcheck_win_message:
        MessageBox MB_ICONSTOP|MB_OK "VoidOne requires Windows 10 or later."
        Abort
systemcheck_win_silent:
        Abort
    ${EndIf}
FunctionEnd

Function un.onInit
    !insertmacro SingleInstanceMutex
    SetRegView 64
    SetShellVarContext all
FunctionEnd

Function un.onUninstSuccess
    HideWindow
    IfSilent un_silent_done
    MessageBox MB_ICONINFORMATION|MB_OK "VoidOne has been removed successfully."
un_silent_done:
FunctionEnd

Section "Uninstall"
    SetRegView 64
    SetShellVarContext all
    DetailPrint "Removing VoidOne Windows integration and shortcuts."
    Delete "$DESKTOP\${APP_NAME}.lnk"
    RMDir /r "${START_MENU_DIR}"
    DeleteRegKey HKCR "${PROTOCOL_SCHEME}"
    DeleteRegKey HKCR ".${FILE_EXT}"
    DeleteRegKey HKCR "${APP_NAME}.ProjectFile"
    DeleteRegKey HKCR "Directory\shell\VoidOne"
    DeleteRegKey HKLM "${UNINST_KEY}"
    DeleteRegKey HKLM "${APP_REG_KEY}"
    RMDir /r "$INSTDIR"
SectionEnd

LangString DESC_SEC_MAIN ${LANG_ENGLISH} "Required VoidOne application files, Qt runtime, plugins, dependencies, and Microsoft Visual C++ runtime bootstrap."
LangString DESC_SEC_STARTMENU ${LANG_ENGLISH} "Create a Start Menu folder with launch and uninstall shortcuts."
LangString DESC_SEC_DESKTOP ${LANG_ENGLISH} "Create a shortcut to VoidOne on the Windows desktop."
LangString DESC_SEC_MAIN ${LANG_FARSI} "فایل‌های اصلی VoidOne، محیط Qt، افزونه‌ها، وابستگی‌ها و نصب خودکار Microsoft Visual C++ Runtime."
LangString DESC_SEC_STARTMENU ${LANG_FARSI} "ساخت پوشه‌ای در منوی Start برای اجرای VoidOne و حذف نصب."
LangString DESC_SEC_DESKTOP ${LANG_FARSI} "ساخت میانبر VoidOne روی دسکتاپ."

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_MAIN} $(DESC_SEC_MAIN)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_STARTMENU} $(DESC_SEC_STARTMENU)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_DESKTOP} $(DESC_SEC_DESKTOP)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

!ifdef VC_REDIST_SOURCE_TEMP
  !delfile "${VC_REDIST_SOURCE}"
  !undef VC_REDIST_SOURCE_TEMP
!endif
