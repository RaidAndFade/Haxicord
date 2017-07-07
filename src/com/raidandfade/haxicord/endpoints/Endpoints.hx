package com.raidandfade.haxicord.endpoints;

import haxe.Json;
import haxe.impl.Timer;

#if (js&&nodejs)
import js.node.Https;
import js.node.Url;
import js.node.Querystring;
import haxe.DynamicAccess;
import haxe.extern.EitherType;
import js.node.http.IncomingMessage;
#elseif cs
//Refer to line 79 if you're confused.
@:classCode("void httpCallBack(System.IAsyncResult res){
                System.Console.WriteLine(\"Not good?\");
                try{
                System.Tuple<System.Net.HttpWebRequest,global::haxe.lang.Function> r = (System.Tuple<System.Net.HttpWebRequest,global::haxe.lang.Function>)res.AsyncState;
                System.Net.HttpWebResponse response = r.Item1.EndGetResponse(res) as System.Net.HttpWebResponse;
                using (var streamReader = new System.IO.StreamReader(response.GetResponseStream()))
                {
                    global::haxe.ds.StringMap<object> headers = new global::haxe.ds.StringMap<object>();

                    foreach (string n in response.Headers){
                        foreach(string s in response.Headers.GetValues(n)){
                            headers.@set(n.ToLower(),s);
                        }
                    }

                    var result = streamReader.ReadToEnd();
                    r.Item2.__hx_invoke2_o(default(double), result, default(double), headers);
                }
                }catch(System.Exception e){System.Console.WriteLine(e);}
            }\n\n"
            )
#else
import haxe.Http;
#end

class Endpoints{

    var client:DiscordClient;

    public function new(_c:DiscordClient){
        client=_c;
    }

    var rateLimitCache:Map<String,RateLimit> = new Map<String,RateLimit>();
    var limitedQueue:Map<String,Array<EndpointCall>> = new Map<String,Array<EndpointCall>>();

//ACTUAL ENDPOINTS : 
    public function getGateway(bot=false,cb:Typedefs.Gateway->Void=null){
        //GET
        //gateway(?/bot)
        var endpoint = new EndpointPath("/gateway"+(bot?"/bot":""),[]);
        var _cb = function(j){
            trace(j);
            cb(j);
        }
        callEndpoint("GET",endpoint,_cb);
    }

    public function getChannel(channel_id:String){
        //GET
        //channels/{0}
    }


//BACKEND : 
    public function callEndpointSync():Dynamic{
#if js
        //ree
#end
        //Implement a blocking version of callEndpoint for not-js languages? or dont
        return null;
    }

// also how 2 deal with race conditions
// since async web request
// say x-remaining is 1
// and same endpoint is called by bot 2 times
// in my cache i know i have 1 left until x time
// so i guess just let whichever one called first go, and delay the 2nd one until it can :Think:
// yea
// how does your burst thing work then if not like that
// maybe i can hook into the callback
// and have my own
// and in that callback see if there's anything waiting in the queue
// that way i avoid the whole loop concept

