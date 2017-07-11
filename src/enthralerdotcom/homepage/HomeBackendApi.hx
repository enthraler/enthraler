package enthralerdotcom.homepage;

import smalluniverse.BackendApi;
import enthralerdotcom.homepage.HomePage;
using tink.CoreApi;

class HomeBackendApi implements BackendApi<HomeAction, {}, {}> {
	public function new() {
	}

	public function get(params:{}):Promise<{}> {
		return {};
	}

	public function processAction(params:{}, action:HomeAction):Promise<BackendApiResult> {
		switch action {
			case _:
				return Done;
		}
	}
}
