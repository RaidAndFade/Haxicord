package com.raidandfade.haxicord.types.structs;

typedef Invite = {
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
}

typedef InviteChannel = {>Channel,
    var name:String;
}

