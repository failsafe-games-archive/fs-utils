class ArrayTools {

    @:generic
    public static inline function iter<T>( array : Array<T>, f : T->Void ) {
        for ( item in array ) f(item);
    }
}