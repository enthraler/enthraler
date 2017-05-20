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
				foreignKeys: [],
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
					{name:"published", type:DDateTime, isNullable:true},
				],
				indicies: [
					{fields:["contentID", "published"], unique:false},
				],
				foreignKeys: [],
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
				foreignKeys: [],
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
					{name:"source", type:DData, isNullable:false},
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
					{name:"basePath", type:DString(255), isNullable:false},
				],
				indicies: [
					{fields:["templateID", "major", "minor", "patch"], unique:true},
				],
				foreignKeys: [],
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
				indicies: [],
				foreignKeys: [],
			}),
			AddForeignKey("Content", {fields: ["copiedFromID"], relatedTableName:"Content", relatedTableFields:["id"], onUpdate:Cascade, onDelete:SetNull}),
			AddForeignKey("Content", {fields: ["templateID"], relatedTableName:"Template", relatedTableFields:["id"], onUpdate:Cascade, onDelete:Restrict}),
			AddForeignKey("ContentVersion", {fields: ["contentID"], relatedTableName:"Content", relatedTableFields:["id"], onUpdate:Cascade, onDelete:Cascade}),
			AddForeignKey("ContentVersion", {fields: ["templateVersionID"], relatedTableName:"TemplateVersion", relatedTableFields:["id"], onUpdate:Cascade, onDelete:Restrict}),
			AddForeignKey("ContentResource", {fields: ["contentVersionID"], relatedTableName:"ContentVersion", relatedTableFields:["id"], onUpdate:Cascade, onDelete:Restrict}),
			AddForeignKey("TemplateVersion", {fields: ["templateID"], relatedTableName:"Template", relatedTableFields:["id"], onUpdate:Cascade, onDelete:Cascade}),
			AddForeignKey("ContentAnalyticsEvent", {fields: ["templateID"], relatedTableName:"Template", relatedTableFields:["id"], onUpdate:Cascade, onDelete:Cascade}),
		]);
	}
}
