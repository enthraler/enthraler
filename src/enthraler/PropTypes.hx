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
	@param descriptiveName The name of the component being created, to be used in an error message if needed.
	@param location The location of the property being checked eg `property`, to be used in an error message if needed.
	@return Null if the property is valid, or a `js.Error` object otherwise.
**/
typedef PropValidator = Dynamic->String->String->String->Null<Error>;

class PropTypes {
	/**
		Validate an object against a schema, logging any errors through `console.warn`.

		@param schema The PropTypes to validate against. eg `{ name: PropTypes.string.isRequired }`
		@param obj The object you are validating. eg `{ name: 'Jason' }`
		@param descriptiveName The name of the component you are validating for, to be used in warning messages
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
		@param descriptiveName The name of the component you are validating for, to be used in warning messages
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

	public static var array(default, never):PropValidator = typeCheck.bind(TClass(Array));
	public static var bool(default, never):PropValidator = typeCheck.bind(TBool);
	public static var func(default, never):PropValidator = typeCheck.bind(TFunction);
	public static var number(default, never):PropValidator = typeCheck.bind(TFloat);
	public static var integer(default, never):PropValidator = typeCheck.bind(TInt);
	public static var object(default, never):PropValidator = typeCheck.bind(TObject);
	public static var string(default, never):PropValidator = typeCheck.bind(TClass(String));
	public static var any(default, never):PropValidator = typeCheck.bind(TUnknown);

	/**
		Required versions of all of the basic validators.
	**/
	public static var required(default, never):{
		array:PropValidator,
		bool:PropValidator,
		func:PropValidator,
		number:PropValidator,
		integer:PropValidator,
		object:PropValidator,
		string:PropValidator,
		any:PropValidator,
		instanceOf:Class<Dynamic>->PropValidator,
		oneOf:Array<Dynamic>->PropValidator,
		oneOfType:Array<PropValidator>->PropValidator,
		arrayOf:PropValidator->PropValidator,
		objectOf:PropValidator->PropValidator,
		shape:Dynamic<PropValidator>->PropValidator
	} = {
		array: requiredTypeCheck(array),
		bool: requiredTypeCheck(bool),
		func: requiredTypeCheck(func),
		number: requiredTypeCheck(number),
		integer: requiredTypeCheck(integer),
		object: requiredTypeCheck(object),
		string: requiredTypeCheck(string),
		any: requiredTypeCheck(any),
		instanceOf: function (cls:Class<Dynamic>):PropValidator {
			return requiredTypeCheck(instanceOf(cls));
		},
		oneOf: function (allowedValues:Array<Dynamic>):PropValidator {
			return requiredTypeCheck(oneOf(allowedValues));
		},
		oneOfType: function (allowedTypes:Array<PropValidator>):PropValidator {
			return requiredTypeCheck(oneOfType(allowedTypes));
		},
		arrayOf: function (expectedType:PropValidator):PropValidator {
			return requiredTypeCheck(arrayOf(expectedType));
		},
		objectOf: function (expectedType:PropValidator):PropValidator {
			return requiredTypeCheck(objectOf(expectedType));
		},
		shape: function (expectedShape:Dynamic<PropValidator>):PropValidator {
			return requiredTypeCheck(shape(expectedShape));
		}
	};

	/** Expect a value to be an instance of a particular class. **/
	public static function instanceOf(cls:Class<Dynamic>):PropValidator {
		return typeCheck.bind(TClass(cls));
	}

	/** Expect a value to be one of this pre-defined set of values. **/
	public static function oneOf(allowedValues:Array<Dynamic>):PropValidator {
		return function (props:Dynamic, propName:String, descriptiveName:String, location:String):Null<Error> {
			var value = Reflect.field(props, propName);
			if (allowedValues.indexOf(value) == -1) {
				var errorMsg = 'Invalid $location `$propName` had value `$value` supplied to `$descriptiveName`, but expected one of `$allowedValues`';
				return new Error(errorMsg);
			}
			return null;
		}
	}

