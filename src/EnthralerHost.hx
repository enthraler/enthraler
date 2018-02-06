import enthraler.EnthralerMessages;
import js.Browser.window;
import js.Browser.document;
import js.html.*;

/**
The entry point for a JS file that runs on the main document page, and can communicate with individual Enthraler Iframes on the page.

It uses `window.addEventListener('message', ...)` to listen fo messages from the Enthraler Iframes and process the messages accordingly.

This is used to implement functionality such as automatic height changes.
**/
class EnthralerHost {
	static function main() {
		if (document.readyState != 'loading') {
			init();
		} else {
			document.addEventListener('DOMContentLoaded', init);
		}
	}

	static function init() {
		addMessageListeners();
	}

	/**
	Add a message listener to the current window to listen to resize events coming from an Enthraler IFrame.
	**/
	public static function addMessageListeners() {
		window.addEventListener('message', function (e:MessageEvent) {
			var frameWindow:Window = e.source,
				message = e.data,
				allFrames = document.querySelectorAll('iframe.enthraler-embed'),
				currentFrame:IFrameElement = null;
			for (elm in allFrames) {
				var iframe:IFrameElement = cast elm;
				if (iframe.contentWindow == frameWindow) {
					currentFrame = iframe;
				}
			}

			if (currentFrame == null) {
				// Message came from something that wasn't an enthraler iframe.  Let's bail.
				return;
			}

			var data;
			try {
				data = haxe.Json.parse(message);
			} catch (e:Dynamic) {
				trace('Failed to parse JSON from window message:', e, message);
				return;
			}
			switch data.context {
				case EnthralerMessages.requestHeightChange:
					if (currentFrame != null) {
						currentFrame.style.height = data.height + 'px';
					}
				default:
					trace('Received message from frame', frameWindow, data);
			}
		});
	}
}
