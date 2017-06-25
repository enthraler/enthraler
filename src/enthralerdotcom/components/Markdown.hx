package enthralerdotcom.components;

import smalluniverse.UniversalComponent;
import smalluniverse.SUMacro.jsx;

typedef MarkdownProps = {
	html:String,
	?className:String
}

class Markdown extends UniversalComponent<MarkdownProps, {}, {}> {
	override public function render() {
		var data = {
			__html: this.props.html
		};
		return jsx('<div className=${this.props.className} dangerouslySetInnerHTML=${data}></div>');
	}
}
