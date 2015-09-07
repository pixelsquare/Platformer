package platformer.main.hero;

import flambe.asset.AssetPack;
import flambe.display.FillSprite;
import flambe.display.Sprite;
import flambe.Entity;
import flambe.swf.Library;
import flambe.swf.MoviePlayer;
import platformer.main.element.GameElement;
import platformer.main.PlatformerMain;
import platformer.main.utils.GameConstants;
import platformer.pxlSq.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class PlatformHero extends GameElement
{
	private var library: Library;
	private var moviePlayer: MoviePlayer;
	private var heroSprite: Sprite;
	
	public function new() {
		super();
	}
	
	override public function Init():Void {
		super.Init();
	}
	
	override public function Draw():Void {
		super.Draw();
	}
	
	override public function GetNaturalWidth():Float {
		return heroSprite.getNaturalWidth();
	}
	
	override public function GetNaturalHeight():Float {
		return heroSprite.getNaturalHeight();
	}
	
	override public function onAdded() {
		super.onAdded();
		var platformerMain: PlatformerMain = parent.get(PlatformerMain);
		var assetPack: AssetPack = platformerMain.dataManager.gameAsset;
		
		library = new Library(assetPack, "platformerassets/heroanim");
		moviePlayer = new MoviePlayer(library).loop("hero_idle");
		elementEntity.add(moviePlayer);
		elementEntity.add(heroSprite = new Sprite());
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		if (heroSprite != null) {
			heroSprite.setAlpha(alpha._);
			heroSprite.setXY(x._, y._);
			heroSprite.setScale(scale._);
			heroSprite.setScaleXY(scaleX._, scaleY._);
		}
	}
	
}