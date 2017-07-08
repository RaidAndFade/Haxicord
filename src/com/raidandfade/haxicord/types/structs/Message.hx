package com.raidandfade.haxicord.types.structs;

typedef Message = {
    var id:Snowflake;
    var channel_id:Snowflake;
    var author:User;
    var content:String;
    var timestamp:Float;
    var edited_timestamp:Float;
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

typedef Attachment = { 
    var id:Snowflake;
    var filename:String;
    var size:Int;
    var url:String;
    var proxy_url:String;
    var height:Int;
    var width:Int;
}

typedef Reaction = {
    var count:Int;
    var me:Bool;
    var emoji:Emoji;
}