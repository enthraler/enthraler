package enthraler;

import enthraler.UserTypes;
import enthraler.HelperTypes;

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
