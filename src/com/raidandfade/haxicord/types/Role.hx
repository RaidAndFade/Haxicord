package com.raidandfade.haxicord.types.structs;

class Role { 
    var client:DiscordClient;

    public var id:Snowflake;
    public var name:String;
    public var color:Int; 
    public var hoist:Bool; //pinned in user listing?
    public var position:Int;   
    public var permissions:Int;
    public var managed:Bool; //Is this an integrated role?
    public var mentionable:Bool;

    public function new(_role:com.raidandfade.haxicord.types.structs.Role,_client:DiscordClient){
        client = _client;
        id = new Snowflake(_role.id);
        name = _role.name;
        color = _role.color;
        hoist = _role.hoist;
        position = _role.position;
        permissions = _role.permissions;
        managed = _role.managed;
        mentionable = _role.mentionable;
    }
}