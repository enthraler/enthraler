package enthral;

typedef User = {
    id:String,
    name:String,
    avatarId:Null<String>
};

typedef Designer = {
    >User,
    designerUrl:String
}

typedef Author = {
    >User,
    authorUrl:String
};

typedef Publisher = {
    >User,
    publisherUrl:String
};

typedef Group = {
    name:String,
    publishers:Array<Publisher>,
    audience:Array<User>
}
