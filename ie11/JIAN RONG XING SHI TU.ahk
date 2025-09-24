#Requires AutoHotkey v2.0
#SingleInstance Force

; IE兼容性视图设置脚本 - AutoHotkey v2.0版本
; 作者：基于原PowerShell脚本转换

; 主界面
MyGui := Gui(, "IE兼容性视图设置工具")
MyGui.OnEvent("Close", GuiClose)
MyGui.SetFont("s10", "Arial")

; 添加控件
MyGui.Add("Text", "w600", "IE兼容性视图设置工具 - 自动生成注册表配置")
MyGui.Add("Text", "w600", "功能：将指定网址添加到IE浏览器的兼容性视图列表中")

MyGui.Add("Text", "w600 Section", "选择配置方式：")
radioManual := MyGui.Add("Radio", "xs Section vConfigMethod Checked", "手动输入网址（多个网址用逗号或空格分隔）")
radioFile := MyGui.Add("Radio", "xs y+5", "从配置文件读取（每行一个网址）")

; 手动输入区域
MyGui.Add("Text", "xs Section w600", "请输入网址：")
editWebsites := MyGui.Add("Edit", "xs w600 r3 vWebsites", "example.com`ngithub.com`nlocalhost")

; 文件选择区域
MyGui.Add("Text", "xs Section w600 vFileText", "配置文件路径（每行一个网址）：")
editFilePath := MyGui.Add("Edit", "xs w500 vFilePath", A_ScriptDir . "\websites.txt")
btnBrowse := MyGui.Add("Button", "x+5 w80 vBrowseBtn", "浏览...")
btnBrowse.OnEvent("Click", BrowseFile)

; 按钮区域
MyGui.Add("Text", "xs Section w600", "操作：")
btnGenerate := MyGui.Add("Button", "xs w120 vGenerateBtn", "生成注册表命令")
btnGenerate.OnEvent("Click", GenerateRegCommand)

btnRun := MyGui.Add("Button", "x+10 w120 vRunBtn", "直接执行")
btnRun.OnEvent("Click", RunRegCommand)

btnCreateTemplate := MyGui.Add("Button", "x+10 w150 vTemplateBtn", "创建配置文件模板")
btnCreateTemplate.OnEvent("Click", CreateTemplateFile)

; 结果显示区域
MyGui.Add("Text", "xs Section w600", "生成的注册表命令：")
editResult := MyGui.Add("Edit", "xs w600 r6 vResult ReadOnly", "请先生成命令")

; 状态栏
statusBar := MyGui.Add("StatusBar",, "就绪")

; 全局变量存储纯注册表命令（不含网址列表）
g_PureRegCommand := ""

; 初始显示设置
UpdateGuiVisibility()

; 显示GUI
MyGui.Show()

; 更新GUI可见性
UpdateGuiVisibility() {
    global radioManual, editWebsites, editFilePath, btnBrowse
    
    if (radioManual.Value) {
        editWebsites.Visible := true
        editFilePath.Visible := false
        btnBrowse.Visible := false
    } else {
        editWebsites.Visible := false
        editFilePath.Visible := true
        btnBrowse.Visible := true
    }
}

; 浏览文件
BrowseFile(*) {
    global editFilePath
    selectedFile := FileSelect(3, A_ScriptDir, "选择网址配置文件", "文本文件 (*.txt)")
    if (selectedFile != "") {
        editFilePath.Value := selectedFile
    }
}

; 创建配置文件模板
CreateTemplateFile(*) {
    global editFilePath
    
    templateContent := 
    (
        "# IE兼容性视图网址配置文件`n"
        "# 每行一个网址，不需要输入 http:// 或 https://`n"
        "# 空行和以#开头的行将被忽略`n"
        "`n"
        "example.com`n"
        "github.com`n"
        "localhost`n"
        "internal.company.com`n"
    )
    
    filePath := editFilePath.Value
    if (filePath = "") {
        filePath := A_ScriptDir . "\websites.txt"
    }
    
    try {
        ;FileDelete(filePath)
        FileAppend(templateContent, filePath)
        MsgBox("配置文件模板已创建：`n" . filePath, "成功", 64)
        editFilePath.Value := filePath
    } catch as e {
        MsgBox("创建配置文件失败：`n" . e.Message, "错误", 16)
    }
}

