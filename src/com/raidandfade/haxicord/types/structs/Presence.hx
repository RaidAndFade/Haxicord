package com.raidandfade.haxicord.types.structs;

typedef Presence = {
    @:optional var idle_since:Int;
    @:optional var nick:String;
    @:optional var user:User;
    @:optional var status:String;
    @:optional var roles:Array<String>;
    @:optional var guild_id:String;
    @:optional var game:PresenceGame;
}

typedef PresenceGame = {
    var name:String;
}
