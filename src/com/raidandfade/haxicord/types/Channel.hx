package com.raidandfade.haxicord.types;

import haxe.extern.EitherType;

class Channel{
    public var client:DiscordClient;

    public var type:Int;
    public var id:Snowflake;

    public static function fromStruct(_chan:com.raidandfade.haxicord.types.structs.Channel):Dynamic->DiscordClient->Channel{
        if(_chan.type==1){
            return DMChannel.fromStruct;
        }else{
            return GuildChannel.fromStruct(_chan);
        }
    }

    public function getMention(){
        return "<#"+id.id+">";
    }
}