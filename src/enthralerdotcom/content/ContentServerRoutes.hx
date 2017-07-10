package enthralerdotcom.content;

import monsoon.Request;
import monsoon.Response;

/**
A collection of functions used for handling server routes that are not React pages - eg embed frames or JSON data.
**/
class ContentServerRoutes {
	static function getVersion(guid:String, id:Null<Int>):ContentVersion {
		if (id != null) {
			return ContentVersion.manager.get(id);
		}
		var content = Content.manager.select($guid == guid);
		return ContentVersion.manager.select($contentID == content.id && $published != null, {
			orderBy: -published,
			limit: 1
		});
	}

	public static function getDataJson(req:Request<{guid:String, ?id:Int}>, res:Response) {
		var version = getVersion(req.params.guid, req.params.id);
		if (version == null) {
			res.status(404);
			res.send('Content version not found');
			return;
		}
		res.set('content-type', 'application/json');
		res.send(version.jsonContent);
	}

	public static function redirectToEmbedFrame(req:Request<{guid:String, ?id:Int}>, res:Response) {
		var baseUrl = '/jslib/0.1.1';
		var version = getVersion(req.params.guid, req.params.id);
		var contentUrl = '/i/${req.params.guid}/data/${version.id}';
		var templateUrl = version.templateVersion.mainUrl;
		var url = '$baseUrl/frame.html#?template=${templateUrl}&authorData=${contentUrl}';
		res.redirect(302, url);
	}
}
