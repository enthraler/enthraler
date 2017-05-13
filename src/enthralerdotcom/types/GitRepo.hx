package enthralerdotcom.types;

abstract GitRepo(String) to String {
	public function new(url:String) {
		this = url;
	}
}
