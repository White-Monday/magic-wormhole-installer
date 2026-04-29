# 🪱 Magic Wormhole Windows Installer

A robust, automated, and "smart" Batch installer to deploy **Magic Wormhole** on Windows, handling all dependencies (Python and Pipx) with zero manual configuration.

[![Windows](https://img.shields.io/badge/Platform-🪟%20Windows-0078D6?style=for-the-badge)](https://microsoft.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?logo=opensourceinitiative&logoColor=white&style=for-the-badge)](https://opensource.org/licenses/MIT)


## 🚀 Key Features

- **Auto-Privilege Escalation**: Automatically requests administrative privileges if missing.
- **Reverse Cascade Installation**: Doesn't reinstall dependencies already installed.
- **Intelligent logic that attempts** to install Python via:
  1) `WinGet`
  2) `Chocolatey`
  3) `Scoop`
  4) `Direct Download` (MSIX or EXE via Curl)
- **Smart PATH Management**: 
  - Dynamic environment refresh (no terminal restart needed).
  - Safety check to prevent exceeding the Windows PATH limit (8192 characters).
  - Anti-duplication logic for cleaner environment variables.
- **Integrity Verification**: Checks for corrupted downloads (0 KB check) and detects system architecture (x64/x86) for the correct installer.
- **Rich UI**: Color-coded logs for a clear and professional user experience.


## 🛠️ Usage

1. **Download** the `.bat` file from the [Releases](../../releases) section or clone this repository.
2. **Run** the script by double-clicking it or via CMD:
   ```cmd
   magic_wormhole_installer.bat
   ```
3. **Relax**: The script will verify your system. If Magic Wormhole is missing, it will sequentially install Python, Pipx, and finally Magic Wormhole.


## 📦 Managed Dependencies

The script automatically configures:
- **Python 3.x** (including PATH setup).
- **Pipx** (to ensure a clean, isolated installation).
- **Magic-Wormhole** (the core tool).


## ⚠️ Requirements

- **Windows 10/11**: Recommended for native `curl` and `winget` support.
- **Internet Connection**: Required for downloading packages.


## 🛠️ Troubleshooting

If the automated installation fails:
1. The script will prompt you to open the official Python download page.
2. **Crucial**: Ensure you check the box **"Add Python to PATH"** during manual installation.
3. Relaunch the script to finish installing Pipx and Wormhole.


## 🔮 Future Fixes & Planned Improvements

- **Extended Python Discovery**: Implement a deeper scan for Python in non-standard install locations (e.g., Microsoft Store local folders, WindowsApps) to avoid redundant installations.
- **Custom Installation Scope**: Add command-line parameters to allow users to choose between a **User-only** or **System-wide** installation.
- **Dynamic Versioning**: Implement a check to always fetch the latest stable Python version URL instead of a hardcoded one.
- **Local/Offline Installation**: Add the ability to detect and use Python installers (`.exe` or `.msix`) if placed in the same directory as the script.
- **CLI Arguments**: Enable passing a specific installer file path as a parameter.
- **Documented Parameters**: A comprehensive list of supported flags and arguments will be added to this README as they are implemented.


## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---
**Author:** [Federico Bosetti]  
*Making secure file transfers easy and accessible on Windows.*