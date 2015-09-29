package platformer.screen;

import flambe.asset.AssetPack;
import flambe.display.Font;
import flambe.display.ImageSprite;
import flambe.display.PatternSprite;
import flambe.display.TextSprite;
import flambe.Entity;
import flambe.util.Promise;

import platformer.name.AssetName;
import platformer.name.FontName;
import platformer.name.ScreenName;

/**
 * ...
 * @author Anthony Ganzon
 */
class PreloadScreen extends GameScreen
{
	private var preloadPromise: Promise<Dynamic>;
	
	private var loadingBarText: TextSprite;
	private var loadingBarPadding: Int = 50;
	private var loadingBarProgress: Float = 0.0;
	
	private static inline var LOADING_TEXT: String = "LOADING | ";
	
	public function new(gameAsset:AssetPack, promise: Promise<Dynamic>) {
		super(gameAsset, null);
		preloadPromise = promise;
	}
	
	/* Keeps the loading text in the center of the stage */
	public function setloadingTextDirty(): Void {
		loadingBarText.text = LOADING_TEXT + Std.int(loadingBarProgress * 100) + "%";
		loadingBarText.centerAnchor();
		loadingBarText.setXY(screenWidth / 2, screenHeight * 0.45);
	}
	
	override public function createScreen():Entity {
		screenEntity = super.createScreen();
		screenTitleText.dispose();
		
		loadingBarText = new TextSprite(new Font(gameAsset, FontName.FONT_VANADINE_32), LOADING_TEXT + Std.int(loadingBarProgress * 100) + "%");
		loadingBarText.centerAnchor();
		loadingBarText.setXY(screenWidth / 2, screenHeight * 0.45);
		addToEntity(loadingBarText);
		
		var progressLeft: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.PROGRESS_LEFT));
		var progressRight: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.PROGRESS_RIGHT));
		
		var totalWidth: Float = screenWidth - progressLeft.texture.width - progressRight.texture.width - 2 * loadingBarPadding;
		var yOffset: Float = screenHeight / 2 - progressLeft.texture.height / 2;

		progressLeft.setXY(loadingBarPadding, yOffset);
		addToEntity(progressLeft);
		
		var progressBG: PatternSprite = new PatternSprite(gameAsset.getTexture(AssetName.PROGRESS_BG), totalWidth);
		progressBG.setXY(progressLeft.x._ + progressLeft.texture.width, yOffset);
		addToEntity(progressBG);
		
		var progressFill: PatternSprite = new PatternSprite(gameAsset.getTexture(AssetName.PROGRESS_FILL));
		progressFill.setXY(progressBG.x._, yOffset);
		
		preloadPromise.progressChanged.connect(function() {
			loadingBarProgress = preloadPromise.progress / preloadPromise.total;
			progressFill.width._ = loadingBarProgress * totalWidth;
			setloadingTextDirty();
		});
		addToEntity(progressFill);
		
		progressRight.setXY(progressFill.x._ + totalWidth, yOffset);
		addToEntity(progressRight);
		
		return screenEntity;
	}
	
	override public function getScreenName():String {
		return ScreenName.SCREEN_PRELOAD;
	}
}