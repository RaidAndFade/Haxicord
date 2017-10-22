package com.raidandfade.haxicord.endpoints;

import com.raidandfade.haxicord.types.Snowflake;
import com.raidandfade.haxicord.types.structs.Embed;
import com.raidandfade.haxicord.types.structs.Role;
import com.raidandfade.haxicord.types.structs.AuditLog.AuditLogEvent;
import com.raidandfade.haxicord.types.structs.GuildChannel.Overwrite;

typedef Gateway = {
    /**
        The url that is suggested.
     */
    var url:String;
    /**
        The number of shards suggested (will only be there for bots)
     */
    @:optional var shards:Int;
}

typedef MessagesRequest = {
    /**
        Get messages around this ID
     */
    @:optional var around:String;
    /**
        Get messages before this ID
     */
    @:optional var before:String;
    /**
        Get messages after this ID
     */
    @:optional var after:String;
    /**
     *  Max number of messages to return, (1-100 default 50)
     */
    @:optional var limit:Int;
}

typedef MessageEdit = {
    /**
        The new message contents (up to 2000 characters)
     */
    @:optional var content:String;
    /**
        Rich embed content.
     */
    @:optional var embed:Embed;
}

typedef MessageCreate = {
    /**
        The message content (Up to 2000 characters)
     */
    @:optional var content:String;
    /**
        A rich embed.
     */
    @:optional var embed:Embed;
    /**
        You really don't need this. This will be returned on the new message object.
     */
    @:optional var nonce:Snowflake;
    /**
        Whether the message is TTS or not.
     */
    @:optional var tts:Bool;
    @:optional var file:String; //TODO: ?? how do??
}

typedef MessageBulkDelete = {
    var messages: Array<String>;
}

typedef ChannelCreate = {
    /**
        The name of the new channel, 2 to 100 characters.
     */
    var name:String; // 2 - 100 chars
    /**
        The channel type ("voice" or "text")
     */
    @:optional var type:String;
    /**
        The ID of the category to add the channel to
    */
    @:optional var parent_id:String;
    /**
        Whether the channel is NSFW or not
    */
    @:optional var nsfw:Bool;
    /**
        An array of overwrites to start the channel off with.
     */
    @:optional var permission_overwrites:Array<Overwrite>;
    /**
        The channel topic. 0 to 1024 characters.
     */
    @:optional var topic:String; // text -- 0 - 1024 characters
    /**
        Bitrate (only for voice)
     */
    @:optional var bitrate:Int; // voice 
    /**
        User limit (only for voice)
     */
    @:optional var user_limit:Int; // voice
}

typedef ChannelUpdate = {
    /**
        The new name of the channel, 2 to 100 characters.
     */
    @:optional var name:String; // 2 - 100 chars
    /**
       the position of the channel in the left-hand listing
     */
    @:optional var position:Int;
    /**
        The ID of the category to add the channel to
    */
    @:optional var parent_id:String;
    /**
        Whether the channel is NSFW or not
    */
    @:optional var nsfw:Bool;
    /**
        An array of overwrites to start the channel off with.
     */
    @:optional var permission_overwrites:Array<Overwrite>;
    /**
        The channel topic. 0 to 1024 characters.
     */
    @:optional var topic:String; // text -- 0 - 1024 characters
    /**
        Bitrate (only for voice)
     */
    @:optional var bitrate:Int; // voice 
    /**
        User limit (only for voice)
     */
    @:optional var user_limit:Int; // voice
}

typedef GuildCreate = {
    /**
        Name of the guild. (2-100 characters)
     */
    var name:String;
    /**
        Voice region to create the guild in.
     */
    var region:String;
    /**
        128x128 base64 image for the guild icon.
     */
    var icon:String;
    /**
        Guild verification level
    */
    var verification_level:Int;
    /**
        Default message notifications setting
    */
    var default_message_notifications:Int;
    /**
        New guild roles.
    */
    var roles:Array<Role>;
    /**
        New guild channels
    */
    var channels:Array<ChannelCreate>;
}

typedef GuildUpdate = {
    /**
        Name of the guild. (2-100 characters)
     */
    @:optional var name:String;
    /**
        Voice region to create the guild in.
     */
    @:optional var region:String;
    /**
        128x128 base64 image for the guild icon.
     */
    @:optional var icon:String;
    /**
        Guild verification level
    */
    @:optional var verification_level:Int;
    /**
        Default message notifications setting
    */
    @:optional var default_message_notifications:Int;
    /**
        ID of the afk voice channel
    */
    @:optional var afk_channel_id:String;
    /**
        Number of seconds before a user is moved to the afk channel
    */
    @:optional var afk_timeout:String;
    /**
        An ID of a user to transfer ownership of the server to (Only works if the current user is owner)
    */
    @:optional var owner_id:String;
    /**
        Base64 128x128 jpeg image for the guild splash (VIP only)
    */
    @:optional var splash:String;
}

typedef PositionChange = Array<Position>;

