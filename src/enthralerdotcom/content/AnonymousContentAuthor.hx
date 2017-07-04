package enthralerdotcom.content;

import enthralerdotcom.types.*;
import ufront.ORM;

/**
When an unauthenticated user creates an enthraler, we only allow them to edit it while the tab is open.
We use a unique GUID, their email address, and a timestamp to authenticate that the same user who created it is the one updating it.
**/
@:index(contentID, unique)
@:index(contentID, guid)
@:index(guid)
class AnonymousContentAuthor extends Object {
	public var content:BelongsTo<Content>;
	public var guid:UserGuid;
	public var ipAddress:IpAddress;

	public function new() {
		super();
		this.guid = UserGuid.generate();
	}
}
