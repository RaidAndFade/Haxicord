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
import com.raidandfade.haxicord.types.structs.Emoji;

import haxe.Json;
import haxe.Timer;

/*TODO to get into dapi

Gateway version != 7 -done
Don't support < gateway 6 -done
RESUMEs - done
GLOBAL RATELIMIT shouldn't be hardcoded - done
Add some spaces -done (not structs)
*/

/*
TODO long term
- uploading files raw to messages
- connect to GW first and then do the rest
*/

@:keep
@:expose
class DiscordClient { 
     /**
      The name of the library
     */
    public static var libName:String = "Haxicord";
    /**
      The library's useragent
     */
    public static var userAgent:String = "DiscordBot (https://github.com/RaidAndFade/Haxicord, 0.1.1)";
    /**
      The gateway version being used.
     */
    public static var gatewayVersion:Int = 6;
    
    //cache arrays (id,object)
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
    public var userDMChannels:Map<String,String> = new Map<String,String>();//put this in somewhere.
    
    @:dox(hide)
    public var ready = false;

    @:dox(hide)
    public var session = "kek";

    @:dox(hide)
    public var canResume:Bool;

    @:dox(hide)
    public var resumeable = false;

    /**
        The bot user, this is you.
     */
    public var user:User; //me

    @:dox(hide)
    public var token:String;
    
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

    /**
        Initialize the bot with your token. This should be the first thing you run in your program.
        @param _tkn - Your BOT token. User tokens do not work!
     */
    public function new(_tkn:String) { //Sharding? lol good joke.
        Logger.registerLogger();

        token = _tkn; //ASSUME BOT FOR NOW. Deal with users later maybe.
        isBot = true;
        
        endpoints = new Endpoints(this);

        //trace("Getting gotten");
        endpoints.getGateway(isBot, connect);
    }
    
    /**
        This is basically just a while true loop to keep the main thread alive while the other threads work.
        @param blocking=true - If you dont want to have the while loop activate, set this to false and make your own loop.
     */
    public function start(blocking=true) {
#if sys
        while(blocking) {
            Sys.sleep(1);
        }
#end
    }
//Flowchart
    @:dox(hide)
    function connect(gateway, error) {
        if(error != null) throw error; 
        //trace("Gottening");
        ws = new WebSocketConnection(gateway.url + "/?v=" + gatewayVersion + "&encoding=json");
        ws.onMessage = webSocketMessage;

        ws.onClose = function(m) {
            trace(m);
            if(hbThread != null) hbThread.pause();

            if(session == "") 
                resumeable = false; //can't be resumed if i don't have a session

            trace("Socket Closed, Re-Opening in " + reconnectTimeout + "s. " + (resumeable?"Resuming":""));

            Timer.delay(endpoints.getGateway.bind(isBot, connect), reconnectTimeout * 2000);
            
            reconnectTimeout *= 2; //double every time it dies.
        }

        ws.onError = function(e) {
            resumeable = false;

            trace("Websocket errored!");
            trace(e);
        }
    }

    @:dox(hide)
    function webSocketMessage(msg) {
        //trace(msg);
        var m:WSMessage = Json.parse(msg);
        switch(m.op) {
            case 10: 
                var seq = 0;

                if(hbThread!=null)
                    seq = hbThread.getSeq();

                if(resumeable) {
                    trace("Resuming");
                    ws.sendJson(WSPrepareData.Resume(token, session, seq));
                }else{
                    trace("Identifying");
                    ws.sendJson(WSPrepareData.Identify(token));
                }

                hbThread = new HeartbeatThread(m.d.heartbeat_interval, ws, seq, this);
            case 9:
                resumeable = !m.d;
                ws.close();
            case 0:
                receiveEvent(m);
            default:
        }
    }

