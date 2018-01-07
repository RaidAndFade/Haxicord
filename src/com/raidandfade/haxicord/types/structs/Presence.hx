package com.raidandfade.haxicord.types.structs;

typedef Presence = {
    @:optional var idle_since:Int;
    @:optional var status:String;
    @:optional var user:User;

    /**
       PER GUILD, WILL BE RANDOM ON USER OBJECTS
    **/
    @:optional var nick:String;
    /**
       PER GUILD, WILL BE RANDOM ON USER OBJECTS
    **/
    @:optional var roles:Array<String>;
    /**
       PER GUILD, WILL BE RANDOM ON USER OBJECTS
    **/
    @:optional var guild_id:String;

    @:optional var game:PresenceGame;
}

typedef PresenceGame = {
    var name:String;
    var type:Int;
}
