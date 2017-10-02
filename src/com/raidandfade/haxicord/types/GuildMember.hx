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
    public var guild:Guild;

    public function new(_mem:com.raidandfade.haxicord.types.structs.GuildMember,_guild:Guild,_client:DiscordClient){
        client = _client;
        guild = _guild;
        
        user = client._newUser(_mem.user);
        nick = _mem.nick;
        roles = _mem.roles; //TODO Make this role objects.
        joined_at = DateUtils.fromISO8601(_mem.joined_at);
        deaf = _mem.deaf;
        mute = _mem.mute;
    }

    public function _update(_mem:com.raidandfade.haxicord.types.structs.GuildMember){
        if(_mem.user!=null) user = client._newUser(_mem.user);
        if(_mem.nick!=null) nick = _mem.nick;
        if(_mem.roles!=null) roles = _mem.roles;
    }

    public function _updatePresence(_pre:com.raidandfade.haxicord.types.structs.Presence){
        if(_pre.nick!=null) nick = _pre.nick;
        if(_pre.roles!=null) roles = _pre.roles;
        if(_pre.game!=null) user.game = _pre.game;
    }

    //Live funcs
    public function addRole(rid:String,cb=null){
        client.endpoints.giveMemberRole(guild.id.id,user.id.id,rid,cb);
    }

    public function removeRole(rid:String,cb=null){
        client.endpoints.takeMemberRole(guild.id.id,user.id.id,rid,cb);
    }

    public function hasRole(rid:String){
        for(r in roles){
            if(r == rid)
                return true;
        }
        return false;
    }

    public function edit(data,cb=null){
        client.endpoints.editGuildMember(guild.id.id,user.id.id,data,cb);
    }

    public function changeNickname(s,cb=null){
        guild.changeNickname(s,this,cb);
    }

    public function kick(cb=null){
        client.endpoints.kickMember(guild.id.id,user.id.id,cb);
    }

    public function ban(days=0,cb=null){
        client.endpoints.banMember(guild.id.id,user.id.id,days,cb);
    }
}