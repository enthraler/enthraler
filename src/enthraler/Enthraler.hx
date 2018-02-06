package enthraler;

import js.Browser;
import js.Promise;
import js.html.*;
import enthraler.Template;
import enthraler.Environment;
import enthraler.Meta;
import RequireJs;
import haxe.extern.EitherType;
// import haxe.ds.Either;
using haxe.io.Path;

typedef EnthralerInstance<AuthorData> = {
	container: Element,
	authorData: AuthorData,
	enthraler: Template<AuthorData>
}

/**
This class allows you to load a new Enthraler component.
**/
class Enthraler {

	/**
	Load an Enthraler component based on the given `Template` (`templateUrl`) and author data `dataUrl`.
	Render the new Enthraler component into the specified `container` element.

	@param templateUrl The URL pointing to the JS file for the template we are loading.
	@param data Either a String with the URL of our JSON data, or the JSON data itself.
	@param container The node to render in. If null, a new DIV will be created, which you can then attach to the document as you please.
	@return A promise of the rendered EnthralerInstance, including it's container and the loaded author data.
	**/
	public static function loadComponent<AuthorData>(templateUrl:String, data:EitherType<String,Dynamic>, container:Element):Promise<EnthralerInstance<AuthorData>> {
		if (container == null) {
			container = Browser.document.createDivElement();
		}
		var dataUrl: String = Std.is(data, String) ? data : 'local-data';
		var componentMeta = buildEnthralerMeta(templateUrl, dataUrl);
		var environment = new Environment(container, componentMeta);

		requireJsInit(componentMeta.template.path);

		var componentClassPromise = RequireJs.requireSingleModule(templateUrl);
		var dataPromise = if (Std.is(data, String)) {
			Browser.window.fetch(dataUrl).then(function (r) return r.json());
		} else {
			new Promise(function (resolve, reject) resolve(data));
		}

		return Promise.all([componentClassPromise, dataPromise]).then(function (arr:Array<Dynamic>) {
			var componentCls:Module = arr[0],
				authorData:AuthorData = arr[1];

			var component:Template<AuthorData> = componentCls.instantiate(environment);
			component.render(authorData);
			return {
				container: container,
				authorData: authorData,
				enthraler: component
			};
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
