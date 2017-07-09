package com.raidandfade.haxicord.types;

class TextChannel extends GuildChannel {
    public var topic:String;
    public var last_message_id:Snowflake;

    public function new(_chan:com.raidandfade.haxicord.types.structs.GuildChannel.TextChannel,_client:DiscordClient){
        client = _client;

        id = new Snowflake(_chan.id);
        is_private = _chan.is_private;
        type = _chan.type;
        guild_id = new Snowflake(_chan.guild_id);
        name = _chan.name;
        position = _chan.position;
        permission_overwrites = _chan.permission_overwrites;
        topic = _chan.topic;
        last_message_id = new Snowflake(_chan.last_message_id);
    }

    public static function fromStruct(_chan,_client){
        return new TextChannel(_chan,_client);
    }
}