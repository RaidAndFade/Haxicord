package com.raidandfade.haxicord.types.structs;

typedef GuildChannel = {>Channel,
    var guild_id:Int; //flake
    var name:String;
    var position:Int;
    var permission_overwrites:Array<Overwrite>;
}

typedef TextChannel = {>GuildChannel,
    var topic:String;
    var last_message_id:Int; //flake 
}

typedef VoiceChannel = {>GuildChannel,
    var bitrate:Int;
    var user_limit:Int;
}

enum OverwriteType{
    Role;
    Member;
}

typedef Overwrite = {
    var id:Int; //flake
    var type:OverwriteType;
    var allow:Int;
    var deny:Int;
}