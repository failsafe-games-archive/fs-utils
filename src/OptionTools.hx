package;

import haxe.ds.Option;

using OptionTools;

class OptionTools {
    
    public static inline function mapOption<T,U>( obj : T, f : T->U ) : Option<U> {
        return switch( obj.option() ) {
            case Some(obj) : f(obj).option();
            case None : None;
        }
    }

    public static inline function option<T>( obj : T ) : Option<T> {
        return obj == null ? None : Some(obj);
    }

    // TODO: Move to another utils
    public static inline function getOr<T>( obj : T, f : Void -> T ) : T {
        return obj == null ? f() : obj;
    }

    public static inline function ifSome<T>( obj : Option<T>, f : T -> Void ) : Option<T> {
        switch(obj) {
            case Some(obj) : f(obj);
            case None : 
        }
        return obj;
    }
}