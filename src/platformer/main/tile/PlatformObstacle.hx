package platformer.main.tile;

import flambe.display.Texture;
import platformer.main.utils.TileDataType;

/**
 * ...
 * @author Anthony Ganzon
 */
class PlatformObstacle extends PlatformTile
{

	public function new(texture:Texture) {
		super(texture);
	}
	
	override public function GetTileDataType():TileDataType {
		return TileDataType.OBSTACLE;
	}
}