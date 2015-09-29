package platformer.screen.main;

import flambe.asset.AssetPack;
import flambe.display.ImageSprite;
import flambe.Entity;
import flambe.input.Key;
import flambe.input.KeyboardEvent;
import flambe.subsystem.StorageSystem;
import flambe.System;
import platformer.main.PlatformMain;

import platformer.core.SceneManager;
import platformer.main.utils.GameConstants;
import platformer.name.AssetName;
import platformer.name.ScreenName;
import platformer.screen.GameScreen;
import flambe.util.Promise;
import flambe.asset.Manifest;

import platformer.pxlsq.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class MainScreen extends GameScreen
{
	private static inline var STREAMING_ASSETS_PACK: String = "streamingassets";
	
	public var platformMain(default, null): PlatformMain;
	
	public function new(gameAsset:AssetPack, gameStorage:StorageSystem) {
		super(gameAsset, gameStorage);
	}
	
	public function initPlatformMain() {
		var promise: Promise<AssetPack> = System.loadAssetPack(Manifest.fromAssets(STREAMING_ASSETS_PACK));
		promise.get(function(streamingAssetsPack: AssetPack) {
			Utils.consoleLog("Streaming asset loaded!");
			SceneManager.showMainScreen();
			
			platformMain = new PlatformMain(gameAsset, streamingAssetsPack);
			addToEntity(platformMain);
		});
		
		SceneManager.showScreen(new PreloadScreen(gameAsset, promise));
	}
	
	override public function createScreen():Entity {
		screenEntity = super.createScreen();
		screenTemplate.dispose();
		
		var background: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_BACKGROUND));
		background.centerAnchor();
		background.setXY(screenWidth / 2, screenHeight / 2);
		background.setScaleXY(
			screenWidth / background.getNaturalWidth()  / 2 + GameConstants.GAME_WIDTH / background.getNaturalWidth() / 2,
			screenHeight / background.getNaturalHeight() / 2 + GameConstants.GAME_HEIGHT / background.getNaturalHeight() / 2
		);
		addToEntity(background);
		
		#if debug
		screenDisposer.add(System.keyboard.up.connect(function(event: KeyboardEvent) {
			if (event.key == Key.P) {
				SceneManager.showControlsScreen();
			}
			
			if (event.key == Key.G) {
				SceneManager.showGameOverScreen();
			}
		}));
		#end
		
		return screenEntity;
	}
	
	override public function getScreenName():String {
		return ScreenName.SCREEN_MAIN;
	}
}