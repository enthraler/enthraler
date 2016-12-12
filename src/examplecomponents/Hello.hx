package examplecomponents;

import enthral.Component;
import js.html.Element;

@:expose("HelloComponent")
class Hello implements StaticComponent<{name:String}> {
	public var authorData:{name:String};
	public var meta:ComponentMeta;

	public function new(authorData, deps) {
		this.authorData = authorData;
		trace(deps.jquery("body"));
	}

	public function setupView(container:Element) {
		container.innerHTML = 'Hello ${authorData.name}';
	}

	public static var enthralPropTypes = {
		name:"String"
	}
	public static var enthralDependencies = {
		jquery: "https://code.jquery.com/jquery-3.1.1.min.js"
	};
}
