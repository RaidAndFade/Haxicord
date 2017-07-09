package com.raidandfade.haxicord.types.structs;

typedef Role = { 
    var id:String;
    var name:String;
    @:optional var color:Int; 
    @:optional var hoist:Bool; //pinned in user listing?
    @:optional var position:Int;   
    @:optional var permissions:Int;
    @:optional var managed:Bool; //Is this an integrated role?
    @:optional var mentionable:Bool;
}