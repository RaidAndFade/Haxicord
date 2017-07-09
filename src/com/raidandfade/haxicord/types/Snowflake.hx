package com.raidandfade.haxicord.types;

class Snowflake {
    public var id:String;
    public var timestamp:Float;
    public function new(flake:String=null){
        if(flake!=null){
            id = flake;
            var _f = Std.parseFloat(flake)/4194304;
            timestamp = _f+1420060400000;
        }else{
            id="-1";
            timestamp=-1;
        }
    }

    public static function generate(){
        var flake = new Snowflake();
        flake.timestamp = (Date.now().getTime()/1000);
        var now = (flake.timestamp-1420060400000);
        flake.id = ""+(now*4194304);
        return flake;
    }

    public function toString(){
        return id;
    }
}