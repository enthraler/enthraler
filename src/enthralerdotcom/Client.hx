package enthralerdotcom;

import smalluniverse.UniversalPage;
import js.Browser.window;
import js.Browser.document;

// Import the pages we will need. They will be loaded via Reflection (for now).
import enthralerdotcom.templates.ManageTemplatesPage;
import enthralerdotcom.templates.ViewTemplatePage;
import enthralerdotcom.content.ContentEditorPage;

class Client {
	static function main() {
		Webpack.require('./EnthralerStyles.scss');
		onReady(function () {
			UniversalPage.startClientRendering();
		});
	}

	static function onReady(fn:Void->Void) {
		if (document.readyState == "loading") {
			window.addEventListener("DOMContentLoaded", fn);
		} else {
			fn();
		}
	}
}
