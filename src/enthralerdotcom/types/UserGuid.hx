package enthralerdotcom.types;

import sys.db.Types;
import enthralerdotcom.util.Uuid;

abstract UserGuid(SString<36>) to String {
	public function new(guid:String) {
		this = guid;
	}

	public static function generate() {
		return new UserGuid(Uuid.generate());
	}
}
