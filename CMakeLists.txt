cmake_minimum_required(VERSION 3.25)

# ============================================================================
# Project Declaration
# ============================================================================

project(VoidOne
    VERSION 0.0.1
    DESCRIPTION "A modern Qt6/QML PC game launcher"
    HOMEPAGE_URL "https://github.com/VoidOne-App/VoidOne"
    LANGUAGES CXX
)

# ============================================================================
# Guard: Refuse In-Source Builds
# ============================================================================

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
    message(FATAL_ERROR
        "In-source builds are not allowed.\n"
        "Please create a separate build directory:\n"
        "    cmake -S . -B build -G Ninja"
    )
endif()

# ============================================================================
# Global C++ Configuration
# ============================================================================

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")

include(GNUInstallDirs)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "RelWithDebInfo" "MinSizeRel")
endif()

# ============================================================================
# Build Options
# ============================================================================

option(VOIDONE_BUILD_TESTS        "Build VoidOne test suite"                       OFF)
option(VOIDONE_ENABLE_CONSOLE     "Keep the console window enabled on Windows"     ON)
option(VOIDONE_WARNINGS_AS_ERRORS "Treat compiler warnings as errors"             OFF)
option(VOIDONE_ENABLE_LTO         "Enable link-time optimization in Release"       ON)
option(VOIDONE_ENABLE_SANITIZERS  "Enable ASan/UBSan in Debug builds (GCC/Clang only)" OFF)

# ============================================================================
# Version Resolution (Git-aware)
# ============================================================================

if(DEFINED VOIDONE_VERSION_OVERRIDE)
    set(VOIDONE_VERSION_DISPLAY "${VOIDONE_VERSION_OVERRIDE}")
elseif(DEFINED PROJECT_VERSION_OVERRIDE)
    set(VOIDONE_VERSION_DISPLAY "${PROJECT_VERSION_OVERRIDE}")
