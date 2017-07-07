package com.raidandfade.haxicord.websocket;

#if !cs
import haxe.net.WebSocket;
#else
import websocketsharp.WebSocket;
#end

class WebSocketConnection { 

    public static var ws:WebSocket;
    var queue:Array<String> = new Array<String>();
    var ready=false;
    public static var host:String;

    public function new(_host){ 
        host = _host;

        //Thread this.
        var th:Dynamic;
#if cpp
        th = cpp.vm.Thread.create(create);
#elseif java
        th = java.vm.Thread.create(create);
#elseif neko
        th = neko.vm.Thread.create(create);
#elseif cs
        th = new cs.system.threading.Thread(new cs.system.threading.ThreadStart(create));
        th.Start();
#else
        create();
#end
    }

    function create(){
        trace("Opening Connection to "+host);
#if cs
        ws = new WebSocket(host,new cs.NativeArray<String>(0));
        ws.add_OnOpen(new cs.system.EventHandler(function(f:Dynamic,e:cs.system.EventArgs){
            trace("Connection done");
            ready=true;
            for(m in queue){
                send(m);
            }
            onReady();
        }));
        ws.add_OnMessage(new cs.system.EventHandler_1<websocketsharp.MessageEventArgs>(function(f:Dynamic,m:websocketsharp.MessageEventArgs){
            trace(m);this.onMessage(m.Data);
        }));
        ws.Connect();
#else 
        ws = WebSocket.create(host, [], null, true);
        ws.onopen = function(){
            trace("Connection done");
            ready=true;
            for(m in queue){
                send(m);
            }
            onReady();
        }
        ws.onmessageString = function(m){trace(m);this.onMessage(m);}
        ws.onmessageBytes = function(m){trace(m);}
        ws.onerror = function(e){trace(e);};
#if sys
        trace("Thread started?");
        while (true==true) {
            try{        
                ws.process();
                Sys.sleep(0.1);
            }catch(e:Dynamic){
                trace(e);
            }
        }
        trace("No fuck can fuck enough fucks.");
#end
#end
    }
    
    public function send(m:String){
        trace("Sending "+m);
        if(!ready)
            queue.push(m);
        else
#if cs  
            ws.Send(m);
#else
            ws.sendString(m);
#end
    }

    dynamic public function onReady(){
    }

    dynamic public function onError(){

    }

    dynamic public function onMessage(m){
        trace("Receiving "+m);
    }

}