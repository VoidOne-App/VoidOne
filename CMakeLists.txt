cmake_minimum_required(VERSION 3.21)

# ==============================================================================
# NeonLauncher
# ==============================================================================

project(NeonLauncher
    VERSION 1.0.2
    DESCRIPTION "A modern Qt6 C++ Game Launcher"
    LANGUAGES CXX
)

# ==============================================================================
# C++ Configuration
# ==============================================================================

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Qt automatic tools
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# ==============================================================================
# Output Directories
# ==============================================================================

include(GNUInstallDirs)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY
    "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}"
)

foreach(CONFIG Debug Release RelWithDebInfo MinSizeRel)
    string(TOUPPER "${CONFIG}" CONFIG_UPPER)

    set(
        CMAKE_RUNTIME_OUTPUT_DIRECTORY_${CONFIG_UPPER}
        "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}/${CONFIG}"
    )
endforeach()

# ==============================================================================
# Compiler Configuration
# ==============================================================================

if(MSVC)

    add_compile_definitions(
        UNICODE
        _UNICODE
        NOMINMAX
        WIN32_LEAN_AND_MEAN
        _SILENCE_STDEXT_ARR_IT_DEPRECATION_WARNINGS
    )

    add_compile_options(
        /W4
        /Zc:__cplusplus
    )

    add_compile_options(
        "$<$<CONFIG:Release>:/O2>"
        "$<$<CONFIG:Release>:/Ob2>"
        "$<$<CONFIG:Release>:/Oi>"
    )

else()

    add_compile_options(
        -Wall
        -Wextra
        -Wpedantic
    )

    add_compile_options(
        "$<$<CONFIG:Release>:-O3>"
    )

endif()

# ==============================================================================
# IPO / LTO
# ==============================================================================

include(CheckIPOSupported)

check_ipo_supported(
    RESULT IPO_SUPPORTED
    OUTPUT IPO_ERROR
)

if(IPO_SUPPORTED)

    message(STATUS
        "NeonLauncher: IPO/LTO supported."
    )

else()

    message(STATUS
        "NeonLauncher: IPO/LTO not supported."
    )

    if(IPO_ERROR)
        message(STATUS
            "IPO check: ${IPO_ERROR}"
        )
    endif()

endif()

# ==============================================================================
# Qt
# ==============================================================================

find_package(Qt6 REQUIRED COMPONENTS
    Core
    Gui
    Quick
    Sql
)

# ==============================================================================
# Project Sources
# ==============================================================================

set(PROJECT_SOURCES

    src/main.cpp

    src/core/Database.cpp
    src/core/Database.h

    src/core/SteamScanner.cpp
    src/core/SteamScanner.h

    src/core/GameModel.cpp
    src/core/GameModel.h

    src/core/TranslationManager.cpp
    src/core/TranslationManager.h

    src/core/SaveBackupManager.cpp
    src/core/SaveBackupManager.h
)

# ==============================================================================
# QML Sources
# ==============================================================================

set(QML_FILES

    src/ui/qml/Main.qml
    src/ui/qml/GameCard.qml
    src/ui/qml/Sidebar.qml
    src/ui/qml/SaveBackupView.qml
)

# ==============================================================================
# Windows Application Icon
# ==============================================================================

if(
    WIN32
    AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/assets/icon.ico"
)

    set(APP_ICON_RESOURCE
        "${CMAKE_CURRENT_BINARY_DIR}/app_icon.rc"
    )

    file(
        WRITE
        "${APP_ICON_RESOURCE}"
        "IDI_ICON1 ICON DISCARDABLE \"${CMAKE_CURRENT_SOURCE_DIR}/assets/icon.ico\"\n"
    )

    list(
        APPEND
        PROJECT_SOURCES
        "${APP_ICON_RESOURCE}"
    )

endif()

# ==============================================================================
# Executable
# ==============================================================================

qt_add_executable(
    NeonLauncherApp
    ${PROJECT_SOURCES}
)

# ==============================================================================
# QML Module
# ==============================================================================

qt_add_qml_module(
    NeonLauncherApp

    URI NeonLauncher

    VERSION 1.0

    QML_FILES
        ${QML_FILES}
)

# ==============================================================================
# Include Directories
# ==============================================================================

target_include_directories(
    NeonLauncherApp
    PRIVATE

    "${CMAKE_CURRENT_SOURCE_DIR}/src"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/core"
)

# ==============================================================================
# Compile Definitions
# ==============================================================================

