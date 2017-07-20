package com.raidandfade.haxicord;

import com.raidandfade.haxicord.websocket.WebSocketConnection;
import com.raidandfade.haxicord.endpoints.Endpoints;

import com.raidandfade.haxicord.types.structs.MessageStruct;

import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.types.User;
import com.raidandfade.haxicord.types.Channel;
import com.raidandfade.haxicord.types.DMChannel;
import com.raidandfade.haxicord.types.GuildChannel;
import com.raidandfade.haxicord.types.GuildMember;
import com.raidandfade.haxicord.types.TextChannel;
import com.raidandfade.haxicord.types.VoiceChannel;
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

    public var userDMChannels:Map<String,String> = new Map<String,String>();//put this in somewhere.
    public var ready = false;

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
    }
    
    public function start(blocking=true){
#if sys
        while(blocking){
            Sys.sleep(1);
        }
#end
    }
//Flowchart
    function connect(gateway,error){
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

    function webSocketMessage(msg){
        trace(msg);
        var m:WSMessage = Json.parse(msg);
        switch(m.op){
            case 10: 
                ws.sendJson(WSPrepareData.Identify(token));
                hbThread = new HeartbeatThread(m.d.heartbeat_interval,ws,null);
            case 9:
                trace("oh god...");
            case 0:
                receiveEvent(m);
            default:
        }
    }

    function receiveEvent(msg){
        var m:WSMessage = msg;
        var d:Dynamic;
        d = m.d;
        trace(m.t);
        hbThread.setSeq(m.s);
        switch(m.t){
            case "READY":
            //save the session, for resumes.
                var re:WSReady = d;
                for(g in re.guilds){
                    _newGuild(g);
                }
                user=_newUser(re.user);
            case "CHANNEL_CREATE":
                _newChannel(d);
            case "CHANNEL_UPDATE":
                _newChannel(d);
            case "CHANNEL_DELETE":
                removeChannel(d);
            case "GUILD_CREATE":
                _newGuild(d);
                var done = true;
                for(g in guildCache){
                    if(g.unavailable){
                        trace(g.id + " is not done.");
                        done=false;
                        break;
                    }
                }
                if(done&&!ready){
                    ready=true;
                    onReady();
                }
            case "GUILD_UPDATE":
                _newGuild(d);
            case "GUILD_DELETE":
                removeGuild(d.id);
            case "GUILD_BAN_ADD":
                getGuildUnsafe(d.guild_id)._addBan(getUserUnsafe(d));
            case "GUILD_BAN_REMOVE":
                getGuildUnsafe(d.guild_id)._removeBan(getUserUnsafe(d));
            case "GUILD_EMOJIS_UPDATE":
                getGuildUnsafe(d.guild_id)._updateEmojis(d.emojis);
            case "GUILD_INTEGRATIONS_UPDATE": //lol ok ~ just set a flag somewhere
            case "GUILD_MEMBER_ADD":
                onMemberJoin(getGuildUnsafe(d.guild_id),getGuildUnsafe(d.guild_id)._newMember(d));
            case "GUILD_MEMBER_REMOVE":
                getGuildUnsafe(d.guild_id).members.remove(d.user.id);
            case "GUILD_MEMBER_UPDATE":
                getGuildUnsafe(d.guild_id)._newMember(d);
            case "GUILD_MEMBERS_CHUNK": 
                var members:Array<com.raidandfade.haxicord.types.structs.GuildMember> = d.members;
                for(g in members){
                    getGuildUnsafe(d.guild_id)._newMember(g);
                }
            case "GUILD_ROLE_CREATE":
                getGuildUnsafe(d.guild_id)._newRole(d.role);
            case "GUILD_ROLE_UPDATE":
                getGuildUnsafe(d.guild_id)._newRole(d.role);
            case "GUILD_ROLE_DELETE":
                getGuildUnsafe(d.guild_id).roles.remove(d.role_id);
            case "MESSAGE_CREATE":
                onMessage(_newMessage(d));
            case "MESSAGE_UPDATE":
                _newMessage(d);
            case "MESSAGE_DELETE":
                removeMessage(d);
            case "MESSAGE_DELETE_BULK":
                var msgs:Array<String> = d.ids;
                for(m in msgs){
                    removeMessage(m);
                }
            case "MESSAGE_REACTION_ADD": //not too sure what to do about this except for fire an event.
            case "MESSAGE_REACTION_REMOVE": //same as above
            case "MESSAGE_REACTION_REMOVE_ALL": //same as above
            case "PRESENCE_UPDATE": // user
                getGuildUnsafe(d.guild_id).members[d.user.id]._updatePresence(d);
            case "TYPING_START": // event
            case "USER_UPDATE": // user
            case "VOICE_STATE_UPDATE": // ...
            case "VOICE_SERVER_UPDATE": // ...
            default:
                trace("Unhandled event "+m.t);
        }
    }

    public function receiveGuildCreate(data){

    }

//Misc funcs that cant fit anywhere else
    /**
     *  Get a list of voice regions.
     *  @param cb - Returns a list of voice regions, or an error.
     */
    public function listVoiceRegions(cb){
        endpoints.listVoiceRegions(cb);
    }

    /**
     *  Create a new guild based on the data given
     *  @param guild_data - The data to be changed, All fields are optional.
     *  @param cb - Returns the new guild object, or an error.
     */
    public function createGuild(guild_data,cb){
        endpoints.createGuild(guild_data,cb);
    }

    /**
     *  Send a message to a channel
     *  @param channel_id - The channel to send to
     *  @param message - Message data
     *  @param cb - Return the message sent, or an error
     */
    public function sendMessage(channel_id,message,cb=null){
        if(userDMChannels.exists(channel_id))
            endpoints.sendMessage(userDMChannels.get(channel_id),message,cb);
        else if(userCache.exists(channel_id))
            endpoints.createDM({recipient_id:channel_id},function(ch,e){
                ch.sendMessage(message,cb);
            });
        else 
            endpoints.sendMessage(channel_id,message,cb);
    }

     /**
     *  Get information about an invite code.
     *  @param invite_code - The invite code.
     *  @param cb - Returns an Invite object, or an error.
     */
    public function getInvite(invite_code,cb=null){
        endpoints.getInvite(invite_code,cb);
    }

    /**
     *  (NOT AVAILABLE FOR BOTS) Accept an invite code and join the server.
     *  @param invite_code - The invite code to join.
     *  @param cb - Returns the invite that was joined, or an error.
     */
    public function joinInvite(invite_code,cb=null){
        endpoints.acceptInvite(invite_code,cb);
    }

    /**
     *  Delete an invite based on it's invite code. Requires the MANAGE_CHANNELS permission in the guild the invite is from.
     *  @param invite_code - The invite code of the invite to delete.
     *  @param cb - Returns the Invite that was removed, or an error.
     */
    public function deleteInvite(invite_code,cb=null){
        endpoints.deleteInvite(invite_code,cb);
    }

    /**
     *  Create a DM group. 
     *  @param data - A struct that contains the necessary arguments required to invite members.
     *  @param cb - Returns the group dm channel, or an error.
     */
    public function createDMGroup(data,cb=null){
        endpoints.createGroupDM(data,cb);
    }

//User @me Endpoints

    /**
     *  Edit the current user's settings.
     *  @param user_data - The parameters to change, all fields are optional.
     *  @param cb - Return the changed user, or an error.
     */
    public function editUser(user_data,cb=null){
        endpoints.editUser(user_data,cb);
    }

    /**
     *  Get a list of all guilds that the current user is in. Normal users do not need to use the filter and can leave it blank `{}`
     *  @param filter - Filter the list depending on these parameters, Only one of BEFORE or AFTER can be specified.
     *  @param cb - Returns the list of Guilds according to the filter specified, or an error.
     */
    public function getGuilds(filter,cb=null){
        endpoints.getGuilds(filter,cb);
    }

    /**
     *  Get a list of connections hooked up to the current account.
     *  @param cb - Returns a list of connections, or an error.
     */
    public function getConnections(cb=null){
        endpoints.getConnections(cb);
    }

//remove
    public function removeChannel(id){
        //remove from guild too.
        var c = channelCache.get(id);
        if(c.type!=1){
            var gc = cast(c,GuildChannel);
            var g = gc.getGuild();
            if(gc.type==0){
                g.textChannels.remove(c.id.id);
            }else{
                g.voiceChannels.remove(c.id.id);
            }
        }
        channelCache.remove(id);
    }

    public function removeMessage(id){
        messageCache.remove(id);
    }

    public function removeGuild(id){
        guildCache.remove(id);
    }

    public function removeUser(id){
        userCache.remove(id);
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

    public function getDMChannels(cb:Array<DMChannel>->Void){
        endpoints.getDMChannels(function(r,e){
            if(e!=null)throw(e);
            cb(r);
        });
    }

    public function getDMChannelsUnsafe(id){
        return [for(dm in dmChannelCache.iterator()) dm];
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


    public function getUser(id,cb:User->Void){
        if(userCache.exists(id)){
            cb(userCache.get(id));
        }else{
            endpoints.getUser(id,function(r,e){
                if(e!=null)throw(e);
                cb(r);
            });
        }
    }

    public function getUserUnsafe(id){
        if(userCache.exists(id)){
            return userCache.get(id);
        }else{
            throw "User not in cache. try loading it safely first!";
        }
    }

    public function getMessage(id,channel_id,cb:Message->Void){
        if(messageCache.exists(id)){
            cb(messageCache.get(id));
        }else{
            endpoints.getMessage(channel_id,id,function(r,e){
                if(e!=null)throw(e);
                cb(r);
            });
        }
    }

    public function getMessageUnsafe(id){
        if(messageCache.exists(id)){
            return messageCache.get(id);
        }else{
            throw "Message not in cache. try loading it safely first!";
        }
    }
//"constructors"


//deal with updating when new is already in cache.
//Channels in client cache should be updated in guild cache.
    public function _newMessage(message_struct:com.raidandfade.haxicord.types.structs.MessageStruct){
        var id = message_struct.id;
        trace("NEW MESSAGE: "+id);
        if(messageCache.exists(id)){
            messageCache.get(id)._update(message_struct);
            return messageCache.get(id);
        }else{
            var msg = new Message(message_struct,this);
            messageCache.set(id,msg);
            return messageCache.get(id);
        }
    }

    public function _newUser(user_struct:com.raidandfade.haxicord.types.structs.User){
        var id = user_struct.id;
        trace("NEW USER: "+id);
        if(userCache.exists(id)){
            userCache.get(id)._update(user_struct);
            return userCache.get(id);
        }else{
            var user = new User(user_struct,this);
            userCache.set(id,user);
            return userCache.get(id);
        }
    }

    public function _newChannel(channel_struct){
        return __newChannel(channel_struct)(channel_struct);
    }

    public function __newChannel(channel_struct:Dynamic):Dynamic->Channel{
        if(channel_struct.type == "text" || channel_struct.type == "voice"){
            channel_struct.type = channel_struct.type=="text"?0:2;
        }
        var id = channel_struct.id;
        trace("NEW CHANNEL: "+id+"("+channel_struct.type+")");
        if(channel_struct.type==1)return _newDMChannel;
        if(channelCache.exists(id)){
            var c = cast(channelCache.get(id),GuildChannel);
            if(c.type==0)
                cast(c,TextChannel)._update(channel_struct);
            else
                cast(c,VoiceChannel)._update(channel_struct);
            return function(c,_){
                return c;
            }.bind(c,_);
        }else{
            var channel = Channel.fromStruct(channel_struct)(channel_struct,this);
            channelCache.set(id,channel);
            var c = cast(channelCache.get(id),GuildChannel);
            try{getGuildUnsafe(c.guild_id.id)._addChannel(c);}catch(e:Dynamic){} //Try. but if it doesn't... meh
            return function(_){return channelCache.get(id);};
        }
    }

    public function _newDMChannel(channel_struct:com.raidandfade.haxicord.types.structs.DMChannel){
        var id = channel_struct.id; 
        if(dmChannelCache.exists(id)){
            dmChannelCache.get(id)._update(channel_struct);
            return dmChannelCache.get(id);
        }else{
            var channel = DMChannel.fromStruct(channel_struct,this);
            dmChannelCache.set(id,channel);
            if(channel.recipient!=null) userDMChannels.set(channel.recipient.id.id,id);
            else if(channel.recipients!=null && channel.recipients.length==1) userDMChannels.set(channel.recipients[0].id.id,id);
            return dmChannelCache.get(id);
        }
    }

    public function _newGuild(guild_struct:com.raidandfade.haxicord.types.structs.Guild){
        var id = guild_struct.id;
        trace("NEW GUILD: "+id);
        if(guildCache.exists(id)){
            guildCache.get(id)._update(guild_struct);
            return guildCache.get(id);
        }else{
            var guild = new Guild(guild_struct,this);
            guildCache.set(id,guild);
            return guildCache.get(id);
        }
    }

//Events 
    public dynamic function onReady(){}

    public dynamic function onMemberJoin(g:Guild,m:GuildMember){}

    public dynamic function onMessage(m:Message){}

    public dynamic function onEvent(e:String,d:Dynamic){}

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

typedef WSReady = {
    @:optional var v:Int;
    @:optional var user_settings:Dynamic;
    @:optional var user:com.raidandfade.haxicord.types.structs.User;
    @:optional var shard:Array<Int>;
    @:optional var session_id:String;
    @:optional var relationships:Dynamic;
    @:optional var private_channels:Array<com.raidandfade.haxicord.types.structs.DMChannel>;
    @:optional var presences:Array<com.raidandfade.haxicord.types.structs.Presence>;
    @:optional var guilds:Array<com.raidandfade.haxicord.types.structs.Guild>;
    @:optional var _trace:Dynamic;
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