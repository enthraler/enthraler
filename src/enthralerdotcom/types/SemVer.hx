package enthralerdotcom.types;

abstract SemVer(String) to String {
	public function new(version:String) {
		this = version;
	}
}
