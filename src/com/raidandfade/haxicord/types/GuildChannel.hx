package com.raidandfade.haxicord.types;

import com.raidandfade.haxicord.types.structs.GuildChannel.Overwrite;

import haxe.extern.EitherType;

class GuildChannel extends Channel {
    public var guild_id:Snowflake;
    public var name:String;
    public var parent_id:Snowflake;
    public var nsfw:Bool;
    public var position:Int;
    public var permission_overwrites:Array<Overwrite>;

    public function getGuild(){
        return client.getGuildUnsafe(guild_id.id);
    }

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
    public function getInvites(cb=null){
        client.endpoints.getChannelInvites(id.id,cb);
    }

    public function createInvite(invite_data,cb=null){
        client.endpoints.createChannelInvite(id.id,invite_data,cb);
    }

    public function editChannel(cd,cb=null){
        client.endpoints.modifyChannel(id.id,cd,cb);
    }

    public function deleteChannel(cb){
        client.endpoints.deleteChannel(id.id,cb);
    }

    public function editPermission(perm,pid,cb=null){
        client.endpoints.editChannelPermissions(id.id,pid,cb);
    }

    public function deletePermission(pid,cb=null){
        client.endpoints.deleteChannelPermission(id.id,pid,cb);
    }
}
