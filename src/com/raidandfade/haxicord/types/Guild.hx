package com.raidandfade.haxicord.types;

import com.raidandfade.haxicord.types.structs.Emoji;
import com.raidandfade.haxicord.types.structs.Presence;

import haxe.DateUtils;

class Guild{
    var client:DiscordClient;

    public var id:Snowflake;
    public var name:String; //2-100chars
    public var icon:String; //Image hash
    public var splash:String; //splash hash
    public var owner_id:Snowflake;
    public var region:String; // voice_region.id
    public var afk_channel_id:Snowflake;
    public var afk_timeout:Int;
    public var embed_enabled:Bool; //Widgetable?
    public var embed_channel_id:Snowflake; //What channel is widgetted?
    public var verification_level:Int;
    public var default_message_notifications:Int;
    public var roles:Map<String,Role> = new Map<String,Role>();
    public var emojis:Array<Emoji> = new Array<Emoji>();
    public var features:Array<String> = new Array<String>();// wth is a guild feature?
    public var mfa_level:Int;

    //SENT ON GUILD_CREATE : 

    public var joined_at:Date;
    public var large:Bool;
    public var unavailable:Bool; //if this is true, only this and ID can be set because the guild data could not be received.
    public var member_count:Int;
    public var members:Map<String,GuildMember> = new Map<String,GuildMember>(); 
    public var textChannels:Map<String,TextChannel> = new Map<String,TextChannel>();
    public var voiceChannels:Map<String,VoiceChannel> = new Map<String,VoiceChannel>();
    public var presences:Array<Presence>; //https://discordapp.com/developers/docs/topics/gateway#presence-update

    public var nextChancb:GuildChannel->Void;

    //live variables
    public var bans:Array<User> = new Array<User>();
    public var owner:GuildMember;

    public function new(_guild:com.raidandfade.haxicord.types.structs.Guild,_client:DiscordClient){
        client = _client;

        id = new Snowflake(_guild.id);
        if(_guild.unavailable!=null) unavailable = _guild.unavailable;
        if(!unavailable){
            name = _guild.name;
            icon = _guild.icon;
            splash = _guild.splash;
            owner_id = new Snowflake(_guild.owner_id);
            region = _guild.region;
            afk_timeout = _guild.afk_timeout;
            afk_channel_id = new Snowflake(_guild.afk_channel_id);
            embed_enabled = _guild.embed_enabled;
            embed_channel_id = new Snowflake(_guild.embed_channel_id);
            verification_level = _guild.verification_level;
            default_message_notifications = _guild.default_message_notifications;
            for(r in _guild.roles){
                _newRole(r);
            }
            emojis = _guild.emojis;
            features = _guild.features;
            mfa_level = _guild.mfa_level;
            if(_guild.joined_at!=null)joined_at = DateUtils.fromISO8601(_guild.joined_at);
            if(_guild.large!=null)large = _guild.large;
            if(_guild.member_count!=null)member_count = _guild.member_count;
            if(_guild.members!=null) for(m in _guild.members){_newMember(m);}
            owner = members[owner_id.id];
            if(_guild.channels!=null)
                for(c in _guild.channels){
                    var ch = cast(_client._newChannel(c),GuildChannel);
                    if(Std.is(ch,TextChannel)){
                        textChannels.set(ch.id.id,cast(ch,TextChannel));
                    }else{
                        voiceChannels.set(ch.id.id,cast(ch,VoiceChannel));
                    }
                }
            if(_guild.presences!=null) presences = _guild.presences;
        }
    }

