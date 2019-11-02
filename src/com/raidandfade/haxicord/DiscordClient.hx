package com.raidandfade.haxicord;

import com.raidandfade.haxicord.websocket.WebSocketConnection;
import com.raidandfade.haxicord.endpoints.Endpoints;

import com.raidandfade.haxicord.types.structs.MessageStruct;

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
import com.raidandfade.haxicord.types.structs.Emoji;
import com.raidandfade.haxicord.types.structs.Status;
import com.raidandfade.haxicord.types.structs.Status.Activity;

import com.raidandfade.haxicord.cachehandler.DataCache;
import com.raidandfade.haxicord.cachehandler.MemoryCache;

// import com.raidandfade.haxicord.utils.Timer;

import haxe.Timer;
import haxe.Json;

/*
TODO rn
- ZLIB optional
- ISO8601 parser takes way too long 
*/

/*
TODO long term
- uploading files raw to messages
- Shardmaster
*/

@:keep
@:expose
#if Profiler
@:build(Profiler.buildMarked())
#end
class DiscordClient { 
     /**
      The name of the library
     */
    public static var libName:String = "Haxicord";
    /**
      The library's useragent
     */
    public static var userAgent:String = "DiscordBot (https://github.com/RaidAndFade/Haxicord, 0.2.0)";
    /**
      The gateway version being used.
     */
    public static var gatewayVersion:Int = 6;
    
    //cache arrays (id,object)
    @:dox(hide)
    public var ready = false;

    @:dox(hide)
    public var session:String; 

    @:dox(hide)
    public var canResume:Bool;

    @:dox(hide)
    public var resumeable = false;

    @:dox(hide)
    public var dataCache:DataCache;
    /**
        The bot user, this is you.
     */
    public var user:User; //me

    @:dox(hide)
    public var token:String;

    public var lastbeat:Float;
    public var ws_latency:Float;
    public var api_latency:Float;
    
    /**
        Is the bot a bot account? <Always true>
     */
    public var isBot:Bool;

    @:dox(hide)
    public var endpoints:Endpoints;

    @:dox(hide)
    public var reconnectTimeout:Int = 1;

    @:dox(hide)
    var hbThread:HeartbeatThread;

    @:dox(hide)
    public var ws:WebSocketConnection;

    @:dox(hide)
    private var shardInfo:WSShard;

    @:dox(hide)
    private var unavailableGuilds:Int;

    //private var dontwaitforguilds:Bool = true;

    private var zlibCompress:Bool = false;
    private var etfFormat:Bool = false;

    
    private var webSocketMessages:Array<String>;
    private var webSocketProcessTimer:Timer;


//TODO update comment
    /**
        Initialize the bot with your token. This should be the first thing you run in your program.
        @param _tkn - Your BOT token. User tokens do not work! 
     */
    @:profile public function new(_tkn:String,_shardInfo:Null<WSShard>=null,_etf=false,_zlib=true,_storage:DataCache=null) {
        Logger.registerLogger();

        token = _tkn; //ASSUME BOT FOR NOW. Deal with users later maybe.
        isBot = true;
        
        endpoints = new Endpoints(this);

        zlibCompress = _zlib;
        etfFormat = _etf;

        if(etfFormat){
            throw "ETF is not yet supported. set _etf to false";
        }

        if(_shardInfo!=null){
            shardInfo = _shardInfo;
        }

        if(_storage==null){
            this.dataCache = new MemoryCache();
        }else{
            this.dataCache = _storage;
        }

        //trace("Getting gotten");
        trace("Starting Client");
        endpoints.getGateway(isBot, connect);

        webSocketMessages = new Array<String>();
        webSocketProcessTimer = new Timer(100);
        webSocketProcessTimer.run = this.processWebsocketMessages;
    }
    
