package com.raidandfade.haxicord.types.structs;

typedef Emoji = {
    var id:String;
    var name:String;
    var roles:Array<Role>;
    var require_colons:Bool;
    var managed:Bool;
}