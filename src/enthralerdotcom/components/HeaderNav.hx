package enthralerdotcom.components;

import smalluniverse.UniversalComponent;
import smalluniverse.SUMacro.jsx;

class HeaderNav extends UniversalComponent<{}, {open:Bool}, {}> {
	public function new(props) {
		super(props);
		this.state = {
			open: false
		};
	}

	override public function render() {
		var isActiveClass = (this.state.open) ? " is-active" : "";
		return jsx('<nav className="nav">
			<div className="nav-left">
				<a href="/" className="nav-item">Enthraler</a>
				<a href="https://github.com/enthraler/enthraler" className="nav-item">
					<span className="icon">
						<i className="fa fa-github"></i>
					</span>
				</a>
				<a href="https://twitter.com/enthraler" className="nav-item">
					<span className="icon">
						<i className="fa fa-twitter"></i>
					</span>
				</a>
			</div>
			<span className=${"nav-toggle" + isActiveClass} onClick=${toggleMenu}>
				<span></span>
				<span></span>
				<span></span>
			</span>
			<div className=${"nav-right nav-menu" + isActiveClass}>
				<div className="nav-item">
					<a href="/create" className="button is-primary">
						Create
					</a>
				</div>
				<a href="/templates" className="nav-item">
					Templates
				</a>
			</div>
		</nav>');
	}

	@:client
	function toggleMenu() {
		this.setState({
			open: !state.open
		});
	}
}
