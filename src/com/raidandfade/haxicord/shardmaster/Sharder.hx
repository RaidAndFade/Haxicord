package com.raidandfade.haxicord.shardmaster;

import com.raidandfade.haxicord.logger.Logger;

import com.raidandfade.haxicord.endpoints.Endpoints;

import com.raidandfade.haxicord.DiscordClient;

import com.raidandfade.haxicord.cachehandler.DataCache;
import com.raidandfade.haxicord.cachehandler.MemoryCache;

import haxe.Https;
import haxe.Timer;

class Sharder{

    public var clients:Array<DiscordClient> = new Array();

    private var gatewaySuggestions:WSGateway;

    private var token:String;

    private var shards:Int;

    private var cache:DataCache;

    function getGateway(cb){
        var url = Endpoints.BASEURL + "v" + DiscordClient.gatewayVersion + "/gateway/bot";

        var headers:Map<String, String> = new Map<String, String>();
        headers.set("Authorization", "Bot " + token);
        headers.set("User-Agent", DiscordClient.userAgent);
        headers.set("Content-Type", "application/json");

        try{
            Https.makeRequest(url, "GET", cb, {}, headers, false);
        }catch(e:Dynamic) {
            trace(e);
            trace(haxe.CallStack.toString(haxe.CallStack.exceptionStack() ) );
        }
    }

    function handleGatewaySuggestions(data,headers) {
        if(data.status!=200) throw "Something went wrong, got " + data.status + " when checking gateway. Are you sure this is a bot token?";

        gatewaySuggestions = data.data;
        trace("Gateway suggests we use " + gatewaySuggestions.shards + " shard(s)");
        this.onReady();
    }

    public function shardAutomatic() {
        shards = gatewaySuggestions.shards;
        setupShards();
    }

    public function shardManual(_shards:Int) {
        if(_shards<gatewaySuggestions.shards){
            throw "You shouldn't run that many shards, Discord wouldn't like that. You need at least " + gatewaySuggestions.shards + " shards";
        }else{
            shards = _shards;
            setupShards();
        }
    }

    public function setupShards(){
        trace("Sharding with " + shards +" shards");
        for(i in 0...shards){
            Timer.delay(initShard.bind(i),i*6000);
        }
    }


    public function initShard(shardId:Int){
        trace("Creating shard "+(shardId+1)+" of "+ shards);
        clients[shardId] =  new DiscordClient(token,[shardId,shards],false,false,cache);
        if(shardId == (shards-1)){
            onStartup();
        }
    }

    public function new(_token:String) {
        Logger.registerLogger();
        token=_token;
        cache = new MemoryCache(); //other types of cache maybe, like redis or something.
    }

    public dynamic function onReady(){}
    public dynamic function onStartup(){}

    public function start(blocking=true){
        getGateway(handleGatewaySuggestions);
#if sys
        while(blocking){
            Sys.sleep(1);
        }
#end
    }
}

typedef WSGateway = { 
    var url:String;
    var shards:Int;
}