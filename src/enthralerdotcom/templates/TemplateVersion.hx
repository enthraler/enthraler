package enthralerdotcom.templates;

import enthralerdotcom.templates.Template;
import enthralerdotcom.contentanalytics.ContentAnalyticsEvent;
import enthralerdotcom.types.*;
import ufront.ORM;
import sys.db.Types;

@:index(templateID, major, minor, patch, unique)
class TemplateVersion extends Object {
	public var template:BelongsTo<Template>;
	public var major:STinyInt;
	public var minor:STinyInt;
	public var patch:STinyInt;

	@:validate(StringTools.endsWith(_, "/"))
	public var basePath:Url; // Rawgit URL.

	public var mainUrl:Url;
	public var schemaUrl:Url;
	public var readme:Null<SText>;

	public var analytics:HasMany<ContentAnalyticsEvent>;

	public function getSemver():SemVer {
		return new SemVer('$major.$minor.$patch');
	}
}
