package enthral;

import haxe.macro.Context;
import haxe.macro.Expr;

/**
	CustomElements prefer to work with ES6 style classes, which set prototypes differently to Haxe classes.
	This macro performs a few tricks to make 2
**/
class CustomElementMacro {
	public static function build(elementName:String) {
		var fields = Context.getBuildFields();

		var thisElement = macro MyComponent;
		var superElement = macro js.html.Element;

		// Add the prototype call / return statement to the constructor.
		var constructor = fields.filter(function (f) {
			return f.name == 'new';
		})[0];
		if (constructor == null) {
			constructor = (macro class ExtraFields {
				public function new() {}
			}).fields[0];
			fields.push(constructor);
		}
		switch constructor.kind {
			case FFun(fn):
				var lines:Array<Expr>;
				switch fn.expr.expr {
					case EBlock(constructorLines):
						lines = constructorLines;
					case singleConstructorLine:
						lines = [fn.expr];
						fn.expr.expr = EBlock(lines);
				}
				lines.push(macro var thisElement = $thisElement);
				lines.push(macro untyped __js__('return (thisElement.__proto__ || Object.getPrototypeOf(thisElement)).apply(this, arguments)'));
			default:
		}

		// Add the init() field which performs initialisation magic before our main() function is executed.
		var initField = (macro class ExtraFields {
			public static function __init__() {
				// Correctly set the prototype.
				untyped Object.setPrototypeOf ? Object.setPrototypeOf($thisElement, $superElement) : $thisElement.__proto__ = $superElement;
				// Register the class as a custom element.
				untyped customElements.define($v{elementName}, $thisElement);
			}
		}).fields[0];
		fields.push(initField);

		return fields;

	}
}
