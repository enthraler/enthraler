package enthralerdotcom.components;

import smalluniverse.UniversalComponent;
import smalluniverse.SUMacro.jsx;
#if client
	import js.html.*;
	import js.codemirror.*;
#end

typedef CodeMirrorEditorProps = {
	content:String,
}

class CodeMirrorEditor extends UniversalComponent<CodeMirrorEditorProps, {}, {}> {
	@:client var textarea:TextAreaElement;

	override public function render() {
		return jsx('<div>
			<textarea ref=${(function (ta) this.textarea=ta)} defaultValue=${this.props.content}></textarea>
		</div>');
	}

	override function componentDidMount() {
		setupCodeMirror();
	}

	@:client
	function setupCodeMirror() {
		// CodeMirror externs don't haxe a `@:jsRequire()` metadata, so we need to assign this directly for the externs to work.
		js.Lib.global.CodeMirror = Webpack.require('codemirror');
		Webpack.require('codemirror/mode/javascript/javascript.js');
		Webpack.require('codemirror/addon/fold/foldcode.js');
		Webpack.require('codemirror/addon/fold/brace-fold.js');
		Webpack.require('codemirror/addon/fold/foldgutter.js');
		Webpack.require('codemirror/addon/lint/lint.js');
		Webpack.require('codemirror/addon/lint/javascript-lint.js');
		Webpack.require('codemirror/lib/codemirror.css');
		Webpack.require('codemirror/addon/lint/lint.css');
		Webpack.require('codemirror/addon/fold/foldgutter.css');
		CodeMirror.fromTextArea(this.textarea, {});
	}
}
