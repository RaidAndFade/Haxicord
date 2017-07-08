package com.raidandfade.haxicord.types.structs;

typedef GuildIntegration = {
    var id:String;
    var name:String;
    var type:String;
    var enabled:Bool;
    var syncing:Bool;
    var role_id:String;
    var expire_behavior:Int;
    var expire_grace_period:Int;
    var user:User;
    var account:IntegrationAccount;
    var synced_at:Float;
}

typedef IntegrationAccount = {
    var id:String;
    var name:String;
}