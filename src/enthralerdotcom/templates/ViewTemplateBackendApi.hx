package enthralerdotcom.templates;

import smalluniverse.BackendApi;
import enthralerdotcom.templates.ViewTemplatePage;
using tink.CoreApi;
#if server
import enthralerdotcom.content.Content;
using ObjectInit;
#end

class ViewTemplateBackendApi implements BackendApi<ViewTemplateAction, ViewTemplateParams, ViewTemplateProps> {
	public function new() {

	}

	function getTemplateName(params:ViewTemplateParams) {
		return '${params.user}/${params.repo}';
	}

	function getTemplate(params:ViewTemplateParams) {
		var name = getTemplateName(params);
		return Template.manager.select($name == name);
	}

	public function get(params:ViewTemplateParams):Promise<ViewTemplateProps> {
		var tpl = getTemplate(params);
		var versions = TemplateVersion.manager.search($templateID==tpl.id, {
			orderBy: [-major, -minor, -patch]
		});
		var latestVersion = versions.first();
		var props:ViewTemplateProps = {
			template: {
				name: tpl.name,
				description: tpl.description,
				homepage: tpl.homepage,
				readme: Markdown.markdownToHtml(latestVersion.readme),
				versions: [for (v in versions) {
					version: v.getSemver(),
					mainUrl: v.mainUrl
				}]
			}
		};
		return props;
	}

	public function processAction(params:ViewTemplateParams, action:ViewTemplateAction):Promise<BackendApiResult> {
		switch action {
			case CreateNewContent:
				var tpl = getTemplate(params);
				var version = TemplateVersion.manager.select($templateID==tpl.id, {
					orderBy: [-major, -minor, -patch]
				});
				var content = new Content().init({
					title: 'My new enthraler',
					template: tpl,
				});
				content.save();
				trace('Creating content ${content.id}, ${content.guid}');
				return Redirect('/content/${content.guid}/');
		}
	}
}
