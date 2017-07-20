package com.raidandfade.haxicord.test;

/* The concept behind the features and featurestest files:
* - To check every single endpoint
* - To check every single event
* - To compare results to desired results, and mark as working or not working.
*/
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
    var ws_reaction:Map<String,Bool> = new Map<String,Bool>();
    var ws_user:Map<String,Bool> = new Map<String,Bool>();
    var ws_voice:Map<String,Bool> = new Map<String,Bool>(); //Lol good joke

    public function new(){
        //REST
        channel_management.set("create",true);
        channel_management.set("delete",false);
        channel_management.set("dm",true);
        channel_management.set("edit",false);
        channel_management.set("history",true);
        channel_management.set("info",true);
        channel_management.set("permission",false);

        misc.set("edit profile",false);
        misc.set("send typing",false);
        misc.set("voice move",false);

        invites.set("create",true);
        invites.set("delete",false);
        invites.set("info",false);
        invites.set("join",false);

        messages.set("send",true);
        messages.set("send file",false);
        messages.set("edit",false);
        messages.set("delete",false);

        roles.set("create",true);
        roles.set("delete",false);
        roles.set("edit",false);
        roles.set("info",false);

        servers.set("ban",false);
        servers.set("unban",false);
        servers.set("kick",false);
        servers.set("create",true);
        servers.set("delete",true);
        servers.set("edit",false);
        servers.set("change owner",false);
        servers.set("info",false);
        servers.set("ban list",false);
        
        //WS
        ws_channel.set("create",true);
        ws_channel.set("delete",true);
        ws_channel.set("update",true);

        ws_message.set("delete",true);
        ws_message.set("receive",true);
        ws_message.set("update",true);

        ws_reaction.set("add",false);
        ws_reaction.set("remove",false);
        ws_reaction.set("remove all",false);

        ws_role.set("create",true);
        ws_role.set("delete",true);
        ws_role.set("update",true);

        ws_presence.set("receive",true);
        ws_presence.set("send",false);

        ws_misc.set("typing",true);

        ws_user.set("join",true);
        ws_user.set("leave",true);

        ws_voice.set("receive",true);
        ws_voice.set("send",true);
        ws_voice.set("multi server",true);
        ws_voice.set("state update",true);
    }

    public function calculatePercentage(debug=false){
        var total = 0;
        var completed = 0;
        for (map in [channel_management,misc,invites,messages,roles,servers,ws_channel,ws_message,ws_role,ws_presence,ws_misc,ws_user,ws_voice,ws_reaction]){
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