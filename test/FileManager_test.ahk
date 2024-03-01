#Include ..\Libs\FileManager.ahk

msg := "# all:`n"

allFolders := GetAllFolder()
if (allFolders and allFolders.Length) {
  for c in allFolders {
    msg .= c "`n"
  }
}

winId := 199138
msg .= "`n# cur(" winId "):`n"
fm := ExplorerFileManager()
res := fm.GetCurrentFolder(winId, true)
if (res and res.Length) {
  for c in res {
    msg .= c "`n"
  }
}

MsgBox(msg)
