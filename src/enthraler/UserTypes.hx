package enthraler;

import enthraler.HelperTypes;

/**
A simple object describing a user.

It has just enough information to display their name, avatar, and differentiate them by a unique ID.
**/
typedef User = {
	id:String,
	name:String,
	avatar:Null<Url>
};

/** A `User` who is a Designer of templates. **/
typedef Designer = {
	>User,
	designerUrl:Url
}

/** A `User` who uses templates to define new Enthraler content. **/
typedef Author = {
	>User,
	authorUrl:Url
};

/** A `User` who shares an Enthraler object with their audience. This may be the same person as the author, or it may be someone choosing to share content written by another author. **/
typedef Publisher = {
	>User,
	publisherUrl:Url
};

/** A `Group` of users who have interacted with the Enthraler.  This is only made avaialable to publishers. **/
typedef Group = {
	name:String,
	publishers:Array<Publisher>,
	audience:Array<User>
}
