package enthralerdotcom.content;

import enthralerdotcom.templates.Template;
import enthralerdotcom.templates.TemplateVersion;
import enthralerdotcom.contentanalytics.ContentAnalyticsEvent;
import enthralerdotcom.types.*;
import ufront.ORM;
import sys.db.Types;

@:index(guid, unique)
@:index(title)
@:index(templateID)
@:index(copiedFromID)
class Content extends Object {
	public var title:SString<255>;
	public var template:BelongsTo<Template>;
	public var guid:ContentGuid;
	public var copiedFrom:Null<BelongsTo<Content>>;
	public var versions:HasMany<ContentVersion>;
	public var analytics:HasMany<ContentAnalyticsEvent>;
}
