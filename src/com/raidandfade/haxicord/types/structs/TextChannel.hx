package com.raidandfade.haxicord.types.structs;

import com.raidandfade.haxicord.types.structs.Channel;

class TextChannel extends GuildChannel{
    var topic:String;
    var last_message_id:Snowflake;
}
