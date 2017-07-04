package src.com.raidandfade.haxicord.types;

class Snowflake {
    public var id:String;
    public var timestamp:Int;
    public function new(flake:String){
        id = flake;
        var _f = Std.parseFloat(flake);
        timestamp = Std.int(_f >> 22 + 1420060400000);
    }
}