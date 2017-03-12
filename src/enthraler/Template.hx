package enthraler;

import js.html.Element;
import enthraler.UserTypes;
import enthraler.Dispatcher;
import enthraler.HelperTypes;

typedef EnthralerMeta = {
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

typedef Template<AuthorData, UserState, GroupState> = {
	/**
		The container HTML Element, you should render the component inside this element.

		Injected: This will be set by Enthraler immediately after the components constructor has completed.
	**/
	var container:Element;

	/**
		Metadata about the component.

		Injected: This will be set by Enthraler immediately after the components constructor has completed.
	**/
	@:optional var meta:EnthralerMeta;

	/**
		A dispatcher used to trigger actions.

		This can be used to trigger user actions that will be saved to the server.

		Injected: This will be set by Enthraler immediately after the components constructor has completed.
	**/
	@:optional var dispatcher:Dispatcher;

	/**
		Render the component using the author's data and the current state.

		This function is called as soon as authorData is ready.
		It should render the component into the container element given in the constructor.

		If either the authorData or the states are updated, `render()` will be called again with the updated data.

		@param authorData The properties used to configure the display of the component.
		@param userState The current user state. This will be null unless `processUserAction` exists and actions have been called to set a group state.
		@param groupState The current group state. This will be null unless `processGroupAction` exists and actions have been called to set a group state.
	**/
	function render(authorData:AuthorData, ?userState:Null<UserState>, ?groupState:Null<GroupState>):Void;

	/**
		Process an action and update the user state accordingly.

		@param previousState The previous userState before the action occured. This may be null if no user state existed.
		@param action The action that has been triggered.
		@return A new user state. Please return a new object, rather than updating and returning the `previousState` object. If the state should not be updated, return the `previousState` object.
	**/
	@:optional function processUserAction(previousState:Null<UserState>, action:Action):UserState;

	/**
		Process an action and update the group state accordingly.

		@param previousState The previous groupState before the action occured. This may be null if no group state existed.
		@param action The action that has been triggered.
		@return A new group state. Please return a new object, rather than updating and returning the `previousState` object. If the state should not be updated, return the `previousState` object.
	**/
	@:optional function processGroupAction(previousState:Null<GroupState>, action:Action):GroupState;
}