    @:dox(hide)
    function receiveEvent(msg) {
        var m:WSMessage = msg;
        var d:Dynamic;
        d = m.d;
        //trace(m.t);
        hbThread.setSeq(m.s);

        onRawEvent(m.t, d);

        switch(m.t) {
            case "READY":
                //TODO save the session, for resumes.
                var re:WSReady = d;
                for(g in re.guilds) {
                    _newGuild(g);
                }
                user=_newUser(re.user);

                session = re.session_id;
                resumeable = true;

                if(re.guilds.length == 0) {
                    ready=true;
                    onReady();
                }
            case "RESUMED": 
                ready = true;
            case "CHANNEL_CREATE":
                onChannelCreate(_newChannel(d));
            case "CHANNEL_UPDATE":
                onChannelUpdate(_newChannel(d));
            case "CHANNEL_DELETE":
                removeChannel(d);
                onChannelDelete(d);
            case "GUILD_CREATE":
                onGuildCreate(_newGuild(d));
                //Wait for all guilds to be loaded before readying. Might cause problems if guilds are genuinely unavailable so maybe check if name is set too
                var done = true;
                for(g in guildCache) {
                    if(g.unavailable) {
                        done = false;
                        break;
                    }
                }
                if( done && !ready ) {
                    ready = true;
                    onReady();
                }
            case "GUILD_UPDATE":
                onGuildUpdate(_newGuild(d));
            case "GUILD_DELETE":
                removeGuild(d.id);
                onGuildDelete(d.id);
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
                        trace(d.who + "-" + d.emoji);
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
                
            case "USER_UPDATE": // user
            case "VOICE_STATE_UPDATE": // ...
            case "VOICE_SERVER_UPDATE": // ...
            default:
                trace("Unhandled event " + m.t);
        }
    }

    //Misc funcs that cant fit anywhere else

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
        if(userDMChannels.exists(channel_id))
            endpoints.sendMessage(userDMChannels.get(channel_id), message,cb);
        else if(userCache.exists(channel_id))
            endpoints.createDM({recipient_id: channel_id},function(ch, e) {
                ch.sendMessage(message, cb);
            });
        else 
            endpoints.sendMessage(channel_id, message, cb);
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
    public function removeChannel(id) {
        //remove from guild too.
        var c = channelCache.get(id);
        if(c != null && c.type != 1) {
            var gc = cast(c, GuildChannel);
            var g = gc.getGuild();
            if(gc.type == 0) {
                g.textChannels.remove(c.id.id);
            }else{
                g.voiceChannels.remove(c.id.id);
            }
        }
        channelCache.remove(id);
    }

    @:dox(hide)
    public function removeMessage(id) {
        messageCache.remove(id);
    }

    @:dox(hide)
    public function removeGuild(id) {
        guildCache.remove(id);
    }

    @:dox(hide)
    public function removeUser(id) {
        userCache.remove(id);
    }

