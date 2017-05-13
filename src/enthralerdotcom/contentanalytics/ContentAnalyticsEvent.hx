package enthralerdotcom.contentanalytics;

import enthralerdotcom.content.Content;
import enthralerdotcom.content.ContentVersion;
import enthralerdotcom.templates.Template;
import enthralerdotcom.templates.TemplateVersion;
import enthralerdotcom.contentanalytics.ContentAnalyticsEventType;
import ufront.ORM;
import sys.db.Types;

class ContentAnalyticsEvent extends Object {
	public var content:BelongsTo<Content>;
	public var contentVersion:BelongsTo<ContentVersion>;
	public var template:BelongsTo<Template>;
	public var templateVersion:BelongsTo<TemplateVersion>;
	public var eventJson:String;
	@:skip public var event:ContentAnalyticsEventType;
}
