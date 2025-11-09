#Requires AutoHotkey v2.0

; 配置信息
batchScriptPath := "uselogout.bat"  ; 替换为你的批处理脚本路径
checkInterval := 1000      ; 检查间隔（毫秒）
maxMissingTime := 30000    ; 最大允许的进程不存在时间（毫秒）

; 初始化变量
lastSeenTime := 0          ; 上次看到进程的时间戳
isProcessRunning := false  ; 进程当前是否在运行

; 创建定时器，定期检查进程
SetTimer CheckProcess, checkInterval

; 进程检查函数
CheckProcess() {
    global lastSeenTime, isProcessRunning, maxMissingTime, batchScriptPath
    
    ; 检查 ffmpeg.exe 进程是否存在
    if ProcessExist("ffmpeg.exe") {
        ; 进程存在，更新最后看到的时间
        lastSeenTime := A_TickCount
        isProcessRunning := true
    } else {
        ; 进程不存在
        isProcessRunning := false
        
        ; 如果之前进程在运行，但现在不存在了
        if (lastSeenTime > 0) {
            ; 计算进程已经消失的时间
            missingTime := A_TickCount - lastSeenTime
            
            ; 如果消失时间超过阈值
            if (missingTime > maxMissingTime) {
                ; 运行批处理脚本
                Run batchScriptPath
                
                ; 重置计时器，避免重复执行
                lastSeenTime := 0
                
                ; 可选：显示通知
                TrayTip "FFmpeg 监控", "FFmpeg 进程已消失超过 " . (maxMissingTime // 1000) . " 秒`n已执行批处理脚本: " . batchScriptPath
            }
        }
    }
}

; 热键：显示当前状态
F1:: {
    global lastSeenTime, isProcessRunning
    
    if isProcessRunning {
        TrayTip "FFmpeg 监控", "FFmpeg 进程正在运行"
    } else if (lastSeenTime > 0) {
        missingTime := (A_TickCount - lastSeenTime) // 1000
        TrayTip "FFmpeg 监控", "FFmpeg 进程已消失 " . missingTime . " 秒"
    } else {
        TrayTip "FFmpeg 监控", "FFmpeg 进程未运行"
    }
}

; 热键：退出脚本
^!q::ExitApp  ; Ctrl+Alt+Q 退出

; 脚本启动时显示提示
TrayTip "FFmpeg 监控", "脚本已启动`n监控 ffmpeg.exe 进程状态"