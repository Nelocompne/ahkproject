; IE11可信站点设置工具 - AutoHotkey v2.0版本
; 作者：基于原始BAT脚本转换
; 版本：1.0
#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, Off

; 主程序
IETrustedSitesManager()

IETrustedSitesManager() {
    ; 创建GUI界面
    MyGui := Gui(, "IE可信站点管理工具")
    MyGui.SetFont("s10", "Arial")
    
    ; 添加控件
    MyGui.Add("Text", "w400", "此工具用于将网站添加到IE11可信站点列表")
    MyGui.Add("Text", "w400", "支持IP地址、IP段和域名格式")
    
    MyGui.Add("Text", "w400 y+10", "配置文件路径：")
    EditConfig := MyGui.Add("Edit", "w300 vConfigPath", "sites.txt")
    BrowseBtn := MyGui.Add("Button", "x+5 w80", "浏览...")
    
    MyGui.Add("Text", "w400 y+10", "添加单个网站（可选）：")
    EditSingleSite := MyGui.Add("Edit", "w300 vSingleSite", "例如：192.168.1.1 或 example.com")
    
    ProgressText := MyGui.Add("Text", "w400 y+10", "就绪")
    ProgressBar := MyGui.Add("Progress", "w400 h20 vMyProgress -Smooth")
    
    BtnAddFromFile := MyGui.Add("Button", "w120 h30 x20 y+20", "从文件添加")
    BtnAddSingle := MyGui.Add("Button", "w120 h30 x+20", "添加单个")
    BtnViewCurrent := MyGui.Add("Button", "w120 h30 x+20", "查看当前设置")
    
    ; 按钮事件
    BrowseBtn.OnEvent("Click", BrowseConfig)
    BtnAddFromFile.OnEvent("Click", AddFromFile)
    BtnAddSingle.OnEvent("Click", AddSingleSite)
    BtnViewCurrent.OnEvent("Click", ViewCurrentSettings)
    
    MyGui.Show()
    
    ; 浏览配置文件
    BrowseConfig(*) {
        SelectedFile := FileSelect(3, , "选择网站配置文件", "文本文件 (*.txt)")
        if SelectedFile != ""
            EditConfig.Value := SelectedFile
    }
    
    ; 从文件添加网站
    AddFromFile(*) {
        configPath := EditConfig.Value
        if !FileExist(configPath) {
            MsgBox("配置文件不存在！`n请选择有效的配置文件。", "错误", 0x10)
            return
        }
        
        try {
            sites := FileRead(configPath)
        } catch as e {
            MsgBox("读取配置文件失败：`n" e.Message, "错误", 0x10)
            return
        }
        
        siteArray := StrSplit(sites, "`n", "`r")
        totalSites := siteArray.Length
        successCount := 0
        
        ProgressText.Text := "正在处理..."
        ProgressBar.Value := 0
        
        for index, site in siteArray {
            site := Trim(site)
            if site = "" || SubStr(site, 1, 1) = ";" || SubStr(site, 1, 1) = "#"
                continue
                
            if AddSiteToRegistry(site) {
                successCount++
            }
            
            ProgressBar.Value := (index / totalSites) * 100
            ProgressText.Text := "处理中: " index "/" totalSites " - " site
        }
        
        ProgressBar.Value := 100
        ProgressText.Text := "完成！成功添加 " successCount " 个网站"
        MsgBox("从文件添加完成！`n成功添加 " successCount " 个网站到可信站点。", "完成", 0x40)
    }
    
    ; 添加单个网站
    AddSingleSite(*) {
        site := Trim(EditSingleSite.Value)
        if site = "" {
            MsgBox("请输入要添加的网站地址", "提示", 0x30)
            return
        }
        
        ProgressText.Text := "正在添加: " site
        ProgressBar.Value := 50
        
        if AddSiteToRegistry(site) {
            ProgressBar.Value := 100
            ProgressText.Text := "添加成功: " site
            MsgBox("网站 '" site "' 已成功添加到可信站点！", "成功", 0x40)
        } else {
            ProgressBar.Value := 0
            ProgressText.Text := "添加失败: " site
            MsgBox("添加网站 '" site "' 失败！", "错误", 0x10)
        }
    }
    
    ; 查看当前设置
    ViewCurrentSettings(*) {
        ShowCurrentSettings()
    }
}

; 添加网站到注册表
AddSiteToRegistry(site) {
    static rangeIndex := GetNextRangeIndex()
    
    ; 清理网站地址
    site := Trim(site)
    site := RegExReplace(site, "^https?://", "")
    site := RegExReplace(site, "/.*$", "")
    
    if site = "" {
        return false
    }
    
    ; 判断网站类型并添加到注册表
    if IsIPAddress(site) {
        return AddIPSite(site, rangeIndex++)
    } else {
        return AddDomainSite(site)
    }
}

; 判断是否为IP地址
IsIPAddress(site) {
    ; 匹配IP地址格式（支持通配符）
    return RegExMatch(site, "^(?:\d{1,3}\.*){3}\d{0,3}(?:\*\.*)*$") > 0
}

; 添加IP网站到Ranges
AddIPSite(ip, index) {
    regPath := "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Ranges\Range" index
    
    try {
        ; 创建注册表项并设置值
        RegWrite(2, "REG_DWORD", regPath, "http")
        RegWrite(2, "REG_DWORD", regPath, "https")
        RegWrite(ip, "REG_SZ", regPath, ":Range")
        return true
    } catch as e {
        OutputDebug("添加IP站点失败: " e.Message)
        return false
    }
}

