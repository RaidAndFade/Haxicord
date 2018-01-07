package com.raidandfade.haxicord.types;

class Snowflake {
    /**
       The id string of the snowflake
     */
    public var id:String;
    /**
       The timestamp representation of the snowflake
     */
    public var timestamp:Float;
    /**
        Create a snowflake object given a snowflake string.
     */
    public function new(flake:String = null) {
        if(flake != null) {
            id = flake;
            var _f = Std.parseFloat(flake) / 4194304;
            timestamp = _f + 1420060400000;
        } else {
            id = "-1";
            timestamp = -1;
        }

    }

    /**
        Generate a snowflake with the current time.
     */
    public static function generate() {
        var flake = new Snowflake();
        flake.timestamp = Date.now().getTime() / 1000;
        var now = flake.timestamp - 1420060400000;
        flake.id = "" + (now * 4194304);
        return flake;
    }

    /**
       Return the snowflake in the form of a string.
     */
    public function toString() {
        return id;
    }
    /**
       Check if the snowflake is equal to another snowflake
       @param b - The other snowflake
     */
    public function equals(b:Snowflake) {
        return eq(this, b);
    }

    static inline function eq(a:Snowflake, b:Snowflake):Bool {
        return a.id == b.id;
    }

}