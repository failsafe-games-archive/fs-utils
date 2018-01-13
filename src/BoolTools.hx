package;

class BoolTools {
    
    public static inline function then( val : Bool, f : Void->Void ) : Bool {
        if (val) f();
        return val;
    }

    public static inline function otherwise( val : Bool, f : Void->Void ) : Bool {
        if (!val) f();
        return val;
    }

    public static inline function compare( val : Bool, i : Void->Void, e : Void->Void ) : Bool {
        if (val) {
            i();
         } else {
            e();
         }
        return val;
    }
}