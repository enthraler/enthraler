package enthraler;

/**
	If you are building an enthraler component in Haxe, have it implement this interface.

	It will run a build macro to define the component using AMD, set up extern dependencies correctly, and check the types.
**/
@:autoBuild(enthraler.macro.HaxeComponentBuilder.build())
interface HaxeComponent<Props> {
	public function render(props:Props):Void;
}
