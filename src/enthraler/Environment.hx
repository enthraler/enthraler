package enthraler;

import js.html.Element;
import js.Browser.*;
import haxe.Json;

class Environment {

	/**
	The container that the enthraler should render into.
	**/
	public var container(default, null):Element;

	/**
	The metadata for the current enthraler being displayed.
	**/
	public var meta(default, null):Meta;

	public function new(container, meta) {
		this.container = container;
		this.meta = meta;
	}

	/**
	Send a request to the parent environment to change the height.

	This works by sending an `iframe.resize` message to the parent window.
	This message is recognised and handled correctly by an Enthral Host or by the Embedly plugin, which is used by sites such as Medium.

	@param requestedHeight The height you would like the iframe to be, in pixels. If not supplied, the `scrollHeight` of the HTML element, plus 1 pixel, will be used.
	**/
	public function requestHeightChange(?requestedHeight:Float) {
		if (window.parent == null) {
			return;
		}

		if (requestedHeight == null) {
			// The extra 1px is because the actual height might be a fraction of a pixel, but we are given an integer.
			// We add 1px to ensure the requested height will be tall enough.
			requestedHeight = document.documentElement.scrollHeight + 1;
		}

		window.parent.postMessage(Json.stringify({
			src: '' + window.location,
			context: 'iframe.resize',
			height: requestedHeight
		}), '*');
	}

	/**
		(Not implemented yet).
		Dispatch an action that is relevant to the specific user viewing this Enthraler.

		TODO: implement this function.
	**/
	public function dispatchUserAction(action:Action):Void {}

	/**
		(Not implemented yet).
		Dispatch an action that is relevant to the whole group of users viewing this Enthraler.

		TODO: implement this function.
	**/
	public function dispatchGroupAction(action:Action):Void {}
}
