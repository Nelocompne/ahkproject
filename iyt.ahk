; AHK v1

#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

/*

下载字幕
--write-subs
--sub-format srt
--sub-langs all

下载整个频道视频
--proxy "http://127.0.0.1:7890"
--downloader aria2c
--downloader-args "-x 16"
-o "%(uploader)s (%(uploader_id)s)/%(upload_date)s - %(title)s %(id)s.%(ext)s"
-f bestvideo*+bestaudio/best
--merge-output-format mkv

下载单个视频
--proxy "http://127.0.0.1:7890"
--downloader aria2c
--downloader-args "-x 16"
-f bestvideo*+bestaudio/best
--merge-output-format mkv


# yt-dlp (youtube-dl) with args
--proxy http://127.0.0.1:7890 #配置代理
--external-downloader aria2c #加入外置下载器，如aria2
--external-downloader-args "-x 16 -k 1M" #给外置下载器的下载参数

#输出文件名格式
-o "%(uploader)s (%(uploader_id)s)/%(upload_date)s - %(title)s %(id)s.%(ext)s"

#输出格式例子
-o "%(upload_date)s - %(title)s %(id)s.%(ext)s"

-f bestvideo*+bestaudio/best #获取最佳视频及音频
--merge-output-format mkv #输出mkv

--add-metadata #加入视频元信息
--write-description #写入视频介绍
--write-thumbnail #写入视频封面图

--cookies-from-browser #调用浏览器cookie

*/


Confname := A_Args[1]
URL := A_Args[2]
;Run yt-dlp --config-location %ConfFile% %URL%

aria2 = --downloader aria2c --downloader-args "-x 16"
formatfile := "%(uploader)s (%(uploader_id)s)/%(upload_date)s - %(title)s %(id)s.%(ext)s"
encode = bestvideo*+bestaudio/best

if (Confname = "sub") {
	MsgBox, 1, , yt-dlp --write-subs --sub-format srt --sub-langs all %URL%
	IfMsgBox OK
		Run %ComSpec% /k yt-dlp --write-subs --sub-format srt --sub-langs all %URL%
	else
		return
}
else if (Confname = "yc") {
	MsgBox, 1, , yt-dlp %aria2% -o %formatfile% -f %encode% --merge-output-format mkv %URL%
	IfMsgBox OK
		Run %ComSpec% /k yt-dlp %aria2% -o %formatfile% -f %encode% --merge-output-format mkv %URL%
	else
		return
}
else if (Confname = "y") {
	MsgBox, 1, , yt-dlp %aria2% -f %encode% --merge-output-format mkv %URL%
	IfMsgBox OK
		Run %ComSpec% /k yt-dlp %aria2% -f %encode% --merge-output-format mkv %URL%
	else
		return
}
else if (Confname = "help") {
	MsgBox, 0, , sub 字幕`nyc 下载整个频道视频`ny 下载视频`nhelp 查询帮助
	return
}
else {
	MsgBox, 0, , sub 字幕`nyc 下载整个频道视频`ny 下载视频`nhelp 查询帮助
	return
}
