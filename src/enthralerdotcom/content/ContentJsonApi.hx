package enthralerdotcom.content;

import monsoon.Request;
import monsoon.Response;

class ContentJsonApi {
	public static function getDataJson(req:Request<{guid:String, ?id:Int}>, res:Response) {
		var version;
		if (req.params.id == null) {
			var content = Content.manager.select($guid == req.params.guid);
			version = ContentVersion.manager.select($contentID == content.id && $published != null, {
				orderBy: -published,
				limit: 1
			});
		} else {
			version = ContentVersion.manager.get(req.params.id);
		}
		if (version == null) {
			res.status(404);
			res.send('Content version not found');
			return;
		}
		res.set('content-type', 'application/json');
		res.send(version.jsonContent);
	}
}
