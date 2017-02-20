Enthraler: capture the fascinated attention of.

Enthraler: an interactive component you add to your page that enthrals your audience.


---

The idea

1. Design - create a new template, design and interaction.
2. Author - use a template to present your idea in a powerful way
3. Publish - share these ideas with your audience so they can interact with it, with you and with each other.

---

You know how articles online are more engaging when they embed videos, slideshows, or interactive content?
What we do is have a system that lets the creatives design templates, the authors present their ideas, and the publishers share it with their audience.
In fact... we have a library of 100+ interactive templates presenting 10,000+ ideas to 1,000,000+ people.

---

Example 1: a simple interactive USA map (solitary interaction)

1. Design - a simple JS/HTML5 API that developers and designers use to create interactive templates.
    - A developer creates a USA map where each state can be colour coded according to data, with tooltips on each. They write JS and HTML to make it work.
2. Author - the author can "fill in the values" for the template to share their own idea.
    - Nate Silver wants to show his final projection for the US presidential election, so he sets values and tooltipis for each of the 50 states, and creates a colour-key to decide what colours they will be rendered.
3. Publish - a high school politics teacher wants to embed the data into their class discussion, and there is an "publish" button on the site
    - The full code is embedded in their school LMS, and students are able to interact with it.

Example 2: (audience to publisher interaction)

1. Design - a translator tool where you can put it an English sentence, and ask for a French translation with several "model answers" that are available after an attempt.
2. Author - a French tutor writes out 100s of examples for their students to practice on.
3. Publish - the French tutor publishes them on their private blog, and the students practice, and the French tutor can give feedback to the student.
    - If a new tutor joins the business, they can re-use the content but with their own audience.

Example 3: (audience to audience interaction)

1. Design - a developer builds a tool for annotating images and adding comments.  A shaded rectangle is added to an image, and when you hover over it you can comment and discuss.
2. Author - A history professor adds a dozen propaganda images for students to analyze, and asks for them to make comments.
3. Publish - A history teacher uses the author's collection, and shares it with their students. Students can see each others comments and discuss further. The teacher can see it all.

---

Why this approach:

1. Let designers come up with some really amazing templates.
2. Let authors create content that is more interactive and more engaging.
3. Bring the best of open-source to content creation
    a. Separation of content and code.
    b. Allow forking and semver on designer templates.
    c. Allow forking and semver on author content (with JSON diffing).
    d. Have a simple model for group interaction that is compatible across different apps and login systems so content is free to be used everywhere.
4. Allow flexibility of libraries used. Could be a simple JS interface, but a template could use React or Vue or whatever.
    a. Allow a hybrid CDN / Semver / Bower type system for loading common dependencies and finding compatible versions.

---

Integrations:

- Moodle
- Wordpress
- Google Classroom
- Gmail
- Twitter (we host, but give a shortlink that is unique to your audience)

---

Code interface:


To render:

```
var moodleConnection = new Moodle(groupToken, userToken);
var enthralerHost = new EnthralerHost().connectTo(moodleConnection);
enthralerHost.render('template:version', 'content:version', '#my-container', 'instance-id-01');
enthralerHost.render('usa-map:2.1.0', '538prediction:1.0.0', '#embed-election', 'instance-id-02');
enthralerHost.render('annotationGallery:2.1.0', 'naziPropaganda:1.0.0', '#embed-posters', 'instance-id-03');
```

To create a component:

```
// Should user, group etc be part of the state?
// That way if someone joins the group, we know?
// One option: the author could include that as a AnnounceJoin(user) action that updates the state.
typedef ComponentState<LocalState, UserState, GroupState> = {
    local:LocalState,
    user:UserState,
    group:GroupState
}

interface StaticComponent<AuthorData> {
    var authorData:AuthorData;
    var author:Author;
    var publisher:Publisher;
    var assetService:AssetService;
    function setup(node):Void; // Render based on author data only. No network. Could be placeholder.
}

interface LocalComponent<AuthorData, {local:LocalState}> extends StaticComponent {
    var dispatch:Dispatcher;
    function receiveState(state:ComponentState):Void;
    function processLocalAction(state:LocalState, action:Action):LocalState;
    function renderView(node, state:ComponentState, isPublisher):Promise<Node>; // Render each change to state.
}

interface UserComponent<AuthorData, {local:LocalState, user:UserState}> extends LocalComponent {
    var user:User;
    function processUserAction(state:UserState, action:Action):UserState;
    function dispatchUser(action:Action);
}

interface GroupComponent<AuthorData, {local:LocalState, user:UserState, group:GroupState}> extends UserComponent {
    var group:Group;
    function processGroupAction(state:GroupState, userWhoTriggered:User, action:Action):GroupState;
    function dispatchGroup(action:Action);
}

interface Form<AuthorData> {
    function render
}

interface StateService() {
    function new(userToken) {}
    function updateUserState(action):UserState {}
    function updateGroupState(action):GroupState {}
}

interface AssetService() {
    function getAvatar(user:User):URL;
    function getInteractionAssets():Promise<{ author:Files, user:Files, group:Files }>;
    function saveAssets(files:Files):Promise<URLs>
}

interface EnthralService() {
    updateUserState()
    updateGroupState()
    getAvatar(user, size):Url

}
```

---

Server side API (could be reimplemented for Wordpress, Moodle etc):

- Request Widgets
    - Request array of widgets with:
        - Current groupToken, userToken
        - Content + version
            - From there figure out template + version, dependencies, actions
    - Return
        - Dependencies (React, D3 etc)
        - Array of:
            - Widget JS modules (pre-bundled)
            - AuthorData
            - Actions (User, Group) collected so far.

- SaveUserActions(content, userToken, action);
- GetUserActions(content[], userToken, ?ignoreActionsBefore:Date):Map<Content,Array<Action>>;

- SaveGroupActions(content, groupToken, action);
- GetGroupActions(content[], groupToken, ?ignoreActionsBefore:Date):Map<Content,Array<Action>>;

- SaveAuthorAsset(content, file):Id
- SaveUserAsset(content, userToken, file):Id

- SaveGroupAsset(content, groupToken, file):Id
- GetAuthorAsset(content, id):File

- GetUserAsset(content, id, userToken):File
- GetGroupAsset(content, id, groupToken):File
