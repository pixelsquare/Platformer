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
	
	private var heroVelocity: Point;
	private var heroAcceleration: Point;
	
	private var currentTile: PlatformTile;
	
	private var jumpForce: Float;
	private var controlDisposer: Disposer;
	
	private static inline var UNIT_GRAVITY: Float = 9.8;
	private static inline var INITIAL_JUMP_FORCE: Float = 220;
	private static inline var MIN_FALL_VELOCITY: Float = -999;
	private static inline var MAX_FALL_VELOCITY: Float = 250;
	
	public function new () { 
		this.heroDirection = HeroDirection.NONE;
		this.isHeroRunning = false;
		this.isHeroGrounded = false;
		this.isHeroOnAir = false;
		
		this.heroVelocity = new Point();
		this.heroAcceleration = new Point();
		
		this.currentTile = null;
		
		this.jumpForce = INITIAL_JUMP_FORCE;
	}
	
	public function SetHeroDirection(direction: HeroDirection): Void {
		this.heroDirection = direction;
	}
	
	public function SetIsGrounded(isGrounded: Bool): Void {
		this.isHeroGrounded = isGrounded;
		this.isHeroOnAir = !isGrounded;
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
	
	override public function onAdded() {
		super.onAdded();
		
		heroAcceleration = new Point(0, -UNIT_GRAVITY);
		SetHeroFacingDirty();
		heroDirection = HeroDirection.NONE;
	}
	
	override public function onStart() {
		super.onStart();
		
		controlDisposer = owner.get(Disposer);
		if (controlDisposer == null) {
			owner.add(controlDisposer = new Disposer());
		}
		
		var platformCollision: PlatformHeroCollision = owner.get(PlatformHeroCollision);
		controlDisposer.add(platformCollision.onTileChanged.connect(function(tile: PlatformTile) {
			currentTile = tile;
		}));
		
		controlDisposer.add(System.keyboard.down.connect(function(event: KeyboardEvent) {	
			if (!PlatformMain.sharedInstance.canMove)
				return;
			
			if (event.key == Key.W || event.key == Key.Up) {
				if (currentTile.tileType == TileType.DOOR_OUT) {
					PlatformMain.sharedInstance.LoadNextRoom();
				}
			}
			
			if (event.key == Key.A || event.key == Key.Left) {
				heroDirection = HeroDirection.LEFT;
			}
			
			if (event.key == Key.D || event.key == Key.Right) {
				heroDirection = HeroDirection.RIGHT;
			}
			
			if (event.key == Key.Space) {
				if (!isHeroGrounded)
					return;
				
				SetHeroVelocity(new Point(0, -jumpForce));
				isHeroGrounded = false;
				isHeroOnAir = true;
			}
		}));
		
		controlDisposer.add(System.keyboard.up.connect(function(event: KeyboardEvent) {
			if (!PlatformMain.sharedInstance.canMove)
				return;
				
			if (!HasAnyKeyDown()) {
				heroDirection = HeroDirection.NONE;
			}
			
			if (event.key == Key.Space) {
				jumpForce = INITIAL_JUMP_FORCE;
			}
		}));
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		
		var platformHero: PlatformHero = owner.get(PlatformHero);

		isHeroRunning = false;
		isHeroGrounded = false;
		
		if (heroDirection == HeroDirection.LEFT) {
			//platformHero.x._ -= GameConstants.HERO_SPEED * dt;
			heroVelocity.x = -GameConstants.HERO_SPEED;
			SetHeroFacingDirty();
			isHeroRunning = true;
		}
		
		if (heroDirection == HeroDirection.RIGHT) {
			//platformHero.x._ += GameConstants.HERO_SPEED * dt;
			heroVelocity.x = GameConstants.HERO_SPEED;
			SetHeroFacingDirty();
			isHeroRunning = true;
		}
		
		heroVelocity.x += heroAcceleration.x;
		platformHero.x._ += heroVelocity.x * dt;
		
		if (!isHeroGrounded) {
			heroVelocity.y -= heroAcceleration.y;
			heroVelocity.y = FMath.clamp(heroVelocity.y, MIN_FALL_VELOCITY, MAX_FALL_VELOCITY);
			platformHero.y._ += heroVelocity.y * dt;
			isHeroOnAir = true;
		}
		
		platformHero.SetAnimationDirty(isHeroRunning);
	}
}