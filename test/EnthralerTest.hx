using buddy.Should;

import enthraler.proptypes.Validators;
import haxe.PosInfos;
import js.Error;

class EnthralerTest extends buddy.SingleSuite {
	public function new() {
		var testData = {
			myNullValue: null,
			myNanValue: Math.NaN,
			myInfinityValue: Math.POSITIVE_INFINITY,
			myTrueValue: true,
			myFalseValue: false,
			myString: "Jason",
			myFloat: 3.14,
			myInt: 99,
			myIntegerFloat: 3.0,
			myZeroValue: 0,
			myEmptyString: "",
			myArrayOfInts: [1,2,3],
			myArrayOfStrings: ["a", "b", "c"],
			myMixedArray: (["a", 1]:Array<Dynamic>),
			myObject: {name: "Jason"},
			myInstance: this
		};

		function testValidator(validator:ValidatorFunction, fields:Map<String,Bool>, ?p:PosInfos) {
			for (field in fields.keys()) {
				var result = validator(testData, field, 'template.js', 'property');
				if (fields[field]) {
					// It should validate
					result.should.be(null, p);
				} else {
					// It should return an error
					result.should.beType(Error, p);
				}
			}
		}

		describe("Using Validators", {
			it("should have a function that validates an array", {
				testValidator(Validators.array, [
					'myNullValue' => true,
					'myArrayOfInts' => true,
					'myArrayOfStrings' => true,
					'myInt' => false,
					'myString' => false
				]);
			});
			it("should have a function that validates a boolean", {
				testValidator(Validators.bool, [
					'myNullValue' => true,
					'myTrueValue' => true,
					'myFalseValue' => true,
					'myZeroValue' => false,
					'myEmptyString' => false,
					'myString' => false,
					'myArrayOfInts' => false
				]);
			});
			it("should have a function that validates a float", {
				testValidator(Validators.number, [
					'myNullValue' => true,
					'myInfinityValue' => true,
					'myNanValue' => true,
					'myFloat' => true,
					'myInt' => true,
					'myIntegerFloat' => true,
					'myZeroValue' => true,
					'myEmptyString' => false,
					'myString' => false,
					'myArrayOfInts' => false,
					'myTrueValue' => false
				]);
			});
			it("should have a function that validates an integer", {
				testValidator(Validators.integer, [
					'myNullValue' => true,
					'myInfinityValue' => false,
					'myNanValue' => false,
					'myFloat' => false,
					'myInt' => true,
					'myIntegerFloat' => true,
					'myZeroValue' => true,
					'myEmptyString' => false,
					'myString' => false,
					'myArrayOfInts' => false,
					'myTrueValue' => false
				]);
			});
			it("should have a function that validates an object", {
				testValidator(Validators.object, [
					'myNullValue' => true,
					'myObject' => true,
					'myInstance' => true,
					'myFloat' => false,
					'myInt' => false,
					'myString' => false,
					'myArrayOfInts' => false,
					'myTrueValue' => false
				]);
			});
			it("should have a function that validates an string", {
				testValidator(Validators.string, [
					'myNullValue' => true,
					'myEmptyString' => true,
					'myString' => true,
					'myFloat' => false,
					'myInt' => false,
					'myArrayOfInts' => false,
					'myTrueValue' => false,
					'myObject' => false
				]);
			});
			it("should have a function that validates any value", {
				testValidator(Validators.any, [
					'myNullValue' => true,
					'myEmptyString' => true,
					'myString' => true,
					'myFloat' => true,
					'myInt' => true,
					'myArrayOfInts' => true,
					'myTrueValue' => true,
					'myObject' => true
				]);
			});
			it("should have a function that validates the `oneOf` type");
			it("should have a function that validates the `oneOfType` type");
			it("should have a function that validates the `objectOf` type");
			it("should have a function that validates the `arrayOf` type");
			it("should have a function that validates the `shape` type");
			it("should have a function that makes any other type required");

			describe("validate()", {});
			describe("getValidatorFnFromPropType()", {});
		});
	}
}
