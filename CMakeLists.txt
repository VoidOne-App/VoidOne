cmake_minimum_required(VERSION 3.25)

# ============================================================================
# 🌌 VOIDONE - ULTIMATE ENTERPRISE BUILD SYSTEM 🌌
# ============================================================================

message(STATUS "
    ██╗   ██╗ ██████╗ ██╗██████╗  ██████╗ ███╗   ██╗███████╗
    ██║   ██║██╔═══██╗██║██╔══██╗██╔═══██╗████╗  ██║██╔════╝
    ██║   ██║██║   ██║██║██║  ██║██║   ██║██╔██╗ ██║█████╗  
    ╚██╗ ██╔╝██║   ██║██║██║  ██║██║   ██║██║╚██╗██║██╔══╝  
     ╚████╔╝ ╚██████╔╝██║██████╔╝╚██████╔╝██║ ╚████║███████╗
      ╚═══╝   ╚═════╝ ╚═╝╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝
    :: VOIDONE-APP ENTERPRISE LAUNCHER BUILD ENGINE ::
")

project(VoidOne
    VERSION 1.0.0
    DESCRIPTION "Ultimate Qt6/C++ Game Launcher & Platform"
    HOMEPAGE_URL "https://github.com/VoidOne-app/VoidOne"
    LANGUAGES CXX C
)

# ============================================================================
# 0. Qt Standard Setup (باید بلافاصله پس از دستور project بیاید - استاندارد Qt6)
# ============================================================================
find_package(Qt6 6.8 REQUIRED COMPONENTS Core Gui Quick Sql Network QuickControls2 LinguistTools)
qt_standard_project_setup(REQUIRES 6.5)

# ============================================================================
# 1. Package Management (VCPKG)
# ============================================================================
if(DEFINED ENV{VCPKG_ROOT} AND NOT CMAKE_TOOLCHAIN_FILE)
    set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake" CACHE STRING "Vcpkg toolchain" FORCE)
    message(STATUS "💼 Enterprise: Vcpkg Package Manager Activated.")
endif()

# ============================================================================
# 2. Global Compiler Settings
# ============================================================================
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# ============================================================================
# 3. Enterprise Features (Static Analysis, CI/CD Readiness)
# ============================================================================
option(VOIDONE_ENABLE_CODE_SIGNING  "Sign binaries for Windows (Authenticode)" ON)
option(VOIDONE_ENABLE_CPPCHECK      "Run cppcheck static analysis"             ON)
option(VOIDONE_GENERATE_INSTALLER   "Generate NSIS Installer (Windows)"        ON)

# --- Cppcheck (Static Analysis) ---
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
        message(STATUS "🛡️ Enterprise: Cppcheck Static Analysis Enabled.")
    endif()
endif()

# ============================================================================
# 4. Auto-Formatting (Code Consistency)
# ============================================================================
find_program(CLANG_FORMAT_EXE NAMES clang-format)
if(CLANG_FORMAT_EXE)
    add_custom_target(format
        COMMAND "${CLANG_FORMAT_EXE}" -i -style=file
        "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp" 
        "${CMAKE_CURRENT_SOURCE_DIR}/src/*.h"
        COMMENT "🎨 Formatting code with clang-format..."
    )
endif()

# ============================================================================
# 5. Core Library (voidone_core)
# ============================================================================
add_library(voidone_core STATIC
    src/core/LaunchEngine.cpp src/core/LaunchEngine.h
    src/core/AuthManager.cpp src/core/AuthManager.h
    src/core/PatchManager.cpp src/core/PatchManager.h
)

target_link_libraries(voidone_core PUBLIC 
    Qt6::Core 
    Qt6::Sql 
    Qt6::Network
)

# استفاده از Generator Expressions برای استانداردسازی اینکلودهای بیلد و نصب
target_include_directories(voidone_core PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src/core>
    $<INSTALL_INTERFACE:include>
)

# بهینه‌سازی سرعت بیلد با Precompiled Headers
target_precompile_headers(voidone_core PRIVATE
    <QObject> 
    <QString> 
    <QVariant> 
    <QNetworkAccessManager> 
    <memory> 
    <thread>
)

# ============================================================================
# 6. Enterprise Localization (i18n)
# ============================================================================
set(TS_FILES 
    translations/voidone_fa_IR.ts
    translations/voidone_en_US.ts
)

qt_add_translations(VoidOne_Translations
    TS_FILES ${TS_FILES}
    QM_FILES_OUTPUT_VARIABLE QM_FILES
)

# ============================================================================
# 7. Main Executable & QML Module (VoidOne)
# ============================================================================
qt_add_executable(VoidOne 
    src/main.cpp
    ${QM_FILES} # لینک شدن فایل‌های ترجمه باینری
)

qt_add_qml_module(VoidOne
    URI VoidOneApp
    VERSION 1.0
    QML_FILES
        src/ui/qml/Dashboard.qml
        src/ui/qml/LibraryView.qml
        src/ui/qml/Settings.qml
)

target_link_libraries(VoidOne PRIVATE 
    voidone_core 
    VoidOne_Translations 
    Qt6::Gui 
    Qt6::Quick 
    Qt6::QuickControls2
)

if(WIN32)
    # مخفی کردن کنسول دیباگ در خروجی نهایی ویندوز
    set_target_properties(VoidOne PROPERTIES WIN32_EXECUTABLE TRUE)
endif()

# ============================================================================
# 8. Auto-Deployment (جمع‌آوری خودکار دیپلوی Qt با windeployqt)
# ============================================================================
if(WIN32)
    # تلاش برای یافتن پوشه bin کیوت به صورت خودکار از طریق تارجت‌های کیوت
    if(TARGET Qt6::core)
        get_target_property(_qt_bin_dir Qt6::core LOCATION)
        if(_qt_bin_dir)
            get_filename_component(_qt_bin_dir "${_qt_bin_dir}" DIRECTORY)
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
            COMMENT "📦 Auto-deploying VoidOne Qt dependencies..."
        )
    endif()
