package com.raidandfade.haxicord.types.structs;

typedef DMChannel = {>Channel,
    var recipient:User;
    var last_message_id:String;
}