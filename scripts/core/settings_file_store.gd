## SettingsFileStore — one checked config-file transaction, without changing saves.
## API: persist(path:String,text:String)->Dictionary (SaveWriteTransaction report).
class_name SettingsFileStore
extends RefCounted

var backend: SaveFileStore = SaveFileStore.new()

func persist(path: String, text: String) -> Dictionary:
	return SaveWriteTransaction.write(backend, path, text.to_utf8_buffer(), 0)
