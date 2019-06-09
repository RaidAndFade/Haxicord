package com.raidandfade.haxicord.types;

import com.raidandfade.haxicord.types.structs.Emoji;
import com.raidandfade.haxicord.types.structs.Presence;

import haxe.DateUtils;

class Guild{
    var client:DiscordClient;

    /**
       The guild Id
     */
    public var id:Snowflake;
    /**
       The guild Name (2-100 characters)
     */
    public var name:String; 
    /**
       The guild Icon hash
     */
    public var icon:String; 
    /**
       The guild Splash hash
     */
    public var splash:String; 
    /**
       The guild owner's id
     */
    public var owner_id:Snowflake;
    /**
       The guild voice region id
     */
    public var region:String; 
    /**
       The guild's afk channel's id 
     */
    public var afk_channel_id:Snowflake;
    /**
       The guild's afk timeout in seconds
     */
    public var afk_timeout:Int;
    /**
       Does the guild have widgets enabled?
     */
    public var embed_enabled:Bool;
    /**
       The channel that is featured in the widget.
     */
    public var embed_channel_id:Snowflake; 
    /**
       The level of verification required for the guild
     */
    public var verification_level:Int;
    /**
       The guild's default message notifications level
     */
    public var default_message_notifications:Int;
    /**
       The guild's default explicit content filter
     */
    public var explicit_content_filter:Int;
    /**
       A dictionary of roles in the guild by Id
     */
    public var roles:Map<String, Role> = new Map<String, Role>();
    /**
       A list of emojis in the guild
     */
    public var emojis:Array<Emoji> = new Array<Emoji>();
    /**
       A list of enabled guild features
     */
    public var features:Array<String> = new Array<String>();// wth is a guild feature?
    /**
       The guild's required MFA level.
     */
    public var mfa_level:Int;

    //SENT ON GUILD_CREATE : 

    /**
       When the current user joined the guild.
     */
    public var joined_at:Date;

    /**
       Is the guild classified by discord as "Large"?
     */
    public var large:Bool;
    /**
       Is this guild unavailable? If so things are going wrong :(
     */
    public var unavailable:Bool; //if this is true, only this and ID can be set because the guild data could not be received.
    /**
       The guild's member count
     */
    public var member_count:Int;
    /**
       A dictionary of members in the guild by Id
     */
    public var members:Map<String, GuildMember> = new Map<String, GuildMember>(); 
    /**
       A dictionary of textChannels in the guild by Id
     */
    public var textChannels:Map<String, TextChannel> = new Map<String, TextChannel>();
    /**
       A dictionary of voiceChannels in the guild by Id
     */
    public var voiceChannels:Map<String, VoiceChannel> = new Map<String, VoiceChannel>();
    /**
       A dictionary of categoryChannels in the guild by Id
     */
    public var categoryChannels:Map<String, CategoryChannel> = new Map<String, CategoryChannel>();
    /**
       A dictionary of storeChannels in the guild by Id
     */
    public var storeChannels:Map<String, StoreChannel> = new Map<String, StoreChannel>();
    /**
       An array of partial presence updates of users in the guild.
     */
    public var presences:Array<Presence>; //https://discordapp.com/developers/docs/topics/gateway#presence-update

    // TODO doc
    public var widget_enabled:Bool;
    public var widget_channel_id:Snowflake;
    public var system_channel_id:Snowflake;
    public var max_members:Int;
    public var max_presences:Int;
    public var vanity_url_code:String;
    public var description:String;
    public var banner:String;
    public var boost_tier:Int;
    public var boost_count:Int;

    /**
        A list of banned users.
     */
    public var bans:Array<User> = new Array<User>();
    /**
       The owner of the guild
     */
    public var owner:GuildMember;

    @:dox(hide)
    public var nextChancb:Array<GuildChannel->Void> = new Array<GuildChannel->Void>();


