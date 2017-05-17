package enthralerdotcom.templates;

import smalluniverse.UniversalPage;
import smalluniverse.SUMacro.jsx;
using tink.CoreApi;

class ManageTemplatesPage extends UniversalPage<{}, {}, {}, {}> {
	override function get():Promise<{}> {
		return {};
	}

	override function render() {
		this.head.addScript('enthralerdotcom.bundle.js');
		this.head.setTitle('Manage templates!');
		return jsx('<div>
			<h1>Manage Templates</h1>
			<a href="/">Link to home</a>
		</div>');
	}

	override function componentDidMount():Void {
		trace('We have mounted the templates page!');
	}
}
