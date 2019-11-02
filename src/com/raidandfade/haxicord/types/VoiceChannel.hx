package com.raidandfade.haxicord.types;

#if Profiler
@:build(Profiler.buildAll())
#end
class VoiceChannel extends GuildChannel {
    
    /**
       The bitrate of the channel
     */
    public var bitrate:Int;
    /**
       The user limit of the channel (or 0 if unlimited)
     */
    public var user_limit:Int;

    @:dox(hide)
    public function new(_chan:com.raidandfade.haxicord.types.structs.GuildChannel.VoiceChannel, _client:DiscordClient) {
        client = _client;

        id = new Snowflake(_chan.id);
        type = _chan.type;
        parent_id = new Snowflake(_chan.parent_id);
        guild_id = new Snowflake(_chan.guild_id);
        name = _chan.name;
        nsfw = _chan.nsfw;
        position = _chan.position;
        permission_overwrites = _chan.permission_overwrites;
        bitrate = _chan.bitrate;
        user_limit = _chan.user_limit;
    }

    @:dox(hide)
    public function _update(_chan:com.raidandfade.haxicord.types.structs.GuildChannel.VoiceChannel) {
        if(_chan.name != null) 
            name = _chan.name;
        
        if(_chan.position != null) 
            position = _chan.position;
        
        if(_chan.permission_overwrites != null) 
            permission_overwrites = _chan.permission_overwrites;
        
        if(_chan.bitrate != null) 
            bitrate = _chan.bitrate;
        
        if(_chan.user_limit != null) 
            user_limit = _chan.user_limit;
        
        if(_chan.nsfw != null) 
            nsfw = _chan.nsfw;
    }

    @:dox(hide)
    public static function fromStruct(_chan, _client) {
        return new VoiceChannel(_chan, _client);
    }
}