package enthraler;

import enthraler.Action;

interface Dispatcher {
	function user(action:Action):Void;
	function group(action:Action):Void;
}
