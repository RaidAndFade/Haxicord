package com.raidandfade.haxicord.types.structs;

class Tag{
    var tag:String;
    var type:TagType;
    var value:Snowflake;

    public function new(_tag:String){
        tag = _tag;

        if(tag.charAt(tag.length-1)!=">")throw "Invalid Tag";
        //Why haxe is good : also why it's bad : 
        type = switch(tag.substr(0,3).split("")){
            case ["<","@","&"]: Role;
            case ["<","@","!"]: Nick;
            case ["<","@",_]: User;
            case ["<",":",_]: Emoji;
            case ["<","#",_]: Channel;
            case _: throw "Invalid Tag";
        }
        
        var offset = ( type==User ? 1 : ( type==Emoji ? tag.lastIndexOf(":") : 2 ));
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