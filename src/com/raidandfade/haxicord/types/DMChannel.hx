package com.raidandfade.haxicord.types;


class DMChannel extends Channel{
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
            recipient = client.newUser(_chan.recipient);
            recipients = [recipient];
        }
        if(_chan.recipients!=null) 
        {
            recipients = [for(u in _chan.recipients){client.newUser(u);}];
            if(recipients.length==1){
                recipient = recipients[0];
            }
        }
        last_message_id = new Snowflake(_chan.last_message_id);
    }

    public function sendMessage(mesg,cb=null){
        client.endpoints.sendMessage(id.id,mesg,cb);
    }

    public static function fromStruct(_chan,_client){
        return new DMChannel(_chan,_client);
    }
}