    public function _update(_guild:com.raidandfade.haxicord.types.structs.Guild.Update){
        if(_guild.unavailable!=null) unavailable = _guild.unavailable;
        if(!unavailable){
            if(_guild.name!=null) name = _guild.name;
            if(_guild.icon!=null) icon = _guild.icon;
            if(_guild.splash!=null) splash = _guild.splash;
            if(_guild.owner_id!=null) owner_id = new Snowflake(_guild.owner_id);
            if(_guild.region!=null) region = _guild.region;
            if(_guild.afk_timeout!=null) afk_timeout = _guild.afk_timeout;
            if(_guild.afk_channel_id!=null) afk_channel_id = new Snowflake(_guild.afk_channel_id);
            if(_guild.embed_enabled!=null) embed_enabled = _guild.embed_enabled;
            if(_guild.embed_channel_id!=null) embed_channel_id = new Snowflake(_guild.embed_channel_id);
            if(_guild.verification_level!=null) verification_level = _guild.verification_level;
            if(_guild.default_message_notifications!=null) default_message_notifications = _guild.default_message_notifications;
            if(_guild.roles!=null) 
            for(r in _guild.roles){
                _newRole(r);
            }
            if(_guild.emojis!=null) emojis = _guild.emojis;
            if(_guild.features!=null) features = _guild.features;
            if(_guild.mfa_level!=null) mfa_level = _guild.mfa_level;
            if(_guild.joined_at!=null)joined_at = DateUtils.fromISO8601(_guild.joined_at);
            if(_guild.large!=null)large = _guild.large;
            if(_guild.member_count!=null)member_count = _guild.member_count;
            if(_guild.members!=null) for(m in _guild.members){_newMember(m);}
            if(_guild.channels!=null)
                for(c in _guild.channels){
                    var ch = cast(client._newChannel(c),GuildChannel);
                    if(Std.is(ch,TextChannel)){
                        textChannels.set(ch.id.id,cast(ch,TextChannel));
                    }else{
                        voiceChannels.set(ch.id.id,cast(ch,VoiceChannel));
                    }
                }
            if(_guild.presences!=null) presences = _guild.presences;
        }
    }

    public function _updateEmojis(e:Array<com.raidandfade.haxicord.types.structs.Emoji>){
        emojis=e;
    }

    public function _addChannel(c){
        if(nextChancb!=null){nextChancb(c);nextChancb=function(c){};}
        if(c.type==0)
            textChannels.set(c.id.id,cast(c,TextChannel));
        else
            voiceChannels.set(c.id.id,cast(c,VoiceChannel));
    }

    public function _addBan(user){
        bans.push(user);
    }

    public function _removeBan(user){
        bans.remove(user);
    }

    public function _newMember(memberStruct:com.raidandfade.haxicord.types.structs.GuildMember){
        if(members.exists(memberStruct.user.id)){
            members.get(memberStruct.user.id)._update(memberStruct);
            return members.get(memberStruct.user.id);
        }else{
            var member = new GuildMember(memberStruct,client);
            members.set(memberStruct.user.id,member);
            return members.get(memberStruct.user.id);
        }
    }

    public function _newRole(roleStruct:com.raidandfade.haxicord.types.structs.Role){
        if(roles.exists(roleStruct.id)){
            roles.get(roleStruct.id)._update(roleStruct);
            return roles.get(roleStruct.id);
        }else{
            var role = new Role(roleStruct,client);
            roles.set(roleStruct.id,role);
            return roles.get(roleStruct.id);
        }
    }
    //Live structs

    public function delete(cb=null){
        client.endpoints.deleteGuild(id.id,cb);
    }

    public function createChannel(cs,cb:GuildChannel->String->Void=null){
        client.endpoints.createChannel(id.id,cs,function(c,e){
            if(e!=null)cb(null,e);
            else nextChancb = function(c){cb(c,null);};
        });
    }

    public function createRole(rs,cb=null){
        client.endpoints.createRole(id.id,rs,cb); 
    }

    public function addRole(m:GuildMember,r:Role,cb=null){
        client.endpoints.giveMemberRole(id.id,m.user.id.id,r.id.id,cb);
    }

    public function removeRole(m:GuildMember,r:Role,cb=null){
        client.endpoints.takeMemberRole(id.id,m.user.id.id,r.id.id,cb);
    }

    public function changeNickname(s:String,m:GuildMember=null,cb=null){
        if(m==null||m.user.id.id==client.user.id.id)
            client.endpoints.changeNickname(id.id,s,cb);
        else
            client.endpoints.editGuildMember(id.id,m.user.id.id,{nick:s},cb);
    }

    public function getChannel(id,cb:Channel->Void=null){
        client.getChannel(id,cb);
    }
}