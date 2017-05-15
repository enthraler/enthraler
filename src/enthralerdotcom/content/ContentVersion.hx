package enthralerdotcom.content;

import enthralerdotcom.templates.Template;
import enthralerdotcom.templates.TemplateVersion;
import enthralerdotcom.contentanalytics.ContentAnalyticsEvent;
import enthralerdotcom.types.*;
import ufront.ORM;
import sys.db.Types;

@:index(contentID, publishDate)
class ContentVersion extends Object {
	public var content:BelongsTo<Content>;
	public var templateVersion:BelongsTo<TemplateVersion>;
	public var jsonContent:SText;
	public var published:Null<SDate>;
	public var analytics:HasMany<ContentAnalyticsEvent>;
	public var resources:ManyToMany<ContentVersion,ContentResource>;
}
