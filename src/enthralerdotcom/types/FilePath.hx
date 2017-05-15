package enthralerdotcom.types;

import sys.db.Types;

abstract FilePath(SString<255>) to String {
	public function new(filePath:String) {
		this = filePath;
	}
}
