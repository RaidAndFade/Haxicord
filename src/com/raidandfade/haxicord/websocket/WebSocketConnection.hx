package com.raidandfade.haxicord.websocket;

import haxe.Json;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.io.BytesInput;
import haxe.io.BufferInput;
import haxe.Utf8;
import haxe.zip.Uncompress;

#if !cs
import haxe.net.WebSocket;
#else
import websocketsharp.WebSocket;
#end

class WebSocketConnection { 
    private static var ZLIB_SUFFIX = "0000ffff";
    private static var BUFFER_SIZE = 1024*1024; //1kb

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
#if sys
#if cs
        var th = new cs.system.threading.Thread(new cs.system.threading.ThreadStart(create));
        th.Start();
#else
        haxe.MainLoop.addThread(create);
#end
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
                haxe.EntryPoint.runInMainThread(onReady);
            })
        );
        ws.add_OnMessage(
            new cs.system.EventHandler_1<websocketsharp.MessageEventArgs> ( function(f:Dynamic, m:websocketsharp.MessageEventArgs) {
                haxe.EntryPoint.runInMainThread(this.onMessage.bind(m.Data));
            })
        );
        ws.add_OnError(
            new cs.system.EventHandler_1<websocketsharp.MessageEventArgs> ( function(f:Dynamic, m:websocketsharp.ErrorEventArgs) {
                haxe.EntryPoint.runInMainThread(this.onError.bind(m.Message));
            })
        );
        ws.add_OnClose( 
            new cs.system.EventHandler_1<websocketsharp.MessageEventArgs> ( function(f:Dynamic, m:websocketsharp.ErrorEventArgs) {
                haxe.EntryPoint.runInMainThread(this._onClose);
            })
        );
        ws.Connect();
#else 
        trace("starting");
        ws = WebSocket.create(host, [], null, false);
        ws.onopen = function() {
            ready = true;
            haxe.EntryPoint.runInMainThread(function(){
                for(m in queue) {
                    send(m);
                }
            });
            haxe.EntryPoint.runInMainThread(onReady);
        }
        ws.onmessageString = function(m) { 
            haxe.EntryPoint.runInMainThread(this.onMessage.bind(m));
        }

        var buf = new BytesBuffer();
        
#if js
        var z = js.node.Zlib.createInflate();
#else
        var z = new Uncompress();
        z.setFlushMode(haxe.zip.FlushMode.SYNC);
#end
        ws.onmessageBytes = function(bytes) {
            // buf.addBytes(m,0,m.length);
            try{
                // var bytes = buf.getBytes();
                if( bytes.toHex().length < 8 || bytes.toHex().substr(-8) != ZLIB_SUFFIX ){
                    var buf = new BytesBuffer();
                    buf.addBytes(bytes,0,bytes.length);
                    return;
                }

                #if (js&&nodejs)
                var data = untyped bytes.b;
                var buf = js.node.buffer.Buffer.from(data.buffer,data.byteOffset,bytes.length);
                var opts = untyped {flush: js.node.Zlib.Z_SYNC_FLUSH, finishFlush: js.node.Zlib.Z_SYNC_FLUSH};
                z.write(buf,function(){
                    var x = z.read();
                    haxe.EntryPoint.runInMainThread(this.onMessage.bind(x));
                });
                #else
                var res = new BytesBuffer();
                
                var chnk = {done:false,write:0,read:0};
                var p = 0;
                var len = bytes.length;
                while(p<len){
                    var chbuf = Bytes.alloc(BUFFER_SIZE);
                    chnk = z.execute(bytes,p,chbuf,0);
                    p += chnk.read;
                    res.addBytes(chbuf,0,chnk.write);
                }

                var msg = res.getBytes().toString();
                haxe.EntryPoint.runInMainThread(this.onMessage.bind(msg));
                #end
            }catch(e:Dynamic){
                trace(Std.string(e)+haxe.CallStack.toString(haxe.CallStack.exceptionStack()));

            }
        }
        
        ws.onerror = onError;
        ws.onclose = _onClose;
#if sys
        while (true) {
            ws.process();
            Sys.sleep(0.1);
        }
        trace("Escaped while, somehow.");
#end
#end
    }

    public function close(){
#if cs
    ws.close();
#else
    ws.close();
#end
    }
    
    /**
        Send any object as json.
        @param d - The object to send.
     */
    public function sendJson(d:Dynamic) {
        this.send(Json.stringify(d));
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


    private function _onClose(m) {
        ready = false;
        trace("died");
        onClose(m);
    }

    /**
        Event listener for when the socket is closed
     */
    dynamic public function onClose(m) { }

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