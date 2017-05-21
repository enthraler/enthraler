package enthraler;

/**
The schema of data we expect in a `package.json` "enthraler" property.
**/
typedef EnthralerPackageInfo = {
	/** The relative URL to the JS file that renders this enthraler template. **/
	main:String,
	/** The relative URL to the JSON file that defines the schema for this enthraler template. **/
	schema:String
}
