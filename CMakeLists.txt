cmake_minimum_required(VERSION 3.16)

# ==============================================================================
# Project Definition & Metadata
# ==============================================================================
project(NeonLauncher
    VERSION 1.1.0
    DESCRIPTION "A modern C++ and Qt6 Game Launcher"
    LANGUAGES CXX
)

# ==============================================================================
# C++ Standard & Compiler Configurations
# ==============================================================================
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Enable Ccache for faster rebuilds if available
find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
    set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
endif()

# Enable Link-Time Optimization (LTO) for Release builds
include(CheckIPOSupported)
check_ipo_supported(RESULT ipo_supported OUTPUT ipo_error)
if(ipo_supported)
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE ON)
endif()

# Strict compiler warnings and definitions
if(MSVC)
    add_compile_definitions(
        _SILENCE_STDEXT_ARR_IT_DEPRECATION_WARNINGS
        UNICODE
        _UNICODE
        NOMINMAX
    )
    add_compile_options(/Zc:__cplusplus /W4 /permissive-)
else()
    add_compile_options(-Wall -Wextra -Wpedantic -Wshadow)
endif()

# Inject project properties into C++ preprocessor
add_compile_definitions(
    PROJECT_VERSION="${PROJECT_VERSION}"
    PROJECT_NAME="${PROJECT_NAME}"
)

# ==============================================================================
# Qt Autogen & Build Paths Setup
# ==============================================================================
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

include(GNUInstallDirs)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}")

# ==============================================================================
# Dependencies (Qt6)
# ==============================================================================
find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Sql)

# ==============================================================================
# Source Files Identification
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

# ==============================================================================
# Target Construction
# ==============================================================================
qt_add_executable(NeonLauncherApp
    ${PROJECT_SOURCES}
)

# QML Module Declaration
qt_add_qml_module(NeonLauncherApp
    URI NeonLauncher
    VERSION 1.0
    QML_FILES ${QML_FILES}
)

# Include Directories Configuration
target_include_directories(NeonLauncherApp PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/src/core
)

# Target Linkage
target_link_libraries(NeonLauncherApp PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::Sql
)

# ==============================================================================
# Platform Specific Adjustments
# ==============================================================================
if(WIN32)
    # Hide the CMD terminal window on Release builds
    set_target_properties(NeonLauncherApp PROPERTIES
        WIN32_EXECUTABLE $<IF:$<CONFIG:Release>,TRUE,FALSE>
    )
endif()

# ==============================================================================
# Installation & Packaging
# ==============================================================================
install(TARGETS NeonLauncherApp
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
