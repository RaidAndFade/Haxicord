package com.raidandfade.haxicord.types.structs;

class Presence {
    var idle_since:Int;
    var game:PresenceGame;
}

class PresenceGame {
    var name:String;
}