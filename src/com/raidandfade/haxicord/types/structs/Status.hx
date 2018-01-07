package com.raidandfade.haxicord.types.structs;

typedef Status = {
    /**
       The status of the user.
       One of: online, dnd, idle, invisible, offline
     */
    @:optional var status:String; 
    
    /**
       Is the user afk?
     */
    @:optional var afk:Null<Bool>;

    /**
       An activity
     */
    @:optional var game:Null<Activity>;

    /**
       Idle since this timestamp
     */
    @:optional var since:Null<Int>;
}

typedef Activity = {

    /**
       The name of the activity
    */
    var name:String;

    /**
       The activity type, 0 = Game, 1 = Streaming, 2 = Listening to
     */
    var type:Int;

    /**
       The url to point to
     */
    @:optional var url:String;

    /**
       Not implemented properly. Use at own risk
     */
    @:optional var timestamps:Dynamic; //TODO impl this when it's actually documented

    /**
       Not implemented properly. Use at own risk
     */
    @:optional var application_id:String;

    /**
       Not implemented properly. Use at own risk
     */
    @:optional var details:String;

    /**
       Not implemented properly. Use at own risk
     */
    @:optional var state:String;

    /**
       Not implemented properly. Use at own risk
     */
    @:optional var party:Dynamic; //TODO impl this when it's actually documented

    /**
       Not implemented properly. Use at own risk
     */
    @:optional var assets:Dynamic; //TODO impl this when it's actually documented
}
