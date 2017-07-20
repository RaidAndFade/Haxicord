package com.raidandfade.haxicord.endpoints;

import haxe.Json;
import haxe.Timer;

//TODO 

//TODO audit logs :
// put for BAN,  : ?reason sets audit log reason and ban reason
// UNBAN, KICK, 
// Header : X-Audit-Log-Reason = reason
// get logs - https://discordapp.com/api/v6/guilds/{guild_id}/bans/{user_id}?delete-message-days=1&reason=asd

import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.types.DMChannel;
import com.raidandfade.haxicord.types.Channel;
import com.raidandfade.haxicord.types.Guild;
import com.raidandfade.haxicord.types.User;
import com.raidandfade.haxicord.types.GuildMember;
import com.raidandfade.haxicord.types.Role;
import com.raidandfade.haxicord.types.structs.MessageStruct.Reaction;
import com.raidandfade.haxicord.types.structs.GuildChannel.Overwrite;
import com.raidandfade.haxicord.types.structs.Invite;
import com.raidandfade.haxicord.types.structs.Voice.VoiceRegion;
import com.raidandfade.haxicord.types.structs.GuildIntegration;
import com.raidandfade.haxicord.types.structs.GuildEmbed;
import com.raidandfade.haxicord.types.structs.Connection;
import com.raidandfade.haxicord.types.structs.Webhook;

