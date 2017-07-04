package com.raidandfade.haxicord.test;

import com.raidandfade.haxicord.websocket.WebSocketConnection;
import com.raidandfade.haxicord.endpoints.Endpoints;

class Test
{

	static function main()
	{
		//Features : 
		var f = new Features();
		trace((f.calculatePercentage()*100)+"% OF FEATURES ARE DONE.");
		
		//Endpoint base test : 

		var discordBot = new DiscordClient("MzMxNjU5NjAwODQxNTM5NTg3.DDyxlQ.4kAF224DP2D4IYPba7tE2GKsqfQ");

		var endpoints = new Endpoints(discordBot);

		endpoints.callEndpoint("GET","/gateway",receiveData);
		trace("1: ");

#if !js
        while(true){
			Sys.sleep(1);
            //maybe it needs to keep running the main thread otherwise everything go boom?
        }
#end
	}

	public static function receiveData(r){
		trace("2: " + r);
	}
}