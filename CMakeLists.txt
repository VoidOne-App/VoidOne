cmake_minimum_required(VERSION 3.25)

set(VOIDONE_VERSION_OVERRIDE "0.0.1" CACHE STRING "Override application version (normally supplied by CI/tag)")
set(VOIDONE_VERSION_INPUT "${VOIDONE_VERSION_OVERRIDE}")
string(REGEX MATCH "^[0-9]+\.[0-9]+\.[0-9]+" VOIDONE_VERSION_BASE "${VOIDONE_VERSION_INPUT}")
if(NOT VOIDONE_VERSION_BASE)
    message(WARNING "Invalid VOIDONE_VERSION_OVERRIDE='${VOIDONE_VERSION_INPUT}'; falling back to 0.0.1")
    set(VOIDONE_VERSION_BASE "0.0.1")
endif()

project(VoidOne
    VERSION "${VOIDONE_VERSION_BASE}"
    DESCRIPTION "A modern Qt6/QML PC game launcher"
    HOMEPAGE_URL "https://github.com/VoidOne-App/VoidOne"
    LANGUAGES CXX C
)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
    message(FATAL_ERROR "In-source builds are not allowed. Use: cmake -S . -B build -G Ninja")
endif()

option(VOIDONE_ENABLE_CODE_SIGNING "Sign binaries for Windows (Authenticode)" ON)
option(VOIDONE_GENERATE_INSTALLER "Generate NSIS installer (Windows)" ON)
option(VOIDONE_ENABLE_LTO "Enable link-time optimization in Release" ON)
option(VOIDONE_ENABLE_SANITIZERS "Enable AddressSanitizer in supported Debug builds" OFF)
option(VOIDONE_BUILD_TESTS "Build and register VoidOne unit tests" OFF)
option(VOIDONE_WARNINGS_AS_ERRORS "Treat compiler warnings as errors" ON)
option(VOIDONE_REPRODUCIBLE_BUILD "Enable deterministic compiler/linker settings" OFF)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

if(VOIDONE_REPRODUCIBLE_BUILD)
    if(NOT DEFINED ENV{SOURCE_DATE_EPOCH})
        message(FATAL_ERROR "VOIDONE_REPRODUCIBLE_BUILD requires SOURCE_DATE_EPOCH to be set")
    endif()
    message(STATUS "VoidOne reproducible build enabled (SOURCE_DATE_EPOCH=$ENV{SOURCE_DATE_EPOCH})")
endif()

if(VOIDONE_ENABLE_SANITIZERS)
    if(MSVC)
        if(NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
            message(FATAL_ERROR "VOIDONE_ENABLE_SANITIZERS requires a Debug build on MSVC")
        endif()
        add_compile_options(/fsanitize=address /Zi /Oy-)
        add_link_options(/fsanitize=address)
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU")
        add_compile_options(-fsanitize=address,undefined -fno-omit-frame-pointer -g)
        add_link_options(-fsanitize=address,undefined)
    else()
        message(FATAL_ERROR "Sanitizers are not supported by this compiler")
    endif()
endif()

if(VOIDONE_ENABLE_LTO AND CMAKE_BUILD_TYPE STREQUAL "Release")
    include(CheckIPOSupported)
    check_ipo_supported(RESULT _ipo_supported OUTPUT _ipo_error)
    if(_ipo_supported)
        set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)
    else()
        message(WARNING "LTO requested but unsupported: ${_ipo_error}")
    endif()
endif()

set(VOIDONE_GENERATED_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
file(MAKE_DIRECTORY "${VOIDONE_GENERATED_DIR}")
set(VOIDONE_VERSION_DISPLAY "${VOIDONE_VERSION_INPUT}")
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/cmake/VoidOneVersion.h.in"
               "${VOIDONE_GENERATED_DIR}/VoidOneVersion.h" @ONLY)

find_package(Qt6 6.11 REQUIRED COMPONENTS Core Gui Quick Sql Network)
if(VOIDONE_BUILD_TESTS)
    find_package(Qt6 6.11 REQUIRED COMPONENTS Test)
endif()
qt_standard_project_setup(REQUIRES 6.11)

function(voidone_apply_compile_policy target)
    if(MSVC)
        target_compile_options(${target} PRIVATE /W4 /permissive- /guard:cf /EHsc)
        if(VOIDONE_WARNINGS_AS_ERRORS)
            target_compile_options(${target} PRIVATE /WX)
        endif()
        if(VOIDONE_REPRODUCIBLE_BUILD)
            target_compile_options(${target} PRIVATE /Brepro)
            target_link_options(${target} PRIVATE /Brepro)
        endif()
    else()
        target_compile_options(${target} PRIVATE -Wall -Wextra -Wpedantic -fstack-protector-strong)
        if(VOIDONE_WARNINGS_AS_ERRORS)
            target_compile_options(${target} PRIVATE -Werror)
        endif()
        if(VOIDONE_REPRODUCIBLE_BUILD)
            target_compile_options(${target} PRIVATE
                "-ffile-prefix-map=${CMAKE_SOURCE_DIR}=."
                "-fdebug-prefix-map=${CMAKE_SOURCE_DIR}=.")
        endif()
    endif()
endfunction()

set(VOIDONE_CORE_SOURCES
    src/core/Database.cpp src/core/Database.h
    src/core/SteamScanner.cpp src/core/SteamScanner.h
    src/core/GameModel.cpp src/core/GameModel.h
    src/core/TranslationManager.cpp src/core/TranslationManager.h
    src/core/SaveBackupManager.cpp src/core/SaveBackupManager.h
)

