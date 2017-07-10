package com.raidandfade.haxicord.types;

import com.raidandfade.haxicord.types.structs.MessageStruct.Attachment;
import com.raidandfade.haxicord.types.structs.MessageStruct.Reaction;

import haxe.DateUtils;

//TODO do it properly.
//import com.raidandfade.haxicord.types.structs.Embed;

class Message {

    public var id:Snowflake;
    public var channel_id:Snowflake;
    public var author:User;
    public var content:String;
    public var timestamp:Date;
    public var edited_timestamp:Date;
    public var tts:Bool;
    public var mention_everyone:Bool;
    public var mentions:Array<User>;
    public var mention_roles:Array<Role>;
    public var attachments:Array<Attachment>;
    public var embeds:Array<Dynamic>;
    public var reactions:Array<Reaction>;
    public var nonce:Snowflake;
    public var pinned:Bool;
    public var webhook_id:String;

    var client:DiscordClient;

    public function new(_msg:com.raidandfade.haxicord.types.structs.MessageStruct,_client:DiscordClient){
        client = _client;

        id = new Snowflake(_msg.id);
        channel_id = new Snowflake(_msg.channel_id);
        author = client.newUser(_msg.author);
        content = _msg.content;
        if(_msg.timestamp!=null)timestamp = DateUtils.fromISO8601(_msg.timestamp);
        if(_msg.edited_timestamp!=null)edited_timestamp = DateUtils.fromISO8601(_msg.edited_timestamp);
        tts = _msg.tts;
        mention_everyone = _msg.mention_everyone;
        mentions = [for(u in _msg.mentions){client.newUser(u);}];
        mention_roles = [for(r in _msg.mention_roles){cast(client.getChannelUnsafe(_msg.channel_id),GuildChannel).getGuild().newRole(r);}];
        attachments = _msg.attachments; // maybe live, idk why i would though
        embeds = _msg.embeds; //[for(ue in _msg.embeds){new Embed(e,client);}]; // TODO this properly
        reactions = _msg.reactions; // same as attachments
        nonce = new Snowflake(_msg.nonce);
        pinned = _msg.pinned;
        webhook_id = _msg.webhook_id;
    }

    public function update(_msg:com.raidandfade.haxicord.types.structs.MessageStruct){
        if(_msg.edited_timestamp!=null)edited_timestamp = DateUtils.fromISO8601(_msg.edited_timestamp);
        if(_msg.tts!=null)tts = _msg.tts;
        if(_msg.mention_everyone!=null)mention_everyone = _msg.mention_everyone;
        if(_msg.mentions!=null)mentions = [for(u in _msg.mentions){client.newUser(u);}];
        if(_msg.mention_roles!=null)mention_roles = [for(r in _msg.mention_roles){cast(client.getChannelUnsafe(_msg.channel_id),GuildChannel).getGuild().newRole(r);}];
        if(_msg.attachments!=null)attachments = _msg.attachments; // maybe live, idk why i would though
        if(_msg.embeds!=null)embeds = _msg.embeds; //[for(ue in _msg.embeds){new Embed(e,client);}]; // TODO this properly
        if(_msg.reactions!=null)reactions = _msg.reactions; // same as attachments
        if(_msg.nonce!=null)nonce = new Snowflake(_msg.nonce);
        if(_msg.pinned!=null)pinned = _msg.pinned;
        if(_msg.webhook_id!=null)webhook_id = _msg.webhook_id;
    }

    //TODO Live struct shit

    public function reply(msg:com.raidandfade.haxicord.endpoints.Typedefs.MessageCreate,cb){
        client.endpoints.sendMessage(channel_id.id,msg,cb);
    }
}
