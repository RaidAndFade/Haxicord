package com.raidandfade.haxicord.types.structs;

typedef DMChannel = {>Channel,
    @:optional var recipient:User;
    @:optional var recipients:Array<User>;
    @:optional var last_message_id:String;
}