    /**
        Get a guild from cache if it's there otherwise load from API.
        @param id - The id of the desired guild.
        @param cb - The Callback to return the guild to.
     */
    public function getGuild(id, cb: Guild->Void) {
        if(guildCache.exists(id)) {
            cb(guildCache.get(id));
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
        if(guildCache.exists(id)) {
            return guildCache.get(id);
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
        return [for(dm in dmChannelCache.iterator()) dm];
    }

    /**
        Get a channel from cache if it's there otherwise get from the API.
        @param id - The id of the desired channel.
        @param cb - The callback to return the channel to.
     */
    public function getChannel(id, cb:Channel->Void) {
        if(channelCache.exists(id)) {
            cb(channelCache.get(id));
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
        if(channelCache.exists(id)) {
            return channelCache.get(id);
        }else{
            throw "Channel not in cache. try loading it safely first!";
        }
    }

    /**
        Get a user from cache if it's there otherwise get from API.
        @param id - The id of the desired user.
        @param cb - The callback to return the user to.
     */
    public function getUser(id,cb:User->Void) {
        if(userCache.exists(id)) {
            cb(userCache.get(id));
        }else{
            endpoints.getUser(id, function(r, e) {
                if(e != null) throw(e);
                cb(r);
            });
        }
    }

    /**
        Unsafely get a user based on it's id from cache.
        Throws an error if the user could not be loaded.
        @param id - The id of the desired user.
     */
    public function getUserUnsafe(id) {
        if(userCache.exists(id)) {
            return userCache.get(id);
        }else{
            throw "User not in cache. try loading it safely first!";
        }
    }

    /**
        Get a message from cache if it is there otherwise load from api.
        @param id - The id of the message.
        @param channel_id - The id of the channel the message is from.
        @param cb - The callback to return the message to.
     */
    public function getMessage(id, channel_id, cb: Message->Void) {
        if(messageCache.exists(id)) {
            cb(messageCache.get(id));
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
        if(messageCache.exists(id)) {
            return messageCache.get(id);
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
        if(messageCache.exists(id)) {
            messageCache.get(id)._update(message_struct);
            return messageCache.get(id);
        }else{
            var msg = new Message(message_struct, this);
            messageCache.set(id, msg);
            return messageCache.get(id);
        }
    }

    @:dox(hide)
    public function _newUser(user_struct: com.raidandfade.haxicord.types.structs.User) {
        var id = user_struct.id;
        //trace("NEW USER: "+id);
        if(userCache.exists(id)) {
            userCache.get(id)._update(user_struct);
            return userCache.get(id);
        }else{
            var user = new User(user_struct, this);
            userCache.set(id, user);
            return userCache.get(id);
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
        if(channelCache.exists(id)) {
            var c = cast(channelCache.get(id),GuildChannel);
            if(c.type == 0) //Is it a text?
                cast(channelCache.get(id), TextChannel)._update(channel_struct);
            else if(c.type == 2) //Is it voice?
                cast(channelCache.get(id), VoiceChannel)._update(channel_struct);
            else //It must be category
                cast(channelCache.get(id), CategoryChannel)._update(channel_struct);
            return function(c, _) {
                return c;
            }.bind(c, _);
        }else{
            var channel = Channel.fromStruct(channel_struct)(channel_struct, this);
            channelCache.set(id, channel);
            var c = cast(channelCache.get(id), GuildChannel);
            try {
                getGuildUnsafe(c.guild_id.id)._addChannel(c);
            } catch(e: Dynamic) {} //Not important if guild is part of unsafe get channel
            
            return function(_) {
                return channelCache.get(id);
            };
        }
    }

    @:dox(hide)
    public function _newDMChannel(channel_struct: com.raidandfade.haxicord.types.structs.DMChannel) {
        var id = channel_struct.id; 
        if(dmChannelCache.exists(id)) {
            dmChannelCache.get(id)._update(channel_struct);

            return dmChannelCache.get(id);
        }else{
            var channel = DMChannel.fromStruct(channel_struct, this);
            dmChannelCache.set(id, channel);
            if(channel.recipient != null) 
                userDMChannels.set(channel.recipient.id.id, id);
            else if(channel.recipients != null && channel.recipients.length == 1)
                userDMChannels.set(channel.recipients[0].id.id, id);

            return dmChannelCache.get(id);
        }
    }

    @:dox(hide)
    public function _newGuild(guild_struct: com.raidandfade.haxicord.types.structs.Guild) {
        var id = guild_struct.id;

        if(guildCache.exists(id)) {
            guildCache.get(id)._update(guild_struct);
            return guildCache.get(id);
        }else{
            var guild = new Guild(guild_struct, this);
            guildCache.set(id, guild);
            return guildCache.get(id);
        }
    }

    //Events 

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
        Event hook for when a guild is created or joined by you.
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
    public dynamic function onMemberUpdate(g: Guild, m: GuildMember) {}
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
    public dynamic function onRoleDelete(g: Guild, role_id: String) {}

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
    public static function Identify(t: String, p: WSIdentify_Properties = null, c: Bool = false, l: Int = 59, s: WSShard = null) {
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
    public var delay: Int;

    var seq: Null<Int>;
    var ws: WebSocketConnection;
    var timer: Timer;
    var cl: DiscordClient;

    var paused: Bool;

    public function setSeq(_s) {
        seq = _s;
    }

    public function getSeq() {
        return seq;
    } 

    public function new(_d, _w, _s, _b) {
        delay = _d;
        ws = _w;
        seq = _s;
        cl = _b;
        timer = new Timer(delay);
        timer.run = beat;
    }

    public function beat() {
        ws.sendJson(WSPrepareData.Heartbeat(seq));
        cl.reconnectTimeout = 1;
    }

    public function pause() {
        paused = true;
        timer.stop();
    }

    public function resume() {
        beat();
        timer = new Timer(delay);
        timer.run = beat;
    }
}