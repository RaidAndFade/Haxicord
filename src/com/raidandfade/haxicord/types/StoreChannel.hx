package com.raidandfade.haxicord.types;

#if Profiler
@:build(Profiler.buildAll())
#end
class StoreChannel extends GuildChannel {

    @:dox(hide)
    public function new(_chan:com.raidandfade.haxicord.types.structs.GuildChannel.StoreChannel, _client:DiscordClient) {
        client = _client;

        id = new Snowflake(_chan.id);
        type = _chan.type;
        parent_id = new Snowflake(_chan.parent_id);
        guild_id = new Snowflake(_chan.guild_id);
        name = _chan.name;
        nsfw = _chan.nsfw;
        position = _chan.position;
        permission_overwrites = _chan.permission_overwrites;
    }

    @:dox(hide)
    public function _update(_chan:com.raidandfade.haxicord.types.structs.GuildChannel.StoreChannel) {
        if(_chan.name != null)
            name = _chan.name;

        if(_chan.position != null) 
            position = _chan.position;

        if(_chan.permission_overwrites != null) 
            permission_overwrites = _chan.permission_overwrites;

        if(_chan.nsfw != null) 
            nsfw = _chan.nsfw;
    }

    @:dox(hide)
    public static function fromStruct(_chan, _client) {
        return new StoreChannel(_chan, _client);
    }

    //livestruct
    /**
       Returns whether the channel is part of a guild or not. Always true for StoreChannels
     */
    public function inGuild() {
        return true;
    }
}
