package enthraler;

/**
The type specification for an Enthraler Template.

A template should have a `new()` function (constructor) and a `render()` method.

(For feature_shared_state): If using persistant state, it should have `processUserAction()` and `processGroupAction()` functions as required.
**/
#if feature_shared_state
typedef Template<AuthorData, UserState, GroupState> = {
#else
typedef Template<AuthorData> = {
#end

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

	This function is called as soon as authorData is ready, and then again if `authorData` is updated.
	It should render the component into the container element given in the constructor.

	@param authorData The JSON data used to configure this enthraler.
	**/
	function render(authorData:AuthorData):Void;
}

