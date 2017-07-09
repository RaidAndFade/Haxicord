package com.raidandfade.haxicord.types;

import com.raidandfade.haxicord.types.structs.GuildChannel.Overwrite;

import haxe.extern.EitherType;

class GuildChannel extends Channel {
    public var type:String;
    public var guild_id:Snowflake;
    public var name:String;
    public var position:Int;
    public var permission_overwrites:Array<Overwrite>;

    public static function fromStruct(_chan){
        if(_chan.type=="text"){
            return TextChannel.fromStruct;
        }
        if(_chan.type=="voice"){
            return VoiceChannel.fromStruct;
        }
        throw "Invalid Struct";
    }
}
