package com.raidandfade.haxicord.endpoints;

import com.raidandfade.haxicord.types.Snowflake;
import com.raidandfade.haxicord.types.structs.Embed;

typedef Gateway = {
    var url:String;
    @:optional var shards:Int;
}

typedef MessagesRequest = {
    @:optional var around:String;
    @:optional var before:String;
    @:optional var after:String;
    @:optional var limit:Int;
}

typedef MessageCreate = {
    @:optional var content:String;
    @:optional var nonce:Snowflake;
    @:optional var tts:Bool;
    @:optional var file:String; //TODO: ?? how do??
    @:optional var embed:Embed;
}

typedef MessageEdit = {
    @:optional var content:String;
    @:optional var embed:Embed;
}

typedef MessageBulkDelete = {
    var messages: Array<String>;
}

typedef ChannelUpdate = {
    @:optional var name:String; // 2 - 100 chars
    @:optional var position:Int;
    @:optional var topic:String; // text -- 0 - 1024 characters
    @:optional var bitrate:Int; // voice 
    @:optional var user_limit:Int; // voice
}

typedef InviteCreate = {
    @:optional var max_age:Int;
    @:optional var max_uses:Int;
    @:optional var temporary:Bool;
    @:optional var unique:Bool;
}