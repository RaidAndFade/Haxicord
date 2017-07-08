package com.raidandfade.haxicord.types;

import com.raidandfade.haxicord.types.structs.Message.Attachment;
import com.raidandfade.haxicord.types.structs.Message.Reaction;

//TODO do it properly.
import com.raidandfade.haxicord.types.structs.Embed;

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
    public var embeds:Array<Embed>;
    public var reactions:Array<Reaction>;
    public var nonce:Snowflake;
    public var pinned:Bool;
    public var webhook_id:String;

    var client:DiscordClient;

    public function new(_msg:com.raidandfade.haxicord.types.structs.Message,_client:DiscordClient){
        client = _client;

        id = new Snowflake(_msg.id);
        channel_id = new Snowflake(_msg.channel_id);
        author = new User(_msg.author,client);
        content = _msg.content;
        timestamp = _msg.timestamp;
        edited_timestamp = _msg.edited_timestamp;
        tts = _msg.tts;
        mention_everyone = _msg.mention_everyone;
        mentions = [for(u in _msg.mentions){new User(u,client);}];
        mention_roles = [for(r in _msg.mention_roles){new Role(r,client);}];
        attachments = _msg.attachments; // maybe live, idk why i would though
        embeds = [for(ue in _msg.embeds){new Embed(e,client);}];
        reactions = _msg.reactions; // same as attachments
        nonce = new Snowflake(_msg.nonce);
        pinned = _msg.pinned;
        webhook_id = _msg.webhook_id;
    }

    //TODO Live struct shit
}
