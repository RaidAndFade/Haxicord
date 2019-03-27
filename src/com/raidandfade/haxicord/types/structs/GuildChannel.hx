package com.raidandfade.haxicord.types.structs;

typedef GuildChannel = {>Channel,
    var guild_id:String; //flake
    @:optional var nsfw:Bool;
    @:optional var parent_id:String;
    @:optional var name:String;
    @:optional var position:Int;
    @:optional var permission_overwrites:Array<Overwrite>;
}

typedef TextChannel = {>GuildChannel,
    @:optional var topic:String;
    @:optional var last_message_id:String; //flake 
    @:optional var rate_limit_per_user:Int; //Text channel ratelimiting (the slow mode thing)
    @:optional var last_pin_timestamp:String;
}

typedef VoiceChannel = {>GuildChannel,
    @:optional var bitrate:Int;
    @:optional var user_limit:Int;
}

typedef NewsChannel = {>TextChannel,} // why the fuck is this it's own type? I wish i fucking knew.

typedef StoreChannel = {>GuildChannel,} // why the fuck is this it's own type? I wish i fucking knew.

enum OverwriteType{
    Role;
    Member;
}

typedef Overwrite = {
    var id:String; //flake
    var type:OverwriteType;
    var allow:Int;
    var deny:Int;
}