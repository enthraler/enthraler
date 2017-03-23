package enthraler;

#if feature_shared_state
/**
An Action object describes an action an end-user has taken while interacting with an Enthraler.

These actions can be triggered in a "User" context, or a "Group" context.

Actions triggered in a User context are relevant to that User and will be remembered every time a user views this Enthraler.
See `Environment.dispatchUserAction()`.

Actions triggered in a Group context are relevant to the whole Group and will be shared with the entire audience of the Enthraler.
See `Environment.dispatchGroupAction()`.

See `Template.processUserAction()` and `Template.processGroupAction()` to see how a template can process these actions into a consistent state.
See `Template.render()` for how this state is then rendered to the user.

Actions are a plain JS object, and always have a "type" property to differentiate different types of actions.
**/
// TODO: make an abstract that is a {type:'EnumConstructor'} name, but works with Haxe enums seamlessly
typedef Action = {
	type:String
}
#end
