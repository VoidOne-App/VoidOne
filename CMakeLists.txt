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
include(FeatureSummary)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "RelWithDebInfo" "MinSizeRel")
endif()

# ============================================================================
# Build Options
# ============================================================================

option(VOIDONE_BUILD_TESTS         "Build VoidOne test suite"                              OFF)
option(VOIDONE_ENABLE_CONSOLE      "Keep the console window enabled on Windows"            ON)
option(VOIDONE_WARNINGS_AS_ERRORS  "Treat compiler warnings as errors"                     OFF)
option(VOIDONE_ENABLE_LTO          "Enable link-time optimization in Release"              ON)
option(VOIDONE_ENABLE_SANITIZERS   "Enable ASan/UBSan in Debug builds (GCC/Clang only)"    OFF)
option(VOIDONE_ENABLE_CLANG_TIDY   "Run clang-tidy during compilation"                     OFF)
option(VOIDONE_ENABLE_UNITY_BUILD  "Batch-compile translation units for faster CI builds"  OFF)
option(VOIDONE_REPRODUCIBLE_BUILD  "Best-effort deterministic build output (see notes below)" OFF)
option(VOIDONE_BUILD_DOCS          "Generate API documentation with Doxygen (if installed)" OFF)

if(VOIDONE_ENABLE_UNITY_BUILD)
    set(CMAKE_UNITY_BUILD ON)
endif()

# ----------------------------------------------------------------------------
# clang-tidy integration — runs as part of the normal compile step (not a
# separate CI-only pass), so warnings show up in your editor/terminal the
# moment you build locally, not after a push.
# ----------------------------------------------------------------------------
if(VOIDONE_ENABLE_CLANG_TIDY)
    find_program(VOIDONE_CLANG_TIDY_EXE NAMES clang-tidy)
    if(VOIDONE_CLANG_TIDY_EXE)
        set(CMAKE_CXX_CLANG_TIDY "${VOIDONE_CLANG_TIDY_EXE}")
        message(STATUS "clang-tidy enabled: ${VOIDONE_CLANG_TIDY_EXE}")
    else()
        message(WARNING "VOIDONE_ENABLE_CLANG_TIDY is ON but clang-tidy was not found on PATH.")
    endif()
endif()

# ============================================================================
# Version Resolution (Git-aware)
# ============================================================================

if(DEFINED VOIDONE_VERSION_OVERRIDE)
    set(VOIDONE_VERSION_DISPLAY "${VOIDONE_VERSION_OVERRIDE}")
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

