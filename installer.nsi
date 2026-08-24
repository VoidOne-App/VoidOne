!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "x64.nsh"

; ============================================
; Enterprise Application Configuration
; ============================================
!define APP_NAME "VoidOne"
!define COMPANY_NAME "VoidOne_app"
!define EXE_NAME "VoidOne.exe"
!define PUBLISHER "VoidOne_app"
!define WEB_SITE "https://github.com/VoidOne-App/VoidOne"
!define FILE_EXT "vone"
!define PROTOCOL_SCHEME "voidone"

; دریافت اتوماتیک نسخه از روی فایل VoidOne.exe
!getdllversion "package\${EXE_NAME}" Expv
!define VERSION "${Expv1}.${Expv2}.${Expv3}"

Name "${APP_NAME} ${VERSION}"

; Fixed output file name for GitHub Actions CI/CD pipeline
OutFile "dist\VoidOne-Setup-x64.exe"

InstallDir "$PROGRAMFILES64\${APP_NAME}"
InstallDirRegKey HKLM "Software\${COMPANY_NAME}\${APP_NAME}" "InstallDir"
RequestExecutionLevel admin

; ============================================
; Modern UI (MUI2) Branding & Visuals
; ============================================
!define MUI_ICON "app-icon.ico"
!define MUI_UNICON "app-icon.ico"

!define MUI_ABORTWARNING

; Finish Page Settings
!define MUI_FINISHPAGE_RUN "$INSTDIR\${EXE_NAME}"
!define MUI_FINISHPAGE_RUN_TEXT "Run ${APP_NAME}"
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

; Language
!insertmacro MUI_LANGUAGE "English"

; ============================================
; Initialization & Architecture Enforcement
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
; Installation Section
; ============================================
Section "MainSection" SEC01
    SetOutPath "$INSTDIR"

    ; 1. Terminate running instances silently
    nsExec::Exec 'taskkill /F /IM "${EXE_NAME}" /T'
    Sleep 1000

    ; 2. Copy payload files & VC Redist payload
    File /r "package\*"

    ; 3. Silent Installation of VC++ Redistributable (If Included in Package)
    ${If} ${FileExists} "$INSTDIR\VC_redist.x64.exe"
        nsExec::Exec '"$INSTDIR\VC_redist.x64.exe" /install /quiet /norestart'
    ${EndIf}

    ; 4. Generate Uninstaller Executable
    WriteUninstaller "$INSTDIR\Uninstall.exe"

    ; 5. Create Start Menu Shortcuts
    CreateDirectory "$SMPROGRAMS\${APP_NAME}"
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "$INSTDIR\${EXE_NAME}" "" "$INSTDIR\${EXE_NAME}" 0
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\Uninstall ${APP_NAME}.lnk" "$INSTDIR\Uninstall.exe"

    ; 6. Register Custom URI Protocol (voidone://)
    WriteRegStr HKCR "${PROTOCOL_SCHEME}" "" "URL:${APP_NAME} Protocol"
    WriteRegStr HKCR "${PROTOCOL_SCHEME}" "URL Protocol" ""
    WriteRegStr HKCR "${PROTOCOL_SCHEME}\DefaultIcon" "" "$INSTDIR\${EXE_NAME},0"
    WriteRegStr HKCR "${PROTOCOL_SCHEME}\shell\open\command" "" '"$INSTDIR\${EXE_NAME}" "%1"'

    ; 7. Windows Add/Remove Programs (Control Panel Integration)
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayName" "${APP_NAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "Publisher" "${PUBLISHER}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayVersion" "${VERSION}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "DisplayIcon" "$INSTDIR\${EXE_NAME},0"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "InstallLocation" "$INSTDIR"
    WriteRegDword HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "NoModify" 1
    WriteRegDword HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}" "NoRepair" 1

    ; 8. Save Install Directory in Registry
    WriteRegStr HKLM "Software\${COMPANY_NAME}\${APP_NAME}" "InstallDir" "$INSTDIR"
SectionEnd

; ============================================
; Uninstallation Section
; ============================================
Section "Uninstall"
    ; 1. Terminate running instance before uninstalling
    nsExec::Exec 'taskkill /F /IM "${EXE_NAME}" /T'
    Sleep 1000

    ; 2. Delete Shortcuts
    Delete "$DESKTOP\${APP_NAME}.lnk"
    RMDir /r "$SMPROGRAMS\${APP_NAME}"

    ; 3. Delete Installed Files & Directory
    RMDir /r "$INSTDIR"

    ; 4. Clean Registry Entries
    DeleteRegKey HKCR "${PROTOCOL_SCHEME}"
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
    DeleteRegKey HKLM "Software\${COMPANY_NAME}\${APP_NAME}"
SectionEnd
