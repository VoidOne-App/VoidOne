cmake_minimum_required(VERSION 3.16)

# ==============================================================================
# Project Definition & Metadata
# ==============================================================================
project(NeonLauncher
    VERSION 1.0.2
    DESCRIPTION "A high-performance Qt6 & C++ Game Launcher"
    LANGUAGES CXX
)

# ==============================================================================
# C++ Standard & Build Setup
# ==============================================================================
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# هدایت خروجی فایل‌های اجرایی به پوشه build/bin/
include(GNUInstallDirs)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}")

# فعال‌سازی ccache در صورت وجود روی سیستم
find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
    set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
endif()

# تنظیمات کامپایلرها
if(MSVC)
    add_compile_definitions(
        _SILENCE_STDEXT_ARR_IT_DEPRECATION_WARNINGS
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
