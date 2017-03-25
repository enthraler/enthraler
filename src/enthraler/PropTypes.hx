package enthraler;

import js.Browser;
import js.Error;
import Type.ValueType;

/**
A validation function to check if a property is of the correct type at runtime.

Please note these are similar to, and compatible with React PropTypes validators - https://facebook.github.io/react/docs/typechecking-with-proptypes.html
See also https://github.com/aackerman/PropTypes

@param props The properties object we are validating. This should be the entire properties object, not the value of a specific property.
@param propName The name of the property this validator should be checking.
@param descriptiveName The name of the enthraler template being created, to be used in an error message if needed.
@param location The location of the property being checked eg `property`, to be used in an error message if needed.
@return Null if the property is valid, or a `js.Error` object otherwise.
**/
typedef PropValidator = Dynamic->String->String->String->Null<Error>;

class PropTypes {
	/**
	Validate an object against a schema, logging any errors through `console.warn`.

	@param schema The PropTypes to validate against. eg `{ name: PropTypes.string.isRequired }`
	@param obj The object you are validating. eg `{ name: 'Jason' }`
	@param descriptiveName The name of the enthraler template you are validating for, to be used in warning messages
	**/
	public static function validate(schema:Dynamic<PropValidator>, obj:Dynamic, descriptiveName:String):Void {
		for (fieldName in Reflect.fields(schema)) {
			var propValidator:PropValidator = Reflect.field(schema, fieldName);
			var error = propValidator(obj, fieldName, descriptiveName, 'property');
			if (error != null) {
				Browser.console.warn(error);
			}
		}
	}

	/**
	Identical to `PropTypes.validate()`, but will throw errors rather than log warnings.

	@param schema The PropTypes to validate against. eg `{ name: PropTypes.string.isRequired }`
	@param obj The object you are validating. eg `{ name: 'Jason' }`
	@param descriptiveName The name of the enthraler template you are validating for, to be used in warning messages
	@throws `js.Error` if `obj` does not validate against the `schema`.
	**/
	public static function validateWithErrors(schema:Dynamic<PropValidator>, obj:Dynamic, descriptiveName:String):Void {
		for (fieldName in Reflect.fields(schema)) {
			var propValidator:PropValidator = Reflect.field(schema, fieldName);
			var error = propValidator(obj, fieldName, descriptiveName, 'property');
			if (error != null) {
				throw error;
			}
		}
	}
}
