package com.raidandfade.haxicord.types.structs;

typedef GuildMember = {
    var user:User;
    var nick:Null<String>;
    var roles:Array<String>;
    @:optional var joined_at:String;
    @:optional var deaf:Bool;
    @:optional var mute:Bool;

    @:optional var guild_id:String;
}