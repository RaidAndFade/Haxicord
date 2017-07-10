package com.raidandfade.haxicord.types.structs;

typedef User = {
    var id:String; 
    var username:String;
    @:optional var discriminator:String;
    @:optional var avatar:String;
    @:optional var bot:Bool;
    @:optional var mfa_enabled:Bool;

    //The next two can only be gained from the OAUTH2 Endpoint.
    @:optional var verified:Bool;
    @:optional var email:String;

    //Ban events have this:
    @:optional var guild_id:String;
}