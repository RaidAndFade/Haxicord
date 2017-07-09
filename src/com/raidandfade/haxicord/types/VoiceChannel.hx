package com.raidandfade.haxicord.types;

class VoiceChannel extends GuildChannel {
    public var bitrate:Int;
    public var user_limit:Int;

    public function new(_chan:com.raidandfade.haxicord.types.structs.GuildChannel.VoiceChannel,_client:DiscordClient){
        client = _client;

        id = new Snowflake(_chan.id);
        is_private = _chan.is_private;
        type = _chan.type;
        guild_id = new Snowflake(_chan.guild_id);
        name = _chan.name;
        position = _chan.position;
        permission_overwrites = _chan.permission_overwrites;
        bitrate = _chan.bitrate;
        user_limit = _chan.user_limit;
    }

    public static function fromStruct(_chan,_client){
        return new TextChannel(_chan,_client);
    }
}