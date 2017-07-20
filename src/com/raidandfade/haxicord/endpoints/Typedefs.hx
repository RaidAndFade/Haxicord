package com.raidandfade.haxicord.endpoints;

import com.raidandfade.haxicord.types.Snowflake;
import com.raidandfade.haxicord.types.structs.Embed;
import com.raidandfade.haxicord.types.structs.Role;

typedef Gateway = {
    var url:String;
    @:optional var shards:Int;
}

typedef MessagesRequest = {
    @:optional var around:String;
    @:optional var before:String;
    @:optional var after:String;
    @:optional var limit:Int;
}

typedef MessageCreate = {
    @:optional var content:String;
    @:optional var nonce:Snowflake;
    @:optional var tts:Bool;
    @:optional var file:String; //TODO: ?? how do??
    @:optional var embed:Embed;
}

typedef MessageEdit = {
    @:optional var content:String;
    @:optional var embed:Embed;
}

typedef MessageBulkDelete = {
    var messages: Array<String>;
}

typedef ChannelCreate = {
    var name:String; // 2 - 100 chars
    @:optional var type:String;
    @:optional var topic:String; // text -- 0 - 1024 characters
    @:optional var bitrate:Int; // voice 
    @:optional var user_limit:Int; // voice
}

typedef ChannelUpdate = {
    @:optional var name:String; // 2 - 100 chars
    @:optional var position:Int;
    @:optional var topic:String; // text -- 0 - 1024 characters
    @:optional var bitrate:Int; // voice 
    @:optional var user_limit:Int; // voice
}

typedef GuildCreate = {
    var name:String;
    var region:String;
    var icon:String;
    var verification_level:Int;
    var default_message_notifications:Int;
    var roles:Array<Role>;
    var channels:Array<ChannelCreate>;
}

typedef GuildUpdate = {
    @:optional var name:String;
    @:optional var region:String;
    @:optional var verification_level:Int;
    @:optional var default_message_notifications:Int;
    @:optional var afk_channel_id:String;
    @:optional var afk_timeout:String;
    @:optional var icon:String;
    @:optional var owner_id:String;
    @:optional var splash:String;
}

typedef PositionChange = Array<Position>;

typedef Position = {
    var id:String;
    var position:Int;
}

typedef ListGuildMember = {
    @:optional var limit:Int;
    @:optional var after:String;    
}

typedef AddGuildMember = {
    var access_token:String;
    @:optional var nick:String;         //requires MANAGE_NICKNAMES
    @:optional var roles:Array<String>; //requires MANAGE_ROLES     -- roles snowflakes
    @:optional var mute:Bool;           //requires MUTE_MEMBERS
    @:optional var deaf:Bool;           //requires DEAFEN_MEMBERS
}

typedef EditGuildMember = {
    @:optional var nick:String;         //requires MANAGE_NICKNAMES
    @:optional var roles:Array<String>; //requires MANAGE_ROLES     -- roles snowflakes
    @:optional var mute:Bool;           //requires MUTE_MEMBERS
    @:optional var deaf:Bool;           //requires DEAFEN_MEMBERS
    @:optional var channel_id:String;   //requires MOVE_MEMBERS     -- Move the user to a differend voice channel
}

typedef RoleInfo = {
    @:optional var name:String;
    @:optional var permissions:Int;
    @:optional var color:Int;
    @:optional var hoist:Bool;
    @:optional var mentionable:Bool;
}

typedef InviteCreate = {
    @:optional var max_age:Int;
    @:optional var max_uses:Int;
    @:optional var temporary:Bool;
    @:optional var unique:Bool;
}

typedef GetGuildFilter = {
    @:optional var before:String;
    @:optional var after:String;
    @:optional var limit:Int;
}

typedef IntegrationCreate = {
    var type:String;
    var id:String;
}

typedef IntegrationModify = {
    @:optional var expire_behavior:Int;
    @:optional var expire_grace_period:Int;
    @:optional var enable_emoticons:Int;
}

typedef CreateGroupDM = {
    var access_tokens:Array<String>;
    var nicks:Map<String,String>;
}

typedef WebhookMessage = {
    @:optional var content:String;
    @:optional var username:String;
    @:optional var avatar_url:String;
    @:optional var tts:Bool;
    @:optional var file:String;
    @:optional var embeds:Array<Embed>;
}