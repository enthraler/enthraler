package enthralerdotcom;

import smalluniverse.UniversalPage;
import smalluniverse.SUMacro.jsx;
using tink.CoreApi;

class AboutPage extends UniversalPage<{}, {}, {}, {}> {
	override function get():Promise<{}> {
		return {};
	}

	override function render() {
		this.head.addScript('enthralerdotcom.bundle.js');
		this.head.setTitle('About!');
		return jsx('<div>
			<h1 onClick={handleClick}>About!</h1>
			<a href="/">Link to home</a>
		</div>');
	}

	override function componentDidMount():Void {
		trace('We have mounted the about page!');
	}

	@:client
	function handleClick() {
		trace('Clicked about header');
	}
}
