package fs._internal.utils; #if macro

import haxe.macro.Compiler;
import haxe.macro.Context;

class ExtraParams {

	public static function include ():Void {
		Compiler.define("concurrent", "");		
	}
}
#end