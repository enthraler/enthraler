import js.Browser.window;
import js.Browser.document;
import js.html.*;

class EnthralerHost {
	static function main() {
		if (document.readyState != 'loading') {
			init();
		} else {
			document.addEventListener('DOMContentLoaded', init);
		}
	}

	static function init() {
		addMessageListener();
		initAllFrames();
	}

	static function initAllFrames() {
		var frames = document.querySelectorAll('iframe.enthraler-embed');
		for (elm in frames) {
			var iframe:IFrameElement = cast elm;
			// We don't have a way to check if an iFrame on a 3rd party domain is loaded already.
			// To be safe, we send a message immediately, as well as on a 'load' event.
			initFrame(iframe);
			iframe.addEventListener('load', function (e) {
				initFrame(iframe);
			});
		}
	}

	static function initFrame(iframe:IFrameElement) {
		var message = {
			type: 'init',
			greeting: 'Hello Embed, I am Host!'
		};
		// TODO: specify an origin based on iframe.src, rather than using a wildcard.
		iframe.contentWindow.postMessage(message, '*');
	}

	static function addMessageListener() {
		window.addEventListener('message', function (e:MessageEvent) {
			var frame:Window = e.source;
			var message = e.data;
			var origin = e.origin;
			trace('Received message from frame', frame, message);
		});
	}
}
