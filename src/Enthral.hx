import js.Browser;
import enthral.Component;
import SystemJs;

class Enthral {
	static function main() {
		var cont = Browser.document.getElementById('container');
		var authorData = {name: 'Jason'};
		SystemJs.importJs('component.js').then(function (componentCls:Dynamic) {
			var component = newComponent(componentCls, authorData);
			component.setupView(cont);
		});
	}

	/**
		Treat a dynamic value as a component class and instantiate it with author data.

		We need this because Haxe does not want to accept `new dynamicValue()` as valid syntax.
	**/
	static function newComponent<AuthorData>(cls:Dynamic, authorData:AuthorData):StaticComponent<AuthorData> {
		// TODO: check for errors, and probably check that it is in fact a component as well.
		return untyped __js__('new cls(authorData)');
	}
}
