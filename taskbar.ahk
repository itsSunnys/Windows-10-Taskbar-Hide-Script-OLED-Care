#Persistent
#SingleInstance Force

; === CONFIGURATION ===
TriggerHeight := 5      ; How close to bottom to SHOW the bar (pixels)
HideBuffer := 10        ; Extra pixels above the taskbar to keep it open (for safety)
CheckFreq := 50         ; Check faster (50ms) for smoother responsiveness

; Variables to track state
IsVisible := false

SetTimer, SmartBarLogic, %CheckFreq%
return

SmartBarLogic:
    ; 1. Fullscreen Check (Gaming Mode) - Keeps it hidden
    if IsFullscreen()
    {
        if (IsVisible) ; Force hide if we entered fullscreen
        {
            HideTaskbar()
        }
        return
    }

    ; 2. Get Mouse Position & Taskbar Height
    CoordMode, Mouse, Screen
    MouseGetPos, , MouseY
    
    ; Get the actual height of the taskbar dynamically
    WinGetPos, , , , TBHeight, ahk_class Shell_TrayWnd
    ; If TBHeight is 0 (hidden), assume a standard height (e.g., 48) to avoid bugs
    SafeTBHeight := (TBHeight > 0) ? TBHeight : 48
    
    ; === LOGIC CORE ===
    
    if (!IsVisible) 
    {
        ; CASE A: Taskbar is HIDDEN. 
        ; We only show it if mouse is at the very bottom edge.
        if (MouseY >= A_ScreenHeight - TriggerHeight)
        {
            ShowTaskbar()
        }
    }
    else 
    {
        ; CASE B: Taskbar is VISIBLE.
        ; We KEEP it visible as long as mouse is inside the taskbar area.
        ; (Screen Height - Taskbar Height - Buffer)
        CutoffPoint := A_ScreenHeight - SafeTBHeight - HideBuffer
        
        if (MouseY < CutoffPoint)
        {
            ; Mouse has moved UP and OUT of the taskbar area -> Hide it
            HideTaskbar()
        }
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

; === FULLSCREEN DETECTION ===
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

; === MANUAL OVERRIDE (F12) ===
F12::
    Suspend
    if (A_IsSuspended) {
        SoundBeep, 500, 200
    } else {
        SoundBeep, 1000, 200
        IsVisible := false ; Reset state on resume
    }
return