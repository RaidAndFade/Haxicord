package com.raidandfade.haxicord.types.structs;

typedef Webhook = {
    var id:String;
    var guild_id:String;
    var channel_id:String;
    @:optional var user:User;
    @:optional var name:String;
    @:optional var avatar:String;
    @:optional var token:String;
}