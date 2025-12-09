# SmartTaskbar.ahk: OLED & Gaming Taskbar Hider

Custom AutoHotkey script designed to replace the unreliable native Windows "Auto-hide" feature, providing seamless taskbar visibility control optimized for OLED monitors and fullscreen gaming.

---

## ✨ Features and Benefits

The script's logic directly addresses the flaws of standard Windows taskbar behavior:

- **🛡️ OLED Protection (Burn-In Fix):** Uses `WinHide` to completely remove the taskbar from the screen, eliminating the visible **1-pixel white line** left by Windows' native auto-hide. This is crucial for protecting OLED panels from static image burn-in.
- **🎮 Automatic Gaming Mode:** Automatically detects if any window is running in true fullscreen (like a game) and **disables the mouse-hover feature**, locking the taskbar hidden. This prevents accidental pop-ups during intense gameplay (e.g., aiming down).
- **🖱️ Smooth Interaction (Hysteresis):** Once triggered, the taskbar remains visible until the mouse moves completely **outside** the taskbar's vertical area. This eliminates the common "flicker" or "snapping shut" issue when you try to click an icon.
- **🎯 Custom Trigger Zone:** The activation zone is set to **5 pixels** at the bottom edge, providing a comfortable balance between ease-of-access and avoiding accidental activation.
- **⚙️ Manual Override:** Includes a hotkey (`F12` by default) to manually pause/lock the script, giving the user ultimate control if the automatic detection is ever wrong.

---

## 🛠️ Core Mechanism

The script operates using a simple **State-Based Timer** logic:

1.  **Detection:** A timer checks the active window every 50ms.
2.  **State Check:** If the window is fullscreen, the script forces the taskbar into a permanent `WinHide` state.
3.  **Hover Logic:** If the window is *not* fullscreen, the script checks the mouse position (`MouseY`). If the mouse is near the bottom edge (the 5px trigger), it issues a `WinShow` command. If the mouse leaves the taskbar's full vertical height, it immediately issues a `WinHide`.

---

## 🚀 Installation and Setup

1.  **Prerequisites:** You must have **AutoHotkey** (version 1.1) installed.
2.  **Download:** Save the script file as `SmartTaskbar.ahk`.
3.  **Startup:** Place a shortcut to the `.ahk` file in your Windows Startup Folder to ensure it runs automatically upon login.

    - *(To quickly open the Startup Folder, press `Win + R` and type `shell:startup`)*
