package com.raidandfade.haxicord.types;


class DMChannel extends Channel{
    public var recipient:User;
    public var last_message_id:Snowflake;

    public function new(_chan:com.raidandfade.haxicord.types.structs.DMChannel,_client:DiscordClient){
        client = _client;

        id = new Snowflake(_chan.id);
        is_private = _chan.is_private;
        recipient = client.newUser(_chan.recipient);
        last_message_id = new Snowflake(_chan.last_message_id);
    }

    public static function fromStruct(_chan,_client){
        return new DMChannel(_chan,_client);
    }
}