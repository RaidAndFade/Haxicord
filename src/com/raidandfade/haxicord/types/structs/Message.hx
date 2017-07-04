package com.raidandfade.haxicord.types.structs;

class Message {
    var id:Snowflake;
    var channel_id:Snowflake;
    var author:User;
    var content:String;
    var timestamp:Date;
    var edited_timestamp:Date;
    var tts:Bool;
    var mention_everyone:Bool;
    var mentions:Array<User>;
    var mention_roles:Array<Role>;
    var attachments:Array<Attachment>;
    var embeds:Array<Embed>;
    var reactions:Array<Reaction>;
    var nonce:Snowflake;
    var pinned:Bool;
    var webhook_id:String;
}

class Attachment { 
    var id:Snowflake;
    var filename:String;
    var size:Int;
    var url:String;
    var proxy_url:String;
    var height:Int;
    var width:Int;
}

//Might have to make separate classes for these two at some point. hope not.
class Reaction {
    var count:Int;
    var me:Bool;
    var emoji:Emoji;
}