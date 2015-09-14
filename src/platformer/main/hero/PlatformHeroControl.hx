package platformer.main.hero;

import flambe.Component;
import flambe.Disposer;
import flambe.input.Key;
import flambe.input.KeyboardEvent;
import flambe.math.FMath;
import flambe.math.Point;
import flambe.System;

import platformer.main.hero.utils.HeroDirection;
import platformer.main.tile.PlatformTile;
import platformer.main.tile.utils.TileType;
import platformer.main.utils.GameConstants;
import platformer.main.tile.utils.TileDataType;

import platformer.pxlSq.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class PlatformHeroControl extends Component
{
	public var heroDirection(default, null): HeroDirection;
	public var isHeroRunning(default, null): Bool;
	public var isHeroGrounded(default, null): Bool;
	public var isHeroOnAir(default, null): Bool;
	public var didJump(default, null): Bool;
	
	public var heroVelocity(default, null): Point;
	public var heroAcceleration(default, null): Point;
	
	public var isKinematic(default, null): Bool;
	
	private var currentTile: PlatformTile;
	private var collisionLayer: Int;
	
	private	var row: Int;
	private	var col: Int;

	private	var minRow: Int;
	private	var minCol: Int;
		
	private	var maxRow: Int;
	private	var maxCol: Int;
	
	private var tileGrid: Array<Array<PlatformTile>>;
	
	private var jumpForce: Float;
	private var controlDisposer: Disposer;
	
	private static inline var UNIT_GRAVITY: Float = 9.8;
	private static inline var GRAVITY_MULTIPLIER: Float = 70;
	private static inline var INITIAL_JUMP_FORCE: Float = 250;
	//private static inline var MIN_FALL_VELOCITY: Float = -999;
	//private static inline var MAX_FALL_VELOCITY: Float = 250;
	
	//private static inline var HERO_FRICTION: Float = 0.5;
	
	public function new () { 
		this.heroDirection = HeroDirection.NONE;
		this.isHeroRunning = false;
		this.isHeroGrounded = false;
		this.isHeroOnAir = false;
		this.didJump = false;
		this.isKinematic = false;
		
		this.heroVelocity = new Point();
		this.heroAcceleration = new Point();
		
		this.currentTile = null;
		this.collisionLayer = 0;
		
		this.jumpForce = INITIAL_JUMP_FORCE;
	}
	
	public function SetHeroDirection(direction: HeroDirection): Void {
		this.heroDirection = direction;
	}
	
	public function SetIsGrounded(isGrounded: Bool): Void {
		this.isHeroGrounded = isGrounded;
	}
	
	public function SetIsKinematic(isKinematic: Bool): Void {
		this.isKinematic = isKinematic;
	}
	
	public function SetHeroVelocity(velocity: Point): Void {
		this.heroVelocity = velocity;
	}
	
	public function HasAnyKeyDown(): Bool {
		return System.keyboard.isDown(Key.W) || System.keyboard.isDown(Key.A) ||
			System.keyboard.isDown(Key.S) || System.keyboard.isDown(Key.D) ||
			System.keyboard.isDown(Key.Left) || System.keyboard.isDown(Key.Right) ||
			System.keyboard.isDown(Key.Up) || System.keyboard.isDown(Key.Down);
	}
	
	// Only avalable when on OnAdded, OnStart and OnUpdate functions
	// owner entity must not be nulled!
	public function SetHeroFacingDirty(): Void {
		var platformHero: PlatformHero = owner.get(PlatformHero);
		if (heroDirection == HeroDirection.LEFT) {
			platformHero.scaleX._ = -Math.abs(platformHero.scaleX._);
		}
		
		if (heroDirection == HeroDirection.RIGHT) {
			platformHero.scaleX._ = Math.abs(platformHero.scaleX._);
		}
	}
	
	public function HasGap(): Bool {
		if (tileGrid == null)
			return false;
			
		if (isHeroOnAir)
			return false;
			
		var minBotTile: PlatformTile = tileGrid[minRow][minCol + 1];
		var maxBotTile: PlatformTile = tileGrid[maxRow][minCol + 1];
		
		//var checkGap: Bool = (minBotTile.GetTileDataType() == TileDataType.NONE && maxBotTile.GetTileDataType() == TileDataType.NONE) && 
			//minBotTile.tileLayer == 0 && maxBotTile.tileLayer == 0;
			
		var checkGap: Bool = minBotTile.tileLayer == 0 && maxBotTile.tileLayer == 0;
		
		var forceStop: Bool = false;
		if(row > 0 && row < (GameConstants.GRID_ROWS - 1)) {
			var prevTile: PlatformTile = tileGrid[row - 1][col + 1];
			var nextTile: PlatformTile = tileGrid[row + 1][col + 1];
			
			forceStop = checkGap && prevTile.GetTileDataType() != TileDataType.NONE && nextTile.GetTileDataType() != TileDataType.NONE;
		}
		
		return forceStop;
	}
	
	override public function onAdded() {
		super.onAdded();
		
		heroAcceleration = new Point(0, -UNIT_GRAVITY * GRAVITY_MULTIPLIER);
		SetHeroFacingDirty();
		heroDirection = HeroDirection.NONE;
	}
	
	override public function onStart() {
		super.onStart();
		
		controlDisposer = owner.get(Disposer);
		if (controlDisposer == null) {
			owner.add(controlDisposer = new Disposer());
		}
		
		var platformHero: PlatformHero = owner.get(PlatformHero);
		controlDisposer.add(platformHero.onTileChanged.connect(function(tile: PlatformTile) {
			currentTile = tile;
		}));
		
		controlDisposer.add(System.keyboard.down.connect(function(event: KeyboardEvent) {	
			if (isKinematic)
				return;
			
			if (event.key == Key.W || event.key == Key.Up) {
				if (currentTile.tileType == TileType.DOOR_OUT) {
					PlatformMain.sharedInstance.LoadNextRoom();
				}
			}
			
			if (event.key == Key.A || event.key == Key.Left) {
				heroDirection = HeroDirection.LEFT;
				SetHeroFacingDirty();
			}
			
			if (event.key == Key.D || event.key == Key.Right) {
				heroDirection = HeroDirection.RIGHT;
				SetHeroFacingDirty();
			}
			
			//if (event.key == Key.W) {
				//heroDirection = HeroDirection.UP;
			//}
			//
			//if (event.key == Key.S) {
				//heroDirection = HeroDirection.DOWN;
			//}
			
			if (event.key == Key.Space) {
				if (!isHeroGrounded)
					return;
				
				SetHeroVelocity(new Point(0, -jumpForce));
				isHeroGrounded = false;
				isHeroOnAir = true;
				didJump = true;
			}
		}));
		
		controlDisposer.add(System.keyboard.up.connect(function(event: KeyboardEvent) {
			if (isKinematic)
				return;
				
			if (!HasAnyKeyDown()) {
				heroDirection = HeroDirection.NONE;
			}
			
			if (didJump) {
				didJump = false;
			}
			
			if (event.key == Key.Space) {
				jumpForce = INITIAL_JUMP_FORCE;
			}
		}));
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		
		if (isKinematic)
			return;
			
		var platformHero: PlatformHero = owner.get(PlatformHero);
		if (platformHero == null)
			return;
		
		var platformMain: PlatformMain = platformHero.parent.get(PlatformMain);
		if (platformMain == null)
			return;
		
		row = Math.floor(platformHero.x._ / GameConstants.TILE_WIDTH);
		col = Math.floor(platformHero.y._ / GameConstants.TILE_HEIGHT);
		
		minRow = Math.floor(platformHero.colliderMin.x / GameConstants.TILE_WIDTH);
		minCol = Math.floor(platformHero.colliderMin.y / GameConstants.TILE_HEIGHT);
		
		maxRow = Math.floor(platformHero.colliderMax.x / GameConstants.TILE_WIDTH);
		maxCol = Math.floor(platformHero.colliderMax.y / GameConstants.TILE_HEIGHT);

		tileGrid = platformMain.tileGrid;
		if (tileGrid == null)
			return;
		
		isHeroRunning = false;
		isHeroGrounded = false;
		
		//heroVelocity.x *= HERO_FRICTION;
		heroVelocity.x += heroAcceleration.x * dt;
		platformHero.x._ += heroVelocity.x * dt;
		
		if (isHeroOnAir) {
			if(col > 0) {
				var topHit: Bool = tileGrid[minRow][maxCol - 1].tileLayer == collisionLayer || tileGrid[maxRow][maxCol - 1].tileLayer == collisionLayer;
				if (topHit) {
					platformHero.y._ = (col + 1) * GameConstants.TILE_HEIGHT - (GameConstants.TILE_HEIGHT / 2);
				}
			}
		}
		
		if(!didJump) {
			var bottomHit: Bool = tileGrid[minRow][minCol + 1].GetTileDataType() == TileDataType.NONE &&
				tileGrid[maxRow][minCol + 1].GetTileDataType() == TileDataType.NONE || tileGrid[minRow][minCol + 1].tileLayer == 0 && tileGrid[maxRow][minCol + 1].tileLayer == 0;
			
			// An offset to keep hero's feet on the ground
			var heroYOffset: Int = 3;
			
			// Determine if the hero is currently falling
			var isHeroFalling: Bool = heroVelocity.y >= 0;
			
			if (!bottomHit && isHeroFalling) {
				platformHero.y._ = col * GameConstants.TILE_HEIGHT + (GameConstants.TILE_HEIGHT / 2) + heroYOffset;
				heroVelocity.y = 0;
				isHeroGrounded = true;
				isHeroOnAir = false;
			}
			
			if (tileGrid[row][col + 1].GetTileDataType() != TileDataType.NONE && tileGrid[row][col + 1].tileLayer > 0) {
				collisionLayer = tileGrid[row][col + 1].tileLayer;
			}
		}
		
		if (!isHeroGrounded) {
			heroVelocity.y -= heroAcceleration.y * dt;
			//heroVelocity.y = FMath.clamp(heroVelocity.y, MIN_FALL_VELOCITY, MAX_FALL_VELOCITY);
			platformHero.y._ += heroVelocity.y * dt;
		}
			
		if (heroDirection == HeroDirection.LEFT) {
			if(maxRow > 0) {
				var leftHit: Bool = tileGrid[maxRow - 1][minCol].GetTileDataType() == TileDataType.NONE && 
					tileGrid[maxRow - 1][maxCol].GetTileDataType() == TileDataType.NONE || collisionLayer != tileGrid[maxRow - 1][col].tileLayer;
			
				if (leftHit && !HasGap()) {
					platformHero.x._ -= GameConstants.HERO_SPEED * dt;
					//heroVelocity.x = -GameConstants.HERO_SPEED;
					isHeroRunning = true;	
				}
			}
		}
		
		if (heroDirection == HeroDirection.RIGHT) {
			if (minRow < (GameConstants.GRID_ROWS - 1)) {
				
				var rightHit: Bool = (tileGrid[minRow + 1][minCol].GetTileDataType() == TileDataType.NONE && 
					tileGrid[minRow + 1][maxCol].GetTileDataType() == TileDataType.NONE) || collisionLayer != tileGrid[minRow + 1][col].tileLayer;
					
				if(rightHit && !HasGap()) {
					platformHero.x._ += GameConstants.HERO_SPEED * dt;
					//heroVelocity.x = GameConstants.HERO_SPEED;
					isHeroRunning = true;
				}
			}
		}
		
		// Clamp hero's position to prevent to overshoot
		platformHero.x._ = FMath.clamp(platformHero.x._, (GameConstants.TILE_WIDTH / 2), GameConstants.GRID_ROWS * GameConstants.TILE_WIDTH - (GameConstants.TILE_WIDTH / 2));
		platformHero.y._ = FMath.clamp(platformHero.y._, (GameConstants.TILE_HEIGHT / 2), GameConstants.GRID_COLS * GameConstants.TILE_HEIGHT - (GameConstants.TILE_HEIGHT / 2));
		
		platformHero.SetAnimationDirty(isHeroRunning);
	}
}