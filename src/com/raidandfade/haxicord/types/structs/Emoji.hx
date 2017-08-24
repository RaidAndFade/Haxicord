package com.raidandfade.haxicord.types.structs;

typedef Emoji = {
    var id:String;
    var name:String;
    @:optional var roles:Array<Role>;
    @:optional var require_colons:Bool;
    @:optional var managed:Bool;
}