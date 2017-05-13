package enthralerdotcom.types;

abstract UserGuid(String) to String {
	public function new(guid:String) {
		this = guid;
	}
}
