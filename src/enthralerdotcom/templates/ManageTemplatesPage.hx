package enthralerdotcom.templates;

import smalluniverse.UniversalPage;
import smalluniverse.SUMacro.jsx;
#if client
	import js.html.*;
#end
import enthralerdotcom.templates.TemplateListView;
using tink.CoreApi;

typedef ManageTemplatesPageProps = {
	templates:TemplateList
}

enum ManageTemplatesAction {
	AddGithubRepoAsTemplate(githubUser:String, githubRepo:String);
}

class ManageTemplatesPage extends UniversalPage<ManageTemplatesAction, {}, ManageTemplatesPageProps, {}, {}> {

	@:client var githubUsername:String;
	@:client var githubRepo:String;

	public function new(backendApi:ManageTemplatesBackendApi) {
		super(backendApi);
	}

	override function render() {
		this.head.addScript('enthralerdotcom.bundle.js');
		this.head.addStylesheet('https://cdnjs.cloudflare.com/ajax/libs/bulma/0.4.1/css/bulma.min.css');
		this.head.setTitle('Manage templates!');
		return jsx('<div>
			<h1 className="title">Manage Templates</h1>
			<h2 className="subtitle">Add a template from Github</h2>
			<div className="field is-grouped">
				<div className="control">
					<span className="select">
						<select>
							<option>Github</option>
						</select>
					</span>
				</div>
				<div className="control">
					<input className="input" placeholder="Github Username" type="text" onKeyUp={userNameKeyUp} />
				</div>
				<div className="control">
					<input className="input" placeholder="Github Repo Name" type="text" onKeyUp={repoNameKeyUp} />
				</div>
				<div className="control">
					<a className="button is-primary" onClick={addTemplateClick}>Add Template</a>
				</div>
			</div>
			<h2 className="subtitle">Existing Templates</h2>
			<TemplateListView templates={this.props.templates} />
			<a href="/">Link to home</a>
		</div>');
	}

	@:client
	function repoNameKeyUp(e:react.ReactEvent) {
		var target = cast (e.target, InputElement);
		this.githubRepo = target.value;
	}

	@:client
	function userNameKeyUp(e:react.ReactEvent) {
		var target = cast (e.target, InputElement);
		this.githubUsername = target.value;
	}

	@:client
	function addTemplateClick(e:react.ReactEvent) {
		this.trigger(AddGithubRepoAsTemplate(githubUsername, githubRepo));
	}
}
