package db.migrations;

import ufront.ORM;

class M20170704175324_Add_Anonymous_Author extends Migration {
	public function new() {
		super([
			CreateTable({
				tableName: "AnonymousContentAuthor",
				fields: [
					{name:"id", type:DId, isNullable:false},
					{name:"created", type:DDateTime, isNullable:false},
					{name:"modified", type:DDateTime, isNullable:false},
					{name:"contentID", type:DInt, isNullable:false},
					{name:"guid", type:DString(36), isNullable:false},
					{name:"ipAddress", type:DString(39), isNullable:false},
				],
				indicies: [
					{fields:["contentID"], unique:true},
					{fields:["contentID", "guid"], unique:false},
					{fields:["guid"], unique:false},
				],
				foreignKeys: [],
			}),
			AddForeignKey("AnonymousContentAuthor", {fields: ["contentID"], relatedTableName:"Content", relatedTableFields:["id"], onUpdate:Cascade, onDelete:Cascade}),
		]);
	}
}