    /**
        This no longer has any function. Threads are all dependant on mainloop.
     */
     @:deprecated public function start() {}

//Flowchart
    @:dox(hide)
    @:profile function connect(gateway, error) {
        try{
            trace("Connecting");
            if(error != null) throw error; 

            //trace("Gottening");
            var url = gateway.url + "/?v=" + gatewayVersion;

            if(etfFormat){
                url += "&encoding=etf";
            }else{
                url += "&encoding=json";
            }

            if(zlibCompress){
                url += "&compress=zlib-stream";
            }

            ws = new WebSocketConnection(url);
            ws.onMessage = this.webSocketMessage;

            ws.onClose = function(m) {
                if(hbThread != null) hbThread.pause();

                if(m == 4006) //The session is invalid. stop it
                    session = "";

                if(session == "") 
                    resumeable = false; //can't be resumed if i don't have a session

                trace("Socket Closed with code " + m  +", Re-Opening in " + this.reconnectTimeout + "s. " + (resumeable?"Resuming":""));

                Timer.delay(connect.bind(gateway,error), this.reconnectTimeout * 1000);
                
                this.reconnectTimeout *= 2; //double every time it dies.
            }

            ws.onError = function(e) {
                resumeable = false;

                trace("Websocket errored!");
                trace(e);
            }
        }catch(e:Dynamic){
            trace(e);
        }
    }

    @:profile function sendWs(d:Dynamic){
        // trace(d);
        ws.sendJson(d);
    }

    @:dox(hide)
    @:profile function webSocketMessage(msg) {
        // trace(msg);
        // webSocketMessageHandle(msg);
        webSocketMessages.push(msg);
        // if(haxe.MainLoop.threadCount<25){
        //     haxe.MainLoop.addThread(prepareWebSocketMessage.bind(msg));
        // }else{
        //     Timer.delay(haxe.MainLoop.add.bind(webSocketMessage.bind(msg)),100);
        // }
        // Timer.delay(webSocketMessageHandle.bind(msg),0);
    }

    function processWebsocketMessages(){
        while(webSocketMessages.length>0 && haxe.MainLoop.threadCount<25){
            var cm = webSocketMessages.shift();
            haxe.MainLoop.addThread(prepareWebSocketMessage.bind(cm));
        }
    }

    function prepareWebSocketMessage(msg:String){
        var m:WSMessage = Json.parse(msg);
        // trace(m);
        haxe.MainLoop.runInMainThread(handleWebSocketMessage.bind(m));
        // trace("cbt");
    }

