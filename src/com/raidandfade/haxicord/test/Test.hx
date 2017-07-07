package com.raidandfade.haxicord.test;

import com.raidandfade.haxicord.websocket.WebSocketConnection;
import haxe.Json;
import haxe.Timer;

class Test
{

	static function main()
	{
		//Features : 
		var f = new Features();
		trace((f.calculatePercentage()*100)+"% OF FEATURES ARE DONE.");

		var discordBot = new DiscordClient("MzMxNjU5NjAwODQxNTM5NTg3.DD4goA.qW87aMd13sVmuhSgOvG1l_vlxAs");
		discordBot.onOpen = onOpen;
		discordBot.start();

	}

	public static function onOpen(){
		trace("Client done");
	};

	public static function receiveData(r){
		//trace("Headers : " + h);
		trace("Response: " + Json.stringify(r));
	}
}