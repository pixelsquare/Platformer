package platformer.pxlsq;

#if flash
import flash.external.ExternalInterface;
#end

/**
 * ...
 * @author Anthony Ganzon
 */
class Utils
{
	public static function consoleLog(obj: Dynamic): Void {
		#if debug
			#if flash
				ExternalInterface.call("console.log", obj);
			#elseif html
				trace(obj);
			#end
		#end
	}
	
	public static function toHHMMSS(ms: Float): String {
		var sec: Int = Std.int((ms % 3600) % 60);
		var secStr: String = sec < 10 ? "0" + sec : "" + sec;
		
		var min: Int = Std.int((ms % 3600) / 60);
		var minStr: String = min < 10 ? "0" + min : "" + min;
		
		var hr: Int = Std.int(ms / 3600);
		var hrStr: String = hr < 10 ? "0" + hr : "" + hr;
		
		return hrStr + ":" + minStr + ":" + secStr;
	}
}