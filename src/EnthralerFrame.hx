import js.Browser.document;
import js.Browser.window;
import js.html.*;
import enthraler.*;
import enthraler.Enthraler;

/**
The entry point for a JS file that renders a single Enthraler in an `<iframe>` element.

This reads a `template` and `authorData` value from the iFrame location hash, and loads them using `Enthraler.loadComponent`

For example, an Iframe pointing to `frame.html#?template=components/templates/amd/hello.js&authorData=bin/data/hello-jason.json` will load:

- The Enthraler template `components/templates/amd/hello.js`
- The author data / content `bin/data/hello-jason.json`

And it will render them into an element with the ID `container`.
**/
class EnthralerFrame {
	public static function main() {
		var params = getParamsFromLocation();
		loadEnthralerComponent(params);

		// Update the editor link.
		var forkLink:AnchorElement = cast document.getElementById('enthraler-fork-link'),
			hash = window.location.hash;
		forkLink.href = '/editor.html' + hash;
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
		Enthraler
			.loadComponent(params['template'], params['authorData'], container)
			.then(function (enthralerInstance:EnthralerInstance<Dynamic>) {
				// If we receive an update with new AuthorData, send it through to the template for rendering.
				window.addEventListener('message', function (e:MessageEvent) {
					var message = e.data,
						data:Dynamic = haxe.Json.parse(message);

					switch data.context {
						case EnthralerMessages.receiveAuthorData:
							enthralerInstance.enthraler.render(data.authorData);
						default:
							trace('Received message from host', data);
					}
				});
			});
	}
}
