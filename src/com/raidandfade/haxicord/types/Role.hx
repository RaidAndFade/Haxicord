package com.raidandfade.haxicord.types;

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

    public var guild:Guild;

    public function new(_role:com.raidandfade.haxicord.types.structs.Role,_guild,_client:DiscordClient){
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

    public function _update(_role:com.raidandfade.haxicord.types.structs.Role){
        if(_role.color!=null) color = _role.color;
        if(_role.hoist!=null) hoist = _role.hoist;
        if(_role.position!=null) position = _role.position;
        if(_role.permissions!=null) permissions = _role.permissions;
        if(_role.managed!=null) managed = _role.managed;
        if(_role.mentionable!=null) mentionable = _role.mentionable;
    }

    //Live funcs
    public function edit(rd,cb=null){
        client.endpoints.editRole(guild.id.id,id.id,rd,cb);
    }

    public function delete(cb=null){
        client.endpoints.deleteRole(guild.id.id,id.id,cb);
    }
}