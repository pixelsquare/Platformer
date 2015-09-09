package platformer.main.hero;

import flambe.asset.AssetPack;
import flambe.Component;
import flambe.display.Sprite;
import flambe.input.Key;
import flambe.input.KeyboardEvent;
import flambe.math.Point;
import flambe.System;
import flambe.math.FMath;

import platformer.main.hero.utils.HeroDirection;
import platformer.pxlSq.Utils;
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
	
	//private var didJump: Bool;
	private var jumpForce: Float;
	
	private static inline var UNIT_GRAVITY: Float = 9.8;
	private static inline var INITIAL_JUMP_FORCE: Float = 220;
	private static inline var MAX_FALL_VELOCITY: Float = 250;
	
	public function new () { 
		this.heroDirection = HeroDirection.NONE;
		this.isHeroRunning = false;
		this.isHeroGrounded = false;
		this.isHeroOnAir = false;
		
		this.heroVelocity = new Point();
		this.heroAcceleration = new Point();
		
		//this.didJump = false;
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
			System.keyboard.isDown(Key.S) || System.keyboard.isDown(Key.D);
	}
	
	public function ResetJump(): Void {
		//didJump = false;
		jumpForce = INITIAL_JUMP_FORCE;
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
		
		System.keyboard.down.connect(function(event: KeyboardEvent) {
			//if (event.key == Key.W) {
				//heroDirection = HeroDirection.UP;
			//}
			
			if (event.key == Key.A) {
				heroDirection = HeroDirection.LEFT;
			}
			
			//if (event.key == Key.S) {
				//heroDirection = HeroDirection.DOWN;
			//}
			
			if (event.key == Key.D) {
				heroDirection = HeroDirection.RIGHT;
			}
			
			if (event.key == Key.Space) {
				if (!isHeroGrounded)
					return;
				
				//didJump = true;
				SetHeroVelocity(new Point(0, -jumpForce));
				isHeroGrounded = false;
				isHeroOnAir = true;
			}
		});
		
		System.keyboard.up.connect(function(event: KeyboardEvent) {
			if (!HasAnyKeyDown()) {
				heroDirection = HeroDirection.NONE;
			}
			
			if (event.key == Key.Space) {
				ResetJump();
			}
		});
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		
		var platformHero: PlatformHero = owner.get(PlatformHero);

		isHeroRunning = false;
		isHeroGrounded = false;
		
		//if (didJump) {
			//jumpForce += 20;
			//SetHeroVelocity(new Point(0, -jumpForce));
			//
			//if (jumpForce >= 200) {
				//ResetJump();
			//}
		//}
		
		// TODO: Limit velocity of free falling hero
		if (!isHeroGrounded) {
			heroVelocity.y -= heroAcceleration.y;
			heroVelocity.y = FMath.clamp(heroVelocity.y, -999, MAX_FALL_VELOCITY);
			platformHero.y._ += heroVelocity.y * dt;
			isHeroOnAir = true;
		}
		
		if (heroDirection == HeroDirection.LEFT) {
			platformHero.x._ -= GameConstants.HERO_SPEED * dt;
			SetHeroFacingDirty();
			isHeroRunning = true;
		}
		
		if (heroDirection == HeroDirection.RIGHT) {
			platformHero.x._ += GameConstants.HERO_SPEED * dt;
			SetHeroFacingDirty();
			isHeroRunning = true;
		}
		
		if (heroDirection == HeroDirection.UP) {
			platformHero.y._ -= GameConstants.HERO_SPEED * dt;
		}
		
		if (heroDirection == HeroDirection.DOWN) {
			platformHero.y._ += GameConstants.HERO_SPEED * dt;
		}
		
		platformHero.SetAnimationDirty(isHeroRunning);
	}
}