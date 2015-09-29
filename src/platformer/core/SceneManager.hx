package platformer.core;

import flambe.animation.Ease;
import flambe.asset.AssetPack;
import flambe.Entity;
import flambe.scene.Director;
import flambe.scene.FadeTransition;
import flambe.scene.Transition;
import flambe.subsystem.StorageSystem;

import platformer.pxlsq.Utils;
import platformer.screen.GameScreen;
import platformer.screen.main.ControlsScreen;
import platformer.screen.main.GameOverScreen;
import platformer.screen.main.MainScreen;
import platformer.screen.main.TitleScreen;

/**
 * ...
 * @author Anthony Ganzon
 */
class SceneManager
{
	public var gameDirector(default, null): Director;
	
	public var gameTitleScreen(default, null): TitleScreen;
	public var gameMainScreen(default, null): MainScreen; 
	public var gameControlsScreen(default, null): ControlsScreen;
	public var gameOverScreen(default, null): GameOverScreen;
	
	private var gameScreenList: Array<GameScreen>;
	
	public static var sharedInstance(default, null): SceneManager;
	public static var curSceneEntity(default, null): Entity;
	
	private static inline var TRANSITION_SHORT: Float = 0.5;
	private static inline var TRANSITION_LONG: Float = 1.0;
	
	public function new(director: Director) {
		sharedInstance = this;
		gameDirector = director;
	}
	
	public function initScreens(assetPack: AssetPack, storage: StorageSystem): Void {
		addGameScreen(gameTitleScreen = new TitleScreen(assetPack, storage));
		addGameScreen(gameMainScreen = new MainScreen(assetPack, storage));
		addGameScreen(gameControlsScreen = new ControlsScreen(assetPack, storage));
		addGameScreen(gameOverScreen = new GameOverScreen(assetPack, storage));
	}
	
	private function addGameScreen(screen: GameScreen): Void {
		if (gameScreenList == null) {
			gameScreenList = new Array<GameScreen>();
		}
		
		gameScreenList.push(screen);
	}
	
	public static function unwindToCurScene(?transition: Transition, ?onComplete: Void->Void): Void {
		sharedInstance.gameDirector.unwindToScene(curSceneEntity, transition, onComplete);
	}
	
	public static function unwindToScene(sceneEntity: Entity, ?transition: Transition, ?onComplete: Void->Void): Void {
		sharedInstance.gameDirector.unwindToScene(sceneEntity, transition, onComplete);
	}
	
	public static function pushScene(screenEntity: Entity, ?transition: Transition, ?onComplete: Void->Void): Void {
		sharedInstance.gameDirector.pushScene(screenEntity, transition, onComplete);
	}
	
	public static function showScreen(gameScreen: GameScreen, willAnimate: Bool = false, ?onComplete: Void->Void): Void {
		Utils.consoleLog("SHOWING SCREEN [" + gameScreen.getScreenName() + "]");
		unwindToScene(gameScreen.createScreen(),
			willAnimate ? new FadeTransition(TRANSITION_SHORT, Ease.linear) : null, onComplete);
		curSceneEntity = gameScreen.screenEntity;
		gameScreen.displayFPS();
	}
	
	public static function showTitleScreen(willAnimate: Bool = false, ?onComplete: Void->Void): Void {
		Utils.consoleLog("SHOWING SCREEN [" + sharedInstance.gameTitleScreen.getScreenName() + "]");
		unwindToScene(sharedInstance.gameTitleScreen.createScreen(),
			willAnimate ? new FadeTransition(TRANSITION_SHORT, Ease.linear) : null, onComplete);
		curSceneEntity = sharedInstance.gameTitleScreen.screenEntity;
		sharedInstance.gameTitleScreen.displayFPS();
	}
	
	public static function showMainScreen(willAnimate: Bool = false, ?onComplete: Void->Void): Void {
		Utils.consoleLog("SHOWING SCREEN [" + sharedInstance.gameMainScreen.getScreenName() + "]");
		unwindToScene(sharedInstance.gameMainScreen.createScreen(),
			willAnimate ? new FadeTransition(TRANSITION_SHORT, Ease.linear): null, onComplete);
		curSceneEntity = sharedInstance.gameMainScreen.screenEntity;
		sharedInstance.gameMainScreen.displayFPS();
	}
	
	public static function showControlsScreen(willAnimate: Bool = false, ?onComplete: Void->Void): Void {
		Utils.consoleLog("SHOWING SCREEN [" + sharedInstance.gameControlsScreen.getScreenName() + "]");
		unwindToCurScene();
		pushScene(sharedInstance.gameControlsScreen.createScreen(),
			willAnimate ? new FadeTransition(TRANSITION_SHORT, Ease.linear) : null, onComplete);
		sharedInstance.gameControlsScreen.displayFPS();
	}
	
	public static function showGameOverScreen(willAnimate: Bool = false, ?onComplete: Void->Void): Void {
		Utils.consoleLog("SHOWING SCREEN [" + sharedInstance.gameOverScreen.getScreenName() + "]");
		unwindToCurScene();
		pushScene(sharedInstance.gameOverScreen.createScreen(),
			willAnimate ? new FadeTransition(TRANSITION_SHORT, Ease.linear) : null, onComplete);
		sharedInstance.gameOverScreen.displayFPS();
	}
	
	public static function getTitleScreen(): TitleScreen {
		return sharedInstance.gameTitleScreen;
	}
	
	public static function getMainScreen(): MainScreen {
		return sharedInstance.gameMainScreen;
	}
	
	public static function getControlsScreen(): ControlsScreen {
		return sharedInstance.gameControlsScreen;
	}
	
	public static function getGameOverScreen(): GameOverScreen {
		return sharedInstance.gameOverScreen;
	}
}