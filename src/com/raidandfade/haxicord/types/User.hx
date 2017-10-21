package com.raidandfade.haxicord.types;

class User {

    var client:DiscordClient;

    public var id:Snowflake; 
    public var tag:String;
    public var username:String;
    public var discriminator:String;
    public var avatar:String;
    public var avatarUrl:String;
    public var bot:Bool;
    public var mfa_enabled:Bool; //only me :(
    public var game:com.raidandfade.haxicord.types.structs.Presence.PresenceGame;

    //The next two can only be gained from the OAUTH2 Endpoint.
    public var verified:Bool;
    public var email:String;


    public function new(_user:com.raidandfade.haxicord.types.structs.User,_client:DiscordClient){
        client = _client;

        id = new Snowflake(_user.id);
        tag = "<@"+id.id+">";
        username = _user.username;
        discriminator = _user.discriminator;
        avatar = _user.avatar;
        avatarUrl = "https://cdn.discordapp.com/avatars/"+_user.id+"/"+_user.avatar+".png"; //TODO gifs? other filetypes? 
        bot = _user.bot;
        if(_user.mfa_enabled!=null) mfa_enabled = _user.mfa_enabled;
        if(_user.verified!=null)    verified = _user.verified;
        if(_user.email!=null)       email = _user.email;
    }

    public function _update(_user:com.raidandfade.haxicord.types.structs.User){
        if(_user.username!=null) username = _user.username;
        if(_user.discriminator!=null) discriminator = _user.discriminator;
        if(_user.avatar!=null) avatar = _user.avatar;
        if(_user.avatar!=null) avatarUrl = "https://cdn.discordapp.com/avatars/"+_user.id+"/"+_user.avatar+".png"; //TODO gifs? other filetypes? \
        if(_user.bot!=null) bot = _user.bot;
        if(_user.mfa_enabled!=null) mfa_enabled = _user.mfa_enabled;
        if(_user.verified!=null)    verified = _user.verified;
        if(_user.email!=null)       email = _user.email;
    }
    //TODO live endpoints


}
