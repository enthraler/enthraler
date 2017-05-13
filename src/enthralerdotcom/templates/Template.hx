package enthralerdotcom.templates;

import enthralerdotcom.templates.TemplateVersion;
import enthralerdotcom.contentanalytics.ContentAnalyticsEvent;
import enthralerdotcom.types.*;
import ufront.ORM;
import sys.db.Types;

class Template extends Object {
	public var gitRepo:GitRepo;
	public var homepage:Url;
	public var versions:HasMany<TemplateVersion>;
	public var analytics:HasMany<ContentAnalyticsEvent>;
}
