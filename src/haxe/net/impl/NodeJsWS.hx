package haxe.net.impl;

import haxe.extern.EitherType;
import js.node.events.EventEmitter;

//By RAIDANDFADE.
@:enum abstract NodeJsWSEvent<T:haxe.Constraints.Function>(Event<T>) to Event<T>{

    
    var Close   : NodeJsWSEvent<Int->String->Void>                      = "close";

    var Error   : NodeJsWSEvent<js.lib.Error->Void>                         = "error";

    var Headers : NodeJsWSEvent< Dynamic -> js.node.http.IncomingMessage -> Void> 
                                                                        = "headers";
    var Message : NodeJsWSEvent< EitherType< String,
                                    EitherType< js.node.buffer.Buffer,
                                        EitherType< js.lib.ArrayBuffer,
                                            Array< js.node.buffer.Buffer >
                                        >
                                    >
                                >->Void>                                = "message";

    var Open    : NodeJsWSEvent<Void->Void>                             = "open";
    var Ping    : NodeJsWSEvent<js.node.buffer.Buffer->Void>            = "ping"; 
    var Pong    : NodeJsWSEvent<js.node.buffer.Buffer->Void>            = "pong";

    var UnexpectedResponse 
                : NodeJsWSEvent<js.node.http.ClientRequest ->
                                js.node.http.IncomingMessage ->
                                Void>                                   = "unexpected_response";
}

@:jsRequire("ws")
extern class NodeJsWS extends js.node.events.EventEmitter<NodeJsWS> {

    public var binaryType:String;
    public var bufferedAmount:Int;
    public var bytesReceived:Int;
    public var extensions:Dynamic;
    public var protocol:String;
    public var protocolVersion:Int;
    public var readyState:Int;
    public var url:String;

    public function new(url:String, ?protocols:EitherType<String,Array<String>>,?options:WSOptions);
    
    public function close(?code:Int,?reason:String):Void;
    public function pause():Void;
    public function resume():Void;
    public function send(data:Dynamic,?options:SendOptions,?callback:Dynamic->Void):Void;
    public function ping(?data:Dynamic,?mask:Bool,?failSilently:Bool):Void;
    public function pong(?data:Dynamic,?mask:Bool,?failSilently:Bool):Void;
    public function terminate():Void;
}

typedef SendOptions = {
    @:optional var compress:Bool;
    @:optional var binary:Bool;
    @:optional var mask:Bool;
    @:optional var fin:Bool;
}

typedef WSOptions = {
    @:optional var protocol:String;
    @:optional var perMessageDeflate:EitherType<Bool,Dynamic>;
    @:optional var localAddress:String;
    @:optional var protocolVersion:Int;
    @:optional var headers:Dynamic;
    @:optional var origin:String;
    @:optional var agent:EitherType<js.node.http.Agent,js.node.https.Agent>;
    @:optional var host:String;
    @:optional var family:Int;
    @:optional var checkServerItendity:Void->Bool;
}