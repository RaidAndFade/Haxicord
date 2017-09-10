package haxe;

#if (js&&nodejs)
import haxe.extern.EitherType;
import js.node.Url;
import js.node.Querystring;
import haxe.DynamicAccess;
import js.node.http.IncomingMessage;
#elseif cs
//Refer to line 1346 if you're confused.
@:classCode("static void httpCallBack(System.IAsyncResult res){
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
                        System.Console.WriteLine(\"ERROR IN HTTPCALLBACK\");
                        System.Console.WriteLine(e);
                    }
                }
            }\n\n"
            )
#else
import haxe.Http;
#end

class Https{
    //this exists because i screwed up. 
    public static function stringify(d:Dynamic):String{
        return Json.stringify(d);
    }

    public static function makeRequest(url,method="GET",_callback:Null<Dynamic->Map<String,String>->Void>=null,_data:{}=null,_headers:Map<String,String>=null){

        var _cb:Null<Dynamic->Map<String,String>->Void> = function(d,e){ //because otherwise the http handler throws the error and shit hits the fan.
            try{
                _callback(d,e);
            }catch(er:Dynamic){
                trace("UNCAUGHT ERROR IN haxe.Https.makeRequest CALLBACK.");
                trace(Std.string(er)+haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
            }
        }

        if(_headers == null){
            _headers = new Map<String,String>();
        }
        method = method.toUpperCase();

        if(["POST","PUT","PATCH"].indexOf(method)>-1&&_data==null)
            _headers.set("Content-Length","0");

#if (js && nodejs)
        var headers = new DynamicAccess<EitherType<String,Array<String>>>();

        for(h in _headers.keys()){
            headers.set(h,_headers.get(h));
        }

        var path = Url.parse(url).pathname;


        var options = {
            "hostname": Url.parse(url).host,
            "path": path,
            "method": method,
            "headers": headers
        };

        var req = js.node.Https.request(options,function(res:IncomingMessage){
            //trace(res.headers);
            var datas = "";
            res.on('data', function (all) {
                datas += all;
                //trace(datas);
            });
            res.on('end', function(){
                var m:Map<String,String> = new Map<String,String>();
                for(k in res.headers.keys()){
                    var v = res.headers[k];
                    m.set(k.toLowerCase(),v);
                }
                var r = res.statusCode==204?null:Json.parse(datas);
                if(res.statusCode<200||res.statusCode>=300)
                    _cb({status:res.statusCode,error:r},m);
                else
                    _cb({status:res.statusCode,data:r},m);
            });
        });
        req.on('error',function(e){
            //trace(e); 
        }); 
        if(["POST","PUT","PATCH"].indexOf(method)>-1&&_data!=null)
            req.write(stringify(_data));
        req.end();
#elseif cs
        var cscb = function(status,response,headers){
            var data = Json.parse(response);
            _cb({status:status,data:data},headers);
        }
        untyped __cs__('
                try{
                var httpWebRequest = (System.Net.HttpWebRequest)System.Net.WebRequest.Create({0});
                httpWebRequest.Method = {1};
                '
            ,url,method);
        for(h in _headers.keys()){
            if(h=="Content-Type")
                untyped __cs__('httpWebRequest.ContentType = {0};',_headers.get(h));
            else if(h=="User-Agent")
                untyped __cs__('httpWebRequest.ContentType = {0};',_headers.get(h));
            else
                untyped __cs__('httpWebRequest.Headers.Add({0},{1})',h,_headers.get(h));
        }
        if(["POST","PUT","PATCH"].indexOf(method)>-1&&_data!=null){
        untyped __cs__('
                using (var streamWriter = new System.IO.StreamWriter(httpWebRequest.GetRequestStream()))
                {
                    streamWriter.Write({0});
                    streamWriter.Flush();
                    streamWriter.Close();
                }'
            ,stringify(_data));
        }
        untyped __cs__('
                httpWebRequest.BeginGetResponse(new System.AsyncCallback(httpCallBack),System.Tuple.Create(httpWebRequest,{0}));
                }catch(System.Net.WebException e){
                    System.Console.WriteLine("ERROR IN HTTP REQUEST");
                    System.Console.WriteLine(e);
                }
            '
        ,cscb);
#else
        var call = new Http(url);
        var result = new haxe.io.BytesOutput();

        for(h in _headers.keys()){
            call.setHeader(h,_headers.get(h));
        }

        var status:Int = -1;
        call.onStatus = function(st){
            status = st;
            //trace("Status!");
        }
        call.onError = function(no){
            trace("Error!");
            var m = new Map<String,String>();
            for(k in call.responseHeaders.keys()){
                var v = call.responseHeaders[k];
                m.set(k.toLowerCase(),v);
            }
            var errReg = ~/Http Error #([0-9]{0,5})/;
            if(errReg.match(no)){
                _cb({"status":status,"error":"HTTP error "+status},m);
            }else{
                _cb({"status":status,"error":no},m);
            }
        }
        if(["POST","PUT","PATCH"].indexOf(method)>-1&&_data!=null){
            var sd = stringify(_data);
            call.setPostData(sd);
        }
        call.onData = function(data){
            trace("Data!");
            var m = new Map<String,String>();
            for(k in call.responseHeaders.keys()){
                var v = call.responseHeaders[k];
                m.set(k.toLowerCase(),v);
            }
            var data = Json.parse(data);
            _cb({status:status,data:data},m);
        }
        call.customRequest(false,result,method);
#end
    }
}