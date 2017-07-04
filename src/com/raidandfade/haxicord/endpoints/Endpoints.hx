package com.raidandfade.haxicord.endpoints;

import haxe.Http;
import haxe.Json;

#if cs
#end

#if (js&&nodejs)
import js.node.Https;
import js.node.Url;
import js.node.Querystring;
import haxe.DynamicAccess;
import haxe.extern.EitherType;
import js.node.http.IncomingMessage;
#end
class Endpoints{

    var client:DiscordClient;

    public function new(_c:DiscordClient){
        client=_c;
    }

    public function callEndpoint(method:String,endpoint:String,callback:Null<Dynamic->Void>=null,data:{}=null,authorized:Bool=true){
        if(callback == null){
            callback = function(f){}
            callback("a");
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

        var res = Https.request(options,function(res:IncomingMessage){
            res.on('data', function (all) {
                callback(Json.parse(all));
            });
        });
        if(["POST","PUT","PATCH"].indexOf(method)>-1&&data!=null)res.write(Querystring.stringify(data));
        res.end();
#elseif cs
        untyped __cs__('
                var httpWebRequest = (System.Net.HttpWebRequest)System.Net.WebRequest.Create({0});
                httpWebRequest.ContentType = "application/json";
                httpWebRequest.Method = {1};
                httpWebRequest.Headers.Add("Authentication",{2});
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
                var httpResponse = (System.Net.HttpWebResponse)httpWebRequest.GetResponse();
                using (var streamReader = new System.IO.StreamReader(httpResponse.GetResponseStream()))
                {
                    var result = streamReader.ReadToEnd();
                    {0}.__hx_invoke1_o(default(double), result);
                }
            '
        ,callback);
#elseif js
        throw "JS IS NOT SUPPORTED AT THE MOMENT.";
#else
        var call = new Http("https://api.gocode.it/requestInfo");
        var result = new haxe.io.BytesOutput();

        call.setHeader("Authorization",client.token);
        call.setHeader("User-Agent",DiscordClient.userAgent);
        call.onError = function(no){
            trace(no);
        }
        call.onData = function(data){
            trace(data);
            callback(Json.parse(data));
        }
        call.onStatus = function(status) 
        {};
        //call.request(true);
        //call.customRequest(false,result,method);
#end


//maybe one day 
/*
if (js && !nodejs)
        var call = new Http("https://api.gocode.it/makeRequest"); // ¯\_(ツ)_/¯
        call.addHeader("X-Client","Haxicord");
        var headers = new Map<String,String>();
        if(authorized)headers.set("Authorization",client.token);
        headers.set("User-Agent",DiscordClient.userAgent);
        call.addParameter("headers",Json.stringify(headers));
        call.addParameter("method",method);
        call.addParameter("url",url);
        call.onData = function(data){
            callback(Json.parse(data));
        }
        call.request(true);
#else
*/
        //Save this just in case something fucks up. its practically useless though.
// #if !js
//         //TODO
// #else
//         untyped __js__('var xmlHttp = new XMLHttpRequest();');
//         untyped __js__('xmlHttp.open({0},{1});',method,url);
//         untyped __js__('xmlHttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");');
//         untyped __js__('xmlHttp.setRequestHeader("User-Agent", {0});',DiscordClient.userAgent);
//         untyped __js__('if({1}) xmlHttp.setRequestHeader("Authorization", {0});',client.token,authorized);
//         untyped __js__('xmlHttp.onreadystatechange = function(){
//             if (this.readyState == 4 && this.status == 200) {
//                 {0}(JSON.parse(xmlHttp.responseText));
//             }
//         }',callback);
//         untyped __js__('xmlHttp.send();');
// #end
    }
}