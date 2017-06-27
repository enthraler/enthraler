package enthralerdotcom.content;

import smalluniverse.UniversalPage;
import smalluniverse.SUMacro.jsx;
import enthralerdotcom.components.*;
using tink.CoreApi;

enum ContentEditorAction {
	None;
}

typedef ContentEditorParams = {
	guid:String
};

typedef ContentEditorProps = {
	template:{
		name:String,
		version:String,
		mainUrl:String
	},
	content:{
		title:String,
		guid:String,
	},
	currentVersion:{
		versionId:Null<Int>,
		jsonContent:String,
		published:Null<Date>
	}
};

class ContentEditorPage extends UniversalPage<ContentEditorAction, ContentEditorParams, ContentEditorProps, {}, {}> {

	@:client var githubUsername:String;
	@:client var githubRepo:String;

	public function new(api:ContentEditorBackendApi) {
		super(api);
	}

	override function render() {
		this.head.addScript('/assets/enthralerdotcom.bundle.js');
		this.head.addStylesheet('/assets/styles.css');
		this.head.setTitle('Content Editor');
		var baseUrl = 'http://localhost:2000'; // TODO: use rawgit or static asset
		var iframeSrc = '$baseUrl/frame.html#?template=${props.template.mainUrl}&authorData=bin/data/hello-jason.json';
		var iframeStyle = {
			display: 'block',
			width: '960px',
			maxWidth: '100%',
			height: '350px'
		};
		return jsx('<div className="container">
			<HeaderNav></HeaderNav>
			<h1 className="title">${props.content.title}</h1>
			<h2 className="subtitle">Using template <a href=${"/templates/"+props.template.name}><em>${props.template.name}</em></a></h2>
			<div className="columns">
				<div className="column">
					<CodeMirrorEditor content=${props.currentVersion.jsonContent}></CodeMirrorEditor>
				</div>
				<div className="column">
					<ul className="hidden"></ul>
					<iframe src=${iframeSrc} id="preview" className="enthraler-embed" sandbox="allow-same-origin allow-scripts allow-forms" frameBorder="0" style=${iframeStyle}></iframe>
				</div>
			</div>
		</div>');
	}
}
