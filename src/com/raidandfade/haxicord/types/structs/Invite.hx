package com.raidandfade.haxicord.types.structs;

typedef Invite = {
    @:optional var approximate_presence_count:Int;
    @:optional var approximate_member_count:Int;
    var code:String;
    var guild:InviteGuild;
    var channel:InviteChannel;
}

//maybe use a trimmed down version of the actual guild/channel class for these two
typedef InviteGuild = {
    var id:Snowflake;
    var name:String;
    var spash:String;
    var icon:String;
    @:optional var text_channel_count:Int;
    @:optional var voice_channel_count:Int;
}

typedef InviteChannel = {>Channel,
    var name:String;
}

