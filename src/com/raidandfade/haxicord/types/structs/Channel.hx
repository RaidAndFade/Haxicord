package com.raidandfade.haxicord.types.structs;

enum ChannelType{
    Text;
    Voice;
    DirectMessage;
}

class Channel{
    var id:Snowflake;
    var is_private:Bool;
    var type:ChannelType;
}