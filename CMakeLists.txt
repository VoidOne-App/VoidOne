cmake_minimum_required(VERSION 3.21)

project(NeonLauncher
    VERSION 1.0.2
    DESCRIPTION "A modern Qt6 C++ Game Launcher"
    LANGUAGES CXX
)

# ============================================================================
# C++ / Qt
# ============================================================================

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

include(GNUInstallDirs)

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
# Sources
# ============================================================================

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

# ============================================================================
# Windows icon
# ============================================================================

if(WIN32 AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/assets/icon.ico")

    set(APP_ICON_RESOURCE
        "${CMAKE_CURRENT_BINARY_DIR}/app_icon.rc"
    )

    file(WRITE
        "${APP_ICON_RESOURCE}"
        "IDI_ICON1 ICON DISCARDABLE \"${CMAKE_CURRENT_SOURCE_DIR}/assets/icon.ico\"\n"
    )

    list(APPEND
        PROJECT_SOURCES
        "${APP_ICON_RESOURCE}"
    )

endif()

# ============================================================================
# Executable
# ============================================================================

qt_add_executable(
    NeonLauncherApp
    ${PROJECT_SOURCES}
)

# ============================================================================
# QML Module
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

        PROJECT_VERSION="${PROJECT_VERSION}"
        PROJECT_NAME="${PROJECT_NAME}"
)

# ============================================================================
# Compiler warnings
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

    target_compile_options(
        NeonLauncherApp
        PRIVATE

            /W4
            /Zc:__cplusplus
    )

else()

    target_compile_options(
        NeonLauncherApp
        PRIVATE

            -Wall
            -Wextra
            -Wpedantic
    )

endif()

# ============================================================================
# Qt libraries
# ============================================================================

target_link_libraries(
    NeonLauncherApp
    PRIVATE

        Qt6::Core
        Qt6::Gui
        Qt6::Quick
        Qt6::Sql
)

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
)

# ============================================================================
# Windows
# ============================================================================

if(WIN32)

    set_target_properties(
        NeonLauncherApp
        PROPERTIES

            WIN32_EXECUTABLE
                $<IF:$<CONFIG:Release>,TRUE,FALSE>
    )

endif()

# ============================================================================
# Installation
# ============================================================================

install(
    TARGETS NeonLauncherApp

    BUNDLE DESTINATION .

    RUNTIME DESTINATION
        "${CMAKE_INSTALL_BINDIR}"
)

# ============================================================================
# Configuration summary
# ============================================================================

message(STATUS "")
message(STATUS "============================================")
message(STATUS "       NeonLauncher Configuration")
message(STATUS "============================================")
message(STATUS "Version:      ${PROJECT_VERSION}")
message(STATUS "C++:          C++${CMAKE_CXX_STANDARD}")
message(STATUS "Compiler:     ${CMAKE_CXX_COMPILER_ID}")
message(STATUS "Compiler Ver: ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "Qt:           ${Qt6_VERSION}")
message(STATUS "System:       ${CMAKE_SYSTEM_NAME}")
message(STATUS "Generator:    ${CMAKE_GENERATOR}")
message(STATUS "============================================")
message(STATUS "NeonLauncher configuration complete.")
message(STATUS "")
