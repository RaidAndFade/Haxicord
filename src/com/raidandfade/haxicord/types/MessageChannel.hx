package com.raidandfade.haxicord.types;

interface MessageChannel{
    @:dox(hide)
    public var client:DiscordClient;
    /**
       The ID of the channel.
     */
    public var id:Snowflake;
    /**
       The id of the last Message that was sent in the chat.
     */
    public var last_message_id:Snowflake;
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
        Get the tag for the channel as a string.
     */
    public function getTag():String;

    /**
        Send a message to a channel
        @param mesg - Message data
        @param cb - Return the message sent, or an error
     */
    public function sendMessage(
        mesg:com.raidandfade.haxicord.endpoints.Typedefs.MessageCreate,
        cb:Message->String->Void=null
    ):Void;

    /**
        Get a message in a channel
        @param mid - The message id
        @param cb - Return the message, or an error.
     */
    public function getMessage(
        mid:String,
        cb:Message->String->Void=null
    ):Void;

    /**
        Get messages from a given channel according to the given format.
        @param format - Before, After, or Around. 
        @param cb - The array of messages, or an error.
     */
    public function getMessages(
        format:com.raidandfade.haxicord.endpoints.Typedefs.MessagesRequest=null,
        cb:Array<Message>->String->Void=null
    ):Void;

    /**
        Delete a given message. If the author is not the current user, the MANAGE_MESSAGES permission is required
        @param mid - The id of the message.
        @param cb - Return when complete.
     */
    public function deleteMessage(
        mids:String,
        cb:Dynamic->String->Void=null
    ):Void;

    /**
        Delete a given messages. MANAGE_MESSAGES is required.
        @param ids - an array of id of the messages.
        @param cb - Return when complete.
     */
    public function deleteMessages(
        mids:com.raidandfade.haxicord.endpoints.Typedefs.MessageBulkDelete,
        cb:Dynamic->String->Void=null
    ):Void;

    /**
        Send a typing event in the given channel. This lasts for 10 seconds or when a message is sent, whichever comes first.
        @param cb - Return when complete.
     */
    public function startTyping(
        cb:Dynamic->String->Void=null
    ):Void;

    /**
        Get the pins of a channel
        @param cb - Return an array of pins (or an error)
     */
    public function getPins(
        cb:Array<Message>->String->Void=null
    ):Void;

    /**
        Add a channel pin
        @param mid - The message id
        @param cb - Called once completed. Leave blank to ignore.
     */
    public function pinMessage(
        mid:String,
        cb:Dynamic->String->Void=null
    ):Void;

    /**
        Delete a channel's pin
        @param mid - The pin id
        @param cb - Called once completed. Leave blank to ignore.
     */
    public function unpinMessage(
        mid:String,
        cb:Dynamic->String->Void=null
    ):Void;

    /**
       Returns whether the channel is part of a guild or not. Always true for TextChannels. Always false for DMChannels
     */
    public function inGuild():Bool;

    public function getPermission(uid:String):Int;
    public function hasPermission(uid:String, p:Int):Bool;
}