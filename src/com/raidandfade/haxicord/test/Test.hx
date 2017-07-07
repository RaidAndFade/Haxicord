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


		//var ws = new WebSocketConnection("wss://echo.websocket.org?test");
		//ws.send("hi");
		var discordBot = new DiscordClient("");
		discordBot.onReady = onReady;
		discordBot.start();
	}

	public static function onReady(){
		trace("Client done");
	};

	public static function receiveData(r){
		//trace("Headers : " + h);
		trace("Response: " + Json.stringify(r));
	}
}