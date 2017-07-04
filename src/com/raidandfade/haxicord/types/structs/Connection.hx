package com.raidandfade.haxicord.types.structs;

class Connection { 
    var id:String;
    var name:String;
    var type:String;
    var revoked:Bool;
    var integrations:Array<GuildIntegration>;
}