package enthral;

import js.Browser;
import js.Promise;
import js.html.*;
import enthral.Component;
import RequireJs;
using haxe.io.Path;

class Enthral {

	static function requireJsInit(baseUrl:String) {
		RequireJs.config({
			baseUrl: baseUrl,
			paths: {
				'jquery': 'https://cdnjs.cloudflare.com/ajax/libs/jquery/1.12.4/jquery.min',
				// 'jquery/v1': 'https://cdnjs.cloudflare.com/ajax/libs/jquery/1.12.4/jquery.min',
				// 'jquery/v2': 'https://cdnjs.cloudflare.com/ajax/libs/jquery/2.2.4/jquery.min',
				// 'jquery/v3': 'https://cdnjs.cloudflare.com/ajax/libs/jquery/3.1.1/jquery.min',
				'd3/v3': 'https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.17/d3.min',
				'd3/v4': 'https://cdnjs.cloudflare.com/ajax/libs/d3/4.4.0/d3.min',
				'c3': 'https://cdnjs.cloudflare.com/ajax/libs/c3/0.4.11/c3.min',
				'c3/styles': 'https://cdnjs.cloudflare.com/ajax/libs/c3/0.4.11/c3.min',
				'react/v15': 'https://cdnjs.cloudflare.com/ajax/libs/react/15.4.2/react.min',
				'react-dom/v15': 'https://cdnjs.cloudflare.com/ajax/libs/react/15.4.2/react-dom.min'
			},
			map: {
				'*': {
					'css': 'https://cdnjs.cloudflare.com/ajax/libs/require-css/0.1.8/css.min.js'
				},
				'c3': {
					'd3': 'd3/v3'
				},
				'react-dom/v15': {
					'react': 'react/v15'
				}
			}
		});

		RequireJs.namedDefine('enthral', [], {
			PropTypes: enthral.PropTypes
		});
	}

	public function new() {}

	public function instantiateComponent<AuthorData,UserState,GroupState>(componentScriptUrl:String, componentDataUrl:String, container:Element):Promise<Component<AuthorData,UserState,GroupState>> {
		var componentMeta = buildComponentMeta(componentScriptUrl, componentDataUrl);
		requireJsInit(componentMeta.template.path);

		var componentClassPromise = RequireJs.requireSingleModule(componentScriptUrl),
			dataPromise = Browser.window.fetch(componentDataUrl).then(function (r) return r.json());

		return Promise.all([componentClassPromise, dataPromise]).then(function (arr:Array<Dynamic>) {
			var componentCls:Module = arr[0],
				authorData:AuthorData = arr[1],
				schema = (componentCls:Dynamic).enthralPropTypes;
			var config = {
				container: container,
				meta: componentMeta
				// TODO: detect if the dispatcher is needed, and inject it if so.
				// I think avoiding adding it unless it is explicitly needed might be smart.
			};
			var component:Component<AuthorData, UserState, GroupState> = componentCls.instantiate(config);
			if (schema != null) {
				PropTypes.validate(schema, authorData, componentDataUrl);
			}
			component.render(authorData, null, null);
			return component;
		});
	}

	function buildComponentMeta(componentScriptUrl:String, componentDataUrl:String):ComponentMeta {
		return {
			template: {
				url: componentScriptUrl,
				path: componentScriptUrl.directory().addTrailingSlash(),
			},
			content: {
				url: componentDataUrl,
				path: componentDataUrl.directory().addTrailingSlash()
			}
		};
	}
}
