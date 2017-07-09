package com.raidandfade.haxicord.types.structs;

typedef VoiceState = {
    var guild_id:String;
    var channel_id:String;
    var user_id:String;
    var session_id:String;
    var deaf:Bool;
    var mute:Bool;
    var self_deaf:Bool;
    var self_mute:Bool;
    var suppress:Bool;
}

typedef VoiceRegion = {
    var id:String;
    var name:String;
    var sample_hostname:String;
    var sample_port:Int;
    var vip:Bool;
    var optimal:Bool;
    var deprecated:Bool;
    var custom:Bool;
}