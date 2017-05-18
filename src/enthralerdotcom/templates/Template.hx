package enthralerdotcom.templates;

import enthralerdotcom.templates.TemplateVersion;
import enthralerdotcom.contentanalytics.ContentAnalyticsEvent;
import enthralerdotcom.types.*;
import ufront.ORM;
import sys.db.Types;

@:index(name)
class Template extends Object {
	public var name:SString<255>;
	public var description:SText;
	public var homepage:Url;
	public var versions:HasMany<TemplateVersion>;
	public var analytics:HasMany<ContentAnalyticsEvent>;
}
