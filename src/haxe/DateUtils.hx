package haxe;

class DateUtils {

    
    public static function fromISO8601(iso:String):Date{
        //oof
        var isoreg = ~/([1-9][0-9]{3}-(?:(0[1-9]|1[0-2])-(0[1-9]|1[0-9]|2[0-8])|(0[13-9]|1[0-2])-(29|30)|(0[13578]|1[02])-(31))|([1-9][0-9](?:0[48]|[2468][048]|[13579][26])|([2468][048]|[13579][26])00)-02-29)T([01][0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9])(\.[0-9]{1,9})?(Z|[+-][01][0-9]:[0-5][0-9])/;
        
        trace("d1");
        if(!isoreg.match(iso))throw "Invalid ISO8601 date";
        trace("d1_1");
        var year = Std.parseInt(isoreg.matched(1));
        trace("d1_2");
        var month = Std.parseInt(isoreg.matched(6));
        trace("d1_3");
        var day = Std.parseInt(isoreg.matched(7));
        trace("d1_4");
        if(isoreg.matched(2)!=null){ //day = 0-28 any month
            month = Std.parseInt(isoreg.matched(2));
            day = Std.parseInt(isoreg.matched(3));
        }else if(isoreg.matched(4)!=null){ //day = 29-30, not feb.
            month = Std.parseInt(isoreg.matched(4));
            day = Std.parseInt(isoreg.matched(5));
        }
        trace("d1_5");
        var hour = Std.parseInt(isoreg.matched(10));
        var minute = Std.parseInt(isoreg.matched(11));
        var second = Std.parseInt(isoreg.matched(12));
        trace("d1_6");
        var fraction = Std.parseFloat("0"+isoreg.matched(13));

        trace("d2");
        trace(year,month,day,hour,minute,second);
        trace(fraction);
        var date = new Date(year,month,day,hour,minute,second);
        var properd = Date.fromTime(date.getTime()+fraction);
        trace("d3");

        return properd;
    }

}