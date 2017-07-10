package com.raidandfade.haxicord.types;

import haxe.DateUtils;

class GuildMember {
    var client:DiscordClient;

    public var user:User;
    public var nick:Null<String>;
    public var roles:Array<String>;
    public var joined_at:Date;
    public var deaf:Bool;
    public var mute:Bool;

    public function new(_mem:com.raidandfade.haxicord.types.structs.GuildMember,_client:DiscordClient){
        client = _client;
        
        user = client.newUser(_mem.user);
        nick = _mem.nick;
        roles = _mem.roles;
        joined_at = DateUtils.fromISO8601(_mem.joined_at);
        deaf = _mem.deaf;
        mute = _mem.mute;
    }

    public function update(_mem:com.raidandfade.haxicord.types.structs.GuildMember){
        if(_mem.user!=null) user = client.newUser(_mem.user);
        if(_mem.nick!=null) nick = _mem.nick;
        if(_mem.roles!=null) roles = _mem.roles;
    }
}