package com.raidandfade.haxicord.types;

class NewsChannel extends TextChannel{
    /**
        The topic of the channel.
     */
    public var topic:String;
    /**
       The id of the last Message that was sent in the chat.
     */
    public var last_message_id:Snowflake;

    @:dox(hide)
    public function new(_chan:com.raidandfade.haxicord.types.structs.GuildChannel.NewsChannel, _client:DiscordClient) {
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

    @:dox(hide)
    public function _update(_chan:com.raidandfade.haxicord.types.structs.GuildChannel.NewsChannel) {
        if(_chan.name != null)
            name = _chan.name;

        if(_chan.position != null) 
            position = _chan.position;

        if(_chan.permission_overwrites != null) 
            permission_overwrites = _chan.permission_overwrites;

        if(_chan.topic != null) 
            topic = _chan.topic;

        if(_chan.nsfw != null) 
            nsfw = _chan.nsfw;

        if(_chan.last_message_id != null) 
            last_message_id = new Snowflake(_chan.last_message_id);
    }

    @:dox(hide)
    public static function fromStruct(_chan, _client) {
        return new NewsChannel(_chan, _client);
    }

    //livestruct
    /**
       Returns whether the channel is part of a guild or not. Always true for NewsChannels
     */
    public function inGuild() {
        return true;
    }

    /**
        Send a message to a channel
        @param mesg - Message data
        @param cb - Return the message sent, or an error
     */
    public function sendMessage(mesg, cb = null) {
        client.endpoints.sendMessage(id.id, mesg, cb);
    }
    
    /**
        Get messages from a given channel according to the given format.
        @param format - Before, After, or Around. 
        @param cb - The array of messages, or an error.
     */
    public function getMessages(format = null, cb = null) {
        if(format == null)
            format = {};
        client.endpoints.getMessages(id.id, format, cb);
    }

    /**
        Get a message in a channel
        @param mid - The message id
        @param cb - Return the message, or an error.
     */
    public function getMessage(mid, cb = null) {
        client.endpoints.getMessage(id.id, mid, cb);
    }

    /**
        Delete a given message. If the author is not the current user, the MANAGE_MESSAGES permission is required
        @param mid - The id of the message.
        @param cb - Return when complete.
     */
    public function deleteMessage(mid, cb = null) {
        client.endpoints.deleteMessage(id.id, mid, cb);
    }

    /**
        Delete a given messages. MANAGE_MESSAGES is required.
        @param ids - an array of id of the messages.
        @param cb - Return when complete.
     */
    public function deleteMessages(ids, cb = null) {
        client.endpoints.deleteMessages(id.id, ids, cb);
    }

    /**
        Send a typing event in the given channel. This lasts for 10 seconds or when a message is sent, whichever comes first.
        @param cb - Return when complete.
     */
    public function startTyping(cb = null) {
        client.endpoints.startTyping(id.id, cb);
    }

    /**
        Get the pins of a channel
        @param cb - Return an array of pins (or an error)
     */
    public function getPins(cb = null) {
        client.endpoints.getChannelPins(id.id, cb);
    }

    /**
        Add a channel pin
        @param mid - The message
        @param cb - Called once completed. Leave blank to ignore.
     */
    public function pinMessage(mid, cb = null) {
        client.endpoints.addChannelPin(id.id, mid, cb);
    }

    /**
        Delete a channel's pin
        @param mid - The pin id
        @param cb - Called once completed. Leave blank to ignore.
     */
    public function unpinMessage(mid, cb = null) {
        client.endpoints.deleteChannelPin(id.id, mid, cb);
    }   
}
