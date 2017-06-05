package enthralerdotcom.templates;

import tink.Json;
import enthralerdotcom.templates.ViewTemplatePage;
using tink.CoreApi;
import enthralerdotcom.types.*;
import enthraler.EnthralerPackageInfo;

class ViewTemplateBackendApi implements smalluniverse.BackendApi<ViewTemplateAction, ViewTemplateParams, ViewTemplateProps> {
	public function new() {

	}

	public function get(params):Promise<ViewTemplateProps> {
		return {};
	}

	public function processAction(params:ViewTemplateParams, action:ViewTemplateAction):Promise<Noise> {
		return Noise;
	}
}
