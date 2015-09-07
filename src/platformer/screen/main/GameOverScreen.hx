package platformer.screen.main;

import flambe.animation.Ease;
import flambe.asset.AssetPack;
import flambe.display.Font;
import flambe.display.ImageSprite;
import flambe.display.Sprite;
import flambe.display.TextSprite;
import flambe.Entity;
import flambe.input.KeyboardEvent;
import flambe.math.Rectangle;
import flambe.subsystem.StorageSystem;
import flambe.System;
import flambe.input.Key;

import platformer.core.SceneManager;
import platformer.main.utils.GameConstants;
import platformer.name.AssetName;
import platformer.name.FontName;
import platformer.name.ScreenName;
import platformer.screen.GameScreen;

/**
 * ...
 * @author Anthony Ganzon
 */
class GameOverScreen extends GameScreen
{
	public function new(assetPack: AssetPack, storage: StorageSystem) {		
		super(assetPack, storage);
	}
	
	override public function CreateScreen():Entity {
		screenEntity = super.CreateScreen();
		//screenBackground.color = 0x000000;
		//screenBackground.alpha._ = 0.5;
		HideTitleText();
		HideBackground();
		
		var title: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_GAME_WIN));
		title.centerAnchor();
		title.setXY(System.stage.width / 2, System.stage.height * 0.3);
		AddToEntity(title);
		
		var spaceToMenu: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_GAME_MENU));
		spaceToMenu.centerAnchor();
		spaceToMenu.setXY(System.stage.width / 2, System.stage.height * 0.7);
		AddToEntity(spaceToMenu);
		
		
		System.keyboard.up.connect(function(event: KeyboardEvent) {
			if (event.key == Key.Space) {
				SceneManager.ShowTitleScreen(true);
			}
		});
		
		return screenEntity;
	}
	
	override public function GetScreenName(): String {
		return ScreenName.SCREEN_GAME_OVER;
	}
}