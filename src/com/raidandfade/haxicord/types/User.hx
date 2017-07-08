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
        if(_user.exists("avatar"))      avatar = _user.avatar;
        if(_user.exists("bot"))         bot = _user.bot;
        if(_user.exists("mfa_enabled")) mfa_enabled = _user.mfa_enabled;
        if(_user.exists("verified"))    verified = _user.verified;
        if(_user.exists("email"))       email = _user.email;
    }
    //TODO live endpoints
}
