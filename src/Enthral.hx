import js.Browser;
import js.Promise;
import js.html.Element;
import enthral.Component;
import SystemJs;

class Enthral {
	static function main() {
		var enthral = new Enthral();
		enthral.setupComponents();
	}

	public function new() {}

	public function setupComponents(?container:Element) {
		if (container == null) {
			container = Browser.document.body;
		}

		var embeds = container.getElementsByClassName('enthral-embed');
		for (elm in embeds) {
			setupComponent(elm);
		}
	}

	public function setupComponent(elm:Element) {
		var script = elm.attributes.getNamedItem('data-enthral-script').value;
		var props = elm.attributes.getNamedItem('data-enthral-props').value;
		var data = haxe.Json.parse(props);
		return instantiateComponent(script, data, elm);
	}

	public function instantiateComponent<T>(componentScript:String, componentData:T, container:Element):Promise<StaticComponent<T>> {
		return SystemJs.importJs(componentScript).then(function (componentCls:Module) {
			var component:StaticComponent<T> = componentCls.instantiate(componentData);
			component.setupView(container);
			return component;
		});
	}
}
