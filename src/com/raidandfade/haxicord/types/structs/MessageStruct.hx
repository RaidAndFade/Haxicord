package com.raidandfade.haxicord.types.structs;

typedef MessageStruct = {
    var id:String;
    var channel_id:String;
    var author:User;
    var content:String;
    var timestamp:String;
    var edited_timestamp:String;
    var tts:Bool;
    var mention_everyone:Bool;
    var mentions:Array<User>;
    var mention_roles:Array<Role>;
    var attachments:Array<Attachment>;
    var embeds:Array<Embed>;
    var reactions:Array<Reaction>;
    var nonce:String;
    var pinned:Bool;
    var webhook_id:String;
}

typedef Attachment = { 
    var id:String;
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