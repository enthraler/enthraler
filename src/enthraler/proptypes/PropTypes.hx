package enthraler.proptypes;

import haxe.extern.EitherType;
import enthraler.proptypes.Validators;

/**
PropTypes definte the type of data that an Enthraler Template expects to be given as it's "author data".

PropTypes in Enthraler are similar to the concept in React, except we use only the subset that can be represented in JSON.
The PropTypes themselves are also stored in JSON rather than being JS validation functions.

The main JSON object should be an object containing all of the expected fields, with the value being the desired `PropType`.
**/
typedef PropTypes = Dynamic<PropType>;

/**
A `PropType` can either be given as a full `PropTypeDescription` or a `SimplePropTypeName` if the field is optional and no extra data is required.

Haxe will treat either a `SimplePropTypeName` or `PropTypeDescription` the same.
If the value is a simple prop type name, then it will treat it as if the object is
**/
abstract PropType(Dynamic) from SimplePropTypeName from PropTypeDescription {

	/**
	Get the original value, however it was passed in.
	**/
	public function getOriginalValue():EitherType<SimplePropTypeName, PropTypeDescription> {
		return this;
	}

	/**
	Get the value as a `PropTypeDescription`, transforming a `SimplePropTypeName` into a description if necessary.
	**/
	@:to
	public function getDescription():PropTypeDescription {
		if (isString(this)) {
			var type:String = this,
				optional = false;
			if (type.substr(0, 1) == "?") {
				optional = true;
				type = type.substr(1);
			}
			return {
				type: type,
				optional: optional
			};
		}
		return this;
	}

	/**
	Get a Haxe enum representation of the PropType.
	This is mostly for internal use.
	**/
	public function getEnum():PropTypeEnum {
		var description = getDescription(),
			optional = description.optional == true;
		return switch description.type {
			case array: PTArray(optional);
			case bool: PTBool(optional);
			case number: PTNumber(optional);
			case integer: PTInteger(optional);
			case object: PTObject(optional);
			case string: PTString(optional);
			case oneOf: PTOneOf(description.values, optional);
			case oneOfType: PTOneOfType(description.subTypes.map(function (s) return s.getEnum()), optional);
			case arrayOf: PTArrayOf(description.subType.getEnum(), optional);
			case objectOf: PTObjectOf(description.subType.getEnum(), optional);
			case shape:
				var shape:Dynamic<PropTypeEnum> = {};
				for (field in Reflect.fields(description.shape)) {
					var subType:PropType = Reflect.field(description.shape, field);
					Reflect.setField(shape, field, subType.getEnum());
				};
				PTShape(shape, optional);
			case any: PTAny(optional);
		}
	}

	/**
	Get a `ValidatorFunction` for this PropType.

	This will be compatible with React PropTypes.
	**/
	public function getValidatorFn():ValidatorFunction {
		return getReactPropTypeFromEnum(getEnum());
	}

	static function getReactPropTypeFromEnum(pt:PropTypeEnum) {
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
				var subTypes = [for (t in types) getReactPropTypeFromEnum(t)];
				wrap(Validators.oneOfType(subTypes), optional);
			case PTArrayOf(subType, optional):
				wrap(Validators.arrayOf(getReactPropTypeFromEnum(subType)), optional);
			case PTObjectOf(subType, optional):
				wrap(Validators.objectOf(getReactPropTypeFromEnum(subType)), optional);
			case PTShape(shapeObj, optional):
				var validatorShape:Dynamic<ValidatorFunction> = {};
				for (fieldName in Reflect.fields(shapeObj)) {
					var pt:PropTypeEnum = Reflect.field(shapeObj, fieldName);
					Reflect.setField(validatorShape, fieldName, getReactPropTypeFromEnum(pt));
				}
				wrap(Validators.shape(validatorShape), optional);
			case PTAny(optional):
				wrap(Validators.any, optional);
		}
	}

	static inline function isString(value:Dynamic):Bool {
		return Std.is(value, String);
	}
}

/**
A complete representation of the options for a PropType.
**/
typedef PropTypeDescription = {
	/** The type of this field (required). **/
	type:PropTypeName,

	/**
	Is the field optional, and the Enthraler can work without it?
	If ommitted, it is assumed the field is required (and not optional).
	**/
	?optional:Bool,

	/**
	Used in combination with the `oneOf` type.
	The author value must match one of the values listed here.
	**/
	?values:Array<Dynamic>,

	/**
	Used in combination with the `arrayOf` and `objectOf` types.
	The author value must be either an array of or an object containing this sub-type as it's items.
	**/
	?subType:PropType,

	/**
	Used in combination with the `oneOfType` type.
	The author value must be one of these types.
	**/
	?subTypes:Array<PropType>,

	/**
	Used in combination with the `shape` type.
	The author data must be an object with the same fields as this shape, and each field matching the specified PropType.
	**/
	?shape:Dynamic<PropType>
};

/**
Some types do not require any extra information.

If your field is one of the types `array`, `bool`, `number`, `integer`, `object`, `string` or `any`, you can just use a simple string rather than a full `PropTypeDescription`.

If you use the above types SimplePropTypeName, it is assumed the field is required.
If you would like to use an optional field, you can use `?array`, `?bool`, `?number`, `?integer`, `?object`, `?string` or `?any` instead.
**/
@:enum abstract SimplePropTypeName(String) from String {
	var array = "array";
	var bool = "bool";
	var number = "number";
	var integer = "integer";
	var object = "object";
	var string = "string";
	var any = "any";
	var optionalArray = "?array";
	var optionalBool = "?bool";
	var optionalNumber = "?number";
	var optionalInteger = "?integer";
	var optionalObject = "?object";
	var optionalString = "?string";
	var optionalAny = "?any";
}

/**
A complete list of the available types.

Note: because we only support types that can be represented in JSON, we do not have `instanceOf`, `element`, or `node` which you might be familiar with from React.PropTypes.
**/
@:enum abstract PropTypeName(String) from String {
	var array = "array";
	var bool = "bool";
	var number = "number";
	var integer = "integer";
	var object = "object";
	var string = "string";
	var oneOf = "oneOf";
	var oneOfType = "oneOfType";
	var arrayOf = "arrayOf";
	var objectOf = "objectOf";
	var shape = "shape";
	var any = "any";
}

/**
Internal use only.

A Haxe enum representation of a `PropType`.
**/
enum PropTypeEnum {
	PTArray(optional:Bool);
	PTBool(optional:Bool);
	PTNumber(optional:Bool);
	PTInteger(optional:Bool);
	PTObject(optional:Bool);
	PTString(optional:Bool);
	PTOneOf(values:Array<Dynamic>, optional:Bool);
	PTOneOfType(types:Array<PropTypeEnum>, optional:Bool);
	PTArrayOf(subType:PropTypeEnum, optional:Bool);
	PTObjectOf(subType:PropTypeEnum, optional:Bool);
	PTShape(shape:Dynamic<PropTypeEnum>, optional:Bool);
	PTAny(optional:Bool);
}
