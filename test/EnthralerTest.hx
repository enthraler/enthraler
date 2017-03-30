using buddy.Should;

import enthraler.proptypes.Validators;
import enthraler.proptypes.PropTypes;
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
			myObjectOfInts: { "1":1, "2":2, "3":3 },
			myArrayOfStrings: ["a", "b", "c"],
			myObjectOfStrings: { "a":"a", "b":"b", "c":"c" },
			myMixedArray: (["a", 1]:Array<Dynamic>),
			myMixedObject: { "a":1, "b":"b" },
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

		describe("Using the basic validator functions", {
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
			it("should have a function that validates the `oneOf` type", {
				var validValues:Array<Dynamic> = [99, "Jason", true, testData.myObject, [1,2,3]];
				testValidator(Validators.oneOf(validValues), [
					'myNullValue' => true,
					'myInt' => true,
					'myString' => true,
					'myTrueValue' => true,
					'myObject' => true,
					'myFloat' => false,
					'myEmptyString' => false,
					'myArrayOfInts' => false, // Same as array above, but it is testing strict equality, so not a match.
					'myInstance' => false
				]);
			});
			it("should have a function that validates the `oneOfType` type", {
				testValidator(Validators.oneOfType([Validators.integer, Validators.object]), [
					'myInt' => true,
					'myObject' => true,
					'myString' => false,
					'myTrueValue' => false,
					'myFloat' => false,
					'myEmptyString' => false,
					'myArrayOfInts' => false,
					'myInstance' => true
				]);
			});
			it("should have a function that validates the `objectOf` type", {
				testValidator(Validators.objectOf(Validators.integer), [
					'myObjectOfInts' => true,
					'myObjectOfStrings' => false,
					'myMixedObject' => false,
					'myObject' => false,
					'myArrayOfInts' => false,
					'myArrayOfStrings' => false,
					'myInstance' => false,
					'myInt' => false,
					'myString' => false,
					'myTrueValue' => false
				]);
				testValidator(Validators.objectOf(Validators.string), [
					'myObjectOfInts' => false,
					'myObjectOfStrings' => true,
					'myMixedObject' => false,
					'myObject' => true,
					'myArrayOfInts' => false,
					'myArrayOfStrings' => false,
					'myInstance' => false,
					'myInt' => false,
					'myString' => false,
					'myTrueValue' => false
				]);
			});
			it("should have a function that validates the `arrayOf` type", {
				testValidator(Validators.arrayOf(Validators.integer), [
					'myArrayOfInts' => true,
					'myArrayOfStrings' => false,
					'myMixedArray' => false,
					'myObject' => false,
					'myObjectOfInts' => false,
					'myInt' => false,
					'myString' => false,
					'myTrueValue' => false
				]);
				testValidator(Validators.arrayOf(Validators.string), [
					'myArrayOfInts' => false,
					'myArrayOfStrings' => true,
					'myMixedArray' => false,
					'myObject' => false,
					'myObjectOfStrings' => false,
					'myInt' => false,
					'myString' => false,
					'myTrueValue' => false
				]);
			});
			it("should have a function that validates the `shape` type", {
				testValidator(Validators.shape({
					name: Validators.required(Validators.string)
				}), [
					'myObject' => true,
					'myObjectOfStrings' => false,
					'myArrayOfInts' => false,
					'myInstance' => false,
					'myString' => false,
					'myInt' => false,
					'myTrueValue' => false
				]);
				testValidator(Validators.shape({
					a: Validators.required(Validators.integer),
					b: Validators.required(Validators.string)
				}), [
					'myObject' => false,
					'myObjectOfStrings' => false,
					'myMixedObject' => true
				]);
				// Extraneous fields should be okay
				testValidator(Validators.shape({
					b: Validators.required(Validators.string)
				}), [
					'myObject' => false,
					'myObjectOfStrings' => true,
					'myMixedObject' => true
				]);
			});

			it("should have a function that makes any other type required", {
				testValidator(Validators.string, [
					'myNullValue' => true,
					'nonExistantString' => true,
					'myEmptyString' => true,
					'myString' => true
				]);
				testValidator(Validators.required(Validators.string), [
					'myNullValue' => false,
					'nonExistantString' => false,
					'myEmptyString' => true,
					'myString' => true
				]);
			});

		});

		describe("Using a simple string as a PropType", {
			it('Should only accept valid strings for SimplePropTypeName', {
				(function () {
					var pt:SimplePropTypeName = 'Not a valid type';
				}).should.throwAnything();

				(function () {
					var schema:Dynamic = {
						'name': 'Not a valid type'
					};
					var propTypes:PropTypes = schema;
					propTypes.get('name').getDescription();
				}).should.throwAnything();
			});

			it('Should transform it into a description', {
				var simple:SimplePropTypeName = '?string';
				var pt:PropType = simple;
				pt.getDescription().optional.should.be(true);
				pt.getDescription().type.should.be('string');
			});

			it('Should pick up on required properties', {
				var simple:SimplePropTypeName = 'integer';
				var pt:PropType = simple;
				pt.getDescription().optional.should.be(false);
				pt.getDescription().type.should.be('integer');
			});
		});

		describe("using Validators.validate()", {
			it('should validate based on simple prop type names', {
				var schema:PropTypes = {
					name: "string",
					age: "?integer"
				};

				it('should validate a correct object', {
					Validators.validate(schema, {
						name: "Jason",
						age: 29
					}, 'test validate()').should.be(null);
				});

				it('should validate even with missing fields', {
					Validators.validate(schema, {
						name: "Jason"
					}, 'test validate()').should.be(null);
				});

				it('should object if a field is the wrong type', {
					Validators.validate(schema, {
						name: 29,
						age: "Jason"
					}, 'test validate()').length.should.be(2);
				});

				it('should error if required fields are not present', {
					Validators.validate(schema, {}, 'test validate()').length.should.be(2);
				});
			});

			it('should validate based on property descriptions', {
				var schema:PropTypes = {
					names: {
						type: "arrayOf",
						optional: false,
						subType: ("string":SimplePropTypeName)
					},
					ages: {
						type: "objectOf",
						optional: true,
						subType: ("?integer":SimplePropTypeName)
					},
					city: {
						type: "oneOf",
						values: ["Perth", "Melbourne", "Sydney", "San Francisco"]
					},
					favourite: {
						type: "oneOfType",
						subTypes: (["string", "integer"]:Array<SimplePropTypeName>)
					},
					address: ({
						type: "shape",
						shape: {
							number: ("integer":SimplePropTypeName),
							streetName: ("string":SimplePropTypeName),
							streetType: {
								type: "oneOf",
								values: ["St", "Rd", "Ave"]
							}
						}
					}:PropTypeDescription)
				};

				var fullObject = {
					names: ["Jason", "Anna"],
					ages: {
						"Jason": 29,
						"Anna": 27
					},
					city: "Melbourne",
					favourite: 3,
					address: {
						number: 512,
						streetName: "Morley",
						streetType: "St"
					}
				};
				Validators.validate(schema, fullObject, 'test validate()').should.be(null);

				var missingBitsButValid = {
					names: [],
					city: "Perth",
					favourite: "",
					address: {
						number: 512,
						streetName: "Morley",
						streetType: "St"
					}
				};
				Validators.validate(schema, missingBitsButValid, 'test validate()').should.be(null);

				var invalidName = {
					names: "Jason",
					ages: {
						"Jason": 29,
						"Anna": 27
					},
					city: "Melbourne",
					favourite: 3,
					address: {
						number: 512,
						streetName: "Morley",
						streetType: "St"
					}
				};
				Validators.validate(schema, invalidName, 'test validate()').length.should.be(1);

				var wrongAges = {
					names: ["Jason", "Anna"],
					ages: {
						"Jason": 29,
						"Anna": "twenty-seven"
					},
					city: "Melbourne",
					favourite: 3,
					address: {
						number: 512,
						streetName: "Morley",
						streetType: "St"
					}
				};
				Validators.validate(schema, wrongAges, 'test validate()').length.should.be(1);

				var wrongCity = {
					names: ["Jason", "Anna"],
					ages: {
						"Jason": 29,
						"Anna": 27
					},
					city: "Adelaide",
					favourite: 3,
					address: {
						number: 512,
						streetName: "Morley",
						streetType: "St"
					}
				};
				Validators.validate(schema, wrongCity, 'test validate()').length.should.be(1);

				var wrongFavourite = {
					names: ["Jason", "Anna"],
					ages: {
						"Jason": 29,
						"Anna": 27
					},
					city: "Melbourne",
					favourite: 3.14,
					address: {
						number: 512,
						streetName: "Morley",
						streetType: "St"
					}
				};
				Validators.validate(schema, wrongFavourite, 'test validate()').length.should.be(1);

				var addressWrong = {
					names: ["Jason", "Anna"],
					ages: {
						"Jason": 29,
						"Anna": 27
					},
					city: "Melbourne",
					favourite: 3,
					address: {
						streetName: "Morley",
						streetType: []
					}
				};
				Validators.validate(schema, addressWrong, 'test validate()').length.should.be(1);

				var addressWrong2 = {
					names: ["Jason", "Anna"],
					ages: {
						"Jason": 29,
						"Anna": 27
					},
					city: "Melbourne",
					favourite: 3,
					address: {
						number: 512,
						streetName: "Morley",
						streetType: []
					}
				};
				Validators.validate(schema, addressWrong2, 'test validate()').length.should.be(1);

				var fieldMissing = {
					names: ["Jason", "Anna"],
					ages: {
						"Jason": 29,
						"Anna": 27
					},
					city: "Melbourne",
					favourite: 3
				};
				Validators.validate(schema, fieldMissing, 'test validate()').length.should.be(1);
			});
		});
	}
}
