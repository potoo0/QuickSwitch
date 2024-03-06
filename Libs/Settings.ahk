; global config
#Include Config.ahk

; A_TrayMenu
SettingMenu := A_TrayMenu
SettingMenu.Insert("1&", "&AutoStartup Switch", onAutoStartupSwitch, "Radio")
SettingMenu.Add()

onAutoStartupSwitch(*) {
  isAutoStartup := !CFG.GetConfig("AutoStartup", "Global")
  CFG.UpdateConfig("AutoStartup", isAutoStartup, "Global")
  autoStartupLnk := A_Startup "\QuickSwitch.lnk"
  if (isAutoStartup and !FileExist(autoStartupLnk)) {
    FileCreateShortcut(A_ScriptFullPath, autoStartupLnk, A_WorkingDir)
  } else if (!isAutoStartup and FileExist(autoStartupLnk)) {
    FileDelete(autoStartupLnk)
  }
  MsgBox(isAutoStartup ? "开机自动启动已允许" : "开机自动启动已禁止")
}
