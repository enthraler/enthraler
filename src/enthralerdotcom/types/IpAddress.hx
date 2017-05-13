package enthralerdotcom.types;

abstract IpAddress(String) to String {
	public function new(ip:String) {
		this = ip;
	}
}
