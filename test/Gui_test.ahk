#Include ..\Libs\FileManager.ahk

MyGui := Gui("Resize")
MyGui.OnEvent("Size", handleGuiResize)

folderTitle := MyGui.AddText(, "Folders")
folderTitle.SetFont("w600")

folders := GetAllFolder()
; r5: 5 rows visible at one time
; vFolderChoice: control's Name
; Choose1: default choose first
listBox := MyGui.AddListBox("r5 vFolderChoice Choose1 Sort", folders)
listBox.OnEvent("DoubleClick", handleFolderChoice)

debugBtn := MyGui.AddButton(, "Debug")
debugBtn.OnEvent("Click", handleDebugBtnClick)

disableBtn := MyGui.AddButton(, "Disabled")
disableBtn.OnEvent("Click", handleDisableBtnClick)

MyGui.Show()

handleDisableBtnClick(guiCtrlObj, Info) {
  MyGui.Destroy()
}

handleDebugBtnClick(guiCtrlObj, Info) {
  MsgBox("Debug")
}

handleFolderChoice(guiCtrlObj, info) {
  selectedText := guiCtrlObj.Text
  MsgBox("selectedText=" selectedText)
}

handleGuiResize(GuiObj, MinMax, Width, Height) {
  listBox.Move(,, Width - 25)
}
