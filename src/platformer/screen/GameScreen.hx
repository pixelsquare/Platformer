package platformer.screen;

import flambe.asset.AssetPack;
import flambe.Component;
import flambe.debug.FpsDisplay;
import flambe.display.FillSprite;
import flambe.display.Font;
import flambe.display.TextSprite;
import flambe.Disposer;
import flambe.Entity;
import flambe.scene.Scene;
import flambe.subsystem.StorageSystem;
import flambe.System;

import platformer.core.DataManager;
import platformer.name.FontName;
import platformer.pxlsq.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class GameScreen extends DataManager
{
	public var screenEntity(default, null): Entity;
	
	private var screenScene: Scene;
	private var screenDisposer: Disposer;
	
	private var screenTemplate: Entity;
	private var screenBackground: FillSprite;
	private var screenTitleText: TextSprite;
	
	private var fpsEntity: Entity;
	
	private var screenWidth: Int;
	private var screenHeight: Int;
	
	private static inline var DEFAULT_BG_COLOR: Int = 0x202020;
	
	public function new(gameAsset:AssetPack, gameStorage:StorageSystem) {
		super(gameAsset, gameStorage);
	}
	
	public function createScreen(): Entity {
		screenEntity = new Entity()
			.add(screenScene = new Scene(false))
			.add(screenDisposer = new Disposer());
			
		screenWidth = System.stage.width;
		screenHeight = System.stage.height;
		
		screenTemplate = new Entity();
		screenBackground = new FillSprite(DEFAULT_BG_COLOR, screenWidth, screenHeight);
		screenTemplate.add(screenBackground);
		
		screenTitleText = new TextSprite(new Font(gameAsset, FontName.FONT_VANADINE_32), getScreenName());
		screenTitleText.centerAnchor();
		screenTitleText.setXY(screenWidth / 2, screenHeight / 2);
		screenTemplate.add(screenTitleText);
		
		screenEntity.addChild(screenTemplate);		
		
		return screenEntity;
	}
	
	public function getScreenName(): String {
		return "";
	}
	
	public function displayFPS(): Void {
		fpsEntity = new Entity();
		fpsEntity.add(new TextSprite(new Font(gameAsset, FontName.FONT_ARIAL_20)));
		fpsEntity.add(new FpsDisplay());
		screenEntity.addChild(fpsEntity);
	}
	
	public function addToEntity(component: Component, append: Bool = true): Void {
		if (component == null) {
			Utils.consoleLog("Cannot append nulled components. [" + component.name + "]");
			return;
		}
		
		screenEntity.addChild(new Entity().add(component), append);
	}
	
	public function removeEntity(component: Component): Void {
		if (component == null) {
			Utils.consoleLog("Cannot remove nulled components. [" + component.name + "]");
			return;
		}
		
		screenEntity.removeChild(new Entity().add(component));
	}
	
	public function removeAndDispose(component: Component): Void {
		removeEntity(component);
		component.dispose();
	}
}