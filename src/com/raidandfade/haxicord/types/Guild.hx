package com.raidandfade.haxicord.types;
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
    public var channels:Array<GuildChannel>;
    public var presences:Array<Presence>; //https://discordapp.com/developers/docs/topics/gateway#presence-update

    public function new(_guild:com.raidandfade.haxicord.structs.types.Guild,_client:DiscordClient){
        id = new Snowflake(_guild.id);
        if(_guild.exists("unavailable")) unavailable = _guild.unavailable;
        if(!unavailable){
            name = _guild.name;
            icon = _guild.icon;
            splash = _guild.splash;
            owner_id = new Snowflake(_guild.owner_id);
            region = _guild.region;
            afk_timeout = _guild.afk_timeout;
            afk_channel_id = new Snowflake(_guild.afk_channel_id);
            embed_enabled = _guild.embed_enabled
            embed_channel_id = new Snowflake(_guild.embed_channel_id);
            verification_level = _guild.verification_level;
            default_message_notifications = _guild.default_message_notifications;
            roles = [for(r in _guild.roles){new Role(r,client)}];
            emojis = _guild.emojis;
            features = _guild.features;
            mfa_level = _guild.mfa_level;
            if(_guild.exists("joined_at"))joined_at = _guild.joined_at;
            if(_guild.exists("large"))large = _guild.large;
            if(_guild.exists("member_count"))member_count = _guild.member_count;
            if(_guild.exists("members"))members = [for(m in _guild.members){new Member(m.client)}];
            if(_guild.exists("channels"))channels = [for(m in _guild.channels){new GuildChannel(m.client)}];
            if(_guild.exists("presences"))presences = _guild.presences;
        }
    }
}