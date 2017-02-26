import js.Browser.document;
import js.Browser.window;
import js.html.*;
import enthraler.*;

class EnthralerFrame {
	public static function main() {
		var params = getParamsFromLocation();
		loadEnthralerComponent(params);
	}

	static function getParamsFromLocation() {
		var hash = window.location.hash;
		var paramStrings = hash.substr(hash.indexOf('?') + 1).split('&');
		var params = new Map();
		for (str in paramStrings) {
			var parts = str.split('=');
			params[parts[0]] = parts[1];
		}
		return params;
	}

	static function loadEnthralerComponent(params:Map<String,String>) {
		var container = document.getElementById('container');
		Enthraler.loadComponent(params['script'], params['props'], container);
	}
}
