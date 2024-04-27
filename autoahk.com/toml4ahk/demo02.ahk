_toml :=  Toml().read("a = 1")
filename := "test"
_file := fileopen(filename, "rw")
_writer := StringWriter()
; 返回值永远是字符串形式。
output1 := TomlWriter().write(_toml)
output2 := TomlWriter().write(_toml, _writer)
; output2 == _writer.toString()
output3 := TomlWriter().write(_toml, _file)
; output3 == _file.read()
output4 := TomlWriter().write(_toml, filename)
; output4 == fileread(filename, "utf-8")