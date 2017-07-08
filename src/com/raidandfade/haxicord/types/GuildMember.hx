package com.raidandfade.haxicord.types;

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

        user = new User(_mem.user,_client);
        nick = _mem.nick;
        roles = _mem.roles;
        joined_at = Date.fromTime(_mem.joined_at*1000);
        deaf = _mem.deaf;
        mute = _mem.mute;
    }
}