package com.raidandfade.haxicord.types;

import com.raidandfade.haxicord.types.Channel;

class TextChannel extends GuildChannel{
    var topic:String;
    var last_message_id:Snowflake;
}
