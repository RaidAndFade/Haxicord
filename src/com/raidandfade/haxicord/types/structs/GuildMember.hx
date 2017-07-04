package com.raidandfade.haxicord.types.structs;

class GuildMember{
    var user:User;
    var nick:Null<String>;
    var roles:Array<Snowflake>;
    var joined_at:Date;
    var deaf:Bool;
    var mute:Bool;
}