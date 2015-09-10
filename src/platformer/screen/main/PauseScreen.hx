package platformer.screen.main;

import flambe.asset.AssetPack;
import flambe.Entity;

import flambe.subsystem.StorageSystem;
import platformer.name.ScreenName;
import platformer.screen.GameScreen;

/**
 * ...
 * @author Anthony Ganzon
 */
class PauseScreen extends GameScreen
{
	public function new(assetPack: AssetPack, storage: StorageSystem) {		
		super(assetPack, storage);
	}
	
	override public function CreateScreen():Entity {
		screenEntity = super.CreateScreen();
		screenBackground.alpha._ = 0.5;
		//HideTitleText();
		
		return screenEntity;
	}
	
	override public function GetScreenName():String {
		return ScreenName.SCREEN_PAUSE;
	}	
}