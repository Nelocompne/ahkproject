#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; 配置文件路径
configFile := "frpMonitor.ini"

; 创建GUI
MyGui := Gui(, "Frp进程监视器")
MyGui.OnEvent("Close", GuiClose)
MyGui.SetFont("s10", "Segoe UI")

; 列表视图
LV := MyGui.Add("ListView", "w600 h300", ["程序名称", "状态", "进程ID", "匹配关键词"])
LV.ModifyCol(1, 150)
LV.ModifyCol(2, 100)
LV.ModifyCol(3, 100)
LV.ModifyCol(4, 250)

; 按钮控件
MyGui.Add("GroupBox", "w600", "控制")
MyGui.SetFont("s10")
MyGui.Add("Button", "x20 yp+30 w80", "添加").OnEvent("Click", AddEntry)
MyGui.Add("Button", "x+10 w80", "删除").OnEvent("Click", DeleteEntry)
MyGui.Add("Button", "x+10 w80", "刷新").OnEvent("Click", UpdateStatus)
MyGui.Add("Button", "x+10 w80", "退出").OnEvent("Click", GuiClose)

; 加载配置
LoadConfig()
UpdateStatus()
SetTimer(UpdateStatus, 5000) ; 每5秒自动刷新

MyGui.Show()

; 加载配置文件
LoadConfig() {
    global configFile, monitoredApps
    monitoredApps := Map()
    
    if FileExist(configFile) {
        loop read, configFile {
            if (A_LoopReadLine = "" || InStr(A_LoopReadLine, "[Entries]"))
                continue
            parts := StrSplit(A_LoopReadLine, "|")
            if parts.Length >= 2
                monitoredApps[parts[1]] := parts[2]
        }
    }
}

; 保存配置
SaveConfig() {
    global configFile, monitoredApps
    content := "[Entries]`n"
    for name, keyword in monitoredApps
        content .= name "|" keyword "`n"
    FileDelete(configFile)
    FileAppend(content, configFile)
}

; 更新状态
UpdateStatus(*) {
    global LV, monitoredApps
    LV.Delete()

    ; 获取所有Java进程
    javaProcs := GetJavaProcesses()
    
    ; 遍历监控项
    for name, keyword in monitoredApps {
        status := "未运行"
        pids := []
        
        ; 检查进程
        for proc in javaProcs {
            if InStr(proc.cmdLine, keyword) {
            ; 修改UpdateStatus中的匹配逻辑
            ; if RegExMatch(proc.cmdLine, "i)\b" keyword "\b") {
                status := "运行中"
                pids.Push(proc.pid)
            }
        }
        
        ; 添加列表项
        row := LV.Add(, name, status, pids.Length ? Join(pids, ",") : "", keyword)
        if (status = "运行中")
            LV.Modify(row, "Vis Check")
    }
}

; 获取Java进程列表
GetJavaProcesses() {
    procs := []
    try {
        wmi := ComObjGet("winmgmts:")
        query := wmi.ExecQuery("SELECT ProcessId, CommandLine FROM Win32_Process "
            "WHERE Name='frpc.exe' OR Name='frps.exe'")
        
        for proc in query
            procs.Push({pid: proc.ProcessId, cmdLine: proc.CommandLine})
    }
    return procs
}

; 添加条目
AddEntry(*) {
    global MyGui, monitoredApps
    addGui := Gui(, "添加监控项")
    addGui.SetFont("s10")
    
    addGui.Add("Text",, "程序名称:")
    nameCtrl := addGui.Add("Edit", "w200")
    addGui.Add("Text",, "匹配关键词:")
    keyCtrl := addGui.Add("Edit", "w200")
    
    addGui.Add("Button", "Default w80", "确定").OnEvent("Click", AddConfirm)
    addGui.Add("Button", "x+10 w80", "取消").OnEvent("Click", (*) => addGui.Destroy())
    
    addGui.Show()
    
    AddConfirm(*) {
        name := Trim(nameCtrl.Value)
        keyword := Trim(keyCtrl.Value)
        if (name != "" && keyword != "") {
            monitoredApps[name] := keyword
            SaveConfig()
            UpdateStatus()
            addGui.Destroy()
        }
    }
}

; 删除条目
DeleteEntry(*) {
    global LV, monitoredApps
    row := LV.GetNext()
    if row {
        name := LV.GetText(row)
        monitoredApps.Delete(name)
        SaveConfig()
        UpdateStatus()
    }
}

; 辅助函数：数组转字符串
Join(arr, delimiter) {
    str := ""
    for i, v in arr
        str .= (i > 1 ? delimiter : "") v
    return str
}

; 关闭事件
GuiClose(*) {
    SaveConfig()
    ExitApp()
}