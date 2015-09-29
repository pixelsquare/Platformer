package platformer.main.hero;

import flambe.animation.AnimatedFloat;
import flambe.asset.AssetPack;
import flambe.display.Sprite;
import flambe.swf.Library;
import flambe.swf.MoviePlayer;

import platformer.main.element.GameCollider;

/**
 * ...
 * @author Anthony Ganzon
 */
class PlatformHero extends GameCollider
{
	public var width(default, null): AnimatedFloat;
	public var height(default, null): AnimatedFloat;
	
	private var heroSprite: Sprite;
	private var heroLibrary: Library;
	private var heroMovPlayer: MoviePlayer;
	
	private var gameAsset: AssetPack;
	
	private static inline var HERO_ANIM_IDLE: String = "hero_idle";
	private static inline var HERO_ANIM_RUN: String = "hero_dash";
	private static inline var HERO_ANIM_PATH: String = "platformerassets/heroanim";
	
	public function new(assets: AssetPack) {
		super();
		
		gameAsset = assets;
		
		width = new AnimatedFloat(0);
		height = new AnimatedFloat(0);
	}
	
	override public function init():Void {
		super.init();
		
		heroLibrary = new Library(gameAsset, HERO_ANIM_PATH);
		heroMovPlayer = new MoviePlayer(heroLibrary);
		heroMovPlayer.loop(HERO_ANIM_IDLE);
		
		heroSprite = new Sprite();
		//heroSprite.centerAnchor();
	}
	
	override public function draw():Void {
		super.draw();
		
		elementEntity.add(heroMovPlayer);
		elementEntity.add(heroSprite);
	}
	
	override public function getNaturalWidth():Float {
		return width._;
	}
	
	override public function getNaturalHeight():Float {
		return height._;
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		
		if (heroSprite != null) {
			heroSprite.setAlpha(alpha._);
			heroSprite.setXY(x._, y._);
			heroSprite.setScale(scale._);
			heroSprite.setScaleXY(scaleX._, scaleY._);
			heroSprite.setRotation(rotation._);
		}
	}
	
	override public function dispose() {
		super.dispose();
		
		if(heroSprite != null)
			heroSprite.dispose();
			
		if(heroMovPlayer != null)
			heroMovPlayer.dispose();
	}
	
	public function setSize(width: Float, height: Float): Void {
		this.width._ = width;
		this.height._ = height;
	}
	
	public function setAnimationDirty(isRunning: Bool): Void {
		if (!heroMovPlayer.looping)
			return;
		
		heroMovPlayer.loop(isRunning ? HERO_ANIM_RUN : HERO_ANIM_IDLE, false);
	}
	
	public function setDeathPose(): Void {
		if (!heroMovPlayer.looping)
			return;
		
		heroMovPlayer.loop(HERO_ANIM_IDLE, false);
	}
}