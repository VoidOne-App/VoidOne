VoidOne — Build Troubleshooting Guide

This guide covers common build, configuration, QML, runtime, and deployment problems when building VoidOne.

Current Build Environment

VoidOne currently targets:

- C++: C++23
- Qt: Qt 6.11.x
- QML: Qt Quick / QML
- Build System: CMake
- Build Generator: Ninja
- Windows Compiler: MSVC 2022
- Linux Compiler: GCC / Clang
- CI: GitHub Actions

---

❌ Error: "Qt6 not found"

CMake Error: Could not find a package configuration file provided by "Qt6"

Windows

Make sure Qt 6.11 is installed and provide the correct Qt path:

cmake `
  -S . `
  -B build `
  -G Ninja `
  -DCMAKE_BUILD_TYPE=Release `
  -DCMAKE_CXX_STANDARD=23 `
  -DCMAKE_PREFIX_PATH="C:\Qt\6.11.x\msvc2022_64"

Replace "6.11.x" with the exact Qt version installed on your system.

Linux

cmake \
  -S . \
  -B build \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=23 \
  -DCMAKE_PREFIX_PATH="$HOME/Qt/6.11.x/gcc_64"

Verify Qt

qmake --version

If "qmake" cannot be found, Qt's "bin" directory is probably not in "PATH".

---

❌ Error: "QML module not found"

Example:

module "VoidOne" is not installed

or:

No module named "VoidOne" found

Make sure the QML module is correctly defined in "CMakeLists.txt".

The project should use Qt's QML module system, for example:

qt_add_qml_module(...)

Also verify that all required QML files are included.

Clean rebuild

Windows

Remove-Item build -Recurse -Force -ErrorAction SilentlyContinue

cmake `
  -S . `
  -B build `
  -G Ninja `
  -DCMAKE_BUILD_TYPE=Release `
  -DCMAKE_CXX_STANDARD=23

cmake --build build --parallel

Linux

rm -rf build

cmake \
  -S . \
  -B build \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=23

cmake --build build --parallel

---

❌ Error: "MSVC compiler not found"

Example:

MSVC compiler not found

or:

cl.exe is not recognized

Solution

Install Visual Studio Build Tools 2022 with the C++ development tools.

Then initialize the MSVC environment.

For example:

& "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"

The Visual Studio edition may be different on your system.

Verify the compiler:

where.exe cl

Then:

cl

You should see the MSVC compiler information.

---

❌ Error: "CMAKE_CXX_COMPILER not specified"

Example:

CMAKE_CXX_COMPILER not set

Make sure the correct compiler is available in the environment.

Windows / MSVC

Initialize the MSVC environment and configure with CMake:

cmake `
  -S . `
  -B build `
  -G Ninja `
  -DCMAKE_BUILD_TYPE=Release `
  -DCMAKE_CXX_STANDARD=23

Linux / GCC

cmake \
  -S . \
  -B build \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=23 \
  -DCMAKE_CXX_COMPILER=g++

Linux / Clang

cmake \
  -S . \
  -B build \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=23 \
  -DCMAKE_CXX_COMPILER=clang++

---

❌ Error: "Linker error: unresolved external symbols"

MSVC

LNK2001: unresolved external symbol

GCC / Clang

undefined reference to ...

Possible causes include:

- A ".cpp" file is missing from the CMake target.
- A required Qt module is not linked.
- A function has been declared but not implemented.
- The wrong build configuration is being used.
- The project contains incompatible compiler settings.

Check "CMakeLists.txt" and make sure all source files and required Qt modules are included.

Then perform a clean rebuild.

rm -rf build

cmake \
  -S . \
  -B build \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=23

cmake --build build --parallel

---

❌ Error: "Database initialization failed"

Example:

Database failed: unable to open database file

Possible causes:

- The application directory is not writable.
- The database directory does not exist.
- The application is trying to write inside a protected installation directory.

For development, verify that the target directory exists and is writable.

On Linux:

ls -ld .

Avoid using:

chmod 777

as a general solution.

For a production application, application data should preferably be stored in the user's writable application-data directory rather than inside the installation directory.

---

