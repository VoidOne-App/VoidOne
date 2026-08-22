!include "MUI2.nsh"
!include "LogicLib.nsh"

; ============================================
; Basic Application Configuration
; ============================================
!define APP_NAME "VoidOne"
!define COMPANY_NAME "VoidOne-App"
!define EXE_NAME "VoidOne.exe"
!define VERSION "1.0.0"
!define PUBLISHER "VoidOne Technologies"
!define WEB_SITE "https://voidone.com"

Name "${APP_NAME} ${VERSION}"

; Fixed output file name for GitHub Actions CI/CD pipeline
OutFile "dist\VoidOne-Setup-x64.exe"

InstallDir "$PROGRAMFILES64\${APP_NAME}"
InstallDirRegKey HKLM "Software\${COMPANY_NAME}\${APP_NAME}" "InstallDir"
RequestExecutionLevel admin

; ============================================
; Modern UI (MUI2) Settings
; ============================================
; Icon configuration from root directory
!define MUI_ICON "app-icon.ico"
!define MUI_UNICON "app-icon.ico"

!define MUI_ABORTWARNING

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
; Installation Section
; ============================================
Section "MainSection" SEC01
    SetOutPath "$INSTDIR"
    
    ; Terminate running instances before setup
    ExecWait 'taskkill /F /IM "${EXE_NAME}" /T' 
    Sleep 1000

    ; Copy payload files
    File /r "package\*"

    ; Generate uninstaller executable
    WriteUninstaller "$INSTDIR\Uninstall.exe"

    ; Create Shortcuts
    CreateDirectory "$SMPROGRAMS\${APP_NAME}"
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "$INSTDIR\${EXE_NAME}" "" "$INSTDIR\${EXE_NAME}" 0
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\Uninstall ${APP_NAME}.lnk" "$INSTDIR\Uninstall.exe"
    CreateShortCut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${EXE_NAME}" "" "$INSTDIR\${EXE_NAME}" 0

    ; Register in Windows Programs & Features
    !define UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
    WriteRegStr HKLM "${UNINST_KEY}" "DisplayName" "${APP_NAME}"
    WriteRegStr HKLM "${UNINST_KEY}" "DisplayVersion" "${VERSION}"
    WriteRegStr HKLM "${UNINST_KEY}" "Publisher" "${PUBLISHER}"
    WriteRegStr HKLM "${UNINST_KEY}" "URLInfoAbout" "${WEB_SITE}"
    WriteRegStr HKLM "${UNINST_KEY}" "DisplayIcon" "$INSTDIR\${EXE_NAME}"
    WriteRegStr HKLM "${UNINST_KEY}" "UninstallString" '"$INSTDIR\Uninstall.exe"'
    WriteRegDWORD HKLM "${UNINST_KEY}" "NoModify" 1
    WriteRegDWORD HKLM "${UNINST_KEY}" "NoRepair" 1

    ; Save installation directory
    WriteRegStr HKLM "Software\${COMPANY_NAME}\${APP_NAME}" "InstallDir" "$INSTDIR"
SectionEnd

; ============================================
; Uninstallation Section
; ============================================
Section "Uninstall"
    ; Terminate running instances
    ExecWait 'taskkill /F /IM "${EXE_NAME}" /T'

    ; Remove shortcuts
    Delete "$DESKTOP\${APP_NAME}.lnk"
    RMDir /r "$SMPROGRAMS\${APP_NAME}"

    ; Remove installed directory & registry entries
    RMDir /r "$INSTDIR"
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APP_NAME}"
    DeleteRegKey HKLM "Software\${COMPANY_NAME}\${APP_NAME}"
SectionEnd
