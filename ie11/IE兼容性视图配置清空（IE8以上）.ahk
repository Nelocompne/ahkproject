#Requires AutoHotkey v2.0

; IE兼容性视图配置清空（IE8以上）
Try {
    ; 删除特定值 - 使用 RegDelete
    RegDelete "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\BrowserEmulation\ClearableListData", "UserFilter"
    MsgBox "IE兼容性视图配置已清空", "完成", "T1"
} Catch Error as e {
    ; 如果值不存在，忽略错误（与批处理的 /f 参数行为一致）
}


MsgBox "所有IE兼容性视图配置已清空完成！", "操作完成", "T2"