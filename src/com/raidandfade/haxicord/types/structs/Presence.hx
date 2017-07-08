package com.raidandfade.haxicord.types.structs;

typedef Presence = {
    var idle_since:Int;
    var game:PresenceGame;
}

typedef PresenceGame = {
    var name:String;
}