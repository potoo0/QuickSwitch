#Include Config.ahk
#Include FileManager.ahk


ShowFolderSelector(*) {
    ; double check file dialog
    if (!WinExist("ahk_id" Context.WinID) || !(WinActive("ahk_id" Context.WinID) || WinActive("ahk_id " A_ScriptHwnd))) {
        return
    }
    folders := GetAllFolder()
    if (!folders or !folders.Length) {
        return
    }

    ; create menu
    contextMenu := createMenu(folders)

    ; double check file dialog
    if (WinExist("ahk_id" Context.WinID) && (WinActive("ahk_id" Context.WinID) || WinActive("ahk_id " A_ScriptHwnd))) {
        ; manually calc pos, as the file dialog not active
        WinGetPos(&posX, &posY,,, "ahk_id" Context.WinID)
        contextMenu.Show(posX + 200, posY + 200) ; halt main thread
    }

    destroyMenu()

    createMenu(folders) {
        ;	--------------- [ Title Bar ] ---------------
        contextMenu := Menu()

        ; --------------- [ folders ] ---------------
        for idx, folder in folders {
            name := idx <= 10 ? ("&" idx " " folder) : folder
            contextMenu.Add(name, onFolderChoice)
            contextMenu.SetIcon(name, "shell32.dll", 5)
        }

        ; --------------- [ Settings ] ---------------
        contextMenu.Add()
        contextMenu.Add("&Never here", onMenuDisable, "Radio")
        contextMenu.SetIcon("&Never here", "shell32.dll", 110)
        contextMenu.Add("&Not now", onResetConfig, "Radio")
        contextMenu.SetIcon("&Not now", "shell32.dll", 132)
        contextMenu.Add("&Debug this dialog", DebugFileDialog)
        contextMenu.SetIcon("&Debug this dialog", "shell32.dll", 57)

        ; --------------- [ Style ] ---------------
        contextMenu.SetColor("C0C59C")

        return contextMenu := contextMenu
    }

    destroyMenu() {
        ; delete all menu items.
        contextMenu.Delete()
    }

    onFolderChoice(itemName, *) {
        if (RegExMatch(itemName, "^&\d\W", &OutputVar)) {
            itemName := SubStr(itemName, StrLen(OutputVar[0]) + 1)
        }
        if (Context.FileDialog and DirExist(itemName)) {
            Context.FileDialog.UpdateCurrentFolder(Context.WinID, itemName)
        }
    }

    onMenuDisable(*) {
        CFG.UpdateConfig(Context.FingerPrint, 0)
    }

    onResetConfig(*) {
        CFG.DeleteConfig(Context.FingerPrint)
    }
}


DebugFileDialog(*) {
    debugGui := Gui()
    listView := debugGui.Add("ListView", "r30 w800", ["Control", "ID", "PID", "Text", "X", "Y", "Width", "Height"])

    appendFileDialogInfo()

    listView.ModifyCol(2, "Integer")
    listView.ModifyCol(3, "Integer")
    listView.ModifyCol()  ; Auto-size each column to fit its contents.

    exportBtn := debugGui.Add("Button", "y+10 w100 h30", "Export")
    exportBtn.OnEvent("Click", export)
    cancelBtn := debugGui.Add("Button", "x+10 w100 h30", "Cancel")
    cancelBtn.OnEvent("Click", cancel)

    Context.DebugViewHwnd := debugGui.Hwnd
    debugGui.OnEvent("Escape", cancel)
    debugGui.Show()

    appendFileDialogInfo() {
        winId := WinExist("ahk_id " Context.WinID)
        if (!winId) {
            return
        }

        ;	get last active window's control list
        controlIds := WinGetControlsHwnd("ahk_id " winId)
        for ctrlId in controlIds {
            ctrlName := ControlGetClassNN(ctrlId)
            ctrlText := ControlGetText(ctrlId, "ahk_id " winId)
            ControlGetPos(&posX, &posY, &posWidth, &posHeight, ctrlId, "ahk_id " winId)
            parentId := DllCall("GetParent", "Ptr", ctrlId)

            ; ;	Add to listview
            listView.Add(, ctrlName, ctrlId, parentId, ctrlText, posX, posY, posWidth, posHeight)
        }
    }

    export(*) {
        fileName := A_ScriptDir . "\" . Context.FingerPrint . ".csv"
        try {
            fileObj := FileOpen(FileName, "w", "UTF-8")
        } catch as Err {
            MsgBox("Can't open '" FileName "' for writing." "`n`nError " Err.Extra ": " Err.Message)
            return
        }

        rows := listView.GetCount()
        cols := listView.GetCount("Column")
        loop rows + 1 {
            rowIdx := A_Index - 1
            line := ""
            loop cols {
                line .= listView.GetText(rowIdx, A_Index)
                if (A_Index != cols) {
                    line .= ','
                }
            }
            fileObj.WriteLine(line)
        }
        fileObj.Close()
        MsgBox("Export to " fileName " finish.")
    }

    cancel(*) {
        debugGui.Destroy()
    }
}