package com.raidandfade.haxicord.types.structs;

class Invite {
    var code:String;
    var guild:InviteGuild;
    var channel:InviteChannel;
}

//maybe use a trimmed down version of the actual guild/channel class for these two
class InviteGuild {
    var id:Snowflake;
    var name:String;
    var spash:String;
    var icon:String;
}

class InviteChannel extends Channel {
    var name:String;
}

