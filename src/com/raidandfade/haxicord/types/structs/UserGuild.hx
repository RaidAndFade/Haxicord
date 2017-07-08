package com.raidandfade.haxicord.types.structs;

typedef UserGuild = {>Guild,
    var owner:Bool; //Is the user the owner?
    var permissions:Int; //User's permissions
}