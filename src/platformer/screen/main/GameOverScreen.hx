package platformer.screen.main;

import flambe.animation.Ease;
import flambe.asset.AssetPack;
import flambe.display.Font;
import flambe.display.ImageSprite;
import flambe.display.Sprite;
import flambe.display.TextSprite;
import flambe.display.Texture;
import flambe.Entity;
import flambe.input.KeyboardEvent;
import flambe.math.Rectangle;
import flambe.subsystem.StorageSystem;
import flambe.System;
import flambe.input.Key;
import platformer.main.PlatformMain;

import platformer.core.SceneManager;
import platformer.main.utils.GameConstants;
import platformer.name.AssetName;
import platformer.name.FontName;
import platformer.name.ScreenName;
import platformer.screen.GameScreen;
import platformer.pxlSq.Utils;

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
		screenBackground.color = 0xFFFFFF;
		screenBackground.alpha.animate(0, 0.5, 0.5);
		HideTitleText();
		//HideBackground();
		
		var platformMain: PlatformMain = SceneManager.instance.gameDirector.topScene.get(PlatformMain);
		if (platformMain != null) {
			var titleTexture: Texture = (platformMain.didWin) ? gameAsset.getTexture(AssetName.ASSET_GAME_WIN) : gameAsset.getTexture(AssetName.ASSET_GAME_OVER);
			var title: ImageSprite = new ImageSprite(titleTexture);
			title.centerAnchor();
			title.setXY(System.stage.width / 2, System.stage.height * 0.3);
			AddToEntity(title);
		}
		
		var spaceToMenu: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_GAME_MENU));
		spaceToMenu.centerAnchor();
		spaceToMenu.setXY(System.stage.width / 2, System.stage.height * 0.7);
		AddToEntity(spaceToMenu);
		
		
		screenDisposer.add(System.keyboard.up.connect(function(event: KeyboardEvent) {
			if (event.key == Key.Space) {
				SceneManager.UnwindToCurScene();
				SceneManager.ShowTitleScreen();
			}
		}));
		
		return screenEntity;
	}
	
	override public function GetScreenName(): String {
		return ScreenName.SCREEN_GAME_OVER;
	}
}