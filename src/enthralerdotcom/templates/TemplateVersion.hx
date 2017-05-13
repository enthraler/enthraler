package enthralerdotcom.templates;

import enthralerdotcom.templates.Template;
import enthralerdotcom.contentanalytics.ContentAnalyticsEvent;
import enthralerdotcom.types.*;
import ufront.ORM;
import sys.db.Types;

class TemplateVersion extends Object {
	public var template:BelongsTo<Template>;
	public var version:SemVer;
	public var major:Int;
	public var minor:Int;
	public var patch:Int;
	public var commitHash:SString<255>;
	public var basePath:Url; // Rawgit URL.
	public var analytics:HasMany<ContentAnalyticsEvent>;
}
