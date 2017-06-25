package enthralerdotcom.components;

import smalluniverse.UniversalComponent;
import smalluniverse.SUMacro.jsx;

typedef ButtonProps = {
	label:String,
	onClick:Void->Void,
	?icon:String,
}

class Button extends UniversalComponent<ButtonProps, {}, {}> {
	override public function render() {
		var iconClassName = "fa fa-"+this.props.icon;
		var icon = (this.props.icon != null) ? jsx('<span className="icon is-small">
			<i className=${iconClassName}></i>
		</span>') : null;
		return jsx('<a href="javascript:void(0)" className="button is-small" onClick=${this.props.onClick}>
			$icon
			<span>${this.props.label}</span>
		</a>');
	}
}
