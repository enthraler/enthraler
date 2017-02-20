package enthraler;

/**
	If you are building an enthraler template in Haxe, have it implement this interface.

	It will run a build macro to define the template using AMD, set up extern dependencies correctly, and (TODO) check the types match our typedef.
**/
@:autoBuild(enthraler.macro.HaxeEnthralerTemplateBuilder.build())
interface HaxeEnthralerTemplate<Props> {
	public function render(props:Props):Void;
}
