package com.raidandfade.haxicord.types;

import haxe.extern.EitherType;

class Channel {
    @:dox(hide)
    public var client:DiscordClient;

    /**
        The type of the channel
        0 = Guild Text Channel
        1 = DM Channel
        2 = Guild Voice Channel
        3 = Group DM
        4 = Category Channel
    */
    public var type:Int;
    /**
       The ID of the channel.
     */
    public var id:Snowflake;

    @:dox(hide)
    public static function fromStruct(_chan:com.raidandfade.haxicord.types.structs.Channel): Dynamic->DiscordClient->Channel {
        if(_chan.type == 1) {
            return DMChannel.fromStruct;
        } else {
            return GuildChannel.fromStruct(_chan);
        }
    }

    /**
        Get the tag for the channel as a string.
     */
    public function getTag() {
        return "<#" + id.id + ">";
    }

    public function getPermission(uid:String):Int{
        return 0;
    }
    public function hasPermission(uid:String, p:Int):Bool{
        return false;
    }
}