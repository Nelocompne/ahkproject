#Requires AutoHotkey v2.0

; IE可信站点地址清空（IE8以上）
Try {
    ; 删除整个注册表项及其所有子项 - 使用 RegDeleteKey
    RegDeleteKey "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Ranges"
    MsgBox "IE可信站点Ranges已清空", "完成", "T1"
} Catch Error as e {
    ; 如果项不存在，忽略错误
}

Try {
    ; 删除整个注册表项及其所有子项 - 使用 RegDeleteKey
    RegDeleteKey "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains"
    MsgBox "IE可信站点Domains已清空", "完成", "T1"
} Catch Error as e {
    ; 如果项不存在，忽略错误
}

MsgBox "所有IE可信站点地址配置已清空完成！", "操作完成", "T2"