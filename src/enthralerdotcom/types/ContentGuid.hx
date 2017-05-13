package enthralerdotcom.types;

abstract ContentGuid(String) to String {
	public function new(guid:String) {
		this = guid;
	}
}
