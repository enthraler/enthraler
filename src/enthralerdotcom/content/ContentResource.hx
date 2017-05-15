package enthralerdotcom.content;

import enthralerdotcom.content.ContentVersion;
import enthralerdotcom.types.*;
import ufront.ORM;
import sys.db.Types;

class ContentResource extends Object {
	/** The original version this resource was included in. **/
	public var contentVersion:BelongsTo<ContentVersion>;

	/** This resource may be re-used in future versions, so track those with a join table. **/
	public var contentVersions:ManyToMany<ContentResource,ContentVersion>;

	public var filePath:FilePath;

	function getUrl(s3BasePath:Url):Url {
		return new Url('${s3BasePath}${contentVersion.content.guid}/${contentVersion.id}/${filePath}');
	}
}
