package enthralerdotcom.templates;

import enthralerdotcom.templates.ViewTemplatePage;
using tink.CoreApi;

class ViewTemplateBackendApi implements smalluniverse.BackendApi<ViewTemplateAction, ViewTemplateParams, ViewTemplateProps> {
	public function new() {

	}

	public function get(params:ViewTemplateParams):Promise<ViewTemplateProps> {
		var name = '${params.user}/${params.repo}';
		var tpl = Template.manager.select($name == name);
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

	public function processAction(params:ViewTemplateParams, action:ViewTemplateAction):Promise<Noise> {
		return Noise;
	}
}
