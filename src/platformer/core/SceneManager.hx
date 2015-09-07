package platformer.core;

import flambe.animation.Ease;
import flambe.asset.AssetPack;
import flambe.Entity;
import flambe.scene.Director;
import flambe.scene.FadeTransition;
import flambe.subsystem.StorageSystem;
import platformer.pxlSq.Utils;

import platformer.screen.GameScreen;
import platformer.screen.main.GameOverScreen;
import platformer.screen.main.MainScreen;
import platformer.screen.main.PauseScreen;
import platformer.screen.main.TitleScreen;

/**
 * ...
 * @author Anthony Ganzon
 */
class SceneManager
{
	public var gameTitleScreen(default, null): TitleScreen;
	public var gameMainScreen(default, null): MainScreen;
	public var gamePauseScreen(default, null): PauseScreen;
	public var gameOverScreen(default, null): GameOverScreen;
	
	private var gameScreenList: Array<GameScreen>;
	private var gameDirector: Director;
	
	public static var instance(default, null): SceneManager;
	public static var curSceneEntity(default, null): Entity;
	
	private static inline var DURATION_SHORT: Float = 0.5;
	private static inline var DURATION_LONG: Int = 1;
	
	public static inline var TARGET_WIDTH: 	Int = 640;
	public static inline var TARGET_HEIGHT: Int = 800;
	
	public function new(director: Director) 
	{
		instance = this;
		gameDirector = director;
	}
	
	public function InitScreens(assetPack: AssetPack, storage: StorageSystem): Void {
		AddGameScreen(gameTitleScreen = new TitleScreen(assetPack, storage));
		AddGameScreen(gameMainScreen = new MainScreen(assetPack, storage));
		AddGameScreen(gamePauseScreen = new PauseScreen(assetPack, storage));
		AddGameScreen(gameOverScreen = new GameOverScreen(assetPack, storage));
	}
	
	private function AddGameScreen(screen: GameScreen) : Void {
		if (gameScreenList == null) {
			gameScreenList = new Array<GameScreen>();
		}
		
		gameScreenList.push(screen);
	}
	
	public static function UnwindToCurScene(): Void {
		instance.gameDirector.unwindToScene(curSceneEntity);
	}
	
	public static function UnwindToScene(scene: Entity): Void {
		instance.gameDirector.unwindToScene(scene);
	}
	
	public static function ShowScreen(gameScreen: GameScreen, willAnimate: Bool = false): Void {
		Utils.ConsoleLog("SHOW SCREEN [" + gameScreen.GetScreenName() + "]");
		instance.gameDirector.unwindToScene(gameScreen.CreateScreen(),
			willAnimate ? new FadeTransition(DURATION_SHORT, Ease.linear) : null);
		curSceneEntity = gameScreen.screenEntity;
	}
	
	public static function ShowTitleScreen(willAnimate: Bool = false): Void {
		Utils.ConsoleLog("SHOWING [" + instance.gameTitleScreen.GetScreenName() + "]");
		instance.gameDirector.unwindToScene(instance.gameTitleScreen.CreateScreen(),
			willAnimate ? new FadeTransition(DURATION_SHORT, Ease.linear) : null);
		curSceneEntity = instance.gameTitleScreen.screenEntity;
	}
	
	public static function ShowMainScreen(willAnimate: Bool = false): Void {
		Utils.ConsoleLog("SHOWING [" + instance.gameMainScreen.GetScreenName() + "]");
		instance.gameDirector.unwindToScene(instance.gameMainScreen.CreateScreen(),
			willAnimate ? new FadeTransition(DURATION_SHORT, Ease.linear) : null);
		curSceneEntity = instance.gameMainScreen.screenEntity;
	}
	
	public static function ShowPauseScreen(willAnimate: Bool = false): Void {	
		Utils.ConsoleLog("SHOWING [" + instance.gamePauseScreen.GetScreenName() + "]");
		UnwindToCurScene();
		instance.gameDirector.pushScene(instance.gamePauseScreen.CreateScreen());
	}
	
	public static function ShowGameOverScreen(willAnimate: Bool = false) : Void {
		Utils.ConsoleLog("SHOWING [" + instance.gameOverScreen.GetScreenName() + "]");
		UnwindToCurScene();
		instance.gameDirector.pushScene(instance.gameOverScreen.CreateScreen());
	}
}