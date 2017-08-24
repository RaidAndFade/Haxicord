package com.raidandfade.haxicord.types;


class DMChannel extends Channel implements MessageChannel{
    public var recipient:User;
    public var recipients:Array<User>;
    public var last_message_id:Snowflake;

    public function new(_chan:com.raidandfade.haxicord.types.structs.DMChannel,_client:DiscordClient){
        client = _client;

        trace(_chan);
        id = new Snowflake(_chan.id);
        type = _chan.type;
        if(_chan.recipient!=null) 
        {
            recipient = client._newUser(_chan.recipient);
            recipients = [recipient];
        }
        if(_chan.recipients!=null) 
        {
            recipients = [for(u in _chan.recipients){client._newUser(u);}];
            if(recipients.length==1){
                recipient = recipients[0];
            }
        }
        last_message_id = new Snowflake(_chan.last_message_id);
    }

    public function _update(_chan:com.raidandfade.haxicord.types.structs.DMChannel){
        
        if(_chan.recipient!=null) 
        {
            recipient = client._newUser(_chan.recipient);
            recipients = [recipient];
        }
        if(_chan.recipients!=null) 
        {
            recipients = [for(u in _chan.recipients){client._newUser(u);}];
            if(recipients.length==1){
                recipient = recipients[0];
            }
        }
        if(_chan.last_message_id!=null)last_message_id = new Snowflake(_chan.last_message_id);
    }

    public static function fromStruct(_chan,_client){
        return new DMChannel(_chan,_client);
    }

//Live endpoints
    public function inGuild(){
        return false;
    }

    public function sendMessage(mesg,cb=null):Void{
        client.endpoints.sendMessage(id.id,mesg,cb);
    }

    public function addMember(user_id,access_token,cb=null){
        client.endpoints.groupDMAddRecipient(id.id,user_id,access_token,cb);
    }

    public function kickMember(user_id,cb=null){
        client.endpoints.groupDMRemoveRecipient(id.id,user_id,cb);
    }

    public function getMessages(format=null,cb=null){
        if(format==null)format={};
        client.endpoints.getMessages(id.id,format,cb);
    }

    public function getMessage(mid,cb=null){
        client.endpoints.getMessage(id.id,mid,cb);
    }

    public function deleteMessage(mid,cb=null){
        client.endpoints.deleteMessage(id.id,mid,cb);
    }

    public function deleteMessages(ids,cb=null){
        client.endpoints.deleteMessages(id.id,ids,cb);
    }

    public function startTyping(cb=null){
        client.endpoints.startTyping(id.id,cb);
    }

    public function getPins(cb=null){
        client.endpoints.getChannelPins(id.id,cb);
    }

    public function pinMessage(mid,cb=null){
        client.endpoints.addChannelPin(id.id,mid,cb);
    }

    public function unpinMessage(mid,cb=null){
        client.endpoints.deleteChannelPin(id.id,mid,cb);
    }   
}