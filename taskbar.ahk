#Persistent
#SingleInstance Force

; === CONFIGURATION ===
TriggerHeight := 5      ; How close to bottom to SHOW the bar (pixels)
HideBuffer := 10        ; Extra pixels above taskbar to keep it open
CheckFreq := 50         ; Check speed (ms)

; Variables to track state
IsVisible := false

SetTimer, SmartBarLogic, %CheckFreq%
return

; ==============================
; 🖱️ DESKTOP ICON TOGGLER
; ==============================
; Trigger: Middle Mouse Button (Wheel Click) on Desktop
#If MouseIsOverDesktop()
MButton::
    ControlGet, hListView, Hwnd,, SysListView321, ahk_class Progman
    if !hListView ; Try WorkerW if Progman fails (Windows 10/11 fallback)
        ControlGet, hListView, Hwnd,, SysListView321, ahk_class WorkerW
    
    if DllCall("IsWindowVisible", "UInt", hListView)
        WinHide, ahk_id %hListView%
    else
        WinShow, ahk_id %hListView%
return
#If ; Reset context

; ==============================
; 🖥️ SMART TASKBAR LOGIC
; ==============================
SmartBarLogic:
    ; 1. Fullscreen Check (Gaming Mode) - Keeps taskbar hidden
    if IsFullscreen()
    {
        if (IsVisible)
            HideTaskbar()
        return
    }

    ; 2. Get Mouse Position & Taskbar Height
    CoordMode, Mouse, Screen
    MouseGetPos, , MouseY
    
    ; Get the actual height of the taskbar dynamically
    WinGetPos, , , , TBHeight, ahk_class Shell_TrayWnd
    SafeTBHeight := (TBHeight > 0) ? TBHeight : 48
    
    ; 3. Logic Core
    if (!IsVisible) 
    {
        ; CASE A: Taskbar is HIDDEN. Show if mouse is at bottom edge.
        if (MouseY >= A_ScreenHeight - TriggerHeight)
            ShowTaskbar()
    }
    else 
    {
        ; CASE B: Taskbar is VISIBLE. Keep it until mouse leaves the area.
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
