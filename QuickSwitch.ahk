#Requires AutoHotkey >=2.0
#SingleInstance force

ThisVersion := "0.5.1"

;@Ahk2Exe-SetVersion 0.5.1
;@Ahk2Exe-SetName QuickSwitch
;@Ahk2Exe-SetDescription Use opened file manager folders in File dialogs.
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
    Context.WinID := WinID

    FileDialog := FileDialogDispatcher(WinID)
    Context.FileDialog := FileDialog

    if (FileDialog) {
        Context.InitFingerPrint(WinID)

        switch CFG.GetConfig(Context.FingerPrint) {
            case 0:
                ; Never here, do nothing
            default:
                ShowFolderSelector()
        }
    }

    ; wait windows file dialog not active
    WinWaitNotActive("ahk_id " WinID)

    ; Clean up
    WinID := ""
    FileDialog := ""
}

MsgBox("We never get here (and that's how it should be)")
ExitApp()