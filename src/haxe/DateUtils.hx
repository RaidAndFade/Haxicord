package haxe;

#if neko
import neko.Lib;
#end


class DateUtils {
    
    public static function fromISO8601(iso:String):Date{
        var isoreg = ~/([1-9][0-9]{3}-(?:(0[1-9]|1[0-2])-(0[1-9]|1[0-9]|2[0-9])|(0[13-9]|1[0-2])-(29|30)|(0[13578]|1[02])-(31))|([1-9][0-9](?:0[48]|[2468][048]|[13579][26])|([2468][048]|[13579][26])00)-02-29)T([01][0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9])(\.[0-9]{1,9})?(Z|[+-][01][0-9]:[0-5][0-9])/;
        
        if(!isoreg.match(iso))throw "Invalid ISO8601 date";

        var year = Std.parseInt(isoreg.matched(1));
        var month = 0;
        var day = 1;
        if(isoreg.matched(2)!=null){ //day = 0-28 any month
            month = Std.parseInt(isoreg.matched(2));
            day = Std.parseInt(isoreg.matched(3));
        }else if(isoreg.matched(4)!=null){ //day = 29-30, not feb.
            month = Std.parseInt(isoreg.matched(4));
            day = Std.parseInt(isoreg.matched(5));
        }else{
            month = Std.parseInt(isoreg.matched(6));
            day = Std.parseInt(isoreg.matched(7));
        }
        var hour = Std.parseInt(isoreg.matched(10));
        var minute = Std.parseInt(isoreg.matched(11));
        var second = Std.parseInt(isoreg.matched(12));
        var fraction = Std.parseFloat("0"+isoreg.matched(13));

        var date = new Date(year,month-1,day,hour,minute,second);
        var properd = Date.fromTime(date.getTime()+fraction);
        return properd;
    }

    /**
       Get the ISO8601 of the date provided. ASSUMES UTC.
       @param d - the date to get iso for
       @return String - the iso string
     */
    public static function toISO8601(d:Date):String{
        var y = ""+d.getFullYear();
        var mo = ""+(d.getMonth()+1);
        var da = ""+d.getDate();
        var h = ""+d.getHours();
        var m = ""+d.getMinutes();
        var s = ""+d.getSeconds();
        var ms = ""+(d.getTime()%1000);

        if(mo.length == 1) mo = "0"+mo;
        if(da.length == 1) da = "0"+da;
        if(h.length == 1) h = "0"+h;
        if(m.length == 1) m = "0"+m;
        if(s.length == 1) s = "0"+s;
        if(ms.length == 1) ms = "00"+ms;
        if(ms.length == 2) ms = "0"+ms;
        
        var str = y+"-"+mo+"-"+da+"T"+h+":"+m+":"+s+"."+ms+"Z";

        return str;
    }

#if neko
    static var date_get_tz = Lib.load("std","date_get_tz",1);
#end
    /**
       Number of seconds from the current time zone to UTC.
       @return Int the num of seconds
     */
    public static function getTimezoneOffset():Int{
    #if js
        return untyped new Date(null,null,null,null,null,null).getTimezoneOffset()*60;
    #elseif neko
        return untyped -date_get_tz(1);
    #else
        throw "Not supported!";
    #end
    }

    public static function utcNow():Date{
        var d = Date.now();
        var time = d.getTime()+(getTimezoneOffset()*1000);
        var utcDate = Date.fromTime(time);
        return utcDate;
    }

    public static function main(){
       // var s = "2018-05-15T06:11:38.619727+00:00";
        
    }
}