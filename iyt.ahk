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