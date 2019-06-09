package com.raidandfade.haxicord.types.structs;

typedef User = {
    var id:String; 
    @:optional var username:String;
    @:optional var discriminator:String;
    @:optional var avatar:String;
    @:optional var bot:Bool;
    @:optional var mfa_enabled:Bool;

    //The next two can only be gained from the OAUTH2 Endpoint.
    @:optional var verified:Bool;
    @:optional var email:String;
    @:optional var flags:Int; // 1=employee, 2=partner, 4=hs events, 8=bug hunter,64=hs bravery,128=hs brilliance,256=hs balance,512=early supporter
    @:optional var premium_type:Int; // 1=nitro classic 2=nitro

    //Ban events have this:
    @:optional var guild_id:String;
}