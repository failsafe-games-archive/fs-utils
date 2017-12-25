using tink.CoreApi;

/**
 *  Handy functions for promises best used with `using PromiseTools`
 */
class PromiseTools {
    
    /**
     *  Call `f` on promise's success and return the promise for chaining
     *  
     *  @param promise - The promise
     *  @param f - Callback called when the promise is a success
     *  @return The promise
     */
    @generic public static function onSuccess<T>(promise:Promise<T>, f:T->Void):Promise<T> {
        promise.handle((outcome) -> switch(outcome) {
            case Success(result) : f(result);
            case Failure(error) : 
        });
        return promise;
    }

    /**
     *  Call `f` on promise's failure and return the promise for chaining
     *  
     *  @param promise - The promise
     *  @param f - Callback called when the promise is a failure
     *  @return The promise
     */
    @generic public static function onFailure<T>(promise:Promise<T>, f:Error->Void):Promise<T> {
        promise.handle((outcome) -> switch(outcome) {
            case Success(result) : 
            case Failure(error) : f(error);
        });
        return promise;
    }
}