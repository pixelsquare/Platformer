package platformer.screen.main;

import flambe.asset.AssetPack;
import flambe.display.ImageSprite;
import flambe.display.TextSprite;
import flambe.Entity;
import flambe.input.Key;
import flambe.input.KeyboardEvent;
import flambe.subsystem.StorageSystem;
import flambe.System;
import flambe.util.Promise;
import flambe.asset.Manifest;
import platformer.main.PlatformMain;

import platformer.core.SceneManager;
import platformer.main.utils.GameConstants;
import platformer.name.AssetName;
import platformer.name.ScreenName;
import platformer.screen.GameButton;
import platformer.screen.GameScreen;
import platformer.pxlSq.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class MainScreen extends GameScreen
{
	private var gamePauseBtn: GameButton;
	private var scoreText: TextSprite;
	
	private static inline var STREAMING_ASSET_PACK: String = "streamingassets";
	
	public function new(assetPack: AssetPack, storage: StorageSystem) {		
		super(assetPack, storage);
	}
	
	override public function CreateScreen(): Entity {
		screenEntity = super.CreateScreen();
		HideTitleText();

		var background: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_BACKGROUND));
		background.centerAnchor();
		background.setXY(System.stage.width / 2, System.stage.height / 2);
		background.setScaleXY(
			(System.stage.width / background.getNaturalWidth()) / 2 + (GameConstants.GAME_WIDTH / background.getNaturalWidth()) / 2,
			(System.stage.height / background.getNaturalHeight()) / 2 + (GameConstants.GAME_HEIGHT / background.getNaturalHeight()) / 2
		);
		AddToEntity(background);
		
		var promise: Promise<AssetPack> = System.loadAssetPack(Manifest.fromAssets(STREAMING_ASSET_PACK));
		promise.get(function(streamingAsset: AssetPack) {
			var platformMain: PlatformMain = new PlatformMain(this, streamingAsset);
			screenEntity.add(platformMain);
		});
		
		//#if html
		System.keyboard.up.connect(function(event: KeyboardEvent) {
			if (event.key == Key.P) {
				SceneManager.ShowPauseScreen();
			}
			
			if (event.key == Key.G) {
				SceneManager.ShowGameOverScreen();
			}
		});
		//#end
		
		return screenEntity;
	}
	
	override public function GetScreenName(): String {
		return ScreenName.SCREEN_MAIN;
	}
}