target_compile_definitions(
    NeonLauncherApp
    PRIVATE

    PROJECT_VERSION="${PROJECT_VERSION}"
    PROJECT_NAME="${PROJECT_NAME}"
)

# ==============================================================================
# Qt Libraries
# ==============================================================================

target_link_libraries(
    NeonLauncherApp
    PRIVATE

    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::Sql
)

# ==============================================================================
# IPO / LTO Target Configuration
# ==============================================================================

if(IPO_SUPPORTED)

    set_property(
        TARGET NeonLauncherApp
        PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE
    )

endif()

# ==============================================================================
# Windows Configuration
# ==============================================================================

if(WIN32)

    set_target_properties(
        NeonLauncherApp
        PROPERTIES

        WIN32_EXECUTABLE
            $<$<CONFIG:Release>:TRUE>

        VS_DEBUGGER_WORKING_DIRECTORY
            "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"
    )

endif()

# ==============================================================================
# Target Metadata
# ==============================================================================

set_target_properties(
    NeonLauncherApp
    PROPERTIES

    OUTPUT_NAME
        "NeonLauncherApp"

    VERSION
        "${PROJECT_VERSION}"

    DESCRIPTION
        "${PROJECT_DESCRIPTION}"
)

# ==============================================================================
# Installation
# ==============================================================================

install(
    TARGETS NeonLauncherApp

    BUNDLE DESTINATION .

    RUNTIME DESTINATION
        "${CMAKE_INSTALL_BINDIR}"
)

# ==============================================================================
# Configuration Summary
# ==============================================================================

