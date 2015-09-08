package platformer.main.hero;

import flambe.asset.AssetPack;
import flambe.Component;
import flambe.math.Point;
import platformer.main.PlatformMain;
import platformer.main.tile.PlatformTile;

import platformer.main.utils.GameConstants;
import platformer.pxlSq.Utils;
import platformer.main.tile.utils.TileDataType;
import platformer.main.hero.utils.HeroDirection;

/**
 * ...
 * @author Anthony Ganzon
 */
class PlatformHeroCollision extends Component
{

	public function new() {	}
	
	public function HitFlags(tile: PlatformTile): Bool {
		return tile.GetTileDataType() == TileDataType.BLOCK ||
			tile.GetTileDataType() == TileDataType.OBSTACLE;
	}
	
	public function CompareLayers(tileA: PlatformTile, tileB: PlatformTile): Bool {
		return tileA.tileLayer == tileB.tileLayer;
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		
		var platformHero: PlatformHero = owner.get(PlatformHero);
		if (platformHero == null)
			return;
			
		var baseRow: Int = Math.floor(platformHero.x._ / GameConstants.TILE_WIDTH);
		var baseCol: Int = Math.floor(platformHero.y._ / GameConstants.TILE_HEIGHT);
		
		var platformMain: PlatformMain = platformHero.parent.get(PlatformMain);
		if (platformMain == null)
			return;
			
		var heroControl: PlatformHeroControl = owner.get(PlatformHeroControl);
		if (heroControl == null)
			return;
			
		var tileGrid: Array<Array<PlatformTile>> = platformMain.tileGrid;
		var bottomTile: PlatformTile = tileGrid[baseRow][baseCol + 1];
		
		// Right
		if (baseRow < (GameConstants.GRID_ROWS - 1)) {
			var rightTile: PlatformTile = tileGrid[baseRow + 1][baseCol];
			if (rightTile != null) {
				var ignoreLayer: Bool = heroControl.isHeroGrounded && CompareLayers(rightTile, bottomTile);
				var collisionFlag: Bool = HitFlags(rightTile) && ignoreLayer;
				if (collisionFlag && platformHero.x._ >= (baseRow * GameConstants.TILE_WIDTH) + 20) {
					platformHero.x._ = (baseRow * GameConstants.TILE_WIDTH) + 20;
				}
				}
		}
		else {
			if (platformHero.x._ >= (baseRow * GameConstants.TILE_WIDTH) + 20) {
				platformHero.x._ = (baseRow * GameConstants.TILE_WIDTH) + 20;
			}
		}
		
		// Left
		if(baseRow > 0) {
			var leftTile: PlatformTile = tileGrid[baseRow - 1][baseCol];
			if (leftTile != null) {
				var ignoreLayer: Bool = heroControl.isHeroGrounded && CompareLayers(leftTile, bottomTile);
				var collisionFlag: Bool = HitFlags(leftTile) && ignoreLayer;
				if (collisionFlag && platformHero.x._ <= ((baseRow + 1) * GameConstants.TILE_WIDTH) - 20) {
					platformHero.x._ = (baseRow + 1) * GameConstants.TILE_WIDTH - 20;
				}
			}
		}
		else {
			if(platformHero.x._ <= ((baseRow + 1) * GameConstants.TILE_WIDTH) - 20) {
				platformHero.x._ = (baseRow + 1) * GameConstants.TILE_WIDTH - 20;
			}
		}
		
		// Top
		if(baseCol > 0) {
			var topTile: PlatformTile = tileGrid[baseRow][baseCol - 1];
			if(topTile != null) {
				if (HitFlags(topTile) && platformHero.y._ <= ((baseCol + 1) * GameConstants.TILE_HEIGHT) - 20) {
					platformHero.y._ = ((baseCol + 1) * GameConstants.TILE_HEIGHT) - 20;
				}
			}
		}
		else {
			if (platformHero.y._ <= ((baseCol + 1) * GameConstants.TILE_HEIGHT) - 20) {
				platformHero.y._ = ((baseCol + 1) * GameConstants.TILE_HEIGHT) - 20;
			}
		}
			
		// Bottom
		if (baseCol < (GameConstants.GRID_COLS - 1)) {
			if (bottomTile != null) {	
				// TODO: LAYER COLLISIONs
				//Utils.ConsoleLog(heroControl.isHeroOnAir + "");
				//var collisionFlag: Bool = bottomTile.tileLayer == platformHero.heroLayer && !heroControl.isHeroOnAir;
				if (HitFlags(bottomTile) && platformHero.y._ >= (baseCol * GameConstants.TILE_HEIGHT) + 20) {
					platformHero.y._ = (baseCol * GameConstants.TILE_HEIGHT) + 20;
					heroControl.SetHeroVelocity(new Point());
					heroControl.SetIsGrounded(true);
					platformHero.SetHeroLayer(bottomTile.tileLayer);
				}
			}
		}
		else {
			if (platformHero.y._ >= (baseCol * GameConstants.TILE_HEIGHT) + 20) {
				platformHero.y._ = (baseCol * GameConstants.TILE_HEIGHT) + 20;
			}
		}
	}
}