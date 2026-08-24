cmake_minimum_required(VERSION 3.25)

# ============================================================================
# 🌌 VOIDONE - ULTIMATE ENTERPRISE BUILD SYSTEM (PRODUCTION READY v1.0.1) 🌌
# ============================================================================

message(STATUS "
    ██╗   ██╗ ██████╗ ██╗██████╗  ██████╗ ███╗   ██╗███████╗
    ██║   ██║██╔═══██╗██║██╔══██╗██╔═══██╗████╗  ██║██╔════╝
    ██║   ██║██║   ██║██║██║  ██║██║   ██║██╔██╗ ██║█████╗  
    ╚██╗ ██╔╝██║   ██║██║██║  ██║██║   ██║██║╚██╗██║██╔══╝  
     ╚████╔╝ ╚██████╔╝██║██████╔╝╚██████╔╝██║ ╚████║███████╗
      ╚═══╝   ╚═════╝ ╚═╝╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝
    :: VOIDONE-APP ENTERPRISE LAUNCHER BUILD ENGINE [v1.0.1-PRO] ::
")

project(VoidOne
    VERSION 1.0.0
    DESCRIPTION "Ultimate Qt6/C++ Game Launcher & Enterprise Platform"
    HOMEPAGE_URL "https://github.com/VoidOne-app/VoidOne"
    LANGUAGES CXX C
)

# ============================================================================
# 0. Qt Standard Setup & Strict Dependency Check
# ============================================================================
find_package(Qt6 6.8 REQUIRED COMPONENTS Core Gui Quick Sql Network QuickControls2 LinguistTools)
qt_standard_project_setup(REQUIRES 6.8)

# ============================================================================
# 1. Package Management (VCPKG Integration)
# ============================================================================
if(DEFINED ENV{VCPKG_ROOT} AND NOT CMAKE_TOOLCHAIN_FILE)
    set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake" CACHE STRING "Vcpkg toolchain" FORCE)
    message(STATUS "💼 Enterprise: Vcpkg Package Manager Activated successfully.")
endif()

# ============================================================================
# 2. Global Compiler Settings & Enterprise Features Flags
# ============================================================================
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

option(VOIDONE_ENABLE_CODE_SIGNING  "Sign binaries for Windows (Authenticode)" ON)
option(VOIDONE_ENABLE_CPPCHECK      "Run cppcheck static analysis"             ON)
option(VOIDONE_GENERATE_INSTALLER   "Generate NSIS Installer (Windows)"        ON)
option(VOIDONE_ENABLE_SANITIZERS    "Enable Address & UB Sanitizers (Debug)"   OFF)
option(VOIDONE_ENABLE_UNITY_BUILD   "Enable Unity Builds for faster compilation" OFF)
option(BUILD_TESTING                "Enable Unit Testing Suite"                OFF)

if(BUILD_TESTING)
    enable_testing()
    message(STATUS "🧪 Enterprise: Testing Framework Initialized.")
endif()

# ============================================================================
# 3. Static Analysis & Compiler Warning Enforcements
# ============================================================================
if(VOIDONE_ENABLE_CPPCHECK)
    find_program(CPPCHECK_EXE NAMES cppcheck)
    if(CPPCHECK_EXE)
        set(CMAKE_CXX_CPPCHECK 
            "${CPPCHECK_EXE}" 
            "--enable=all" 
            "--inconclusive" 
            "--force" 
            "--inline-suppr"
            "--suppress=missingIncludeSystem"
        )
        message(STATUS "🛡️ Enterprise: Cppcheck Static Analysis Hooked.")
    endif()
endif()

function(voidone_set_warnings target_name)
    if(MSVC)
        target_compile_options(${target_name} PRIVATE /W4 /wx /permissive-)
    else()
        target_compile_options(${target_name} PRIVATE -Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wno-unused-parameter)
    endif()
endfunction()

# ============================================================================
# 4. Auto-Formatting Target
# ============================================================================
find_program(CLANG_FORMAT_EXE NAMES clang-format)
if(CLANG_FORMAT_EXE)
    add_custom_target(format
        COMMAND "${CLANG_FORMAT_EXE}" -i -style=file
        "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp" 
        "${CMAKE_CURRENT_SOURCE_DIR}/src/*.h"
        COMMENT "🎨 Formatting codebase with clang-format..."
    )
endif()

# ============================================================================
# 5. Core Engine Library (voidone_core)
# ============================================================================
add_library(voidone_core STATIC
    src/core/LaunchEngine.cpp src/core/LaunchEngine.h
    src/core/AuthManager.cpp src/core/AuthManager.h
    src/core/PatchManager.cpp src/core/PatchManager.h
)

set_target_properties(voidone_core PROPERTIES
    POSITION_INDEPENDENT_CODE ON
    UNITY_BUILD ${VOIDONE_ENABLE_UNITY_BUILD}
)

target_link_libraries(voidone_core PUBLIC 
    Qt6::Core 
    Qt6::Sql 
    Qt6::Network
)

target_include_directories(voidone_core PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/core>
    $<INSTALL_INTERFACE:include>
)

target_precompile_headers(voidone_core PRIVATE
    <QObject> 
    <QString> 
    <QVariant> 
    <QNetworkAccessManager> 
    <memory> 
    <thread>
)

voidone_set_warnings(voidone_core)

if(VOIDONE_ENABLE_SANITIZERS AND CMAKE_BUILD_TYPE STREQUAL "Debug")
    if(NOT MSVC)
        target_compile_options(voidone_core PRIVATE -fsanitize=address,undefined -fno-omit-frame-pointer)
        target_link_options(voidone_core PRIVATE -fsanitize=address,undefined)
        message(STATUS "⚡ Enterprise: Address & UB Sanitizers Enabled for Core.")
    endif()
endif()

# ============================================================================
# 6 & 7. Main Executable, QML Module & Localization (Fixed Target Scope)
# ============================================================================
qt_add_executable(VoidOne 
    src/main.cpp
)

qt_add_qml_module(VoidOne
    URI VoidOneApp
    VERSION 1.0
    QML_FILES
        src/ui/qml/Dashboard.qml
        src/ui/qml/LibraryView.qml
        src/ui/qml/Settings.qml
)

# تعریف فایل‌های ترجمه و اتصال امن آن‌ها به تارگت اصلی VoidOne
set(TS_FILES 
    translations/voidone_fa_IR.ts
    translations/voidone_en_US.ts
)

qt_add_translations(VoidOne
    TS_FILES ${TS_FILES}
)

set_target_properties(VoidOne PROPERTIES
    UNITY_BUILD ${VOIDONE_ENABLE_UNITY_BUILD}
)

target_link_libraries(VoidOne PRIVATE 
    voidone_core 
    Qt6::Gui 
    Qt6::Quick 
    Qt6::QuickControls2
)

voidone_set_warnings(VoidOne)

if(WIN32)
    set_target_properties(VoidOne PROPERTIES WIN32_EXECUTABLE TRUE)
    if(VOIDONE_ENABLE_SANITIZERS AND CMAKE_BUILD_TYPE STREQUAL "Debug" AND NOT MSVC)
        target_compile_options(VoidOne PRIVATE -fsanitize=address,undefined -fno-omit-frame-pointer)
        target_link_options(VoidOne PRIVATE -fsanitize=address,undefined)
    endif()
endif()

# ============================================================================
# 8. Robust Automated Qt Deployment (windeployqt)
# ============================================================================
if(WIN32)
    if(TARGET Qt6::Core)
        get_target_property(_qt_core_location Qt6::Core LOCATION)
        if(_qt_core_location)
            get_filename_component(_qt_bin_dir "${_qt_core_location}" DIRECTORY)
        endif()
    endif()

    find_program(WINDEPLOYQT_EXECUTABLE windeployqt HINTS "${_qt_bin_dir}" "${_qt_bin_dir}/../bin")
    if(WINDEPLOYQT_EXECUTABLE)
        add_custom_command(TARGET VoidOne POST_BUILD
            COMMAND "${CMAKE_COMMAND}" -E env PATH="${_qt_bin_dir}"
            "${WINDEPLOYQT_EXECUTABLE}"
            "--qmldir" "${CMAKE_CURRENT_SOURCE_DIR}/src/ui/qml"
            "--no-translations"
            "--no-compiler-runtime"
            "$<TARGET_FILE:VoidOne>"
            COMMENT "📦 Enterprise: Auto-deploying Qt QML runtime dependencies..."
        )
    endif()
endif()

# ============================================================================
# 9. Enterprise Code Signing (CI/CD & SmartScreen Bypass)
# ============================================================================
if(WIN32 AND VOIDONE_ENABLE_CODE_SIGNING)
    find_program(SIGNTOOL_EXECUTABLE signtool)
    if(SIGNTOOL_EXECUTABLE)
        if(DEFINED ENV{VOIDONE_SIGN_CERT_PATH} AND DEFINED ENV{VOIDONE_SIGN_PASSWORD})
            set(_CERT_PATH "$ENV{VOIDONE_SIGN_CERT_PATH}")
            set(_CERT_PWD "$ENV{VOIDONE_SIGN_PASSWORD}")
            
            add_custom_command(TARGET VoidOne POST_BUILD
                COMMAND "${SIGNTOOL_EXECUTABLE}" sign 
                    /f "${_CERT_PATH}" 
                    /p "${_CERT_PWD}" 
                    /fd sha256 
                    /tr http://timestamp.digicert.com 
                    /td sha256 
                    "$<TARGET_FILE:VoidOne>"
                COMMENT "🔐 Enterprise: Signing executable via Environment Certificate..."
                VERBATIM
            )
            message(STATUS "🔐 Enterprise: Code signing configured via CI/CD environment variables.")
        else()
            message(WARNING "⚠️ Code signing requested, but VOIDONE_SIGN_CERT_PATH or VOIDONE_SIGN_PASSWORD environment variables are missing. Skipping signature.")
        endif()
    endif()
endif()

# ============================================================================
# 10. Professional Packaging & Distribution Engine (CPack)
# ============================================================================
install(TARGETS VoidOne 
    BUNDLE DESTINATION . 
    RUNTIME DESTINATION bin
)

set(CPACK_PACKAGE_NAME "VoidOne")
set(CPACK_PACKAGE_VENDOR "VoidOne-app")
set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "VoidOne Ultimate Enterprise Game Launcher")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")

if(WIN32 AND VOIDONE_GENERATE_INSTALLER)
    set(CPACK_GENERATOR "NSIS")
    set(CPACK_NSIS_DISPLAY_NAME "VoidOne Enterprise Platform")
    set(CPACK_NSIS_COMPRESSOR "/SOLID lzma")
    set(CPACK_NSIS_CONTACT "admin@voidone-app.com")
    set(CPACK_NSIS_CREATE_ICONS_EXTRA "CreateShortCut '$SMPROGRAMS\\\\$STARTMENU_FOLDER\\\\VoidOne.lnk' '$INSTDIR\\\\bin\\\\VoidOne.exe'")
    set(CPACK_NSIS_MUI_FINISHPAGE_RUN "$INSTDIR\\\\bin\\\\VoidOne.exe")
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/assets/installer.ico")
        set(CPACK_NSIS_MUI_ICON "${CMAKE_CURRENT_SOURCE_DIR}/assets/installer.ico")
    endif()
elseif(UNIX AND NOT APPLE)
    set(CPACK_GENERATOR "DEB;RPM")
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER "admin@voidone-app.com")
endif()

include(CPack)
