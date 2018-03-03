package com.raidandfade.haxicord.types.structs;

typedef Emoji = {
    var id:String;
    var name:String;
    @:optional var roles:Array<Role>;
    @:optional var require_colons:Bool;
    @:optional var user:User;
    @:optional var managed:Bool;
    @:optional var animated:Bool;
}