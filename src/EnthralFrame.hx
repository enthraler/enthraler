import js.Browser;
import enthral.Enthral;

class EnthralFrame {
	public static function main() {
		var params = getParamsFromLocation();
		var enthral = new Enthral();
		var container = Browser.document.getElementById('container');
		enthral.instantiateComponent(params['script'], params['props'], container);
	}

	static function getParamsFromLocation() {
		var hash = Browser.location.hash;
		var paramStrings = hash.substr(hash.indexOf('?') + 1).split('&');
		var params = new Map();
		for (str in paramStrings) {
			var parts = str.split('=');
			params[parts[0]] = parts[1];
		}
		return params;
	}
}
