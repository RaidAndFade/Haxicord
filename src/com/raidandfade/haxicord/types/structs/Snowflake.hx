package com.raidandfade.haxicord.types.structs;

class Snowflake {
    public var id:String;
    public var timestamp:Int;
    public function new(flake:String){
        id = flake;
        var _f = Std.parseFloat(flake)/4194304;
        timestamp = Std.int(_f+1420060400000);
    }
}