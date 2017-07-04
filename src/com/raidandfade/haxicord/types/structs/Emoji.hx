package com.raidandfade.haxicord.types.structs;

class Emoji {
    var id:Snowflake;
    var name:String;
    var roles:Array<Role>;
    var require_colons:Bool;
    var managed:Bool;
}