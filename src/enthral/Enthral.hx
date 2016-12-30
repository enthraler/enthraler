package enthral;

import js.Browser;
import js.Promise;
import js.html.*;
import enthral.Component;
import enthral.PropTypes;
import SystemJs;
using haxe.io.Path;

class Enthral {
	public function new() {
		SystemJs.config({
			map: {
				'd3.v3': 'https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.17/d3.min.js',
				'd3.v4': 'https://cdnjs.cloudflare.com/ajax/libs/d3/4.4.0/d3.min.js',
				'c3': 'https://cdnjs.cloudflare.com/ajax/libs/c3/0.4.11/c3.min.js',
				'c3.css': 'https://cdnjs.cloudflare.com/ajax/libs/c3/0.4.11/c3.min.css'
			},
			packages: {
				'c3': {
					map: {
						d3: 'd3.v3'
					}
				}
			},
			meta: {
				'*.css': {
					loader: 'node_modules/systemjs-plugin-css/css.js'
				}
			}
		});
		SystemJs.setObject('enthral', {
			"SystemJS": SystemJs,
			"PropTypes": enthral.PropTypes
		});
	}

	public function instantiateComponent<T>(componentScriptUrl:String, componentDataUrl:String, container:Element):Promise<StaticComponent<T>> {
		var scriptPromise = SystemJs.importJs(componentScriptUrl),
			dataPromise = Browser.window.fetch(componentDataUrl).then(function (resp:Response) {
				return resp.json().then(function (data) {
					data.enthral = {
						scriptUrl: componentScriptUrl,
						scriptPath: componentScriptUrl.directory().addTrailingSlash(),
						dataUrl: componentDataUrl,
						dataPath: componentDataUrl.directory().addTrailingSlash()
					};
					return data;
				});
			});
		return Promise.all([scriptPromise, dataPromise]).then(function (arr:Array<Dynamic>) {
			return mountComponent(arr[0], arr[1], container);
		});
	}

	function mountComponent<T>(componentCls:Module, componentData:T, container:Element):StaticComponent<T> {
		var dependencies = (componentCls:Dynamic).enthralLoadedDependencies,
			schema = (componentCls:Dynamic).enthralPropTypes,
			enthralData = (componentData:Dynamic).enthral;
		if (schema != null) {
			PropTypes.validate(schema, componentData, enthralData.dataUrl);
		}

		var component:StaticComponent<T> = componentCls.instantiate(componentData, dependencies);
		component.setupView(container);
		return component;
	}
}
