# ◈ PHANTOM OS

A fake desktop OS running natively on iOS. Built with SwiftUI.

## Features

- **POST Screen** — BIOS-style boot text on first launch
- **Boot Animation** — Animated logo + progress bar
- **Particle Desktop** — Animated particle wallpaper with grid overlay
- **Draggable Windows** — Glassmorphic floating windows, drag by title bar
- **Terminal** — Fake shell: `help`, `ls`, `cat`, `neofetch`, `matrix`, `echo`, `date`, etc.
- **Notes** — Multi-note editor with sidebar
- **Calculator** — Fully functional with expression display
- **System Info** — neofetch-style panel with live uptime clock
- **Dock** — Bottom dock with open-app indicators

## Build & Install (no Mac needed)

### 1. Push to GitHub
```sh
git init
git remote add origin https://github.com/YOU/PHANTOM.git
git add .
git commit -m "init"
git push -u origin main
```

### 2. Get the IPA
- Go to **Actions** tab in your repo
- Click the latest **Build PHANTOM IPA** run
- Download the **PHANTOM-unsigned-ipa** artifact (zip)
- Extract → `PHANTOM-unsigned.ipa`

### 3. Sideload with Sideloadly
1. Download [Sideloadly](https://sideloadly.io) on Windows
2. Connect iPhone via USB
3. Drag `PHANTOM-unsigned.ipa` into Sideloadly
4. Enter your Apple ID
5. Click Start

### 4. Trust the app
Settings → General → VPN & Device Management → Trust your Apple ID

## Project Structure
```
PHANTOM/
├── .github/workflows/build.yml   # CI/CD → unsigned IPA
├── project.yml                   # XcodeGen spec
└── PHANTOM/
    ├── PhantomApp.swift           # Entry point
    ├── RootView.swift             # Phase manager
    ├── POSTView.swift             # BIOS screen
    ├── BootView.swift             # Boot animation
    ├── DesktopView.swift          # Desktop + dock + topbar
    ├── WindowManager.swift        # Window state + z-index
    ├── FloatingWindow.swift       # Draggable window frame
    ├── ParticleWallpaper.swift    # Canvas particles + grid
    ├── TerminalView.swift         # Fake shell
    ├── NotesView.swift            # Notes app
    ├── CalculatorView.swift       # Calculator
    ├── SystemInfoView.swift       # System info panel
    ├── Extensions.swift           # Color(hex:)
    ├── Info.plist
    └── Assets.xcassets/
```

## Terminal Commands
| Command | Description |
|---------|-------------|
| `help` | List all commands |
| `ls` | List files |
| `cat <file>` | View file (try `readme.txt`, `.secrets`) |
| `pwd` | Print directory |
| `whoami` | Print user |
| `uname` | System info |
| `neofetch` | ASCII art system info |
| `echo <text>` | Print text |
| `date` | Current date/time |
| `clear` | Clear terminal |
| `matrix` | 👀 |
