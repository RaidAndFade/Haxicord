package com.raidandfade.haxicord;

class DiscordClient { 
    public static var userAgent:String = "DiscordBot (https://github.com/RaidAndFade/Haxicord,0.0.1)";

    public var token:String;

    public function new(_tkn:String){ //Sharding? lol good joke.
        token = "Bot" + _tkn; //ASSUME BOT FOR NOW. Deal with users later maybe.

        //Init websocket
		//ws = new WebSocketConnection("ws://echo.websocket.org");
		//ws.send("Henlo!");


    }
}