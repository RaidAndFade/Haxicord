package com.raidandfade.haxicord.types;

class NewsChannel extends TextChannel{
    @:dox(hide)
    public function new(_chan:com.raidandfade.haxicord.types.structs.GuildChannel.NewsChannel, _client:DiscordClient) {
        super(_chan,_client);
    }
    
    @:dox(hide)
    public static function fromStruct(_chan, _client) {
        return new NewsChannel(_chan, _client);
    }
}
