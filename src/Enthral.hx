import enthral.Action;
import enthral.UserTypes;
import enthral.Dispatcher;
import enthral.Component;
import js.html.Element;
import js.Browser;

class Enthral {
	static function main() {
		trace('Hello');
		var cont = Browser.document.getElementById('container');
		var comp = new MyComponent({name: 'Jason'});
		comp.setupView(cont);
	}
}

class MyComponent implements StaticComponent<{name:String}> {
	public var authorData:{name:String};
	public var meta:ComponentMeta;

	public function new(authorData) {
		this.authorData = authorData;
	}

	public function setupView(container:Element) {
		container.innerHTML = 'Hello ${authorData.name}';
	}
}
