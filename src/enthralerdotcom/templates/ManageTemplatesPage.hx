package enthralerdotcom.templates;

import smalluniverse.UniversalPage;
import smalluniverse.SUMacro.jsx;
import enthralerdotcom.components.*;
#if client
	import js.html.*;
#end

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

	@:client var repoUrl:String;

	public function new(backendApi:ManageTemplatesBackendApi) {
		super(backendApi);
	}

	override function render() {
		this.head.addScript('/assets/enthralerdotcom.bundle.js');
		this.head.addStylesheet('/assets/styles.css');
		this.head.setTitle('Manage templates!');
		return jsx('<div className="container">
			<HeaderNav></HeaderNav>
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
					<input className="input" placeholder="https://github.com/enthraler/enthraler-hello-amd" type="text" onKeyUp=${repoUrlKeyup} />
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
		var templateRows = this.props.templates.map(function (tpl) {
			var numVersions = tpl.versions.length,
				latestVersion = (numVersions > 0) ? tpl.versions[numVersions-1].version : "";
			return jsx('<tr>
				<th>
					<a href=${'/templates/'+tpl.name}>${tpl.name}</a>
				</th>
				<td>
					<a href="${tpl.homepage}">${tpl.homepage}</a>
				</td>
				<td>
					$latestVersion
				</td>
				<td>
					${""+numVersions}
				</td>
				<td>
					<Button label="Reload" icon="refresh" onClick=${reloadTemplate.bind(${tpl.id})}></Button>
				</td>
			</tr>');
		});
		return jsx('<table className="table">
			<thead>
				<th>Template</th>
				<th>Homepage</th>
				<th>Latest release</th>
				<th># of releases</th>
				<th>Actions</th>
			</thead>
			<tbody>
				${templateRows}
			</tbody>
		</table>');
	}

	@:client
	function reloadTemplate(id:Int) {
		this.trigger(ReloadTemplate(id));
	}

	@:client
	function repoUrlKeyup(e:react.ReactEvent) {
		var target = cast (e.target, InputElement);
		this.repoUrl = target.value;
	}

	@:client
	function addTemplateClick(e:react.ReactEvent) {
		trace(repoUrl);
		var urlRegex = ~/github\.com\/([^\/]+)\/([^\/]+)/i;
		if (urlRegex.match(repoUrl)) {
			var githubUsername = urlRegex.matched(1),
				githubRepo = urlRegex.matched(2);
			this.trigger(AddGithubRepoAsTemplate(githubUsername, githubRepo));
		} else {
			js.Browser.alert('The URL format did not match our regex...');
		}
	}
}
