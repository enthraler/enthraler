package enthral;

import enthral.Action;

interface Dispatcher {
	function local(action:Action):Void;
	function user(action:Action):Void;
	function group(action:Action):Void;
}
