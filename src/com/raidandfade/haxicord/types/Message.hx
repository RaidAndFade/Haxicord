package com.raidandfade.haxicord.types;

import com.raidandfade.haxicord.types.structs.MessageStruct.Attachment;
import com.raidandfade.haxicord.types.structs.MessageStruct.Reaction;

import haxe.DateUtils;

//TODO do it properly.
//import com.raidandfade.haxicord.types.structs.Embed;

class Message {

    /**
        The id of this message
     */
    public var id:Snowflake;
    /**
        The id of the channel this message is in
     */
    public var channel_id:Snowflake;
    /**
        The user object of this message's author.
     */
    public var author:User;
    /**
        The message content.
     */
    public var content:String;
    /**
        When the message was sent.
     */
    public var timestamp:Date;
    /**
        Last time the message was edited (or null)
     */
    public var edited_timestamp:Date;
    /**
        Was the message TTS?
     */
    public var tts:Bool;
    /**
        Did the message mention everyone?
     */
    public var mention_everyone:Bool;
    /**
        A list of users that were mentioned in the message.
     */
    public var mentions:Array<User> = new Array<User>();
    /**
        A list of roles that were mentioned in the message.
     */
    public var mention_roles:Array<Role> = new Array<Role>();
    /**
        A list of attachments on this message.
     */
    public var attachments:Array<Attachment> = new Array<Attachment>();
    /**
        A list of embeds on this message.
     */
    public var embeds:Array<Dynamic> = new Array<Dynamic>();
    /**
        A list of reactions on this message.
     */
    public var reactions:Array<Reaction> = new Array<Reaction>();
    /**
        A nonce, only seen when you are the author and have sent a nonce. otherwise Null.
     */
    public var nonce:Snowflake;
    /**
        Is this message pinned?
     */
    public var pinned:Bool;
    /**
        If the message was created by a webhook, this will be the webhook's id
     */
    public var webhook_id:String;

    var client:DiscordClient;

    @:dox(hide)
    public function new(_msg:com.raidandfade.haxicord.types.structs.MessageStruct, _client:DiscordClient) {
        client = _client;

        id = new Snowflake(_msg.id);
        channel_id = new Snowflake(_msg.channel_id);
        author = client._newUser(_msg.author);
        content = _msg.content;

        if(_msg.timestamp != null)
            timestamp = DateUtils.fromISO8601(_msg.timestamp);

        if(_msg.edited_timestamp != null)
            edited_timestamp = DateUtils.fromISO8601(_msg.edited_timestamp);

        tts = _msg.tts;
        mention_everyone = _msg.mention_everyone;

        mentions = [for(u in _msg.mentions) { client._newUser(u); } ];

        mention_roles = [
                for(r in _msg.mention_roles) {
                    cast(client.getChannelUnsafe(_msg.channel_id), GuildChannel).getGuild()._newRole(r);
                }
            ];
        
        if(_msg.attachments != null)
            attachments = _msg.attachments; // maybe live, idk why i would though

        embeds = _msg.embeds;

        if(_msg.reactions != null)
            reactions = _msg.reactions; // same as attachments

        nonce = new Snowflake(_msg.nonce);
        pinned = _msg.pinned;
        webhook_id = _msg.webhook_id;
    }

    @:dox(hide)
    public function _update(_msg:com.raidandfade.haxicord.types.structs.MessageStruct) {
        if(_msg.edited_timestamp != null)
            edited_timestamp = DateUtils.fromISO8601(_msg.edited_timestamp);

        if(_msg.tts != null)
            tts = _msg.tts;

        if(_msg.mention_everyone != null)
            mention_everyone = _msg.mention_everyone;

        if(_msg.mentions != null)
            mentions = [for(u in _msg.mentions) { client._newUser(u); } ];

        if(_msg.mention_roles != null)
            mention_roles = [
                    for(r in _msg.mention_roles) {
                        cast(client.getChannelUnsafe(_msg.channel_id), GuildChannel).getGuild()._newRole(r);
                    }
                ];
        if(_msg.attachments != null)
            attachments = _msg.attachments; // maybe live, idk why i would though

        if(_msg.embeds != null)
            embeds = _msg.embeds;

        if(_msg.reactions != null)
            reactions = _msg.reactions; // same as attachments

        if(_msg.nonce != null)
            nonce = new Snowflake(_msg.nonce);

        if(_msg.pinned != null)
            pinned = _msg.pinned;

        if(_msg.webhook_id != null)
            webhook_id = _msg.webhook_id;
    }

