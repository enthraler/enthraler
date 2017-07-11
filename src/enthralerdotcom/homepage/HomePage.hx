package enthralerdotcom.homepage;

import smalluniverse.UniversalPage;
import smalluniverse.SUMacro.jsx;
import enthralerdotcom.components.*;
import enthralerdotcom.types.*;
using tink.CoreApi;

enum HomeAction {
	None;
}

class HomePage extends UniversalPage<HomeAction, {}, {}, {}, {}> {

	public function new(api:HomeBackendApi) {
		super(api);
	}

	override function render() {
		this.head.addScript('/assets/enthralerdotcom.bundle.js');
		this.head.addStylesheet('/assets/styles.css');
		this.head.setTitle('Enthraler');
		return jsx('<div>
			<div className="container is-fluid">
				<HeaderNav></HeaderNav>
			</div>
			<section className="hero is-fullheight is-dark">
				<div className="hero-body">
					<div className="container">
						<h1 className="title">
							Coming Soon: Enthraler
						</h1>
						<h2 className="subtitle">
							<strong>Create digital infographics in seconds</strong>
							<br />
							Using ready-made templates from our creative community
						</h2>
					</div>
				</div>
			</section>
			<section className="section">
				<div className="container">
					<h3 className="title">Enthral</h3>
					<h4 className="subtitle"><em>v. Capture the fascinated attention of.</em></h4>
				</div>
			</section>
			<section className="section">
				<div className="container">
					<h3 className="title">Enthraler</h3>
					<h4 className="subtitle"><em>n. A digital infographic you can use to share your best stories and your biggest ideas with your audience.</em></h4>
				</div>
			</section>
		</div>');
		/**
		TODO:
		- An audience of 160k visitors
		- Has interacted with 17k enthralers
		- Created by 2k authors
		- And 172 designers
		**/
	}
}
