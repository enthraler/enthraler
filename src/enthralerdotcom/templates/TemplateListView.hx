package enthralerdotcom.templates;

import smalluniverse.UniversalComponent;
import smalluniverse.SUMacro.jsx;

typedef TemplateList = Array<{
	name:String,
	homepage:String,
	versions:Array<{
		mainUrl:String,
		version:String
	}>,
}>

class TemplateListView extends UniversalComponent<{templates:TemplateList}, {}, {}> {
	override function render() {
		var templateLIs = this.props.templates.map(function (tpl) {
			var versionLIs = [for (version in tpl.versions) jsx('<li>
				<p><a href=${version.mainUrl}>${version.version}</a></p>
			</li>')];
			return jsx('<li>
				<p><a href="${tpl.homepage}">${tpl.name}</a></p>
				<ul>
					$versionLIs
				</ul>
			</li>');
		});
		return jsx('<div className="menu">
			<ul className="menu-list">
				$templateLIs
			</ul>
		</div>');
	}
}
