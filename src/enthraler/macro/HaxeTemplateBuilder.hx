package enthraler.macro;

import haxe.macro.Expr;
import haxe.macro.Context;
using tink.MacroApi;
using StringTools;

/**
This class provides a build macro used by `HaxeTemplate`.
**/
class HaxeTemplateBuilder {
	public static function build() {
		return ClassBuilder.run([
			addKeepMetadata,
			addAmdModuleDefinition
		]);
	}

	/**
	Add metadata required to keep the enthraler template from being DCE'd.

	Note: @:keepSub on the interface is not sufficient because we need `@:keepInit` to avoid DCE, and that needs to be applied to each class, not just the interface.
	**/
	static function addKeepMetadata(cb:ClassBuilder) {
		cb.target.meta.add(':keep', [], cb.target.pos);
		cb.target.meta.add(':keepInit', [], cb.target.pos);
	}

	/**
	Create a magic Haxe `__init__` field to trigger the AMD definition when the JS loads.
	**/
	static function addAmdModuleDefinition(cb:ClassBuilder) {
		var className = cb.target.name;
		var deps = getDependencies(cb);
		var depsArray = macro ($a{deps.list}:Array<String>);

		// Define the AMD callback function.
		// We need the arguments of the function to match those of the dependencies we are requesting.
		var amdCallback = macro function () {
			$b{deps.setters};
			return $i{className};
		};
		switch amdCallback.expr {
			case EFunction(null, fnDefinition):
				fnDefinition.args = [for (ident in deps.identifiers) {
					name: ident.getIdent().sure(),
					type: null
				}];
			default:
		}

		// Some modules might expect dependencies under a certain name.
		// If so, we need to call `requirejs.config({map: ...})` so that the names are mapped correctly.
		var configExpr = macro null;
		if (Lambda.count(deps.mappings) > 0) {
			var mappingFields = [for (name in deps.mappings.keys())
				{'field': name, 'expr': deps.mappings[name]}
			];
			var mappingExpr = {
				expr: EObjectDecl(mappingFields),
				pos: cb.target.pos
			};
			configExpr = macro js.Lib.global.requirejs.config({
				map: {
					'*': $mappingExpr
				}
			});
		}

		// Add the __init__ function
		var initField = (macro class Tmp {
			static function __init__() {
				$configExpr;
				js.Lib.global.define($depsArray, $amdCallback);
			}
		}).fields[0];
		cb.addMember(initField);
	}

	/**
	Fetch information about all the dependencies defined with `@:enthralerDependency` data.
	This will also modify the externs in those dependencies to use a new `@:native` name, which we will set during the AMD definition.
	**/
	static function getDependencies(cb:ClassBuilder) {
		var deps = {
			list: [],
			identifiers: [],
			setters: [],
			mappings: new Map()
		};
		var i = 0;
		for (meta in cb.target.meta.extract(':enthralerDependency')) {
			if (meta.params == null || meta.params.length < 1) {
				Context.warning('@:enthralerDependency metadata should have at least 1 parameter, for example: @:enthralerDependency("jquery", js.jquery.JQuery, "$")', meta.pos);
				continue;
			}
			var dependencyString = meta.params[0];
			deps.list.push(dependencyString);

			if (meta.params.length == 1) {
				// We are loading the dependency, but do not need to link it to an extern.
				deps.identifiers.push(macro _);
				continue;
			}

			// We need to link the dependency to an extern.
			var externPath = meta.params[1],
				externTypeName = getFullTypeNameFromExternPath(externPath),
				externIdentName = externTypeName.replace('.', '_'),
				depIdent = macro $i{externIdentName};

			changeNativeNameForExtern(externTypeName, externIdentName, externPath.pos);

			deps.identifiers.push(depIdent);
			deps.setters.push(
				macro js.Lib.global.$externIdentName = $depIdent
			);

			if (meta.params.length > 2) {
				var exposeExpr = meta.params[2];
				switch exposeExpr.expr {
					case EConst(CString(exposeName)):
						deps.mappings[exposeName] = dependencyString;
					case other:
						Context.error('Expected 3rd parameter to be a String, but was ${exposeExpr.toString()}', exposeExpr.pos);
				}
			}
		}
		return deps;
	}

	/**
	Transform a simple expression like `JQuery` into the string "js.jquery.JQuery" representing the full path to that type.
	Takes into account local imports etc.
	**/
	static function getFullTypeNameFromExternPath(externPath:Expr) {
		switch (externPath.typeof().sure()) {
			case TType(_.get().name => typeName, []):
				var classNameRegex = ~/Class<([a-zA-Z0-9.]+)>/;
				classNameRegex.match(typeName);
				var className = classNameRegex.matched(1);
				return className;
			default:
				Context.error('Could not extract class name from ' +  externPath.toString(), externPath.pos);
				return null;
		}
	}

	/**
	Find a type given the name, and change it's @:native metadata.
	**/
	static function changeNativeNameForExtern(typeName:String, newNativeName:String, pos:Position) {
		var type = Context.getType(typeName);
		switch type {
			case TInst(_.get() => ct, []) if (ct.isExtern):
				var nativeNameExpr = newNativeName.toExpr(pos);
				ct.meta.remove(':native');
				ct.meta.add(':native', [nativeNameExpr], pos);
			default:
				Context.error('Type $typeName was not an extern class', pos);
		}
	}
}
