package com.raidandfade.haxicord.test;

import com.raidandfade.haxicord.websocket.WebSocketConnection;
import haxe.Json;
import haxe.Timer;

import com.raidandfade.haxicord.types.Message;

class Test
{

	static var discordBot:DiscordClient;

	static function main()
	{
		discordBot = new DiscordClient("");
		discordBot.onReady = onReady;
		discordBot.onMessage = onMessage;

		discordBot.start();

	}

	public static function onMessage(m:Message){
		if(m.content=="!ping"){
			m.reply({"content":"pong!"},function(m,e){});
		}
	}

	public static function onReady(){
		trace("Loaded up.");
	};
}