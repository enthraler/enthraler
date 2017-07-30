package enthralerdotcom;

import smalluniverse.UniversalPage;
import js.Browser.window;
import js.Browser.document;

// Import the pages we will need. They will be loaded via Reflection (for now).
import enthralerdotcom.templates.ManageTemplatesPage;
import enthralerdotcom.templates.ViewTemplatePage;
import enthralerdotcom.content.ContentEditorPage;

class Client {
	public static function main() {
		Webpack.require('./EnthralerStyles.scss');
		onReady(function () {
			var propsElem = document.getElementById('small-universe-props');
			switch propsElem.getAttribute('data-page') {
				case 'enthralerdotcom.templates.ManageTemplatesPage':
					Webpack.async(ManageTemplatesPage).then(function () {
						UniversalPage.startClientRendering(ManageTemplatesPage, propsElem.innerText);
					});
				case 'enthralerdotcom.templates.ViewTemplatePage':
					Webpack.async(ViewTemplatePage).then(function () {
						UniversalPage.startClientRendering(ViewTemplatePage, propsElem.innerText);
					});
				case 'enthralerdotcom.content.ContentEditorPage':
					Webpack.async(ContentEditorPage).then(function () {
						UniversalPage.startClientRendering(ContentEditorPage, propsElem.innerText);
					});
				default: null;
			}
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
