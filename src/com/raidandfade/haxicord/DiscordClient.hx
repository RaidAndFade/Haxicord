package com.raidandfade.haxicord;

import com.raidandfade.haxicord.websocket.WebSocketConnection;
import com.raidandfade.haxicord.endpoints.Endpoints;

import haxe.Json;

class DiscordClient { 
    public static var userAgent:String = "DiscordBot (https://github.com/RaidAndFade/Haxicord,0.0.1)";
    public static var gatewayVersion:Int = 6;

    public var token:String;

    public var endpoints:Endpoints;

    var ws:WebSocketConnection;

    public function new(_tkn:String){ //Sharding? lol good joke.
        token = "Bot " + _tkn; //ASSUME BOT FOR NOW. Deal with users later maybe.
        
        endpoints = new Endpoints(this);

        trace("Getting gotten");
        endpoints.getGateway(false,connect);
        //Init websocket
		//ws = new WebSocketConnection("ws://echo.websocket.org");
		//ws.send("Henlo!");
    }
//Flowchart
    public function connect(gateway){
        trace("Gottening");
        ws = new WebSocketConnection(gateway.url+"?v="+gatewayVersion+"&encoding=json");
        ws.onMessage = webSocketMessage;
    }

    public function webSocketMessage(msg){
        var m:WSMessage = Json.parse(msg);
        trace(m);
    }

    public function start(blocking=true){
#if sys
        while(blocking){
            Sys.sleep(1);
        }
#end
    }
//Events 
    public dynamic function onWSOpen(){
        
    }

    public dynamic function onOpen(){

    }

}

typedef WSMessage = {
    var op:Int;
    var d:Array<Dynamic>;
}