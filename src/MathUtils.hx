package;

import haxe.ds.Vector;

/**
 * Some usefull mathematical functions for audio processing
 *
 * Also some approx. functions for faster performance (do some testing about that...)
 */
class MathUtils {

    // Const
    public inline static var PI = 3.141592653589793;
    public inline static var TWO_PI = 2.0 * PI;
    public inline static var TWELTH_TWO = 1.0594630943592952645618252949463;
    public inline static var LN10 = 2.30258509299405;
    public inline static var LOG10E = 0.4342944819032518;

    // The base 10 exponent multiplier for decibels
    public inline static var DECIBELS_PER_DECADE = 20.0;

    // The smallest audible signal strength
    public inline static var MINIMUM_SIGNAL = 1.0 / 65536.0;

    // The smallest parametric control signal
    public inline static var MINIMUM_CONTROL = 1.0 / 128.0;

    // The decibel gain at which a sound becomes inaudible at 16 bit sample size
    public static var ZERO_GAIN_DECIBELS = factorToDecibels(MINIMUM_SIGNAL);

    // The natural log of the gain of an inaudible sound
    public static var MINIMUM_CONTROL_LN = Math.log(MINIMUM_CONTROL);

    // Sin table
    var sinTable : Vector<Float> = null;

    // Decibel table
    var dbTable : Vector<Float> = null;

    // Pow
    var pow : Float = 0;

    // Instance
    public static var instance(get, null) : MathUtils;
    public static function get_instance() : MathUtils {
        if( instance == null ) {
            instance = new MathUtils();
            instance.createTables(4);
        }
        return instance;
    }

    // No need to instantiate
    private function new() { }

    // Create tables
    public function createTables( numDigits : Int = 2 ) : Void {
        // Sin
        if( sinTable == null ) {
            pow = Math.pow(10, numDigits);
            var round = 1.0 / pow;
            var len = Std.int(1 + TWO_PI*pow);

            sinTable = new Vector<Float>( len );

            var theta = 0.0;
            for( i in 0...len ) {
                sinTable[i] = Math.sin( theta );
                theta += round;
            }
        }
        
        // Decibel
        if( dbTable == null ) {
            dbTable = new Vector<Float>(8192);
            
            var ln10div20 = 2.3025850929940459011 / 20.0;
            var db = -128.0;
            for( b in 0...dbTable.length ) {
                // From -128db to +128db in 1/32 db steps
                dbTable[b] = Math.exp(db * ln10div20);
                db += .03125; // 1/32
            }
        }
    }

    // Combine Pan value
    public static inline function combinePan( pan1 : Float, pan2 : Float, pan3 : Float = 0, pan4 : Float = 0, pan5 : Float = 0 ) : Float {
        pan1 += pan2 + pan3 + pan4 + pan5;
        return (pan1 > 1) ? 1 : (pan1 < -1) ? -1 : pan1;
    }
  
    // Fast decibel to factor
    public static inline function fastDecibelsToFactor( dB : Float ) : Float {
        return instance.dbTable[Std.int((dB*32) + 4096)];
    }
  
    // Convert a gain in decibels to a pure proportional factor.
    public static inline function decibelsToFactor( dB : Float ) : Float {
        return Math.exp(dB * LN10 / DECIBELS_PER_DECADE);
    }

    // Convert a pure proportional factor to a gain in decibels.
    public static inline function factorToDecibels( gain : Float ) : Float {
        return Math.log(gain) * LOG10E * DECIBELS_PER_DECADE;
    }

    // Sin
    public static inline function sin( radians : Float ) : Float {
        return instance._sin(radians);
    }

    // Sin
    public inline function _sin( radians : Float ) : Float {
        return radians >= 0
        ? sinTable[Std.int((radians%TWO_PI)*pow)]
        : sinTable[Std.int((TWO_PI+radians%TWO_PI)*pow)];
    }

    // Faster Sin function?
    public inline function fastsin( angle : Float ) : Float {
        var x = (Std.int(angle * 683565275.576431589782294)) >> 16;
        var sinB = (x - ((x * (x < 0 ? -x : x)) >> 15)) * 41721;
        var sinC = sinB >> 15;
        var fix = sinB + (sinC * (sinC < 0 ? -sinC : sinC) >> 9) * 467;
        return fix / 441009855.21060102566599663103894;
    }

    // Simple linear interpolation
    public static inline function interpolateInt( val1 : Int, val2 : Int, fraction : Float ) : Int {
        return val1 + Std.int(fraction * (val2-val1));
    }

    public static inline function interpolate( val1 : Float, val2 : Float, fraction : Float ) : Float {
        return val1 + fraction * (val2-val1);
    }

    // Cubic spline interpolation
    public static inline function cubicInterpolate( y0 : Float, y1 : Float, y2 : Float, y3 : Float, mu : Float ) : Float {
        var a0 : Float, a1 : Float, a2 : Float, a3 : Float, mu2 : Float;
        mu2 = mu * mu;
        a0 = y3 - y2 - y0 + y1;
        a1 = y0 - y1 - a0;
        a2 = y2 - y0;
        a3 = y1;

        return (a0 * mu * mu2 + a1 * mu2 + a2 * mu + a3);
    }
    
    // "Proper" mod for negative value
    public static inline function mod( a : Int, b : Int ) : Int {
        if( a < 0 ) a = b - Std.int(Math.abs(a % b));
        return a % b;
    }
    public static inline function modf( a : Float, b : Float ) : Float {
        if ( a < 0 ) a = b - Math.abs(a % b);
        return a % b;
    }
}