package platformer.main.utils;

import flambe.System;
import platformer.main.tile.PlatformTile;
import flambe.util.Promise;

/**
 * ...
 * @author Anthony Ganzon
 */
class PlatformUtils
{
	public static function LoadTileGrid(fn: Array < Array<PlatformTile> -> Void): Promise<Array<Array<PlatformTile>>> {
		var promise: Promise<Array<Array<PlatformTile>>> = new Promise<Array<Array<PlatformTile>>>();
		
		return promise;
	}
}