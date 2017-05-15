package db.migrations;

import ufront.ORM;

class M20170514172105_Initial_Schema_Setup extends Migration {
	public function new() {
		super([
			CreateTable({
				tableName: "Content",
				fields: [
					{name:"id", type:DId, isNullable:false},
					{name:"created", type:DDateTime, isNullable:false},
					{name:"modified", type:DDateTime, isNullable:false},
					{name:"title", type:DString(255), isNullable:false},
					{name:"templateID", type:DInt, isNullable:false},
					{name:"guid", type:DString(36), isNullable:false},
					{name:"copiedFromID", type:DInt, isNullable:true},
				],
				indicies: [
					{fields:["guid"], unique:true},
					{fields:["templateID"], unique:false},
					{fields:["copiedFromID"], unique:false},
				],
				foreignKeys: [
					{fields: ["copiedFromID"], relatedTableName:"Content", relatedTableFields:["id"], onUpdate:Cascade, onDelete:SetNull},
					{fields: ["templateID"], relatedTableName:"Template", relatedTableFields:["id"], onUpdate:Cascade, onDelete:Restrict},
				],
			}),
			CreateTable({
				tableName: "ContentVersion",
				fields: [
					{name:"id", type:DId, isNullable:false},
					{name:"created", type:DDateTime, isNullable:false},
					{name:"modified", type:DDateTime, isNullable:false},
					{name:"contentID", type:DInt, isNullable:false},
					{name:"templateVersionID", type:DInt, isNullable:false},
					{name:"jsonContent", type:DText, isNullable:false},
					{name:"publishDate", type:DDateTime, isNullable:true},
				],
				indicies: [
					{fields:["contentID", "date"], unique:false},
				],
				foreignKeys: [
					{fields: ["contentID"], relatedTableName:"Content", relatedTableFields:["id"], onUpdate:Cascade, onDelete:Cascade},
					{fields: ["templateVersionID"], relatedTableName:"TemplateVersion", relatedTableFields:["id"], onUpdate:Cascade, onDelete:Restrict},
				],
			}),
			CreateTable({
				tableName: "ContentResource",
				fields: [
					{name:"id", type:DId, isNullable:false},
					{name:"created", type:DDateTime, isNullable:false},
					{name:"modified", type:DDateTime, isNullable:false},
					{name:"contentVersionID", type:DInt, isNullable:false},
					{name:"filePath", type:DString(255), isNullable:false},
				],
				indicies: [],
				foreignKeys: [
					{fields: ["contentVersionID"], relatedTableName:"ContentVersion", relatedTableFields:["id"], onUpdate:Cascade, onDelete:Restrict}
				],
			}),
			CreateJoinTable("enthralerdotcom.content.ContentVersion", "enthralerdotcom.content.ContentResource"),
			CreateTable({
				tableName: "Template",
				fields: [
					{name:"id", type:DId, isNullable:false},
					{name:"created", type:DDateTime, isNullable:false},
					{name:"modified", type:DDateTime, isNullable:false},
					{name:"name", type:DString(255), isNullable:false},
					{name:"description", type:DText, isNullable:false},
					{name:"gitRepo", type:DString(255), isNullable:false},
					{name:"homepage", type:DString(255), isNullable:false},
				],
				indicies: [
					{fields:["name"], unique:false}
				],
				foreignKeys: [],
			}),
			CreateTable({
				tableName: "TemplateVersion",
				fields: [
					{name:"id", type:DId, isNullable:false},
					{name:"created", type:DDateTime, isNullable:false},
					{name:"modified", type:DDateTime, isNullable:false},
					{name:"templateID", type:DInt, isNullable:false},
					{name:"major", type:DInt, isNullable:false},
					{name:"minor", type:DInt, isNullable:false},
					{name:"patch", type:DInt, isNullable:false},
					{name:"commitHash", type:DString(255), isNullable:false},
					{name:"basePath", type:DString(255), isNullable:false},
				],
				indicies: [
					{fields:["templateID", "major", "minor", "patch", "unique"], unique:true},
				],
				foreignKeys: [
					{fields: ["templateID"], relatedTableName:"Template", relatedTableFields:["id"], onUpdate:Cascade, onDelete:Cascade},
				],
			}),
			CreateTable({
				tableName: "ContentAnalyticsEvent",
				fields: [
					{name:"id", type:DId, isNullable:false},
					{name:"created", type:DDateTime, isNullable:false},
					{name:"modified", type:DDateTime, isNullable:false},
					{name:"contentID", type:DInt, isNullable:false},
					{name:"contentVersionID", type:DInt, isNullable:false},
					{name:"templateID", type:DInt, isNullable:false},
					{name:"templateVersionID", type:DInt, isNullable:false},
					{name:"eventJson", type:DText, isNullable:false},
				],
				indicies: [
					{fields:["templateID", "major", "minor", "patch", "unique"], unique:true},
				],
				foreignKeys: [
					{fields: ["templateID"], relatedTableName:"Template", relatedTableFields:["id"], onUpdate:Cascade, onDelete:Cascade},
				],
			}),
		]);
	}
}
