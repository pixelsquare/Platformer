package platformer.screen.main;

import flambe.asset.AssetPack;
import flambe.display.FillSprite;
import flambe.display.ImageSprite;
import flambe.display.Texture;
import flambe.Entity;
import flambe.input.Key;
import flambe.input.KeyboardEvent;
import flambe.script.AnimateTo;
import flambe.script.Repeat;
import flambe.script.Script;
import flambe.script.Sequence;
import flambe.subsystem.StorageSystem;
import flambe.System;

import platformer.core.SceneManager;
import platformer.name.AssetName;
import platformer.name.ScreenName;
import platformer.screen.GameScreen;
import platformer.main.PlatformMain;

/**
 * ...
 * @author Anthony Ganzon
 */
class GameOverScreen extends GameScreen
{
	private static inline var DEFAULT_BG_COLOR: Int = 0xFFFFFF;
	
	public function new(gameAsset:AssetPack, gameStorage:StorageSystem) {
		super(gameAsset, gameStorage);
	}
	
	override public function createScreen():Entity {
		screenEntity = super.createScreen();
		screenTemplate.dispose();
		
		screenBackground = new FillSprite(DEFAULT_BG_COLOR, screenWidth, screenHeight);
		screenBackground.alpha.animate(0, 0.5, 0.5);
		addToEntity(screenBackground);
		
		var titleTexture: Texture = (PlatformMain.sharedInstance.didWin) ? gameAsset.getTexture(AssetName.ASSET_GAME_WIN) : gameAsset.getTexture(AssetName.ASSET_GAME_OVER);
		var title: ImageSprite = new ImageSprite(titleTexture);
		title.centerAnchor();
		title.setXY(screenWidth / 2, screenHeight * 0.3);
		addToEntity(title);
		
		var spaceToMenu: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_GAME_MENU));
		spaceToMenu.centerAnchor();
		spaceToMenu.setXY(screenWidth / 2, screenHeight * 0.7);
		addToEntity(spaceToMenu);
		
		var blinkScript: Script = new Script();
		blinkScript.run(new Repeat(new Sequence([
			new AnimateTo(spaceToMenu.alpha, 0.25, 0.5),
			new AnimateTo(spaceToMenu.alpha, 1, 0.5)
		])));
		addToEntity(blinkScript);
		
		screenDisposer.add(System.keyboard.up.connect(function(event: KeyboardEvent) {
			if (event.key == Key.Space) {
				SceneManager.unwindToCurScene();
				SceneManager.showTitleScreen();
			}
		}));
		
		return screenEntity;
	}
	
	override public function getScreenName():String {
		return ScreenName.SCREEN_GAME_OVER;
	}
}