package platformer.screen.main;

import flambe.asset.AssetPack;
import flambe.display.ImageSprite;
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
import platformer.main.utils.GameConstants;
import platformer.name.AssetName;
import platformer.name.ScreenName;
import platformer.screen.GameScreen;

/**
 * ...
 * @author Anthony Ganzon
 */
class TitleScreen extends GameScreen
{	
	public function new(gameAsset:AssetPack, gameStorage:StorageSystem) {
		super(gameAsset, gameStorage);
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
		
		var title: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_GAME_TITLE));
		title.centerAnchor();
		title.setXY(screenWidth / 2, screenHeight * 0.3);
		addToEntity(title);
		
		var spaceToStart: ImageSprite = new ImageSprite(gameAsset.getTexture(AssetName.ASSET_GAME_START));
		spaceToStart.centerAnchor();
		spaceToStart.setXY(screenWidth / 2, screenHeight * 0.7);
		addToEntity(spaceToStart);
		
		var blinkScript: Script = new Script();
		blinkScript.run(new Repeat(new Sequence([
			new AnimateTo(spaceToStart.alpha, 0.25, 0.5),
			new AnimateTo(spaceToStart.alpha, 1, 0.5)
		])));
		addToEntity(blinkScript);
		
		screenDisposer.add(System.keyboard.up.connect(function(event: KeyboardEvent) {
			if (event.key == Key.Space) {
				SceneManager.getMainScreen().initPlatformMain();
			}
		}));
		
		return screenEntity;
	}
	
	override public function getScreenName():String {
		return ScreenName.SCREEN_TITLE;
	}
}