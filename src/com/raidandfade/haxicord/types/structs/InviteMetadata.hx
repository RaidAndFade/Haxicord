package com.raidandfade.haxicord.types.structs;

class InviteMetadata{
    var inviter:User;
    var uses:Int;
    var max_uses:Int;
    var max_age:Int;
    var temporary:Bool;
    var created_at:Date;
    var revoked:Bool;
}