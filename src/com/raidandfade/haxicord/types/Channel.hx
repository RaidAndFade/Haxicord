package com.raidandfade.haxicord.types;

import haxe.extern.EitherType;

class Channel{
    var client:DiscordClient;

    public var type:Int;
    public var id:Snowflake;

    public static function fromStruct(_chan:com.raidandfade.haxicord.types.structs.Channel):Dynamic->DiscordClient->Channel{
        if(_chan.type==1){
            return DMChannel.fromStruct;
        }else{
            return GuildChannel.fromStruct(_chan);
        }
    }

    //Live struct
    public function getMessages(format=null,cb=null){
        if(format==null)format={};
        client.endpoints.getMessages(id.id,format,cb);
    }

    public function getMessage(mid,cb=null){
        client.endpoints.getMessage(id.id,mid,cb);
    }

    public function deleteMessages(ids,cb=null){
        client.endpoints.deleteMessages(id.id,ids,cb);
    }

    public function startTyping(cb=null){
        client.endpoints.startTyping(id.id,cb);
    }

    public function getPins(cb=null){
        client.endpoints.getChannelPins(id.id,cb);
    }

    public function pinMessage(mid,cb=null){
        client.endpoints.addChannelPin(id.id,mid,cb);
    }

    public function unpinMessage(mid,cb=null){
        client.endpoints.deleteChannelPin(id.id,mid,cb);
    }

}

typedef PossibleChannelTypes = EitherType < com.raidandfade.haxicord.types.structs.DMChannel , com.raidandfade.haxicord.types.structs.GuildChannel > ;