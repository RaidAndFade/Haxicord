package com.raidandfade.haxicord.test;

//This class lists all features that have been completed and all that have not. 
class Features {
    //Various categories from the comparison chart at https://discordapi.com/unofficial/comparison.html

    //REST
    var channel_management:Map<String,Bool> = new Map<String,Bool>();
    var misc:Map<String,Bool> = new Map<String,Bool>();
    var invites:Map<String,Bool> = new Map<String,Bool>();
    var messages:Map<String,Bool> = new Map<String,Bool>();
    var roles:Map<String,Bool> = new Map<String,Bool>();
    var servers:Map<String,Bool> = new Map<String,Bool>();

    //WS
    var ws_channel:Map<String,Bool> = new Map<String,Bool>();
    var ws_message:Map<String,Bool> = new Map<String,Bool>();
    var ws_role:Map<String,Bool> = new Map<String,Bool>();
    var ws_presence:Map<String,Bool> = new Map<String,Bool>();
    var ws_server:Map<String,Bool> = new Map<String,Bool>();
    var ws_misc:Map<String,Bool> = new Map<String,Bool>();
    var ws_user:Map<String,Bool> = new Map<String,Bool>();
    var ws_voice:Map<String,Bool> = new Map<String,Bool>(); //Lol good joke

    public function new(){
        //REST
        channel_management.set("create",false);
        channel_management.set("delete",false);
        channel_management.set("dm",false);
        channel_management.set("edit",false);
        channel_management.set("history",false);
        channel_management.set("info",false);
        channel_management.set("permission",false);

        misc.set("edit profile",false);
        misc.set("send typing",false);
        misc.set("voice move",false);

        invites.set("create",false);
        invites.set("delete",false);
        invites.set("info",false);
        invites.set("join",false);

        messages.set("send",false);
        messages.set("send file",false);
        messages.set("edit",false);
        messages.set("delete",false);

        roles.set("create",false);
        roles.set("delete",false);
        roles.set("edit",false);
        roles.set("info",false);

        servers.set("ban",false);
        servers.set("unban",false);
        servers.set("kick",false);
        servers.set("create",false);
        servers.set("delete",false);
        servers.set("edit",false);
        servers.set("change owner",false);
        servers.set("info",false);
        servers.set("ban list",false);
        
        //WS
        ws_channel.set("create",false);
        ws_channel.set("delete",false);
        ws_channel.set("update",false);

        ws_message.set("delete",false);
        ws_message.set("receive",false);
        ws_message.set("update",false);

        ws_role.set("create",false);
        ws_role.set("delete",false);
        ws_role.set("update",false);

        ws_presence.set("receive",false);
        ws_presence.set("send",false);

        ws_misc.set("typing",false);

        ws_user.set("join",false);
        ws_user.set("leave",false);

        ws_voice.set("receive",false);
        ws_voice.set("send",false);
        ws_voice.set("multi server",false);
        ws_voice.set("state update",false);
    }

    public function calculatePercentage(debug=false){
        var total = 0;
        var completed = 0;
        for (map in [channel_management,misc,invites,messages,roles,servers,ws_channel,ws_message,ws_role,ws_presence,ws_misc,ws_user,ws_voice]){
            for (feat in map.keys()) {
                if(debug)trace("DEBUG : '" + feat + "' IS "+(map.get(feat)?"":"NOT ")+"DONE!");
                total++;
                if(channel_management.get(feat)){
                    completed++;
                }
            }
        }
        return completed/total;
    }
}