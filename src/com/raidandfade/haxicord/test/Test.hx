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

	static function main()
	{
		//INIT the actual client with your token
		// sharder = new Sharder("MzQ5OTk2NzQxNTQ3OTE3MzIy.Dc1xzA.wIlBrSulp46ZXTP4z-7PaDWzR-E");

		// sharder.onReady = function(){
		// 	sharder.shardManual(4);
		// };

		// sharder.start();
		// //Bind the events to the proper handlers
		discordBot = new DiscordClient("MzQ5OTk2NzQxNTQ3OTE3MzIy.Dc1xzA.wIlBrSulp46ZXTP4z-7PaDWzR-E",null,false,true);
		discordBot.onReady = onReady;
		discordBot.onMessage = onMessage;
		discordBot.start();
		// discordBot.onMemberJoin = onMemberJoin;

		//Start the bot.
		//IF BUILDING ON SYS, THIS FUNC IS BLOCKING UNTIL THE BOT STOPS
		//If you dont want it to be blocking, use `start(false)`
		//discordBot.start();
	}

	public static function onMessage(m:Message) {
		//m.content
		m.content.indexOf
		if(m.content == "!test"){
			m.reply({content:"Hello from zlib-stream!"});
		}
	}

	public static function onReady() {
        trace("My invite link is: " + discordBot.getInviteLink());
	}

	public static function onMemberJoin(g:Guild, m:GuildMember) {

	}
}