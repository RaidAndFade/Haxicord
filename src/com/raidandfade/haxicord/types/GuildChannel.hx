package com.raidandfade.haxicord.types;

import com.raidandfade.haxicord.types.structs.GuildChannel.Overwrite;

class GuildChannel extends Channel {
    public var type:String;
    public var guild_id:Snowflake;
    public var name:String;
    public var position:Int;
    public var permission_overwrites:Array<Overwrite>;

    public static function fromStruct(_chan,_client){
        if(_chan.type=="text"){
            return new TextChannel(_chan,_client);
        }
        if(_chan.type=="voice"){
            return new VoiceChannel(_chan,_client);
        }
        throw "Invalid Struct";
    }
}