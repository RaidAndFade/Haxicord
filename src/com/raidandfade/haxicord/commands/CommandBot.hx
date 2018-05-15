package com.raidandfade.haxicord.commands;

import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.types.MessageChannel;
import haxe.rtti.Meta;
import Reflect;
import Type;

class CommandBot {
    private var client:DiscordClient;
    private var commands:Map<String, Command> = new Map();
    private var prefixes:Array<String> = [];

    /**
       Create the bot or something
       @param token - 
       @param commandBot - 
       @param _prefix = "!" - 
       @param tagPrefix = true - 
       @param etf = false - 
       @param zlib = true - 
       @param block = true - 
       @param shardInfo = null - 
     */
    private function new(token:String, commandBot:Class<CommandBot>, _prefix = "!", tagPrefix=true, etf=false, zlib=true, block=true, shardInfo=null) {
        try{
        client = new DiscordClient(token,shardInfo,etf,zlib);
        if(_prefix!=null&&_prefix!=""){
            prefixes.push(_prefix);
        }
        client.onMessage = onMessage;
        client._onReady = function(){
            if(tagPrefix){
                prefixes.push(client.user.tag+" ");
                prefixes.push("<@!"+client.user.id.id+"> "); //nickname
                prefixes.push(client.user.tag); //for the crazies who dont put spaces
                prefixes.push("<@!"+client.user.id.id+">"); //for the crazies who have nicknames and dont put spaces
            }
            trace("My invite link is: " + client.getInviteLink());
            client.onReady();
        }

        var annr = Meta.getFields(commandBot);
        for(comName in Reflect.fields(annr)) {
            var com = Reflect.field(annr, comName);
            var params:CommandParams = null;
            for(annName in Reflect.fields(com)) {
                if(annName == "Command") {
                    try {
                        var p = Reflect.field(com, annName);
                        if(p == null)
                            params = new CommandParams();
                        else
                            params = p[0]; //i wish i knew why [0].
                    } catch(e:Dynamic) {
                        throw "Command " + com + "'s annotation is not correctly formatted.";
                    }
                }
            }
            if(params != null) {
                var func = Reflect.field(this, comName);
                trace("Registered " + comName + " Command");
                registerCommand(comName, params, func);
            }
        }
        if(block)client.start();
        }catch(e:Dynamic){trace(e);}
    }

    private function onMessage(m:Message) {
        var cnt = m.content;

        for(pre in prefixes){
            if(cnt.substr(0, pre.length) == pre) {
                cnt = cnt.substr(pre.length);
                var cmd = cnt.split(" ")[0];
                if(commands.exists(cmd)) {
                    callCommand(cmd, m);
                }
                return;
            }
        }
    }

    private function registerCommand(commandName:String, commandParams:CommandParams, commandFunc:Dynamic->Void) {
        commands.set(commandName, {func:commandFunc, params:commandParams});
    }

    private function callCommand(commandName:String, message:Message) {
        var args:Array<Dynamic> = [];
        var com = commands.get(commandName);
        if(com.params.context == true)
            args.push({client:client, channel:message.getChannel()});
        args.push(message);
        Reflect.callMethod(this, com.func, args);
    }
}

typedef Command = {
    var func:Dynamic->Void;
    var params:CommandParams;
}

class CommandParams {
    public var context:Bool = false;
    public var permissions:Int = 0;

    public function new() {}
}

typedef CommandContext = {
    var client:DiscordClient;
    var channel:MessageChannel;
}