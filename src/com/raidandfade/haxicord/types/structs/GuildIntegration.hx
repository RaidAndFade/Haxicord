package com.raidandfade.haxicord.types.structs;

class GuildIntegration {
    var id:Snowflake;
    var name:String;
    var type:String;
    var enabled:Bool;
    var syncing:Bool;
    var role_id:Snowflake;
    var expire_behavior:Int;
    var expire_grace_period:Int;
    var user:User;
    var account:IntegrationAccount;
    var synced_at:Date;
}

class IntegrationAccount{
    var id:String;
    var name:String;
}