; 生成单个网站的十六进制数据
GetWebsiteHex(website) {
    ; 去除网址中的 https:// 和 http:// 前缀
    website := RegExReplace(website, "i)^https?://", "")
    
    ; 去除斜杠后的所有内容
    website := RegExReplace(website, "/.*", "")
    
    if (website = "") {
        return ""
    }
    
    ; 计算网站名称的十六进制长度
    length := StrLen(website)
    hexLength := Format("{:04X}", length)
    ; 注意：需要转换为小端序
    hexLength := SubStr(hexLength, 3, 2) . SubStr(hexLength, 1, 2)
    
    ; 将网站名称转换为十六进制数据（Unicode编码）
    hexData := ""
    Loop Parse website {
        charCode := Ord(A_LoopField)
        ; Unicode字符，小端序
        hexData .= Format("{:02X}", charCode & 0xFF) . Format("{:02X}", (charCode >> 8) & 0xFF)
    }
    
    return "0C000000000000000000000101000000" . hexLength . hexData
}

; 生成IE兼容性视图的十六进制数据
GetIECVHex(websitesArray) {
    websiteCount := websitesArray.Length
    
    ; 构建IE兼容性视图的头部
    hexCount := Format("{:08X}", websiteCount)
    ; 转换为小端序
    hexCount := SubStr(hexCount, 7, 2) . SubStr(hexCount, 5, 2) . SubStr(hexCount, 3, 2) . SubStr(hexCount, 1, 2)
    
    header := "411F00005308ADBA" . hexCount . "FFFFFFFF01000000" . hexCount
    
    ; 获取每个网站的十六进制表示
    hexWebsites := ""
    for website in websitesArray {
        hexWebsites .= GetWebsiteHex(website)
    }
    
    return header . hexWebsites
}

; 从配置文件读取网址
ReadWebsitesFromFile(filePath) {
    websites := []
    
    if (!FileExist(filePath)) {
        throw Error("配置文件不存在：`n" . filePath)
    }
    
    try {
        loop read filePath {
            line := Trim(A_LoopReadLine)
            ; 跳过空行和注释行
            if (line = "" || SubStr(line, 1, 1) = "#") {
                continue
            }
            
            ; 处理一行中有多个网址的情况（用空格或逗号分隔）
            urlArray := StrSplit(line, " ,`t")
            for url in urlArray {
                cleanUrl := Trim(url)
                if (cleanUrl != "") {
                    websites.Push(cleanUrl)
                }
            }
        }
    } catch as e {
        throw Error("读取配置文件失败：`n" . e.Message)
    }
    
    if (websites.Length = 0) {
        throw Error("配置文件中没有找到有效的网址")
    }
    
    return websites
}

; 从手动输入解析网址（修正版）
ParseWebsitesFromInput(input) {
    websites := []
    
    ; 首先按换行符分割
    lines := StrSplit(input, "`n", "`r")
    
    for line in lines {
        line := Trim(line)
        
        ; 跳过空行和注释行
        if (line = "" || SubStr(line, 1, 1) = "#") {
            continue
        }
        
        ; 处理一行中有多个网址的情况（用逗号或空格分隔）
        urlArray := StrSplit(line, " ,`t")
        for url in urlArray {
            cleanUrl := Trim(url)
            if (cleanUrl != "") {
                websites.Push(cleanUrl)
            }
        }
    }
    
    if (websites.Length = 0) {
        throw Error("请输入有效的网址")
    }
    
    return websites
}

