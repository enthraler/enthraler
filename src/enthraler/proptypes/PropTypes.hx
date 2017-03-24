package enthraler.proptypes;

import haxe.extern.EitherType;

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
abstract PropType(Dynamic) from SimplePropTypeName from PropTypeDescription to PropTypeDescription {

	/**
	Get the original value, however it was passed in.
	**/
	public function getOriginalValue():EitherType<SimplePropTypeName, PropTypeDescription> {
		return this;
	}

	/**
	Get the value as a `PropTypeDescription`, transforming a `SimplePropTypeName` into a description if necessary.
	**/
	public function getDescription():PropTypeDescription {
		if (isString(this)) {
			return {
				type: this
			};
		}
		return this;
	}

	/**
	Get a Haxe enum representation of the PropType.
	This is mostly for internal use.
	**/
	public function getEnum():PropTypeEnum {
		var description = getDescription();
		return switch description.type {
			case array: PTArray;
			case bool: PTBool;
			case func: PTFunc;
			case number: PTNumber;
			case object: PTObject;
			case string: PTString;
			case oneOf: PTOneOf(description.values);
			case oneOfType: PTOneOfType(description.subTypes.map(function (s) return s.getEnum()));
			case arrayOf: PTArrayOf(description.subType.getEnum());
			case objectOf: PTObjectOf(description.subType.getEnum());
			case shape:
				var shape:Dynamic<PropTypeEnum> = {};
				for (field in Reflect.fields(description.shape)) {
					var subType:PropType = Reflect.field(description.shape, field);
					Reflect.setField(shape, field, subType.getEnum());
				};
				PTShape(shape);
			case any: PTAny;
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

If your field is one of the types `array`, `bool`, `func`, `number`, `object`, `string` or `any`, you can just use a simple string rather than a full `PropTypeDescription`.

If you use a SimplePropTypeName, it is assumed the field is required.
You will need to do a `PropTypeDescription` with the `optional: true` field if the field is optional.
**/
@:enum abstract SimplePropTypeName(String) from String {
	var array = "array";
	var bool = "bool";
	var func = "func";
	var number = "number";
	var object = "object";
	var string = "string";
	var any = "any";
}

/**
A complete list of the available types.

Note: because we only support types that can be represented in JSON, we do not have `instanceOf`, `element`, or `node` which you might be familiar with from React.PropTypes.
**/
@:enum abstract PropTypeName(String) from String {
	var array = "array";
	var bool = "bool";
	var func = "func";
	var number = "number";
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
	PTArray;
	PTBool;
	PTFunc;
	PTNumber;
	PTObject;
	PTString;
	PTOneOf(values:Array<Dynamic>);
	PTOneOfType(types:Array<PropTypeEnum>);
	PTArrayOf(subType:PropTypeEnum);
	PTObjectOf(subType:PropTypeEnum);
	PTShape(shape:Dynamic<PropTypeEnum>);
	PTAny;
}