endif()

# ============================================================================
# 9. Code Signing (امضای دیجیتال اپلیکیشن - سازگار با محیط لوکال و CI/CD)
# ============================================================================
if(WIN32 AND VOIDONE_ENABLE_CODE_SIGNING)
    find_program(SIGNTOOL_EXECUTABLE signtool)
    if(SIGNTOOL_EXECUTABLE)
        # پشتیبانی از متغیرهای محیطی برای امنیت بیشتر در گیت‌هاب اکشنز یا سیستم‌های بیلد
        if(DEFINED ENV{VOIDONE_SIGN_CERT_PATH} AND DEFINED ENV{VOIDONE_SIGN_PASSWORD})
            set(_CERT_PATH "$ENV{VOIDONE_SIGN_CERT_PATH}")
            set(_CERT_PWD "$ENV{VOIDONE_SIGN_PASSWORD}")
        else()
            set(_CERT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cert.pfx")
            set(_CERT_PWD "YOUR_PASSWORD")
        endif()

        add_custom_command(TARGET VoidOne POST_BUILD
            COMMAND "${SIGNTOOL_EXECUTABLE}" sign 
                /f "${_CERT_PATH}" 
                /p "${_CERT_PWD}" 
                /fd sha256 
                /tr http://timestamp.digicert.com 
                /td sha256 
                "$<TARGET_FILE:VoidOne>"
            COMMENT "🔐 Signing VoidOne executable for SmartScreen bypass..."
            VERBATIM
        )
    endif()
endif()

# ============================================================================
# 10. Professional Installer Generation (CPack & NSIS / DEB / RPM)
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
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "VoidOne Ultimate Game Launcher")

if(WIN32 AND VOIDONE_GENERATE_INSTALLER)
    set(CPACK_GENERATOR "NSIS")
    set(CPACK_NSIS_DISPLAY_NAME "VoidOne")
    set(CPACK_NSIS_COMPRESSOR "/SOLID lzma")
    set(CPACK_NSIS_CREATE_ICONS_EXTRA "CreateShortCut '$SMPROGRAMS\\\\$STARTMENU_FOLDER\\\\VoidOne.lnk' '$INSTDIR\\\\bin\\\\VoidOne.exe'")
    set(CPACK_NSIS_MUI_FINISHPAGE_RUN "$INSTDIR\\\\bin\\\\VoidOne.exe")
    set(CPACK_NSIS_MUI_ICON "${CMAKE_CURRENT_SOURCE_DIR}/assets/installer.ico")
elseif(UNIX AND NOT APPLE)
    set(CPACK_GENERATOR "DEB;RPM")
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER "admin@voidone-app.com")
endif()

include(CPack)