❌ Error: "Steam not found"

Example:

Steam folder not found

Do not assume that Steam is always installed at:

C:\Program Files (x86)\Steam

Steam can be installed on another drive or in a custom location.

Check:

- Steam installation directory
- Steam library locations
- "steamapps" directories
- User permissions

If Steam is installed somewhere else, the launcher should detect or allow the correct library path.

---

❌ VoidOne.exe Closes Immediately

If the application builds successfully but closes immediately after launching, possible causes include:

- Missing Qt DLLs
- Missing QML modules
- Missing Qt platform plugins
- QML loading failure
- Invalid resource paths
- Database initialization failure
- Application initialization failure
- "engine.rootObjects()" being empty

Run the application from a terminal instead of double-clicking it.

Windows

cd package
.\VoidOne.exe

Linux

./build/VoidOne

Running from a terminal can reveal runtime errors that are not visible when double-clicking the executable.

---

🔍 Debugging Application Startup

For startup problems, temporary logging can be added to "main.cpp".

Example:

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDebug>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qDebug() << "Step 1";

    QQmlApplicationEngine engine;

    qDebug() << "Step 2";

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []()
        {
            QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection
    );

    qDebug() << "Step 3";

    engine.loadFromModule("VoidOne", "Main");

    qDebug() << "Step 4";

    if (engine.rootObjects().isEmpty())
    {
        qDebug() << "Step 5";
        return -1;
    }

    qDebug() << "Step 6";

    return app.exec();
}

Expected startup output:

Step 1
Step 2
Step 3
Step 4
Step 6

If the output reaches:

Step 5

the QML engine failed to create the root object.

If there is no output at all, investigate the executable, runtime dependencies, platform plugin, or console environment.

---

❌ Missing Qt DLLs on Windows

A Windows release build requires Qt runtime libraries.

Users should not need the complete Qt development environment installed to run VoidOne.

Use "windeployqt" to deploy the required Qt runtime files.

Example:

windeployqt `
  --release `
  --qmldir "$env:GITHUB_WORKSPACE\src\ui\qml" `
  "package\VoidOne.exe"

After deployment, verify the package:

Get-ChildItem package -Recurse

The exact Qt DLLs depend on the modules used by VoidOne.

---

❌ "windeployqt" Not Found

Example:

windeployqt : The term 'windeployqt' is not recognized

Make sure Qt's "bin" directory is available in "PATH".

Example:

$qtRoot = "C:\Qt\6.11.x\msvc2022_64"
$env:PATH = "$qtRoot\bin;$env:PATH"

Then verify:

windeployqt --version

---

❌ GitHub Actions Qt Installation Failed

If Qt installation fails in GitHub Actions, first verify which versions are available.

For "aqtinstall":

python -m aqt list-qt windows desktop

To inspect the available MSVC 2022 builds:

python -m aqt list-qt windows desktop --arch win64_msvc2022_64

Do not assume that every Qt version is immediately available through every mirror.

If the requested version is unavailable, use an available compatible Qt 6 version.

---

❌ GitHub Actions Build Succeeds but Application Does Not Start

A successful GitHub Actions compilation does not necessarily mean that the application has been packaged correctly.

Check the following:

1. Verify the executable

Test-Path "package\VoidOne.exe"

2. Verify Qt deployment

Get-ChildItem package -Recurse

3. Verify QML deployment

Make sure the required QML modules are included.

4. Run from a terminal

cd package
.\VoidOne.exe

5. Add temporary startup logging

Use the startup logging described above.

---

🧹 Clean Build

A clean build is recommended after major changes to:

- "CMakeLists.txt"
- QML modules
- Qt version
- Source files
- Build configuration

Windows

Remove-Item build -Recurse -Force -ErrorAction SilentlyContinue

Then:

cmake `
  -S . `
  -B build `
  -G Ninja `
  -DCMAKE_BUILD_TYPE=Release `
  -DCMAKE_CXX_STANDARD=23

cmake --build build --parallel

Linux

rm -rf build

Then:

cmake \
  -S . \
  -B build \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=23

cmake --build build --parallel

---

🐛 Debug Build

For debugging:

