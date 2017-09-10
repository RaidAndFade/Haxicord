package com.raidandfade.haxicord.types;

class TextChannel extends GuildChannel implements MessageChannel {
    public var topic:String;
    public var last_message_id:Snowflake;

    public function new(_chan:com.raidandfade.haxicord.types.structs.GuildChannel.TextChannel,_client:DiscordClient){
        client = _client;

        id = new Snowflake(_chan.id);
        type = _chan.type;
        parent_id = new Snowflake(_chan.parent_id);
        guild_id = new Snowflake(_chan.guild_id);
        name = _chan.name;
        nsfw = _chan.nsfw;
        position = _chan.position;
        permission_overwrites = _chan.permission_overwrites;
        topic = _chan.topic;
        last_message_id = new Snowflake(_chan.last_message_id);
    }

    public function _update(_chan:com.raidandfade.haxicord.types.structs.GuildChannel.TextChannel){
        if(_chan.name!=null) name = _chan.name;
        if(_chan.position!=null) position = _chan.position;
        if(_chan.permission_overwrites!=null) permission_overwrites = _chan.permission_overwrites;
        if(_chan.topic!=null) topic = _chan.topic;
        if(_chan.nsfw!=null) nsfw = _chan.nsfw;
    }

    public static function fromStruct(_chan,_client){
        return new TextChannel(_chan,_client);
    }

    //livestruct
    public function inGuild(){
        return true;
    }

    public function sendMessage(mesg,cb=null){
        client.endpoints.sendMessage(id.id,mesg,cb);
    }
    
    public function getMessages(format=null,cb=null){
        if(format==null)format={};
        client.endpoints.getMessages(id.id,format,cb);
    }

    public function getMessage(mid,cb=null){
        client.endpoints.getMessage(id.id,mid,cb);
    }

    public function deleteMessage(mid,cb=null){
        client.endpoints.deleteMessage(id.id,mid,cb);
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