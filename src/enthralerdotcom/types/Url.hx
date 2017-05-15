package enthralerdotcom.types;

import sys.db.Types;

abstract Url(SString<255>) to String {
	public function new(url:String) {
		this = url;
	}
}
