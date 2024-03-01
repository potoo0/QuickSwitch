FileDialogDispatcher(winId) {
    ; Only consider this dialog a possible file-dialog when:
    ; (SysListView321 AND ToolbarWindow321) OR (DirectUIHWND1 AND ToolbarWindow321) controls detected
    ; First is for notepad/vscode...; second for all other filedialogs
    ; That is our rough detection of a File dialog. Returns 1 or 0 (TRUE/FALSE)
    flag := 0 ; bits: SysListView321 ToolbarWindow321 DirectUIHWND1 Edit1
    if (!WinExist("ahk_id " winId)) {
        return false
    }
    for control in WinGetControls("ahk_id " winId) {
        switch control {
            case "Edit1":
                flag |= 1
            case "DirectUIHWND1":
                flag |= 1 << 1
            case "ToolbarWindow321":
                flag |= 1 << 2
            case "SysListView321":
                flag |= 1 << 3
        }
        if (flag = 15) {
            break
        }
    }

    switch flag {
        case 7:
            return GeneralFileDialog
        case 13:
            return SysListWiewFileDialog
        default:
            return false
    }
}

class AbstractFileDialog {
    /**
     * update folder path
     * @param {Integer} winId ahk_id of file dialog
     * @param {Integer} dstFolder
     */
    UpdateCurrentFolder(winId, dstFolder) => ""
}

class GeneralFileDialog extends AbstractFileDialog {
    /**
     * update folder path. current manager didnot need instance var, set to static
     * @param {Integer} winId ahk_id of file dialog
     * @param {Integer} dstFolder
     */
    static UpdateCurrentFolder(winId, dstFolder) {
        if (!WinExist("ahk_id " winId)) {
            return
        }
        WinActivate("ahk_id " winId)
        Sleep(60)

        ; Focus file name input box
        ControlFocus("Edit1", "ahk_id " winId)
        controls := WinGetControls("ahk_id " winId)

        useToolbar := ""
        enterToolbar := ""
        for control in controls {
            If (!InStr(control, "ToolbarWindow32")) {
                continue
            }
            controlId := ControlGetHwnd(control, "ahk_id " winId)
            parentId := DllCall("GetParent", "Ptr", controlId)
            parentCls := WinGetClass("ahk_id " parentId)

            if (InStr(parentCls, "Breadcrumb Parent")) {
                useToolbar := control
            }
            if InStr(parentCls, "msctls_progress32") {
                enterToolbar := control
            }
        }
        if (useToolbar and enterToolbar) {
            folderSet := false
            loop 5 {
                SendInput("^l")
                sleep(100)

                ; Check and insert folder
                ctrlFocus := ControlGetClassNN(ControlGetFocus("A"))
                if (InStr(ctrlFocus, "Edit") and (ctrlFocus != "Edit1")) {
                    EditPaste(dstFolder, ctrlFocus, "A")
                    curFolder := ControlGetText(ctrlFocus, "ahk_id " winId)
                    folderSet := curFolder = dstFolder
                }
            } until folderSet

            if (folderSet) {
                ; Click control to "execute" new folder
                ControlClick(enterToolbar, "ahk_id " winId)

                ; Focus file name input box
                Sleep(15)
                ControlFocus("Edit1", "ahk_id " winId)
            }
        }
    }
}

class SysListWiewFileDialog extends AbstractFileDialog {
    /**
     * update folder path. current manager didnot need instance var, set to static
     * @param {Integer} winId ahk_id of file dialog
     * @param {Integer} dstFolder
     */
    static UpdateCurrentFolder(winId, dstFolder) {
        if (!WinExist("ahk_id " winId)) {
            return
        }
        WinActivate("ahk_id " winId)

        ; Read the current text in the "File Name:" input box
        oldText := ControlGetText("Edit1", "ahk_id " winId)
        Sleep(20)

        ; Make sure there exactly 1 \ at the end.
        dstFolder := RTrim(dstFolder, "\") . "\"

        folderSet := false
        loop 20 {
            Sleep(10)
            ControlSetText(dstFolder, "Edit1", "ahk_id " winId)
            curFolder := ControlGetText("Edit1", "ahk_id " winId)
            folderSet := curFolder = dstFolder
        } until folderSet

        if (folderSet) {
            Sleep(20)
            ControlFocus("Edit1", "ahk_id " winId)
            ControlSend("{Enter}", "Edit1", "ahk_id " winId)

            ; Restore  original filename / make empty in case of previous folder
            Sleep(15)
            ControlFocus("Edit1", "ahk_id " winId)
            Sleep(20)

            loop 5 {
                ControlSetText(oldText, "Edit1", "ahk_id " winId)
                Sleep(15)
                curFolder := ControlGetText("Edit1", "ahk_id " winId)
                if (curFolder = oldText)
                    break
            }
        }
    }
}