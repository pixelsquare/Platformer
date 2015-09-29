package platformer.screen;

import flambe.asset.AssetPack;
import flambe.display.FillSprite;
import flambe.display.Font;
import flambe.display.ImageSprite;
import flambe.display.TextSprite;
import flambe.Entity;
import flambe.script.CallFunction;
import flambe.script.Delay;
import flambe.script.Script;
import flambe.script.Sequence;

import platformer.core.SceneManager;
import platformer.name.AssetName;
import platformer.name.FontName;
import platformer.name.ScreenName;

/**
 * ...
 * @author Anthony Ganzon
 */
class SplashScreen extends GameScreen
{
	private var splashDuration: Int = 2;
	
	private static inline var SPLASH_BG_COLOR: Int = 0x000000;
	
	public function new(gameAsset:AssetPack, duration: Int = 2) {
		super(gameAsset, null);
	}
	
	override public function createScreen():Entity {
		screenEntity = super.createScreen();
		screenTemplate.dispose();
		
		screenBackground = new FillSprite(SPLASH_BG_COLOR, screenWidth, screenHeight);
		addToEntity(screenBackground);
		
		var splashImage: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.LOGO_PXLSQR));
		splashImage.centerAnchor();
		splashImage.setXY(screenWidth / 2, screenHeight / 2);
		addToEntity(splashImage);
		
		var logoText: TextSprite = new TextSprite(new Font(gameAsset, FontName.FONT_VANADINE_32), "PIXEL SQUARE");
		logoText.centerAnchor();
		logoText.setXY(screenWidth / 2, splashImage.y._ + (splashImage.getNaturalHeight() / 2) + logoText.getNaturalHeight());
		addToEntity(logoText);
		
		var splashScript: Script = new Script();
		splashScript.run(new Sequence([
			new Delay(splashDuration),
			new CallFunction(function() {
				SceneManager.showTitleScreen(true, function() {
					gameAsset.dispose();
				});
				removeAndDispose(splashScript);
			})
		]));
		addToEntity(splashScript);
		
		return screenEntity;
	}
	
	override public function getScreenName():String {
		return ScreenName.SCREEN_SPLASH;
	}
}