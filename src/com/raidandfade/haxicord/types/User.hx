package com.raidandfade.haxicord.types;

class User {

    var client:DiscordClient;

    /**
       The id of the user
     */
    public var id:Snowflake; 
    /**
       The mention string (tag) of the user
     */
    public var tag:String;
    /**
       The username of the user
     */
    public var username:String;
    /**
       The discriminator of the user
     */
    public var discriminator:String;
    /**
       The avatar hash of the user
     */
    public var avatar:String;
    /**
       The avatar url of the user
     */
    public var avatarUrl:String;
    /**
       Is the user a bot?
     */
    public var bot:Bool;
    /**
        Does the user have MFA enabled?
        Only set for the bot user.
     */
    public var mfa_enabled:Bool; //only me :(
    /**
       The game that the current user is playing.
     */
    public var game:com.raidandfade.haxicord.types.structs.Presence.PresenceGame;

    //The next two can only be gained from the OAUTH2 Endpoint.
    /**
        Has the user verified their email?
        PLACEHOLDER. WILL NEVER CONTAIN ANYTHING
     */
    public var verified:Bool;
    /**
        The user's email
        PLACEHOLDER. WILL NEVER CONTAIN ANYTHING
     */
    public var email:String;


    @:dox(hide)
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

    @:dox(hide)
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

}
