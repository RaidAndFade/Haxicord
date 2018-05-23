package haxe;

class DateUtils {

    
    public static function fromISO8601(iso:String):Date{
        //oof
        var isoreg = ~/([1-9][0-9]{3}-(?:(0[1-9]|1[0-2])-(0[1-9]|1[0-9]|2[0-9])|(0[13-9]|1[0-2])-(29|30)|(0[13578]|1[02])-(31))|([1-9][0-9](?:0[48]|[2468][048]|[13579][26])|([2468][048]|[13579][26])00)-02-29)T([01][0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9])(\.[0-9]{1,9})?(Z|[+-][01][0-9]:[0-5][0-9])/;
        
        if(!isoreg.match(iso))throw "Invalid ISO8601 date";

        var year = Std.parseInt(isoreg.matched(1));
        var month = Std.parseInt(isoreg.matched(6));
        var day = Std.parseInt(isoreg.matched(7));
        if(isoreg.matched(2)!=null){ //day = 0-28 any month
            month = Std.parseInt(isoreg.matched(2));
            day = Std.parseInt(isoreg.matched(3));
        }else if(isoreg.matched(4)!=null){ //day = 29-30, not feb.
            month = Std.parseInt(isoreg.matched(4));
            day = Std.parseInt(isoreg.matched(5));
        }
        var hour = Std.parseInt(isoreg.matched(10));
        var minute = Std.parseInt(isoreg.matched(11));
        var second = Std.parseInt(isoreg.matched(12));
        var fraction = Std.parseFloat("0"+isoreg.matched(13));

        var date = new Date(year,month,day,hour,minute,second);
        var properd = Date.fromTime(date.getTime()+fraction);

        return properd;
    }

    public static function utcNow() : Date {
        var now = Date.now();

        var h  = "" + now.getHours();
        var m  = "" + now.getMinutes();
        var s  = "" + now.getSeconds();
        var mo = "" + now.getMonth();
        var da = "" + now.getDate();
                
        if(h.length == 1) h = "0"+h;
        if(m.length == 1) m = "0"+m;
        if(s.length == 1) s = "0"+s;
        if(da.length == 1) da = "0"+da;
        if(mo.length == 1) mo = "0"+mo;

        var utcTime = Date.fromString(h + ":" + m + ":" + s).getTime();
        var dateMs = Date.fromString(now.getFullYear() + "-" + mo + "-" + da).getTime();
        var utcDate = Date.fromTime(utcTime + dateMs);
        return utcDate;  
    }
}