else()
    find_package(Git QUIET)
    if(Git_FOUND)
        execute_process(
            COMMAND ${GIT_EXECUTABLE} describe --tags --always --dirty
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            OUTPUT_VARIABLE VOIDONE_GIT_DESCRIBE
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
    endif()

    if(VOIDONE_GIT_DESCRIBE)
        set(VOIDONE_VERSION_DISPLAY "${VOIDONE_GIT_DESCRIBE}")
    else()
        set(VOIDONE_VERSION_DISPLAY "${PROJECT_VERSION}-dev")
    endif()
endif()

# ============================================================================
# Qt
# ============================================================================

find_package(Qt6 6.8 REQUIRED COMPONENTS
    Core
    Gui
    Quick
    Sql
)

# ============================================================================
# Source Files
# ============================================================================

set(VOIDONE_SOURCES
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
# QML Files
# ============================================================================

set(VOIDONE_QML_FILES
    src/ui/qml/Main.qml
    src/ui/qml/GameCard.qml
    src/ui/qml/Sidebar.qml
    src/ui/qml/SaveBackupView.qml
)

# ============================================================================
# Windows Resources: Icon + Embedded Version Info
# ============================================================================

if(WIN32)
    set(APP_ICON_PATH "${CMAKE_CURRENT_SOURCE_DIR}/app.ico")
    set(VOIDONE_RC_PATH "${CMAKE_CURRENT_BINARY_DIR}/voidone.rc")

    string(REPLACE "." ";" _voidone_version_list "${PROJECT_VERSION}")
    list(LENGTH _voidone_version_list _voidone_version_len)
    while(_voidone_version_len LESS 4)
        list(APPEND _voidone_version_list 0)
        list(LENGTH _voidone_version_list _voidone_version_len)
    endwhile()
    list(JOIN _voidone_version_list "," VOIDONE_RC_VERSION_CSV)

    file(WRITE "${VOIDONE_RC_PATH}" "\
#include <winver.h>

IDI_ICON1 ICON DISCARDABLE \"${APP_ICON_PATH}\"

VS_VERSION_INFO VERSIONINFO
 FILEVERSION ${VOIDONE_RC_VERSION_CSV}
 PRODUCTVERSION ${VOIDONE_RC_VERSION_CSV}
 FILEFLAGSMASK 0x3fL
 FILEFLAGS 0x0L
 FILEOS 0x40004L
 FILETYPE 0x1L
 FILESUBTYPE 0x0L
BEGIN
    BLOCK \"StringFileInfo\"
    BEGIN
        BLOCK \"040904b0\"
        BEGIN
            VALUE \"CompanyName\", \"VoidOne-App Core Team\"
            VALUE \"FileDescription\", \"${PROJECT_DESCRIPTION}\"
            VALUE \"FileVersion\", \"${VOIDONE_VERSION_DISPLAY}\"
            VALUE \"InternalName\", \"VoidOne\"
            VALUE \"LegalCopyright\", \"Copyright (c) 2026 VoidOne-App Core Team\"
            VALUE \"OriginalFilename\", \"VoidOne.exe\"
            VALUE \"ProductName\", \"VoidOne\"
            VALUE \"ProductVersion\", \"${VOIDONE_VERSION_DISPLAY}\"
        END
    END
    BLOCK \"VarFileInfo\"
    BEGIN
        VALUE \"Translation\", 0x409, 1200
    END
END
")

    if(EXISTS "${APP_ICON_PATH}")
        list(APPEND VOIDONE_SOURCES "${VOIDONE_RC_PATH}")
    else()
        message(WARNING "app.ico not found at ${APP_ICON_PATH} — building without an application icon.")
    endif()
endif()

# ============================================================================
# Executable
# ============================================================================

qt_add_executable(VoidOne ${VOIDONE_SOURCES})

# ============================================================================
# QML Module
# ============================================================================

qt_add_qml_module(VoidOne
    URI VoidOne
    VERSION 1.0
    QML_FILES ${VOIDONE_QML_FILES}
)

# ============================================================================
# Include Directories
# ============================================================================

target_include_directories(VoidOne
    PRIVATE
        "${CMAKE_CURRENT_SOURCE_DIR}/src"
        "${CMAKE_CURRENT_SOURCE_DIR}/src/core"
)

# ============================================================================
# Precompiled Headers
# ============================================================================

target_precompile_headers(VoidOne
    PRIVATE
        <QObject>
        <QString>
        <QList>
        <memory>
        <vector>
        <string>
)

# ============================================================================
# Compile Definitions
# ============================================================================

target_compile_definitions(VoidOne
    PRIVATE
        PROJECT_VERSION="${PROJECT_VERSION}"
        PROJECT_VERSION_DISPLAY="${VOIDONE_VERSION_DISPLAY}"
        PROJECT_NAME="${PROJECT_NAME}"
)

# ============================================================================
# Compiler Warnings & Hardening
# ============================================================================

if(MSVC)
    target_compile_definitions(VoidOne
        PRIVATE
            UNICODE
            _UNICODE
            NOMINMAX
            WIN32_LEAN_AND_MEAN
            _SILENCE_STDEXT_ARR_IT_DEPRECATION_WARNINGS
    )

    target_compile_options(VoidOne
        PRIVATE
            /W4
            /permissive-
            /Zc:__cplusplus
            /sdl
            $<$<CONFIG:Release>:/GL>
    )

    if(VOIDONE_WARNINGS_AS_ERRORS)
        target_compile_options(VoidOne PRIVATE /WX)
    endif()
else()
    target_compile_options(VoidOne
        PRIVATE
            -Wall
            -Wextra
            -Wpedantic
            -Wshadow
    )

    if(VOIDONE_WARNINGS_AS_ERRORS)
        target_compile_options(VoidOne PRIVATE -Werror)
    endif()

    if(VOIDONE_ENABLE_SANITIZERS AND CMAKE_BUILD_TYPE STREQUAL "Debug")
        target_compile_options(VoidOne PRIVATE -fsanitize=address,undefined -fno-omit-frame-pointer)
        target_link_options(VoidOne PRIVATE -fsanitize=address,undefined)
    endif()
endif()

# ============================================================================
# Link-Time Optimization (Release only)
# ============================================================================

if(VOIDONE_ENABLE_LTO)
    include(CheckIPOSupported)
    check_ipo_supported(RESULT VOIDONE_IPO_SUPPORTED OUTPUT VOIDONE_IPO_ERROR)
    if(VOIDONE_IPO_SUPPORTED)
        set_property(TARGET VoidOne PROPERTY
            INTERPROCEDURAL_OPTIMIZATION_RELEASE TRUE)
    else()
        message(STATUS "LTO requested but not supported by this toolchain: ${VOIDONE_IPO_ERROR}")
    endif()
endif()

# ============================================================================
# Qt Libraries
# ============================================================================

target_link_libraries(VoidOne
    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Quick
        Qt6::Sql
)

# ============================================================================
# Target Properties
# ============================================================================

set_target_properties(VoidOne
    PROPERTIES
        OUTPUT_NAME "VoidOne"
        VERSION "${PROJECT_VERSION}"
        DESCRIPTION "${PROJECT_DESCRIPTION}"
)

# ============================================================================
# Windows Subsystem
# ============================================================================

if(WIN32)
    if(VOIDONE_ENABLE_CONSOLE)
        set_target_properties(VoidOne PROPERTIES WIN32_EXECUTABLE FALSE)
    else()
        set_target_properties(VoidOne PROPERTIES WIN32_EXECUTABLE TRUE)
    endif()
endif()

# ============================================================================
# Installation
# ============================================================================

install(
    TARGETS VoidOne
    BUNDLE DESTINATION .
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
)

# ============================================================================
# Tests
# ============================================================================

if(VOIDONE_BUILD_TESTS)
    enable_testing()
    message(STATUS "VoidOne tests: ENABLED")
endif()

# ============================================================================
# Configuration Summary
# ============================================================================

message(STATUS "")
message(STATUS "============================================")
message(STATUS "          VoidOne Configuration")
message(STATUS "============================================")
message(STATUS "Version:        ${PROJECT_VERSION} (${VOIDONE_VERSION_DISPLAY})")
message(STATUS "C++ Standard:   C++${CMAKE_CXX_STANDARD}")
message(STATUS "Build Type:     ${CMAKE_BUILD_TYPE}")
message(STATUS "Compiler:       ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "Qt Version:     ${Qt6_VERSION}")
message(STATUS "System:         ${CMAKE_SYSTEM_NAME}")
message(STATUS "Generator:      ${CMAKE_GENERATOR}")
message(STATUS "Console:        ${VOIDONE_ENABLE_CONSOLE}")
message(STATUS "LTO:            ${VOIDONE_ENABLE_LTO}")
message(STATUS "Warnings=Errors:${VOIDONE_WARNINGS_AS_ERRORS}")
message(STATUS "Tests:          ${VOIDONE_BUILD_TESTS}")
message(STATUS "============================================")
message(STATUS "VoidOne configuration complete.")
message(STATUS "")