import haxe.extern.EitherType;
#if (js&&nodejs)
import js.node.Https;
import js.node.Url;
import js.node.Querystring;
import haxe.DynamicAccess;
import js.node.http.IncomingMessage;
#elseif cs
//Refer to line 79 if you're confused.
@:classCode("void httpCallBack(System.IAsyncResult res){
                System.Tuple<System.Net.HttpWebRequest,global::haxe.lang.Function> r = (System.Tuple<System.Net.HttpWebRequest,global::haxe.lang.Function>)res.AsyncState; 
                try{
                System.Net.HttpWebResponse response = r.Item1.EndGetResponse(res) as System.Net.HttpWebResponse;
                using (var streamReader = new System.IO.StreamReader(response.GetResponseStream()))
                {
                    global::haxe.ds.StringMap<object> headers = new global::haxe.ds.StringMap<object>();

                    foreach (string n in response.Headers){
                        foreach(string s in response.Headers.GetValues(n)){
                            headers.@set(n.ToLower(),s);
                        }
                    }

                    var result = streamReader.ReadToEnd();
                    var status = response.StatusCode;
                    r.Item2.__hx_invoke3_o(default(double), status, default(double), result, default(double), headers);
                }
                }catch(System.Net.WebException e){
                    if(e.Status == System.Net.WebExceptionStatus.ProtocolError){
                        global::haxe.ds.StringMap<object> headers = new global::haxe.ds.StringMap<object>();
                        foreach (string n in e.Response.Headers){
                            foreach(string s in e.Response.Headers.GetValues(n)){
                                headers.@set(n.ToLower(),s);
                            }
                        }
                        r.Item2.__hx_invoke3_o(default(double), ((int)((System.Net.HttpWebResponse)e.Response).StatusCode), default(double), \"{\\\"status\\\":\\\"\"+((int)((System.Net.HttpWebResponse)e.Response).StatusCode)+\"\\\",\\\"error\\\":\\\"\"+((System.Net.HttpWebResponse)e.Response).StatusDescription+\"\\\"}\", default(double), headers);
                    }else{
                        System.Console.WriteLine(\"ERROR IN HTTPCALLBACK\");
                        System.Console.WriteLine(e);
                    }
                }
            }\n\n"
            )
#else
import haxe.Http;
#end

class Endpoints{

    var client:DiscordClient;

    public function new(_c:DiscordClient){
        client=_c;
    }

    var rateLimitCache:Map<String,RateLimit> = new Map<String,RateLimit>();
    var limitedQueue:Map<String,Array<EndpointCall>> = new Map<String,Array<EndpointCall>>();

//ACTUAL ENDPOINTS : 

//GATEWAY START
    /**
     *  Get the gateway that the client should connect to. 
     *  @param bot - Will get the bot gateway along with reccomended shard info if true.
     *  @param cb - The callback to call once gotten. Or null if result is not desired.
     */
    public function getGateway(bot=false,cb:Typedefs.Gateway->String->Void=null){ //y
        var endpoint = new EndpointPath("/gateway"+(bot?"/bot":""),[]);
        callEndpoint("GET",endpoint,cb);
    }

//CHANNEL START
    /**
     *  Get a channel based on a given channel id.
     *  @param channel_id - The channel id to get the channel from
     *  @param cb - Callback to send the receivied channel object to. Or null if result is not desired.
     */
    public function getChannel(channel_id:String,cb:Channel->String->Void=null){ //y
        var endpoint = new EndpointPath("/channels/{0}",[channel_id]);
        callEndpoint("GET",endpoint,function(ch,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else cb(client._newChannel(ch),null);
        });
    }

    /**
     *  Create a channel in a guild
     *  @param guild_id - The guild to create the channel in
     *  @param channel_data - The channel's starting data 
     *  @param cb - Callback to send the new channel object to. Or null if result is not desired.
     */
    public function createChannel(guild_id:String,channel_data:Typedefs.ChannelCreate,cb:EmptyResponseCallback=null){ //y
         //Requires manage_channels
        var endpoint = new EndpointPath("/guilds/{0}/channels",[guild_id]);
        callEndpoint("POST",endpoint,cb,channel_data);
    }

    /**
     *  Change a channel's parameters
     *  @param channel_id - The id of the channel to be modified
     *  @param channel_data - The changed channel data, all fields are optional
     *  @param cb - Callback to send the new channel object to. Or null if result is not desired.
     */
    public function modifyChannel(channel_id:String,channel_data:Typedefs.ChannelUpdate,cb:Channel->String->Void=null){ //y
         //Requires manage_channels
        var endpoint = new EndpointPath("/channels/{0}",[channel_id]);
        callEndpoint("PATCH",endpoint,function(ch,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else cb(client._newChannel(ch),null);
        },channel_data);
    }

    /**
     *  Delete the given channel.
     *  @param channel_id - Channel id of channel to delete
     *  @param cb - Callback to send old channel to. Or null if result is not desired.
     */
    public function deleteChannel(channel_id:String,cb:Channel->String->Void=null){ //y
         //Requires manage_channels
        var endpoint = new EndpointPath("/channels/{0}",[channel_id]);
        callEndpoint("DELETE",endpoint,function(ch,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else cb(client._newChannel(ch),null);
        });
    }

    /**
     *  Edit or Create a channel's overwrite permissions;
     *  @param channel_id - The channel
     *  @param overwrite_id - The overwrite Id, Id of user or role.
     *  @param new_permission - The modified overwrite permission object
     *  @param cb - Call once finished.
     */
    public function editChannelPermissions(channel_id:String,overwrite_id:String,new_permission:Overwrite,cb:EmptyResponseCallback=null){ //y
        //Requires manage_roles
        var endpoint = new EndpointPath("/channels/{0}/permissions/{1}",[channel_id,overwrite_id]);
        callEndpoint("PUT",endpoint,cb,new_permission); //204
    }
    /**
     *  Delete a channel override
     *  @param channel_id - The channel
     *  @param overwrite_id - The overwrite id to delete
     *  @param cb - Call once finished.
     */
    public function deleteChannelPermission(channel_id:String,overwrite_id:String,cb:EmptyResponseCallback=null){ //y
        //Requires manage_roles
        var endpoint = new EndpointPath("/channels/{0}/permissions/{1}",[channel_id,overwrite_id]);
        callEndpoint("DELETE",endpoint,cb); //204
    }

    /**
     *  Get the invites of a given channel
     *  @param channel_id - The channel
     *  @param cb - Array of Invites (or error).
     */
    public function getChannelInvites(channel_id:String,cb:Array<Invite>->String->Void=null){ //y
        //Requires manage_channels
        var endpoint = new EndpointPath("/channels/{0}/invites",[channel_id]);
        callEndpoint("GET",endpoint,cb);
    }

    /**
     *  Create a new invite for a given channel
     *  @param channel_id - The channel
     *  @param invite - The invite data.
     *  @param cb - Return the invite or an error.
     */
    public function createChannelInvite(channel_id:String,invite:Typedefs.InviteCreate,cb:EmptyResponseCallback=null){ //y
        //requires create_instant_invite
        var endpoint = new EndpointPath("/channels/{0}/invites",[channel_id]);
        callEndpoint("POST",endpoint,cb,invite);
    }

    /**
     *  Get the pins of a channel
     *  @param channel_id - The channel
     *  @param cb - Return an array of pins (or an error)
     */
    public function getChannelPins(channel_id:String,cb:Array<Message>->String->Void=null){
        var endpoint = new EndpointPath("/channels/{0}/pins",[channel_id]);
        callEndpoint("GET",endpoint,function(r:Array<com.raidandfade.haxicord.types.structs.MessageStruct>,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else{
                var msgs = [for(m in r){client._newMessage(m);}];
                cb(msgs,null);
            }
        });
    }

    /**
     *  Add a channel pin
     *  @param channel_id - The channel
     *  @param message_id - The message
     *  @param cb - Called once completed. Leave blank to ignore.
     */
    public function addChannelPin(channel_id:String,message_id:String,cb:EmptyResponseCallback=null){
        //requires manage_messages
        var endpoint = new EndpointPath("/channels/{0}/pins/{1}",[channel_id,message_id]);
        callEndpoint("PUT",endpoint,cb,"");
    }

    /**
     *  Delete a channel's pin
     *  @param channel_id - The channel
     *  @param message_id - The pin id
     *  @param cb - Called once completed. Leave blank to ignore.
     */
    public function deleteChannelPin(channel_id:String,message_id:String,cb:EmptyResponseCallback=null){
        //requires manage_messages
        var endpoint = new EndpointPath("/channels/{0}/pins/{1}",[channel_id,message_id]);
        callEndpoint("DELETE",endpoint,cb);
    }

//GROUPDM START
    
    /**
     *  Add a user to a group dm.
     *  @param channel_id - The group dm's channel.
     *  @param user_id - The user to be added.
     *  @param access_token - An OAUTH2 token received from authenticating the user.
     *  @param nick - The nickname of the user.
     *  @param cb - Called once completed.
     */
    public function groupDMAddRecipient(channel_id:String,user_id:String,access_token:String,nick:String,cb:EmptyResponseCallback=null){
        var endpoint = new EndpointPath("/channels/{0}/recipients/{1}",[channel_id,user_id]);
        callEndpoint("PUT",endpoint,cb,{"access_token":access_token,"nick":nick});
    }

    /**
     *  Remove a user from a group dm.
     *  @param channel_id - The group dm's channel.
     *  @param user_id - The user to be removed
     *  @param cb - Called once completed, or errored
     */
    public function groupDMRemoveRecipient(channel_id:String,user_id:String,cb:EmptyResponseCallback=null){
        var endpoint = new EndpointPath("/channels/{0}/recipients/{1}",[channel_id,user_id]);
        callEndpoint("DELETE",endpoint,cb);
    }

//MESSAGE START

    /**
     *  Get messages from a given channel according to the given format.
     *  @param channel_id - The channel
     *  @param format - Before, After, or Around. 
     *  @param cb - The array of messages, or an error.
     */
    public function getMessages(channel_id:String,format:Typedefs.MessagesRequest,cb:Array<Message>->String->Void=null){
        //Requires read_messages
        var endpoint = new EndpointPath("/channels/{0}/messages{1}",[channel_id,queryString(format)]);
        callEndpoint("GET",endpoint,function(r:Array<com.raidandfade.haxicord.types.structs.MessageStruct>,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else{
                var msgs = [for(m in r){client._newMessage(m);}];
                cb(msgs,null);
            }
        });
    }

    /**
     *  Get a message in a channel
     *  @param channel_id - The channel id
     *  @param message_id - The message id
     *  @param cb - Return the message, or an error.
     */
    public function getMessage(channel_id:String,message_id:String,cb:Message->String->Void=null){
        //Requires read_message_history
        var endpoint = new EndpointPath("/channels/{0}/messages/{1}",[channel_id,message_id]);
        callEndpoint("GET",endpoint,function(m,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else cb(client._newMessage(m),null);
        });
    }

    /**
     *  Send a message to a channel
     *  @param channel_id - The channel to send to
     *  @param message - Message data
     *  @param cb - Return the message sent, or an error
     */
    public function sendMessage(channel_id:String,message:Typedefs.MessageCreate,cb:Message->String->Void=null){
        //Requires send_messages
        var endpoint = new EndpointPath("/channels/{0}/messages",[channel_id]);
        callEndpoint("POST",endpoint,function(m,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else cb(client._newMessage(m),null);
        },message);        
    }

    /**
     *  Send a typing event in the given channel. This lasts for 10 seconds or when a message is sent, whichever comes first.
     *  @param channel_id - The channel to type in.
     *  @param cb - Return when complete.
     */
    public function startTyping(channel_id:String,cb:EmptyResponseCallback=null){
        //Requires send_messages
        var endpoint = new EndpointPath("/channels/{0}/typing",[channel_id]);
        callEndpoint("POST",endpoint,cb,{});        //204
    }

    /**
     *  Edit a message previously sent by you.
     *  @param channel_id - The channel the message is in.
     *  @param message_id - The id of the message desired to be changed.
     *  @param message - The new content of the message, all fields are optional.
     *  @param cb - Return the new message, or an error.
     */
    public function editMessage(channel_id:String,message_id:String,message:Typedefs.MessageEdit,cb:Message->String->Void=null){
        var endpoint = new EndpointPath("/channels/{0}/messages/{1}",[channel_id,message_id]);
        callEndpoint("PATCH",endpoint,function(m,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else cb(client._newMessage(m),null);
        },message);
    }

    /**
     *  Delete a given message. If the author is not the current user, the MANAGE_MESSAGES permission is required
     *  @param channel_id - The channel the message is in.
     *  @param message_id - The id of the message.
     *  @param cb - Return when complete.
     */
    public function deleteMessage(channel_id:String,message_id:String,cb:EmptyResponseCallback=null){
        //If !currentUser==author, requires Manage Messages
        var endpoint = new EndpointPath("/channels/{0}/messages/{1}",[channel_id,message_id]);
        callEndpoint("DELETE",endpoint,cb); //204
    }
    /**
     *  Delete a given messages. MANAGE_MESSAGES is required.
     *  @param channel_id - The channel the message is in.
     *  @param message_ids - an array of id of the messages.
     *  @param cb - Return when complete.
     */
    public function deleteMessages(channel_id:String,message_ids:Typedefs.MessageBulkDelete,cb:EmptyResponseCallback=null){
        //Requires manage_messages
        var endpoint = new EndpointPath("/channels/{0}/messages/bulk-delete",[channel_id]);
        callEndpoint("POST",endpoint,cb,message_ids); //204
    }

//REACTION START
    /**
     *  Add a reaction to a message. requires READ_MESSAGE_HISTORY and ADD_REACTIONS if the emoji is not already present.
     *  @param channel_id - The channel that contains the message.
     *  @param message_id - The message to react to.
     *  @param emoji - The emote to be added, Custom emotes require their TAG.
     *  @param cb - Called when completed, good for checking for errors.
     */
    public function createReaction(channel_id:String,message_id:String,emoji:String,cb:EmptyResponseCallback=null){
        //Requires read_message_history, and add_reactions if emoji not already on message
        var endpoint = new EndpointPath("/channels/{0}/messages/{1}/reactions/{2}/@me",[channel_id,message_id,emoji]);
        callEndpoint("PUT",endpoint,cb); //204
    }

    /**
     *  Delete a reaction of your own off of a message.
     *  @param channel_id - The channel that contains the message.
     *  @param message_id - The message to delete the reaction from.
     *  @param emoji - The emote to be removed. Custom emotes require their TAG
     *  @param cb - Called when completed, good for checking for errors.
     */
    public function deleteOwnReaction(channel_id:String,message_id:String,emoji:String,cb:EmptyResponseCallback=null){
        var endpoint = new EndpointPath("/channels/{0}/messages/{1}/reactions/{2}/@me",[channel_id,message_id,emoji]);
        callEndpoint("DELETE",endpoint,cb); //204
    }

    /**
     *  Delete another user's reaction off of a message.
     *  @param channel_id - The channel that contains the message.
     *  @param message_id - The message to delete the reaction from.
     *  @param user_id - The user to delete the reaction from.
     *  @param emoji - The emote to be removed. Custom emotes require their TAG
     *  @param cb - Called when completed, good for checking for errors.
     */
    public function deleteUserReaction(channel_id:String,message_id:String,user_id:String,emoji:String,cb:EmptyResponseCallback=null){
        //Requires MANAGE_MESSAGES
        var endpoint = new EndpointPath("/channels/{0}/messages/{1}/reactions/{2}/{3}",[channel_id,message_id,emoji,user_id]);
        callEndpoint("DELETE",endpoint,cb); //204
    }

    /**
     *  Get all reactions of emoji by user on a message.
     *  @param channel_id - The channel that contains the message.
     *  @param message_id - The message to get reactions from.
     *  @param emoji - The emoji to look for.
     *  @param cb - Returns an array of Reaction objects, or an error.
     */
    public function getReactions(channel_id:String,message_id:String,emoji:String,cb:Array<Reaction>->String->Void=null){
        var endpoint = new EndpointPath("/channels/{0}/messages/{1}/reactions/{2}",[channel_id,message_id,emoji]);
        callEndpoint("GET",endpoint,cb);
    }

    /**
     *  Delete all reactions from a message. Requires the MANAGE_MESSAGES permission.
     *  @param channel_id - The channel that contains the message.
     *  @param message_id - The message to remove reactions from.
     *  @param cb - Called when completed, good for looking for errors.
     */
    public function deleteAllReactions(channel_id:String,message_id:String,cb:EmptyResponseCallback=null){
        //Requires MANAGE_MESSAGES
        var endpoint = new EndpointPath("/channels/{0}/messages/{1}/reactions",[channel_id,message_id]);
        callEndpoint("DELETE",endpoint,cb); //204
    }

//GUILD START
    /**
     *  Create a new guild based on the data given
     *  @param guild_data - The data to be changed, All fields are optional.
     *  @param cb - Returns the new guild object, or an error.
     */
    public function createGuild(guild_data:Typedefs.GuildCreate,cb:Guild->String->Void=null){
        //Requires manage_guild
        var endpoint = new EndpointPath("/guilds",[]);
        callEndpoint("POST",endpoint,function(g,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else cb(client._newGuild(g),null);
        },guild_data);
    }
    
    /**
     *  Get a guild by the id.
     *  @param guild_id - The guild id
     *  @param cb - Return the guild object, or an error.
     */
    public function getGuild(guild_id:String,cb:Guild->String->Void=null){
        var endpoint = new EndpointPath("/guilds/{0}",[guild_id]);
        callEndpoint("GET",endpoint,function(g,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else cb(client._newGuild(g),null);
        });
    }
    
    /**
     *  Edit a guild's settings. Requires the MANAGE_GUILD permission
     *  @param guild_id - The guild id.
     *  @param guild_data - The data to be changed, All fields are optional.
     *  @param cb - Returns the new guild object, or an error.
     */
    public function modifyGuild(guild_id:String,guild_data:Typedefs.GuildUpdate,cb:Guild->String->Void=null){
        //Requires manage_guild
        var endpoint = new EndpointPath("/guilds/{0}",[guild_id]);
        callEndpoint("PATCH",endpoint,function(g,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else cb(client._newGuild(g),null);
        },guild_data);
    }

    /**
     *  Delete a guild. The account must be the owner of the guild.
     *  @param guild_id - The guild to delete.
     *  @param cb - Return the old guild object, or an error.
     */
    public function deleteGuild(guild_id:String,cb:EmptyResponseCallback=null){
        //Requires owner
        var endpoint = new EndpointPath("/guilds/{0}",[guild_id]);
        callEndpoint("DELETE",endpoint,cb);        
    }

    /**
     *  Get the channels in a guild
     *  @param guild_id - The guild id.
     *  @param cb - Return an array of channel objects, or an error.
     */
    public function getChannels(guild_id:String,cb:Array<Channel>->String->Void=null){
        var endpoint = new EndpointPath("/guilds/{0}/channels",[guild_id]);
        callEndpoint("GET",endpoint,function(r:Array<com.raidandfade.haxicord.types.structs.Guild.GuildChannelTypes>,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else{
                var channels = [for(c in r){client._newChannel(c);}];
                cb(channels,null);
            }
        });
    }

    /**
     *  Move two or more channel's positions within a guild. Requires the MANAGE_CHANNELS permission.
     *  @param guild_id - The id of the guild
     *  @param changes - An array of changes to channel positions
     *  @param cb - Return an array of the channels within the guild, or an error.
     */
    //TODO this logic, in Discordclient (or maybe guild object/client object)
    public function moveChannel(guild_id:String,changes:Typedefs.PositionChange,cb:Array<Channel>->String->Void=null){
        //Requires manage_channels
        var endpoint = new EndpointPath("/guilds/{0}/channels",[guild_id]);
        callEndpoint("PATCH",endpoint,function(r:Array<com.raidandfade.haxicord.types.structs.Guild.GuildChannelTypes>,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else{
                var channels = [for(c in r){client._newChannel(c);}];
                cb(channels,null);
            }
        });
    }

    /**
     *  Get a member of the guild.
     *  @param guild_id - The guild id.
     *  @param user_id - The member's id.
     *  @param cb - Return a member instance of the user. Or an error.
     */
    public function getGuildMember(guild_id:String,user_id:String,cb:GuildMember->String->Void=null){
        var endpoint = new EndpointPath("/guilds/{0}/members/{1}",[guild_id,user_id]);
        callEndpoint("GET",endpoint,function(gm,e){
            if(e!=null)cb(null,e);
            else cb(client.getGuildUnsafe(guild_id)._newMember(gm),null); //TODO this like the others. (look @410)
        });        
    }

    /**
     *  Get all members of a guild. 
     *  @param guild_id - The id of the guild.
     *  @param format - The limit, and after. both are optional. used for paginating.
     *  @param cb - The array of guild members. or an error.
     */
    public function getGuildMembers(guild_id:String,format:Typedefs.ListGuildMember,cb:Array<GuildMember>->String->Void=null){
        var endpoint = new EndpointPath("/guilds/{0}/members{1}",[guild_id,queryString(format)]);
        callEndpoint("GET",endpoint,function(r:Array<com.raidandfade.haxicord.types.structs.GuildMember>,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else{
                var members = [for(gm in r){client.getGuildUnsafe(guild_id)._newMember(gm);}]; //TODO this like the others. 
                cb(members,null);
            }
        });      
    }

    /**
     *  Add a guild member using a token received through Oauth2. 
     *  Requires the CREATE_INSTANT_INVITE permission along with various other permissions depending on `member_data` parameters
     *  @param guild_id - The id of the guild.
     *  @param user_id - The id of the user
     *  @param member_data - The access token, along with other optional parameters.
     *  @param cb - The added guildmember. or an error.
     */
    public function addGuildMember(guild_id:String,user_id:String,member_data:Typedefs.AddGuildMember,cb:GuildMember->String->Void=null){
        //bot needs CREATE_INSTANT_INVITE --various other parameters also need permissions
        var endpoint = new EndpointPath("/guilds/{0}/members/{1}",[guild_id,user_id]);
        callEndpoint("PUT",endpoint,function(gm,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else cb(client.getGuildUnsafe(guild_id)._newMember(gm),null); 
        },member_data);        //201. probably ok but make sure to _specifically_ test this func
    }
    
    /**
     *  Edit a guild member's properties, requires various permissions depending on the data provided. 
     *  @param guild_id - The guild the member is in.
     *  @param user_id - The id of the member.
     *  @param member_data - The updated data, all parameters are optional. All parameters require a different permission.
     *  @param cb - Called on completion, useful for checking for errors.
     */
    public function editGuildMember(guild_id:String,user_id:String,member_data:Typedefs.EditGuildMember,cb:EmptyResponseCallback=null){
        var endpoint = new EndpointPath("/guilds/{0}/members/{1}",[guild_id,user_id]);
        callEndpoint("PATCH",endpoint,cb,member_data);        //204.
    }

    /**
     *  Change this user's nickname.
     *  @param guild_id - The guild to change nickname in.
     *  @param nickname - The nickname to change to.
     *  @param cb - Returns the nickname, or an error.
     */
    public function changeNickname(guild_id:String,nickname:String,cb:String->String->Void=null){
        var endpoint = new EndpointPath("/guilds/{0}/members/@me/nick",[guild_id]);
        callEndpoint("PATCH",endpoint,cb,{nick:nickname});
    }

    /**
     *  Give a role to a member. Requires the MANAGE_ROLES permission
     *  @param guild_id - The guild that the user is in. 
     *  @param user_id - The id of the user.
     *  @param role_id - The id of the role desired to be added.
     *  @param cb - Called on completion, useful for checking for errors.
     */
    public function giveMemberRole(guild_id:String,user_id:String,role_id:String,cb:EmptyResponseCallback=null){
        //requires MANAGE_ROLES
        var endpoint = new EndpointPath("/guilds/{0}/members/{1}/roles/{2}",[guild_id,user_id,role_id]);
        callEndpoint("PUT",endpoint,cb,{});
    }

    /**
     *  Take a role away from a member. Requires the MANAGE_ROLES permission
     *  @param guild_id - The guild id.
     *  @param user_id - The id of the user.
     *  @param role_id - The id of the role to take away.
     *  @param cb - Called on completion, useful for checking for errors.
     */
    public function takeMemberRole(guild_id:String,user_id:String,role_id:String,cb:EmptyResponseCallback=null){
        //requires MANAGE_ROLES
        var endpoint = new EndpointPath("/guilds/{0}/members/{1}/roles/{2}",[guild_id,user_id,role_id]);
        callEndpoint("DELETE",endpoint,cb);
    }

    /**
     *  Kick a member from the guild. Requires the KICK_MEMBERS permission
     *  @param guild_id - The guild id.
     *  @param user_id - The user id.
     *  @param cb - Called on completion, useful for checking for errors.
     */
    public function kickMember(guild_id:String,user_id:String,cb:EmptyResponseCallback=null){
        //requires KICK_MEMBERS
        var endpoint = new EndpointPath("/guilds/{0}/members/{1}",[guild_id,user_id]);
        callEndpoint("DELETE",endpoint,cb); //TODO AUDIT LOG
    }

    /**
     *  List all the bans in a guild. Requires the BAN_MEMBERS permission.
     *  @param guild_id - The guild id.
     *  @param cb - Returns an array of users, or an error.
     */
    public function getGuildBans(guild_id:String,cb:Array<User>->String->Void=null){
        //requires BAN_MEMBERS
        var endpoint = new EndpointPath("/guilds/{0}/bans",[guild_id]);
        callEndpoint("GET",endpoint,function(r:Array<com.raidandfade.haxicord.types.structs.User>,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else{
                var users = [for(gm in r){client._newUser(gm);}];
                cb(users,null);
            }
        });      
    }

    /**
     *  Ban a member of the guild. Requires the BAN_MEMBERS permission.
     *  @param guild_id - The guild to ban from.
     *  @param user_id - The user to ban.
     *  @param days - Number of days (from 0-7) to remove the user's messages server wide.
     *  @param cb - Called on completion, useful for checking for errors.
     */
    public function banMember(guild_id:String,user_id:String,days:Int,cb:EmptyResponseCallback=null){
        //requires BAN_MEMBERS
        var endpoint = new EndpointPath("/guilds/{0}/bans/{1}",[guild_id,user_id]);
        callEndpoint("PUT",endpoint,cb,{}); //TODO AUDIT LOG
    }

    /**
     *  Unban a member of the guild. Requires the BAN_MEMBERS permission.
     *  @param guild_id - The guild to unban from.
     *  @param user_id - The user to unban.
     *  @param cb - Called on completion, useful for checking for errors.
     */
    public function unbanMember(guild_id:String,user_id:String,cb:EmptyResponseCallback=null){
        //requires BAN_MEMBERS
        var endpoint = new EndpointPath("/guilds/{0}/bans/{1}",[guild_id,user_id]);
        callEndpoint("DELETE",endpoint,cb); //TODO AUDIT LOG
    }

    /**
     *  Get the roles of a guild. Requires the MANAGE_ROLES permission.
     *  @param guild_id - The guild to fetch roles for.
     *  @param cb - Returns an array of guilds, or an error.
     */
    public function getGuildRoles(guild_id:String,cb:Array<Role>->String->Void=null){
        //requires MANAGE_ROLES
        var endpoint = new EndpointPath("/guilds/{0}/roles",[guild_id]);
        callEndpoint("GET",endpoint,function(res:Array<com.raidandfade.haxicord.types.structs.Role>,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else{
                var roles = [for(r in res){client.getGuildUnsafe(guild_id)._newRole(r);}];
                cb(roles,null);
            }
        });      
    }

    /**
     *  Create a role. Requires the MANAGE_ROLES permission.
     *  @param guild_id - The guild to add a role to.
     *  @param role_data - The role's data.
     *  @param cb - Returns the new role, or an error.
     */
    public function createRole(guild_id:String,role_data:Typedefs.RoleInfo,cb:Role->String->Void=null){
        //bot needs MANAGE_ROLES
        var endpoint = new EndpointPath("/guilds/{0}/roles",[guild_id]);
        callEndpoint("POST",endpoint,function(r,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else cb(client.getGuildUnsafe(guild_id)._newRole(r),null); 
        },role_data); 
    }

    /**
     *  Move the position of two or more roles in the hierarchy, requiers the MANAGE_ROLES permission.
     *  @param guild_id - The guild to make the changes in.
     *  @param changes - An array of changes to position.
     *  @param cb - Returns an array of the roles of the server with their new positions, or an error.
     */
    //TODO this logic, in Discordclient (or maybe guild object/client object)
    public function moveRole(guild_id:String,changes:Typedefs.PositionChange,cb:Array<Role>->String->Void=null){
        //Requires MANAGE_ROLES
        var endpoint = new EndpointPath("/guilds/{0}/roles",[guild_id]);
        callEndpoint("PATCH",endpoint,function(res:Array<com.raidandfade.haxicord.types.structs.Role>,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else{
                var roles = [for(r in res){client.getGuildUnsafe(guild_id)._newRole(r);}];
                cb(roles,null);
            }
        });
    }

    /**
     *  Edit a role's data. Requires the MANAGE_ROLES permission.
     *  @param guild_id - The guild id to make the changes in.
     *  @param role_id - The role to change.
     *  @param role_data - The new data, All fields are optional. 
     *  @param cb - Returns the new role, or an error.
     */
    public function editRole(guild_id:String,role_id:String,role_data:Typedefs.RoleInfo,cb:Role->String->Void=null){
        //bot needs MANAGE_ROLES
        var endpoint = new EndpointPath("/guilds/{0}/roles/{1}",[guild_id,role_id]);
        callEndpoint("PATCH",endpoint,function(r,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else cb(new Role(r,client.getGuildUnsafe(guild_id),client),null); 
        },role_data); 
    }

    /**
     *  Delete a role from a guild. Requires the MANAGE_ROLES permission.
     *  @param guild_id - The guild to remove from.
     *  @param role_id - The role to remove.
     *  @param cb - Called on completion, useful for checking for errors.
     */
    public function deleteRole(guild_id:String,role_id:String,cb:EmptyResponseCallback=null){
        //requires MANAGE_ROLES
        var endpoint = new EndpointPath("/guilds/{0}/roles/{1}",[guild_id,role_id]);
        callEndpoint("DELETE",endpoint,cb); 
    }

    /**
     *  Get the number of users that will be pruned if a prune was run. Requires the KICK_MEMBERS permission.
     *  @param guild_id - The guild to prune in.
     *  @param days - The number of days to count prune for.
     *  @param cb - Returns the number of users that would be pruned on a real request, or an error.
     */
    public function getPruneCount(guild_id:String,days:Int=1,cb:Int->String->Void=null){
        //requires KICK_MEMBERS
        var endpoint = new EndpointPath("/guilds/{0}/prune{1}",[guild_id,queryString({days:days})]);
        callEndpoint("GET",endpoint,function(res:{pruned:Int},e){
            if(cb==null)return;
            if(e!=null)cb(-1,e);
            else cb(res.pruned,null);
        }); 
    }

    /**
     *  Prune the members of a server. Requires the KICK_MEMBERS permission
     *  @param guild_id - The guild to prune in.
     *  @param days - The number of days to count prune for.
     *  @param cb - Returns the number of users that were pruned, or an error.
     */
    public function beginPrune(guild_id:String,days:Int=1,cb:Int->String->Void=null){
        //requires KICK_MEMBERS
        var endpoint = new EndpointPath("/guilds/{0}/prune{1}",[guild_id,queryString({days:days})]);
        callEndpoint("POST",endpoint,function(res:{pruned:Int},e){
            if(cb==null)return;
            if(e!=null)cb(-1,e);
            else cb(res.pruned,null);
        });
    }

    /**
     *  Get a list of voice regions for the guild. Including VIP servers if the server is a VIP-Enabled server.
     *  @param guild_id - The guild to get the list for.
     *  @param cb - Returns an array of voiceregion objects, or an error.
     */
    public function guildVoiceRegions(guild_id:String,cb:Array<VoiceRegion>->String->Void=null){
        var endpoint = new EndpointPath("/guilds/{0}/regions",[guild_id]);
        callEndpoint("GET",endpoint,function(res:Array<VoiceRegion>,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else cb(res,null);
        }); 
    }
    
    /**
     *  Get a list of integrations for a given guild. Requires the MANAGE_GUILD permission.
     *  @param guild_id - The guild to get the list for.
     *  @param cb - Returns an array of guildintegration objects, or an error.
     */
    public function getIntegrations(guild_id:String,cb:Array<GuildIntegration>->String->Void=null){
        //requires MANAGE_GUILD
        var endpoint = new EndpointPath("/guilds/{0}/integrations",[guild_id]);
        callEndpoint("GET",endpoint,cb);
    }

    /**
     *  Add a new integration from the user onto the guild. Requires the MANAGE_GUILD permission.
     *  @param guild_id - The id to add the integration to.
     *  @param int_data - The data of the new integration. 
     *  @param cb - Called on completion, useful for checking for errors.
     */
    public function addIntegration(guild_id:String,int_data:Typedefs.IntegrationCreate,cb:EmptyResponseCallback=null){
        //requires MANAGE_GUILD
        var endpoint = new EndpointPath("/guilds/{0}/integrations",[guild_id]);
        callEndpoint("POST",endpoint,cb,int_data);
    }

    /**
     *  Edit an integration in a guild. Requires the MANAGE_GUILD permission.
     *  @param guild_id - The guild that contains the integration.
     *  @param int_id - The id of the integration to change.
     *  @param int_data - The new data for the integration. All parameters are optional.
     *  @param cb - Called on completion, useful for checking for errors.
     */
    public function editIntegration(guild_id:String,int_id:String,int_data:Typedefs.IntegrationModify,cb:EmptyResponseCallback=null){
        //requires MANAGE_GUILD
        var endpoint = new EndpointPath("/guilds/{0}/integrations/{1}",[guild_id,int_id]);
        callEndpoint("PATCH",endpoint,cb,int_data);
    }

    /**
     *  Remove an integration from a guild. Requires the MANAGE_GUILD permission.
     *  @param guild_id - The guild that contains the integration.
     *  @param int_id - The id of the integration to remove.
     *  @param cb - Called on completion, useful for checking for errors.
     */
    public function deleteIntegration(guild_id:String,int_id:String,cb:EmptyResponseCallback=null){
        //requires MANAGE_GUILD
        var endpoint = new EndpointPath("/guilds/{0}/integrations/{1}",[guild_id,int_id]);
        callEndpoint("DELETE",endpoint,cb);
    }

    /**
     *  Sync a given integration in a guild. Requires the MANAGE_GUILD permission.
     *  @param guild_id - The id of the guild that contains the integration.
     *  @param int_id - The id of the integration to sync.
     *  @param cb - Called on completion, useful for checking for errors.
     */
    public function syncIntegration(guild_id:String,int_id:String,cb:EmptyResponseCallback=null){
        //requires MANAGE_GUILD
        var endpoint = new EndpointPath("/guilds/{0}/integrations/{1}/sync",[guild_id,int_id]);
        callEndpoint("POST",endpoint,cb);
    }

    /**
     *  Get the widget/embed for a guild. Requires the MANAGE_GUILD permission.
     *  @param guild_id - The id of the guild to fetch the widget from.
     *  @param cb - Returns the GuildEmbed object of the guild, or an error.
     */
    public function getWidget(guild_id:String,cb:GuildEmbed->String->Void=null){
        //requires MANAGE_GUILD
        var endpoint = new EndpointPath("/guilds/{0}/embed",[guild_id]);
        callEndpoint("GET",endpoint,cb);
    }

    /**
     *  Change the properties of a guild's embed or widget. Requires the MANAGE_GUILD permission.
     *  @param guild_id - The guild that contains the widget/embed.
     *  @param edits - The changes to be made to the widget/embed. All parameters are optional.
     *  @param cb - Returns the changed GuildEmbed object, or an error.
     */
    public function modifyWidget(guild_id:String,edits:GuildEmbed,cb:GuildEmbed->String->Void=null){
        //requires MANAGE_GUILD
        var endpoint = new EndpointPath("/guilds/{0}/embed",[guild_id]);
        callEndpoint("PATCH",endpoint,cb,edits);
    }

//INVITE START
    /**
     *  Get a list of all invites in a guild. requires the MANAGE_GUILD permission.
     *  @param guild_id - The id to get the list from.
     *  @param cb - Returns an array of invites, or an error.
     */
    public function getInvites(guild_id:String,cb:Array<Invite>->String->Void=null){
        //requires MANAGE_GUILD
        var endpoint = new EndpointPath("/guilds/{0}/invites",[guild_id]);
        callEndpoint("GET",endpoint,cb);
    }

    /**
     *  Get information about an invite code.
     *  @param invite_code - The invite code.
     *  @param with_counts - Get some extra data from the invite's server
     *  @param cb - Returns an Invite object, or an error.
     */
    public function getInvite(invite_code:String,with_counts:Bool=true,cb:Invite->String->Void=null){
        var endpoint = new EndpointPath("/invite/{0}?with_counts={1}",[invite_code,with_counts?"true":"false"]);
        callEndpoint("GET",endpoint,cb);
    }

    /**
     *  Delete an invite based on it's invite code. Requires the MANAGE_CHANNELS permission in the guild the invite is from.
     *  @param invite_code - The invite code of the invite to delete.
     *  @param cb - Returns the Invite that was removed, or an error.
     */
    public function deleteInvite(invite_code:String,cb:Invite->String->Void=null){
        var endpoint = new EndpointPath("/invite/{0}",[invite_code]);
        callEndpoint("DELETE",endpoint,cb);
    }

    /**
     *  (NOT AVAILABLE FOR BOTS) Accept an invite code and join the server.
     *  @param invite_code - The invite code to join.
     *  @param cb - Returns the invite that was joined, or an error.
     */
    //nope.jpg for bots
    public function acceptInvite(invite_code:String,cb:Invite->String->Void=null){
        var endpoint = new EndpointPath("/invite/{0}",[invite_code]);
        callEndpoint("POST",endpoint,cb);
    }

//USER START

    /**
     *  Get a user based on their Id. 
     *  @param user_id - Get any user based on their id, or set to "@me" to return self.
     *  @param cb - Return the user object, or an error.
     */
    public function getUser(user_id:String="@me",cb:User->String->Void=null){
        var endpoint = new EndpointPath("/users/{0}",[user_id]);
        callEndpoint("GET",endpoint,function(r,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else cb(new User(r,client),null);
        });
    }

    /**
     *  Edit the current user's settings.
     *  @param user_data - The parameters to change, all fields are optional.
     *  @param cb - Return the changed user, or an error.
     */
    public function editUser(user_data:{username:String,avatar:String},cb:User->String->Void=null){
        var endpoint = new EndpointPath("/users/@me",[]);
        callEndpoint("PATCH",endpoint,function(r,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else cb(new User(r,client),null);
        },user_data);
    }

    /**
     *  Get a list of all guilds that the current user is in. Normal users do not need to use the filter and can leave it blank `{}`
     *  @param filter - Filter the list depending on these parameters, Only one of BEFORE or AFTER can be specified.
     *  @param cb - Returns the list of Guilds according to the filter specified, or an error.
     */
    public function getGuilds(filter:Typedefs.GetGuildFilter,cb:Array<Guild>->String->Void=null){ 
        var endpoint = new EndpointPath("/users/@me/guilds{0}",[]);
        callEndpoint("GET",endpoint,function(r:Array<com.raidandfade.haxicord.types.structs.Guild>,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else{
                var guilds = [for(g in r){client._newGuild(g);}];
                cb(guilds,null);
            }
        });
    }

    /**
     *  Make the current user leave the specified guild.
     *  @param guild_id - The guild to leave.
     *  @param cb - Called on completion, useful for checking for errors.
     */
    public function leaveGuild(guild_id:String,cb:EmptyResponseCallback=null){
        var endpoint = new EndpointPath("/users/@me/guilds/{0}",[guild_id]);
        callEndpoint("POST",endpoint,cb);
    }

    /**
     *  Get the dm channels that the current user has open.
     *  @param cb - Returns an array of all dm channels the user currently has open, or an error.
     */
    public function getDMChannels(cb:Array<DMChannel>->String->Void=null){
        var endpoint = new EndpointPath("/users/@me/channels",[]);
        callEndpoint("GET",endpoint,function(r:Array<com.raidandfade.haxicord.types.structs.DMChannel>,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else{
                var channels = [for(c in r){client._newDMChannel(c);}];
                cb(channels,null);
            }
        });
    }

    /**
     *  Create a dm with another individual
     *  @param data - A struct that contains the recipient's id.
     *  @param cb - Returns the dm channel requested, or an error.
     */
    public function createDM(data:{recipient_id:String},cb:DMChannel->String->Void=null){
        var endpoint = new EndpointPath("/users/@me/channels",[]);
        callEndpoint("POST",endpoint,function(r:com.raidandfade.haxicord.types.structs.DMChannel,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else{
                var channels = client._newDMChannel(r);
                cb(channels,null);
            }
        },data);
    }

    /**
     *  Create a DM group. 
     *  @param data - A struct that contains the necessary arguments required to invite members.
     *  @param cb - Returns the group dm channel, or an error.
     */
    public function createGroupDM(data:Typedefs.CreateGroupDM,cb:DMChannel->String->Void=null){
        var endpoint = new EndpointPath("/users/@me/channels",[]);
        callEndpoint("POST",endpoint,function(r:com.raidandfade.haxicord.types.structs.DMChannel,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else{
                var channels = client._newDMChannel(r);
                cb(channels,null);
            }
        },data);
    }

    /**
     *  Get a list of connections hooked up to the current account.
     *  @param cb - Returns a list of connections, or an error.
     */
    public function getConnections(cb:Array<Connection>->String->Void=null){
        var endpoint = new EndpointPath("/users/@me/connections",[]);
        callEndpoint("GET",endpoint,cb);
    }

//VOICE START
    /**
     *  Get a list of voice regions.
     *  @param cb - Returns a list of voice regions, or an error.
     */
    public function listVoiceRegions(cb:Array<VoiceRegion>->String->Void=null){
        var endpoint = new EndpointPath("/voice/regions",[]);
        callEndpoint("GET",endpoint,function(res:Array<VoiceRegion>,e){
            if(cb==null)return;
            if(e!=null)cb(null,e);
            else cb(res,null);
        }); 
    }

//WEBHOOK START ~ consider caching these

    /**
     *  Create a webhook for a given channel based on the given data.
     *  @param channel_id - The channel to create for.
     *  @param data - The data to create with.
     *  @param cb - Returns the webhook object, or an error.
     */
    public function createWebhook(channel_id:String,data:{name:String,avatar:String},cb:Webhook->String->Void=null){
        var endpoint = new EndpointPath("/channels/{0}/webhooks",[channel_id]);
        callEndpoint("POST",endpoint,cb,data);
    }

    /**
     *  Get all webhooks for a given channel. Requires the MANAGE_WEBHOOKS permission.
     *  @param channel_id - The channel id to get webhooks about.
     *  @param cb - Returns an array of webhooks, or an error.
     */
    public function getChannelWebhooks(channel_id:String,cb:Array<Webhook>->String->Void=null){
        var endpoint = new EndpointPath("/channels/{0}/webhooks",[channel_id]);
        callEndpoint("GET",endpoint,cb);
    }

    /**
     *  Get all webhooks for a given guild. Requires the MANAGE_WEBHOOKS permission.
     *  @param guild_id - The guild id to get webhooks about.
     *  @param cb - Returns an array of webhooks, or an error.
     */
    public function getGuildWebhooks(guild_id:String,cb:Array<Webhook>->String->Void=null){
        var endpoint = new EndpointPath("/guilds/{0}/webhooks",[guild_id]);
        callEndpoint("GET",endpoint,cb);
    }

    /**
     *  Get a webhook based on it's id. Requires the MANAGE_WEBHOOKS permission in the guild/channel that the webhook is part of.
     *  @param webhook_id - The id of the webhook.
     *  @param cb - Returns a webhook object, or an error.
     */
    public function getWebhook(webhook_id:String,cb:Webhook->String->Void=null){
        var endpoint = new EndpointPath("/webhooks/{0}",[webhook_id]);
        callEndpoint("GET",endpoint,cb);
    }

    /**
     *  Edit a webhook based on it's id. Requires the MANAGE_WEBHOOKS permission in the guild/channel that the webhook is part of.
     *  @param webhook_id - The id of the webhook to change.
     *  @param data - The updated data for the webhook. All parameters are optional.
     *  @param cb - Returns a webhook object, or an error.
     */
    public function editWebhook(webhook_id:String,data:{?name:String,?avatar:String},cb:Webhook->String->Void=null){
        var endpoint = new EndpointPath("/webhooks/{0}",[webhook_id]);
        callEndpoint("PATCH",endpoint,cb,data);
    }

    /**
     *  Delete a webhook based on it's id. Requires the MANAGE_WEBHOOKS permission in the guild/channel that the webhook is part of.
     *  @param webhook_id - The id of the webhook to delete.
     *  @param cb - Called on completion, useful for checking for errors.
     */
    public function deleteWebhook(webhook_id:String,cb:EmptyResponseCallback=null){
        var endpoint = new EndpointPath("/webhooks/{0}",[webhook_id]);
        callEndpoint("DELETE",endpoint,cb);
    }

    /**
     *  Get a webhook using it's id and token. 
     *  @param webhook_id - The webhook's id.
     *  @param webhook_token - The webhook's token.
     *  @param cb - Returns a webhook object, or an error.
     */
    public function getWebhookWithToken(webhook_id:String,webhook_token:String,cb:Webhook->String->Void=null){
        var endpoint = new EndpointPath("/webhooks/{0}/{1}",[webhook_id,webhook_token]);
        callEndpoint("GET",endpoint,cb,{},false);
    }

    /**
     *  Edit a webhook using it's id and token
     *  @param webhook_id - The webhook's id.
     *  @param webhook_token - The webhook's token.
     *  @param data - The updated data for the webhook. All parameters are optional.
     *  @param cb - Returns a webhook object, or an error.
     */
    public function editWebhookWithToken(webhook_id:String,webhook_token:String,data:{?name:String,?avatar:String},cb:Webhook->String->Void=null){
        var endpoint = new EndpointPath("/webhooks/{0}/{1}",[webhook_id,webhook_token]);
        callEndpoint("PATCH",endpoint,cb,data,false);
    }

    /**
     *  Delete a webhook based on it's id and token.
     *  @param webhook_id - The id of the webhook to delete.
     *  @param webhook_token - The webhook's token.
     *  @param cb - Called on completion, useful for checking for errors.
     */
    public function deleteWebhookWithToken(webhook_id:String,webhook_token:String,cb:EmptyResponseCallback=null){
        var endpoint = new EndpointPath("/webhooks/{0}/{1}",[webhook_id,webhook_token]);
        callEndpoint("DELETE",endpoint,cb,{},false);
    }
    
    /**
     *  Execute a given webhook and send a message.
     *  @param webhook_id - The id of the webhook.
     *  @param webhook_token - The token of the webhook.
     *  @param data - The message data to send.
     *  @param wait - Whether or not the request should wait until the message is successfully sent.
     *  @param cb - Called on completion, useful for checking for errors.
     */
    public function executeWebhook(webhook_id:String,webhook_token:String,data:Typedefs.WebhookMessage,wait=false,cb:EmptyResponseCallback=null){
        var endpoint = new EndpointPath("/webhooks/{0}/{1}?wait={2}",[webhook_id,webhook_token,wait?"true":"false"]);
        callEndpoint("POST",endpoint,cb,data,false);
    }


//BACKEND
    //later on if it matters see if there's a better way to do this
    public static function queryString(datar:{}):String{
        if(Std.is(datar,new Map<String,Dynamic>())){
            var data:Map<String,Dynamic> = cast(datar,Map<String,Dynamic>);
            var s = "?";
            var c = 0;
            for(k in data.keys()){
                var v = data.get(k);
                if(c++!=0)s+="&";
                s+=k+"="+Std.string(v);
            }
            return s;
        }
        return "";
    }

//TODO global ratelimit
    public function callEndpoint(method:String,endpoint:EndpointPath,callback:Null<Dynamic->String->Void>=null,data:{}=null,authorized:Bool=true){
        trace("Req : "+endpoint.getPath());
        var rateLimitName = endpoint.getRoute();
        trace("RLC: "+rateLimitCache.exists(rateLimitName));
        if(rateLimitCache.exists(rateLimitName)){
            trace("RLL: "+rateLimitCache.get(rateLimitName).remaining);
            if(rateLimitCache.get(rateLimitName).remaining <= 0){
                trace("LQ: "+limitedQueue.exists(rateLimitName));
                if(limitedQueue.exists(rateLimitName)){
                    limitedQueue.get(rateLimitName).push(new EndpointCall(method,endpoint,callback,data,authorized));
                }else{
                    limitedQueue.set(rateLimitName,new Array<EndpointCall>());
                    limitedQueue.get(rateLimitName).push(new EndpointCall(method,endpoint,callback,data,authorized));
                }
                return;
            }else{
                rateLimitCache.get(rateLimitName).remaining--;
            }
        }else{
            rateLimitCache.set(rateLimitName,new RateLimit(1,0,-1));
        }
        var _callback = function(data,headers:Map<String,String>){
            trace("?: ",rateLimitName,rateLimitCache.get(rateLimitName));
            if(headers.exists("x-ratelimit-reset")){
                var limit = Std.parseInt(headers.get("x-ratelimit-limit"));
                var remaining = Std.parseInt(headers.get("x-ratelimit-remaining"));
                var reset = Std.parseFloat(headers.get("x-ratelimit-reset"));
                rateLimitCache.set(rateLimitName,new RateLimit(limit,remaining,reset));
                if(remaining==0){
                    var delay = Std.int(reset-(Date.now().getTime()/1000))*1000+500;
                    var waitForLimit = function(rateLimitName,rateLimit){
                        trace("Ratelimit reset reached.");
                        rateLimitCache.set(rateLimitName,new RateLimit(limit,limit,-1));
                        if(limitedQueue.exists(rateLimitName)){
                            var arrCopy = limitedQueue.get(rateLimitName).map(function(l){return l;});
                            limitedQueue.set(rateLimitName,new Array<EndpointCall>());
                            for(calli in 0...arrCopy.length){
                                var call = arrCopy[calli];
                                callEndpoint(call.method,call.endpoint,call.callback,call.data,call.authorized);
                            }
                        }
                    }

                    trace("Must wait for "+delay+"ms.");
                    var f = waitForLimit.bind(rateLimitName,rateLimitCache.get(rateLimitName));
                    Timer.delay(f,delay);
                }
                if(remaining!=0){
                    if(limitedQueue.exists(rateLimitName)){
                        if(limitedQueue.get(rateLimitName).length>0){
                            var arrCopy = limitedQueue.get(rateLimitName).map(function(l){return l;});
                            limitedQueue.set(rateLimitName,new Array<EndpointCall>());
                            for(calli in 0...arrCopy.length){
                                var call = arrCopy[calli];
                                callEndpoint(call.method,call.endpoint,call.callback,call.data,call.authorized);
                            }
                        }
                    }
                }
            }else{
                trace("No ratelimits on this endpoint.");
                rateLimitCache.set(rateLimitName,new RateLimit(50,50,-1));
                if(limitedQueue.exists(rateLimitName)){
                    if(limitedQueue.get(rateLimitName).length>0){
                        var arrCopy = limitedQueue.get(rateLimitName).map(function(l){return l;});
                        limitedQueue.set(rateLimitName,new Array<EndpointCall>());
                        for(calli in 0...arrCopy.length){ 
                            var call = arrCopy[calli];
                            callEndpoint(call.method,call.endpoint,call.callback,call.data,call.authorized);
                        }
                    }
                }
            }
            //TODO if data is not an error luleh
            if(callback==null)return;
            //trace(data);
            if(data.status < 200 || data.status>=300){
                callback(null,data.error);
            }else{
                callback(data.data,null);
            }
        }
        var path = endpoint.getPath();
        rawCallEndpoint(method,path,_callback,data,authorized);
        return;
    }


    //this exists because i screwed up. 
    public static function stringify(d:Dynamic):String{
        return Json.stringify(d);
    }

    //TODO doc
    public function rawCallEndpoint(method:String,endpoint:String,callback:Null<Dynamic->Map<String,String>->Void>=null,data:{}=null,authorized:Bool=true){
        if(callback == null){
            callback = function(f,a){}
        }
        method=method.toUpperCase();
        if(["GET","HEAD","POST","PUT","PATCH","DELETE","OPTIONS"].indexOf(method)==-1)throw "Invalid Method Request";

        var url = "https://discordapp.com/api"+endpoint;
        var token = "Bot " + client.token;
#if (js && nodejs)
        var headers = new DynamicAccess<EitherType<String,Array<String>>>();

        if(authorized)headers.set("Authorization",token);
        headers.set("User-Agent",DiscordClient.userAgent);
        headers.set("Content-Type","application/json");
        //

        var path = Url.parse(url).pathname;

        var options = {
            "hostname": Url.parse(url).host,
            "path": path,
            "method": method,
            "headers": headers
        };

        var req = Https.request(options,function(res:IncomingMessage){
            //trace(res.headers);
            var datas = "";
            res.on('data', function (all) {
                datas += all;
                trace(datas);
            });
            res.on('end', function(){
                var m:Map<String,String> = new Map<String,String>();
                for(k in res.headers.keys()){
                    var v = res.headers[k];
                    m.set(k.toLowerCase(),v);
                }
                trace(res.statusCode);
                var r = res.statusCode==204?null:Json.parse(datas);
                trace(r);
                if(res.statusCode<200||res.statusCode>=300)
                    callback({status:res.statusCode,error:r},m);
                else
                    callback({status:res.statusCode,data:r},m);
            });
        });
        req.on('error',function(e){
            trace(e);
        });
        if(["POST","PUT","PATCH"].indexOf(method)>-1&&data!=null)
            req.write(stringify(data));
        req.end();
#elseif cs
        var cscb = function(status,response,headers){
            var data = Json.parse(response);
            callback({status:status,data:data},headers);
        }
        untyped __cs__('
                try{
                var httpWebRequest = (System.Net.HttpWebRequest)System.Net.WebRequest.Create({0});
                httpWebRequest.ContentType = "application/json";
                httpWebRequest.Method = {1};
                httpWebRequest.Headers.Add("Authorization",{2});
                httpWebRequest.UserAgent = {3};
                '
            ,url,method,token,DiscordClient.userAgent);
        if(["POST","PUT","PATCH"].indexOf(method)>-1&&data!=null){
        untyped __cs__('
                using (var streamWriter = new System.IO.StreamWriter(httpWebRequest.GetRequestStream()))
                {
                    streamWriter.Write({0});
                    streamWriter.Flush();
                    streamWriter.Close();
                }'
            ,stringify(data));
        }
        untyped __cs__('
                httpWebRequest.BeginGetResponse(new System.AsyncCallback(httpCallBack),System.Tuple.Create(httpWebRequest,{0}));
                }catch(System.Net.WebException e){
                    System.Console.WriteLine("ERROR IN HTTP REQUEST");
                    System.Console.WriteLine(e);
                }
            '
        ,cscb);
#elseif js
        throw "Browser JS is not supported as it's not possible to send modified User-Agents.";
#else
        var call = new Http(url);
        var result = new haxe.io.BytesOutput();

        call.setHeader("Authorization",token);
        call.setHeader("User-Agent",DiscordClient.userAgent);
        var status:Int = -1;
        call.onStatus = function(st){
            status = st;
        }
        call.onError = function(no){
            var m = new Map<String,String>();
            for(k in call.responseHeaders.keys()){
                var v = call.responseHeaders[k];
                m.set(k.toLowerCase(),v);
            }
            var errReg = ~/Http Error #([0-9]{0,5})/;
            if(errReg.match(no)){
                callback({"status":status,"error":"HTTP error "+status},m);
            }else{
                callback({"status":status,"error":no},m);
            }
        }
        if(["POST","PUT","PATCH"].indexOf(method)>-1&&data!=null){
            var sd = stringify(data);
            call.setHeader("Content-Type","application/json");
            call.setPostData(sd);
        }
        call.onData = function(data){
            var m = new Map<String,String>();
            for(k in call.responseHeaders.keys()){
                var v = call.responseHeaders[k];
                m.set(k.toLowerCase(),v);
            }
            var data = Json.parse(data);
            callback({status:status,data:data},m);
        }
        //TODO data
        call.customRequest(false,result,method);
#end
    }
}

// Love you b1nzy
class RateLimit { 
    public var limit:Int;
    public var remaining:Int;
    public var reset:Float;
    public function new(_l,_rm,_rs){
        limit = _l;
        remaining = _rm;
        reset = _rs;
    }

    public function toString(){
        return "RateLimit("+remaining+"/"+limit+" until "+reset+")";
    }
}

class EndpointCall {
    public var method:String;
    public var endpoint:EndpointPath;
    public var callback:Null<Dynamic->String->Void>;
    public var data:{};
    public var authorized:Bool;
    public function new(_m,_e,_c=null,_d=null,_a=true){
        method = _m; endpoint = _e; callback = _c; data = _d; authorized = _a;
    }
}

class EndpointPath { 
    public var endpoint:String;
    public var data:Array<String>;
    public function new(_e,_d:Array<String>){
        endpoint=_e;
        data=_d;
    }

    public function getRoute(){
        var cur = endpoint;
        if(endpoint.charAt(1)=="c") StringTools.replace(cur,"channels/{0}","channels/"+data[0]);
        if(endpoint.charAt(1)=="g") StringTools.replace(cur,"guilds/{0}","guilds/"+data[0]);
        return cur;
    }

    public function getPath(){
        var cur = endpoint;
        for(i in 0...data.length){
            var d = data[i];
            cur = StringTools.replace(cur,"{"+i+"}",d);
        }
        return cur;
    }
}

typedef EmptyResponseCallback = Dynamic->String->Void;