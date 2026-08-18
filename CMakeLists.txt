cmake_minimum_required(VERSION 3.21)

project(NeonLauncher
    VERSION 1.0.2
    DESCRIPTION "A modern Qt6 C++ Game Launcher"
    LANGUAGES CXX
)

# ============================================================================
# Project configuration
# ============================================================================

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

include(GNUInstallDirs)

# ============================================================================
# Build options
# ============================================================================

option(NEONLAUNCHER_BUILD_TESTS
    "Build NeonLauncher unit tests"
    OFF
)

option(NEONLAUNCHER_ENABLE_WARNINGS
    "Enable compiler warnings"
    ON
)

option(NEONLAUNCHER_ENABLE_LTO
    "Enable link-time optimization for Release builds"
    OFF
)

# ============================================================================
# Qt
# ============================================================================

find_package(Qt6 6.8 REQUIRED COMPONENTS
    Core
    Gui
    Qml
    Quick
    Sql
)

qt_standard_project_setup(
    REQUIRES 6.8
)

# ============================================================================
# Sources
# ============================================================================

set(PROJECT_SOURCES

    src/main.cpp

    # Core
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

# ============================================================================
# QML
# ============================================================================

set(QML_FILES

    src/ui/qml/Main.qml
    src/ui/qml/GameCard.qml
    src/ui/qml/Sidebar.qml
    src/ui/qml/SaveBackupView.qml
)

# ============================================================================
# Windows application icon
# ============================================================================

if(WIN32)

    set(APP_ICON_FILE
        "${CMAKE_CURRENT_SOURCE_DIR}/assets/icon.ico"
    )

    if(EXISTS "${APP_ICON_FILE}")

        set(APP_ICON_RESOURCE
            "${CMAKE_CURRENT_BINARY_DIR}/NeonLauncherApp.rc"
        )

        file(WRITE
            "${APP_ICON_RESOURCE}"
            "IDI_ICON1 ICON DISCARDABLE \"${APP_ICON_FILE}\"\n"
        )

        list(APPEND
            PROJECT_SOURCES
            "${APP_ICON_RESOURCE}"
        )

    endif()

endif()

# ============================================================================
# Executable
# ============================================================================

qt_add_executable(
    NeonLauncherApp
    ${PROJECT_SOURCES}
)

# ============================================================================
# QML module
# ============================================================================

qt_add_qml_module(
    NeonLauncherApp

    URI NeonLauncher
    VERSION 1.0

    QML_FILES
        ${QML_FILES}
)

# ============================================================================
# Include directories
# ============================================================================

target_include_directories(
    NeonLauncherApp

    PRIVATE
        "${CMAKE_CURRENT_SOURCE_DIR}/src"
        "${CMAKE_CURRENT_SOURCE_DIR}/src/core"
)

# ============================================================================
# Compile definitions
# ============================================================================

target_compile_definitions(
    NeonLauncherApp

    PRIVATE
        PROJECT_NAME="${PROJECT_NAME}"
        PROJECT_VERSION="${PROJECT_VERSION}"
)

# ============================================================================
# Qt libraries
# ============================================================================

target_link_libraries(
    NeonLauncherApp

    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        Qt6::Sql
)

# ============================================================================
# Compiler configuration
# ============================================================================

if(NEONLAUNCHER_ENABLE_WARNINGS)

    if(MSVC)

        target_compile_options(
            NeonLauncherApp

            PRIVATE
                /W4
                /permissive-
                /Zc:__cplusplus
                /utf-8
        )

    elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")

        target_compile_options(
            NeonLauncherApp

            PRIVATE
                -Wall
                -Wextra
                -Wpedantic
        )

    endif()

endif()

# ============================================================================
# MSVC configuration
# ============================================================================

if(MSVC)

    target_compile_definitions(
        NeonLauncherApp

        PRIVATE
            UNICODE
            _UNICODE
            NOMINMAX
            WIN32_LEAN_AND_MEAN
            _SILENCE_STDEXT_ARR_IT_DEPRECATION_WARNINGS
    )

endif()

# ============================================================================
# Link-time optimization
# ============================================================================

if(NEONLAUNCHER_ENABLE_LTO)

    include(CheckIPOSupported)

    check_ipo_supported(
        RESULT LTO_SUPPORTED
        OUTPUT LTO_ERROR
    )

    if(LTO_SUPPORTED)

        set_property(
            TARGET NeonLauncherApp
            PROPERTY INTERPROCEDURAL_OPTIMIZATION_RELEASE TRUE
        )

        message(STATUS
            "NeonLauncher: LTO enabled"
        )

    else()

        message(WARNING
            "NeonLauncher: LTO requested but not supported: ${LTO_ERROR}"
        )

    endif()

endif()

# ============================================================================
# Target properties
# ============================================================================

set_target_properties(
    NeonLauncherApp

    PROPERTIES

        OUTPUT_NAME
            "NeonLauncherApp"

        VERSION
            "${PROJECT_VERSION}"

        DESCRIPTION
            "${PROJECT_DESCRIPTION}"

        CXX_EXTENSIONS
            OFF

        DEBUG_POSTFIX
            "d"
)

# ============================================================================
# Windows GUI subsystem
# ============================================================================

if(WIN32)

    set_target_properties(
        NeonLauncherApp

        PROPERTIES
            WIN32_EXECUTABLE TRUE
    )

endif()

# ============================================================================
# Installation
# ============================================================================

install(
    TARGETS NeonLauncherApp

    BUNDLE
        DESTINATION .

    RUNTIME
        DESTINATION "${CMAKE_INSTALL_BINDIR}"

    LIBRARY
        DESTINATION "${CMAKE_INSTALL_LIBDIR}"

    ARCHIVE
        DESTINATION "${CMAKE_INSTALL_LIBDIR}"
)

# ============================================================================
# Optional tests
# ============================================================================

if(NEONLAUNCHER_BUILD_TESTS)

    enable_testing()

    message(STATUS
        "NeonLauncher: test support enabled"
    )

endif()

# ============================================================================
# Configuration summary
# ============================================================================

message(STATUS "")
message(STATUS "================================================")
message(STATUS "             NeonLauncher Configuration")
message(STATUS "================================================")
message(STATUS "Version:       ${PROJECT_VERSION}")
message(STATUS "C++ Standard:  C++${CMAKE_CXX_STANDARD}")
message(STATUS "Compiler:      ${CMAKE_CXX_COMPILER_ID}")
message(STATUS "Compiler Ver:  ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "Qt Version:    ${Qt6_VERSION}")
message(STATUS "System:        ${CMAKE_SYSTEM_NAME}")
message(STATUS "Generator:     ${CMAKE_GENERATOR}")
message(STATUS "Build Type:    ${CMAKE_BUILD_TYPE}")
message(STATUS "Tests:         ${NEONLAUNCHER_BUILD_TESTS}")
message(STATUS "Warnings:      ${NEONLAUNCHER_ENABLE_WARNINGS}")
message(STATUS "LTO:           ${NEONLAUNCHER_ENABLE_LTO}")
message(STATUS "================================================")
message(STATUS "NeonLauncher configuration complete.")
message(STATUS "")
