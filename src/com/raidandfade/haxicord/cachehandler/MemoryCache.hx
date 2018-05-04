package com.raidandfade.haxicord.cachehandler;

import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.types.User;
import com.raidandfade.haxicord.logger.Logger;
import com.raidandfade.haxicord.types.Channel;
import com.raidandfade.haxicord.types.DMChannel;
import com.raidandfade.haxicord.types.GuildChannel;
import com.raidandfade.haxicord.types.GuildMember;
import com.raidandfade.haxicord.types.TextChannel;
import com.raidandfade.haxicord.types.CategoryChannel;
import com.raidandfade.haxicord.types.VoiceChannel;
import com.raidandfade.haxicord.types.Guild;
import com.raidandfade.haxicord.types.Role;
import com.raidandfade.haxicord.types.Snowflake;

class MemoryCache implements DataCache{

    public function new(){}

    @:dox(hide)
    public var messageCache:Map<String,Message> = new Map<String,Message>();

    @:dox(hide)
    public var userCache:Map<String,User> = new Map<String,User>();

    @:dox(hide)
    public var channelCache:Map<String,Channel> = new Map<String,Channel>();

    @:dox(hide)
    public var dmChannelCache:Map<String,DMChannel> = new Map<String,DMChannel>();

    @:dox(hide)
    public var guildCache:Map<String,Guild> = new Map<String,Guild>();

    @:dox(hide)
    public var userDMChannels:Map<String,String> = new Map<String,String>(); //put this in somewhere.

    public function setMessage(id:String,m:Message):Void{
        messageCache.set(id,m);
    }
    public function setUser(id:String,u:User):Void{
        userCache.set(id,u);
    }
    public function setChannel(id:String,ch:Channel):Void{
        channelCache.set(id,ch);
    }
    public function setDMChannel(id:String,dmch:DMChannel):Void{
        dmChannelCache.set(id,dmch);
    }
    public function setGuild(id:String,g:Guild):Void{
        guildCache.set(id,g);
    }
    public function setUserDMChannel(id:String,dmchid:String):Void{
        userDMChannels.set(id,dmchid);
    }
    
    public function delMessage(id:String):Void{
        messageCache.remove(id);
    }
    public function delUser(id:String):Void{
        userCache.remove(id);
    }
    public function delChannel(id:String):Void{
        channelCache.remove(id);
    }
    public function delDMChannel(id:String):Void{
        dmChannelCache.remove(id);
    }
    public function delGuild(id:String):Void{
        guildCache.remove(id);
    }
    public function delUserDMChannel(id:String):Void{
        userDMChannels.remove(id);
    }

    public function getMessage(id:String):Null<Message>{
        return messageCache.get(id);
    }
    public function getUser(id:String):Null<User>{
        return userCache.get(id);
    }
    public function getChannel(id:String):Null<Channel>{
        return channelCache.get(id);
    }
    public function getDMChannel(id:String):Null<DMChannel>{
        return dmChannelCache.get(id);
    }
    public function getGuild(id:String):Null<Guild>{
        return guildCache.get(id);
    }
    public function getUserDMChannel(id:String):Null<String>{
        return userDMChannels.get(id);
    }

    
    public function getAllDMChannels():Array<DMChannel>{
        return [for(dm in dmChannelCache.iterator()) dm];
    }
    public function getAllGuilds():Map<String,Guild>{
        return guildCache;
    }
}