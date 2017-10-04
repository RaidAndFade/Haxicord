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

    /**
        Give a role to a member. Requires the MANAGE_ROLES permission
        @param rid - The id of the role desired to be added.
        @param cb - Called on completion, useful for checking for errors.
     */
    public function addRole(rid:String,cb=null){
        client.endpoints.giveMemberRole(guild.id.id,user.id.id,rid,cb);
    }

    /**
        Take a role away from a member. Requires the MANAGE_ROLES permission
        @param rid - The id of the role to take away.
        @param cb - Called on completion, useful for checking for errors.
     */
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

    /**
        Edit a guild member's properties, requires various permissions depending on the data provided. 
        @param data - The updated data, all parameters are optional. All parameters require a different permission.
        @param cb - Called on completion, useful for checking for errors.
     */
    public function edit(data,cb=null){
        client.endpoints.editGuildMember(guild.id.id,user.id.id,data,cb);
    }

    /**
        Change this user's nickname.
        @param s - The nickname to change to.
        @param cb - Returns the nickname, or an error.
     */
    public function changeNickname(s,cb=null){
        guild.changeNickname(s,this,cb);
    }

    /**
        Kick a member from the guild. Requires the KICK_MEMBERS permission
        @param cb - Called on completion, useful for checking for errors.
     */
    public function kick(cb=null){
        client.endpoints.kickMember(guild.id.id,user.id.id,cb);
    }

    /**
        Ban a member of the guild. Requires the BAN_MEMBERS permission.
        @param days - Number of days (from 0-7) to remove the user's messages server wide.
        @param cb - Called on completion, useful for checking for errors.
     */
    public function ban(days=0,cb=null){
        client.endpoints.banMember(guild.id.id,user.id.id,days,cb);
    }
}
