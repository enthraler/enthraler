package enthraler;

import haxe.macro.Expr;
import haxe.macro.Context;

class UmdBuilder {

	/**
	A build macro to make the current class exposes the current class as a UMD build.
	**/
	public static function exposeUmd(name: String) {
		var classPath = Context.getLocalClass().toString().split('.');
		var classExpr = macro $p{classPath};
		var fields = Context.getBuildFields();
		fields.push(buildUmdTemplate(classExpr, name, new Map()));
		return fields;
	}

	static function buildUmdTemplate(module: Expr, globalVarName: String, dependencies: Map<String, String>): Field {
		var depsAsStrings = [for (url in dependencies) macro $v{url}];
		var depsAsRequires = [for (url in dependencies) macro js.Lib.require($v{url})];
		var depsAsRootProperties = [for (name in dependencies.keys()) macro js.Lib.global.$name];
		var depsAsFunctionArgs = [for (name in dependencies.keys()) {
			name: name,
			type: macro :Dynamic,
		}];
		var setDepsOnGlobal = [for (name in dependencies.keys()) macro js.Lib.global.$name = $i{name}];

		var factoryFn: Expr = {
			expr: EFunction(null, {
				args: depsAsFunctionArgs,
				expr: macro {
					$b{setDepsOnGlobal};
					return $module;
				},
				params: null,
				ret: macro :Dynamic
			}),
			pos: Context.currentPos()
		};

		var tmpClass = macro class {
			static function __init__() {
				function (root: Dynamic, factory: Dynamic) untyped {
					if (__typeof__(define) == "function" && define.amd) {
						// Export an unnamed AMD module.
						define($a{depsAsStrings}, factory);
					} else if (__typeof__(module) == "object" && module.exports) {
						// Export an unnamed CommonJS-ish module.
						// Will work for Node, but not necessarily strict CommonJS environments.
						module.exports = factory($a{depsAsRequires});
					} else {
						// Use Browser globals
						js.Lib.global.$globalVarName = factory($a{depsAsRootProperties});
					}
				}(js.Lib.global, $factoryFn);
			}
		};

		return tmpClass.fields[0];
	}
}