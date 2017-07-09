package com.raidandfade.haxicord.types.structs;

import haxe.extern.EitherType;

typedef Guild = {
    var id:String;
    var name:String; //2-100chars
    var icon:String; //Image hash
    var splash:String; //splash hash
    var owner_id:String;
    var region:String; // voice_region.id
    var afk_channel_id:String;
    var afk_timeout:Int;
    var embed_enabled:Bool; //Widgetable?
    var embed_channel_id:String; //What channel is widgetted?
    var verification_level:Int;
    var default_message_notifications:Int;
    var roles:Array<Role>;
    var emojis:Array<Emoji>;
    var features:Array<String>;// wth is a guild feature?
    var mfa_level:Int;

    //SENT ON GUILD_CREATE : 

    var joined_at:Date;
    var large:Bool;
    var unavailable:Bool; //if this is true, only this and ID can be set because the guild data could not be received.
    var member_count:Int;
    var members:Array<GuildMember>; 
    var channels:Array<GuildChannelTypes>;
    var presences:Array<Presence>; //https://discordapp.com/developers/docs/topics/gateway#presence-update
}

typedef GuildChannelTypes = EitherType < GuildChannel.TextChannel , GuildChannel.VoiceChannel >