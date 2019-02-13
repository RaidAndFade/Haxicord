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

interface DataCache{
    public function setMessage(id:String,m:Message):Void;
    public function setUser(id:String,u:User):Void;
    public function setChannel(id:String,ch:Channel):Void;
    public function setDMChannel(id:String,dmch:DMChannel):Void;
    public function setGuild(id:String,g:Guild):Void;
    public function setUserDMChannel(id:String,dmchid:String):Void;
    
    public function delMessage(id:String):Void;
    public function delUser(id:String):Void;
    public function delChannel(id:String):Void;
    public function delDMChannel(id:String):Void;
    public function delGuild(id:String):Void;
    public function delUserDMChannel(id:String):Void;
    
    public function getMessage(id:String):Null<Message>;
    public function getUser(id:String):Null<User>;
    public function getChannel(id:String):Null<Channel>;
    public function getDMChannel(id:String):Null<DMChannel>;
    public function getGuild(id:String):Null<Guild>;
    public function getUserDMChannel(id:String):Null<String>;

    public function getAllDMChannels():Array<DMChannel>;
    public function getAllGuilds():Array<Guild>;
}