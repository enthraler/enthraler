package enthralerdotcom.content;

import smalluniverse.UniversalPage;
import smalluniverse.SUMacro.jsx;
import enthralerdotcom.components.*;
import enthralerdotcom.types.*;
using tink.CoreApi;
import enthraler.proptypes.Validators;
import enthraler.proptypes.PropTypes;
import enthraler.EnthralerMessages;
import haxe.Json;
import haxe.Http;

enum ContentEditorAction {
	SaveAnonymousVersion(contentId:Int, authorGuid:String, authorIp:String, newContent:String, templateVersionId:Int, draft:Bool);
}

typedef ContentEditorParams = {
	guid:String
}

typedef ContentEditorProps = {
	template:{
		name:String,
		versionId:Int,
		version:String,
		mainUrl:String,
		schemaUrl:String
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
	contentData:Any,
	validationResult:Null<Array<ValidationError>>,
	schema:PropTypes
}

class ContentEditorPage extends UniversalPage<ContentEditorAction, ContentEditorParams, ContentEditorProps, ContentEditorState, {}> {

	@:client var preview:js.html.IFrameElement;
	@:client function setIframe(iframe) this.preview = iframe;

	public function new(api:ContentEditorBackendApi) {
		super(api);
	}

	static function loadFromUrl(url:String):Promise<String> {
		return Future.async(function (handler:Outcome<String,Error>->Void) {
			var h = new haxe.Http(url);
			var status = null;
			h.onStatus = function (s) status = s;
			h.onData = function (result) handler(Success(result));
			h.onError = function (errMessage) handler(Failure(new Error(status, errMessage)));
			h.request(false);
		});
	}

	@:client
	override public function componentDidMount() {
		this.setState({
			contentData: this.props.currentVersion.jsonContent,
			validationResult: null,
			schema: null
		});
		EnthralerHost.addMessageListeners();
		loadFromUrl(this.props.template.schemaUrl)
			.next(function (schemaJson) {
				var schema = PropTypes.fromObject(Json.parse(schemaJson));
				this.setState({
					contentData: this.state.contentData,
					validationResult: this.state.validationResult,
					schema: schema
				});
				return schema;
			})
			.recover(function (err:Error):PropTypes {
				trace('Failed to load schema from URL', err);
				return null;
			})
			.handle(function () {});
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
					${renderErrorList()}
					<iframe src=${iframeSrc} ref=${setIframe} id="preview" className="enthraler-embed" sandbox="allow-same-origin allow-scripts allow-forms" frameBorder="0" style=${iframeStyle}></iframe>
				</div>
			</div>
		</div>');
	}

	function renderErrorList() {
		if (state == null || state.validationResult == null) {
			return null;
		}

		var errors = [];
		function addError(err:ValidationError) {
			errors.push(jsx('<li>
				<strong>${err.getErrorPath()}</strong>: ${err.message}
			</li>'));
			for (childError in err.childErrors) {
				addError(childError);
			}
		}
		for (err in state.validationResult) {
			addError(err);
		}

		return jsx('<ul>${errors}</ul>');
	}

	@:client
	function onEditorChange(newJson:String) {
		var validationResult,
			authorData = null;

		try {
			authorData = Json.parse(newJson);
			if (this.state.schema != null) {
				validationResult = Validators.validate(this.state.schema, authorData, 'live JSON editor');
			} else {
				validationResult = null;
			}
		} catch (e:Dynamic) {
			validationResult = [new ValidationError('JSON syntax error: ' + e, AccessProperty('document'))];
		}
		this.setState({
			contentData: authorData,
			validationResult: validationResult,
			schema: this.state.schema
		});
	}

	@:client
	override function componentDidUpdate(_, _) {
		preview.contentWindow.postMessage(Json.stringify({
			src: '' + js.Browser.window.location,
			context: EnthralerMessages.receiveAuthorData,
			authorData: this.state.contentData
		}), preview.contentWindow.location.origin);
	}
}
