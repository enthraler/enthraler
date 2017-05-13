package enthralerdotcom.types;

abstract Url(String) to String {
	public function new(url:String) {
		this = url;
	}
}
