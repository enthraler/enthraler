import js.Browser;
import js.Promise;
import js.html.*;
import enthral.Component;
import enthral.PropTypes;
import SystemJs;

@:build(enthral.CustomElementMacro.build('my-element'))
class MyComponent extends Element {
	function connectedCallback() untyped {
		this.attachShadow({ mode: 'open' });
		var myElementTemplate = Browser.document.getElementById('myTemplate');
		var templateNode = document.importNode(myElementTemplate.content, true);
		this.shadowRoot.appendChild(templateNode);
		ShadyCSS.applyStyle(this);
	}
}

class Enthral {
	static function main() {
		var myElementTemplate:TemplateElement = cast Browser.document.getElementById('myTemplate');
		trace(myElementTemplate.content);
		untyped ShadyCSS.prepareTemplate(myElementTemplate, 'my-element');

		Browser.document.getElementById('container').innerHTML = '<my-element>Light DOM content is also affected.</my-element>';

		// var enthral = new Enthral();
		// enthral.setupComponents();
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
		var scriptPromise = SystemJs.importJs(componentScriptUrl).then(loadModuleDependencies);
		var dataPromise = Browser.window.fetch(componentDataUrl).then(function (resp) {
			return resp.json();
		});
		return Promise.all([scriptPromise, dataPromise]).then(function (arr:Array<Dynamic>) {
			var componentCls:Module = arr[0];
			var componentData:T = arr[1];
			var dependencies = (componentCls:Dynamic).enthralLoadedDependencies;
			var schema = (componentCls:Dynamic).enthralPropTypes;
			if (schema != null) {
				PropTypes.validate(schema, componentData, componentDataUrl);
			}
			var component:StaticComponent<T> = componentCls.instantiate(componentData, dependencies);
			component.setupView(container);
			return component;
		});
	}

	/**
		Given a loaded module, see if an `enthralDependencies` array exists.
		If it does, load each of the dependencies, and return a promise for once they are ready to go.
	**/
	function loadModuleDependencies(module:Dynamic):Promise<Module> {
		// TODO: use an abstract here instead of Dynamic and Reflect. ObjectMap isn't quite what we need either.
		var loadedDependencies:Dynamic<Module> = {},
			promises = [];
		if (module.enthralDependencies != null) {
			var deps:Dynamic<String> = module.enthralDependencies;
			for (name in Reflect.fields(deps)) {
				var url = Reflect.field(deps, name);
				var depLoaded = SystemJs.importJs(url).then(function (dep:Module) {
					Reflect.setField(loadedDependencies, name, dep);
				});
				promises.push(depLoaded);
			}
		}
		return Promise.all(promises).then(function (_) {
			module.enthralLoadedDependencies = loadedDependencies;
			return module;
		});
	}
}
