package db.migrations;

import ufront.ORM;

class M20170624095943_Make_Template_Name_Unique extends Migration {
	public function new() {
		super([
			// Remove existing index, and replace it with a unique one.
			RemoveIndex("Template", {fields:["name"], unique:false}),
			AddIndex("Template", {fields:["name"], unique:true}),
		]);
	}
}
