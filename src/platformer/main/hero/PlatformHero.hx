package platformer.main.hero;

import flambe.asset.AssetPack;
import flambe.display.Sprite;
import flambe.swf.Library;
import flambe.swf.MoviePlayer;

import platformer.main.element.GameElement;
import platformer.main.utils.GameConstants;
import platformer.main.utils.IGrid;

/**
 * ...
 * @author Anthony Ganzon
 */
class PlatformHero extends GameElement implements IGrid
{
	public var idx(default, null): Int;
	public var idy(default, null): Int;
	
	private var heroSprite: Sprite;
	private var heroLibrary: Library;
	private var heroMoviePlayer: MoviePlayer;
	
	private var gameAsset: AssetPack;
	
	private static inline var HERO_ANIM_IDLE: String = "hero_idle";
	private static inline var HERO_ANIM_RUN: String = "hero_dash";
	private static inline var HERO_ANIM_PATH: String = "platformerassets/heroanim";
	
	public function new(gameAsset: AssetPack) {
		this.gameAsset = gameAsset;
		super();
	}
	
	public function UpdateGridPosition(): Void {
		var tileIdx: Int = Std.int(Math.floor(heroSprite.x._ / GameConstants.TILE_WIDTH));
		var tileIdy: Int = Std.int(Math.floor(heroSprite.y._ / GameConstants.TILE_HEIGHT));
		SetGridID(tileIdx, tileIdy);
	}
	
	public function SetAnimationDirty(isRunning: Bool): Void {
		if(heroMoviePlayer.looping) {
			heroMoviePlayer.loop(isRunning ? HERO_ANIM_RUN : HERO_ANIM_IDLE, false);
		}
	}
	
	override public function Init(): Void {
		super.Init();
		
		heroLibrary = new Library(gameAsset, HERO_ANIM_PATH);
		heroMoviePlayer = new MoviePlayer(heroLibrary);
		heroMoviePlayer.loop(HERO_ANIM_IDLE);
		
		heroSprite = new Sprite();
		heroSprite.centerAnchor();
	}
	
	override public function Draw(): Void {
		super.Draw();
		
		elementEntity.add(heroMoviePlayer);
		elementEntity.add(heroSprite);
	}
	
	override public function GetNaturalWidth():Float {
		return heroSprite.getNaturalWidth();
	}
	
	override public function GetNaturalHeight():Float {
		return heroSprite.getNaturalHeight();
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		
		if (heroSprite != null) {
			heroSprite.setAlpha(alpha._);
			heroSprite.setXY(x._, y._);
			heroSprite.setScale(scale._);
			heroSprite.setScaleXY(scaleX._, scaleY._);
			
			UpdateGridPosition();
		}
	}
	
	/* INTERFACE platformer.main.utils.IGrid */
	
	public function SetGridID(idx:Int, idy:Int, updatePosition:Bool = false): Void {
		this.idx = idx;
		this.idy = idy;
	}
	
	public function GridIDToString(): String {
		return "Grid [" + this.idx + "," + this.idy + "]";
	}
}