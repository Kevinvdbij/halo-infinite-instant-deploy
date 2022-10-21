#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force ; Only run one instance of this script.
SendMode Event  ; Set to Event mode because we use KeyDelay.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetKeyDelay, 25, 0 ; Without this delay the press can fail to register.

; Keybind globals
global UseBind := ""
global GrappleBind := ""
global SensorBind := ""
global WallBind := ""
global ThrusterBind := ""
global WindowBind := ""
global UseSwap := ""
global WindowOnStart := ""

global WindowPosX := ""
global WindowPosY := ""

; Script globals
global ScriptName = regexreplace(A_scriptname,"\..*","")
global ConfigPath := ScriptName . ".ini"
global IconPath := ScriptName . ".ico"
global DetectedKey := ""
global DebugMode := false

; Load configuration
LoadIni(false)

; Assign hotkeys
Hotkey, $*%GrappleBind%, UseAbility, on
Hotkey, $*%SensorBind%, UseAbility, on
Hotkey, $*%WallBind%, UseAbility, on
Hotkey, $*%ThrusterBind%, UseAbility, on
Hotkey, $*%WindowBind%, HideWindow, on

if (FileExist(IconPath)) {
    Menu, tray, Icon , %IconPath%
}

; Create menu bar entries
SaveFunc := Func("SaveIni").Bind("all")
Menu, ConfigMenu, Add, Save, %SaveFunc%
Menu, ConfigMenu, Add, Reset, ResetIni

Menu, ScriptMenu, Add, Reload, ReloadScript
Menu, ScriptMenu, Add, Pause, PauseScript

IsChecked := !A_IsSuspended ? "Check" : "Uncheck"
Menu, ScriptMenu, Add, Hotkeys, SuspendHotkeys
Menu, ScriptMenu, %IsChecked%, Hotkeys

Menu, ScriptMenu, Add, Debug, ToggleDebug
Menu, ScriptMenu, Add, Exit, Exit

Menu, Tray, NoStandard
Menu, Tray, Add, Open Instant Deploy Window, ShowWindow
Menu, Tray, Add, ; Divider
Menu, Tray, Add, Reload Script, ReloadScript
Menu, Tray, Add, Pause Script, PauseScript
Menu, Tray, Add, Suspend Hotkeys, SuspendHotkeys
Menu, Tray, Add, Exit, Exit
Menu, Tray, Add, ; Divider
Menu, Tray, Add, Debug Mode, ToggleDebug

Menu, MenuBar, Add, Script, :ScriptMenu
Menu, MenuBar, Add, Config, :ConfigMenu

Gui, Menu, MenuBar

; Create GUI controls
Gui, +AlwaysOnTop -MaximizeBox

Gui, Font, s8, Verdana

Gui, Add, Text, vUseText w120 Center section,
Gui, Add, Button, Default w120 gSetUseClicked vSetUseButton,

Gui, Add, Text, vSensorText w120 Center,
Gui, Add, Button, Default w120 gSetSensorClicked vSetSensorButton,

Gui, Add, Text, vThrusterText w120 Center,
Gui, Add, Button, Default w120 gSetThrusterClicked vSetThrusterButton,

Gui, Font, s7, Verdana
Gui, Add, CheckBox, gUseSwapChecked vUseSwap w120 h50 Checked%UseSwap% Center,
Gui, Font, s8, Verdana

Gui, Add, Button, Default w120 section, Hide

Gui, Add, Text, vGrappleText w120 Center ym,
Gui, Add, Button, Default w120 gSetGrappleClicked vSetGrappleButton,

Gui, Add, Text, vWallText w120 Center,
Gui, Add, Button, Default w120 gSetWallClicked vSetWallButton,

Gui, Add, Text, vWindowText w120 Center,
Gui, Add, Button, Default w120 gSetWindowClicked vSetWindowButton,

Gui, Font, s7, Verdana
Gui, Add, CheckBox, gWindowOnStartChecked vWindowOnStart w120 h50 Checked%WindowOnStart% Center,
Gui, Font, s8, Verdana

Gui, Add, Button, Default w120, Stop

PopulateGUI()

; Show window on start
If (WindowOnStart = true) {
    ShowWindow()
}

; Link Use and Grapple keys
IsSwapped := UseSwap ? "on" : "off"
Hotkey, *%UseBind%, SendGrapple, %IsSwapped%

ExitFunc := Func("SaveIni").Bind("window")
OnExit(ExitFunc)

return

ResetIni() {
    LoadIni(true)
    SaveIni("all")
    PopulateGUI()
    ShowWindow()
    Return
}

