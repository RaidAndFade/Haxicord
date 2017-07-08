package com.raidandfade.haxicord.types.structs;

typedef Connection = { 
    var id:String;
    var name:String;
    var type:String;
    var revoked:Bool;
    var integrations:Array<GuildIntegration>;
}