    @:dox(hide)
    public function new(_guild:com.raidandfade.haxicord.types.structs.Guild, _client:DiscordClient) {
        client = _client;

        id = new Snowflake(_guild.id);
        if(_guild.unavailable != null)
            unavailable = _guild.unavailable;

        if(!unavailable) {
            name = _guild.name;
            icon = _guild.icon;
            splash = _guild.splash;
            owner_id = new Snowflake(_guild.owner_id);
            region = _guild.region;
            afk_timeout = _guild.afk_timeout;
            afk_channel_id = new Snowflake(_guild.afk_channel_id);
            embed_enabled = _guild.embed_enabled;
            embed_channel_id = new Snowflake(_guild.embed_channel_id);
            verification_level = _guild.verification_level;
            default_message_notifications = _guild.default_message_notifications;
            explicit_content_filter = _guild.explicit_content_filter;

            for(r in _guild.roles) {
                _newRole(r);
            }
            emojis = _guild.emojis;
            features = _guild.features;
            mfa_level = _guild.mfa_level;

            if(_guild.widget_enabled != null) widget_enabled = _guild.widget_enabled;
            if(_guild.widget_channel_id != null) widget_channel_id = new Snowflake(_guild.widget_channel_id);
            if(_guild.system_channel_id != null) system_channel_id = new Snowflake(_guild.system_channel_id);

            max_members = _guild.max_members;
            max_presences = _guild.max_presences;

            vanity_url_code = _guild.vanity_url_code;
            description = _guild.description;
            banner = _guild.banner;
            boost_tier = _guild.premium_tier;
            if(_guild.premium_subscription_count != null) boost_count = _guild.premium_subscription_count;

            if(_guild.joined_at != null)
                joined_at = DateUtils.fromISO8601(_guild.joined_at);

            if(_guild.large != null)
                large = _guild.large;

            if(_guild.member_count != null)
                member_count = _guild.member_count;

            if(_guild.members != null)
                for(m in _guild.members) { _newMember(m); }

            owner = getMemberUnsafe(owner_id.id);
            if(owner_id != null && owner_id.id != "" && owner == null){
                try{
                    getMember(owner_id.id,function(m){
                        owner=m;
                    });
                }catch(f:Dynamic){
                    trace("["+id.id+"] Failed to load the guild owner manually (they were not in cache and this error occured when attempting to retrieve them):");
                    trace(f);
                }
            }

            if(_guild.channels != null)
                for(c in _guild.channels) {
                    var ch = cast(_client._newChannel(c), GuildChannel);
                    ch.guild_id = this.id;
                    if(Std.is(ch, TextChannel)) {
                        textChannels.set(ch.id.id, cast(ch, TextChannel));
                    } else if(Std.is(ch, VoiceChannel)) {
                        voiceChannels.set(ch.id.id, cast(ch, VoiceChannel));
                    } else {
                        categoryChannels.set(ch.id.id, cast(ch, CategoryChannel));
                    }
                }
            if(_guild.presences != null)
                presences = _guild.presences;
        }
    }

