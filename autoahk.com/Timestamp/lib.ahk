; https://www.autoahk.com/archives/44829

;获取时间戳
getTimestamp() {
    startTime := "19700101000000"
    nowTime := A_NowUTC
    ; 计算现在时间到startTime时间戳经过的秒数
    EnvSub, nowTime, startTime, Seconds
    ;毫秒时间戳
    timestamp := nowTime * 1000 + A_MSec
    SendInput, %timestamp%
}

;时间戳转日期格式
timestampToDate(timestamp) {
    ;可以自行添加一下格式校验
    len := StrLen(timestamp)
    ;毫秒转秒
    if(len == 13) {
        timestamp := (timestamp - A_MSec)// 1000
    }
    startTime := "19700101000000"
    ;时区换算
    difTime := A_Now
    EnvSub, difTime, A_NowUTC, Seconds
    EnvAdd, startTime, timestamp, Seconds
    EnvAdd, startTime, difTime, Seconds
    ;格式化
    FormatTime, time, %startTime%, yyyy-MM-dd HH:mm:ss
    SendInput, %time%
}