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
#if client
import enthralerdotcom.services.client.ErrorNotificationService;
#end

enum ContentEditorAction {
	SaveAnonymousVersion(contentId:Int, authorGuid:String, newContent:String, templateVersionId:Int, draft:Bool);
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
		id:Int,
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
	contentJson:String,
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
			contentJson: this.props.currentVersion.jsonContent,
			contentData: null,
			validationResult: null,
			schema: null
		});
		EnthralerHost.addMessageListeners();
		loadFromUrl(this.props.template.schemaUrl)
			.next(function (schemaJson) {
				var schema = PropTypes.fromObject(Json.parse(schemaJson));
				this.setState({
					contentJson: this.state.contentJson,
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
		var iframeSrc = (props.currentVersion.versionId != null)
			? '/i/${props.content.guid}/embed/${props.currentVersion.versionId}'
			: 'about:blank';
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
			<div className="field is-grouped">
				<div className="control">
					<a className="button is-primary" onClick=${onSave.bind(false)}>Save</a>
				</div>
				<div className="control">
					<a className="button" onClick=${onSave.bind(true)}>Save Draft</a>
				</div>
			</div>
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
	function getUserGuid():UserGuid {
		var guidString = js.Browser.window.localStorage.getItem('enthraler_anonymous_guid');
		if (guidString != null) {
			return new UserGuid(guidString);
		} else {
			var guid = UserGuid.generate();
			js.Browser.window.localStorage.setItem('enthraler_anonymous_guid', guid);
			return guid;
		}
	}

	@:client
	function onSave(draft:Bool) {
		if (state.validationResult != null) {
			ErrorNotificationService.inst.logMessage("We can't save while you have validation errors, please fix them first");
			return;
		}
		var action = SaveAnonymousVersion(props.content.id, getUserGuid(), state.contentJson, props.template.versionId, draft);
		this.trigger(action).handle(function (outcome) switch outcome {
			case Failure(err):
				ErrorNotificationService.inst.logError(err, onSave.bind(draft), 'Try Again');
			case _:
		});
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
			contentJson: newJson,
			contentData: authorData,
			validationResult: validationResult,
			schema: this.state.schema
		});
	}

	@:client
	override function componentDidUpdate(_, _) {
		if (state.validationResult != null) {
			return;
		}
		if (preview.contentWindow.location.origin == null || preview.contentWindow.location.origin == "null") {
			return;
		}
		preview.contentWindow.postMessage(Json.stringify({
			src: '' + js.Browser.window.location,
			context: EnthralerMessages.receiveAuthorData,
			authorData: this.state.contentData
		}), preview.contentWindow.location.origin);
	}
}
