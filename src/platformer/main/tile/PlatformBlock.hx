package platformer.main.tile;

import flambe.display.Texture;
import platformer.main.tile.utils.TileDataType;

/**
 * ...
 * @author Anthony Ganzon
 */
class PlatformBlock extends PlatformTile
{

	public function new(texture:Texture) {
		super(texture);
	}
	
	override public function GetTileDataType(): TileDataType {
		return TileDataType.BLOCK;
	}
}