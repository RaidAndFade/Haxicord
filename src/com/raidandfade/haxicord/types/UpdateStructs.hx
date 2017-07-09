package com.raidandfade.haxicord.types;

typedef UpdateRole = {
    @:optional var name:String;
    @:optional var permissions:Int;
    @:optional var color:Int;
    @:optional var position:Int;
    @:optional var hoist:Bool;
    @:optional var mentionable:Bool;
    @:optional var managed:Bool;
}