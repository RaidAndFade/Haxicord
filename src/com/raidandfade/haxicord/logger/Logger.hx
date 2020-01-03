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
        infostr = StringTools.replace(infostr, "%t", DateTools.format(Date.now(), "%H:%M:%S"));

        var infostrt = infostr.split("").join("");

        for(i in 0 ... infostr.length-2 ) {
            if(infostr.substr(i, 2) == "%c") {
                var ic = infostr.indexOf("}", i);
                var c = infostr.substr(i + 3, ic - i - 3); 
                infostrt = StringTools.replace(infostrt, infostr.substring(i, ic + 1), getReplaceColor(c));
            }
        }
        infostr = infostrt;
        try{
        if(infos != null){
            infostr = StringTools.replace(infostr, "%fn", infos.methodName);
            infostr = StringTools.replace(infostr, "%l", Std.string(infos.lineNumber));
            infostr = StringTools.replace(infostr, "%f", infos.fileName);
            infostr = StringTools.replace(infostr, "%cn", infos.className.substr(infos.className.lastIndexOf(".")+1)); //className
            infostr = StringTools.replace(infostr, "%cp", infos.className); //classPath
        }else{
            infostr = StringTools.replace(infostr, "<%fn", "");
            infostr = StringTools.replace(infostr, ":%l>", "");
            infostr = StringTools.replace(infostr, "%f->", "");
        }
        }catch(e:Dynamic){}

        origTrace(infostr+v,null);
    }

    public static function out(s:String) {
        #if sys
            Sys.stdout().writeString(s+"\n");
            Sys.stdout().flush();
        #elseif js
            js.Browser.console.info(s);
        #else
            trace("OUT-"+s);
        #end
    }
    public static function err(s:String) {
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