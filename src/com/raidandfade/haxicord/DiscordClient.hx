package com.raidandfade.haxicord;

import com.raidandfade.haxicord.websocket.WebSocketConnection;
import com.raidandfade.haxicord.endpoints.Endpoints;


import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.types.User;
import com.raidandfade.haxicord.types.Channel;
import com.raidandfade.haxicord.types.DMChannel;
import com.raidandfade.haxicord.types.Guild;

import haxe.Json;
import haxe.Timer;

//TODO connect to gw first

class DiscordClient { 
    public static var libName:String = "Haxicord";
    public static var userAgent:String = "DiscordBot (https://github.com/RaidAndFade/Haxicord, 0.0.1)";
    public static var gatewayVersion:Int = 6;
    
    //cache arrays (id,object)
    public var messageCache:Map<String,Message> = new Map<String,Message>();
    public var userCache:Map<String,User> = new Map<String,User>();
    public var channelCache:Map<String,Channel> = new Map<String,Channel>();
    public var dmChannelCache:Map<String,DMChannel> = new Map<String,DMChannel>();
    public var guildCache:Map<String,Guild> = new Map<String,Guild>();

    public var user:User; //me

    public var token:String;
    public var isBot:Bool;

    public var endpoints:Endpoints;

    var hbThread:HeartbeatThread;
    var ws:WebSocketConnection;

    public function new(_tkn:String){ //Sharding? lol good joke.
        token = _tkn; //ASSUME BOT FOR NOW. Deal with users later maybe.
        isBot = true;
        
        endpoints = new Endpoints(this);

        trace("Getting gotten");
        endpoints.getGateway(false,connect);
        //Init websocket
		//ws = new WebSocketConnection("ws://echo.websocket.org");
		//ws.send("Henlo!");
    }
    
    public function start(blocking=true){
#if sys
        while(blocking){
            Sys.sleep(1);
        }
#end
    }
//Flowchart
    public function connect(gateway,error){
        if(error!=null)throw error;
        trace("Gottening");
        ws = new WebSocketConnection(gateway.url+"/?v="+gatewayVersion+"&encoding=json");
        ws.onMessage = webSocketMessage;
        ws.onClose = function(){
            if(hbThread!=null)hbThread.pause();
        }
        ws.onError = function(e){
            if(hbThread!=null)hbThread.pause();
        }
    }

    public function webSocketMessage(msg){
        trace(msg);
        var m:WSMessage = Json.parse(msg);
        var d:Dynamic;
        d = m.d;
        trace(m);
        switch(m.op){
            case 10: 
                ws.sendJson(WSPrepareData.Identify(token));
                hbThread = new HeartbeatThread(d.heartbeat_interval,ws,null);
            case 9:
                trace("oh god...");
            case 0:
                receiveEvent(m);
            default:
        }
    }

    public function receiveEvent(msg){
        var m:WSMessage = msg;
        var d:Dynamic;
        d = m.d;
        switch(m.t){
            case "READY":
                onReady();
            case "CHANNEL_CREATE":
            case "CHANNEL_UPDATE":
            case "CHANNEL_DELETE":
            case "GUILD_CREATE":
            case "GUILD_UPDATE":
            case "GUILD_DELETE":
            case "GUILD_BAN_ADD":
            case "GUILD_BAN_REMOVE":
            case "GUILD_EMOJIS_UPDATE":
            case "GUILD_INTEGRATIONS_UPDATE": //lol ok
            case "GUILD_MEMBER_ADD":
            case "GUILD_MEMBER_REMOVE":
            case "GUILD_MEMBER_UPDATE":
            case "GUILD_MEMBERS_CHUNK": //gg
            case "GUILD_ROLE_CREATE":
            case "GUILD_ROLE_UPDATE":
            case "GUILD_ROLE_DELETE":
            case "MESSAGE_CREATE":
            case "MESSAGE_UPDATE":
            case "MESSAGE_DELETE":
            case "MESSAGE_DELETE_BULK":
            case "MESSAGE_REACTION_ADD":
            case "MESSAGE_REACTION_REMOVE":
            case "MESSAGE_REACTION_REMOVE_ALL":
            case "PRESENCE_UPDATE":
            case "TYPING_START":
            case "USER_UPDATE":
            case "VOICE_STATE_UPDATE":
            case "VOICE_SERVER_UPDATE":
            default:
                trace("Unhandled event "+m.t);
        }
    }

    public function receiveGuildCreate(data){

    }

//get
    public function getGuild(id,cb:Guild->Void){
        if(guildCache.exists(id)){
            cb(guildCache.get(id));
        }else{
            endpoints.getGuild(id,function(r,e){
                if(e!=null)throw(e);
                cb(r);
            });
        }
    }

    public function getGuildUnsafe(id){
        if(guildCache.exists(id)){
            return guildCache.get(id);
        }else{
            throw "Guild not in cache. try loading it safely first!";
        }
    }

