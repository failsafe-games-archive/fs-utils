package;

import haxe.ds.Option;

using OptionTools;

class OptionTools {
    
    public static function mapFromNullable<T,U>( obj : T, f : T->U ) : Option<U> {
        return switch( obj.fromNullable() ) {
            case Some(obj) : f(obj).fromNullable();
            case None : None;
        }
    }

    public static function fromNullable<T>( obj : T ) : Option<T> {
        return obj == null ? None : Some(obj);
    }
}