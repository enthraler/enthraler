package enthral;

import js.Browser;
import js.Promise;
import js.html.*;
import enthral.Component;
import enthral.PropTypes;
import SystemJs;
using haxe.io.Path;

class Enthral {

	static var systemJsInitComplete = false;
	static function systemJsInit() {
		if (systemJsInitComplete) {
			return;
		}

		SystemJs.config({
			map: {
				'jquery/v1': 'https://cdnjs.cloudflare.com/ajax/libs/jquery/1.12.4/jquery.min.js',
				'jquery/v2': 'https://cdnjs.cloudflare.com/ajax/libs/jquery/2.2.4/jquery.min.js',
				'jquery/v3': 'https://cdnjs.cloudflare.com/ajax/libs/jquery/3.1.1/jquery.min.js',
				'd3/v3': 'https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.17/d3.min.js',
				'd3/v4': 'https://cdnjs.cloudflare.com/ajax/libs/d3/4.4.0/d3.min.js',
				'c3/v0': 'https://cdnjs.cloudflare.com/ajax/libs/c3/0.4.11/c3.min.js',
				'c3/v0/c3.css': 'https://cdnjs.cloudflare.com/ajax/libs/c3/0.4.11/c3.min.css'
			},
			packages: {
				'c3/v0': {
					map: {
						d3: 'd3/v3'
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

		systemJsInitComplete = true;
	}

	public function new() {
		systemJsInit();
	}

	public function instantiateComponent<AuthorData,UserState,GroupState>(componentScriptUrl:String, componentDataUrl:String, container:Element):Promise<Component<AuthorData,UserState,GroupState>> {
		var componentClassPromise = SystemJs.importJs(componentScriptUrl),
			componentMeta:ComponentMeta = {
				template:{
					name: null,
					url: componentScriptUrl,
					path: componentScriptUrl.directory().addTrailingSlash(),
					version: null
				},
				content:{
					name: null,
					url: componentDataUrl,
					path: componentDataUrl.directory().addTrailingSlash(),
					version: null,
					author: null
				},
				instance:{
					publisher: null
				}
			},
			componentPromise = componentClassPromise.then(function (componentCls:Module) {
				var config = {
					container: container,
					meta: componentMeta
					// TODO: detect if the dispatcher is needed, and inject it if so.
					// I think avoiding adding it unless it is explicitly needed might be smart.
				};
				var component:Component<AuthorData, UserState, GroupState> = componentCls.instantiate(config);
				return component;
			}),
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
		return Promise.all([componentClassPromise, componentPromise, dataPromise]).then(function (arr:Array<Dynamic>) {
			var componentCls:Dynamic = arr[0],
				component:Component<AuthorData, UserState, GroupState> = arr[1],
				authorData:AuthorData = arr[2],
				schema = componentCls.enthralPropTypes,
				enthralData = (authorData:Dynamic).enthral;
			if (schema != null) {
				PropTypes.validate(schema, authorData, enthralData.dataUrl);
			}
			component.render(authorData, null, null);
			return component;
		});
	}
}
