package com.raidandfade.haxicord.types;

import com.raidandfade.haxicord.types.structs.Channel.ChannelType;

class Channel{
    var client:DiscordClient;

    public var id:Snowflake;
    public var is_private:Bool;

    public function fromStruct(_chan:com.raidandfade.haxicord.types.structs.Channel,_client:DiscordClient){
        if(_chan.is_private){
            return new DMChannel(_chan,_client);
        }else{
            return GuildChannel.fromStruct(_chan,_client);
        }
    }
}