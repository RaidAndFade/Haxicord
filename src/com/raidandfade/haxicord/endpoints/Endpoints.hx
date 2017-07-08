package com.raidandfade.haxicord.endpoints;

import haxe.Json;
import haxe.Timer;

import com.raidandfade.haxicord.types.Message;
import com.raidandfade.haxicord.types.structs.GuildChannel.Overwrite;
import com.raidandfade.haxicord.types.Channel;
import com.raidandfade.haxicord.types.Invite;

import haxe.extern.EitherType;
#if (js&&nodejs)
import js.node.Https;
import js.node.Url;
import js.node.Querystring;
import haxe.DynamicAccess;
import js.node.http.IncomingMessage;
#elseif cs
//Refer to line 79 if you're confused.
@:classCode("void httpCallBack(System.IAsyncResult res){
                System.Tuple<System.Net.HttpWebRequest,global::haxe.lang.Function> r = (System.Tuple<System.Net.HttpWebRequest,global::haxe.lang.Function>)res.AsyncState; 
                try{
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
                    var status = response.StatusCode;
                    r.Item2.__hx_invoke3_o(default(double), status, default(double), result, default(double), headers);
                }
                }catch(System.Net.WebException e){
                    if(e.Status == System.Net.WebExceptionStatus.ProtocolError){
                        global::haxe.ds.StringMap<object> headers = new global::haxe.ds.StringMap<object>();
                        foreach (string n in e.Response.Headers){
                            foreach(string s in e.Response.Headers.GetValues(n)){
                                headers.@set(n.ToLower(),s);
                            }
                        }
                        r.Item2.__hx_invoke3_o(default(double), ((int)((System.Net.HttpWebResponse)e.Response).StatusCode), default(double), \"{\\\"status\\\":\\\"\"+((int)((System.Net.HttpWebResponse)e.Response).StatusCode)+\"\\\",\\\"error\\\":\\\"\"+((System.Net.HttpWebResponse)e.Response).StatusDescription+\"\\\"}\", default(double), headers);
                    }else{
                        System.Console.WriteLine(\"Something quite bad happened\");
                        System.Console.WriteLine(e);
                    }
                }
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

//GATEWAY START
    public function getGateway(bot=false,cb:Typedefs.Gateway->String->Void=null){
        var endpoint = new EndpointPath("/gateway"+(bot?"/bot":""),[]);
        callEndpoint("GET",endpoint,cb);
    }

//CHANNEL START
    //TODO change to Channel->String->Void
    public function getChannel(channel_id:String,cb:Channel->String->Void){
        var endpoint = new EndpointPath("/channels/{0}",[channel_id]);
        callEndpoint("GET",endpoint,cb);
    }

    //TODO change to Channel->String->Void
    public function modifyChannel(channel_id:String,channel_data:Typedefs.ChannelUpdate,cb:Channel->String->Void){
         //Requires manage_channels
        var endpoint = new EndpointPath("/channels/{0}",[channel_id]);
        callEndpoint("PATCH",endpoint,cb,channel_data);
    }

    //TODO change to Channel->String->Void
    public function deleteChannel(channel_id:String,cb:Channel->String->Void){
         //Requires manage_channels
        var endpoint = new EndpointPath("/channels/{0}",[channel_id]);
        callEndpoint("DELETE",endpoint,cb);
    }

    public function editChannelPermissions(channel_id:String,overwrite_id:String,new_permission:Overwrite,cb:EmptyResponseCallback){
        //Requires manage_roles
        var endpoint = new EndpointPath("/channels/{0}/permissions/{1}",[channel_id,overwrite_id]);
        callEndpoint("PUT",endpoint,cb,new_permission); //204
    }

    public function deleteChannelPermission(channel_id:String,overwrite_id:String,cb:EmptyResponseCallback){
        //Requires manage_roles
        var endpoint = new EndpointPath("/channels/{0}/permissions/{1}",[channel_id,overwrite_id]);
        callEndpoint("DELETE",endpoint,cb); //204
    }

    //TODO change to Array<Invite>->String->Void
    public function getChannelInvites(channel_id:String,cb:Array<Invite>->String->Void){
        //Requires manage_channels
        var endpoint = new EndpointPath("/channels/{0}/invites",[channel_id]);
        callEndpoint("GET",endpoint,cb);
    }

    //TODO change to Invite->String->Void
    public function createChannelInvite(channel_id:String,invite:Typedefs.InviteCreate,cb:Invite->String->Void){
        //requires create_instant_invite
        var endpoint = new EndpointPath("/channels/{0}/invites",[channel_id]);
        callEndpoint("POST",endpoint,cb,invite);
    }

//MESSAGE START
    //TODO change to Array<Messages>->String->Void
    public function getChannelPins(channel_id:String,cb:Array<Message>->String->Void){
        //Requires read_messages
        var endpoint = new EndpointPath("/channels/{0}/pins",[channel_id]);
        callEndpoint("GET",endpoint,cb);
    }

    //TODO change to Array<Messages>->String->Void
    public function getMessages(channel_id:String,format:Typedefs.MessagesRequest,cb:Array<Message>->String->Void){
        //Requires read_messages
        var endpoint = new EndpointPath("/channels/{0}/messages{1}",[channel_id,queryString(format)]);
        callEndpoint("GET",endpoint,function(r:Array<com.raidandfade.haxicord.types.Message>,e){
            if(e!=null)cb(null,e);
            else cb([for(m in r){new Message(m,client);}],null);
        });
    }

    //TODO change to Message->String->Void
    public function getMessage(channel_id:String,message_id:String,cb:Message->String->Void){
        //Requires read_message_history
        var endpoint = new EndpointPath("/channels/{0}/messages/{1}",[channel_id,message_id]);
        callEndpoint("GET",endpoint,cb);
    }

    //TODO change to Message->String->Void
    public function sendMessage(channel_id:String,message:Typedefs.MessageCreate,cb:Message->String->Void){
        //Requires send_messages
        var endpoint = new EndpointPath("/channels/{0}/messages",[channel_id]);
        callEndpoint("POST",endpoint,cb,message);        
    }

    public function startTyping(channel_id:String,cb:EmptyResponseCallback){
        //Requires send_messages
        var endpoint = new EndpointPath("/channels/{0}/typing",[channel_id]);
        callEndpoint("POST",endpoint,cb,{});        //204
    }

    //TODO change to Message->String->Void
    public function editMessage(channel_id:String,message:Typedefs.MessageEdit,cb:Message->String->Void){
        var endpoint = new EndpointPath("/channels/{0}/messages",[channel_id]);
        callEndpoint("PATCH",endpoint,cb,message);
    }

    public function deleteMessage(channel_id:String,message_id:String,cb:EmptyResponseCallback){
        //If !currentUser==author, requires Manage Messages
        var endpoint = new EndpointPath("/channels/{0}/messages/{1}",[channel_id,message_id]);
        callEndpoint("DELETE",endpoint,cb); //204
    }

    public function deleteMessages(channel_id:String,message_ids:Typedefs.MessageBulkDelete,cb:EmptyResponseCallback){
        //Requires manage_messages
        var endpoint = new EndpointPath("/channels/{0}/messages/bulk-delete",[channel_id]);
        callEndpoint("POST",endpoint,cb,message_ids); //204
    }

//REACTION START
    public function createReaction(channel_id:String,message_id:String,emoji:String,cb:EmptyResponseCallback){
        //Requires read_message_history, and add_reactions if emoji not already on message
        var endpoint = new EndpointPath("/channels/{0}/messages/{1}/reactions/{2}/@me",[channel_id,message_id,emoji]);
        callEndpoint("PUT",endpoint,cb); //204
    }

    public function deleteOwnReaction(channel_id:String,message_id:String,emoji:String,cb:EmptyResponseCallback){
        var endpoint = new EndpointPath("/channels/{0}/messages/{1}/reactions/{2}/@me",[channel_id,message_id,emoji]);
        callEndpoint("DELETE",endpoint,cb); //204
    }

    public function deleteUserReaction(channel_id:String,message_id:String,user_id:String,emoji:String,cb:EmptyResponseCallback){
        //Requires MANAGE_MESSAGES
        var endpoint = new EndpointPath("/channels/{0}/messages/{1}/reactions/{2}/{3}",[channel_id,message_id,emoji,user_id]);
        callEndpoint("DELETE",endpoint,cb); //204
    }

    public function getReactions(channel_id:String,message_id:String,emoji:String,cb:Array<Reaction>->String->Void){
        var endpoint = new EndpointPath("/channels/{0}/messages/{1}/reactions/{2}",[channel_id,message_id,emoji]);
        callEndpoint("GET",endpoint,cb);
    }

    public function deleteAllReactions(channel_id:String,message_id:String,cb:EmptyResponseCallback){
        //Requires MANAGE_MESSAGES
        var endpoint = new EndpointPath("/channels/{0}/messages/{1}/reactions",[channel_id,message_id]);
        callEndpoint("DELETE",endpoint,cb); //204
    }

//BACKEND
    //later on if it matters see if there's a better way to do this
    public static function queryString(datar:{}):String{
        if(Std.is(datar,new Map<String,Dynamic>())){
            var data:Map<String,Dynamic> = cast(datar,Map<String,Dynamic>);
            var s = "?";
            var c = 0;
            for(k in data.keys()){
                var v = data.get(k);
                if(c++!=0)s+="&";
                s+=k+"="+Std.string(v);
            }
            return s;
        }
        return "";
    }

    public function callEndpoint(method:String,endpoint:EndpointPath,callback:Null<Dynamic->String->Void>=null,data:{}=null,authorized:Bool=true){
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
                rateLimitCache.set(rateLimitName,new RateLimit(limit,remaining,reset));
                if(remaining==0){
                    var delay = Std.int(reset-(Date.now().getTime()/1000))*1000+500;
                    var waitForLimit = function(rateLimitName,rateLimit){
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
                    if(limitedQueue.exists(rateLimitName)){
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
                rateLimitCache.set(rateLimitName,new RateLimit(50,50,-1));
                if(limitedQueue.exists(rateLimitName)){
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
            //TODO if data is not an error luleh
            if(data.status < 200 || data.status>=300){
                callback(null,data.error);
            }else{
                callback(data.data,null);
            }
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
        var token = "Bot " + client.token;
#if (js && nodejs)
        var headers = new DynamicAccess<EitherType<String,Array<String>>>();

        if(authorized)headers.set("Authorization",token);
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
                callback({status:res.statusCode,data:Json.parse(all)},m);
            });
        });
        req.on('error',function(e){
            trace(e);
        });
        if(["POST","PUT","PATCH"].indexOf(method)>-1&&data!=null)req.write(Querystring.stringify(data));
        req.end();
#elseif cs
        var cscb = function(status,response,headers){
            var data = Json.parse(response);
            callback({status:status,data:data},headers);
        }
        untyped __cs__('
                try{
                var httpWebRequest = (System.Net.HttpWebRequest)System.Net.WebRequest.Create({0});
                httpWebRequest.ContentType = "application/json";
                httpWebRequest.Method = {1};
                httpWebRequest.Headers.Add("Authorization",{2});
                httpWebRequest.UserAgent = {3};
                '
            ,url,method,token,DiscordClient.userAgent);
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
                httpWebRequest.BeginGetResponse(new System.AsyncCallback(httpCallBack),System.Tuple.Create(httpWebRequest,{0}));
                }catch(System.Net.WebException e){
                    System.Console.WriteLine("Something quite bad happened");
                    System.Console.WriteLine(e);
                }
            '
        ,cscb);
#elseif js
        throw "Browser JS is not supported as it's not possible to send modified User-Agents.";
#else
        var call = new Http(url);
        var result = new haxe.io.BytesOutput();

        call.setHeader("Authorization",token);
        call.setHeader("User-Agent",DiscordClient.userAgent);
        var status:Int = -1;
        call.onStatus = function(st){
            status = st;
        }
        call.onError = function(no){
            var m = new Map<String,String>();
            for(k in call.responseHeaders.keys()){
                var v = call.responseHeaders[k];
                m.set(k.toLowerCase(),v);
            }
            var errReg = ~/Http Error #([0-9]{0,5})/;
            if(errReg.match(no)){
                callback({"status":status,"error":"HTTP error"},m);
            }else{
                callback({"status":"-1","error":no},m);
            }
        }
        if(["POST","PUT","PATCH"].indexOf(method)>-1&&data!=null){
            call.setPostData(Json.stringify(data));
        }
        call.onData = function(data){
            var m = new Map<String,String>();
            for(k in call.responseHeaders.keys()){
                var v = call.responseHeaders[k];
                m.set(k.toLowerCase(),v);
            }
            var data = Json.parse(data);
            callback({status:status,data:data},m);
        }
        //TODO data
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
    public var callback:Null<Dynamic->String->Void>;
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

typedef EmptyResponseCallback = Dynamic->String->Void;