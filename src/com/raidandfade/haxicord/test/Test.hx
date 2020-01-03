package com.raidandfade.haxicord.test;

import com.raidandfade.haxicord.websocket.WebSocketConnection;
import haxe.Json;
import haxe.Timer;

import com.raidandfade.haxicord.types.Guild;
import com.raidandfade.haxicord.types.GuildMember;
import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.types.Snowflake;

import com.raidandfade.haxicord.DiscordClient;

import com.raidandfade.haxicord.shardmaster.Sharder;

class Test
{

	static var sharder:Sharder;
	static var discordBot:DiscordClient;

    static var startTime:Date;

	static function main()
	{
		//INIT the actual client with your token
		// sharder = new Sharder("MzQ5OTk2NzQxNTQ3OTE3MzIy.Dc1xzA.wIlBrSulp46ZXTP4z-7PaDWzR-E");

		// sharder.onReady = function(){
		// 	sharder.shardManual(4);
		// };

		// sharder.start();

        startTime = Date.now();        

		// //Bind the events to the proper handlers
		discordBot = new DiscordClient(Sys.getEnv("DevBotToken"));
		discordBot.onReady = onReady;
		discordBot.onMessage = onMessage;
        
        discordBot.onGuildCreate = function(g){
            trace("Guild Object Created For "+g.name+"("+g.id.id+")");
        }
        
        trace("cbt?");
	}

	public static function onMessage(m:Message) {
		if(m.author.id.id != "120308435639074816"){
            return;
        }
        if(m.content=="-!p"){
            m.reply({content:"cbt!"});
#if Profiler
        Profiler.traceResults();
#end
        }
	}

	public static function onReady() {
        trace("My invite link is: " + discordBot.getInviteLink());
        trace(Date.now().getTime()-startTime.getTime());
#if Profiler
        Profiler.traceResults();
#end
	}
}