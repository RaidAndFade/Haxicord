package com.raidandfade.haxicord.types;

import com.raidandfade.haxicord.types.structs.Emoji;
import com.raidandfade.haxicord.types.structs.Presence;

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
    public var roles:Array<Role>;
    public var emojis:Array<Emoji>;
    public var features:Array<String>;// wth is a guild feature?
    public var mfa_level:Int;

    //SENT ON GUILD_CREATE : 

    public var joined_at:Date;
    public var large:Bool;
    public var unavailable:Bool; //if this is true, only this and ID can be set because the guild data could not be received.
    public var member_count:Int;
    public var members:Array<GuildMember>; 
    public var textChannels:Array<TextChannel>;
    public var voiceChannels:Array<VoiceChannel>;
    public var presences:Array<Presence>; //https://discordapp.com/developers/docs/topics/gateway#presence-update

    public function new(_guild:com.raidandfade.haxicord.types.structs.Guild,_client:DiscordClient){
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
            roles = [for(r in _guild.roles){new Role(r,client);}];
            emojis = _guild.emojis;
            features = _guild.features;
            mfa_level = _guild.mfa_level;
            if(_guild.joined_at!=null)joined_at = _guild.joined_at;
            if(_guild.large!=null)large = _guild.large;
            if(_guild.member_count!=null)member_count = _guild.member_count;
            if(_guild.members!=null)members = [for(m in _guild.members){new GuildMember(m,client);}];
            if(_guild.channels!=null)
                for(c in _guild.channels){
                    var ch = Channel.fromStruct(c)(c,client);
                    if(Std.is(ch,TextChannel)){
                        textChannels.push(new TextChannel(c,client));
                    }else{
                        voiceChannels.push(new VoiceChannel(c,client));
                    }
                }
            if(_guild.presences!=null)presences = _guild.presences;
        }
    }
}