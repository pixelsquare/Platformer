package platformer.pxlSq;
import flambe.Entity;

#if flash
import flash.external.ExternalInterface;
#end

/**
 * ...
 * @author Anthony Ganzon
 * Console logger for debugging purposes.
 * NOTE: Works only with flash build
 */
class Utils
{
	public static function ConsoleLog(str: Dynamic): Void {
		#if flash
		ExternalInterface.call("console.log", str);
		#elseif html
		trace(str);
		#end
	}
	
	public static function DebugEntity(entity: Entity): Void {
		if (entity == null) {
			ConsoleLog("1 Entity is Null!");
		}
		
		if (entity.parent == null) {
			ConsoleLog("2 Parent is Null!");
		}
		
		if (entity.firstChild == null) {
			ConsoleLog("3 First Child is null!");
		}
		
		if (entity.next == null) {
			ConsoleLog("4 Next is null!");
		}
		
		if (entity.firstComponent == null) {
			ConsoleLog("5 First Component is null!");
		}
	}
	
	public static function GetSpritesRecursively(root: Entity, result: Array<Entity>): Void {
		var child: Entity = root.firstChild;
		while (child != null) {
			var next = child.next;
			result.push(child);
			GetSpritesRecursively(child, result);
			child = next;
		}
	}
	
	public static function ToMMSS(ms: Float): String {		
		var sec: Int = Std.int((ms % 3600) % 60);
		var secStr: String = (sec < 10) ? "0" + sec : "" + sec;
		
		var min = Std.int((ms % 3600) / 60);
		var minStr: String = (min < 10) ? "0" + min : "" + min;
		
		//var hr = Std.int(ms / 3600);
		//var hrStr: String = (hr < 10) ? "0" + hr : "" + hr;
		
		return minStr + ":" + secStr;
	}
}
