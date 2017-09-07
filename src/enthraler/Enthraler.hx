package enthraler;

import js.Browser;
import js.Promise;
import js.html.*;
import enthraler.Template;
import enthraler.Environment;
import enthraler.Meta;
import RequireJs;
using haxe.io.Path;

/**
This class allows you to load a new Enthraler component.
**/
class Enthraler {

	/**
	Load an Enthraler component based on the given `Template` (`templateUrl`) and author data `dataUrl`.
	Render the new Enthraler component into the specified `container` element.
	**/
	#if feature_shared_state
	public static function loadComponent<AuthorData,UserState,GroupState>(templateUrl:String, dataUrl:String, container:Element):Promise<Template<AuthorData,UserState,GroupState>> {
	#else
	public static function loadComponent<AuthorData>(templateUrl:String, dataUrl:String, container:Element):Promise<Template<AuthorData>> {
	#end
		var componentMeta = buildEnthralerMeta(templateUrl, dataUrl),
			environment = new Environment(container, componentMeta);

		requireJsInit(componentMeta.template.path);

		var componentClassPromise = RequireJs.requireSingleModule(templateUrl),
			dataPromise = Browser.window.fetch(dataUrl).then(function (r) return r.json());

		return Promise.all([componentClassPromise, dataPromise]).then(function (arr:Array<Dynamic>) {
			var componentCls:Module = arr[0],
				authorData:AuthorData = arr[1];

			// If there is a Schema defined, post a message in case there's an editor that wants to know.
			// We have this hacky way of loading because loading an AMD module without loading it's dependencies, for the purpose of extracting a single variable, is non-trivial.
			var schemaUrl:String = (componentCls['enthralerSchema'] != null) ? componentCls['enthralerSchema'] : "";
			environment.broadcastSchemaUrl(schemaUrl);

			#if feature_shared_state
			var component:Template<AuthorData, UserState, GroupState> = componentCls.instantiate(environment);
			component.render(authorData, null, null);
			#else
			var component:Template<AuthorData> = componentCls.instantiate(environment);
			component.render(authorData);
			#end
			return component;
		});
	}

	static function requireJsInit(baseUrl:String) {
		RequireJs.config({
			baseUrl: baseUrl,
			enforceDefine: true,
			paths: {
				'cdnjs': 'https://cdnjs.cloudflare.com/ajax/libs/',
				'jquery': 'https://cdnjs.cloudflare.com/ajax/libs/jquery/1.12.4/jquery.min',
			},
			map: {
				'*': {
					'css': 'https://cdnjs.cloudflare.com/ajax/libs/require-css/0.1.8/css.min.js'
				}
			}
		});

		RequireJs.namedDefine('enthraler', [], {
			Validators: enthraler.proptypes.Validators,
			PropTypes: enthraler.proptypes.PropTypes
		});
	}

	static function buildEnthralerMeta(templateUrl:String, dataUrl:String):Meta {
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
