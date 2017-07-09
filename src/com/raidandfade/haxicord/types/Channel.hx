package com.raidandfade.haxicord.types;

import haxe.extern.EitherType;

class Channel{
    var client:DiscordClient;

    public var id:Snowflake;
    public var is_private:Bool;

    public static function fromStruct(_chan:com.raidandfade.haxicord.types.structs.Channel):Dynamic->DiscordClient->Channel{
        if(_chan.is_private){
            return DMChannel.fromStruct;
        }else{
            return GuildChannel.fromStruct(_chan);
        }
    }
}

typedef PossibleChannelTypes = EitherType < com.raidandfade.haxicord.types.structs.DMChannel , com.raidandfade.haxicord.types.structs.GuildChannel > ;