    public function callEndpoint(method:String,endpoint:EndpointPath,callback:Null<Dynamic->Void>=null,data:{}=null,authorized:Bool=true){
        trace("Req : "+endpoint.getPath());
        var rateLimitName = method+endpoint.endpoint;
        trace("RLC: "+rateLimitCache.exists(rateLimitName));
        if(rateLimitCache.exists(rateLimitName)){
            trace("RLL: "+rateLimitCache.get(rateLimitName).remaining);
            if(rateLimitCache.get(rateLimitName).remaining <= 0){
                trace("LQ: "+limitedQueue.exists(rateLimitName));
                if(limitedQueue.exists(rateLimitName)){
                    limitedQueue.get(rateLimitName).push(new EndpointCall(method,endpoint,callback,data,authorized));
                }else{
                    limitedQueue.set(rateLimitName,new Array<EndpointCall>());
                    limitedQueue.get(rateLimitName).push(new EndpointCall(method,endpoint,callback,data,authorized));
                }
                return;
            }else{
                rateLimitCache.get(rateLimitName).remaining--;
            }
        }else{
            rateLimitCache.set(rateLimitName,new RateLimit(1,0,-1));
        }
        var _callback = function(data,headers:Map<String,String>){
            trace("?: ",rateLimitName,rateLimitCache.get(rateLimitName));
            if(headers.exists("x-ratelimit-reset")){
                var limit = Std.parseInt(headers.get("x-ratelimit-limit"));
                var remaining = Std.parseInt(headers.get("x-ratelimit-remaining"));
                var reset = Std.parseFloat(headers.get("x-ratelimit-reset"));
                trace("B:",rateLimitName,rateLimitCache.get(rateLimitName));
                rateLimitCache.set(rateLimitName,new RateLimit(limit,remaining,reset));
                if(remaining==0){
                    var delay = Std.int(reset-(Date.now().getTime()/1000))*1000+500;
                    var waitForLimit = function(rateLimitName,rateLimit){
#if (cpp||cs)
                        //var delay = Std.parseInt(cpp.vm.Thread.readMessage(true)); -- Read  note line 139                        

                        trace("Must wait for "+delay+"ms.");
                        Sys.sleep(delay/1000);
#end
                        trace("Ratelimit reset reached.");
                        rateLimitCache.set(rateLimitName,new RateLimit(limit,limit,-1));
                        if(limitedQueue.exists(rateLimitName)){
                            var arrCopy = limitedQueue.get(rateLimitName).map(function(l){return l;});
                            limitedQueue.set(rateLimitName,new Array<EndpointCall>());
                            for(calli in 0...arrCopy.length){
                                var call = arrCopy[calli];
                                callEndpoint(call.method,call.endpoint,call.callback,call.data,call.authorized);
                            }
                        }
                    }

                    trace("Must wait for "+delay+"ms.");
                    var f = waitForLimit.bind(rateLimitName,rateLimitCache.get(rateLimitName));
                    Timer.delay(f,delay);
                }
                if(remaining!=0){
                    trace("LQ: "+limitedQueue.exists(rateLimitName));
                    if(limitedQueue.exists(rateLimitName)){
                        trace("LL: "+limitedQueue.get(rateLimitName).length);
                        if(limitedQueue.get(rateLimitName).length>0){
                            var arrCopy = limitedQueue.get(rateLimitName).map(function(l){return l;});
                            limitedQueue.set(rateLimitName,new Array<EndpointCall>());
                            for(calli in 0...arrCopy.length){
                                var call = arrCopy[calli];
                                callEndpoint(call.method,call.endpoint,call.callback,call.data,call.authorized);
                            }
                        }
                    }
                }
            }else{
                trace("No ratelimits on this endpoint.");
                trace("LQ: "+limitedQueue.exists(rateLimitName));
                rateLimitCache.set(rateLimitName,new RateLimit(50,50,-1));
                if(limitedQueue.exists(rateLimitName)){
                    trace("LL: "+limitedQueue.get(rateLimitName).length);
                    if(limitedQueue.get(rateLimitName).length>0){
                        var arrCopy = limitedQueue.get(rateLimitName).map(function(l){return l;});
                        limitedQueue.set(rateLimitName,new Array<EndpointCall>());
                        for(calli in 0...arrCopy.length){ 
                            var call = arrCopy[calli];
                            callEndpoint(call.method,call.endpoint,call.callback,call.data,call.authorized);
                        }
                    }
                }
            }
            callback(data);
        }
        var path = endpoint.getPath();
        rawCallEndpoint(method,path,_callback,data,authorized);
        return;
    }


