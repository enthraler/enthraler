import haxe.Constraints.Function;
import js.Lib.global;
import js.Promise;

/**
	All options: http://requirejs.org/docs/api.html#config
**/
typedef RequireJsConfig = {
	@:optional var baseUrl:String;
	@:optional var paths:Dynamic<String>;
	@:optional var map:Dynamic<Dynamic<String>>;
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
			require([url], resolve, reject);
		});
	}
}

abstract Module(Dynamic) from Dynamic {
	inline public function new(module:Dynamic) {
		this = module;
	}

	inline public function instantiate(?arg1:Dynamic, ?arg2:Dynamic, ?arg3:Dynamic, ?arg4:Dynamic, ?arg5:Dynamic) {
		return inst(this, arg1, arg2, arg3, arg4, arg5);
	}

	static function inst(loadedModule:Dynamic, arg1, arg2, arg3, arg4, arg5) {
		if (Reflect.hasField(loadedModule, 'default')) {
			loadedModule = Reflect.field(loadedModule, 'default');
		}
		return untyped __js__('new loadedModule(arg1, arg2, arg3, arg4, arg5)');
	}
}