    @:dox(hide)
    public function _update(_guild:com.raidandfade.haxicord.types.structs.Guild.Update) {
        if(_guild.unavailable != null)
            unavailable = _guild.unavailable;

        if(!unavailable) {
            if(_guild.name != null)
                name = _guild.name;

            if(_guild.icon != null)
                icon = _guild.icon;

            if(_guild.splash != null)
                splash = _guild.splash;

            if(_guild.region != null)
                region = _guild.region;

            if(_guild.afk_timeout != null)
                afk_timeout = _guild.afk_timeout;

            if(_guild.afk_channel_id != null)
                afk_channel_id = new Snowflake(_guild.afk_channel_id);

            if(_guild.embed_enabled != null)
                embed_enabled = _guild.embed_enabled;

            if(_guild.embed_channel_id != null)
                embed_channel_id = new Snowflake(_guild.embed_channel_id);

            if(_guild.verification_level != null)
                verification_level = _guild.verification_level;

            if(_guild.default_message_notifications != null)
                default_message_notifications = _guild.default_message_notifications;
            
            if(_guild.roles != null) 
                for(r in _guild.roles) { _newRole(r); }

            if(_guild.emojis != null) 
                emojis = _guild.emojis;

            if(_guild.features != null)
                features = _guild.features;

            if(_guild.mfa_level != null)
                mfa_level = _guild.mfa_level;

            if(_guild.joined_at != null)
                joined_at = DateUtils.fromISO8601(_guild.joined_at);

            if(_guild.large != null)
                large = _guild.large;

            if(_guild.member_count != null)
                member_count = _guild.member_count;

            if(_guild.members != null) 
                for(m in _guild.members) { _newMember(m); }

            if(_guild.owner_id != null){
                owner_id = new Snowflake(_guild.owner_id);
                owner = getMemberUnsafe(owner_id.id);
                if(owner_id != null && owner_id.id != "" && owner == null){
                    try{
                        getMember(owner_id.id,function(m){
                            owner=m;
                        });
                    }catch(f:Dynamic){
                        trace("["+id.id+"] Failed to load the guild owner manually (they were not in cache and this error occured when attempting to retrieve them):");
                        trace(f);
                    }
                }
            }

            if(_guild.channels != null) {
                for(c in _guild.channels) {
                    var ch = cast(client._newChannel(c), GuildChannel);
                    ch.guild_id = this.id;
                    if(Std.is(ch, TextChannel) || Std.is(ch, NewsChannel)) { 
                        // since they are literally the same thing, and i don't think it's necessary to 
                        //  have a new map of just news channels considering how niche it is
                        textChannels.set(ch.id.id, cast(ch, TextChannel));
                    }else if(Std.is(ch, VoiceChannel)) {
                        voiceChannels.set(ch.id.id, cast(ch, VoiceChannel));
                    }else if(Std.is(ch, CategoryChannel)){
                        categoryChannels.set(ch.id.id, cast(ch, CategoryChannel));
                    }else if(Std.is(ch, StoreChannel)){ 
                        // I can't do similar things to newschannel here since storechannel is distinct
                        storeChannels.set(ch.id.id, cast(ch, StoreChannel));
                    }else{
                        throw "Unsupported channel type in guild initialization";
                    }
                }
            }

            if(_guild.presences != null) presences = _guild.presences;

            if(_guild.widget_enabled != null) widget_enabled = _guild.widget_enabled;
            if(_guild.widget_channel_id != null) widget_channel_id = new Snowflake(_guild.widget_channel_id);
            if(_guild.system_channel_id != null) system_channel_id = new Snowflake(_guild.system_channel_id);

            if(_guild.max_members != null) max_members = _guild.max_members;
            if(_guild.max_presences != null) max_presences = _guild.max_presences;

            if(_guild.vanity_url_code != null) vanity_url_code = _guild.vanity_url_code;
            if(_guild.description != null) description = _guild.description;
            if(_guild.banner != null) banner = _guild.banner;
            if(_guild.premium_tier != null) boost_tier = _guild.premium_tier;
            if(_guild.premium_subscription_count != null) boost_count = _guild.premium_subscription_count;
        }
    }

    @:dox(hide)
    public function _updateEmojis(e:Array<com.raidandfade.haxicord.types.structs.Emoji>) {
        emojis = e;
    }

    @:dox(hide)
    public function _addChannel(ch) {
        if(nextChancb.length > 0)
            nextChancb.splice(0, 1)[0](ch);

        if(Std.is(ch, TextChannel) || Std.is(ch, NewsChannel)) { 
            // since they are literally the same thing, and i don't think it's necessary to 
            //  have a new map of just news channels considering how niche it is
            textChannels.set(ch.id.id, cast(ch, TextChannel));
        }else if(Std.is(ch, VoiceChannel)) {
            voiceChannels.set(ch.id.id, cast(ch, VoiceChannel));
        }else if(Std.is(ch, CategoryChannel)){
            categoryChannels.set(ch.id.id, cast(ch, CategoryChannel));
        }else if(Std.is(ch, StoreChannel)){ 
            // I can't do similar things to newschannel here since storechannel is distinct
            storeChannels.set(ch.id.id, cast(ch, StoreChannel));
        }else{
            throw "Unsupported channel type in channel addition in guild";
        }
        // if(c.type == 0)
        //     textChannels.set(c.id.id, cast(c, TextChannel));
        // else if(c.type == 2)
        //     voiceChannels.set(c.id.id, cast(c, VoiceChannel));
        // else
        //     categoryChannels.set(c.id.id, cast(c, CategoryChannel));
    }

    @:dox(hide)
    public function _addBan(user) {
        bans.push(user);
    }

    @:dox(hide)
    public function _removeBan(user) {
        bans.remove(user);
    }

