cmake_minimum_required(VERSION 3.21)

project(VoidOne
    VERSION 0.0.1
    DESCRIPTION "A modern Qt6 C++ game launcher"
    LANGUAGES CXX
)

# ============================================================================
# Project Configuration
# ============================================================================

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

include(GNUInstallDirs)

# ============================================================================
# Build Options
# ============================================================================

option(VOIDONE_BUILD_TESTS
    "Build VoidOne tests"
    OFF
)

option(VOIDONE_ENABLE_CONSOLE
    "Keep the console window enabled on Windows"
    ON
)

# ============================================================================
# Qt
# ============================================================================

find_package(Qt6 REQUIRED COMPONENTS
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
# Windows Application Icon (تغییر یافته برای خواندن app.ico از ریشه)
# ============================================================================

if(WIN32)
    set(APP_ICON_PATH "${CMAKE_CURRENT_SOURCE_DIR}/app.ico")
    if(EXISTS "${APP_ICON_PATH}")
        set(VOIDONE_ICON_RESOURCE "${CMAKE_CURRENT_BINARY_DIR}/voidone_icon.rc")
        file(WRITE "${VOIDONE_ICON_RESOURCE}"
            "IDI_ICON1 ICON DISCARDABLE \"${APP_ICON_PATH}\"\n"
        )
        list(APPEND VOIDONE_SOURCES "${VOIDONE_ICON_RESOURCE}")
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
# Compile Definitions (تغییر نسخه نمایشی به 0.0.1b)
# ============================================================================

target_compile_definitions(VoidOne
    PRIVATE
        PROJECT_VERSION="${PROJECT_VERSION}"
        PROJECT_VERSION_DISPLAY="0.0.1b"
        PROJECT_NAME="${PROJECT_NAME}"
)

# ============================================================================
# Compiler Warnings
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
    )
else()
    target_compile_options(VoidOne
        PRIVATE
            -Wall
            -Wextra
            -Wpedantic
    )
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
# Windows Application
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
message(STATUS "Version:        ${PROJECT_VERSION} (0.0.1b)")
message(STATUS "C++ Standard:   C++${CMAKE_CXX_STANDARD}")
message(STATUS "Compiler:       ${CMAKE_CXX_COMPILER_ID}")
message(STATUS "Compiler Ver:   ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "Qt Version:     ${Qt6_VERSION}")
message(STATUS "System:         ${CMAKE_SYSTEM_NAME}")
message(STATUS "Generator:      ${CMAKE_GENERATOR}")
message(STATUS "Console:        ${VOIDONE_ENABLE_CONSOLE}")
message(STATUS "Tests:          ${VOIDONE_BUILD_TESTS}")
message(STATUS "============================================")
message(STATUS "VoidOne configuration complete.")
message(STATUS "")