; 添加域名网站到Domains
AddDomainSite(domain) {
    ; 处理通配符域名
    if InStr(domain, "*.") = 1 {
        domain := SubStr(domain, 3)  ; 去掉*.
        subkey := "*"
    } else {
        ; 分离主域名和子域名
        parts := StrSplit(domain, ".")
        if parts.Length > 2 {
            subkey := parts[1]
            domain := SubStr(domain, StrLen(parts[1]) + 2)
        } else {
            subkey := "*"
        }
    }
    
    regPath := "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\" domain "\" subkey
    
    try {
        RegWrite(2, "REG_DWORD", regPath, "http")
        RegWrite(2, "REG_DWORD", regPath, "https")
        return true
    } catch as e {
        OutputDebug("添加域名站点失败: " e.Message)
        return false
    }
}

; 获取下一个可用的Range索引
GetNextRangeIndex() {
    basePath := "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Ranges"
    maxIndex := 100  ; 从100开始
    
    try {
        loop {
            testPath := basePath "\Range" maxIndex
            if !RegKeyExist(testPath) {
                break
            }
            maxIndex++
        }
    }
    
    return maxIndex
}

; 显示当前可信站点设置
; 显示当前可信站点设置
ShowCurrentSettings() {
    settings := "当前可信站点设置：`n`n"
    
    ; 获取Ranges中的IP站点
    basePath := "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Ranges"
    
    ; 使用RegKeyList获取所有Range子键
    try {
        ranges := RegKeyList(basePath)
        if ranges.Length > 0 {
            settings .= "IP范围站点：`n"
            for rangeKey in ranges {
                rangePath := basePath "\" rangeKey
                try {
                    ; 尝试读取:Range值
                    ipRange := RegRead(rangePath, ":Range")
                    httpValue := RegRead(rangePath, "http")
                    
                    settings .= "  - " ipRange " (HTTP: " httpValue ")" "`n"
                } catch as e {
                    settings .= "  - " rangeKey " (读取失败)" "`n"
                }
            }
            settings .= "`n"
        } else {
            settings .= "IP范围站点：无`n`n"
        }
    } catch {
        settings .= "IP范围站点：无法读取`n`n"
    }
    
    ; 获取Domains中的域名站点
    domainsPath := "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains"
    
    try {
        domains := RegKeyList(domainsPath)
        if domains.Length > 0 {
            settings .= "域名站点：`n"
            for domain in domains {
                domainPath := domainsPath "\" domain
                
                ; 获取子键（如www、*等）
                try {
                    subkeys := RegKeyList(domainPath)
                    for subkey in subkeys {
                        fullPath := domainPath "\" subkey
                        try {
                            httpValue := RegRead(fullPath, "http")
                            httpsValue := RegRead(fullPath, "https")
                            
                            if subkey = "*" {
                                settings .= "  - " domain "/*" " (HTTP: " httpValue ", HTTPS: " httpsValue ")" "`n"
                            } else {
                                settings .= "  - " subkey "." domain " (HTTP: " httpValue ", HTTPS: " httpsValue ")" "`n"
                            }
                        } catch {
                            settings .= "  - " domain "/" subkey " (值读取失败)" "`n"
                        }
                    }
                } catch {
                    ; 如果没有子键，直接显示域名
                    try {
                        httpValue := RegRead(domainPath, "http")
                        httpsValue := RegRead(domainPath, "https")
                        settings .= "  - " domain " (HTTP: " httpValue ", HTTPS: " httpsValue ")" "`n"
                    } catch {
                        settings .= "  - " domain " (值读取失败)" "`n"
                    }
                }
            }
        } else {
            settings .= "域名站点：无`n"
        }
    } catch {
        settings .= "域名站点：无法读取`n"
    }
    
    ; 使用更宽的对话框显示
    MsgBox(settings, "当前可信站点设置", 0x40)
}


; 辅助函数：列出注册表键
RegKeyList(path) {
    keys := []
    try {
        loop Reg, path, "K" {
            keys.Push(A_LoopRegName)
        }
    }
    return keys
}

; 辅助函数：检查注册表键是否存在
RegKeyExist(path) {
    try {
        RegRead(, path)
        return true
    } catch {
        return false
    }
}

; 创建示例配置文件
CreateSampleConfig() {
    sampleContent := 
    "
    (
    ; IE可信站点配置文件
    ; 每行一个网站地址，支持以下格式：
    ;
    ; IP地址: 192.168.1.1
    ; IP段:   192.168.*.*
    ; 域名:   example.com
    ; 子域名: www.example.com
    ; 通配符: *.example.com
    
    ; 示例站点：
    100.64.0.1
    100.64.0.*
    192.168.1.100
    example.com
    www.example.com
    *.mydomain.com
    )"
    
    if !FileExist("sites.txt") {
        FileAppend(sampleContent, "sites.txt", "UTF-8")
        MsgBox("已创建示例配置文件: sites.txt", "提示", 0x40)
    }
}

; 程序启动时检查并创建示例配置文件
if !FileExist("sites.txt") {
    result := MsgBox("未找到配置文件 sites.txt，是否创建示例文件？", "提示", 0x34)
    if result = "Yes" {
        CreateSampleConfig()
    }
}