cmake \
  -S . \
  -B build-debug \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_CXX_STANDARD=23

cmake --build build-debug --parallel

On Linux, the application can be inspected with GDB:

gdb ./build-debug/VoidOne

On macOS, LLDB can be used:

lldb ./build-debug/VoidOne

On Windows, Visual Studio or WinDbg can be used for native debugging.

---

🧪 Unit Tests

If tests are enabled:

cmake \
  -S . \
  -B build-tests \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_CXX_STANDARD=23 \
  -DVOIDONE_BUILD_TESTS=ON

Build:

cmake --build build-tests --parallel

Run:

ctest \
  --test-dir build-tests \
  --output-on-failure \
  --parallel 2

---

🔬 Sanitizers

AddressSanitizer and UndefinedBehaviorSanitizer can help detect memory and undefined-behavior problems.

Example:

cmake \
  -S . \
  -B build-sanitize \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_CXX_STANDARD=23 \
  -DCMAKE_CXX_FLAGS="-fsanitize=address,undefined -fno-omit-frame-pointer" \
  -DCMAKE_EXE_LINKER_FLAGS="-fsanitize=address,undefined"

Then:

cmake --build build-sanitize --parallel

---

🔎 Static Analysis

For Clang-based static analysis:

clang++ --version
clang-tidy --version

A CMake configuration can use:

-DCMAKE_CXX_COMPILER=clang++
-DCMAKE_CXX_CLANG_TIDY=clang-tidy

Static-analysis failures should be investigated separately from normal compiler errors.

---

🖥️ QML Validation

If the project provides a QML lint target:

cmake \
  --build build \
  --target VoidOneApp_qmllint \
  --parallel

If this target does not exist, verify the QML module configuration in "CMakeLists.txt".

---

📦 Release Build Checklist

Before distributing a Windows release:

- [ ] CMake configuration succeeds.
- [ ] C++23 is enabled.
- [ ] Qt 6.11.x is available.
- [ ] MSVC 2022 is configured.
- [ ] Release compilation succeeds.
- [ ] "VoidOne.exe" exists.
- [ ] "windeployqt" completes successfully.
- [ ] Required Qt DLLs are present.
- [ ] Required QML modules are present.
- [ ] Required platform plugins are present.
- [ ] VoidOne starts without Qt Creator installed.
- [ ] VoidOne starts without the Qt development environment installed.
- [ ] Unit tests pass.
- [ ] Sanitizer build succeeds.
- [ ] Static analysis succeeds.
- [ ] QML validation succeeds.
- [ ] Release archive is generated.
- [ ] SHA256 checksum is generated.
- [ ] GitHub Actions artifact is uploaded successfully.

---

🆘 When Reporting a Problem

When asking for help, include:

Operating System

Windows 11

Qt Version

Qt 6.11.x

Compiler

MSVC 2022

CMake Version

cmake --version

Build Command

Include the exact command used to configure and build the project.

Full Error

Include the complete terminal or GitHub Actions error.

Runtime Behavior

Explain exactly what happens.

For example:

Build succeeds.
VoidOne.exe is created.
The executable closes immediately.
No visible error appears.

GitHub Actions

If the problem occurs in CI, include the GitHub Actions workflow run URL.

---

🧭 Recommended Debugging Order

When VoidOne fails to build or start, investigate in this order:

1. Does CMake configure successfully?
        ↓
2. Does compilation succeed?
        ↓
3. Does VoidOne.exe exist?
        ↓
4. Can it start from a terminal?
        ↓
5. Are Qt DLLs deployed?
        ↓
6. Are required QML modules deployed?
        ↓
7. Does engine.loadFromModule() succeed?
        ↓
8. Are rootObjects() created?
        ↓
9. Does app.exec() remain running?

This approach helps isolate the actual failure instead of changing multiple parts of the project at once.

---

Important

A successful compilation does not automatically mean that the application is ready for distribution.

A Windows release must include the runtime dependencies required by VoidOne.

The final package should allow a user to run VoidOne without installing:

- Qt Creator
- The Qt SDK
- Visual Studio
- The Qt development environment

The release package should contain everything required to run the application.
