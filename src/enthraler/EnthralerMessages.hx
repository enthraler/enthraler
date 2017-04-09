package enthraler;

@:enum
abstract EnthralerMessages(String) from String to String {
	inline var requestHeightChange = "iframe.resize";
	inline var broadbastSchemaUrl = "enthraler.broadcast.schemaUrl";
	inline var receiveAuthorData = "enthraler.receive.authordata";
}