	/** Expect a value to be one of the given types. **/
	public static function oneOfType(allowedTypes:Array<PropValidator>):PropValidator {
		return function (props:Dynamic, propName:String, descriptiveName:String, location:String) {
			for (propValidator in allowedTypes) {
				var result = propValidator(props, propName, descriptiveName, location);
				if (result == null) {
					return null;
				}
			}

			var value = Reflect.field(props, propName);
			var actualType = Type.typeof(value);
			var errorMsg = 'Invalid $location `$propName` of type `${typeName(actualType)}` supplied to `$descriptiveName`';
			return new Error(errorMsg);
		}
	}

	/** Expect a value to be an array where every value matches the given type. **/
	public static function arrayOf(type:PropValidator):PropValidator {
		return function (props:Dynamic, propName:String, descriptiveName:String, location:String) {
			var isNotArray = array(props, propName, descriptiveName, location);
			if (isNotArray != null) {
				return isNotArray;
			}

			var values:Array<Dynamic> = Reflect.field(props, propName),
				i = 0;
			for (value in values) {
				var error = type(values, '$i', descriptiveName, location);
				if (error != null) {
					error.message += ' on item [${i}]';
					return error;
				}
				i++;
			}
			return null;
		}
	}

	/** Expect a value to be an object where every property matches the given type. **/
	public static function objectOf(type:PropValidator):PropValidator {
		return function (props:Dynamic, propName:String, descriptiveName:String, location:String) {
			var valueObj = Reflect.field(props, propName),
				fields = Reflect.fields(valueObj);
			for (field in fields) {
				var error = type(valueObj, field, descriptiveName, location);
				if (error != null) {
					error.message += ' on field `$field`';
					return error;
				}
			}
			return null;
		}
	}

	/** Expect a value to be an object, which has the same properties as described here, with each property matching the expected type. **/
	public static function shape(shape:Dynamic<PropValidator>):PropValidator {
		return function (props:Dynamic, propName:String, descriptiveName:String, location:String) {
			var valueObj = Reflect.field(props, propName),
				fields = Reflect.fields(shape);
			for (field in fields) {
				var propValidator:PropValidator = Reflect.field(shape, field);
				var error = propValidator(valueObj, field, descriptiveName, location);
				if (error != null) {
					error.message += ' on field `$field`';
					return error;
				}
			}
			return null;
		}
	}

	// Private

	static function requiredTypeCheck(check:PropValidator) {
		return function (props:Dynamic, propName:String, descriptiveName:String, location:String):Null<Error> {
			var value = Reflect.field(props, propName);
			if (value == null) {
				var errorMsg = 'Required $location `$propName` was not specified in `$descriptiveName`';
				return new Error(errorMsg);
			}
			return check(props, propName, descriptiveName, location);
		}
	}

	static function typeCheck(expectedType:ValueType, props:Dynamic, propName:String, descriptiveName:String, location:String):Null<Error> {
		var value = Reflect.field(props, propName);

		if (value == null) {
			return null;
		}

		var actualType = Type.typeof(value);
		if (Type.enumEq(actualType, expectedType)) {
			return null;
		}

		// Types are not equal, but they might be compatible.
		switch [expectedType, actualType] {
			case [TFloat, TInt]:
				return null;
			case [TObject, TClass(cls)]:
				// Any object that is not an instance of String or Array we will consider an 'Object'.
				if (cls != String && cls != Array) {
					return null;
				}
			case [TUnknown, _]:
				// If the expected type is Unknown we will consider anything compatible.
				return null;
			default:
		}

		// Types are not compatible, return an error.
		var errorMsg = 'Invalid $location `$propName` of type `${typeName(actualType)}` supplied to `$descriptiveName`, expected `${typeName(expectedType)}`';
		return new Error(errorMsg);
	}

	static function typeName(type:ValueType):String {
		return switch type {
			case TNull: 'Null Value';
			case TInt: 'Integer';
			case TFloat: 'TFloat';
			case TBool: 'TBool';
			case TObject: 'TObject';
			case TFunction: 'TFunction';
			case TClass(String): 'String';
			case TClass(Array): 'Array';
			case TClass(cls): Type.getClassName(cls) + ' Object';
			case TEnum(enm): Type.getEnumName(enm) + ' Enum Value';
			case TUnknown: 'Unknown Type';
		}
	}
}
