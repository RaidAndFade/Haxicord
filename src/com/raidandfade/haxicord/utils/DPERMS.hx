package com.raidandfade.haxicord.utils;


/*how this works:
* ok so there's an abstract DPERMS enum which maps names to vals, this is for easy programming
* 
*/
class DPERMS {
    public static var CREATE_INSTANT_INVITE:Int = 0x00000001;
    public static var KICK_MEMBERS:Int          = 0x00000002;
    public static var BAN_MEMBERS:Int           = 0x00000004;
    public static var ADMINISTRATOR:Int         = 0x00000008;
    public static var MANAGE_CHANNELS:Int       = 0x00000010;
    public static var MANAGE_GUILD:Int          = 0x00000020;
    public static var ADD_REACTIONS:Int         = 0x00000040;
    public static var VIEW_AUDIT_LOG:Int        = 0x00000080;
    public static var VIEW_CHANNEL:Int          = 0x00000400;
    public static var SEND_MESSAGES:Int         = 0x00000800;
    public static var SEND_TTS_MESSAGES:Int     = 0x00001000;
    public static var MANAGE_MESSAGES:Int       = 0x00002000;
    public static var EMBED_LINKS:Int           = 0x00004000;
    public static var ATTACH_FILES:Int          = 0x00008000;
    public static var READ_MESSAGE_HISTORY:Int  = 0x00010000;
    public static var MENTION_EVERYONE:Int      = 0x00020000;
    public static var USE_EXTERNAL_EMOJIS:Int   = 0x00040000;
    public static var CONNECT:Int               = 0x00100000;
    public static var SPEAK:Int                 = 0x00200000;
    public static var MUTE_MEMBERS:Int          = 0x00400000;
    public static var DEAFEN_MEMBERS:Int        = 0x00800000;
    public static var MOVE_MEMBERS:Int          = 0x01000000;
    public static var USE_VAD:Int               = 0x02000000;
    public static var PRIORITY_SPEAKER:Int      = 0x00000100;
    public static var CHANGE_NICKNAME:Int       = 0x04000000;
    public static var MANAGE_NICKNAMES:Int      = 0x08000000;
    public static var MANAGE_ROLES:Int          = 0x10000000;
    public static var MANAGE_WEBHOOKS:Int       = 0x20000000;
    public static var MANAGE_EMOJIS:Int         = 0x40000000;

    private static var pnames:Array<String>=["CREATE_INSTANT_INVITE","KICK_MEMBERS","BAN_MEMBERS","ADMINISTRATOR","MANAGE_CHANNELS","MANAGE_GUILD","ADD_REACTIONS","VIEW_AUDIT_LOG","VIEW_CHANNEL","SEND_MESSAGES","SEND_TTS_MESSAGES","MANAGE_MESSAGES","EMBED_LINKS","ATTACH_FILES","READ_MESSAGE_HISTORY","MENTION_EVERYONE","USE_EXTERNAL_EMOJIS","CONNECT","SPEAK","MUTE_MEMBERS","DEAFEN_MEMBERS","MOVE_MEMBERS","USE_VAD","PRIORITY_SPEAKER","CHANGE_NICKNAME","MANAGE_NICKNAMES","MANAGE_ROLES","MANAGE_WEBHOOKS","MANAGE_EMOJIS"];
    private static var pvals:Array<Int>=[DPERMS.CREATE_INSTANT_INVITE,DPERMS.KICK_MEMBERS,DPERMS.BAN_MEMBERS,DPERMS.ADMINISTRATOR,DPERMS.MANAGE_CHANNELS,DPERMS.MANAGE_GUILD,DPERMS.ADD_REACTIONS,DPERMS.VIEW_AUDIT_LOG,DPERMS.VIEW_CHANNEL,DPERMS.SEND_MESSAGES,DPERMS.SEND_TTS_MESSAGES,DPERMS.MANAGE_MESSAGES,DPERMS.EMBED_LINKS,DPERMS.ATTACH_FILES,DPERMS.READ_MESSAGE_HISTORY,DPERMS.MENTION_EVERYONE,DPERMS.USE_EXTERNAL_EMOJIS,DPERMS.CONNECT,DPERMS.SPEAK,DPERMS.MUTE_MEMBERS,DPERMS.DEAFEN_MEMBERS,DPERMS.MOVE_MEMBERS,DPERMS.USE_VAD,DPERMS.PRIORITY_SPEAKER,DPERMS.CHANGE_NICKNAME,DPERMS.MANAGE_NICKNAMES,DPERMS.MANAGE_ROLES,DPERMS.MANAGE_WEBHOOKS,DPERMS.MANAGE_EMOJIS];
    
    public static function PermsAsNamedList(p:Int):Array<String>{
        var l = new Array<String>();
        for(x in 0...pvals.length){
            if(p&cast(pvals[x],Int) > 0){
                l.push(pnames[x]);
            }
        }
        return l;
    }

    public static function PermsAsList(p:Int):Array<Int>{
        var l = new Array<Int>();
        for(x in pvals){
            if(p&cast(x,Int) > 0){
                l.push(x);
            }
        }
        return l;
    }

    public static function PermsToInt(p:Array<Int>):Int{
        var i = 0;
        for(x in p){
            i |= x;
        }
        return i;
    }

    public static function PermsToString(p:Int):String{
        var l = PermsAsNamedList(p);
        return l.join(" | ");
    }

    public static function PermArrToString(p:Array<Int>):String{
        return p.map(function(x){
            return permToString(x);
        }).join(" | ");
    }

    public static function permToString(d:Int):String{
        return pnames[pvals.indexOf(d)];
    }
}
