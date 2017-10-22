package com.raidandfade.haxicord.types.structs;

typedef AuditLog = {
    var webhooks:Array<Webhook>;
    var users:Array<User>;
    var audit_log_entries:Array<AuditLogEntry>;
}

typedef AuditLogEntry = {
    var target_id:String;
    var changes:Array<AuditLogChange>;
    var user_id:String; //snowflake
    var id:String; //snowflake
    var action_type:AuditLogEvent;
    var options:Array<AuditLogOptionalEntryInfo>;
    var reason:String;
}

@:enum
abstract AuditLogEvent(Int) {
    var GUILD_UPDATE = 1;
	var CHANNEL_CREATE = 10;
	var CHANNEL_UPDATE = 11;
	var CHANNEL_DELETE = 12;
	var CHANNEL_OVERWRITE_CREATE = 13;
	var CHANNEL_OVERWRITE_UPDATE = 14;
	var CHANNEL_OVERWRITE_DELETE = 15;
	var MEMBER_KICK = 20;
	var MEMBER_PRUNE = 21;
	var MEMBER_BAN_ADD = 22;
	var MEMBER_BAN_REMOVE = 23;
	var MEMBER_UPDATE = 24;
	var MEMBER_ROLE_UPDATE = 25;
	var ROLE_CREATE = 30;
	var ROLE_UPDATE = 31;
	var ROLE_DELETE = 32;
	var INVITE_CREATE = 40;
	var INVITE_UPDATE = 41;
	var INVITE_DELETE = 42;
	var WEBHOOK_CREATE = 50;
	var WEBHOOK_UPDATE = 51;
	var WEBHOOK_DELETE = 52;
	var EMOJI_CREATE = 60;
	var EMOJI_UPDATE = 61;
	var EMOJI_DELETE = 62;
	var MESSAGE_DELETE = 72;
}

typedef AuditLogOptionalEntryInfo = {
    @:optional var delete_member_days:String;
    @:optional var members_removed:String;
    @:optional var channel_id:String;
    @:optional var count:String;
    @:optional var id:String;
    @:optional var type:String;
    @:optional var role_name:String;
}

typedef AuditLogChange = {
    @:optional var new_value:Dynamic;
    @:optional var old_value:Dynamic;
    @:optional var key:String;
}