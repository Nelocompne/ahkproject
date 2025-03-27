#Requires AutoHotkey v2.0
#SingleInstance Force

; 配置初始化
configFile := A_ScriptDir "\ProcessMonitorV2.ini"
rowColors := Map()  ; 使用Map存储行号与颜色关系

; 创建主界面
mainGui := Gui('+AlwaysOnTop +Resize', "多进程状态监视器 V2")
mainGui.SetFont('s10', 'Segoe UI')

; 进程列表（启用双重缓冲和完整行选择）
lv := mainGui.AddListView('x10 y10 w300 h200 AltSubmit -Multi Grid +0x4E +LV0x10000', ['进程名称', '状态', 'PID'])
lv.ModifyCol(1, 150)
lv.ModifyCol(2, 80)
lv.ModifyCol(3, 60)
lv.OnEvent('DoubleClick', removeSelected)
; 注册正确的通知处理
lv.OnNotify(-12, NM_CUSTOMDRAW)  ; NM_CUSTOMDRAW = -12 (0xFFFFFFF4)

; 控制面板
ctrlPanel := mainGui.AddGroupBox('x320 y10 w190 h200', '进程管理')
ctrlPanel.SetFont('s10')

editProcess := mainGui.AddEdit('xp+10 yp+30 w120')
btnAdd := mainGui.AddButton('x+5 yp-3 w60', '添加', )
btnAdd.OnEvent("Click", addProcess)
btnRemove := mainGui.AddButton('x320 y70 w80', '删除选中', )
btnAdd.OnEvent("Click", removeSelected)
btnClear := mainGui.AddButton('x410 y70 w90', '清空列表', )
btnAdd.OnEvent("Click", clearList)

; 状态说明
mainGui.AddText('x320 y110', '状态颜色说明：')
mainGui.AddText('x320 y130 cGreen', '● 运行中')
mainGui.AddText('x320 y150 cRed', '● 未运行')

; 加载配置并显示窗口
loadConfiguration()
mainGui.Show('w530 h230')
SetTimer(checkAllProcesses, 1000)  ; 启动定时检查

; 添加进程函数
addProcess(*) {
    global editProcess, lv
    newProcess := Trim(editProcess.Value)
    if newProcess = ''
        return
    
    if isDuplicate(newProcess) {
        MsgBox('该进程已存在于监控列表中！', '警告', 'Icon!')
        return
    }
    
    lv.Add(, newProcess, '待检测', '')
    editProcess.Value := ''  ; 清空输入框
    saveConfiguration()
}

; 删除选中项
removeSelected(*) {
    global lv
    while (row := lv.GetNext()) {
        lv.Delete(row)
    }
    saveConfiguration()
}

; 清空列表
clearList(*) {
    global lv
    lv.Delete()
    saveConfiguration()
}

; 自定义绘制处理函数（完整Windows API实现）
NM_CUSTOMDRAW(lv, lParam) {
    static CDDS_PREPAINT := 0x00000001
    static CDDS_ITEMPREPAINT := 0x00010001
    static CDRF_NOTIFYITEMDRAW := 0x00000020
    static CDRF_NEWFONT := 0x00000002
    static CDRF_DODEFAULT := 0x00000000

    ; 解析NMLVCUSTOMDRAW结构
    drawStage := NumGet(lParam, A_PtrSize * 2, "UInt")
    dwItemSpec := NumGet(lParam, A_PtrSize * 3, "UPtr")  ; 行号
    clrText := NumGet(lParam, A_PtrSize * 4 + 16, "UInt")

    if (drawStage == CDDS_PREPAINT) {
        return CDRF_NOTIFYITEMDRAW  ; 请求项目级通知
    }
    else if (drawStage == CDDS_ITEMPREPAINT) {
        ; 注意：ListView的行号从0开始
        rowIndex := dwItemSpec + 1  ; 转换为AHK的行号（从1开始）

        if rowColors.Has(rowIndex) {
            ; 修改文本颜色
            NumPut("UInt", rowColors[rowIndex], lParam, A_PtrSize * 4 + 16)
            return CDRF_NEWFONT
        }
    }
    return CDRF_DODEFAULT  ; 0x00000000
}

; 在检查进程时更新颜色映射
checkAllProcesses() {
    global rowColors, lv
    
    rowColors.Clear()
    loop lv.GetCount() {
        processName := lv.GetText(A_Index, 1)
        pid := ProcessExist(processName)
        rowColors[A_Index] := pid ? 0x008000 : 0xC00000  ; 更柔和的颜色方案
        lv.Modify(A_Index, 'Col2', pid ? "运行中" : "未运行")
        lv.Modify(A_Index, 'Col3', pid ?? '')
    }
}

; 配置文件操作
loadConfiguration() {
    global configFile, lv
    if FileExist(configFile) {
        try {
            processes := IniRead(configFile, 'Processes')
            loop Parse processes, '`n' {
                if A_LoopField != ''
                    lv.Add(, A_LoopField, '待检测', '')
            }
        }
    }
}

saveConfiguration() {
    global configFile, lv
    processList := ''
    loop lv.GetCount() {
        processList .= lv.GetText(A_Index, 1) "`n"
    }
    IniWrite(Trim(processList, "`n"), configFile, 'Processes')
}

; 重复项检查
isDuplicate(newProcess) {
    global lv
    loop lv.GetCount() {
        if (lv.GetText(A_Index, 1) = newProcess)
            return true
    }
    return false
}

; 退出时保存配置
mainGui.OnEvent('Close', (*) => ExitApp())