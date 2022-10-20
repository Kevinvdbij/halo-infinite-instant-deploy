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

; Script globals
global ScriptName = regexreplace(A_scriptname,"\..*","")
global ConfigPath := ScriptName . ".ini"
global IconPath := ScriptName . ".ico"
global DetectedKey := ""

; Load configuration
LoadIni(false)
OnExit("SaveIni")

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
Menu, ConfigMenu, Add, Save, SaveIni
Menu, ConfigMenu, Add, Reset, ResetIni
Menu, MenuBar, Add, Settings, :ConfigMenu

Gui, Menu, MenuBar

; Create GUI controls
Gui, +AlwaysOnTop +Owner -0x30000

Gui, Font, s8, Verdana

Gui, Add, Text, vUseText w120 Center section,
Gui, Add, Button, Default w120 gSetUse vSetUseButton,

Gui, Add, Text, vSensorText w120 Center,
Gui, Add, Button, Default w120 gSetSensor vSetSensorButton,

Gui, Add, Text, vThrusterText w120 Center,
Gui, Add, Button, Default w120 gSetThruster vSetThrusterButton,

Gui, Font, s7, Verdana
Gui, Add, CheckBox, gSwapUseBind vUseSwap w120 h50 Checked%UseSwap% Center,
Gui, Font, s8, Verdana

Gui, Add, Button, Default w120 section, Hide

Gui, Add, Text, vGrappleText w120 Center ym,
Gui, Add, Button, Default w120 gSetGrapple vSetGrappleButton,

Gui, Add, Text, vWallText w120 Center,
Gui, Add, Button, Default w120 gSetWall vSetWallButton,

Gui, Add, Text, vWindowText w120 Center,
Gui, Add, Button, Default w120 gSetWindow vSetWindowButton,

Gui, Font, s7, Verdana
Gui, Add, CheckBox, vWindowOnStart w120 h50 Checked%WindowOnStart% Center,
Gui, Font, s8, Verdana

Gui, Add, Button, Default w120, Stop

PopulateGUI()

; Show window on start
If (WindowOnStart = true) {
    ShowWindow()
}

; Link Use and Grapple keys
#If SwapUse
    Gosub SwapUseBind

#If WinActive("ahk_exe haloinfinite.exe") ; Only trigger hotkeys in game window.
return

ButtonHide:
    HideWindow()
    return

ButtonStop:
SaveIni()
ExitApp

GuiClose:
SaveIni()
ExitApp

ResetIni:
    LoadIni(true)
    PopulateGUI()
    SaveIni()
    Return

SetUse:
    GuiControl,,SetUseButton, ...
    Gosub, ListenForKey

    Hotkey, $*%UseBind%, off
    UseBind := DetectedKey
    Hotkey, $*%UseBind%, UseAbility, on

    PopulateGUI()
    return

SetGrapple:
    GuiControl,,SetGrappleButton, ...
    Gosub, ListenForKey

    Hotkey, $*%GrappleBind%, off
    GrappleBind := DetectedKey
    Hotkey, $*%GrappleBind%, UseAbility, on

    PopulateGUI()
    return

SetSensor:
    GuiControl,,SetSensorButton, ...
    Gosub, ListenForKey

    Hotkey, $*%SensorBind%, off
    SensorBind := DetectedKey
    Hotkey, $*%SensorBind%, UseAbility, on

    PopulateGUI()
    return

SetWall:
    GuiControl,,SetWallButton, ...
    Gosub, ListenForKey

    Hotkey, $*%WallBind%, off
    WallBind := DetectedKey
    Hotkey, $*%WallBind%, UseAbility, on

    PopulateGUI()
    return

SetThruster:
    GuiControl,,SetThrusterButton, ...
    Gosub, ListenForKey

    Hotkey, $*%ThrusterBind%, off
    ThrusterBind := DetectedKey
    Hotkey, $*%ThrusterBind%, UseAbility, on

    PopulateGUI()
    return

SetWindow:
    GuiControl,,SetWindowButton, ...
    Gosub, ListenForKey

    Hotkey, $*%WindowBind%, off
    WindowBind := DetectedKey
    Hotkey, $*%WindowBind%, UseAbility, on

    PopulateGUI()
    return

ListenForKey:
    loop {
        if (key := AnyKeyIsDown(1,1)) {
            DetectedKey := key
            return
        }
    }


SwapUseBind:
    Gui, Submit, NoHide
    Hotkey, *%UseBind%, SendGrapple, off

    if (UseSwap = true) {
        Hotkey, *%UseBind%, on
    }

    return

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
    Send {Blind}{%UsedHotkey%}%UseBind%
    KeyWait % UsedHotkey
    return
}

LoadIni(UseDefaults) {
    IniRead, UseBindValue, % ConfigPath, keybinds, usebind, q
    IniRead, GrappleBindValue, % ConfigPath, keybinds, grapplebind, o
    IniRead, SensorBindValue, % ConfigPath, keybinds, sensorbind, c
    IniRead, WallBindValue, % ConfigPath, keybinds, wallbind, f
    IniRead, ThrusterBindValue, % ConfigPath, keybinds, thrusterbind, LAlt
    IniRead, WindowBindValue, % ConfigPath, keybinds, windowbind, Home
    IniRead, SwapUseValue, % ConfigPath, keybinds, swapuse, 1
    IniRead, WindowOnStartValue, % ConfigPath, keybinds, windowonstart, 1
    
    UseBind := (UseDefaults ? "q" : UseBindValue)
    GrappleBind := (UseDefaults ? "o" : GrappleBindValue)
    SensorBind := (UseDefaults ? "c" : SensorBindValue)
    WallBind := (UseDefaults ? "f" : WallBindValue)
    ThrusterBind := (UseDefaults ? "LAlt" : ThrusterBindValue)
    WindowBind := (UseDefaults ? "Home" : WindowBindValue)
    UseSwap := (UseDefaults ? "1" : SwapUseValue)
    WindowOnStart := (UseDefaults ? "1" : WindowOnStartValue)
}

SaveIni() {
    Gui, Submit, NoHide

    IniWrite, %UseBind%, % ConfigPath, keybinds, usebind
    IniWrite, %GrappleBind%, % ConfigPath, keybinds, grapplebind
    IniWrite, %SensorBind%, % ConfigPath, keybinds, sensorbind
    IniWrite, %WallBind%, % ConfigPath, keybinds, wallbind
    IniWrite, %ThrusterBind%, % ConfigPath, keybinds, thrusterbind
    IniWrite, %WindowBind%, % ConfigPath, keybinds, windowbind
    IniWrite, %UseSwap%, % ConfigPath, keybinds, swapuse
    IniWrite, %WindowOnStart%, % ConfigPath, keybinds, windowonstart
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

    GuiControl,,WindowText, Toggle Window: %WindowBind%
    GuiControl,,SetWindowButton, Set

    GuiControl,,UseSwap, Grapple with Use Equipment key
    GuiControl,,WindowOnStart, Show window on start
}

ShowWindow() {
    OffsetX := A_ScreenWidth - 300
    OffsetY := A_ScreenHeight - 316

    Gui, Show, w270 h240 x%OffsetX% y%OffsetY% NoActivate, Instant Deploy

    Hotkey, $*%WindowBind%, HideWindow, on
}

HideWindow() {
    Gui, Hide

    Hotkey, $*%WindowBind%, ShowWindow, on
}

SendGrapple() {
    SendLevel, 1
    Send {Blind}%GrappleBind%
}