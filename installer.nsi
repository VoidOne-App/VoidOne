!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "x64.nsh"

; ============================================
; Enterprise Application Configuration
; ============================================
!define APP_NAME "VoidOne"
!define COMPANY_NAME "VoidOne_app"
!define EXE_NAME "VoidOne.exe"
!define VERSION "1.0.0"
!define PUBLISHER "VoidOne_app"
!define WEB_SITE "https://github.com/VoidOne-App/VoidOne"
!define FILE_EXT "vone"
!define PROTOCOL_SCHEME "voidone"

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

; در صورت داشتن تصاویر برندینگ در پروژه، این دو خط را فعال کنید:
; !define MUI_HEADERIMAGE
; !define MUI_HEADERIMAGE_BITMAP "assets\header.bmp"

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

    ; 7. Register Custom File Association (.vone)
    WriteRegStr HKCR ".${FILE_EXT}" "" "${APP_NAME}.ProjectFile"
    WriteRegStr HKCR "${APP_NAME}.ProjectFile" "" "${APP_NAME} Project File"
    WriteRegStr HKCR "${APP_NAME}.ProjectFile\DefaultIcon" "" "$INSTDIR\${EXE_NAME},0"
    WriteRegStr HKCR "${APP_NAME}.ProjectFile\shell\open\command" "" '"$INSTDIR\${EXE_NAME}" "%1"'
    nsExec::Exec 'shell32::SHChangeNotify(i 0x08000000, i 0, i 0, i 0)'

    ; 8. Register Windows Firewall Exception
    nsExec::Exec 'netsh advfirewall firewall add rule name="${APP_NAME} Engine" dir=in action=allow program="$INSTDIR\${EXE_NAME}" enable=yes profile=any'

    ; 9. Auto-Startup Registration
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${APP_NAME}" '"$INSTDIR\${EXE_NAME}" --autostart'

    ; 10. Register in Windows Programs & Features (Control Panel / ARP)
    !define UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
    WriteRegStr HKLM "${UNINST_KEY}" "DisplayName" "${APP_NAME}"
    WriteRegStr HKLM "${UNINST_KEY}" "DisplayVersion" "${VERSION}"
    WriteRegStr HKLM "${UNINST_KEY}" "Publisher" "${PUBLISHER}"
    WriteRegStr HKLM "${UNINST_KEY}" "URLInfoAbout" "${WEB_SITE}"
    WriteRegStr HKLM "${UNINST_KEY}" "DisplayIcon" "$INSTDIR\${EXE_NAME}"
    WriteRegStr HKLM "${UNINST_KEY}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
    WriteRegStr HKLM "${UNINST_KEY}" "InstallLocation" "$INSTDIR"
    WriteRegDWORD HKLM "${UNINST_KEY}" "NoModify" 1
    WriteRegDWORD HKLM "${UNINST_KEY}" "NoRepair" 1

    ; Save installation directory
    WriteRegStr HKLM "Software\${COMPANY_NAME}\${APP_NAME}" "InstallDir" "$INSTDIR"
SectionEnd

; ============================================
; Uninstallation Section
; ============================================
Section "Uninstall"
    ; 1. Terminate running instances
    nsExec::Exec 'taskkill /F /IM "${EXE_NAME}" /T'

    ; 2. Remove Windows Firewall Rule
    nsExec::Exec 'netsh advfirewall firewall delete rule name="${APP_NAME} Engine"'

    ; 3. Remove Registry & Associations
    DeleteRegKey HKCR "${PROTOCOL_SCHEME}"
    DeleteRegKey HKCR ".${FILE_EXT}"
    DeleteRegKey HKCR "${APP_NAME}.ProjectFile"
    DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${APP_NAME}"

    ; 4. Remove Shortcuts
    Delete "$DESKTOP\${APP_NAME}.lnk"
    RMDir /r "$SMPROGRAMS\${APP_NAME}"

    ; 5. Remove Installed Directory & System Registry Entries
    RMDir /r "$INSTDIR"
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
    DeleteRegKey HKLM "Software\${COMPANY_NAME}\${APP_NAME}"
    DeleteRegKey /ifempty HKLM "Software\${COMPANY_NAME}"
SectionEnd
