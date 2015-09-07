package platformer.screen;

import flambe.asset.AssetPack;
import flambe.display.FillSprite;
import flambe.display.Font;
import flambe.display.TextSprite;
import flambe.Entity;
import flambe.System;
import flambe.util.Promise;

import platformer.name.FontName;
import platformer.name.ScreenName;
import platformer.pxlSq.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class PreloadScreen extends GameScreen
{
	private var promise: Promise<Dynamic>;
	
	private static inline var BACKGROUND_COLOR: Int = 0x202020;
	private static inline var LOADING_BAR_COLOR: Int = 0xFFFFFF;
	
	public function new(preloadPack: AssetPack, promise: Promise<Dynamic>) {
		super(preloadPack, null);
		
		this.promise = promise;
	}
	
	override public function CreateScreen(): Entity {
		screenEntity = super.CreateScreen();
		screenBackground.color = 0x202020;
		HideTitleText();
		
		var loadingEntity: Entity = new Entity();
		var loadingFont: Font = new Font(gameAsset, FontName.FONT_VANADINE_32);
		var loadingText: TextSprite = new TextSprite(loadingFont, "LOADING | ");
		loadingText.centerAnchor();
		loadingText.setXY(System.stage.width / 2, (System.stage.height * 0.5) - (loadingText.getNaturalHeight() / 2));
		loadingEntity.addChild(new Entity().add(loadingText));
		
		var padding: Int = 100;
		var progressWidth: Float = System.stage.width - (padding * 2);
		
		var loadingBarEntity: Entity = new Entity();
		var loadingBarBG: FillSprite = new FillSprite(LOADING_BAR_COLOR, progressWidth, 33);
		loadingBarBG.centerAnchor();
		loadingBarBG.setXY(System.stage.width / 2, (System.stage.height * 0.5) + (loadingBarBG.getNaturalHeight() / 2));
		loadingBarEntity.addChild(new Entity().add(loadingBarBG));
		
		var loadingBG: FillSprite = new FillSprite(BACKGROUND_COLOR, loadingBarBG.width._ * 0.98, 30);
		loadingBG.centerAnchor();
		loadingBG.setXY(loadingBarBG.x._, loadingBarBG.y._);
		loadingBarEntity.addChild(new Entity().add(loadingBG));
		
		var loadingBar: FillSprite = new FillSprite(LOADING_BAR_COLOR, 0, 10);
		loadingBar.setXY(
			(System.stage.width / 2) - (loadingBG.width._ * 0.475), 
			loadingBG.y._ - (loadingBar.getNaturalHeight() / 2)
		);
		loadingBarEntity.addChild(new Entity().add(loadingBar));
		
		screenEntity.addChild(loadingEntity.addChild(loadingBarEntity));
		
		// Set maximum width relative to loading bg
		progressWidth = loadingBG.width._ * 0.95;
		
		promise.progressChanged.connect(function() {
			var percentage: Float = promise.progress / promise.total;
			loadingBar.width._ = percentage * progressWidth;
			loadingText.text = "LOADING | " + Std.int(percentage * 100) + "%";
			loadingText.centerAnchor();
			loadingText.setXY(System.stage.width / 2, System.stage.height * 0.45);
		});
		
		return screenEntity;
	}
	
	override public function GetScreenName(): String {
		return ScreenName.SCREEN_PRELOAD;
	}
}