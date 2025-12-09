#Persistent
#SingleInstance Force

; === CONFIGURATION ===
TriggerHeight := 5      ; Bottom pixels to trigger showing
HideBuffer := 10        ; Safety buffer zone
CheckFreq := 50         ; Update speed (ms)

; Variables to track state
IsVisible := false

SetTimer, SmartBarLogic, %CheckFreq%
return

; ==============================
; ⌨️ WINDOWS KEY FIX
; ==============================
; When you press the Windows Key, force the taskbar to show immediately
~LWin::ShowTaskbar()
~RWin::ShowTaskbar()

; ==============================
; 🖱️ DESKTOP ICON TOGGLER
; ==============================
#If MouseIsOverDesktop()
MButton::
    ControlGet, hListView, Hwnd,, SysListView321, ahk_class Progman
    if !hListView
        ControlGet, hListView, Hwnd,, SysListView321, ahk_class WorkerW
    
    if DllCall("IsWindowVisible", "UInt", hListView)
        WinHide, ahk_id %hListView%
    else
        WinShow, ahk_id %hListView%
return
#If

; ==============================
; 🖥️ SMART TASKBAR LOGIC
; ==============================
SmartBarLogic:
    ; 1. Fullscreen Gaming Check (Priority #1)
    if IsFullscreen()
    {
        if (IsVisible)
            HideTaskbar()
        return
    }

    ; 2. Start Menu Check (Priority #2)
    ; If Start Menu is open, KEEP taskbar visible no matter where mouse is
    if IsStartMenuOpen()
    {
        if (!IsVisible)
            ShowTaskbar()
        return
    }

    ; 3. Standard Mouse Logic
    CoordMode, Mouse, Screen
    MouseGetPos, , MouseY
    
    WinGetPos, , , , TBHeight, ahk_class Shell_TrayWnd
    SafeTBHeight := (TBHeight > 0) ? TBHeight : 48
    
    if (!IsVisible) 
    {
        ; CASE A: Taskbar is HIDDEN -> Show if at bottom
        if (MouseY >= A_ScreenHeight - TriggerHeight)
            ShowTaskbar()
    }
    else 
    {
        ; CASE B: Taskbar is VISIBLE -> Keep until mouse leaves area
        CutoffPoint := A_ScreenHeight - SafeTBHeight - HideBuffer
        if (MouseY < CutoffPoint)
            HideTaskbar()
    }
return

; === ACTIONS ===
ShowTaskbar() {
    global IsVisible
    WinShow, ahk_class Shell_TrayWnd
    WinShow, ahk_class Shell_SecondaryTrayWnd
    IsVisible := true
}

HideTaskbar() {
    global IsVisible
    WinHide, ahk_class Shell_TrayWnd
    WinHide, ahk_class Shell_SecondaryTrayWnd
    IsVisible := false
}

; === HELPERS ===
IsFullscreen() {
    WinGet, winID, ID, A
    if !winID
        return false
    WinGetClass, winClass, ahk_id %winID%
    if (winClass = "Progman" or winClass = "WorkerW" or winClass = "Shell_TrayWnd")
        return false
    WinGetPos, X, Y, W, H, ahk_id %winID%
    return (X = 0 && Y = 0 && W = A_ScreenWidth && H = A_ScreenHeight)
}

IsStartMenuOpen() {
    ; Checks for standard Windows 10/11 Start Menu and Search classes
    return WinActive("Start ahk_class Windows.UI.Core.CoreWindow") 
        or WinActive("Search ahk_class Windows.UI.Core.CoreWindow")
}

MouseIsOverDesktop() {
    MouseGetPos,,, WinID
    WinGetClass, Class, ahk_id %WinID%
    return (Class = "Progman" || Class = "WorkerW")
}

; === MANUAL OVERRIDE (F12) ===
F12::
    Suspend
    if (A_IsSuspended) {
        SoundBeep, 500, 200
    } else {
        SoundBeep, 1000, 200
        IsVisible := false
    }
return
