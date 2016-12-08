import js.Promise;

typedef SystemJsConfig = {
	?baseURL:String
};

@:native('SystemJS')
extern class SystemJs {
	public static function config(conf:SystemJsConfig):Void;
	@:native('import') public static function importJs(file:String):Promise<Dynamic>;
}
