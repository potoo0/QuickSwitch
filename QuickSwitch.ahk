#Requires AutoHotkey >=2.0
#SingleInstance force

ThisVersion := "0.5.1"

;@Ahk2Exe-SetVersion 0.5.1
;@Ahk2Exe-SetName QuickSwitch
;@Ahk2Exe-SetDescription QuickSwitch ; the script's name in Task Manager under "Processes".
;@Ahk2Exe-SetCopyright NotNull

#Include Libs\Config.ahk
#Include Libs\FileDialog.ahk
#Include Libs\FolderSelector.ahk

;_____________________________________________________________________________
;
;					SETTINGS
;_____________________________________________________________________________
;
SendMode("Input")           ; SendInput and SendPlay use the same syntax as SendEvent but are generally faster and more reliable.
SetWorkingDir(A_ScriptDir)  ; working dir for rw ini config file.
CoordMode("Menu")           ; set the coord of menu relative to the desktop (entire screen)

; CTRL-Q
MENU_HOTKEY := "^Q"
; #32770: windows file dialog class
FILE_DIALOG_CLASS := "#32770"

;_____________________________________________________________________________
;
;         ACTION!
;_____________________________________________________________________________
;
; Check if Win7 SP1 or higher; if not: exit
If (VerCompare(A_OSVersion, "<6.1.7601")) {
    MsgBox(A_OSVersion " is not supported.")
    ExitApp
}

; bind menu hotkey, but only work when file dialog is active
HotIfWinActive("ahk_class " FILE_DIALOG_CLASS) ; make context-sensitive
Hotkey(MENU_HOTKEY, ShowFolderSelector)
HotIfWinActive ; turn off context-sensitive

; listen file dialog event
Loop {
    WinID := WinWaitActive("ahk_class " FILE_DIALOG_CLASS)
    Context.Update(WinID)

    FileDialog := FileDialogDispatcher(WinID)
    Context.FileDialog := FileDialog

    if (FileDialog) {
        Context.InitFingerPrint(WinID)

        switch CFG.GetConfig(Context.FingerPrint) {
            case 0:
                ; Never here, do nothing
            default:
                ; active script's window, see https://github.com/samhocevar-forks/ahk/blob/master/source/script_menu.cpp#L1273
                ;   must ensure one of the script's windows is active before showing the menu
                ;   because otherwise the menu cannot be dismissed via the escape key or by clicking outside the menu.
                DetectHiddenWindows true
                WinActivate("ahk_id " A_ScriptHwnd)
                ShowFolderSelector()
                ; restore active state if needed
                if (!Context.DebugViewHwnd) {
                    WinActivate("ahk_id " WinID)
                }
                ; move script's window to bottom
                WinMoveBottom("ahk_id " A_ScriptHwnd)
                DetectHiddenWindows false
        }
    }

    ; wait windows file dialog not active
    WinWaitNotActive("ahk_id " WinID)

    ; Clean up
    Context.Update("")
    CFG.ClearCache()
    WinID := ""
    FileDialog := ""
}

MsgBox("We never get here (and that's how it should be)")
ExitApp()