package enthraler;

import enthraler.UserTypes;
import enthraler.HelperTypes;

/**
Metadata about a particular Enthraler instance.

It contains information about the template, the content, and the specific shared instance.
**/
typedef Meta = {
	template:{
		url:Url,
		path:Url,
		?name:String,
		?version:SemverString
	},
	content:{
		url:Url,
		path:Url,
		?name:String,
		?version:SemverString,
		?author:Author
	},
	?instance:{
		?publisher:Publisher
	}
};
