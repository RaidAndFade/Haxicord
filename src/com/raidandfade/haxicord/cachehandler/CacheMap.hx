package com.raidandfade.haxicord.cachehandler;

//@:build(Profiler.buildAll())
class CacheMap<K>{

    //list of ids
    public var idx:Array<String> = new Array<String>();
    //data
    public var data:Map<String,K> = new Map<String,K>();

    public var maxlen:Int;

    public function new(maxlen){
        this.maxlen = maxlen;
        if(this.maxlen == null){
            this.idx = null;
        }
    }

    public function set(id:String,val:K):Void{
        while(idx!=null && idx.length>this.maxlen){
            var oid = idx.shift();
            data.remove(oid);
        }

        if(idx!=null){
            if(!data.exists(id)){
                idx.push(id);
                data.set(id, val);
            }
        }else{
            data.set(id, val);
        }
    }

    public function get(id:String):Null<K> {
        return data.get(id);
    }

    public function remove(id:String){
        if(data.remove(id)){
            if(idx!=null)idx.remove(id);
        }
    }

    public function iterator():Iterator<K>{
        return data.iterator();
    }
}