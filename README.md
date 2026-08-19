VoidOne

Open-source PC Game Launcher built with C++ and Qt 6.

VoidOne is an open-source game launcher focused on providing a modern, fast, customizable, and visually distinctive experience for PC gamers.

The project is currently in active development and aims to grow into a powerful game library and launcher, with features inspired by modern game-management software such as Playnite while maintaining its own identity and design.

«🚧 VoidOne is currently in early development.
Features and architecture may change significantly as the project evolves.»

---

✨ Vision

The goal of VoidOne is to create a complete and extensible game launcher that can:

- Automatically discover installed games
- Organize games into a unified library
- Launch games from different platforms
- Provide a modern and customizable interface
- Support mods and game management
- Integrate useful gaming tools
- Remain lightweight and open source

The long-term goal is to build something that can become a serious alternative to existing game-library managers.

---

🚀 Planned Features

🎮 Game Library

- [ ] Automatic game scanning
- [ ] Unified game library
- [ ] Game metadata
- [ ] Cover and background artwork
- [ ] Game categories and tags
- [ ] Favorites
- [ ] Playtime tracking
- [ ] Recently played games

🕹️ Game Launching

- [ ] Direct game launching
- [ ] Steam integration
- [ ] Epic Games integration
- [ ] GOG integration
- [ ] Xbox / Microsoft Store integration
- [ ] Custom game executables
- [ ] Launch arguments
- [ ] Per-game configuration

🧩 Mod Management

- [ ] Mod installation
- [ ] Mod profiles
- [ ] Mod enable/disable
- [ ] Mod load order
- [ ] Mod backup and restore

🎨 Interface

- [ ] Modern QML interface
- [ ] Custom themes
- [ ] Animations
- [ ] Dark mode
- [ ] Customizable library layouts
- [ ] Cyberpunk-inspired visual identity

⚙️ Advanced Features

- [ ] SQLite-based game database
- [ ] Plugin system
- [ ] Overlay system
- [ ] RGB device integration
- [ ] Cloud synchronization
- [ ] Game statistics
- [ ] Optional AI-powered recommendations

---

🛠️ Technology

VoidOne is currently built around:

Technology| Purpose
C++23| Core application
Qt 6| Application framework
QML| User interface
SQLite| Local game database
CMake| Build system
WinAPI| Windows integration
GitHub Actions| CI/CD

---

🖥️ Supported Platforms

Windows

Primary development platform

- Windows 10+
- Windows 11
- x64

Linux

Linux builds are also being tested through CI.

«macOS support is not currently a priority, but the architecture may evolve to support additional platforms in the future.»

---

🔨 Building

Requirements

- C++23-compatible compiler
- Qt 6
- CMake
- Ninja or another supported CMake generator
- Git

Clone the repository:

git clone https://github.com/mohammedmk3900-rgb/NeonLauncher-Qt.git
cd NeonLauncher-Qt

Configure:

cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release

Build:

cmake --build build --parallel

---

🤖 GitHub Actions

VoidOne uses GitHub Actions to automatically build and validate the project.

The CI pipeline currently performs tasks such as:

- Windows Release build
- Windows Debug build
- Linux Release build
- Linux Debug build
- Unit tests
- Address/Undefined Behavior Sanitizers
- Static analysis
- QML validation
- Release artifact generation

Every release build is packaged with the required runtime files so that the application can be distributed without requiring the user to install the development environment.

---

📦 Releases

Official builds will be published through GitHub Releases.

Development versions may be unstable and should not be considered production-ready.

---

🗺️ Roadmap

Phase 1 — Foundation

- [x] Initial C++/Qt project
- [x] CMake build system
- [x] QML integration
- [x] Windows CI
- [x] Linux CI
- [x] Automated release builds
- [ ] Stable application startup
- [ ] Basic launcher UI

Phase 2 — Game Library

- [ ] Game detection
- [ ] Game database
- [ ] Game metadata
- [ ] Library UI
- [ ] Game launching

Phase 3 — Platform Integration

- [ ] Steam
- [ ] Epic Games
- [ ] GOG
- [ ] Microsoft/Xbox
- [ ] Custom games

Phase 4 — Advanced Management

- [ ] Mod manager
- [ ] Plugin system
- [ ] Game profiles
- [ ] Statistics
- [ ] Overlay

Phase 5 — Ecosystem

- [ ] Themes
- [ ] Extensions
- [ ] Cloud synchronization
- [ ] Optional AI features
- [ ] Community integrations

---

🤝 Contributing

VoidOne is an open-source project and contributions are welcome.

You don't need to be an expert to contribute.

You can help with:

- C++
- Qt / QML
- Python
- UI/UX
- Testing
- Documentation
- Bug reports
- Feature ideas
- Performance improvements
- Translation
- Game compatibility testing

If you're interested in contributing, feel free to open an issue or submit a pull request.

---

👨‍💻 Project Background

VoidOne started as an idea for a modern PC game launcher.

The project is currently being developed while its creator learns C++ and Qt.

Some early parts of the project were generated or assisted by AI. The goal is not to hide that fact, but to use AI as a development tool while gradually understanding, improving, and rewriting the code.

The project is intended to become a genuine open-source project where contributors can help shape its architecture and future.

«The idea comes first. The code gets better with every version.»

---

📸 Screenshots

Coming soon.

---

📄 License

License information will be added as the project approaches its first stable release.

---

⭐ Support the Project

If you like the idea behind VoidOne, you can help by:

- ⭐ Starring the repository
- 🐛 Reporting bugs
- 💡 Suggesting features
- 🧪 Testing development builds
- 🧑‍💻 Contributing code
- 📖 Improving documentation

Every contribution helps the project grow.

---

VoidOne

One launcher. Your entire PC game library.
