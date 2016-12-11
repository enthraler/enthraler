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
		return instantiateComponent(script, props, elm);
	}

	public function instantiateComponent<T>(componentScriptUrl:String, componentDataUrl:String, container:Element):Promise<StaticComponent<T>> {
		var scriptPromise = SystemJs.importJs(componentScriptUrl);
		var dataPromise = Browser.window.fetch(componentDataUrl).then(function (resp) {
			return resp.json();
		});
		return Promise.all([scriptPromise, dataPromise]).then(function (arr:Array<Dynamic>) {
			var componentCls:Module = arr[0];
			var componentData:T = arr[1];
			var component:StaticComponent<T> = componentCls.instantiate(componentData);
			component.setupView(container);
			return component;
		});
	}
}
