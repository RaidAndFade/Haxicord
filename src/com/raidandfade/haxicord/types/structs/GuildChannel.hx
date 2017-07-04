package com.raidandfade.haxicord.types.structs;

class GuildChannel extends Channel{
    var guild_id:Int;
    var name:String;
    var position:Int;
    var permission_overwrites:Array<Overwrite>;
}

enum OverwriteType{
    Role;
    Member;
}

class Overwrite{
    var id:Snowflake;
    var type:OverwriteType;
    var allow:Int;
    var deny:Int;
}