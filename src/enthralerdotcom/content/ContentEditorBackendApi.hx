package enthralerdotcom.content;

import smalluniverse.BackendApi;
import enthralerdotcom.content.ContentEditorPage;
using tink.CoreApi;
#if server
import enthralerdotcom.content.Content;
import enthralerdotcom.templates.Template;
import enthralerdotcom.templates.TemplateVersion;
using ObjectInit;
#end

class ContentEditorBackendApi implements BackendApi<ContentEditorAction, ContentEditorParams, ContentEditorProps> {
	public function new() {

	}

	public function get(params:ContentEditorParams):Promise<ContentEditorProps> {
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
				mainUrl: templateVersion.mainUrl,
				schemaUrl: templateVersion.schemaUrl
			},
			content:{
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

	public function processAction(params:ContentEditorParams, action:ContentEditorAction):Promise<BackendApiResult> {
		switch action {
			case _:
				return Done;
		}
	}
}
