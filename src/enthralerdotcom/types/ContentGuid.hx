package enthralerdotcom.types;

import sys.db.Types;

abstract ContentGuid(SString<36>) to String {
	public function new(guid:String) {
		this = guid;
	}
}
