package enthraler;

/**
The type specification for an Enthraler Template.

A template should have a `new()` function (constructor) and a `render()` method.

If using persistant state, it should have `processUserAction()` and `processGroupAction()` functions as required.
**/
typedef Template<AuthorData, UserState, GroupState> = {

	#if xml
		/**
		The constructor (or `new()` function) for your Enthraler Template.

		It will accept one argument, the `Environment`, which includes the container it should render inside, functions to dispatch actions, metadata etc.
		**/
		// Note: Haxe 3.4 no longer allows us to add a `new()` function specification to a typedef.
		// We are rendering it here only in XML (API document generation) mode, and using the name "constructor" as a workaround.
		function constructor(environment:Environment):Void;
	#end

	/**
	Render the component using the author's data and the current state.

	This function is called as soon as authorData is ready, and then again if any of `authorData`, `userState` or `groupState` are updated.
	It should render the component into the container element given in the constructor.

	If either the authorData or the states are updated, `render()` will be called again with the updated data.

	@param authorData The properties used to configure the display of the component.
	@param userState The current user state. This will only be set if `processUserAction` exists and actions have been called to set a group state.
	@param groupState The current group state. This will only be set if `processGroupAction` exists and actions have been called to set a group state.
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

