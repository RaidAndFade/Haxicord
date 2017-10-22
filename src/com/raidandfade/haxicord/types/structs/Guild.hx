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
    var explicit_content_filter:Int;
    var roles:Array<Role>;
    var emojis:Array<Emoji>;
    var features:Array<String>;// wth is a guild feature?
    var mfa_level:Int;

    //SENT ON GUILD_CREATE : 

    @:optional var joined_at:String;
    @:optional var large:Bool;
    @:optional var unavailable:Bool; //if this is true, only this and ID can be set because the guild data could not be received.
    @:optional var member_count:Int;
    @:optional var members:Array<GuildMember>; 
    @:optional var channels:Array<GuildChannelTypes>;
    @:optional var presences:Array<Presence>; //https://discordapp.com/developers/docs/topics/gateway#presence-update
}

typedef Update = {
    var id:String;
    @:optional var name:String; //2-100chars
    @:optional var icon:String; //Image hash
    @:optional var splash:String; //splash hash
    @:optional var owner_id:String;
    @:optional var region:String; // voice_region.id
    @:optional var afk_channel_id:String;
    @:optional var afk_timeout:Int;
    @:optional var embed_enabled:Bool; //Widgetable?
    @:optional var embed_channel_id:String; //What channel is widgetted?
    @:optional var verification_level:Int;
    @:optional var default_message_notifications:Int;
    @:optional var roles:Array<Role>;
    @:optional var emojis:Array<Emoji>;
    @:optional var features:Array<String>;// wth is a guild feature?
    @:optional var mfa_level:Int;

    //SENT ON GUILD_CREATE : 

    @:optional var joined_at:String;
    @:optional var large:Bool;
    @:optional var unavailable:Bool; //if this is true, only this and ID can be set because the guild data could not be received.
    @:optional var member_count:Int;
    @:optional var members:Array<GuildMember>; 
    @:optional var channels:Array<GuildChannelTypes>;
    @:optional var presences:Array<Presence>; //https://discordapp.com/developers/docs/topics/gateway#presence-update
}

typedef GuildChannelTypes = EitherType < GuildChannel.TextChannel , GuildChannel.VoiceChannel >