package com.raidandfade.haxicord.types;

class User {

    var client:DiscordClient;

    public var id:Snowflake; 
    public var username:String;
    public var discriminator:String;
    public var avatar:String;
    public var bot:Bool;
    public var mfa_enabled:Bool;

    //The next two can only be gained from the OAUTH2 Endpoint.
    public var verified:Bool;
    public var email:String;

    public function new(_user:com.raidandfade.haxicord.types.structs.User,_client:DiscordClient){
        client = _client;

        id = new Snowflake(_user.id);
        username = _user.username;
        discriminator = _user.discriminator;
        avatar = _user.avatar;
        bot = _user.bot;
        if(_user.mfa_enabled!=null) mfa_enabled = _user.mfa_enabled;
        if(_user.verified!=null)    verified = _user.verified;
        if(_user.email!=null)       email = _user.email;
    }

    public function update(_user:com.raidandfade.haxicord.types.structs.User){
        if(_user.username!=null) username = _user.username;
        if(_user.discriminator!=null) discriminator = _user.discriminator;
        if(_user.avatar!=null) avatar = _user.avatar;
        if(_user.bot!=null) bot = _user.bot;
        if(_user.mfa_enabled!=null) mfa_enabled = _user.mfa_enabled;
        if(_user.verified!=null)    verified = _user.verified;
        if(_user.email!=null)       email = _user.email;
    }
    //TODO live endpoints
}
