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
	}

	static function addMessageListener() {
		window.addEventListener('message', function (e:MessageEvent) {
			var frameWindow:Window = e.source,
				message = e.data,
				data = haxe.Json.parse(message),
				allFrames = document.querySelectorAll('iframe.enthraler-embed'),
				currentFrame:IFrameElement = null;
			for (elm in allFrames) {
				var iframe:IFrameElement = cast elm;
				if (iframe.contentWindow == frameWindow) {
					currentFrame = iframe;
				}
			}

			switch data.context {
				case "iframe.resize":
					if (currentFrame != null) {
						currentFrame.style.height = data.height + 'px';
					}
				default:
					trace('Received message from frame', frameWindow, data);
			}
		});
	}
}
