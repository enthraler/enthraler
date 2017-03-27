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
			myZeroValue: 0,
			myEmptyString: "",
			myArrayOfInts: [1,2,3],
			myArrayOfStrings: ["a", "b", "c"],
			myMixedArray: (["a", 1]:Array<Dynamic>),
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
					'myZeroValue' => true,
					'myEmptyString' => false,
					'myString' => false,
					'myArrayOfInts' => true,
					'myTrueValue' => false
				]);
			});
			it("should have a function that validates an integer");
			it("should have a function that validates an object");
			it("should have a function that validates an string");
			it("should have a function that validates any value");
		});
	}
}
