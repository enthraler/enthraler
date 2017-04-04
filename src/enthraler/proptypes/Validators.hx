package enthraler.proptypes;

import enthraler.proptypes.PropTypes;
import js.Error;
import Type;

/**
A validation function to check if a property is of the correct type at runtime.

These are compatible with React PropTypes validators.

With Enthraler, you should generally create your schema using JSON rather than using JS functions.
You can then use `PropType.getReactPropType()` to generate a ValidatorFunction.

@param props The properties object we are validating. This should be the entire properties object, not the value of a specific property.
@param propName The name of the property this validator should be checking.
@param descriptiveName The name of the enthraler template being created, to be used in an error message if needed.
@param location The location of the property being checked eg `property`, to be used in an error message if needed.
@return Null if the property is valid, or a `ValidationError` object otherwise.
**/
typedef ValidatorFunction = Dynamic->String->String->String->Null<ValidationError>;

/**
A collection of basic `ValidatorFunction`s that match all the common cases for Enthraler PropTypes.
**/
class Validators {

	/**
	Validate an object against a `PropTypes` schema, returning any errors that were encountered.

	@param schema The PropTypes to validate against. eg `{ name: "string" }`
	@param obj The object you are validating. eg `{ name: 'Jason' }`
	@param descriptiveName The name of the enthraler template you are validating for, to be used in warning messages.
	@return Returns null if no errors were encountered, or an array of errors otherwise.
	**/
	public static function validate(schema:PropTypes, obj:Dynamic, descriptiveName:String):Null<Array<ValidationError>> {
		var errors = [];
		for (fieldName in schema.keys()) {
			var propType = schema[fieldName],
				propValidator = propType.getValidatorFn();
			var error = propValidator(obj, fieldName, descriptiveName, 'property');
			if (error != null) {
				errors.push(error);
			}
		}
		return errors.length > 0 ? errors : null;
	}

	/**
	Take a PropTypeEnum and return a valid ValidatorFunction.
	**/
	public static function getValidatorFnFromPropType(pt:PropTypeEnum) {
		inline function wrap(check:ValidatorFunction, isOptional:Null<Bool>) {
			return isOptional ? check : Validators.required(check);
		}

		return switch pt {
			case PTArray(optional):
				wrap(Validators.array, optional);
			case PTBool(optional):
				wrap(Validators.bool, optional);
			case PTNumber(optional):
				wrap(Validators.number, optional);
			case PTInteger(optional):
				wrap(Validators.integer, optional);
			case PTObject(optional):
				wrap(Validators.object, optional);
			case PTString(optional):
				wrap(Validators.string, optional);
			case PTOneOf(values, optional):
				wrap(Validators.oneOf(values), optional);
			case PTOneOfType(types, optional):
				var subTypes = [for (t in types) getValidatorFnFromPropType(t)];
				wrap(Validators.oneOfType(subTypes), optional);
			case PTArrayOf(subType, optional):
				wrap(Validators.arrayOf(getValidatorFnFromPropType(subType)), optional);
			case PTObjectOf(subType, optional):
				wrap(Validators.objectOf(getValidatorFnFromPropType(subType)), optional);
			case PTShape(shapeObj, optional):
				var validatorShape:Dynamic<ValidatorFunction> = {};
				for (fieldName in Reflect.fields(shapeObj)) {
					var pt:PropTypeEnum = Reflect.field(shapeObj, fieldName);
					Reflect.setField(validatorShape, fieldName, getValidatorFnFromPropType(pt));
				}
				wrap(Validators.shape(validatorShape), optional);
			case PTAny(optional):
				wrap(Validators.any, optional);
		}
	}

	/** Wrap any other validator with a "required" check to ensure it is present. **/
	public static function required(check:ValidatorFunction) {
		return function (props:Dynamic, propName:String, descriptiveName:String, location:String):Null<ValidationError> {
			var value = Reflect.field(props, propName);
			if (value == null) {
				var errorMsg = 'Required $location `$propName` was not specified in `$descriptiveName`';
				var error = new ValidationError(errorMsg);
				error.errorPath.unshift(AccessProperty(propName));
				return error;
			}
			return check(props, propName, descriptiveName, location);
		}
	}

	/** Validate that the value is an Array. **/
	public static var array(default, never):ValidatorFunction = typeCheck.bind(TClass(Array));
	/** Validate that the value is either true or false. **/
	public static var bool(default, never):ValidatorFunction = typeCheck.bind(TBool);
	/** Validate that the value is a number. **/
	public static var number(default, never):ValidatorFunction = typeCheck.bind(TFloat);
	/** Validate that the value is an integer. **/
	public static var integer(default, never):ValidatorFunction = typeCheck.bind(TInt);
	/** Validate that the value is an object (either a plain anonymous object, or a class instance). **/
	public static var object(default, never):ValidatorFunction = typeCheck.bind(TObject);
	/**
	Validate that the value is a string.
	Please note that an empty string `""` is still considered a valid string.
	**/
	public static var string(default, never):ValidatorFunction = typeCheck.bind(TClass(String));
	/** A validator that matches any value. **/
	public static var any(default, never):ValidatorFunction = typeCheck.bind(TUnknown);

	/**
	Expect a value to be one of this pre-defined set of values.

	Please note if using objects or arrays here, strict equality is used.
	This means that when using `oneOf()` in PropTypes that are validating JSON, you should stick to primitive types like Strings, Booleans and Numbers.
	**/
	public static function oneOf(allowedValues:Array<Dynamic>):ValidatorFunction {
		return function (props:Dynamic, propName:String, descriptiveName:String, location:String):Null<ValidationError> {
			var value = Reflect.field(props, propName);
			if (value !=null && allowedValues.indexOf(value) == -1) {
				var errorMsg = 'Invalid $location `$propName` had value `$value` supplied to `$descriptiveName`, but expected one of `$allowedValues`';
				var error = new ValidationError(errorMsg);
				error.errorPath.unshift(AccessProperty(propName));
				return error;
			}
			return null;
		}
	}

