#Requires AutoHotkey v2.0

; 配置文件路径
configFile := "scripts.cfg"

; 创建GUI界面
myGui := Gui()
myGui.Title := "AHK脚本管理器"
myGui.SetFont("s10", "Segoe UI")

; 创建列表控件
lv := myGui.Add("ListView", "w600 h300", ["脚本名称", "脚本路径"])
lv.ModifyCol(1, 150)
lv.ModifyCol(2, 440)

; 按钮组
btnGroup := myGui.Add("GroupBox", "x+10 y10 w100 h130", "操作")
startBtn := myGui.Add("Button", "xp+10 yp+30 w80", "启动脚本")
refreshBtn := myGui.Add("Button", "x+0 y+10 w80", "刷新列表")
exitBtn := myGui.Add("Button", "x+0 y+10 w80", "退出")

; 加载脚本列表
LoadScripts() {
    global lv, configFile
    
    ; 清空现有列表
    lv.Delete()
    
    ; 检查配置文件是否存在
    if !FileExist(configFile) {
        MsgBox "配置文件不存在，已自动创建。请添加脚本路径到scripts.cfg"
        FileAppend("; 在此添加AHK脚本路径（每行一个）`n", configFile)
        return
    }
    
    ; 读取配置文件
    try {
        loop read, configFile {
            line := Trim(A_LoopReadLine)
            
            ; 跳过空行和注释
            if !line || RegExMatch(line, "^;")
                continue
                
            ; 验证文件是否存在
            if FileExist(line) {
                SplitPath(line, &name)
                lv.Add("", name, line)
            }
        }
    }
    catch as e {
        MsgBox "读取配置文件失败： " e.Message
    }
}

; 事件处理
startBtn.OnEvent("Click", StartScript)
refreshBtn.OnEvent("Click", (*) => LoadScripts())
exitBtn.OnEvent("Click", (*) => ExitApp())

; 启动脚本函数
StartScript(*) {
    global lv
    if (row := lv.GetNext()) {
        selectedRow := lv.GetText(row, 2)
        try {
            Run selectedRow
            MsgBox "已启动脚本：`n" selectedRow, "成功", "Iconi"
        }
        catch as e {
            MsgBox "启动失败：`n" e.Message, "错误", "Iconx"
        }
    } else {
        MsgBox "请先选择一个脚本", "提示", "Iconi"
    }
}

; 显示界面
LoadScripts()
myGui.Show()
; 双击事件处理
lv.OnEvent("DoubleClick", StartScript)