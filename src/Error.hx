typedef TypedError<T> = {
    var message:String;
    var code:Int;
    var data:T;
}

@:forward(message, code, data)
abstract Error<T>(TypedError<T>) from TypedError<T> to TypedError<T> {
    @:from static function fromString(message:String):Error<String>
        return {message: message, code: 0, data: message};

    @:from static function fromCode(code:Int):Error<Int>
        return {message: 'Error Code: ${code}', code: code, data: code};
    
    @:from static function fromData<R>(data:R):Error<R>
        return {message: 'From Data: ${data}', code: 0, data: data};

    public function toString():String
        return 'Message: ${this.message}, Code: ${this.code}, Data: ${this.data}';
}