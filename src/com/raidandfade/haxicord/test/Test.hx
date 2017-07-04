package com.raidandfade.haxicord.test;

import com.raidandfade.haxicord.websocket.WebSocketConnection;
class Test
{

	static var ws:WebSocketConnection;

	static function main()
	{
		ws = new WebSocketConnection("ws://echo.websocket.org");
		ws.send("Henlo!");

        while(true){
            //maybe it needs to keep running the main thread otherwise everything go boom?
        }
	}
}