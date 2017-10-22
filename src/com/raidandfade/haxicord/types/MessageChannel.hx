package com.raidandfade.haxicord.types;

interface MessageChannel{
    public var client:DiscordClient;
    public var id:Snowflake;
    public var last_message_id:Snowflake;
    public var type:Int;

    public function getTag():String;

    public function sendMessage(
        mesg:com.raidandfade.haxicord.endpoints.Typedefs.MessageCreate,
        cb:Message->String->Void=null
    ):Void;

    public function getMessage(
        mid:String,
        cb:Message->String->Void=null
    ):Void;

    public function getMessages(
        format:com.raidandfade.haxicord.endpoints.Typedefs.MessagesRequest=null,
        cb:Array<Message>->String->Void=null
    ):Void;

    public function deleteMessage(
        mids:String,
        cb:Dynamic->String->Void=null
    ):Void;

    public function deleteMessages(
        mids:com.raidandfade.haxicord.endpoints.Typedefs.MessageBulkDelete,
        cb:Dynamic->String->Void=null
    ):Void;

    public function startTyping(
        cb:Dynamic->String->Void=null
    ):Void;

    public function getPins(
        cb:Array<Message>->String->Void=null
    ):Void;

    public function pinMessage(
        mid:String,
        cb:Dynamic->String->Void=null
    ):Void;

    public function unpinMessage(
        mid:String,
        cb:Dynamic->String->Void=null
    ):Void;

    public function inGuild():Bool;
}