package platformer.main.hero;

import flambe.Component;
import flambe.Disposer;
import flambe.input.Key;
import flambe.input.KeyboardEvent;
import flambe.math.FMath;
import flambe.math.Point;
import flambe.System;

import platformer.main.tile.PlatformTile;
import platformer.main.tile.utils.TileType;
import platformer.main.utils.GameConstants;

import platformer.pxlsq.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class HeroControl extends Component
{	
	public var isHeroRunning(default, null): Bool;
	public var isHeroGrounded(default, null): Bool;
	public var heroLayer(default, null): Int;
	
	private var platformHero: PlatformHero;
	private var tileGrid: Array<Array<PlatformTile>>;
	
	private var heroVelocity: Point;
	private var heroDisposer: Disposer;
	
	private var baseRow: Int;
	private var baseCol: Int;
	private var rowOverlap: Int;
	private var colOverlap: Int;
	
	private var rowMin: Int;
	private var colMin: Int;
	private var rowMinOverlap: Int;
	private var colMinOverlap: Int;
	
	private var rowMax: Int;
	private var colMax: Int;
	private var rowMaxOverlap: Int;
	private var colMaxOverlap: Int;
	
	private static inline var HERO_SPEED: Int = 100;
	private static inline var HERO_JUMP: Int = 300;
	
	private static inline var COLLIDER_PRECISION: Float = 0.991;
	
	public function new() {
		isHeroRunning = false;
		isHeroGrounded = false;
		heroVelocity = new Point();
	}
	
	public function ignoreLayer(tile: PlatformTile): Bool {
		return heroLayer == tile.tileLayer;
	}
	
	public function compareLayer(tileA: PlatformTile, tileB: PlatformTile): Bool {
		return tileA.tileLayer == tileB.tileLayer;
	}
	
	public function isBlockedBy(tile: PlatformTile): Bool {
		return platformHero.intersect(tile) && tile.tileLayer != 0 && tile.tileType == TileType.BLOCK;
	}
	
	public function isBlock(tile: PlatformTile): Bool {
		return tile.tileType == TileType.BLOCK;
	}
	
	public function screenBounds(): Void {
		platformHero.x._ = FMath.clamp(platformHero.x._, (GameConstants.TILE_WIDTH / 2), GameConstants.GAME_WIDTH - (GameConstants.TILE_WIDTH / 2));
		platformHero.y._ = FMath.clamp(platformHero.y._, (GameConstants.TILE_HEIGHT / 2), GameConstants.GAME_HEIGHT - (GameConstants.TILE_HEIGHT / 2));
	}
	
	public function updateValues(): Void {
		baseRow = Math.floor(platformHero.x._ / GameConstants.TILE_WIDTH);
		baseCol = Math.floor(platformHero.y._ / GameConstants.TILE_HEIGHT);
		rowOverlap = (Math.floor(platformHero.x._ / 10) * 10) % GameConstants.TILE_WIDTH;
		colOverlap = (Math.floor(platformHero.y._ / 10) * 10) % GameConstants.TILE_HEIGHT;
		
		rowMin = Math.floor(platformHero.colliderMin.x / GameConstants.TILE_WIDTH);
		colMin = Math.floor(platformHero.colliderMin.y / GameConstants.TILE_HEIGHT);
		rowMinOverlap = (Math.floor(platformHero.colliderMin.x / 10) * 10) % GameConstants.TILE_WIDTH;
		colMinOverlap = (Math.floor(platformHero.colliderMin.y / 10) * 10) % GameConstants.TILE_HEIGHT;

		rowMax = Math.floor(platformHero.colliderMax.x / GameConstants.TILE_WIDTH);
		colMax = Math.floor(platformHero.colliderMax.y / GameConstants.TILE_HEIGHT);
		rowMaxOverlap = (Math.floor(platformHero.colliderMax.x / 10) * 10) % GameConstants.TILE_WIDTH;
		colMaxOverlap = (Math.floor(platformHero.colliderMax.y / 10) * 10) % GameConstants.TILE_HEIGHT;
	}
	
	public function collisionDetection(dt: Float): Void {
		if (heroVelocity.x > 0) {
			if (rowMax <= GameConstants.GRID_ROWS - 1 && colMin >= 0 && colMax <= GameConstants.GRID_COLS - 1 &&
				(platformHero.intersect(tileGrid[rowMax][colMin]) || platformHero.intersect(tileGrid[rowMax][colMax])) && rowMaxOverlap == 0 &&
				(tileGrid[baseRow + 1][colMin].tileLayer != 0 || tileGrid[baseRow + 1][colMax].tileLayer != 0) &&
				ignoreLayer(tileGrid[baseRow + 1][baseCol])) {
				platformHero.x._ = (baseRow * GameConstants.TILE_WIDTH) + Math.abs(GameConstants.TILE_WIDTH - platformHero.colliderOffset.x);
				heroVelocity.x = 0;
			}
		}
		
		if (heroVelocity.x < 0) {
			if (rowMin >= 0 && colMin >= 0 && colMax <= GameConstants.GRID_COLS - 1 &&
				(platformHero.intersect(tileGrid[rowMin][colMin]) || platformHero.intersect(tileGrid[rowMin][colMax])) && rowMinOverlap == 30 &&
				(tileGrid[baseRow - 1][colMin].tileLayer != 0 || tileGrid[baseRow - 1][colMax].tileLayer != 0) &&
				ignoreLayer(tileGrid[baseRow - 1][baseCol])) {
				platformHero.x._ = ((baseRow + 1) * GameConstants.TILE_WIDTH) - Math.abs(GameConstants.TILE_WIDTH - platformHero.colliderOffset.x);
				heroVelocity.x = 0;
			}
		}
		
		if (heroVelocity.y > 0) {
			if (rowMin >= 0 && rowMax <= GameConstants.GRID_ROWS - 1 && colMax <= GameConstants.GRID_COLS - 1 &&
				(platformHero.intersect(tileGrid[rowMin][colMax]) || platformHero.intersect(tileGrid[rowMax][colMax])) && colMaxOverlap == 0 &&
				((tileGrid[rowMin][baseCol + 1].tileLayer != 0 && platformHero.colliderMin.x < tileGrid[rowMin][baseCol + 1].colliderMax.x) || 
				(tileGrid[rowMax][baseCol + 1].tileLayer != 0 && platformHero.colliderMax.x > tileGrid[rowMax][baseCol + 1].colliderMin.x))) {
				platformHero.y._ = (baseCol * GameConstants.TILE_HEIGHT) + Math.abs(GameConstants.TILE_HEIGHT - platformHero.colliderOffset.y);
				heroVelocity.y = 0;
				isHeroGrounded = true;

				if(tileGrid[baseRow][baseCol + 1].tileLayer != 0) {
					heroLayer = tileGrid[baseRow][baseCol + 1].tileLayer;
				}
			}
		}
		
		if (heroVelocity.y < 0) {
			if (rowMin >= 0 && rowMax <= GameConstants.GRID_ROWS - 1 && colMin >= 0 &&
				(platformHero.intersect(tileGrid[rowMin][colMin]) || platformHero.intersect(tileGrid[rowMax][colMin])) && colMinOverlap == 0 &&
				((tileGrid[rowMin][baseCol - 1].tileLayer != 0 && platformHero.colliderMin.x < tileGrid[rowMin][baseCol - 1].colliderMax.x) || 
				(tileGrid[rowMax][baseCol - 1].tileLayer != 0 && platformHero.colliderMax.x > tileGrid[rowMax][baseCol - 1].colliderMin.x)) &&
				ignoreLayer(tileGrid[baseRow - 1][baseCol])) {
				platformHero.y._ = (((baseCol + 1) * GameConstants.TILE_HEIGHT) - Math.abs(GameConstants.TILE_HEIGHT - platformHero.colliderOffset.y));
				heroVelocity.y = 0;
			}
		}
	}
	
	public function collisionDetection2(dt: Float): Void {		
		if (heroVelocity.x > 0) {
			if (rowMax <= GameConstants.GRID_ROWS - 1 && colMin >= 0 && colMax <= GameConstants.GRID_COLS - 1 && rowMaxOverlap == 0 && ignoreLayer(tileGrid[baseRow + 1][baseCol]) && 
				(isBlock(tileGrid[baseRow + 1][baseCol]) || isBlock(tileGrid[baseRow + 1][colMin]) || (isBlock(tileGrid[baseRow + 1][colMax]) && !isHeroGrounded)) &&
				(isBlockedBy(tileGrid[rowMax][baseCol]) || isBlockedBy(tileGrid[rowMax][colMin]) || isBlockedBy(tileGrid[rowMax][colMax]))) {
				platformHero.x._ = (baseRow * GameConstants.TILE_WIDTH) + (GameConstants.TILE_WIDTH - platformHero.colliderOffset.x);
				heroVelocity.x = 0;
			}
		}
		
		if (heroVelocity.x < 0) {
			rowMinOverlap = (Math.ceil(platformHero.colliderMin.x / 10) * 10) % GameConstants.TILE_WIDTH;
			rowMaxOverlap = (Math.ceil(platformHero.colliderMax.x / 10) * 10) % GameConstants.TILE_WIDTH;

			if (rowMin >= 0 && colMin >= 0 && colMax <= GameConstants.GRID_COLS - 1 && baseRow > 0 && rowMinOverlap == 0 && ignoreLayer(tileGrid[baseRow - 1][baseCol]) &&
				(isBlock(tileGrid[baseRow - 1][baseCol]) || isBlock(tileGrid[baseRow - 1][colMin]) || (isBlock(tileGrid[baseRow - 1][colMax]) && !isHeroGrounded)) &&
				(isBlockedBy(tileGrid[rowMin][baseCol]) || isBlockedBy(tileGrid[rowMin][colMin]) || isBlockedBy(tileGrid[rowMin][colMax]))) {
				platformHero.x._ = ((baseRow + 1) * GameConstants.TILE_WIDTH) - (GameConstants.TILE_WIDTH - platformHero.colliderOffset.x);
				heroVelocity.x = 0;
			}
		}

		if (heroVelocity.y > 0) {
			if (rowMin >= 0 && rowMax <= GameConstants.GRID_ROWS - 1 && colMax <= GameConstants.GRID_COLS - 1 && colMaxOverlap == 0 &&
				(isBlock(tileGrid[baseRow][baseCol + 1]) || isBlock(tileGrid[rowMin][baseCol + 1]) || isBlock(tileGrid[rowMax][baseCol + 1])) &&
				(isBlockedBy(tileGrid[baseRow][colMax]) || 
				(isBlockedBy(tileGrid[rowMin][colMax]) && !compareLayer(tileGrid[rowMin][colMin], tileGrid[rowMin][colMax]) && platformHero.colliderMin.x < tileGrid[rowMin][baseCol + 1].colliderMax.x) || 
				(isBlockedBy(tileGrid[rowMax][colMax]) && !compareLayer(tileGrid[rowMax][colMin], tileGrid[rowMax][colMax]) && platformHero.colliderMax.x > tileGrid[rowMax][baseCol + 1].colliderMin.x))) {
				platformHero.y._ = (baseCol * GameConstants.TILE_HEIGHT) + (GameConstants.TILE_HEIGHT - platformHero.colliderOffset.y);
				heroVelocity.y = 0;
				isHeroGrounded = true;

				if (tileGrid[baseRow][baseCol + 1].tileLayer != 0) {
					heroLayer = tileGrid[baseRow][baseCol + 1].tileLayer;
				}
			}
		}
		
		if (heroVelocity.y < 0) {
			colMinOverlap = (Math.ceil(platformHero.colliderMin.y / 10) * 10) % GameConstants.TILE_HEIGHT;
			colMaxOverlap = (Math.ceil(platformHero.colliderMax.y / 10) * 10) % GameConstants.TILE_HEIGHT;

			if (rowMin >= 0 && rowMax <= GameConstants.GRID_ROWS - 1 && colMin >= 0 && colMinOverlap == 0 && ignoreLayer(tileGrid[baseRow][baseCol - 1]) &&
				(isBlock(tileGrid[baseRow][baseCol - 1]) || isBlock(tileGrid[rowMin][baseCol - 1]) || isBlock(tileGrid[rowMax][baseCol - 1])) &&
				(isBlockedBy(tileGrid[baseRow][colMin]) || isBlockedBy(tileGrid[rowMin][colMin]) || isBlockedBy(tileGrid[rowMax][colMin]))) {
				platformHero.y._ = ((baseCol + 1) * GameConstants.TILE_HEIGHT) - (GameConstants.TILE_HEIGHT - platformHero.colliderOffset.y);
				heroVelocity.y = 0;
			}
		}
	}
	
	public function applyGravity(dt: Float): Void {
		if (baseCol < GameConstants.GRID_COLS - 1) {
			isHeroGrounded = false;
			heroVelocity.y += GameConstants.GRAVITY * dt;
		}
	}
	
	public function heroFallOutOfBounds(): Bool {
		return baseCol == GameConstants.GRID_COLS - 1 && tileGrid[baseRow][baseCol].tileLayer == 0;
	}
	
	public function hasCollidedWithObstacle(type: TileType): Bool {
		var rightSideHit: Bool = (tileGrid[rowMax][colMin].tileType == type && tileGrid[rowMax][colMax].tileType == type);
		
		var leftSideHit: Bool =	(tileGrid[rowMin][colMin].tileType == type && tileGrid[rowMin][colMax].tileType == type);
		
		var topSideHit: Bool = (tileGrid[rowMin][colMin].tileType == type && tileGrid[rowMax][colMin].tileType == type);
			
		var bottomSideHit: Bool = (tileGrid[rowMin][colMax].tileType == type && tileGrid[rowMax][colMax].tileType == type);
			
		if (rightSideHit || leftSideHit || topSideHit || bottomSideHit)
			return true;
			
		return false;
	}
	
	override public function onAdded() {
		super.onAdded();
		
		heroDisposer = owner.get(Disposer);
		if (heroDisposer == null) {
			owner.add(heroDisposer = new Disposer());
		}
		
		heroDisposer.add(System.keyboard.down.connect(function(event: KeyboardEvent) {
			if (!PlatformMain.sharedInstance.isGameStart)
				return;
			
			if (event.key == Key.Space) {
				if (heroVelocity.y != 0)
					return;
				
				heroVelocity.y = -HERO_JUMP;
				isHeroGrounded = false;
			}
			
			if (event.key == Key.W || event.key == Key.Up) {
				if (tileGrid[baseRow][baseCol].tileType == TileType.DOOR_OUT) {
					PlatformMain.sharedInstance.loadNextRoom();
				}
			}
			
			if ((System.keyboard.isDown(Key.A) && event.key == Key.D) ||
				(System.keyboard.isDown(Key.Left) && event.key == Key.Right)){
				platformHero.scaleX._ = Math.abs(platformHero.scaleX._);
			}
			
			if ((System.keyboard.isDown(Key.D) && event.key == Key.A) ||
				(System.keyboard.isDown(Key.Right) && event.key == Key.Left)){
				platformHero.scaleX._ = -Math.abs(platformHero.scaleX._);
			}
		}));
		
		platformHero = owner.get(PlatformHero);
		tileGrid = PlatformMain.sharedInstance.tileGrid;
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		
		if (!PlatformMain.sharedInstance.isGameStart)
				return;
			
		heroVelocity.x = 0; 
		//heroVelocity.y = 0;
		isHeroRunning = false;
		
		if ((System.keyboard.isDown(Key.D) && !System.keyboard.isDown(Key.A)) || 
			(System.keyboard.isDown(Key.Right) && !System.keyboard.isDown(Key.Left))) {
			heroVelocity.x = HERO_SPEED;
			platformHero.scaleX._ = Math.abs(platformHero.scaleX._);
			isHeroRunning = true;
		}
		
		if ((System.keyboard.isDown(Key.A) && !System.keyboard.isDown(Key.D)) || 
			(System.keyboard.isDown(Key.Left) && !System.keyboard.isDown(Key.Right))) {
			heroVelocity.x = -HERO_SPEED;
			platformHero.scaleX._ = -Math.abs(platformHero.scaleX._);
			isHeroRunning = true;
		}
		
		//if (System.keyboard.isDown(Key.S)) {
			//heroVelocity.y = HERO_SPEED;
		//}
		//
		//if (System.keyboard.isDown(Key.W)) {
			//heroVelocity.y = -HERO_SPEED;
		//}
		
		if ((System.keyboard.isDown(Key.A) && System.keyboard.isDown(Key.D)) ||
			(System.keyboard.isDown(Key.Left) && System.keyboard.isDown(Key.Right))){
			heroVelocity.x = 0;
		}
		
		updateValues();
		applyGravity(dt);
		//collisionDetection(dt);
		collisionDetection2(dt);
		
		// Clamp velocity to 80% of the total gravity to prevent overshoot
		heroVelocity.y = FMath.clamp(heroVelocity.y, -GameConstants.GRAVITY * 0.8, GameConstants.GRAVITY * 0.8);
		
		platformHero.x._ += heroVelocity.x * dt;	
		platformHero.y._ += heroVelocity.y * dt;	
		
		platformHero.setAnimationDirty(isHeroRunning);
		screenBounds();
		
		// Trigger death if the player falls out of stage or hit an obstacle
		if (heroFallOutOfBounds() || hasCollidedWithObstacle(TileType.SPIKE_DOWN) || hasCollidedWithObstacle(TileType.SPIKE_UP)) {
			PlatformMain.sharedInstance.playHeroDeathAnim();
		}
	}
}