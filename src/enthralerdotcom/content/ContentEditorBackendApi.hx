package enthralerdotcom.content;

import smalluniverse.BackendApi;
import smalluniverse.BackendApi.Request;
import enthralerdotcom.content.ContentEditorPage;
using tink.CoreApi;
#if server
import enthralerdotcom.types.*;
import enthralerdotcom.content.Content;
import enthralerdotcom.templates.TemplateVersion;
using ObjectInit;
#end

class ContentEditorBackendApi implements BackendApi<ContentEditorAction, ContentEditorParams, ContentEditorProps> {
	public function new() {

	}

	public function get(req:Request<ContentEditorParams>):Promise<ContentEditorProps> {
		var params = req.params;
		var content = Content.manager.select($guid == params.guid);
		var template = content.template;
		var latestVersion = content.versions.last();
		if (latestVersion == null) {
			// If it is new content, with no version saved yet, create a new version.
			latestVersion = new ContentVersion().objectInit({
				content: content,
				jsonContent: "{}",
				templateVersion: TemplateVersion.manager.select($templateID == template.id, {
					orderBy: [-major, -minor, -patch]
				})
			});
		}
		var templateVersion = latestVersion.templateVersion;
		var props:ContentEditorProps = {
			template:{
				name: template.name,
				version: templateVersion.getSemver(),
				versionId: templateVersion.id,
				mainUrl: templateVersion.mainUrl,
				schemaUrl: templateVersion.schemaUrl
			},
			content:{
				id: content.id,
				title: content.title,
				guid: content.guid,
			},
			currentVersion:{
				versionId: latestVersion.id,
				jsonContent: latestVersion.jsonContent,
				published: latestVersion.published
			}
		};
		return props;
	}

	public function processAction(req:Request<ContentEditorParams>, action:ContentEditorAction):Promise<BackendApiResult> {
		switch action {
			case SaveAnonymousVersion(contentId, authorGuid, newContent, templateVersionId, draft):
				var ipAddress = new IpAddress(req.clientIp);
				return saveAnonymousContentVersion(contentId, new UserGuid(authorGuid), ipAddress, newContent, templateVersionId, draft);
		}
	}

	public function saveAnonymousContentVersion(contentId:Int, authorGuid:UserGuid, authorIp:IpAddress, newContent:String, templateVersionId:Int, draft:Bool):Promise<BackendApiResult> {
		var contentVersion = ContentVersion.manager.select($contentID == contentId, {orderBy: -created});
		var author = AnonymousContentAuthor.manager.select(
			$contentID == contentId
			&& $guid == authorGuid
			&& $ipAddress == authorIp
			&& $modified > DateTools.delta(Date.now(), -24*60*60*1000)
		);
		if (contentVersion != null && author == null) {
			// This content already exists but is from a different author.  We should block this request.
			return Failure(new Error(tink.core.Error.ErrorCode.Forbidden, 'This content is no longer editable'));
		}

		if (contentVersion == null) {
			// This is the first entry - save the author so we can keep track of them going forward.
			author = new AnonymousContentAuthor().objectInit({
				contentID: contentId,
				guid: authorGuid,
				ipAddress: authorIp
			});
		}
		// Save the author - this will touch the "modified" field and give the user another 24 hours to keep editing.
		author.save();

		if (contentVersion == null || contentVersion.published != null) {
			// Either there was no previous version, or the previous version was already published - so save a new one.
			contentVersion = new ContentVersion();
		}

		contentVersion.objectInit({
			contentID: contentId,
			templateVersionID: templateVersionId,
			jsonContent: newContent,
			published: (draft) ? null : Date.now()
		});
		contentVersion.save();
		return Done;
	}
}
