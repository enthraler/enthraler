import js.Promise;

typedef SystemJsMapConfig = Dynamic<String>;

typedef SystemJsMetaConfig = Dynamic<{
	?loader:String,
	?format:String,
	?deps:Array<String>,
	?globals:Dynamic<String>,
	?scriptLoad:Bool,
}>;

typedef SystemJsConfig = {
	?baseURL:String,
	?map:SystemJsMapConfig,
	?meta:SystemJsMetaConfig,
	?packages:Dynamic<{
		?main:String,
		?format:String,
		?defaultExtension:String,
		?map:SystemJsMapConfig,
		?meta:SystemJsMetaConfig
	}>,
	?bundles:Dynamic<Array<String>>
};

abstract Module(Dynamic) from Dynamic {
	inline public function new(module:Dynamic) {
		this = module;
	}

	inline public function instantiate(?arg1:Dynamic, ?arg2:Dynamic, ?arg3:Dynamic, ?arg4:Dynamic, ?arg5:Dynamic) {
		return inst(this, arg1, arg2, arg3, arg4, arg5);
	}

	static function inst(loadedModule:Class<Dynamic>, arg1, arg2, arg3, arg4, arg5) {
		return untyped __js__('new loadedModule(arg1, arg2, arg3, arg4, arg5)');
	}
}

/**
	API: https://github.com/systemjs/systemjs/blob/master/docs/system-api.md
**/
@:jsRequire('systemjs/dist/system.src.js')
@:native('SystemJS')
extern class SystemJs {
	public static function amdDefine():Void;

	public static function amdRequire():Void;

	public static function config(conf:SystemJsConfig):Void;

	/**
		Instantiates a copy of SystemJS with different options.
		To reflect this properly in Haxe we would need both static and instance functions with the same names.
	**/
	public static function constructor(conf:SystemJsConfig):Class<SystemJs>;

	public static function delete(moduleName:String):Bool;

	public static function get(moduleName:String):Module;

	public static function has(moduleName:String):Bool;

	@:native('import')
	@:overload(function (file:String, normalisedParentName:String):Promise<Module> {})
	public static function importJs(file:String):Promise<Module>;

	public static function newModule(jsObject:Dynamic):Module;

	public static function normalizeSync(name:String):String;

	@:overload(function (dependencies:Array<String>, executingRequire:Bool, declare:Dynamic->Void):Void {})
	public static function register(name:String, dependencies:Array<String>, declare:Dynamic->Void):Void;

	@:overload(function (dependencies:Array<String>, executingRequire:Bool, declare:Dynamic->Dynamic->Dynamic->Void):Void {})
	public static function registerDynamic(name:String, dependencies:Array<String>, executingRequire:Bool, declare:Dynamic->Dynamic->Dynamic->Void):Void;

	public static function set(moduleName:String, module:Module):Void;

	public static function _nodeRequire():Void;

	public static inline function setObject(moduleName:String, module:Dynamic):Void {
		SystemJs.set(SystemJs.normalizeSync(moduleName), SystemJs.newModule(module));
	}
}