    @:dox(hide)
    public function _newMember(memberStruct:com.raidandfade.haxicord.types.structs.GuildMember) {
        if( members.exists(memberStruct.user.id) ) {
            var m = members.get(memberStruct.user.id);
            m._update(memberStruct);
            return m;
        } else {
            var member = new GuildMember(memberStruct, this, client);
            members.set(memberStruct.user.id, member);
            return member;
        }
    }

    @:dox(hide)
    public function _newRole(roleStruct:com.raidandfade.haxicord.types.structs.Role) {
        if(roles.exists(roleStruct.id) ) {
            var r = roles.get(roleStruct.id);
            r._update(roleStruct);
            return r;
        } else {
            var role = new Role(roleStruct, this, client);
            roles.set(roleStruct.id, role);
            return roles.get(roleStruct.id);
        }
    }

    //Live structs
    /**
        Get the channels in a guild
        @param cb - Return an array of channel objects, or an error.
     */
    public function getChannels(cb = null) {
        client.endpoints.getChannels(id.id, cb); 
    }
    
    /**
        Create a channel in a guild
        @param cs - The channel's starting data 
        @param cb - Callback to send the new channel object to. Or null if result is not desired.
     */
    public function createChannel(cs, cb:GuildChannel->String->Void = null) {
        client.endpoints.createChannel(id.id, cs, function(c, e) {
            if(e != null) {
                cb(null, e);
            } else {
                nextChancb.push(
                    (
                        function(c:GuildChannel, cb):Void {
                            cb(c, null);
                        }
                    ).bind(_, cb)
                );
            }
        });
    }

    /**
        Get a channel based on a given channel id.
        @param channel_id - The channel id to get the channel from
        @param cb - Callback to send the receivied channel object to. Or null if result is not desired.
     */
    public function getChannel(cid, cb:Channel->Void = null) {
        client.getChannel(cid, cb);
    }

    /**
        Try to find all channels that have names that contain (or equal are to) the given string
        @return - A list of applicable channels, ordered by absolute equality first and then partial equality afterwards
    */
    public function findChannels(name:String):Array<GuildChannel>{
        var rs = [];
        var cs = [];
        for(r in textChannels.iterator()){
            if(r.name == name){
                rs.push(cast(r,GuildChannel));
            }else if(r.name.indexOf(name)>-1){
                cs.push(cast(r,GuildChannel));
            }
        }
        for(r in voiceChannels.iterator()){
            if(r.name == name){
                rs.push(cast(r,GuildChannel));
            }else if(r.name.indexOf(name)>-1){
                cs.push(cast(r,GuildChannel));
            }
        }
        for(r in categoryChannels.iterator()){
            if(r.name == name){
                rs.push(cast(r,GuildChannel));
            }else if(r.name.indexOf(name)>-1){
                cs.push(cast(r,GuildChannel));
            }
        }
        for(r in storeChannels.iterator()){
            if(r.name == name){
                rs.push(cast(r,GuildChannel));
            }else if(r.name.indexOf(name)>-1){
                cs.push(cast(r,GuildChannel));
            }
        }

        for(r in cs){
            rs.push(r);
        }

        return rs;
    }

    public function moveChannels() {
        //TODO this...
    }

    /**
        Get a list of all invites in a guild. requires the MANAGE_GUILD permission.
        @param cb - Returns an array of invites, or an error.
     */
    public function getInvites(cb = null) {
        client.endpoints.getInvites(id.id, cb);
    }

    /**
        Get the roles of a guild. Requires the MANAGE_ROLES permission.
        @param cb - Returns an array of guilds, or an error.
     */
    public function getRoles(cb = null) {
        client.endpoints.getGuildRoles(id.id, cb); 
    }

    /**
        Get a role by ID.  
        @return - The role being asked for, or null
    */
    public function getRole(rid){
        return roles.get(rid);
    }

    /**
        Try to find a role whose name contains (or is equal to) the given string
        @return - A list of applicable roles, ordered by absolute equality first and then partial equality afterwards
    */
    public function findRoles(name:String):Array<Role>{
        var rs = [];
        var cs = [];
        for(r in roles){
            if(r.name == name){
                rs.push(r);
            }else if(r.name.indexOf(name)>-1){
                cs.push(r);
            }
        }

        for(r in cs){
            rs.push(r);
        }

        return rs;
    }