	/** Expect a value to be one of the given types. **/
	public static function oneOfType(allowedTypes:Array<ValidatorFunction>):ValidatorFunction {
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
			var error = new ValidationError(errorMsg);
			error.errorPath.unshift(AccessProperty(propName));
			return error;
		}
	}

	/** Expect a value to be an array where every value matches the given type. **/
	public static function arrayOf(type:ValidatorFunction):ValidatorFunction {
		return function (props:Dynamic, propName:String, descriptiveName:String, location:String) {
			var isNotArray = array(props, propName, descriptiveName, location);
			if (isNotArray != null) {
				return isNotArray;
			}

			var values:Array<Dynamic> = Reflect.field(props, propName),
				errors = [],
				propertyPath = AccessProperty(propName),
				i = 0;
			for (value in values) {
				var error = type(values, '$i', descriptiveName, 'array item');
				if (error != null) {
					// The validator probably assumed a property access, replace it with an array access.
					error.errorPath.shift();
					error.errorPath.unshift(AccessArray(i));
					error.errorPath.unshift(propertyPath);
					errors.push(error);
				}
				i++;
			}
			if (errors.length > 0) {
				var itemOrItems = (errors.length == 1) ? "item" : "items",
					error = new ValidationError('The array in $location `$propName` contained ${errors.length} invalid $itemOrItems');
				error.childErrors = errors;
				error.errorPath.unshift(propertyPath);
				return error;
			}
			return null;
		}
	}

	/** Expect a value to be an object where every property matches the given type. **/
	public static function objectOf(type:ValidatorFunction):ValidatorFunction {
		return function (props:Dynamic, propName:String, descriptiveName:String, location:String) {
			var error = typeCheck(TObject, props, propName, descriptiveName, location);
			if (error != null) {
				return error;
			}

			var valueObj = Reflect.field(props, propName),
				errors = [],
				propertyPath = AccessProperty(propName),
				fields = Reflect.fields(valueObj);
			for (field in fields) {
				var error = type(valueObj, field, descriptiveName, 'field');
				if (error != null) {
					error.errorPath.unshift(AccessProperty(field));
					error.errorPath.unshift(propertyPath);
					errors.push(error);
				}
			}
			if (errors.length > 0) {
				var fieldOrFields = (errors.length == 1) ? "field" : "fields",
					error = new ValidationError('The object in $location `$propName` contained ${errors.length} invalid $fieldOrFields');
				error.childErrors = errors;
				error.errorPath.unshift(propertyPath);
				return error;
			}
			return null;
		}
	}

	/** Expect a value to be an object, which has the same properties as described here, with each property matching the expected type. **/
	public static function shape(shape:Dynamic<ValidatorFunction>):ValidatorFunction {
		return function (props:Dynamic, propName:String, descriptiveName:String, location:String) {
			var valueObj = Reflect.field(props, propName),
				errors = [],
				propertyPath = AccessProperty(propName),
				fields = Reflect.fields(shape);
			for (field in fields) {
				var propValidator:ValidatorFunction = Reflect.field(shape, field);
				var error = propValidator(valueObj, field, descriptiveName, 'field');
				if (error != null) {
					error.errorPath.unshift(AccessProperty(field));
					error.errorPath.unshift(propertyPath);
					errors.push(error);
				}
			}
			if (errors.length > 0) {
				var fieldOrFields = (errors.length == 1) ? "field" : "fields",
					error = new ValidationError('The object in $location `$propName` contained ${errors.length} invalid $fieldOrFields');
				error.childErrors = errors;
				error.errorPath.unshift(propertyPath);
				return error;
			}
			return null;
		}
	}

	// Private

	static function typeCheck(expectedType:ValueType, props:Dynamic, propName:String, descriptiveName:String, location:String):Null<ValidationError> {
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
		var error = new ValidationError(errorMsg);
		error.errorPath.unshift(AccessProperty(propName));
		return error;
	}

	static function typeName(type:ValueType):String {
		return switch type {
			case TNull: 'Null Value';
			case TInt: 'Integer';
			case TFloat: 'Float';
			case TBool: 'Bool';
			case TObject: 'Object';
			case TFunction: 'Function';
			case TClass(String): 'String';
			case TClass(Array): 'Array';
			case TClass(cls): Type.getClassName(cls) + ' Object';
			case TEnum(enm): Type.getEnumName(enm) + ' Enum Value';
			case TUnknown: 'Unknown Type';
		}
	}

	/**
	Return a JS error that stores the property name.
	**/
	static function newError(propertyName:String, message:String):ValidationError {
		var err = new ValidationError(message);
		err.errorPath.unshift(AccessProperty(propertyName));
		return err;
	}
}

/**
A special error class that we can use.
**/
class ValidationError extends js.Error {
	public var errorPath:Array<ValidationPathPart>;
	public var childErrors:Array<ValidationError>;

	public function new(message:String) {
		super(message);
		this.name = "ValidationError";
		this.message = message;
		this.errorPath = [];
		this.childErrors = [];
	}

	public function getErrorPath():String {
		return [for (p in errorPath) switch p {
			case AccessProperty(name): '.$name';
			case AccessArray(itemNumber): '[$itemNumber]';
		}].join('');
	}

	public function toString():String {
		return getErrorPath() + ": " + message;
	}
}

/**
An enum used by `ValidationError.errorPath` to allow us to "drill down" to any item in a JSON tree.
**/
enum ValidationPathPart {
	AccessProperty(name:String);
	AccessArray(itemNumber:Int);
}
