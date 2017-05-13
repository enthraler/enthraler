package enthralerdotcom.content;

import enthralerdotcom.templates.Template;
import enthralerdotcom.templates.TemplateVersion;
import enthralerdotcom.contentanalytics.ContentAnalyticsEvent;
import enthralerdotcom.types.*;
import ufront.ORM;
import sys.db.Types;

class Content extends Object {
	public var template:BelongsTo<Template>;
	public var guid:ContentGuid;
	public var jsonContent:SText;
	public var analytics:HasMany<ContentAnalyticsEvent>;
	public var currentVersion:BelongsTo<ContentVersion>;
	public var versions:HasMany<ContentVersion>;
	public var copiedFrom:Null<BelongsTo<Content>>;
}
