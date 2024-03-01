; global config instance
CFG := Config()


class Context {
    static WinID := ""
    static FingerPrint := ""
    static FileDialog := ""

    static InitFingerPrint(winID) {
        ; process name of the windows file dialog, eg: notepad.exe
        processName := WinGetProcessName("ahk_id " winID)
        ; windows file dialog title
        windowTitle := WinGetTitle("ahk_id " winID)
        Context.FingerPrint := processName "___" windowTitle
    }
}

class Config extends Object {
    ConfigFilePath := this._BuildConfigFilePath()
    _cache := Map()

    _BuildConfigFilePath() {
        SplitPath(A_ScriptFullPath, , , , &nameNoExt)
        return nameNoExt ".ini"
    }

    /**
     * get config
     * @param {String} key
     * @param {String} section default to "Dialogs"
     * @returns {String} config value
     */
    GetConfig(key, section := "Dialogs") {
        if (this._cache.Has(key)) {
            return this._cache[key]
        }
        val := IniRead(this.ConfigFilePath, section, key, "")
        this._cache[key] := val
        return val
    }

    /**
     * update config
     * @param {String} key
     * @param {String} val default to ""
     * @param {String} section default to "Dialogs"
     */
    UpdateConfig(key, val := "", section := "Dialogs") {
        this._cache[key] := val
        IniWrite(val, this.ConfigFilePath, section, key)
    }

    /**
     * delete config
     * @param {String} key
     * @param {String} section default to "Dialogs"
     */
    DeleteConfig(key, section := "Dialogs") {
        if (this._cache.Has(key)) {
            this._cache.Delete(key)
        }
        if (!FileExist(this.ConfigFilePath)) {
            return
        }
        IniDelete(this.ConfigFilePath, section, key)
    }
}