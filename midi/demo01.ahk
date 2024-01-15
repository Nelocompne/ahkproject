; 8.15新使用方法——键盘演奏
; 初始化winmm.dll
LoadMidi()
; 转换演奏曲谱为库支持类型
Arr := File2KeyArr("Ultramarine.txt")
; 开始演奏
; 最后一个参数表示演奏速率（默认为中速300，数值越小速率越快）
Music.KeyPlay(Arr, , , 150)