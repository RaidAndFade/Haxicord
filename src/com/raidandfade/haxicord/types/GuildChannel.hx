package com.raidandfade.haxicord.types;

import com.raidandfade.haxicord.types.structs.GuildChannel.Overwrite;

import haxe.extern.EitherType;

class GuildChannel extends Channel {
    /**
        The ID of the guild this is part of.
     */
    public var guild_id:Snowflake;
    /**
        The name of this channel
     */
    public var name:String;
    /**
        The ID of the category this is under (Or null)
     */
    public var parent_id:Snowflake;
    /**
        Is this channel nsfw?
     */
    public var nsfw:Bool;
    /**
        The position of this channel.
     */
    public var position:Int;
    /**
        A list of this channel's permission overwrites
     */
    public var permission_overwrites:Array<Overwrite>;

    /**
       Get the guild object that this channel is a part of. If this returns null or throws an error something has seriously gone wrong.
     */
    public function getGuild(){
        return client.getGuildUnsafe(guild_id.id);
    }

    @:dox(hide)
    public static function fromStruct(_chan):Dynamic->DiscordClient->GuildChannel{
        if(_chan.type==0){
            return TextChannel.fromStruct;
        }
        if(_chan.type==2){
            return VoiceChannel.fromStruct;
        }
        if(_chan.type==4){
            return CategoryChannel.fromStruct;
        }
        throw "Invalid Struct";
    }

    //Live structs

    /**
        Get the invites of a given channel
        @param cb - Array of Invites (or error).
     */
    public function getInvites(cb=null){
        client.endpoints.getChannelInvites(id.id,cb);
    }
    /**
        Create a new invite for a given channel
        @param invite_data - The invite data.
        @param cb - Return the invite or an error.
     */
    public function createInvite(invite_data,cb=null){
        client.endpoints.createChannelInvite(id.id,invite_data,cb);
    }
    /**
        Change a channel's parameters
        @param cd - The changed channel data, all fields are optional
        @param cb - Callback to send the new channel object to. Or null if result is not desired.
     */
    public function editChannel(cd,cb=null){
        client.endpoints.modifyChannel(id.id,cd,cb);
    }
    /**
        Delete the given channel.
        @param cb - Callback to send old channel to. Or null if result is not desired.
     */
    public function deleteChannel(cb=null){
        client.endpoints.deleteChannel(id.id,cb);
    }
    /**
        Edit or Create a channel's overwrite permissions;
        @param perm - The modified overwrite permission object
        @param pid - The overwrite Id, Id of user or role.
        @param cb - Call once finished.
     */
    public function editPermission(perm,pid,cb=null){
        client.endpoints.editChannelPermissions(id.id,pid,perm,cb);
    }
    /**
        Delete a channel override
        @param pid - The overwrite id to delete
        @param cb - Call once finished.
     */
    public function deletePermission(pid,cb=null){
        client.endpoints.deleteChannelPermission(id.id,pid,cb);
    }
}
