package enthralerdotcom.templates;

import smalluniverse.UniversalPage;
import smalluniverse.SUMacro.jsx;
import enthralerdotcom.components.Button;
#if client
	import js.html.*;
#end
using tink.CoreApi;

typedef ManageTemplatesPageProps = {
	templates:TemplateList
}

typedef TemplateList = Array<{
	id:Int,
	name:String,
	homepage:String,
	versions:Array<{
		mainUrl:String,
		version:String
	}>,
}>

enum ManageTemplatesAction {
	AddGithubRepoAsTemplate(githubUser:String, githubRepo:String);
	ReloadTemplate(id:Int);
}

class ManageTemplatesPage extends UniversalPage<ManageTemplatesAction, {}, ManageTemplatesPageProps, {}, {}> {

	@:client var githubUsername:String;
	@:client var githubRepo:String;

	public function new(backendApi:ManageTemplatesBackendApi) {
		super(backendApi);
	}

	override function render() {
		this.head.addScript('/assets/enthralerdotcom.bundle.js');
		this.head.addStylesheet('/assets/styles.css');
		this.head.setTitle('Manage templates!');
		return jsx('<div className="container">
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
					<input className="input" placeholder="Github Username" type="text" onKeyUp=${userNameKeyUp} />
				</div>
				<div className="control">
					<input className="input" placeholder="Github Repo Name" type="text" onKeyUp=${repoNameKeyUp} />
				</div>
				<div className="control">
					<a className="button is-primary" onClick=${addTemplateClick}>Add Template</a>
				</div>
			</div>
			<h2 className="subtitle">Existing Templates</h2>
			${renderTempmlateList()}
			<a href="/">Link to home</a>
		</div>');
	}

	function renderTempmlateList() {
		var templateLIs = this.props.templates.map(function (tpl) {
			var versionLIs = [for (version in tpl.versions) jsx('<li>
				<p><a href=${version.mainUrl}>${version.version}</a></p>
			</li>')];
			return jsx('<article className="tile is-child">
				<div>
					<h3><a href="${tpl.homepage}">${tpl.name}</a></h3>
					<div className="field">
						<Button label="Reload" icon="refresh" onClick=${reloadTemplate.bind(${tpl.id})}></Button>
					</div>
				</div>
				<ul>
					$versionLIs
				</ul>
			</article>');
		});
		return jsx('<div className="tile is-ancestor">
			<div className="tile is-parent">
				$templateLIs
			</div>
		</div>');
	}

	@:client
	function reloadTemplate(id:Int) {
		this.trigger(ReloadTemplate(id));
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
