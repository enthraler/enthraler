import js.Browser.document;
import js.Browser.window;
import js.html.*;
import enthral.Enthral;

class EnthralFrame {
	public static function main() {
		var params = getParamsFromLocation();
		addMessageListener();
		loadEnthralEmbed(params);
	}

	static function loadEnthralEmbed(params:Map<String,String>) {
		var enthral = new Enthral();
		var container = document.getElementById('container');
		enthral.instantiateComponent(params['script'], params['props'], container);
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

	static function addMessageListener() {
		window.addEventListener('message', function (e:MessageEvent) {
			var host:Window = e.source;
			var message = e.data;
			var origin = e.origin;

			if (message.type == 'init') {
				var reply = {
					'type': 'register',
					'url': window.location.hash
				};
				trace('Connected to host:', host);
				// TODO: use the host origin.
				host.postMessage(reply, '*');
			} else {
				// Check the origin!
				trace('Is origin correct?', origin);
			}
		});
	}
}
