import js.Browser.document;
import js.Browser.window;
import enthraler.*;

/**
The entry point for a JS file that renders a single Enthraler in an `<iframe>` element.

This reads a `script` and `props` value from the iFrame location hash, and loads them using `Enthraler.loadComponent`

For example, an Iframe pointing to `frame.html#?script=components/templates/amd/hello.js&props=bin/data/hello-jason.json` will load:

- The Enthraler template `components/templates/amd/hello.js`
- The author data / content `bin/data/hello-jason.json`

And it will render them into an element with the ID `container`.
**/
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