SetUseClicked:
    Gui, Submit, NoHide

    GuiControl,,SetUseButton, ...
    Gosub, ListenForKey

    Hotkey, $*%UseBind%, off
    UseBind := DetectedKey
    Hotkey, $*%UseBind%, UseAbility, on

    SaveIni("keybinds")

    PopulateGUI()
    return

SetGrappleClicked:
    Gui, Submit, NoHide

    GuiControl,,SetGrappleButton, ...
    Gosub, ListenForKey

    Hotkey, $*%GrappleBind%, off
    GrappleBind := DetectedKey
    Hotkey, $*%GrappleBind%, UseAbility, on

    SaveIni("keybinds")

    PopulateGUI()
    return

SetSensorClicked:
    Gui, Submit, NoHide

    GuiControl,,SetSensorButton, ...
    Gosub, ListenForKey

    Hotkey, $*%SensorBind%, off
    SensorBind := DetectedKey
    Hotkey, $*%SensorBind%, UseAbility, on

    SaveIni("keybinds")

    PopulateGUI()
    return

SetWallClicked:
    Gui, Submit, NoHide

    GuiControl,,SetWallButton, ...
    Gosub, ListenForKey

    Hotkey, $*%WallBind%, off
    WallBind := DetectedKey
    Hotkey, $*%WallBind%, UseAbility, on

    SaveIni("keybinds")

    PopulateGUI()
    return

SetThrusterClicked:
    Gui, Submit, NoHide

    GuiControl,,SetThrusterButton, ...
    Gosub, ListenForKey

    Hotkey, $*%ThrusterBind%, off
    ThrusterBind := DetectedKey
    Hotkey, $*%ThrusterBind%, UseAbility, on

    SaveIni("keybinds")

    PopulateGUI()
    return

SetWindowClicked:
    Gui, Submit, NoHide

    GuiControl,,SetWindowButton, ...
    Gosub, ListenForKey

    Hotkey, $*%WindowBind%, off
    WindowBind := DetectedKey
    Hotkey, %WindowBind%, HideWindow, on

    SaveIni("keybinds")

    PopulateGUI()
    return


UseSwapChecked:
    Gui, Submit, NoHide

    IsSwapped := UseSwap ? "on" : "off"
    Hotkey, *%UseBind%, SendGrapple, %IsSwapped%
    SaveIni("keybinds")

    return

WindowOnStartChecked:
    Gui, Submit, NoHide

    SaveIni("keybinds")
    return


ButtonHide:
    HideWindow()
    return

ButtonStop:
ExitApp

GuiClose:
    if WinExist("Instant Deploy")
    {
        WinGetPos, X, Y

        IniWrite, %X%, % ConfigPath, window, x
        IniWrite, %Y%, % ConfigPath, window, y
    }
ExitApp

ListenForKey:
    loop {
        if (key := AnyKeyIsDown(1,1)) {
            DetectedKey := key
            return
        }
    }

