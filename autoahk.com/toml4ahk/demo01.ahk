; https://www.autoahk.com/archives/44337

filename := "test"
_file := fileopen(filename, "r")
_string := "a = 1"
_toml1 := Toml().read(_string)
_toml2 := Toml().read(_file)
_toml3 := Toml().read(_toml1)
_toml4 := Toml().read(filename, _type := "file")
_toml5 := Toml().read(filename, _type := "file", encoding := "utf-8")
_toml_with_defaults := Toml(_toml1).read(_file)