message(STATUS "")
message(STATUS "========================================")
message(STATUS "       NeonLauncher Configuration")
message(STATUS "========================================")
message(STATUS "Version:      ${PROJECT_VERSION}")
message(STATUS "C++:          C++${CMAKE_CXX_STANDARD}")
message(STATUS "Build type:   ${CMAKE_BUILD_TYPE}")
message(STATUS "Compiler:     ${CMAKE_CXX_COMPILER_ID}")
message(STATUS "Compiler ver: ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "Qt version:   ${Qt6_VERSION}")
message(STATUS "System:       ${CMAKE_SYSTEM_NAME}")
message(STATUS "Architecture: ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "IPO/LTO:      ${IPO_SUPPORTED}")
message(STATUS "========================================")
message(STATUS "")
message(STATUS "NeonLauncher configuration complete.")
message(STATUS "")set(CMAKE_RUNTIME_OUTPUT_DIRECTORY
    "${CMAKE_BINARY_DIR}/bin"
)

# Multi-config generators: Visual Studio
foreach(CONFIG Debug Release RelWithDebInfo MinSizeRel)
    string(TOUPPER "${CONFIG}" CONFIG_UPPER)

    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${CONFIG_UPPER}
        "${CMAKE_BINARY_DIR}/bin/${CONFIG}"
    )
endforeach()

# ==============================================================================
# Compiler Configuration
# ==============================================================================

if(MSVC)

    add_compile_definitions(
        UNICODE
        _UNICODE
        NOMINMAX
        WIN32_LEAN_AND_MEAN
        _SILENCE_STDEXT_ARR_IT_DEPRECATION_WARNINGS
    )

    add_compile_options(
        /W4
        /Zc:__cplusplus
    )

    # Release optimization
    add_compile_options(
        "$<$<CONFIG:Release>:/O2>"
        "$<$<CONFIG:Release>:/Ob2>"
        "$<$<CONFIG:Release>:/Oi>"
    )

else()

    add_compile_options(
        -Wall
        -Wextra
        -Wpedantic
    )

    # Release optimization
    add_compile_options(
        "$<$<CONFIG:Release>:-O3>"
    )

endif()

# ==============================================================================
# IPO / LTO
# ==============================================================================

include(CheckIPOSupported)

check_ipo_supported(
    RESULT IPO_SUPPORTED
    OUTPUT IPO_ERROR
)

if(IPO_SUPPORTED)

    message(STATUS "NeonLauncher: IPO/LTO supported")

else()

    message(STATUS "NeonLauncher: IPO/LTO not supported")

    if(IPO_ERROR)
        message(STATUS "IPO reason: ${IPO_ERROR}")
    endif()

endif()

# ==============================================================================
# Qt6
# ==============================================================================

find_package(Qt6 REQUIRED COMPONENTS
    Core
    Gui
    Quick
    Sql
)

# ==============================================================================
# Source Files
# ==============================================================================

set(PROJECT_SOURCES

    src/main.cpp

    src/core/Database.cpp
    src/core/Database.h

    src/core/SteamScanner.cpp
    src/core/SteamScanner.h

    src/core/GameModel.cpp
    src/core/GameModel.h

    src/core/TranslationManager.cpp
    src/core/TranslationManager.h

    src/core/SaveBackupManager.cpp
    src/core/SaveBackupManager.h
)

# ==============================================================================
# QML
# ==============================================================================

set(QML_FILES

    src/ui/qml/Main.qml
    src/ui/qml/GameCard.qml
    src/ui/qml/Sidebar.qml
    src/ui/qml/SaveBackupView.qml
)

# ==============================================================================
# Windows Application Icon
# ==============================================================================

if(WIN32 AND EXISTS
    "${CMAKE_CURRENT_SOURCE_DIR}/assets/icon.ico"
)

    set(APP_ICON_RESOURCE
        "${CMAKE_CURRENT_BINARY_DIR}/app_icon.rc"
    )

    file(
        WRITE
        "${APP_ICON_RESOURCE}"
        "IDI_ICON1 ICON DISCARDABLE \"${CMAKE_CURRENT_SOURCE_DIR}/assets/icon.ico\"\n"
    )

    list(
        APPEND
        PROJECT_SOURCES
        "${APP_ICON_RESOURCE}"
    )

endif()

# ==============================================================================
# Executable
# ==============================================================================

qt_add_executable(
    NeonLauncherApp
    ${PROJECT_SOURCES}
)

# ==============================================================================
# QML Module
# ==============================================================================

qt_add_qml_module(
    NeonLauncherApp

    URI NeonLauncher

    VERSION 1.0

    QML_FILES
        ${QML_FILES}
)

# ==============================================================================
# Include Directories
# ==============================================================================

target_include_directories(
    NeonLauncherApp
    PRIVATE

    "${CMAKE_CURRENT_SOURCE_DIR}/src"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/core"
)

# ==============================================================================
# Compile Definitions
# ==============================================================================

target_compile_definitions(
    NeonLauncherApp
    PRIVATE

    PROJECT_VERSION="${PROJECT_VERSION}"
    PROJECT_NAME="${PROJECT_NAME}"
)

# ==============================================================================
# Qt Libraries
# ==============================================================================

target_link_libraries(
    NeonLauncherApp
    PRIVATE

    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::Sql
)

# ==============================================================================
# IPO / LTO
# ==============================================================================

if(IPO_SUPPORTED)

    set_property(
        TARGET NeonLauncherApp
        PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE
    )

endif()

# ==============================================================================
# Windows
# ==============================================================================

if(WIN32)

    set_target_properties(
        NeonLauncherApp
        PROPERTIES

        OUTPUT_NAME "NeonLauncherApp"

        WIN32_EXECUTABLE
            $<$<CONFIG:Release>:TRUE>

        VS_DEBUGGER_WORKING_DIRECTORY
            "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"
    )

else()

    set_target_properties(
        NeonLauncherApp
        PROPERTIES

        OUTPUT_NAME "NeonLauncherApp"
    )

endif()

# ==============================================================================
# Target Metadata
# ==============================================================================

set_target_properties(
    NeonLauncherApp
    PROPERTIES

    VERSION
        ${PROJECT_VERSION}

    DESCRIPTION
        "${PROJECT_DESCRIPTION}"
)

# ==============================================================================
# Installation
# ==============================================================================

install(
    TARGETS NeonLauncherApp

    BUNDLE DESTINATION .

    RUNTIME DESTINATION
        ${CMAKE_INSTALL_BINDIR}
)

# ==============================================================================
# Configuration Summary
# ==============================================================================

message(STATUS "")
message(STATUS "==============================================")
message(STATUS "          NeonLauncher Configuration")
message(STATUS "==============================================")
message(STATUS "Project:       ${PROJECT_NAME}")
message(STATUS "Version:       ${PROJECT_VERSION}")
message(STATUS "Description:   ${PROJECT_DESCRIPTION}")
message(STATUS "C++ Standard:  C++${CMAKE_CXX_STANDARD}")
message(STATUS "Compiler:      ${CMAKE_CXX_COMPILER_ID}")
message(STATUS "Compiler Ver:  ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "Qt Version:    ${Qt6_VERSION}")
message(STATUS "System:        ${CMAKE_SYSTEM_NAME}")
message(STATUS "Architecture:  ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "Generator:     ${CMAKE_GENERATOR}")
message(STATUS "IPO/LTO:       ${IPO_SUPPORTED}")
message(STATUS "==============================================")
message(STATUS "")
message(STATUS "NeonLauncher configuration complete.")
message(STATUS "")# Multi-config generators (Visual Studio)
foreach(CONFIG Debug Release RelWithDebInfo MinSizeRel)
    string(TOUPPER "${CONFIG}" CONFIG_UPPER)

    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${CONFIG_UPPER}
        "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}/${CONFIG}"
    )
endforeach()

# ==============================================================================
# Compiler Configuration
# ==============================================================================

if(MSVC)

    add_compile_definitions(
        UNICODE
        _UNICODE
        NOMINMAX
        WIN32_LEAN_AND_MEAN

        _SILENCE_STDEXT_ARR_IT_DEPRECATION_WARNINGS
    )

    add_compile_options(
        /W4
        /Zc:__cplusplus
    )

    # Release optimization
    add_compile_options(
        "$<$<CONFIG:Release>:/O2>"
        "$<$<CONFIG:Release>:/Ob2>"
        "$<$<CONFIG:Release>:/Oi>"
    )

else()

    add_compile_options(
        -Wall
        -Wextra
        -Wpedantic
    )

    # Release optimization
    add_compile_options(
        "$<$<CONFIG:Release>:-O3>"
    )

endif()

# ==============================================================================
# Link-Time Optimization
# ==============================================================================

include(CheckIPOSupported)

check_ipo_supported(
    RESULT IPO_SUPPORTED
    OUTPUT IPO_ERROR
)

if(IPO_SUPPORTED)

    message(STATUS
        "NeonLauncher: IPO/LTO is supported."
    )

else()

    message(STATUS
        "NeonLauncher: IPO/LTO is not supported."
    )

    if(IPO_ERROR)
        message(STATUS
            "IPO check: ${IPO_ERROR}"
        )
    endif()

endif()

# ==============================================================================
# Qt
# ==============================================================================

find_package(Qt6 REQUIRED COMPONENTS
    Core
    Gui
    Quick
    Sql
)

message(STATUS "========================================")
message(STATUS "NeonLauncher Configuration")
message(STATUS "========================================")
message(STATUS "Version:      ${PROJECT_VERSION}")
message(STATUS "C++:          ${CMAKE_CXX_STANDARD}")
message(STATUS "Build type:   ${CMAKE_BUILD_TYPE}")
message(STATUS "Compiler:     ${CMAKE_CXX_COMPILER_ID}")
message(STATUS "Compiler ver: ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "Qt version:   ${Qt6_VERSION}")
message(STATUS "System:       ${CMAKE_SYSTEM_NAME}")
message(STATUS "Architecture: ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "========================================")

# ==============================================================================
# Source Files
# ==============================================================================

set(PROJECT_SOURCES

    src/main.cpp

    src/core/Database.cpp
    src/core/Database.h

    src/core/SteamScanner.cpp
    src/core/SteamScanner.h

    src/core/GameModel.cpp
    src/core/GameModel.h

    src/core/TranslationManager.cpp
    src/core/TranslationManager.h

    src/core/SaveBackupManager.cpp
    src/core/SaveBackupManager.h
)

# ==============================================================================
# QML Files
# ==============================================================================

set(QML_FILES

    src/ui/qml/Main.qml
    src/ui/qml/GameCard.qml
    src/ui/qml/Sidebar.qml
    src/ui/qml/SaveBackupView.qml
)

# ==============================================================================
# Windows Application Icon
# ==============================================================================

if(WIN32 AND EXISTS
    "${CMAKE_CURRENT_SOURCE_DIR}/assets/icon.ico"
)

    set(APP_ICON_RESOURCE
        "${CMAKE_CURRENT_BINARY_DIR}/app_icon.rc"
    )

    file(
        WRITE
        "${APP_ICON_RESOURCE}"
        "IDI_ICON1 ICON DISCARDABLE \"${CMAKE_CURRENT_SOURCE_DIR}/assets/icon.ico\"\n"
    )

    list(
        APPEND
        PROJECT_SOURCES
        "${APP_ICON_RESOURCE}"
    )

endif()

# ==============================================================================
# Executable
# ==============================================================================

qt_add_executable(
    NeonLauncherApp
    ${PROJECT_SOURCES}
)

# ==============================================================================
# QML Module
# ==============================================================================

qt_add_qml_module(
    NeonLauncherApp

    URI NeonLauncher

    VERSION 1.0

    QML_FILES
        ${QML_FILES}
)

# ==============================================================================
# Include Directories
# ==============================================================================

target_include_directories(
    NeonLauncherApp
    PRIVATE

    "${CMAKE_CURRENT_SOURCE_DIR}/src"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/core"
)

# ==============================================================================
# Compile Definitions
# ==============================================================================

target_compile_definitions(
    NeonLauncherApp
    PRIVATE

    PROJECT_VERSION="${PROJECT_VERSION}"
    PROJECT_NAME="${PROJECT_NAME}"
)

# ==============================================================================
# Qt Libraries
# ==============================================================================

target_link_libraries(
    NeonLauncherApp
    PRIVATE

    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::Sql
)

# ==============================================================================
# IPO / LTO
# ==============================================================================

if(IPO_SUPPORTED)

    set_property(
        TARGET NeonLauncherApp
        PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE
    )

endif()

# ==============================================================================
# Windows Configuration
# ==============================================================================

if(WIN32)

    set_target_properties(
        NeonLauncherApp
        PROPERTIES

        WIN32_EXECUTABLE
            $<$<CONFIG:Release>:TRUE>

        VS_DEBUGGER_WORKING_DIRECTORY
            "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"
    )

endif()

# ==============================================================================
# Target Properties
# ==============================================================================

set_target_properties(
    NeonLauncherApp
    PROPERTIES

    OUTPUT_NAME "NeonLauncherApp"

    VERSION
        ${PROJECT_VERSION}

    DESCRIPTION
        "${PROJECT_DESCRIPTION}"
)

# ==============================================================================
# Installation
# ==============================================================================

install(
    TARGETS NeonLauncherApp

    BUNDLE DESTINATION .

    RUNTIME DESTINATION
        ${CMAKE_INSTALL_BINDIR}
)

# ==============================================================================
# Build Summary
# ==============================================================================

message(STATUS "")
message(STATUS "NeonLauncher build configuration complete.")
message(STATUS "Executable: NeonLauncherApp")
message(STATUS "Qt: ${Qt6_VERSION}")
message(STATUS "C++: C++${CMAKE_CXX_STANDARD}")
message(STATUS "")include(CheckIPOSupported)
check_ipo_supported(RESULT lto_supported)
if(lto_supported)
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
    message(STATUS "LTO/IPO is ENABLED - Max performance mode active!")
endif()

# ==============================================================================
# Compiler Optimization Flags
# ==============================================================================
if(MSVC)
    add_compile_definitions(
        _SILENCE_STDEXT_ARR_IT_DEPRECATION_WARNINGS
        UNICODE
        _UNICODE
        NOMINMAX
        WIN32_LEAN_AND_MEAN
    )
    # تنظیمات پایه ویندوز
    add_compile_options(/Zc:__cplusplus /W4)
    # فشردن پدال گاز در حالت Release (حداکثر بهینه‌سازی سرعت و پردازش ریاضی سریع)
    add_compile_options("$<$<CONFIG:Release>:/O2;/Ob2;/Oi;/Ot;/fp:fast>")
else()
    add_compile_options(-Wall -Wextra -Wpedantic)
    # فشردن پدال گاز در لینوکس: استفاده از تمام توان پردازنده میزبان
    add_compile_options("$<$<CONFIG:Release>:-O3;-march=native;-ffast-math>")
endif()

# ==============================================================================
# Dependencies (Qt6)
# ==============================================================================
find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Sql)

# ==============================================================================
# Source Files Definition
# ==============================================================================
set(PROJECT_SOURCES
    src/main.cpp
    src/core/Database.cpp
    src/core/Database.h
    src/core/SteamScanner.cpp
    src/core/SteamScanner.h
    src/core/GameModel.cpp
    src/core/GameModel.h
    src/core/TranslationManager.cpp
    src/core/TranslationManager.h
    src/core/SaveBackupManager.cpp
    src/core/SaveBackupManager.h
)

set(QML_FILES
    src/ui/qml/Main.qml
    src/ui/qml/GameCard.qml
    src/ui/qml/Sidebar.qml
    src/ui/qml/SaveBackupView.qml
)

# ساخت فایل ریسورس آیکون برای ویندوز در صورت وجود فایل icon.ico
if(WIN32 AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/assets/icon.ico")
    set(APP_ICON_RESOURCE "${CMAKE_CURRENT_BINARY_DIR}/app_icon.rc")
    file(WRITE "${APP_ICON_RESOURCE}" "IDI_ICON1 ICON DISCARDABLE \"${CMAKE_CURRENT_SOURCE_DIR}/assets/icon.ico\"\n")
    list(APPEND PROJECT_SOURCES "${APP_ICON_RESOURCE}")
endif()

# ==============================================================================
# Target Construction & QML Module
# ==============================================================================
qt_add_executable(NeonLauncherApp
    ${PROJECT_SOURCES}
)

# این دستور با کمک Qt Quick Compiler فایل‌های QML را مستقیماً به کد ماشین تبدیل می‌کند
qt_add_qml_module(NeonLauncherApp
    URI NeonLauncher
    VERSION 1.0
    QML_FILES ${QML_FILES}
)

target_include_directories(NeonLauncherApp PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/src/core
)

# تزریق نسخه پروژه به کد C++
target_compile_definitions(NeonLauncherApp PRIVATE
    PROJECT_VERSION="${PROJECT_VERSION}"
    PROJECT_NAME="${PROJECT_NAME}"
)

target_link_libraries(NeonLauncherApp PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::Sql
)

# ==============================================================================
# Platform Adjustments
# ==============================================================================
if(WIN32)
    # مخفی کردن پنجره ترمینال CMD در نسخه Release ویندوز
    set_target_properties(NeonLauncherApp PROPERTIES
        WIN32_EXECUTABLE $<IF:$<CONFIG:Release>,TRUE,FALSE>
    )
endif()

# ==============================================================================
# Installation Rules
# ==============================================================================
install(TARGETS NeonLauncherApp
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
        UNICODE
        _UNICODE
        NOMINMAX
        WIN32_LEAN_AND_MEAN
    )
    add_compile_options(/Zc:__cplusplus /W4)
else()
    add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# ==============================================================================
# Dependencies (Qt6)
# ==============================================================================
find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Sql)

# ==============================================================================
# Source Files Definition
# ==============================================================================
set(PROJECT_SOURCES
    src/main.cpp
    src/core/Database.cpp
    src/core/Database.h
    src/core/SteamScanner.cpp
    src/core/SteamScanner.h
    src/core/GameModel.cpp
    src/core/GameModel.h
    src/core/TranslationManager.cpp
    src/core/TranslationManager.h
    src/core/SaveBackupManager.cpp
    src/core/SaveBackupManager.h
)

set(QML_FILES
    src/ui/qml/Main.qml
    src/ui/qml/GameCard.qml
    src/ui/qml/Sidebar.qml
    src/ui/qml/SaveBackupView.qml
)

# ساخت فایل ریسورس آیکون برای ویندوز در صورت وجود فایل icon.ico
if(WIN32 AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/assets/icon.ico")
    set(APP_ICON_RESOURCE "${CMAKE_CURRENT_BINARY_DIR}/app_icon.rc")
    file(WRITE "${APP_ICON_RESOURCE}" "IDI_ICON1 ICON DISCARDABLE \"${CMAKE_CURRENT_SOURCE_DIR}/assets/icon.ico\"\n")
    list(APPEND PROJECT_SOURCES "${APP_ICON_RESOURCE}")
endif()

# ==============================================================================
# Target Construction & QML Module
# ==============================================================================
qt_add_executable(NeonLauncherApp
    ${PROJECT_SOURCES}
)

qt_add_qml_module(NeonLauncherApp
    URI NeonLauncher
    VERSION 1.0
    QML_FILES ${QML_FILES}
)

target_include_directories(NeonLauncherApp PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/src/core
)

# تزریق نسخه پروژه به کد C++
target_compile_definitions(NeonLauncherApp PRIVATE
    PROJECT_VERSION="${PROJECT_VERSION}"
    PROJECT_NAME="${PROJECT_NAME}"
)

target_link_libraries(NeonLauncherApp PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::Sql
)

# ==============================================================================
# Platform Adjustments
# ==============================================================================
if(WIN32)
    # مخفی کردن پنجره ترمینال CMD در نسخه Release ویندوز
    set_target_properties(NeonLauncherApp PROPERTIES
        WIN32_EXECUTABLE $<IF:$<CONFIG:Release>,TRUE,FALSE>
    )
endif()

# ==============================================================================
# Installation Rules
# ==============================================================================
install(TARGETS NeonLauncherApp
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
