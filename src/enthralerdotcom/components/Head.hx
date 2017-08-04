package enthralerdotcom.components;

import smalluniverse.UniversalPageHead;

class Head {
	public static function prepareHead(head:UniversalPageHead) {
		head.addMeta('viewport', 'width=device-width, initial-scale=1');
		head.addScript('/assets/enthralerdotcom.bundle.js');
		head.addStylesheet('/assets/styles.css');
	}
}