# ----------------------------------------------------------------------------
# Generated version header — replaces scattering PROJECT_VERSION as raw
# preprocessor -D defines. This gives you a real, includable header
# (`#include "VoidOneVersion.h"`) that both the core library and the QML
# front end can use. To surface it in QML specifically, expose one of these
# macros via a QML_SINGLETON C++ class or qmlRegisterSingletonType in
# main.cpp — that part is application code, not something CMake can do on
# its own, but the header is ready for it.
# ----------------------------------------------------------------------------
set(VOIDONE_GENERATED_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
file(MAKE_DIRECTORY "${VOIDONE_GENERATED_DIR}")

file(WRITE "${VOIDONE_GENERATED_DIR}/VoidOneVersion.h" "\
// Auto-generated by CMake. Do not edit — do not commit.
#pragma once

#define VOIDONE_VERSION         \"${PROJECT_VERSION}\"
#define VOIDONE_VERSION_DISPLAY \"${VOIDONE_VERSION_DISPLAY}\"
#define VOIDONE_VERSION_MAJOR   ${PROJECT_VERSION_MAJOR}
#define VOIDONE_VERSION_MINOR   ${PROJECT_VERSION_MINOR}
#define VOIDONE_VERSION_PATCH   ${PROJECT_VERSION_PATCH}
#define VOIDONE_PROJECT_NAME    \"${PROJECT_NAME}\"
")

# ============================================================================
# Reproducible Build (best-effort)
# ============================================================================
# HONEST LIMITATIONS: byte-for-byte reproducibility is a much harder
# guarantee on MSVC/PE than on GCC/Clang+ELF. The PDB embeds a fresh GUID
# every link by design (that's how the debugger matches symbols to binary),
# and some PE header fields aren't fully deterministic even with /Brepro.
# What this DOES get you: no embedded wall-clock timestamp, no leaked local
# absolute file paths, and independently-built binaries whose *code and
# resources* match — enough for a community member to meaningfully verify
# "this release matches this commit," which is the actual trust goal here.
# It is not a cryptographic guarantee of bit-identical output on MSVC.
# ============================================================================

if(VOIDONE_REPRODUCIBLE_BUILD)
    if(DEFINED ENV{SOURCE_DATE_EPOCH})
        message(STATUS "Reproducible build: SOURCE_DATE_EPOCH=$ENV{SOURCE_DATE_EPOCH}")
    else()
        message(STATUS "Reproducible build: SOURCE_DATE_EPOCH not set in environment.")
        message(STATUS "  CI should export it before configuring, e.g.:")
        message(STATUS "  SOURCE_DATE_EPOCH=$(git log -1 --format=%ct)")
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
# Shared Compiler Warnings / Hardening (INTERFACE library)
# ============================================================================
# Defined once, linked into every target (core lib + executable, and future
# test binaries). Avoids the previous pattern of copy-pasting the same
# /W4 / -Wall block onto each target separately.
# ============================================================================

add_library(voidone_compiler_warnings INTERFACE)

if(MSVC)
    target_compile_definitions(voidone_compiler_warnings
        INTERFACE
            UNICODE
            _UNICODE
            NOMINMAX
            WIN32_LEAN_AND_MEAN
            _SILENCE_STDEXT_ARR_IT_DEPRECATION_WARNINGS
    )

    target_compile_options(voidone_compiler_warnings
        INTERFACE
            /W4
            /permissive-
            /Zc:__cplusplus
            /sdl
            $<$<CONFIG:Release>:/GL>
    )

    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")

    if(VOIDONE_WARNINGS_AS_ERRORS)
        target_compile_options(voidone_compiler_warnings INTERFACE /WX)
    endif()

    if(VOIDONE_REPRODUCIBLE_BUILD)
        # /experimental:deterministic strips build-environment-dependent
        # data from generated debug info where the compiler supports it.
        target_compile_options(voidone_compiler_warnings INTERFACE /experimental:deterministic)
        target_link_options(voidone_compiler_warnings INTERFACE /Brepro)
    endif()
else()
    target_compile_options(voidone_compiler_warnings
        INTERFACE
            -Wall
            -Wextra
            -Wpedantic
            -Wshadow
    )

    if(VOIDONE_WARNINGS_AS_ERRORS)
        target_compile_options(voidone_compiler_warnings INTERFACE -Werror)
    endif()

    if(VOIDONE_ENABLE_SANITIZERS AND CMAKE_BUILD_TYPE STREQUAL "Debug")
        target_compile_options(voidone_compiler_warnings INTERFACE -fsanitize=address,undefined -fno-omit-frame-pointer)
        target_link_options(voidone_compiler_warnings INTERFACE -fsanitize=address,undefined)
    endif()

    if(VOIDONE_REPRODUCIBLE_BUILD)
        # Strips local absolute build-machine paths from debug info and
        # __FILE__ expansions, replacing them with a relative, portable form.
        target_compile_options(voidone_compiler_warnings INTERFACE
            -ffile-prefix-map=${CMAKE_SOURCE_DIR}=.
            -Wdate-time
        )
    endif()
endif()

# ============================================================================
# Core Library (voidone_core)
# ============================================================================
# Everything that isn't UI glue lives here: database access, store scanners,
# models, translation, backups. Splitting this out of the VoidOne executable
# is what makes VOIDONE_BUILD_TESTS meaningful — tests link against this
# library directly instead of needing to somehow test through main.cpp.
# It also means a future CLI tool, plugin host, or headless service could
# reuse this same logic without dragging in Qt Quick/QML.
# ============================================================================

add_library(voidone_core STATIC
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

target_include_directories(voidone_core
    PUBLIC
        "${CMAKE_CURRENT_SOURCE_DIR}/src"
        "${CMAKE_CURRENT_SOURCE_DIR}/src/core"
        "${VOIDONE_GENERATED_DIR}"
)

target_link_libraries(voidone_core
    PUBLIC
        Qt6::Core
        Qt6::Sql
    PRIVATE
        voidone_compiler_warnings
)

target_precompile_headers(voidone_core
    PRIVATE
        <QObject>
        <QString>
        <QList>
        <memory>
        <vector>
        <string>
)

if(VOIDONE_ENABLE_LTO)
    include(CheckIPOSupported)
    check_ipo_supported(RESULT VOIDONE_IPO_SUPPORTED OUTPUT VOIDONE_IPO_ERROR)
    if(VOIDONE_IPO_SUPPORTED)
        set_property(TARGET voidone_core PROPERTY INTERPROCEDURAL_OPTIMIZATION_RELEASE TRUE)
    else()
        message(STATUS "LTO requested but not supported by this toolchain: ${VOIDONE_IPO_ERROR}")
    endif()
endif()

# ============================================================================
# Windows Resources: Icon + Embedded Version Info (Executable only)
# ============================================================================

set(VOIDONE_EXE_EXTRA_SOURCES "")

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
        list(APPEND VOIDONE_EXE_EXTRA_SOURCES "${VOIDONE_RC_PATH}")
    else()
        message(WARNING "app.ico not found at ${APP_ICON_PATH} — building without an application icon.")
    endif()
endif()

# ============================================================================
# Executable (thin — just the entry point + Windows resources)
# ============================================================================

qt_add_executable(VoidOne
    src/main.cpp
    ${VOIDONE_EXE_EXTRA_SOURCES}
)

qt_add_qml_module(VoidOne
    URI VoidOne
    VERSION 1.0
    QML_FILES
        src/ui/qml/Main.qml
        src/ui/qml/GameCard.qml
        src/ui/qml/Sidebar.qml
        src/ui/qml/SaveBackupView.qml
)

target_link_libraries(VoidOne
    PRIVATE
        voidone_core
        voidone_compiler_warnings
        Qt6::Gui
        Qt6::Quick
)

if(VOIDONE_ENABLE_LTO AND VOIDONE_IPO_SUPPORTED)
    set_property(TARGET VoidOne PROPERTY INTERPROCEDURAL_OPTIMIZATION_RELEASE TRUE)
endif()

set_target_properties(VoidOne
    PROPERTIES
        OUTPUT_NAME "VoidOne"
        VERSION "${PROJECT_VERSION}"
        DESCRIPTION "${PROJECT_DESCRIPTION}"
)

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
# Now meaningful: tests link against voidone_core, not against the GUI
# executable. Add tests/CMakeLists.txt yourself when you're ready — this
# just wires the option up so nothing breaks in the meantime.

if(VOIDONE_BUILD_TESTS)
    enable_testing()
    message(STATUS "VoidOne tests: ENABLED (link against the 'voidone_core' target)")
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/tests/CMakeLists.txt")
        add_subdirectory(tests)
    else()
        message(STATUS "  No tests/CMakeLists.txt yet — nothing to add_subdirectory().")
    endif()
endif()

# ============================================================================
# Documentation (Doxygen, optional)
# ============================================================================

if(VOIDONE_BUILD_DOCS)
    find_package(Doxygen QUIET)
    if(DOXYGEN_FOUND)
        set(DOXYGEN_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/docs")
        set(DOXYGEN_EXTRACT_ALL YES)
        set(DOXYGEN_RECURSIVE YES)
        doxygen_add_docs(docs
            "${CMAKE_CURRENT_SOURCE_DIR}/src"
            COMMENT "Generating API documentation with Doxygen"
        )
        message(STATUS "Doxygen target 'docs' available (run: cmake --build build --target docs)")
    else()
        message(WARNING "VOIDONE_BUILD_DOCS is ON but Doxygen was not found — 'docs' target not created.")
    endif()
endif()

# ============================================================================
# Configuration Summary
# ============================================================================

message(STATUS "")
message(STATUS "============================================")
message(STATUS "          VoidOne Configuration")
message(STATUS "============================================")
message(STATUS "Version:          ${PROJECT_VERSION} (${VOIDONE_VERSION_DISPLAY})")
message(STATUS "C++ Standard:     C++${CMAKE_CXX_STANDARD}")
message(STATUS "Build Type:       ${CMAKE_BUILD_TYPE}")
message(STATUS "Compiler:         ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "Qt Version:       ${Qt6_VERSION}")
message(STATUS "Generator:        ${CMAKE_GENERATOR}")
message(STATUS "Console:          ${VOIDONE_ENABLE_CONSOLE}")
message(STATUS "LTO:              ${VOIDONE_ENABLE_LTO}")
message(STATUS "Unity Build:      ${VOIDONE_ENABLE_UNITY_BUILD}")
message(STATUS "clang-tidy:       ${VOIDONE_ENABLE_CLANG_TIDY}")
message(STATUS "Reproducible:     ${VOIDONE_REPRODUCIBLE_BUILD}")
message(STATUS "Warnings=Errors:  ${VOIDONE_WARNINGS_AS_ERRORS}")
message(STATUS "Tests:            ${VOIDONE_BUILD_TESTS}")
message(STATUS "Docs:             ${VOIDONE_BUILD_DOCS}")
message(STATUS "============================================")
message(STATUS "")

feature_summary(WHAT ALL)
