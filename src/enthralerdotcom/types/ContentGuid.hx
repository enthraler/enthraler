package enthralerdotcom.types;

import sys.db.Types;
import enthralerdotcom.util.Uuid;

abstract ContentGuid(SString<36>) to String {
	public function new(guid:String) {
		this = guid;
	}

	public static function generate() {
		return new ContentGuid(Uuid.generate());
	}
}
