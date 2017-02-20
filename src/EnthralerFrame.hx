import js.Browser.document;
import js.Browser.window;
import js.html.*;
import enthraler.Enthraler;

class EnthralerFrame {
	public static function main() {
		var params = getParamsFromLocation();
		addMessageListener();
		loadEnthralerEmbed(params);
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
				// TODO: use the host origin.
				host.postMessage(reply, '*');
			} else {
				// TODO: Check the origin!
			}
		});
	}

	static function loadEnthralerEmbed(params:Map<String,String>) {
		var container = document.getElementById('container');
		Enthraler.instantiateComponent(params['script'], params['props'], container);
	}
}
