import js.Browser;
import js.Promise;
import js.html.Element;
import enthral.Component;
import SystemJs;

class Enthral {
	static function main() {
		var enthral = new Enthral();
		var cont = Browser.document.getElementById('container');
		var authorData = {name: 'Jason'};
		enthral.createEmbed('component.js', authorData, cont);
	}

	public function new() {}

	public function createEmbed<T>(componentScript:String, componentData:T, container:Element):Promise<StaticComponent<T>> {
		return SystemJs.importJs(componentScript).then(function (componentCls:Module) {
			var component:StaticComponent<T> = componentCls.instantiate(componentData);
			component.setupView(container);
			return component;
		});
	}
}
