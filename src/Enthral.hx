import js.Browser;
import enthral.Component;
import SystemJs;

class Enthral {
	static function main() {
		var cont = Browser.document.getElementById('container');
		var authorData = {name: 'Jason'};
		SystemJs.importJs('component.js').then(function (componentCls:Module) {
			var component:StaticComponent<{name:String}> = componentCls.instantiate(authorData);
			component.setupView(cont);
		});
	}
}
