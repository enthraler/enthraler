package enthralerdotcom.content;

import enthralerdotcom.content.ContentVersion;
import enthralerdotcom.types.*;
import ufront.ORM;
import sys.db.Types;

class ContentResource extends Object {
	public var contentVersion:BelongsTo<ContentVersion>;
	public var filePath:FilePath;
	public var url:Url; // On S3
}
