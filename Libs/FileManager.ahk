GetAllFolder() {
    allFolders := []

    ; skip hidden windows
    DetectHiddenWindowsStateOld := A_DetectHiddenWindows
    DetectHiddenWindows false
    windows := WinGetlist()
    DetectHiddenWindows DetectHiddenWindowsStateOld

    ; parse foler
    folderMap := Map() ; ensure folder unique
    for winId in windows {
        winCls := WinGetClass("ahk_id " winId)
        fileManager := ""
        switch winCls {
            case ExplorerFileManager.WinCls: fileManager := ExplorerFileManager
        }
        if (!fileManager) {
            continue
        }

        folders := fileManager.GetCurrentFolder(winId, true)
        if (folders and folders.Length) {
            for folder in folders {
                if (!folderMap.Has(folder)) {
                    allFolders.Push(folder)
                    folderMap.Set(folder, true)
                }
            }
        }
    }
    return allFolders
}

class AbstractFileManager {
    /**
     * get folder path of spec file manager
     * @param {Integer} winId ahk_id of file manager
     * @param {Integer} allTab query all tab
     * @returns {String[]} folder path
     */
    GetCurrentFolder(winId, allTab := false) => []
}

class ExplorerFileManager extends AbstractFileManager {
    static WinCls := "CabinetWClass"
    static IID_IShellBrowser := "{000214E2-0000-0000-C000-000000000046}"

    /**
     * get folder path of spec file manager. current manager didnot need instance var, set to static
     * @param {Integer} winId ahk_id of file manager
     * @param {Integer} allTab query all tab
     * @returns {String[]} folder path
     */
    static GetCurrentFolder(winId, allTab := false) {
        ; precheck
        if (!WinExist("ahk_id " winId) or WinGetClass("ahk_id " winId) != ExplorerFileManager.WinCls) {
            return
        }

        ; query folder path
        folders := []
        activeTab := ControlGetHwnd("ShellTabWindowClass1", "ahk_id " winId)
        for window in ComObject("Shell.Application").Windows {
            if (window.hwnd != winId) {
                continue
            }
            if (!allTab and activeTab) {
                shellBrowser := ComObjQuery(window, ExplorerFileManager.IID_IShellBrowser, ExplorerFileManager.IID_IShellBrowser)
                ComCall(3, shellBrowser, "Int*", &currentTab := 0)
                if (currentTab != activeTab) {
                    continue
                }
            }
            path := window.Document.Folder.Self.Path
            if (path ~= "^::") {
                continue
            }
            folders.Push(path)
            if (!allTab) {
                break
            }
        }
        return folders
    }
}