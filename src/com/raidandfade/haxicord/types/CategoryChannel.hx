package com.raidandfade.haxicord.types;

class CategoryChannel extends GuildChannel{
    public function new(_chan:com.raidandfade.haxicord.types.structs.GuildChannel,_client){
        client = _client;

        id = new Snowflake(_chan.id);
        parent_id = new Snowflake(_chan.parent_id);
        type = _chan.type;
        guild_id = new Snowflake(_chan.guild_id);
        name = _chan.name;
        nsfw = _chan.nsfw;
        position = _chan.position;
        permission_overwrites = _chan.permission_overwrites;
    }
    
    public function _update(_chan:com.raidandfade.haxicord.types.structs.GuildChannel){
        if(_chan.name!=null) name = _chan.name;
        if(_chan.position!=null) position = _chan.position;
        if(_chan.permission_overwrites!=null) permission_overwrites = _chan.permission_overwrites;
        if(_chan.nsfw!=null) nsfw = _chan.nsfw;
    }

    public static function fromStruct(_chan:com.raidandfade.haxicord.types.structs.GuildChannel,_client){
        return new CategoryChannel(_chan,_client);
    }
}