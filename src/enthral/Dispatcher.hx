package enthral;

import enthral.Action;

interface Dispatcher {
	function user(action:Action):Void;
	function group(action:Action):Void;
}
