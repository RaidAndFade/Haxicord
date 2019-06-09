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
       The user's current status
     */
    public var presence:com.raidandfade.haxicord.types.structs.Presence;

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

    /**
        Is the user loaded? If this is false you should consider doing user.load()
     */
    public var isLoaded:Bool;

    // TODO doc these
    public var flags:Int;
    public var premium_type:Int;


    @:dox(hide)
    public function new(_user:com.raidandfade.haxicord.types.structs.User, _client:DiscordClient) {
        client = _client;

        isLoaded = _user != null;
        if(_user == null) return;

        id = new Snowflake(_user.id);
        tag = "<@"+id.id+">";
        username = _user.username;
        discriminator = _user.discriminator;
        avatar = _user.avatar;
        avatarUrl = "https://cdn.discordapp.com/avatars/" + _user.id + "/" + _user.avatar + ".png"; //TODO gifs? other filetypes? 
        bot = _user.bot;

        //init presence with the default jazz
        presence = {status:"online"};

        if(_user.mfa_enabled != null) 
            mfa_enabled = _user.mfa_enabled;

        if(_user.verified != null)    
            verified = _user.verified;

        if(_user.email != null)
            email = _user.email;

            
        if(_user.flags != null)
            flags = _user.flags;
        if(_user.premium_type != null)
            premium_type = _user.premium_type;
    }

    @:dox(hide)
    public function _update(_user:com.raidandfade.haxicord.types.structs.User) {
        if(_user.username != null) 
            username = _user.username;

        if(_user.discriminator != null) 
            discriminator = _user.discriminator;
        
        if(_user.avatar != null) 
            avatar = _user.avatar;
        
        if(_user.avatar != null) 
            avatarUrl = "https://cdn.discordapp.com/avatars/" + _user.id + "/" + _user.avatar + ".png"; //TODO gifs? other filetypes? \
        
        if(_user.bot != null) 
            bot = _user.bot;
        
        if(_user.mfa_enabled != null) 
            mfa_enabled = _user.mfa_enabled;
        
        if(_user.verified != null)    
            verified = _user.verified;
        
        if(_user.email != null)       
            email = _user.email;
        
        if(_user.flags != null)
            flags = _user.flags;
        if(_user.premium_type != null)
            premium_type = _user.premium_type;
    }

    /**
       Load this user if it's not loaded (if isLoaded == false)
     */
    public function load(){
        if(isLoaded) return;
        client.getUser(this.id.id,function(_){});
    }

}