    /**
        Create a role. Requires the MANAGE_ROLES permission.
        @param rs - The role's data.
        @param cb - Returns the new role, or an error.
     */
    public function createRole(rs, cb = null) {
        client.endpoints.createRole(id.id, rs, cb); 
    }

    public function moveRole(rs, cb = null) { //NTS: translate from the thing you impl in d.io
        //TODO this
    }

    /**
        Get a member of the guild.
        @param mid - The member's id.
        @param cb - Return a member instance of the user. Or an error.
     */
    public function getMember(mid, cb:GuildMember->Void) {
        if(members.exists(mid)) {
            cb(members.get(mid));
        } else {
            client.endpoints.getGuildMember(id.id, mid, function(r, e) {
                if(e != null)
                    throw(e);
                cb(r);
            });
        }
    }

    /**
        Get a member by ID unsafely. 
        @param id - The id of the member you want
        @returns The member object or null
     */
    public function getMemberUnsafe(id) {
        if(members.exists(id)) {
            return members.get(id);
        } else {
            return null;
        }
    }

    /**
        To be finished. Will return all members in one callback.
     */
     public function getAllMembers(cb:List<GuildMember>) {
         trace("Call to unfinished function getAllMembers. Please don't do this");
     }

    /**
        Get all members of a guild. 
        @param format - The limit, and after. both are optional. used for paginating.
        @param cb - The array of guild members. or an error.
    */
    public function getMembers(format, cb = null) {
        client.endpoints.getGuildMembers(id.id, format, cb);
    }

    /**
        Add a guild member using a token received through Oauth2. 
        Requires the CREATE_INSTANT_INVITE permission along with various other permissions depending on `member_data` parameters
        @param uid - The id of the user
        @param mdata - The access token, along with other optional parameters.
        @param cb - The added guildmember. or an error.
     */
    public function addMember(uid, mdata, cb = null) {
        client.endpoints.addGuildMember(id.id, uid, mdata, cb);
    }

    /**
        Change this user's nickname.
        @param s - The nickname to change to.
        @param cb - Returns the nickname, or an error.
     */
    public function changeNickname(s:String, m:GuildMember = null, cb = null) {
        if(m == null || m.user.id.id == client.user.id.id)
            client.endpoints.changeNickname(id.id, s, cb);
        else
            client.endpoints.editGuildMember(id.id, m.user.id.id, {nick:s}, cb);
    }

    /**
        List all the bans in a guild. Requires the BAN_MEMBERS permission.
        @param cb - Returns an array of users, or an error.
     */
    public function getBans(cb = null) {
        client.endpoints.getGuildBans(id.id, cb);
    }

    /**
        Get the number of users that will be pruned if a prune was run. Requires the KICK_MEMBERS permission.
        @param days - The number of days to count prune for.
        @param cb - Returns the number of users that would be pruned on a real request, or an error.
     */
    public function getPruneCount(days, cb = null) {
        client.endpoints.getPruneCount(id.id, days, cb);
    }

    /**
        Get a guild's audit logs
        @param filter - Filter audit logs by these parameters.
        @param cb - Returns the AuditLog object, or an error.
     */
    public function getAuditLog(filter = null, cb = null) {
        client.endpoints.getAuditLogs(id.id, filter, cb);
    }
    /**
        Prune the members of a server. Requires the KICK_MEMBERS permission
        @param days - The number of days to count prune for.
        @param cb - Returns the number of users that were pruned, or an error.
     */
    public function beginPrune(days, cb = null) {
        client.endpoints.beginPrune(id.id, days, cb);
    }

    /**
        Get a list of voice regions for the guild. Including VIP servers if the server is a VIP-Enabled server.
        @param cb - Returns an array of voiceregion objects, or an error.
     */
    public function getVoiceRegions(cb = null) {
        client.endpoints.guildVoiceRegions(id.id, cb);
    }
    
    /**
        Get a list of integrations for a given guild. Requires the MANAGE_GUILD permission.
        @param cb - Returns an array of guildintegration objects, or an error.
     */
    public function getIntegrations(cb = null) {
        client.endpoints.getIntegrations(id.id, cb);
    }

