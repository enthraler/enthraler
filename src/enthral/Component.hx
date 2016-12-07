package enthral;

import enthral.UserTypes;
import enthral.Dispatcher;
import enthral.HelperTypes;
import js.html.Element;

typedef ComponentMeta = {
    template:{
        name:String,
        url:Url,
        version:SemverString
    },
    content:{
        name:String,
        url:Url,
        version:SemverString,
        author:Author
    },
    instance:{
        groupToken:String,
        publisher:Publisher
    }
};

/**
A component that renders author data but has no user interactions that modify the state of the component.
**/
interface StaticComponent<AuthorData> {
    /** (Injected). **/
    var meta:ComponentMeta;

    /** (Injected). The data the author has populated this template with. **/
    var authorData:AuthorData;

    /**
    This function is called once all author data has been injected and we are ready to render our the component.

    It should add itself as a child of the container element, without affecting the container in any way.
    You can assume that the container is already empty and is already attached to the DOM.

    This function should render *something* synchronously, even if asynchronous calls are required to populate the view completely.
    If the view will change height as additional data is loaded, we encourage you to set an approximate height during this call to avoid too many layout reflows as various components change height over time.

    @param container The container element the view should render in.
    **/
    function setupView(container:Element):Void;
}

/**
A component that renders author data and allows local interaction and state, but does not persist any state after a page refresh or share any state with the network.
**/
interface LocalComponent<AuthorData, LocalState> extends StaticComponent<AuthorData> {
    /** (Injected). A dispatcher for triggering actions. **/
    var dispatch:Dispatcher;

    /**
    A callback that is called whenever new state is received.
    Use this to update or re-render your component.
    **/
    function receiveLocalState(state:LocalState):Void;

    /**
    Taking the old local state, and receiving an action, return the new local state.

    This is similar to a 'reducer' in Redux, except we're not too precious about immutable state.
    You're welcome to be precious about it if you want though!
    **/
    function processLocalAction(state:LocalState, action:Action):LocalState;
}


/**
A component that renders author data and allows private state to be saved for each user.
**/
interface UserComponent<AuthorData, UserState> extends StaticComponent<AuthorData> {
    /**
    A callback that is called whenever new state is received.
    Use this to update or re-render your component.
    **/
    function receiveUserState(state:{local:UserState, user:UserState}):Void;

    /**
    Taking the old user state, and receiving an action, return the new user state.

    This is similar to a 'reducer' in Redux, except we're not too precious about immutable state.
    You're welcome to be precious about it if you want though!
    **/
    function processUserAction(state:UserState, action:Action):UserState;
}


/**
A component that renders author data and allows shared state to be saved between users in the group.
**/
interface GroupComponent<AuthorData, UserState> extends StaticComponent<AuthorData> {
    /**
    A callback that is called whenever new state is received.
    Use this to update or re-render your component.
    **/
    function receiveUserState(state:{local:UserState, user:UserState}):Void;

    /**
    Taking the old user state, and receiving an action, return the new user state.

    This is similar to a 'reducer' in Redux, except we're not too precious about immutable state.
    You're welcome to be precious about it if you want though!
    **/
    function processUserAction(state:UserState, action:Action):UserState;
}

/**
**/
interface Component<AuthorData, LocalState, UserState, GroupState>
    extends LocalComponent<AuthorData, LocalState>
    extends UserComponent<AuthorData, UserState>
    extends GroupComponent<AuthorData, GroupState> {}
