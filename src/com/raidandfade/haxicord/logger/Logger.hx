package com.raidandfade.haxicord.logger;


/**
    A logger that actually looks good. Use this please. The `colors` compile flag will add colors to the prefix format.
 */
class Logger{

    static var outPrefix = "[%c{Green}%t%c{Reset}] %c{lightblue}%cn%c{Reset}->%c{LightBlue}%fn()%c{Reset}:%c{LightRed}%l%c{Reset}: ";

    static var origTrace : Dynamic;

    /**
       Register the logger as your official logger.
     */
    public static function registerLogger(){
        origTrace = haxe.Log.trace;
        haxe.Log.trace = hxTrace;
        #if (colors&&sys)
            Sys.command("echo \033[0m"); //because windows is very special.
        #end
    }

    /**
       Use this when you regret having a good logger you filthy black and white terminal person.
     */
    public static function unregisterLogger(){
        haxe.Log.trace = origTrace;
    }

    public static function getReplaceColor(col:String):String{
        #if (!sys||!colors)
            return "";
        #end
        return switch(col.toLowerCase()){
            case "red": "\033[0;31m";
            case "lightred": "\033[0;91m";
            case "green": "\033[0;32m";
            case "lightblue": "\033[0;94m";
            case "blue": "\033[0;34m";
            case "reset": "\033[0m";
            case _: "";
        }
    } 

    public static function hxTrace(v:Dynamic, ?infos:haxe.PosInfos) { 
        var infostr = outPrefix.split("").join("");
        infostr = StringTools.replace(infostr,"%t",DateTools.format(Date.now(),"%H:%M:%S"));
        var infostrt = infostr.split("").join("");
        for(i in 0...infostr.length-2 ){
            if(infostr.substr(i,2)=="%c"){
                var ic = infostr.indexOf("}",i);
                var c = infostr.substr(i+3,ic-i-3); 
                infostrt = StringTools.replace(infostrt,infostr.substring(i,ic+1),getReplaceColor(c));
            }
        }
        infostr = infostrt;
        if(infos!=null){
            infostr = StringTools.replace(infostr,"%fn",infos.methodName);
            infostr = StringTools.replace(infostr,"%l",Std.string(infos.lineNumber));
            infostr = StringTools.replace(infostr,"%f",infos.fileName);
            infostr = StringTools.replace(infostr,"%cn",infos.className.substr(infos.className.lastIndexOf(".")+1)); //className
            infostr = StringTools.replace(infostr,"%cp",infos.className); //classPath
        }else{
            infostr = StringTools.replace(infostr,"<%fn","");
            infostr = StringTools.replace(infostr,":%l>","");
            infostr = StringTools.replace(infostr,"%f->","");
        }

		#if flash
			#if (fdb || native_trace)
				var str = flash.Boot.__string_rec(v, "");
				if( infos != null && infos.customParams != null ) for( v in infos.customParams ) str += "," + flash.Boot.__string_rec(v, "");
				untyped __global__["trace"](infostr+""+str);
			#else
				untyped flash.Boot.__trace(v,infos);
			#end
		#elseif neko
			untyped {
				$print(infostr, v);
				if( infos.customParams != null ) for( v in infos.customParams ) $print(",", v);
				$print("\n");
			}
		#elseif js
			untyped js.Boot.__trace(v,infos); //TODO this
		#elseif (php && php7)
			php.Boot.trace(v, infos); //TODO this
		#elseif php
			if (infos!=null && infos.customParams!=null) {
				var extra:String = "";
				for( v in infos.customParams )
					extra += "," + v;
				untyped __call__('_hx_trace', v + extra, infos); //TODO this
			}
			else
				untyped __call__('_hx_trace', v, infos); //TODO this
		#elseif cpp
			if (infos!=null && infos.customParams!=null) {
				var extra:String = "";
				for( v in infos.customParams )
					extra += "," + v;
				untyped __trace(v + extra,infos); //TODO this
			}
			else
				untyped __trace(v,infos); //TODO this
		#elseif (cs || java || lua)
			var str:String = null;
			str = infostr + v;
			if (infos != null && infos.customParams != null)
            {
                str += "," + infos.customParams.join(",");
            }
			#if cs
			cs.system.Console.WriteLine(str);
			#elseif java
			untyped __java__("java.lang.System.out.println(str)");
			#elseif lua
			if (str == null) str = "null";
			untyped __define_feature__("use._hx_print",_hx_print(str));
			#end
		#elseif (python)
			var str:String = null;
		    str = infostr + " " + v;
			if (infos != null && infos.customParams != null) {
                str += "," + infos.customParams.join(",");
            }
			python.Lib.println(str);
		#elseif hl
			var str = Std.string(v);
			if( infos != null && infos.customParams != null ) for( v in infos.customParams ) str += "," + Std.string(v);
			Sys.println(infostr+": "+str);
		#end
    }

    public static function out(s:String){
        #if sys
            Sys.stdout().writeString(s+"\n");
            Sys.stdout().flush();
        #elseif js
            js.Browser.console.info(s);
        #else
            trace("OUT-"+s);
        #end
    }
    public static function err(s:String){
        #if sys
            Sys.stderr().writeString(s+"\n");
            Sys.stderr().flush();
        #elseif js
            js.Browser.console.error(s);
        #else
            trace("ERR-"+s); //TODO this
        #end
    }
}