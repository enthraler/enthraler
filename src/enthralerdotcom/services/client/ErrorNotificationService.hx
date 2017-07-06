package enthralerdotcom.services.client;

import tink.CoreApi;
import haxe.PosInfos;

class ErrorNotificationService {
	public static var inst = new ErrorNotificationService();

	public function new() {}

	public function logMessage(message:String, ?action:Void->Void, ?actionMessage:String, ?pos:PosInfos) {
		haxe.Log.trace(message, pos);
		if (action != null) {
			if (js.Browser.window.confirm(message)) {
				action();
			}
		} else {
			js.Browser.alert(message);
		}
	}

	inline public function logError(err:Error, ?action:Void->Void, ?actionMessage:String) {
		logMessage(err.message, action, actionMessage, err.pos);
	}
}
