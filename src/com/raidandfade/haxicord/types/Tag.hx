package com.raidandfade.haxicord.types;

class Tag{
    var tag:String;
    var type:TagType;
    var value:Snowflake;

    public function new(_tag:String){
        tag = _tag;
        if(tag.charAt(0)!="<")throw "Invalid Tag Given";
        //Why haxe is good : also why it's bad : 
        type = switch(tag.charAt(1)){
            default:throw "Invalid Tag Given";
            case "@":
                switch(tag.charAt(2)){
                    default: User
                    case "!": Nick
                    case "&": Role
                }
            case "#": Channel
            case ":": Emoji
        }
        var offset = type==User?1:type==Emoji?tag.lastIndexOf(":"):2;
        var flakeStr = tag.substr(offset,tag.length-(offset+1));
        value = new Snowflake(flakeStr);
    }
}

enum TagType{
    User;
    Nick;
    Channel;
    Role;
    Emoji;
}