    @:profile function handleWebSocketMessage(m:WSMessage) {
        // trace(m);
        // trace("cbt");
        try{
        // trace(m);
        switch(m.op) {
            case 10: 
                var seq = 0;

                if(hbThread!=null)
                    seq = hbThread.getSeq();

                if(resumeable) {
                    //trace("Resuming");
                    sendWs(WSPrepareData.Resume(token, session, seq));
                }else{
                    //trace("Identifying");
                    sendWs(WSPrepareData.Identify(token,shardInfo));
                }

                hbThread = new HeartbeatThread(m.d.heartbeat_interval, ws, seq, this);
            case 9:
                trace("Session was invalidated, killing.");
                resumeable = !m.d;
                ws.close();
            case 0:
                receiveEvent(m);
            case 11:
                this.ws_latency = Sys.time()-this.lastbeat;
                this.reconnectTimeout = 1;
            default:
        }
        }catch(er:Dynamic){
            trace("UNCAUGHT ERROR IN EVENT CALLBACK.");
            trace(Std.string(er)+haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
        }
    }

    @:dox(hide)
    function receiveEvent(msg) {
        var m:WSMessage = msg;
        var d:Dynamic;
        d = m.d;
        // trace(m.t);
        hbThread.setSeq(m.s);

        onRawEvent(m.t, d);

        switch(m.t) {
            case "READY":
                //TODO save the session, for resumes.
                var re:WSReady = d;
                for(g in re.guilds) {
                    _newGuild(g);
                }
                user = _newUser(re.user);

                session = re.session_id;
                resumeable = true;

                trace(re.guilds);
                unavailableGuilds = re.guilds.filter(function(g){return g.unavailable;}).length; //assume all guilds unavail
                
                if(re.guilds.length == 0) {
                    ready=true;
                    _onReady();
                }
            case "RESUMED": 
                ready = true;
            case "CHANNEL_CREATE":
                onChannelCreate(_newChannel(d));
            case "CHANNEL_UPDATE":
                onChannelUpdate(_newChannel(d));
            case "CHANNEL_PINS_UPDATE":
                
                //TODO this
            case "CHANNEL_DELETE":
                removeChannel(d);
                onChannelDelete(d);
            case "GUILD_CREATE":
                if(ready){
                    if(dataCache.getGuild(d.id) == null){
                        var g:Guild = _newGuild(d);
                        onGuildCreate(g);
                        onGuildJoin(g);
                    }
                }else{
                    var g = _newGuild(d);
                    onGuildCreate(g);
                    //Wait for all guilds to be loaded before readying. Might cause problems if guilds are genuinely unavailable so maybe check if name is set too
                    
                    //TODO this more efficiently
                    unavailableGuilds = dataCache.getAllGuilds().filter(function(g){return g.unavailable;}).length; //assume all guilds unavail
                    var done = unavailableGuilds==0;
                    if( done && !ready ) {
                        ready = true;
                        _onReady();
                    }
                }
            case "GUILD_UPDATE":
                onGuildUpdate(_newGuild(d));
            case "GUILD_DELETE":
                onGuildLeave(getGuildUnsafe(d.id));
                onGuildDelete(d.id);
                removeGuild(d.id);
            case "GUILD_BAN_ADD":
                var u = getUserUnsafe(d);
                var g = getGuildUnsafe(d.guild_id);
                g._addBan(u);
                onMemberBan(g, u);
            case "GUILD_BAN_REMOVE":
                var u = getUserUnsafe(d);
                var g = getGuildUnsafe(d.guild_id);
                g._removeBan(u);
                onMemberUnban(g,u);
            case "GUILD_EMOJIS_UPDATE":
                var g = getGuildUnsafe(d.guild_id);
                g._updateEmojis(d.emojis);
                onGuildEmojisUpdate(g,d.emojis);
            case "GUILD_INTEGRATIONS_UPDATE": 
                //TODO this
            case "GUILD_MEMBER_ADD":
                var g = getGuildUnsafe(d.guild_id);
                _newUser(d.user);
                onMemberJoin(g, g._newMember(d));
            case "GUILD_MEMBER_REMOVE":
                var g = getGuildUnsafe(d.guild_id);
                g.members.remove(d.user.id);
                onMemberLeave(g, getUserUnsafe(d.user.id)); 
            case "GUILD_MEMBER_UPDATE":
                var g = getGuildUnsafe(d.guild_id);
                onMemberUpdate(g, g._newMember(d));
            case "GUILD_MEMBERS_CHUNK": 
                var members:Array<com.raidandfade.haxicord.types.structs.GuildMember> = d.members;
                var g = getGuildUnsafe(d.guild_id);
                for(m in members) {
                    onMemberJoin(g, g._newMember(m));
                }
            case "GUILD_ROLE_CREATE":
                var g = getGuildUnsafe(d.guild_id);
                onRoleCreate(g, g._newRole(d.role));
            case "GUILD_ROLE_UPDATE":
                var g = getGuildUnsafe(d.guild_id);
                onRoleUpdate(g, g._newRole(d.role));
            case "GUILD_ROLE_DELETE":
                var g = getGuildUnsafe(d.guild_id);
                g.roles.remove(d.role_id);
                onRoleDelete(g, d.role_id);
            case "MESSAGE_CREATE":
                onMessage(_newMessage(d));
            case "MESSAGE_UPDATE":
                if(dataCache.getMessage(d.id) != null)
                    onMessageEdit(_newMessage(d));
            case "MESSAGE_DELETE":
                removeMessage(d);
                onMessageDelete(d);
            case "MESSAGE_DELETE_BULK":
                var msgs:Array<String> = d.ids;
                for(m in msgs) {
                    removeMessage(m);
                    onMessageDelete(m);
                }
            case "MESSAGE_REACTION_ADD": 
                getMessage(d.message_id, d.channel_id, function(m) {
                    m._addReaction(getUserUnsafe(d.user_id), d.emoji);
                    onReactionAdd(m, getUserUnsafe(d.user_id), d.emoji);
                });
            case "MESSAGE_REACTION_REMOVE": 
                getMessage(d.message_id, d.channel_id, function(m) {
                    m._delReaction(getUserUnsafe(d.user_id), d.emoji);
                    onReactionRemove(m, getUserUnsafe(d.user_id), d.emoji);
                });
            case "MESSAGE_REACTION_REMOVE_ALL": 
                getMessage(d.message_id, d.channel_id, function(m) {
                    for(r in m.reactions) {
                        //trace(d.who + "-" + d.emoji);
                        if(d.who != null)
                            onReactionRemove(m, getUserUnsafe(d.who), d.emoji);
                        else
                            onReactionRemove(m, null, d.emoji);
                    }
                    m._purgeReactions();
                });
            case "PRESENCE_UPDATE": // user
                var m = getGuildUnsafe(d.guild_id).getMemberUnsafe(d.user.id);
                if(m != null)
                    m._updatePresence(d);
            case "TYPING_START": // event
                try{
                    onTypingStart(getUserUnsafe(d.user_id), getChannelUnsafe(d.channel_id), d.timestamp);
                }catch(e:Dynamic){
                    //this is a problem with shardid != 0 getting DM CHANNEL typing_starts.
                    // idk what to do about this.
                }
            case "USER_UPDATE": // never seen this so idk how to handle it.
                trace("User Changed");
                trace(d);
            case "VOICE_STATE_UPDATE": // ... yeah i'll definitely do voice for sure
            case "VOICE_SERVER_UPDATE": // ... yeah i'll definitely do voice for sure
            case "WEBHOOKS_UPDATE": //eventually...

            case "PRESENCES_REPLACE", "CHANNEL_PINS_ACK": // User only.
            default:
                trace("Unhandled event " + m.t);
        }
    }

    //Misc funcs that cant fit anywhere else

    /**
        Set the status of the bot
        @param status - The status object to set, All fields are optional
     */
    public function setStatus(status:Status) {
        var msg = {
            "op": 3,
            "d": status
        }

        if(msg.d.status == null) 
            msg.d.status = user.presence.status;

        if(msg.d.afk == null) 
            msg.d.afk = false;
        
        if(msg.d.since == null)
            msg.d.since = null;

        if(msg.d.game == null) 
            msg.d.game = null;

        sendWs(msg);
    }

    /**
        Set the activity of the bot
        @param activity - The activity object to set
     */
    public function setActivity(activity:Activity) {
        setStatus({"game":activity});
    }
    /**
        Get the invite link of the bot.
        @param perms=0 - The permissions to put on the link.
     */
    public function getInviteLink(perms = 0) {
        var clid = this.user.id.id;
        
        var permstr = "";
        if(perms != 0)
            permstr = "&perms=" + perms;

        return "https://discordapp.com/api/oauth2/authorize?client_id=" + clid + "&scope=bot" + permstr;
    }
    /**
        Get a list of voice regions.
        @param cb - Returns a list of voice regions, or an error.
     */
    public function listVoiceRegions(cb) {
        endpoints.listVoiceRegions(cb);
    }

    /**
        Create a new guild based on the data given
        @param guild_data - The data to be changed, All fields are optional.
        @param cb - Returns the new guild object, or an error.
     */
    public function createGuild(guild_data, cb) {
        endpoints.createGuild(guild_data, cb);
    }

    /**
        Send a message to a channel
        @param channel_id - The channel to send to
        @param message - Message data
        @param cb - Return the message sent, or an error
     */
    public function sendMessage(channel_id, message, cb = null) {
        var udmch = dataCache.getUserDMChannel(channel_id);
        if(udmch != null)
            endpoints.sendMessage(udmch, message,cb);
        else{
            var u = dataCache.getUser(channel_id);
            if(u != null)
                endpoints.createDM({recipient_id: channel_id},function(ch, e) {
                    ch.sendMessage(message, cb);
                });
            else 
                endpoints.sendMessage(channel_id, message, cb);
        }
    }

     /**
        Get information about an invite code.
        @param invite_code - The invite code.
        @param cb - Returns an Invite object, or an error.
     */
    public function getInvite(invite_code, cb = null) {
        endpoints.getInvite(invite_code, cb);
    }

    /**
        (NOT AVAILABLE FOR BOTS) Accept an invite code and join the server.
        @param invite_code - The invite code to join.
        @param cb - Returns the invite that was joined, or an error.
     */
    public function joinInvite(invite_code, cb = null) {
        if(isBot) return;

        endpoints.acceptInvite(invite_code, cb);
    }

    /**
        Delete an invite based on it's invite code. Requires the MANAGE_CHANNELS permission in the guild the invite is from.
        @param invite_code - The invite code of the invite to delete.
        @param cb - Returns the Invite that was removed, or an error.
     */
    public function deleteInvite(invite_code, cb = null) {
        endpoints.deleteInvite(invite_code, cb);
    }

    /**
        Create a DM group. 
        @param data - A struct that contains the necessary arguments required to invite members.
        @param cb - Returns the group dm channel, or an error.
     */
    public function createDMGroup(data, cb = null) {
        endpoints.createGroupDM(data, cb);
    }

    //User @me Endpoints

    /**
        Edit the current user's settings.
        @param user_data - The parameters to change, all fields are optional.
        @param cb - Return the changed user, or an error.
     */
    public function editUser(user_data, cb = null) {
        endpoints.editUser(user_data, cb);
    }

    /**
        Get a list of all guilds that the current user is in. Normal users do not need to use the filter and can leave it blank `{}`
        @param filter - Filter the list depending on these parameters, Only one of BEFORE or AFTER can be specified.
        @param cb - Returns the list of Guilds according to the filter specified, or an error.
     */
    public function getGuilds(filter, cb = null) {
        endpoints.getGuilds(filter, cb);
    }

    /**
        Get a list of connections hooked up to the current account.
        @param cb - Returns a list of connections, or an error.
     */
    public function getConnections(cb = null) {
        endpoints.getConnections(cb);
    }

    @:dox(hide)
    @:profile public function removeChannel(id) {
        //remove from guild too.
        var c = dataCache.getChannel(id);
        if(c != null && c.type != 1) {
            var gc = cast(c, GuildChannel);
            var g = gc.getGuild();
            if(gc.type == 0) {
                g.textChannels.remove(c.id.id);
            }else{
                g.voiceChannels.remove(c.id.id);
            }
        }
        dataCache.delChannel(id);
    }

    @:dox(hide)
    public function removeMessage(id) {
        dataCache.delMessage(id);
    }

    @:dox(hide)
    public function removeGuild(id) {
        dataCache.delGuild(id);
    }

    @:dox(hide)
    public function removeUser(id) {
        dataCache.delUser(id);
    }

    /**
        Get a guild from cache if it's there otherwise load from API.
        @param id - The id of the desired guild.
        @param cb - The Callback to return the guild to.
     */
    public function getGuild(id, cb: Guild->Void) {
        var g = dataCache.getGuild(id);
        if(g != null) {
            cb(g);
        }else{
            endpoints.getGuild(id, function(r, e) {
                if(e != null) throw(e);
                cb(r);
            });
        }
    }

    /**
        Unsafely get a guild from cache based on it's id.
        Throws an error if the guild is not cached.
        @param id - The id of the desired guild
     */
    public function getGuildUnsafe(id) {
        var g = dataCache.getGuild(id);
        if(g != null) {
            return g;
        }else{
            throw "Guild not in cache. try loading it safely first!";
        }
    }

    /**
        Get a list of all dm channels the bot is in.
        @param cb - Callback to return the channels to.
     */
    public function getDMChannels(cb:Array<DMChannel>->Void) {
        endpoints.getDMChannels(function(r, e) {
            if(e != null) throw(e);
            cb(r);
        });
    }
    
    /**
        Get a list of all DMChannels currently in cache
     */
    public function getDMChannelsUnsafe() {
        return dataCache.getAllDMChannels();
    }

    /**
        Get a channel from cache if it's there otherwise get from the API.
        @param id - The id of the desired channel.
        @param cb - The callback to return the channel to.
     */
    public function getChannel(id, cb:Channel->Void) {
        var c = dataCache.getChannel(id);
        if(c != null) {
            cb(c);
        }else{
            endpoints.getChannel(id, function(r, e) {
                if(e != null) throw(e);
                cb(r);
            });
        }
    }

    /**
        Unsafely get a channel from cache based on it's id.
        Throws an error if the channel could not be loaded.
        @param id - The id of the desired channel.
     */
    public function getChannelUnsafe(id) {
        var c = dataCache.getChannel(id);
        if(c != null) {
            return c;
        }else{
            c = dataCache.getDMChannel(id);
            if(c != null){
                return c;
            }else{
                throw "Channel not in cache. try loading it safely first!";
            }
        }
    }

    /**
        Get a user from cache if it's there otherwise get from API.
        @param id - The id of the desired user.
        @param cb - The callback to return the user to.
     */
    public function getUser(id,cb:User->Void) {
        var u = dataCache.getUser(id);
        if(u != null) {
            cb(u);
        }else{
            endpoints.getUser(id, function(r, e) {
                if(e != null) throw(e);
                dataCache.setUser(id,r);
                cb(r);
            });
        }
    }

    /**
        Unsafely get a user based on it's id from cache.
        Throws an error if the user could not be loaded.
        @param id - The id of the desired user.
     */
    public function getUserUnsafe(id,partial=true) {
        var u = dataCache.getUser(id);
        if(u != null) {
            return u;
        }else{
            if(partial){
                var u = new User(null,this);
                u.id = new Snowflake(id);
                return u;
            }else{
                throw "User not in cache. try loading it safely first!";
            }
        }
    }

    /**
        Get a message from cache if it is there otherwise load from api.
        @param id - The id of the message.
        @param channel_id - The id of the channel the message is from.
        @param cb - The callback to return the message to.
     */
    public function getMessage(id, channel_id, cb: Message->Void) {
        var m = dataCache.getMessage(id);
        if(m != null) {
            cb(m);
        }else{
            endpoints.getMessage(channel_id, id, function(r, e) {
                if(e != null) throw(e);
                cb(r);
            });
        }
    }

    /**
        Unsafely get a message based on it's id from cache.
        Throws an error if the message could not be loaded.
        @param id - The id of the desired message.
     */
    public function getMessageUnsafe(id) {
        var m = dataCache.getMessage(id);
        if(m != null) {
            return m;
        }else{
            throw "Message not in cache. try loading it safely first!";
        }
    }

    //"constructors"
    //Channels in client cache should be updated in guild cache.

    @:dox(hide)
    public function _newMessage(message_struct: com.raidandfade.haxicord.types.structs.MessageStruct) {
        var id = message_struct.id;
        //trace("NEW MESSAGE: "+id);
        var m = dataCache.getMessage(id);
        if(m != null) {
            m._update(message_struct);
            return m;
        }else{
            var msg = new Message(message_struct, this);
            dataCache.setMessage(id, msg);
            return msg;
        }
    }

    @:dox(hide)
    public function _newUser(user_struct: com.raidandfade.haxicord.types.structs.User) {
        var id = user_struct.id;
        //trace("NEW USER: "+id);
        var u = dataCache.getUser(id);
        if(u != null) {
            u._update(user_struct);
            return u;
        }else{
            var user = new User(user_struct, this);
            dataCache.setUser(id, user);
            return user;
        }
    }

    @:dox(hide)
    public function _newChannel(channel_struct) {
        return __newChannel(channel_struct)(channel_struct);
    }

    @:dox(hide)
    public function __newChannel(channel_struct: Dynamic): Dynamic->Channel{
        if(channel_struct.type == "text" || channel_struct.type == "voice") {
            channel_struct.type = channel_struct.type == "text" ? 0 : 2 ;
        }
        var id = channel_struct.id;
        if(channel_struct.type == 1) return _newDMChannel;
        var chan = dataCache.getChannel(id);
        if(chan!=null) {
            var c = cast(chan,GuildChannel);
            if(c.type == 0) //Is it a text?
                cast(chan, TextChannel)._update(channel_struct);
            else if(c.type == 2) //Is it voice?
                cast(chan, VoiceChannel)._update(channel_struct);
            else //It must be category
                cast(chan, CategoryChannel)._update(channel_struct);
            return function(c, _) {
                return c;
            }.bind(c, _);
        }else{
            var channel = Channel.fromStruct(channel_struct)(channel_struct, this);
            dataCache.setChannel(id, channel);
            var c = cast(channel, GuildChannel);
            try {
                getGuildUnsafe(c.guild_id.id)._addChannel(c);
            } catch(e: Dynamic) {} //Not important if guild is part of unsafe get channel
            
            return function(_) {
                return channel;
            };
        }
    }

    @:dox(hide)
    public function _newDMChannel(channel_struct: com.raidandfade.haxicord.types.structs.DMChannel) {
        var id = channel_struct.id; 
        var dmch = dataCache.getDMChannel(id);
        if(dmch != null) {
            dmch._update(channel_struct);
            return dmch;
        }else{
            var channel = DMChannel.fromStruct(channel_struct, this);
            dataCache.setDMChannel(id, channel);
            if(channel.recipient != null) 
                dataCache.setUserDMChannel(channel.recipient.id.id, id);
            else if(channel.recipients != null && channel.recipients.length == 1)
                dataCache.setUserDMChannel(channel.recipients[0].id.id, id);

            return channel;
        }
    }

    @:dox(hide)
    public function _newGuild(guild_struct: com.raidandfade.haxicord.types.structs.Guild) {
        var id = guild_struct.id;
        var g = dataCache.getGuild(id);
        // if(!guild_struct.unavailable)
        //     trace("New guild Object "+guild_struct.name+"("+id+")");
        if(g!=null) {
            g._update(guild_struct);
            return g;
        }else{
            var guild = new Guild(guild_struct, this);
            dataCache.setGuild(id, guild);
            return guild;
        }
    }

    //Events 

    public dynamic function _onReady() {onReady();}
    /**
        Event hook for when the bot has connected, loaded cache, and is ready to go.
     */
    public dynamic function onReady() {}

    /**
        Event hook for when a new channel is created.
        @param c - The channel object. 
     */
    public dynamic function onChannelCreate(c: Channel) {}
    /**
        Event hook for when a channel is changed/updated.
        @param c - The new channel object.
     */
    public dynamic function onChannelUpdate(c: Channel) {}
    /**
        Event hook for when a channel is deleted.
        @param channel_id - The id of the deleted channel.
     */
    public dynamic function onChannelDelete(channel_id: String) {}

    /**
        NON-API Event hook for when a guild has been joined by you.
        @param g - The guild object.
     */
    public dynamic function onGuildJoin(g: Guild) {}

    /**
        NON-API Event hook for when a guild has been joined by you.
        @param g - The guild object.
     */
    public dynamic function onGuildLeave(g: Guild) {}

    /**
        Event hook for when a guild is created or joined by you, fired when bot is starting up as well.
        @param g - The guild object.
     */
    public dynamic function onGuildCreate(g: Guild) {}
    /**
        Event hook for when a guild is updated or changed.
        @param g - The new guild object.
     */
    public dynamic function onGuildUpdate(g: Guild) {}
    /**
        Event hook for when a guild is deleted
        @param guild_id - The id of the guild that was deleted.
     */
    public dynamic function onGuildDelete(guild_id: String) {}
    /**
        Event hook for when a guild updates it's emojis. 
        @param g - The guild the emojis were updated for.
        @param emojis - The new list of emojis
     */
    public dynamic function onGuildEmojisUpdate(g: Guild, emojis: Array<Emoji>) {}

    /**
        Event hook for when a new user joins a guild.
        @param g - The guild the user has joined.
        @param m - The instanced member object of the user.
     */
    public dynamic function onMemberJoin(g: Guild, m: GuildMember) {}
    /**
        Event hook for when a user is updated or changed. 
        @param g - The guild the user is in.
        @param m - The instanced member object of the user.
     */
    @:profile public dynamic function onMemberUpdate(g: Guild, m: GuildMember) {}
    /**
        Event hook for when a user is banned from a guild.
        @param g - The guild the ban was from.
        @param u - The user that was banned (May be null).
     */
    public dynamic function onMemberBan(g: Guild, u: Null<User>) {}
    /**
        Event hook for when a user is unbanned from a guild.
        @param g - The guild the ban was from.
        @param u - The user that was unbanned (May be null).
     */
    public dynamic function onMemberUnban(g: Guild, u: Null<User>) {}
    /**
        Event hook for when a member leaves a guild.
        @param g - The guild the member belonged to.
        @param u - The user of the member (May be null).
     */
    public dynamic function onMemberLeave(g: Guild, u: Null<User>) {}

    /**
        Event hook for when a role is created.
        @param g - The guild it was created in.
        @param r - The role.
     */
    public dynamic function onRoleCreate(g: Guild, r: Role) {}
    /**
        Event hook for when a role is changed/updated
        @param g - The guild it was updated in.
        @param r - The new role.
     */
    public dynamic function onRoleUpdate(g: Guild, r: Role) {}
    /**
        Event hook for when a role is deleted
        @param g - The guild it was deleted from.
        @param role_id - The id of the role that was deleted.
     */
    @:profile public dynamic function onRoleDelete(g: Guild, role_id: String) {}

    /**
        Event hook for when a message is sent.
        @param m - The message.
     */
    public dynamic function onMessage(m: Message) {}
    /**
        Event hook for when a message is edited.
        @param m - The new message.
     */
    public dynamic function onMessageEdit(m: Message) {}
    /**
        Event hook for when a message is deleted.
        @param message_id - The id of the deleted message.
     */
    public dynamic function onMessageDelete(message_id: String) {}

    /**
        Event hook for when a reaction is added.
        @param m - The message the reaction is added to.
        @param u - The user that added the reaction.
        @param e - The emoji of the reaction.
     */
    public dynamic function onReactionAdd(m: Message, u: User, e: com.raidandfade.haxicord.types.structs.Emoji) {}
    /**
        Event hook for when reactions are removed.
        @param m - The message the reaction was removed from.
        @param u - The user that removed the reaction. (Do not rely on this for purges, may be null)
        @param e - The emoji of the reaction.
     */
    public dynamic function onReactionRemove(m: Message, u: Null<User>, e: com.raidandfade.haxicord.types.structs.Emoji) {}
    /**
        Event hook for when reactions are purged from a message.
        @param m - The message that was purged.
     */
    public dynamic function onReactionPurge(m: Message) {}


    /**
        Event hook for when someone starts typing
        @param u - The user who started typing
        @param c - The channel they are typing in
        @param t - Timestamp of when they started typing (in seconds)
     */
    public dynamic function onTypingStart(u: User, c: Channel, t: Int) {}

    /**
        A raw event hook, for things that require a little more flexibility.
        @param e - The event name as defined by API Docs.
        @param d - The event data.
     */
    public dynamic function onRawEvent(e: String, d: Dynamic) {}

}

private typedef WSMessage = {
    var op:Int;
    var d:Dynamic;
    var s:Int;
    var t:String;
}

private class WSPrepareData {
    public static function Identify(t: String, s: WSShard = null, p: WSIdentify_Properties = null, c: Bool = false, l: Int = 59) {
        if(p == null) 
            p = {
                "$os": "", 
                "$browser": DiscordClient.libName,
                "$device": DiscordClient.libName,
                "$referrer": "",
                "$referring_domain": ""
                };

        if(s == null) 
            s = [0, 1];

        return {
                "op": 2,
                "d": {
                    "token": t,
                    "properties": p,
                    "compress": c,
                    "large_threshhold": l,
                    "shard":s 
                    }
                };
    }

