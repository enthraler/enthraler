/**
Until https://github.com/elsassph/haxe-modular/issues/17 is fixed, we need a hardcoded Main class instead of enthralerdotcom.Client.
**/
import enthralerdotcom.Client;

class Main {
	static function main() {
		Client.main();
	}
}
