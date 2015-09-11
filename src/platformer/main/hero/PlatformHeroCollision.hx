package platformer.main.hero;

import flambe.Component;
import flambe.math.Point;
import flambe.util.Signal1;

import platformer.main.PlatformMain;
import platformer.main.tile.PlatformTile;
import platformer.main.tile.utils.TileDataType;
import platformer.main.utils.GameConstants;

import platformer.pxlSq.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class PlatformHeroCollision extends Component
{
	public var onTileChanged(default, null): Signal1<PlatformTile>;
	
	private var collisionLayer: Int;
	private var curTile: PlatformTile;
	private var prevTile: PlatformTile;
	
	public function new() {	
		this.onTileChanged = new Signal1<PlatformTile>();
		this.curTile = null;
		this.prevTile = null;
		this.collisionLayer = 0;
	}
	
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
		if (tileGrid == null)
			return;
			
		var rightOverlap: Bool = platformHero.x._ % GameConstants.TILE_WIDTH >= (GameConstants.TILE_WIDTH / 2);
		var leftOverlap: Bool = platformHero.x._ % GameConstants.TILE_WIDTH <= (GameConstants.TILE_WIDTH / 2);
		var topOverlap: Bool = platformHero.y._ % GameConstants.TILE_HEIGHT <= (GameConstants.TILE_HEIGHT / 2);
		var bottomOverlap: Bool = platformHero.y._ % GameConstants.TILE_HEIGHT >= (GameConstants.TILE_HEIGHT / 2);
		
		//var horizontalOverlap: Float = platformHero.x._ % GameConstants.TILE_WIDTH;
		//var verticalOverlap: Float = platformHero.y._ % GameConstants.TILE_HEIGHT;
		//Utils.ConsoleLog(horizontalOverlap + " " + verticalOverlap);
		
		if(baseRow < (GameConstants.GRID_ROWS - 1)) {
			var rightTile: PlatformTile = tileGrid[baseRow + 1][baseCol];
			var ignoreLayer: Bool = collisionLayer == rightTile.tileLayer;
			if (HitFlags(rightTile) && rightOverlap && ignoreLayer) {
				platformHero.x._ = baseRow * GameConstants.TILE_WIDTH + (GameConstants.TILE_WIDTH / 2);
			}
		}
		else {
			// Right Stage corner bounds
			if (rightOverlap) {
				platformHero.x._ = baseRow * GameConstants.TILE_WIDTH + (GameConstants.TILE_WIDTH / 2);
			}
		}
		
		if(baseRow > 0) {
			var leftTile: PlatformTile = tileGrid[baseRow - 1][baseCol];
			var ignoreLayer: Bool = collisionLayer == leftTile.tileLayer;
			if (HitFlags(leftTile) && leftOverlap && ignoreLayer) {
				platformHero.x._ = (baseRow + 1) * GameConstants.TILE_WIDTH - (GameConstants.TILE_WIDTH / 2);
			}
		}
		else {
			// Left Stage corner bounds
			if(leftOverlap) {
				platformHero.x._ = baseRow * GameConstants.TILE_WIDTH + (GameConstants.TILE_WIDTH / 2);
			}
		}
		
		if(baseCol > 0) {
			var topTile: PlatformTile = tileGrid[baseRow][baseCol - 1];
			var ignoreLayer: Bool = collisionLayer == topTile.tileLayer;
			if (HitFlags(topTile) && topOverlap && ignoreLayer) {
				platformHero.y._ = (baseCol + 1) * GameConstants.TILE_HEIGHT - (GameConstants.TILE_HEIGHT / 2);
				heroControl.SetHeroVelocity(new Point());
			}
		}
		else {
			// Top Stage corner bounds
			if (topOverlap) {
				platformHero.y._ = (baseCol + 1) * GameConstants.TILE_HEIGHT - (GameConstants.TILE_HEIGHT / 2);
			}
		}
		
		// heroYOffset adds an offset to hero's y position
		// for the feet to touch the ground
		var heroYOffset: Int = 3;
		if(baseCol < (GameConstants.GRID_COLS - 1)) {
			var bottomTile: PlatformTile = tileGrid[baseRow][baseCol + 1];
			var ignoreLayer: Bool = bottomTile.tileLayer >= 1;
			var isHeroFalling: Bool = heroControl.heroVelocity.y > 0;
			if (HitFlags(bottomTile) && bottomOverlap && ignoreLayer && isHeroFalling) {
				platformHero.y._ = baseCol * GameConstants.TILE_HEIGHT + (GameConstants.TILE_HEIGHT / 2) + heroYOffset;
				heroControl.SetHeroVelocity(new Point());
				heroControl.SetIsGrounded(true);
				
				if (heroControl.isHeroGrounded && !heroControl.isHeroOnAir) {
					collisionLayer = bottomTile.tileLayer;
				}
			}
		}
		else {
			// Bottom Stage corner bounds
			if (bottomOverlap) {
				platformHero.y._ = baseCol * GameConstants.TILE_HEIGHT + (GameConstants.TILE_HEIGHT / 2) + heroYOffset;
			}
		}
		
		curTile = tileGrid[baseRow][baseCol];
		if (curTile != prevTile) {
			if(rightOverlap || leftOverlap || topOverlap || bottomOverlap) {
				onTileChanged.emit(tileGrid[baseRow][baseCol]);
				prevTile = tileGrid[baseRow][baseCol];
			}
		}
	}
}