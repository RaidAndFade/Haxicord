package com.raidandfade.haxicord.types;

import com.raidandfade.haxicord.utils.DPERMS;

#if Profiler
@:build(Profiler.buildAll())
#end
class DMChannel extends Channel implements MessageChannel{

    /**
       The other person in the DM chat. Will be null for Group DMs
     */
    public var recipient:User;
    /**
       A list of all others in the dm channel.
     */
    public var recipients:Array<User>;
    /**
       The id of the last Message that was sent in the chat.
     */
    public var last_message_id:Snowflake;

    @:dox(hide)
    public function new(_chan:com.raidandfade.haxicord.types.structs.DMChannel, _client:DiscordClient) {
        client = _client;

        //trace(_chan);

        id = new Snowflake(_chan.id);
        type = _chan.type;
        if(_chan.recipient != null) 
        {
            recipient = client._newUser(_chan.recipient);
            recipients = [recipient];
        }
        if(_chan.recipients != null) 
        {
            recipients = [ for(u in _chan.recipients){ client._newUser(u); } ];
            if(recipients.length == 1) {
                recipient = recipients[0];
            }
        }
        last_message_id = new Snowflake(_chan.last_message_id);
    }

    @:dox(hide)
    public function _update(_chan:com.raidandfade.haxicord.types.structs.DMChannel) {
        
        if(_chan.recipient != null) 
        {
            recipient = client._newUser(_chan.recipient);
            recipients = [recipient];
        }
        if(_chan.recipients != null) 
        {
            recipients = [ for(u in _chan.recipients){ client._newUser(u); } ];
            if(recipients.length == 1) {
                recipient = recipients[0];
            }
        }
        if(_chan.last_message_id != null)
            last_message_id = new Snowflake(_chan.last_message_id);
    }

    @:dox(hide)
    public static function fromStruct(_chan, _client) {
        return new DMChannel(_chan, _client);
    }

//Live endpoints
    /**
        Returns whether the channel is in a guild or not (Always false for DM channels)
     */
    public function inGuild() {
        return false;
    }
    /**
        Send a message to a channel
        @param mesg - Message data
        @param cb - Return the message sent, or an error
     */
    public function sendMessage(mesg, cb = null):Void {
        client.endpoints.sendMessage(id.id, mesg, cb);
    }
    /**
        Add a user to a group dm.
        @param user_id - The user to be added.
        @param access_token - An OAUTH2 token received from authenticating the user.
        @param nick - The nickname of the user.
        @param cb - Called once completed.
     */
     public function addMember(user_id, access_token, nick, cb = null) {
        client.endpoints.groupDMAddRecipient(id.id, user_id, access_token, nick, cb);
    }
    /**
        Remove a user from a group dm.
        @param user_id - The user to be removed
        @param cb - Called once completed, or errored
     */
    public function kickMember(user_id, cb = null) {
        client.endpoints.groupDMRemoveRecipient(id.id, user_id, cb);
    }
    /**
        Get messages from a given channel according to the given format.
        @param format - Before, After, or Around. 
        @param cb - The array of messages, or an error.
     */
    public function getMessages(format = null, cb = null) {
        client.endpoints.getMessages(id.id, format, cb);
    }
    /**
        Get a message in a channel
        @param mid - The message id
        @param cb - Return the message, or an error.
     */
    public function getMessage(mid, cb = null) {
        client.endpoints.getMessage(id.id, mid, cb);
    }
    /**
        Delete a given message. If the author is not the current user, the MANAGE_MESSAGES permission is required
        @param mid - The id of the message.
        @param cb - Return when complete.
     */
    public function deleteMessage(mid, cb = null) {
        client.endpoints.deleteMessage(id.id, mid, cb);
    }
    /**
        Delete a given messages. MANAGE_MESSAGES is required.
        @param ids - an array of id of the messages.
        @param cb - Return when complete.
     */
    public function deleteMessages(ids, cb = null) {
        client.endpoints.deleteMessages(id.id, ids, cb);
    }
    /**
        Send a typing event in the given channel. This lasts for 10 seconds or when a message is sent, whichever comes first.
        @param cb - Return when complete.
     */
    public function startTyping(cb = null) {
        client.endpoints.startTyping(id.id, cb);
    }
    /**
        Get the pins of a channel
        @param cb - Return an array of pins (or an error)
     */
    public function getPins(cb = null) {
        client.endpoints.getChannelPins(id.id, cb);
    }
    /**
        Add a channel pin
        @param mid - The message
        @param cb - Called once completed. Leave blank to ignore.
     */
    public function pinMessage(mid, cb = null) {
        client.endpoints.addChannelPin(id.id, mid, cb);
    }
    /**
        Delete a channel's pin
        @param mid - The pin id
        @param cb - Called once completed. Leave blank to ignore.
     */
    public function unpinMessage(mid, cb = null) {
        client.endpoints.deleteChannelPin(id.id, mid, cb);
    }   


    public override function getPermission(uid:String):Int{
        // these are permissions that every dm channel has.
        return DPERMS.ADD_REACTIONS | DPERMS.SEND_MESSAGES | DPERMS.READ_MESSAGE_HISTORY | DPERMS.VIEW_CHANNEL | DPERMS.EMBED_LINKS | DPERMS.USE_EXTERNAL_EMOJIS;
    }

    public override function hasPermission(uid:String, dp:Int):Bool{
        return getPermission(uid) & dp == dp;
    }
}