    //TODO doc
    public function rawCallEndpoint(method:String,endpoint:String,callback:Null<Dynamic->Map<String,String>->Void>=null,data:{}=null,authorized:Bool=true){
        if(callback == null){
            callback = function(f,a){}
        }
        method=method.toUpperCase();
        if(["GET","HEAD","POST","PUT","PATCH","DELETE","OPTIONS"].indexOf(method)==-1)throw "Invalid Method Request";

        var url = "https://discordapp.com/api"+endpoint;
#if (js && nodejs)
        var headers = new DynamicAccess<EitherType<String,Array<String>>>();

        if(authorized)headers.set("Authorization",client.token);
        headers.set("User-Agent",DiscordClient.userAgent);
        headers.set("Content-Type","application/x-www-form-urlencoded");

        var path = Url.parse(url).pathname;

        var options = {
            "hostname": Url.parse(url).host,
            "path": path,
            "method": method,
            "headers": headers
        };

        var req = Https.request(options,function(res:IncomingMessage){
            //trace(res.headers);
            res.on('data', function (all) {
                var m:Map<String,String> = new Map<String,String>();
                for(k in res.headers.keys()){
                    var v = res.headers[k];
                    m.set(k.toLowerCase(),v);
                }
                callback(Json.parse(all),m);
            });
        });
        if(["POST","PUT","PATCH"].indexOf(method)>-1&&data!=null)req.write(Querystring.stringify(data));
        req.end();
#elseif cs
        trace("Sending req to "+url);
        untyped __cs__('
                try{
                var httpWebRequest = (System.Net.HttpWebRequest)System.Net.WebRequest.Create({0});
                httpWebRequest.ContentType = "application/json";
                httpWebRequest.Method = {1};
                httpWebRequest.Headers.Add("Authorization",{2});
                httpWebRequest.UserAgent = {3};
                '
            ,url,method,client.token,DiscordClient.userAgent);
        if(["POST","PUT","PATCH"].indexOf(method)>-1&&data!=null){
        untyped __cs__('
                using (var streamWriter = new System.IO.StreamWriter(httpWebRequest.GetRequestStream()))
                {
                    streamWriter.Write({0});
                    streamWriter.Flush();
                    streamWriter.Close();
                }'
            ,Json.stringify(data));
        }
        untyped __cs__('
                System.Console.WriteLine("Sending Req!");
                httpWebRequest.BeginGetResponse(new System.AsyncCallback(httpCallBack),System.Tuple.Create(httpWebRequest,{0}));
                }catch(System.Net.WebException e){System.Console.WriteLine(e);}
            '
        ,callback);
#elseif js
        throw "Browser JS is not supported as it's not possible to send modified User-Agents.";
#else
        var call = new Http(url);
        var result = new haxe.io.BytesOutput();

        call.setHeader("Authorization",client.token);
        call.setHeader("User-Agent",DiscordClient.userAgent);
        call.onError = function(no){
            throw no;
        }
        call.onData = function(data){
            var m = new Map<String,String>();
            for(k in call.responseHeaders.keys()){
                var v = call.responseHeaders[k];
                m.set(k.toLowerCase(),v);
            }
            callback(Json.parse(data),m);
        }
        call.customRequest(false,result,method);
#end
    }
}

// Love you b1nzy
class RateLimit { 
    public var limit:Int;
    public var remaining:Int;
    public var reset:Float;
    public function new(_l,_rm,_rs){
        limit = _l;
        remaining = _rm;
        reset = _rs;
    }

    public function toString(){
        return "RateLimit("+remaining+"/"+limit+" until "+reset+")";
    }
}

class EndpointCall {
    public var method:String;
    public var endpoint:EndpointPath;
    public var callback:Null<Dynamic->Void>;
    public var data:{};
    public var authorized:Bool;
    public function new(_m,_e,_c=null,_d=null,_a=true){
        method = _m; endpoint = _e; callback = _c; data = _d; authorized = _a;
    }
}

class EndpointPath { 
    public var endpoint:String;
    public var data:Array<String>;
    public function new(_e,_d:Array<String>){
        endpoint=_e;
        data=_d;
    }

    public function getPath(){
        var cur = endpoint;
        for(i in 0...data.length){
            var d = data[i];
            cur = StringTools.replace(cur,"{"+i+"}",d);
        }
        return cur;
    }
}