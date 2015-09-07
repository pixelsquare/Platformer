package platformer.screen.main;

import flambe.asset.AssetPack;
import flambe.display.Font;
import flambe.display.ImageSprite;
import flambe.display.Sprite;
import flambe.display.TextSprite;
import flambe.display.Texture;
import flambe.Entity;
import flambe.input.Key;
import flambe.input.KeyboardEvent;
import flambe.subsystem.StorageSystem;
import flambe.swf.Library;
import flambe.swf.MoviePlayer;
import flambe.swf.MovieSprite;
import flambe.swf.MovieSymbol.MovieKeyframe;
import flambe.System;
import platformer.main.PlatformerMain;
import platformer.main.utils.GameConstants;

import platformer.core.SceneManager;
import platformer.name.AssetName;
import platformer.name.FontName;
import platformer.name.ScreenName;
import platformer.pxlSq.Utils;
import platformer.screen.GameButton;
import platformer.screen.GameScreen;

/**
 * ...
 * @author Anthony Ganzon
 */
class MainScreen extends GameScreen
{
	private var gamePauseBtn: GameButton;
	private var scoreText: TextSprite;
	
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
	
		//var lib = new Library(gameAsset, "PlatformerAssets/monster");
		//var movieEntity: Entity = new Entity();
		//var moviePlayer: MoviePlayer = new MoviePlayer(lib).loop("idle");
		//movieEntity.add(moviePlayer);
		//movieEntity.add(new Sprite().setXY(System.stage.width / 2, System.stage.height / 2));
		//screenEntity.addChild(movieEntity);
		
		//var lib = new Library(gameAsset, "PlatformerAssets/heroAnim");
		//var movieEntity: Entity = new Entity();
		//var moviePlayer: MoviePlayer = new MoviePlayer(lib).loop("hero_dash");
		//movieEntity.add(moviePlayer);
		//movieEntity.add(new Sprite().setXY(System.stage.width / 2, System.stage.height / 2));
		//screenEntity.addChild(movieEntity);
		
		//var lib1 = new Library(gameAsset, "PlatformerAssets/heroAnim");
		//var movieEntity1: Entity = new Entity();
		//var moviePlayer1: MoviePlayer = new MoviePlayer(lib).loop("hero_idle");
		//movieEntity1.add(moviePlayer1);
		//movieEntity1.add(new Sprite().setXY(System.stage.width * 0.4, System.stage.height / 2));
		//screenEntity.addChild(movieEntity1);
		
		//var image: Texture = gameAsset.getTexture(AssetName.ASSET_TILES).subTexture(240, 81, 40, 40);
		//var imageSprite: ImageSprite = new ImageSprite(image);
		//imageSprite.centerAnchor();
		//imageSprite.setXY(System.stage.width / 2, System.stage.height / 2);
		//AddToEntity(imageSprite);
		
		var platformMain: PlatformerMain = new PlatformerMain(this);
		AddToEntity(platformMain);
		
		//#if html
		System.keyboard.up.connect(function(event: KeyboardEvent) {
			if (event.key == Key.P) {
				SceneManager.ShowPauseScreen();
			}
			
			if (event.key == Key.G) {
				SceneManager.ShowGameOverScreen();
			}
			
			if (event.key == Key.Space) {
				trace("Hello World!");
			}
		});
		//#end
		
		return screenEntity;
	}
	
	override public function GetScreenName(): String {
		return ScreenName.SCREEN_MAIN;
	}
}