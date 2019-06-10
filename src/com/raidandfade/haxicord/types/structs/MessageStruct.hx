package com.raidandfade.haxicord.types.structs;

typedef MessageStruct = {
    var id:String;
    var channel_id:String;
    @:optional var author:User;
    @:optional var content:String;
    @:optional var timestamp:String;
    @:optional var edited_timestamp:String;
    @:optional var tts:Bool;
    @:optional var mention_everyone:Bool;
    @:optional var mentions:Array<User>;
    @:optional var mention_roles:Array<String>;
    @:optional var attachments:Array<Attachment>;
    @:optional var embeds:Array<Embed>;
    @:optional var reactions:Array<Reaction>;
    @:optional var nonce:String;
    @:optional var pinned:Bool;
    @:optional var webhook_id:String;
    @:optional var type:Int;
    @:optional var activity:MessageActivity;
    @:optional var application:MessageApplication;

}

typedef MessageActivity = {
    var type:Int;
    var party_id:String;
}
typedef MessageApplication = {
    var id:String;
    var cover_image:String;
    var description:String;
    var icon:String;
    var name:String;
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
    @:optional var count:Int;
    @:optional var me:Bool;
    @:optional var who:String;
    var emoji:Emoji;
}