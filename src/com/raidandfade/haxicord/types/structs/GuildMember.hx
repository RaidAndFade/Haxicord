package com.raidandfade.haxicord.types.structs;

typedef GuildMember = {
    var user:User;
    var nick:Null<String>;
    var roles:Array<String>;
    var joined_at:Float;
    var deaf:Bool;
    var mute:Bool;
}