package platformer.screen.main;

import flambe.animation.Ease;
import flambe.asset.AssetPack;
import flambe.display.Font;
import flambe.display.ImageSprite;
import flambe.Entity;
import flambe.input.KeyboardEvent;
import flambe.input.PointerEvent;
import flambe.script.AnimateTo;
import flambe.script.CallFunction;
import flambe.script.Delay;
import flambe.script.Parallel;
import flambe.script.Repeat;
import flambe.script.Script;
import flambe.script.Sequence;
import flambe.subsystem.StorageSystem;
import flambe.System;
import flambe.input.Key;

import platformer.core.SceneManager;
import platformer.name.AssetName;
import platformer.name.FontName;
import platformer.name.ScreenName;
import platformer.screen.GameButton;
import platformer.main.utils.GameConstants;
import flambe.util.Promise;
import flambe.asset.Manifest;

import platformer.pxlSq.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class TitleScreen extends GameScreen
{
	private var startGameBtn: GameButton;
	
	public function new(assetPack: AssetPack, storage: StorageSystem) {		
		super(assetPack, storage);
	}
	
	override public function CreateScreen(): Entity {
		screenEntity = super.CreateScreen();
		HideTitleText();
		HideBackground();
		
		var background: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_BACKGROUND));
		background.centerAnchor();
		background.setXY(System.stage.width / 2, System.stage.height / 2);
		background.setScaleXY(
			(System.stage.width / background.getNaturalWidth()) / 2 + (GameConstants.GAME_WIDTH / background.getNaturalWidth()) / 2,
			(System.stage.height / background.getNaturalHeight()) / 2 + (GameConstants.GAME_HEIGHT / background.getNaturalHeight()) / 2
		);
		AddToEntity(background);
		
		var title: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_GAME_TITLE));
		title.centerAnchor();
		title.setXY(System.stage.width / 2, System.stage.height * 0.3);
		AddToEntity(title);
		
		var spaceToStart: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_GAME_START));
		spaceToStart.centerAnchor();
		spaceToStart.setXY(System.stage.width / 2, System.stage.height * 0.7);
		AddToEntity(spaceToStart);
		
		var blinkScript: Script = new Script();
		blinkScript.run(new Repeat(new Sequence([
			new AnimateTo(spaceToStart.alpha, 0.25, 0.5),
			new AnimateTo(spaceToStart.alpha, 1, 0.5)
		])));
		AddToEntity(blinkScript);
		
		screenDisposer.add(System.keyboard.up.connect(function(event: KeyboardEvent) {
			if (event.key == Key.Space) {
				var promise: Promise<AssetPack> = System.loadAssetPack(Manifest.fromAssets(MainScreen.STREAMING_ASSET_PACK));
				promise.get(function(streamingAsset: AssetPack) {
					Utils.ConsoleLog("Streaming Asset loaded!");
					SceneManager.ShowMainScreen();
					SceneManager.instance.gameMainScreen.InitPlatformMain(streamingAsset);
					
				});
				//SceneManager.ShowMainScreen();
				SceneManager.ShowScreen(new PreloadScreen(gameAsset, promise));
			}
		}));
		
		return screenEntity;
	}
	
	override public function GetScreenName(): String {
		return ScreenName.SCREEN_TITLE;
	}
}