    @:dox(hide)
    public function _addReaction(_u:User, _e) {
        reactions.push({who:_u.id.id, emoji:_e});
    }

    @:dox(hide)
    public function _delReaction(_u:User, _e) {
        reactions = [for (r in reactions) if(!(r.who == _u.id.id && r.emoji == _e)) r];
    }

    @:dox(hide)
    public function _purgeReactions() {
        reactions = new Array<Reaction>();
    }

    /**
        Pin this message
        @param cb - Called once completed. Leave blank to ignore.
     */
    public function pin(cb = null) {
       cast(client.getChannelUnsafe(channel_id.id), MessageChannel).pinMessage(id.id, cb);
    }

    /**
        Unpin this message
        @param cb - Called once completed. Leave blank to ignore.
     */
    public function unpin(cb = null) {
        cast(client.getChannelUnsafe(channel_id.id), MessageChannel).unpinMessage(id.id, cb);
    }

    /**
       Return the channel this message is part of
       @return MessageChannel : The channel this message is part of, either a TextChannel or a DMChannel
     */
    public function getChannel():MessageChannel{
        return cast(client.getChannelUnsafe(channel_id.id), MessageChannel);
    }

    /**
        Return whether this message is in a guild or not.
     */
    public function inGuild():Bool{
        return getChannel().inGuild();
    }

    /**
        If this message was in a guild, get the guildmember object of the member who sent it, otherwise return null.
     */
    public function getMember():Null<GuildMember>{
        if(inGuild())
            return this.getGuild().getMemberUnsafe(author.id.id);
        else
            return null;
    }

    /**
        If this message was in a guild, get the guild object this was sent in, otherwise return null.
     */
    public function getGuild():Null<Guild>{
        if(inGuild())
            return cast(getChannel(), TextChannel).getGuild();
        else
            return null;
    }

    /**
        Send a message to a channel
        @param msg - Message data
        @param cb - Return the message sent, or an error
     */
    public function reply(msg:com.raidandfade.haxicord.endpoints.Typedefs.MessageCreate, cb = null) {
        client.endpoints.sendMessage(channel_id.id, msg, cb);
    }

    /**
        Edit a message previously sent by you.
        @param msg - The new content of the message, all fields are optional.
        @param cb - Return the new message, or an error.
     */
    public function edit(msg, cb = null) {
        client.endpoints.editMessage(channel_id.id, id.id, msg, cb);
    }

    /**
        Delete a given message. If the author is not the current user, the MANAGE_MESSAGES permission is required
        @param cb - Return when complete.
     */
    public function delete(cb = null) {
        client.endpoints.deleteMessage(channel_id.id, id.id, cb);
    }

    /**
        Get all reactions of emoji by user on a message.
        @param e - The emoji to look for.
        @param cb - Returns an array of Reaction objects, or an error.
     */
    public function getReactions(e, cb = null) {
        client.endpoints.getReactions(channel_id.id, id.id, e, cb);
    }

    /**
        Add a reaction to a message. requires READ_MESSAGE_HISTORY and ADD_REACTIONS if the emoji is not already present.
        @param e - The emote to be added, Custom emotes require their TAG.
        @param cb - Called when completed, good for checking for errors.
     */
    public function react(e, cb = null) {
        client.endpoints.createReaction(channel_id.id, id.id, e, cb);
    }

    /**
        Delete a reaction of your own off of a message.
        @param e - The emote to be removed. Custom emotes require their TAG
        @param cb - Called when completed, good for checking for errors.
     */
    public function unreact(e, cb = null) {
        client.endpoints.deleteOwnReaction(channel_id.id, id.id, e, cb);
    }

    /**
        Delete another user's reaction off of a message.
        @param uid - The user to delete the reaction from.
        @param e - The emote to be removed. Custom emotes require their TAG
        @param cb - Called when completed, good for checking for errors.
     */
    public function removeReaction(e, uid, cb = null) {
        client.endpoints.deleteUserReaction(channel_id.id, id.id, uid, e, cb);
    }

    /**
        Delete all reactions from a message. Requires the MANAGE_MESSAGES permission.
        @param cb - Called when completed, good for looking for errors.
     */
    public function removeAllReactions(cb = null) {
        client.endpoints.deleteAllReactions(channel_id.id, id.id, cb);
    }
}