    /**
        Add a new integration from the user onto the guild. Requires the MANAGE_GUILD permission.
        @param intd - The data of the new integration. 
        @param cb - Called on completion, useful for checking for errors.
     */
    public function addIntegration(intd, cb = null) {
        client.endpoints.addIntegration(id.id, intd, cb);
    }

    /**
        Edit an integration in a guild. Requires the MANAGE_GUILD permission.
        @param intid - The id of the integration to change.
        @param intd - The new data for the integration. All parameters are optional.
        @param cb - Called on completion, useful for checking for errors.
     */
    public function editIntegration(intid, intd, cb = null) {
        client.endpoints.editIntegration(id.id, intid, intd, cb);
    }

    /**
        Sync a given integration in a guild. Requires the MANAGE_GUILD permission.
        @param intid - The id of the integration to sync.
        @param cb - Called on completion, useful for checking for errors.
     */
    public function syncIntegration(intid, cb = null) {
        client.endpoints.syncIntegration(id.id, intid, cb);
    }

    /**
        Remove an integration from a guild. Requires the MANAGE_GUILD permission.
        @param intid - The id of the integration to remove.
        @param cb - Called on completion, useful for checking for errors.
     */
    public function deleteIntegration(intid, cb = null) {
        client.endpoints.deleteIntegration(id.id, intid, cb);
    }

    /**
        Get the widget/embed for a guild. Requires the MANAGE_GUILD permission.
        @param cb - Returns the GuildEmbed object of the guild, or an error.
     */
    public function getWidget(cb = null) {
        client.endpoints.getWidget(id.id, cb);
    }

    /**
        Change the properties of a guild's embed or widget. Requires the MANAGE_GUILD permission.
        @param wd - The changes to be made to the widget/embed. All parameters are optional.
        @param cb - Returns the changed GuildEmbed object, or an error.
     */
    public function editWidget(wd, cb = null) {
        client.endpoints.modifyWidget(id.id, wd, cb);
    }
    
    /**
        Edit a guild's settings. Requires the MANAGE_GUILD permission
        @param gd - The data to be changed, All fields are optional.
        @param cb - Returns the new guild object, or an error.
     */
    public function edit(gd, cb = null) {
        client.endpoints.modifyGuild(id.id, gd, cb);
    }

    /**
        Delete a guild. The account must be the owner of the guild.
        @param cb - Return the old guild object, or an error.
     */
    public function delete(cb = null) {
        client.endpoints.deleteGuild(id.id, cb);
    }

    /**
        Make the current user leave the specified guild.
        @param cb - Called on completion, useful for checking for errors.
     */
    public function leave(cb = null) {
        client.endpoints.leaveGuild(id.id, cb);
    }

    /**
        Get all emojis on the guild by guild_id.
        @param cb - Returns an array of emoji objects, or an error.
     */
    public function listEmojis(cb = null) {
        client.endpoints.listEmojis(id.id, cb);
    }

    /**
        Get an emojis from the guild by id of guild and emoji.
        @param emoji_id - The emoji to get
        @param cb - Returns an emoji object, or an error.
     */
    public function getEmoji(emoji_id, cb = null) {
        client.endpoints.getEmoji(id.id, emoji_id, cb);
    }

    /**
        Create an emoji in the guild.
        @param emoji - The emoji to create.
        @param cb - The created emoji, or an error
     */
    public function createEmoji(emoji, cb = null) {
        //REQUIRES MANAGE_EMOJIS
        client.endpoints.createEmoji(id.id, emoji, cb);
    }

    /**
        Modify an emoji in the guild.
        @param emoji_id - The emoji to edit.
        @param emoji - The new emoji data.
        @param cb - The edited emoji, or an error
     */
    public function modifyEmoji(emoji_id, emoji, cb = null) {
        //REQUIRES MANAGE_EMOJIS
        client.endpoints.modifyEmoji(id.id, emoji_id, emoji, cb);
    }

    /**
        Remove an emoji by ID in the guild
        @param cb - Called when completed, good for looking for errors
     */
    public function removeEmoji(emoji_id, cb = null) {
        //REQUIRES MANAGE_EMOJIS
        client.endpoints.removeEmoji(id.id, emoji_id, cb);
    }
}
