package enthralerdotcom.content;

import smalluniverse.UniversalPage;
import smalluniverse.SUMacro.jsx;
import enthralerdotcom.components.*;
using tink.CoreApi;
import enthraler.proptypes.Validators;
import haxe.Json;

enum ContentEditorAction {
	None;
}

typedef ContentEditorParams = {
	guid:String
}

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
}

typedef ContentEditorState = {
	jsonContent:String,
	validationResult:Null<Array<ValidationError>>
}

class ContentEditorPage extends UniversalPage<ContentEditorAction, ContentEditorParams, ContentEditorProps, ContentEditorState, {}> {

	public function new(api:ContentEditorBackendApi) {
		super(api);
	}

	override public function componentWillMount() {
		this.setState({
			jsonContent: this.props.currentVersion.jsonContent,
			validationResult: (this.state!=null) ? this.state.validationResult : null
		});
	}

	override function render() {
		this.head.addScript('/assets/enthralerdotcom.bundle.js');
		this.head.addStylesheet('/assets/styles.css');
		this.head.setTitle('Content Editor');
		var baseUrl = '/jslib/0.1.1';
		var contentUrl = '/i/${props.content.guid}/data/${props.currentVersion.versionId}';
		var iframeSrc = '$baseUrl/frame.html#?template=${props.template.mainUrl}&authorData=${contentUrl}';
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
					<CodeMirrorEditor content=${this.props.currentVersion.jsonContent} onChange=${onEditorChange}></CodeMirrorEditor>
				</div>
				<div className="column">
					<ul className="hidden"></ul>
					<iframe src=${iframeSrc} id="preview" className="enthraler-embed" sandbox="allow-same-origin allow-scripts allow-forms" frameBorder="0" style=${iframeStyle}></iframe>
				</div>
			</div>
		</div>');
	}

	@:client
	function onEditorChange(newJson:String) {
		var validationResult,
			authorData = null;

		try {
			authorData = Json.parse(newJson);
			// if (schema != null) {
			// 	validationResult = Validators.validate(schema, authorData, 'live JSON editor');
			// }
			validationResult = null;
			trace('new content:', authorData);
		} catch (e:Dynamic) {
			validationResult = [new ValidationError('JSON syntax error: ' + e, AccessProperty('document'))];
		}
		this.setState({
			jsonContent: newJson,
			validationResult: validationResult
		});
	}

	override function componentDidUpdate(_, _) {
		if (this.state.validationResult == null) {
			trace('update the preview');
		} else {
			function addError(ve:ValidationError) {
				trace(ve.getErrorPath(), ve.message);
				for (childError in ve.childErrors) {
					addError(childError);
				}
			}1
			// Show a validation error
			for (e in this.state.validationResult) {
				addError(e);
			}
		}
	}
}
