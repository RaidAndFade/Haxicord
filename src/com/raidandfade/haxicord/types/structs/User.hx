package com.raidandfade.haxicord.types.structs;

typedef User = {
    var id:String; 
    var username:String;
    var discriminator:String;
    var avatar:String;
    var bot:Bool;
    var mfa_enabled:Bool;

    //The next two can only be gained from the OAUTH2 Endpoint.
    var verified:Bool;
    var email:String;
}