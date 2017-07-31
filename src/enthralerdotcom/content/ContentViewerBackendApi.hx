package enthralerdotcom.content;

import smalluniverse.BackendApi;
import smalluniverse.BackendApi.Request;
import enthralerdotcom.content.ContentViewerPage;
using tink.CoreApi;
import enthralerdotcom.content.Content;

class ContentViewerBackendApi implements BackendApi<ContentViewerAction, ContentViewerParams, ContentViewerProps> {
	public function new() {
	}

	public function get(req:Request<ContentViewerParams>):Promise<ContentViewerProps> {
		var params = req.params;
		var content = Content.manager.select($guid == params.guid);
		var latestVersion = ContentVersion.manager.select($contentID == content.id && $published != null, {orderBy: -published});
		if (latestVersion == null) {
			throw new Error(404, 'Content not found');
		}
		var templateVersion = latestVersion.templateVersion;
		var template = templateVersion.template;
		var embedUrl = 'https://enthraler.com/i/${params.guid}/embed';
		var embedCode = '<iframe src="${embedUrl}" className="enthraler-embed" frameBorder="0"></iframe>';
		var props:ContentViewerProps = {
			contentVersionId: latestVersion.id,
			templateName: template.name,
			templateUrl: templateVersion.mainUrl,
			contentUrl: '/i/${content.guid}/data/${latestVersion.id}',
			title: content.title,
			published: latestVersion.published,
			guid: content.guid,
			embedCode: embedCode
		};
		return props;
	}

	public function processAction(req:Request<ContentViewerParams>, action:ContentViewerAction):Promise<BackendApiResult> {
		var params = req.params;
		switch action {
			case _:
				return Done;
		}
	}
}
