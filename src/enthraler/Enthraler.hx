package enthraler;

import js.Browser;
import js.Promise;
import js.html.*;
import enthraler.EnthralerTemplate;
import enthraler.EnthralerEnvironment;
import RequireJs;
using haxe.io.Path;

class Enthraler {

	public static function loadComponent<AuthorData,UserState,GroupState>(templateUrl:String, dataUrl:String, container:Element):Promise<EnthralerTemplate<AuthorData,UserState,GroupState>> {
		var componentMeta = buildEnthralerMeta(templateUrl, dataUrl),
			environment = new EnthralerEnvironment();
		requireJsInit(componentMeta.template.path);

		var componentClassPromise = RequireJs.requireSingleModule(templateUrl),
			dataPromise = Browser.window.fetch(dataUrl).then(function (r) return r.json());

		return Promise.all([componentClassPromise, dataPromise]).then(function (arr:Array<Dynamic>) {
			var componentCls:Module = arr[0],
				authorData:AuthorData = arr[1],
				schema = (componentCls:Dynamic).enthralerPropTypes;
			var config = {
				container: container,
				meta: componentMeta,
				environment: environment
				// TODO: detect if the dispatcher is needed, and inject it if so.
				// I think avoiding adding it unless it is explicitly needed might be smart.
			};
			var component:EnthralerTemplate<AuthorData, UserState, GroupState> = componentCls.instantiate(config);
			if (schema != null) {
				PropTypes.validate(schema, authorData, dataUrl);
			}
			component.render(authorData, null, null);
			return component;
		});
	}

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

		RequireJs.namedDefine('enthraler', [], {
			PropTypes: enthraler.PropTypes
		});
	}

	static function buildEnthralerMeta(templateUrl:String, dataUrl:String):EnthralerMeta {
		return {
			template: {
				url: templateUrl,
				path: templateUrl.directory().addTrailingSlash(),
			},
			content: {
				url: dataUrl,
				path: dataUrl.directory().addTrailingSlash()
			}
		};
	}
}