typedef Position = {
    /**
        Id of the channel/role being moved
    */
    var id:String;
    /**
        The new position
    */
    var position:Int;
}

typedef ListGuildMember = {
    /**
        Max number of members to return (1 to 1000)
    */
    @:optional var limit:Int;
    /**
        Highest user id from the previous page.
    */
    @:optional var after:String;    
}

typedef AddGuildMember = {
    /**
        The Oauth2 access token granted through an oauth link with the `guilds.join` scope.
    */
    var access_token:String;
    /**
        A nickname to set for the user
        Requires MANAGE_NICKNAMES
    */
    @:optional var nick:String;         
    /**
        A list of role ids to assign to the user.
        Requires MANAGE_ROLES
    */
    @:optional var roles:Array<String>; 
    /**
        Start the user off muted
        Requires MUTE_MEMBERS
    */
    @:optional var mute:Bool;           
    /**
        Start the user off deafened
        Requires DEAFEN_MEMBERS
    */
    @:optional var deaf:Bool;           
}

typedef EditGuildMember = {
        /**
        A nickname to set for the user
        Requires MANAGE_NICKNAMES
    */
    @:optional var nick:String;         
    /**
        A list of role ids to assign to the user.
        Requires MANAGE_ROLES
    */
    @:optional var roles:Array<String>; 
    /**
        Start the user off muted
        Requires MUTE_MEMBERS
    */
    @:optional var mute:Bool;           
    /**
        Start the user off deafened
        Requires DEAFEN_MEMBERS
    */
    @:optional var deaf:Bool;    
    /**
        Move the member to a different voice channel.
        Only works if the user is connected to voice.
        Requires MOVE_MEMBERS
     */
    @:optional var channel_id:String;
}

typedef RoleInfo = {
    /**
        The name of the role (Default : "new role")
     */
    @:optional var name:String;
    /**
        The permissions bitwise int. (Default : Same as @everyone role)
     */
    @:optional var permissions:Int;
    /**
        The RGB color value. (Default : none)
    */
    @:optional var color:Int;
    /**
        Should the role be displayed separately? (Default : False)
    */
    @:optional var hoist:Bool;
    /**
        Should the role be mentionable? (Default : False)
    */
    @:optional var mentionable:Bool;
}

typedef InviteCreate = {
    /**
        Duration of invite in seconds before expiry, or 0 for never (Default 86400 (or 24h))
     */
    @:optional var max_age:Int;
    /**
        Max number of uses or 0 for unlimited (Default 0)
     */
    @:optional var max_uses:Int;
    /**
        Whether this invite only grants temporary membership (Default False)
     */
    @:optional var temporary:Bool;
    /**
        If true, don't try to reuse a similar invite (useful for creating many unique one time use invites) (Default False)
     */
    @:optional var unique:Bool;
}

typedef GetGuildFilter = {
    /**
        Get guilds before this guild ID
     */
    @:optional var before:String;
    /**
        Get guilds after this guild ID
     */
    @:optional var after:String;
    /**
        Max number of guilds to return (1 to 100, Default 100)
     */
    @:optional var limit:Int;
}

typedef IntegrationCreate = {
    /**
        The integration type.
     */
    var type:String;
    /**
        The integration id.
     */
    var id:String;
}

typedef IntegrationModify = {
    /**
        The behavior when an integration subscription lapses
     */
    @:optional var expire_behavior:Int;
    /**
        Period (in seconds) where the integration will ignore lapsed subscriptions
     */
    @:optional var expire_grace_period:Int;
    /**
        Whether emoticons should be synced for this integration (twitch only currently)
     */
    @:optional var enable_emoticons:Int;
}

typedef CreateGroupDM = {
    /**
       Access tokens of users that have granted your app the `gdm.join` scope
     */
    var access_tokens:Array<String>;
    /**
       	A dictionary of user ids to their respective nicknames
     */
    var nicks:Map<String,String>;
}

typedef WebhookMessage = {
    /**
        The message contents (up to 2000 characters)
        Every webhook requires at least one of either content, file, or embeds.
     */
    @:optional var content:String;
    /**
        Override the default username of the webhook
     */
    @:optional var username:String;
    /**
        Override the default avatar of the webhook
     */
    @:optional var avatar_url:String;
    /**
        True if this is a TTS message
     */
    @:optional var tts:Bool;
    /**
        The contents of the file being sent
        Every webhook requires at least one of either content, file, or embeds.
     */
    @:optional var file:String;
    /**
        Embedded rich content
        Every webhook requires at least one of either content, file, or embeds.
     */
    @:optional var embeds:Array<Embed>;
}

typedef AuditLogFilter = {
    /**
        Filter the log for a user id
     */
    @:optional var user_id:String;
    /**
        The type of audit log event
     */
    @:optional var action_type:AuditLogEvent;
    /**
        Filter the log before a certain entry id
     */
    @:optional var before:String;
    /**
        How many entries are returned (default 50, minimum 1, maximum 100)
     */
    @:optional var limit:Int;
}