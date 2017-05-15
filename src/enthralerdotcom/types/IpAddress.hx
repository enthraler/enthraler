package enthralerdotcom.types;

import sys.db.Types;

// 39 = length of IPv6 address
abstract IpAddress(SString<39>) to String {
	public function new(ip:String) {
		this = ip;
	}
}