    public static function Resume(token: String, session_id: String, sequence: Int){
        return {
            "op": 6,
            "d" : {
                "token": token,
                "session_id": session_id,
                "seq": sequence
            }
        };
    }



    public static function Heartbeat(seq = null) {
        return {"op": 1, "d": seq};
    }
}

private typedef WSShard = Array<Int>;

private typedef WSIdentify_Properties = {
    @:optional var os: String;
    @:optional var browser: String;
    @:optional var device: String;
    @:optional var referrer: String;
    @:optional var referring_domain: String;
}

private typedef WSReady = {
    @:optional var v: Int;
    @:optional var user_settings: Dynamic;
    @:optional var user: com.raidandfade.haxicord.types.structs.User;
    @:optional var shard: Array<Int>;
    @:optional var session_id: String;
    @:optional var relationships: Dynamic;
    @:optional var private_channels: Array<com.raidandfade.haxicord.types.structs.DMChannel>;
    @:optional var presences: Array<com.raidandfade.haxicord.types.structs.Presence>;
    @:optional var guilds: Array<com.raidandfade.haxicord.types.structs.Guild>;
    @:optional var _trace: Dynamic;
}

private class HeartbeatThread { 
    public var delay: Float;

    var seq: Null<Int>;
    var ws: WebSocketConnection;
    var timer: Timer;
    var cl: DiscordClient;
    var l:Float;

    var paused: Bool;

    public function setSeq(_s) {
        seq = _s;
    }

    public function getSeq() {
        return seq;
    } 

    public function new(_d, _w, _s, _b) {
        delay = _d/1000-2;
        ws = _w;
        seq = _s;
        cl = _b;
        cl.lastbeat=Sys.time();
        timer = new Timer(2000);
        timer.run = beat;
    }

    public function beat() {
        // trace("tick");
        if(Sys.time()-cl.lastbeat<delay)
            return;
        // trace("hb");
        cl.lastbeat = Sys.time();
        ws.sendJson(WSPrepareData.Heartbeat(seq));
    }

    public function pause() {
        paused = true;
        timer.stop();
    }

    public function resume() {
        beat();
        timer = new Timer(2000);
        timer.run = beat;
    }
}