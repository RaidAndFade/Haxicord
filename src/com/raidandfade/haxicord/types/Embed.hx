package com.raidandfade.haxicord.types;


//@serverside is for when you decide to at some point have an embed creator. fun times.

class Embed {
    var title:String;
    @serverSide var type:String; // should be "rich"
    var description:String;
    var url:String;
    @serverSide var timestamp:Date;
    var color:Int;
    var footer:EmbedFooter;
    var image:EmbedImage;
    var thumbnail:EmbedThumbnail;
    var video:EmbedVideo;
    var provider:EmbedProvider;
    var author:EmbedAuthor;
    var fields:Array<EmbedField>;
}

class EmbedFooter { 
    var text:String;
    var icon_url:String;
    @serverSide var proxy_icon_url:String; // http(s) and attachments.
}

class EmbedImage {
    var url:String;
    @serverSide var proxy_url:String;
    @serverSide var height:Int;
    @serverSide var width:Int;
}

//might be able to just use EmbedImage...
class EmbedThumbnail {
    var url:String;
    @serverSide var proxy_url:String;
    @serverSide var height:Int;
    @serverSide var width:Int;
}

class EmbedVideo {
    var url:String;
    @serverSide var height:Int;
    @serverSide var width:Int;
}

class EmbedProvider {
    var name:String;
    var url:String;
}

class EmbedAuthor {
    var name:String;
    var url:String;
    var icon_url:String;
    @serverSide var proxy_icon_url:String; // http(s) and attachments.
}

class EmbedField {
    var name:String;
    var value:String;
    var inline:Bool;
}