    public function getChannel(id,cb:Channel->Void){
        if(channelCache.exists(id)){
            cb(channelCache.get(id));
        }else{
            endpoints.getChannel(id,function(r,e){
                if(e!=null)throw(e);
                cb(r);
            });
        }
    }

    public function getChannelUnsafe(id){
        if(channelCache.exists(id)){
            return channelCache.get(id);
        }else{
            throw "Channel not in cache. try loading it safely first!";
        }
    }

//"constructors"


//deal with updating when new is already in cache.
//Channels in client cache should be updated in guild cache.
    public function newMessage(message_struct:com.raidandfade.haxicord.types.structs.MessageStruct){
        var id = message_struct.id;
        if(messageCache.exists(id)){
            return messageCache.get(id);
        }else{
            var msg = new Message(message_struct,this);
            messageCache.set(id,msg);
            return messageCache.get(id);
        }
    }

    public function newUser(user_struct:com.raidandfade.haxicord.types.structs.User){
        var id = user_struct.id;
        if(userCache.exists(id)){
            return userCache.get(id);
        }else{
            var user = new User(user_struct,this);
            userCache.set(id,user);
            return userCache.get(id);
        }
    }

    public function newChannel(channel_struct){
        return _newChannel(channel_struct)(channel_struct);
    }

    public function _newChannel(channel_struct):Dynamic->Channel{
        var id = channel_struct.id;
        if(channel_struct.is_private)return newDMChannel;
        if(channelCache.exists(id)){
            return function(_){return channelCache.get(id);};
        }else{
            var channel = Channel.fromStruct(channel_struct)(channel_struct,this);
            channelCache.set(id,channel);
            return function(_){return channelCache.get(id);};
        }
    }

    public function newDMChannel(channel_struct:com.raidandfade.haxicord.types.structs.DMChannel){
        var id = channel_struct.id;
        if(dmChannelCache.exists(id)){
            return dmChannelCache.get(id);
        }else{
            var channel = DMChannel.fromStruct(channel_struct,this);
            dmChannelCache.set(id,channel);
            return dmChannelCache.get(id);
        }
    }

    public function newGuild(guild_struct:com.raidandfade.haxicord.types.structs.Guild){
        var id = guild_struct.id;
        if(guildCache.exists(id)){
            return guildCache.get(id);
        }else{
            var guild = new Guild(guild_struct,this);
            guildCache.set(id,guild);
            return guildCache.get(id);
        }
    }

//Events 
    public dynamic function onReady(){}

    public dynamic function onMessage(m){}

    public dynamic function onEvent(){}

}

typedef WSMessage = {
    var op:Int;
    var d:Dynamic;
    var s:Int;
    var t:String;
}

class WSPrepareData {
    public static function Identify(t:String, p:WSIdentify_Properties=null, c:Bool=false, l:Int=59, s:WSShard=null){
        if(p==null) p = {"$os":"","$browser":DiscordClient.libName,"$device":DiscordClient.libName,"$referrer":"","$referring_domain":""};
        if(s==null) s = [0,1];
        return {"op":2,"d":{"token":t,"properties":p,"compress":c,"large_threshhold":l,"shard":s}};
    }

    public static function Heartbeat(seq=null){
        return {"op":1,"d":seq};
    }
}

typedef WSShard = Array<Int>;

typedef WSIdentify_Properties = {
    @:optional var os:String;
    @:optional var browser:String;
    @:optional var device:String;
    @:optional var referrer:String;
    @:optional var referring_domain:String;
}

class HeartbeatThread { 
    public var delay:Int;

    var seq:Null<Int>;
    var ws:WebSocketConnection;
    var timer:Timer;

    var paused:Bool;

    public function setSeq(_s){
        seq = _s;
    }

    public function new(_d,_w,_s){
        delay = _d;
        ws=_w;
        seq=_s;
#if sys
        var delayf:Float=delay/1000;
#if cpp
        cpp.vm.Thread.create(beatRecursive);
#elseif cs
        var th = new cs.system.threading.Thread(new cs.system.threading.ThreadStart(beatRecursive));
        th.Start();
#elseif neko
        neko.vm.Thread.create(beatRecursive);
#end
#else
        timer = new Timer(delay);
        timer.run = beat;
#end
    }

    public function beatRecursive(){
#if sys
        while(!paused){
            Sys.sleep(delay/1000);
            beat();
        }
#end
    }

    public function beat(){
        ws.sendJson(WSPrepareData.Heartbeat(seq));
    }

    public function pause(){
        paused=true;
        timer.stop();
    }

    public function resume(){
        beat();
#if sys
        var delayf:Float=delay/1000;
#if cpp
        cpp.vm.Thread.create(beatRecursive);
#elseif cs
        var th = new cs.system.threading.Thread(new cs.system.threading.ThreadStart(beatRecursive));
        th.Start();
#elseif neko
        neko.vm.Thread.create(beatRecursive);
#end
#else
        timer = new Timer(delay);
        timer.run = beat;
#end
    }
}