add_library(voidone_core STATIC ${VOIDONE_CORE_SOURCES})
target_include_directories(voidone_core PUBLIC
    "${CMAKE_CURRENT_SOURCE_DIR}/src"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/core"
    "${VOIDONE_GENERATED_DIR}"
)
target_link_libraries(voidone_core PUBLIC Qt6::Core Qt6::Sql Qt6::Network)
target_precompile_headers(voidone_core PRIVATE <QObject> <QString> <QList> <memory> <vector> <string>)
voidone_apply_compile_policy(voidone_core)

set(VOIDONE_EXE_EXTRA_SOURCES "")
if(WIN32)
    set(APP_ICON_PATH "${CMAKE_CURRENT_SOURCE_DIR}/app-icon.ico")
    set(VOIDONE_RC_PATH "${CMAKE_CURRENT_BINARY_DIR}/voidone.rc")
    if(EXISTS "${APP_ICON_PATH}")
        set(VOIDONE_RC_VERSION "${PROJECT_VERSION_MAJOR},${PROJECT_VERSION_MINOR},${PROJECT_VERSION_PATCH},0")
        file(WRITE "${VOIDONE_RC_PATH}" "#include <winver.h>\nIDI_ICON1 ICON DISCARDABLE \"${APP_ICON_PATH}\"\nVS_VERSION_INFO VERSIONINFO\n FILEVERSION ${VOIDONE_RC_VERSION}\n PRODUCTVERSION ${VOIDONE_RC_VERSION}\n FILEFLAGSMASK 0x3fL\n FILEFLAGS 0x0L\n FILEOS 0x40004L\n FILETYPE 0x1L\n FILESUBTYPE 0x0L\nBEGIN\n BLOCK \"StringFileInfo\"\n BEGIN\n  BLOCK \"040904b0\"\n  BEGIN\n   VALUE \"CompanyName\", \"VoidOne_app\"\n   VALUE \"FileDescription\", \"${PROJECT_DESCRIPTION}\"\n   VALUE \"FileVersion\", \"${VOIDONE_VERSION_DISPLAY}\"\n   VALUE \"InternalName\", \"VoidOne\"\n   VALUE \"OriginalFilename\", \"VoidOne.exe\"\n   VALUE \"ProductName\", \"VoidOne\"\n   VALUE \"ProductVersion\", \"${VOIDONE_VERSION_DISPLAY}\"\n  END\n END\n BLOCK \"VarFileInfo\"\n BEGIN\n  VALUE \"Translation\", 0x409, 1200\n END\nEND\n")
        list(APPEND VOIDONE_EXE_EXTRA_SOURCES "${VOIDONE_RC_PATH}")
    endif()
endif()

qt_add_executable(VoidOne src/main.cpp ${VOIDONE_EXE_EXTRA_SOURCES})
qt_add_qml_module(VoidOne
    URI VoidOne VERSION 1.0 NO_PLUGIN
    QML_FILES
        src/ui/qml/Main.qml
        src/ui/qml/GameCard.qml
        src/ui/qml/Sidebar.qml
        src/ui/qml/SaveBackupView.qml
        src/ui/qml/SidebarButton.qml
        src/ui/qml/EnterpriseDialog.qml
        src/ui/qml/MusicControllerWidget.qml
        src/ui/qml/SystemTelemetryWidget.qml
)
target_link_libraries(VoidOne PRIVATE voidone_core Qt6::Gui Qt6::Quick)
voidone_apply_compile_policy(VoidOne)

if(WIN32)
    set_target_properties(VoidOne PROPERTIES WIN32_EXECUTABLE TRUE)
endif()

if(WIN32 AND VOIDONE_ENABLE_CODE_SIGNING)
    find_program(SIGNTOOL_EXECUTABLE signtool)
    if(SIGNTOOL_EXECUTABLE AND DEFINED ENV{VOIDONE_SIGN_CERT_PATH} AND DEFINED ENV{VOIDONE_SIGN_PASSWORD})
        add_custom_command(TARGET VoidOne POST_BUILD
            COMMAND "${SIGNTOOL_EXECUTABLE}" sign /f "$ENV{VOIDONE_SIGN_CERT_PATH}"
                    /p "$ENV{VOIDONE_SIGN_PASSWORD}" /fd sha256
                    /tr http://timestamp.digicert.com /td sha256 "$<TARGET_FILE:VoidOne>"
            COMMENT "Signing VoidOne.exe" VERBATIM)
    endif()
endif()

install(TARGETS VoidOne BUNDLE DESTINATION . RUNTIME DESTINATION bin)
if(WIN32)
    qt_generate_deploy_qml_app_script(TARGET VoidOne OUTPUT_SCRIPT VOIDONE_QT_DEPLOY_SCRIPT
        NO_UNSUPPORTED_PLATFORM_ERROR)
    install(SCRIPT "${VOIDONE_QT_DEPLOY_SCRIPT}")
endif()

set(CPACK_PACKAGE_NAME "VoidOne")
set(CPACK_PACKAGE_VENDOR "VoidOne_app")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "VoidOne PC Game Launcher (${VOIDONE_VERSION_DISPLAY})")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "VoidOne")
if(WIN32 AND VOIDONE_GENERATE_INSTALLER)
    set(CPACK_GENERATOR "NSIS")
    set(CPACK_NSIS_DISPLAY_NAME "VoidOne ${VOIDONE_VERSION_DISPLAY}")
    set(CPACK_NSIS_COMPRESSOR "/SOLID lzma")
    set(CPACK_NSIS_MUI_FINISHPAGE_RUN "$INSTDIR\\bin\\VoidOne.exe")
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/app-icon.ico")
        set(CPACK_NSIS_MUI_ICON "${CMAKE_CURRENT_SOURCE_DIR}/app-icon.ico")
    endif()
endif()
include(CPack)

if(VOIDONE_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()
