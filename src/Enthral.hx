import js.Browser;
import js.Promise;
import js.html.Element;
import enthral.Component;
import SystemJs;

class Enthral {
	static function main() {
		var enthral = new Enthral();
		var cont = Browser.document.getElementById('container');
		enthral.transformElement(cont);
	}

	public function new() {}

	public function transformElement(elm:Element) {
		var script = elm.attributes.getNamedItem('data-enthral-script').value;
		var props = elm.attributes.getNamedItem('data-enthral-props').value;
		var data = haxe.Json.parse(props);
		return createEmbed(script, data, elm);
	}

	public function createEmbed<T>(componentScript:String, componentData:T, container:Element):Promise<StaticComponent<T>> {
		return SystemJs.importJs(componentScript).then(function (componentCls:Module) {
			var component:StaticComponent<T> = componentCls.instantiate(componentData);
			component.setupView(container);
			return component;
		});
	}
}
