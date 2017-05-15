package enthralerdotcom.types;

import sys.db.Types;

abstract SemVer(SString<255>) to String {
	public function new(version:String) {
		this = version;
	}
}
