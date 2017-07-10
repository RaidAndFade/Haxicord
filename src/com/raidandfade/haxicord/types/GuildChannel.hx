package com.raidandfade.haxicord.types;

import com.raidandfade.haxicord.types.structs.GuildChannel.Overwrite;

import haxe.extern.EitherType;

class GuildChannel extends Channel {
    public var type:Int;
    public var guild_id:Snowflake;
    public var name:String;
    public var position:Int;
    public var permission_overwrites:Array<Overwrite>;

    public function getGuild(){
        return client.getGuildUnsafe(guild_id.id);
    }

    public static function fromStruct(_chan):Dynamic->DiscordClient->GuildChannel{
        if(_chan.type==0){
            return TextChannel.fromStruct;
        }
        if(_chan.type==2){
            return VoiceChannel.fromStruct;
        }
        throw "Invalid Struct";
    }
}
