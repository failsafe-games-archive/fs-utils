package;

import haxe.ds.Option;

class OptionTools {
    
    public static function fromNullable<T>( obj : T ):Option<T> {
        return obj == null ? None : Some(obj);
    }
}