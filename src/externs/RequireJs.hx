import haxe.Constraints.Function;
import js.Lib.global;
import js.Promise;

/**
	All options: http://requirejs.org/docs/api.html#config
**/
typedef RequireJsConfig = {
	@:optional var baseUrl:String;
	@:optional var enforceDefine:Bool;
	@:optional var paths:Dynamic<String>;
	@:optional var map:Dynamic<Dynamic<String>>;
	@:optional var bundles:Dynamic<Array<String>>;
}

@:native('requirejs')
extern class RequireJs {
	public static function config(config:RequireJsConfig):Void;

	public static inline function require(dependencies:Array<String>, callback:Function, ?errorHandler:Function):Void {
		global.require(dependencies, callback, errorHandler);
	}

	public static inline function define(dependencies:Array<String>, definition:Dynamic, ?errorHandler:Function):Void {
		global.define(dependencies, definition, errorHandler);
	}

	public static inline function namedDefine(name:String, dependencies:Array<String>, definition:Dynamic, ?errorHandler:Function):Void {
		global.define(name, dependencies, definition, errorHandler);
	}

	public static inline function requireSingleModule(url:String):Promise<Module> {
		return new Promise(function (resolve, reject) {
			require([url], function (module:Dynamic) {
				resolve(Module.fromDynamic(module));
			}, reject);
		});
	}
}

abstract Module(Any) {
	/**
	Turn any dynamic object into a `Module`.

	Please note if the object has a field called `default`, we will use that field instead of the object itself.
	This is to provide compatibility with CommonJS modules that use `export default class ...`.
	**/
	public function new(module:Dynamic) {
		if (Reflect.hasField(module, 'default')) {
			this = new Module(Reflect.field(module, 'default'));
		} else {
			this = module;
		}
	}

	/**
	Allow automatic casting of a Dynamic object to a Module.
	**/
	@:from
	inline public static function fromDynamic(obj:Any):Module {
		return new Module(obj);
	}

	/**
	Retrieve any static field on the loaded module using it's name.
	**/
	@:arrayAccess
	inline public function getStaticField(key:String):Any {
		return Reflect.field(this, key);
	}

	inline public function instantiate(?arg1:Any, ?arg2:Any, ?arg3:Any, ?arg4:Any, ?arg5:Any) {
		return inst(this, arg1, arg2, arg3, arg4, arg5);
	}

	static function inst(loadedModule:Dynamic, arg1, arg2, arg3, arg4, arg5) {
		if (Reflect.hasField(loadedModule, 'default')) {
			loadedModule = Reflect.field(loadedModule, 'default');
		}
		return untyped __js__('new loadedModule(arg1, arg2, arg3, arg4, arg5)');
	}
}