; courtesy of /u/deleted ;(
AnyKeyIsDown(detectKeyboard:=1,detectMouse:=1) { ; return whatever key is down that has the largest scan code
	if (detectKeyboard) {
		loop % 86 { ; detect all common physical keys: https://www.win.tue.nl/~aeb/linux/kbd/scancodes-1.html
			if (GetKeyState(keyname:=GetKeyName("sc" Format("{1:x}",A_Index)))) {
				return keyname
			}
		}
	}
	if (detectMouse) {
		mouseArr := ["LButton","RButton","MButton","XButton1","XButton2"]
		loop % mouseArr.Count() {
			if (GetKeyState(mouseArr[A_Index])) {
				return mouseArr[A_Index]
			}
		}
	}
	return ""
}

;Fire ability swap key and use equipment key.
UseAbility() {
    UsedHotkey := RegExReplace(A_ThisHotkey, "\$\*")

    if (WinActive("ahk_exe haloinfinite.exe") or DebugMode) {
        Send {Blind}{%UsedHotkey%}{%UseBind%}
        KeyWait % UsedHotkey
        return
    }
    Send {Blind}{%UsedHotkey%}

    ;Send {LAlt}
}

LoadIni(UseDefaults) {
    IniRead, UseBindValue, % ConfigPath, keybinds, usebind, q
    IniRead, GrappleBindValue, % ConfigPath, keybinds, grapplebind, o
    IniRead, SensorBindValue, % ConfigPath, keybinds, sensorbind, c
    IniRead, WallBindValue, % ConfigPath, keybinds, wallbind, f
    IniRead, ThrusterBindValue, % ConfigPath, keybinds, thrusterbind, LAlt
    IniRead, WindowBindValue, % ConfigPath, keybinds, windowbind, Home
    IniRead, SwapUseValue, % ConfigPath, keybinds, useswap, 1
    IniRead, WindowOnStartValue, % ConfigPath, keybinds, x, 1
    
    ; Keybinds
    UseBind := (UseDefaults ? "q" : UseBindValue)
    GrappleBind := (UseDefaults ? "o" : GrappleBindValue)
    SensorBind := (UseDefaults ? "c" : SensorBindValue)
    WallBind := (UseDefaults ? "f" : WallBindValue)
    ThrusterBind := (UseDefaults ? "LAlt" : ThrusterBindValue)
    WindowBind := (UseDefaults ? "Home" : WindowBindValue)
    UseSwap := (UseDefaults ? "1" : SwapUseValue)
    WindowOnStart := (UseDefaults ? "1" : WindowOnStartValue)

    ; Window
    DefaultWidth := A_ScreenWidth - 295
    DefaultHeight := A_ScreenHeight - 360

    IniRead, X, % ConfigPath, window, x, %DefaultWidth%
    IniRead, Y, % ConfigPath, window, y, %DefaultHeight%

    WindowPosX := (UseDefaults ? DefaultWidth : X)
    WindowPosY := (UseDefaults ? DefaultHeight : Y)
}

SaveIni(section := "all") {
    if (section = "keybinds" or section = "all") {
        IniWrite, %UseBind%, % ConfigPath, keybinds, usebind
        IniWrite, %GrappleBind%, % ConfigPath, keybinds, grapplebind
        IniWrite, %SensorBind%, % ConfigPath, keybinds, sensorbind
        IniWrite, %WallBind%, % ConfigPath, keybinds, wallbind
        IniWrite, %ThrusterBind%, % ConfigPath, keybinds, thrusterbind
        IniWrite, %WindowBind%, % ConfigPath, keybinds, windowbind
        IniWrite, %UseSwap%, % ConfigPath, keybinds, useswap
        IniWrite, %WindowOnStart%, % ConfigPath, keybinds, windowonstart
    }

    if (section = "window" or section = "all") {
        if WinExist("Instant Deploy")
        {
            WinGetPos, X, Y

            IniWrite, %X%, % ConfigPath, window, x
            IniWrite, %Y%, % ConfigPath, window, y
        }
    }
}

PopulateGUI() {
    GuiControl,,UseText, Use Equipment: %UseBind%
    GuiControl,,SetUseButton, Set

    GuiControl,,GrappleText, Grappleshot: %GrappleBind%
    GuiControl,,SetGrappleButton, Set

    GuiControl,,SensorText, Threat Sensor: %SensorBind%
    GuiControl,,SetSensorButton, Set

    GuiControl,,WallText, Drop Wall: %WallBind%
    GuiControl,,SetWallButton, Set

    GuiControl,,ThrusterText, Thruster: %ThrusterBind%
    GuiControl,,SetThrusterButton, Set

    GuiControl,,WindowText, Menu: %WindowBind%
    GuiControl,,SetWindowButton, Set

    GuiControl,,UseSwap, Grapple with Use Equipment key
    GuiControl,,WindowOnStart, Show window on start
}

ShowWindow() {
    Gui, -Owner
    
    Gui, Show, w270 h240 x%WindowPosX% y%WindowPosY% NoActivate, Instant Deploy

    Hotkey, $*%WindowBind%, HideWindow, on
}

HideWindow() {
    Gui, +Owner
    Gui, Hide

    Hotkey, $*%WindowBind%, ShowWindow, on
}

SendGrapple() {
    if (WinActive("ahk_exe haloinfinite.exe") or DebugMode) {
        SendLevel, 1
        Send {Blind}%GrappleBind%
    }
    Send %UseBind%
}

ReloadScript() {
    Reload
    Sleep 1000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
    MsgBox, 4,, The script could not be reloaded. Would you like to open it for editing?
    IfMsgBox, Yes, Edit
    return
}

PauseScript() {
    IsChecked := !A_IsPaused ? "Check" : "Uncheck"
    Menu, Tray, %IsChecked%, Pause Script
    Menu, ScriptMenu, %IsChecked%, Pause
    
    Pause, Toggle
}

Exit() {
    ExitApp
}

ToggleDebug() {
    DebugMode := !DebugMode
    
    IsChecked := DebugMode ? "Check" : "Uncheck"
    Menu, Tray, %IsChecked%, Debug Mode
    Menu, ScriptMenu, %IsChecked%, Debug
}

SuspendHotkeys() {
    Suspend, Toggle
    
    IsChecked := A_IsSuspended ? "Check" : "Uncheck"
    Menu, Tray, %IsChecked%, Suspend Hotkeys

    IsChecked := !A_IsSuspended ? "Check" : "Uncheck"
    Menu, ScriptMenu, %IsChecked%, Hotkeys
}