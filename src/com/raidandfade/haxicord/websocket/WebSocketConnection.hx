package com.raidandfade.haxicord.websocket;

import haxe.Json;

#if !cs
import haxe.net.WebSocket;
#else
import websocketsharp.WebSocket;
#end

class WebSocketConnection { 

    private static var ws:WebSocket;
    var queue:Array<String> = new Array<String>();
    var ready = false;
    private static var host:String;
    
    /**
        Connect to the given host (works for wss and ws)
        @param _host - The url of the host
     */
    public function new(_host) { 
        host = _host;
#if cpp
        var th = cpp.vm.Thread.create(create);
#elseif java
        var th = java.vm.Thread.create(create);
#elseif neko
        var th = neko.vm.Thread.create(create);
#elseif cs
        var th = new cs.system.threading.Thread(new cs.system.threading.ThreadStart(create));
        th.Start();
#else
        create();
#end
    }

    @:dox(hide)
    function create() {
#if cs
        ws = new WebSocket(host, new cs.NativeArray<String>(0));
        ws.add_OnOpen(
            new cs.system.EventHandler( function(f:Dynamic, e:cs.system.EventArgs) {
                ready = true;
                for(m in queue) {
                    send(m);
                }
                onReady();
            })
        );
        ws.add_OnMessage(
            new cs.system.EventHandler_1<websocketsharp.MessageEventArgs> ( function(f:Dynamic, m:websocketsharp.MessageEventArgs) {
                this.onMessage(m.Data);
            })
        );
        ws.add_OnError(
            new cs.system.EventHandler_1<websocketsharp.MessageEventArgs> ( function(f:Dynamic, m:websocketsharp.ErrorEventArgs) {
                this.onError(m.Message);
            })
        );
        ws.add_OnClose( 
            new cs.system.EventHandler_1<websocketsharp.MessageEventArgs> ( function(f:Dynamic, m:websocketsharp.ErrorEventArgs) {
                this._onClose();
            })
        );
        ws.Connect();
#else 
        ws = WebSocket.create(host, [], null, false);
        ws.onopen = function() {
            ready = true;
            for(m in queue) {
                send(m);
            }
            onReady();
        }
        ws.onmessageString = function(m) { 
            this.onMessage(m);
        }
        ws.onmessageBytes = function(m) {}
        ws.onerror = onError;
        ws.onclose = _onClose;
#if sys
        while (true) {
            ws.process();
            Sys.sleep(0.1);
        }
#end
#end
    }
    
    /**
        Send any object as json.
        @param d - The object to send.
     */
    public function sendJson(d:Dynamic) {
        this.send(Json.stringify(d) );
    }
    
    /**
        Send a raw string as a message.
        @param m - The string to send.
     */
    public function send(m:String) {
        //trace(m);
        if(!ready)
            queue.push(m);
        else
#if cs  
            ws.Send(m);
#else
            ws.sendString(m);
#end
    }


    private function _onClose() {
        ready = false;
        onClose();
    }

    /**
        Event listener for when the socket is closed
     */
    dynamic public function onClose() { }

    /**
        Event listener for when the socket is open and connected
     */
    dynamic public function onReady() { }

    /**
        Event listener for when the socket errors
        @param s - The error.
     */
    dynamic public function onError(s) { }

    /**
        Event listener for when a message is received
        @param m - The message recieved;
     */
    dynamic public function onMessage(m) { }

}