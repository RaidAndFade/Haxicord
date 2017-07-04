package com.raidandfade.haxicord.types.structs;

class Role { 
    var id:Snowflake;
    var name:String;
    var color:Int; 
    var hoist:Bool; //pinned in user listing?
    var position:Int;   
    var permissions:Int;
    var managed:Bool; //Is this an integrated role?
    var mentionable:Bool;
}