; 生成注册表命令
GenerateRegCommand(*) {
    global radioManual, editWebsites, editFilePath, editResult, statusBar, g_PureRegCommand
    
    try {
        ; 获取网址列表
        if (radioManual.Value) {
            websites := ParseWebsitesFromInput(editWebsites.Value)
        } else {
            websites := ReadWebsitesFromFile(editFilePath.Value)
        }
        
        ; 生成十六进制数据
        hexData := GetIECVHex(websites)
        
        ; 构建注册表命令
        regCommand := 'reg add "HKCU\Software\Microsoft\Internet Explorer\BrowserEmulation\ClearableListData" /v "UserFilter" /t REG_BINARY /d ' . hexData
        
        ; 保存纯注册表命令（不含网址列表）
        g_PureRegCommand := regCommand
        
        ; 显示结果
        displayText := regCommand
        
        ; 在结果中显示网址列表
        websiteList := "`n`n包含的网址：`n"
        for website in websites {
            websiteList .= "  • " . website . "`n"
        }
        editResult.Value := displayText . websiteList
        
        ; 显示统计信息
        statusBar.Text := "成功生成命令，包含 " . websites.Length . " 个网址"
        
    } catch as e {
        MsgBox(e.Message, "错误", 16)
        statusBar.Text := "生成命令失败"
        g_PureRegCommand := ""
    }
}

; 直接执行注册表命令
RunRegCommand(*) {
    global editResult, g_PureRegCommand, statusBar
    
    ; 检查是否已生成命令
    if (g_PureRegCommand = "") {
        MsgBox("请先生成有效的注册表命令", "提示", 48)
        return
    }
    
    ; 使用保存的纯注册表命令（不含网址列表）
    regCommand := g_PureRegCommand
    
    ; 验证命令格式
    if (!RegExMatch(regCommand, "^reg add")) {
        MsgBox("注册表命令格式无效，请重新生成", "错误", 16)
        return
    }
    
    ; 确认执行
    result := MsgBox("确定要执行以下注册表命令吗？`n`n" 
                   . "此操作将修改IE兼容性视图设置。`n`n"
                   . "命令: " . regCommand, "确认执行", 4)
    
    if (result != "Yes") {
        statusBar.Text := "用户取消执行"
        return
    }
    
    try {
        ; 以管理员权限运行
        if (A_IsAdmin) {
            ; 已经具有管理员权限，直接执行
            RunWait(regCommand,, "Hide")
            statusBar.Text := "注册表命令已成功执行！"
            MsgBox("注册表命令已成功执行！", "成功", 64)
        } else {
            ; 请求管理员权限
            statusBar.Text := "正在请求管理员权限..."
            try {
                RunWait('*RunAs ' regCommand,, "Hide")
                statusBar.Text := "注册表命令已成功执行！"
                MsgBox("注册表命令已成功执行！", "成功", 64)
            } catch as e {
                ; 如果用户取消了UAC提示
                if (InStr(e.Message, "Cancel")) {
                    statusBar.Text := "用户取消了管理员权限请求"
                    MsgBox("操作已取消：需要管理员权限才能修改注册表", "提示", 48)
                } else {
                    throw e
                }
            }
        }
    } catch as e {
        errorMsg := "执行命令失败：`n" . e.Message
        if (InStr(e.Message, "exit code 1")) {
            errorMsg .= "`n`n可能的原因："
            errorMsg .= "`n• 注册表路径不存在"
            errorMsg .= "`n• 没有足够的权限"
            errorMsg .= "`n• 命令格式错误"
        }
        MsgBox(errorMsg, "错误", 16)
        statusBar.Text := "执行命令失败"
    }
}

; GUI关闭事件
GuiClose(*) {
    ExitApp
}

; 配置文件改变时更新可见性
radioManual.OnEvent("Click", (*) => UpdateGuiVisibility())
radioFile.OnEvent("Click", (*) => UpdateGuiVisibility())

; 初始更新可见性
UpdateGuiVisibility()