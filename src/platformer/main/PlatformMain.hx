package platformer.main;

import flambe.animation.Ease;
import flambe.asset.AssetPack;
import flambe.asset.File;
import flambe.display.FillSprite;
import flambe.display.Font;
import flambe.display.ImageSprite;
import flambe.display.TextSprite;
import flambe.Disposer;
import flambe.Entity;
import flambe.input.Key;
import flambe.input.KeyboardEvent;
import flambe.script.AnimateTo;
import flambe.script.CallFunction;
import flambe.script.Script;
import flambe.script.Sequence;
import flambe.subsystem.StorageSystem;
import flambe.display.Texture;
import platformer.core.DataManager;
import platformer.main.format.RoomFormat;
import platformer.main.hero.HeroControl;
import platformer.main.hero.PlatformHero;
import platformer.main.tile.PlatformTile;
import platformer.main.tile.utils.TileType;
import platformer.name.AssetName;
import platformer.main.utils.GameConstants;
import flambe.display.SubTexture;
import flambe.System;
import platformer.name.FontName;
import platformer.pxlsq.Utils;
import haxe.Json;
import platformer.core.SceneManager;

/**
 * ...
 * @author Anthony Ganzon
 */
class PlatformMain extends DataManager
{
	public var streamingAsset(default, null): AssetPack;
	public var curRoomIndx(default, null): Int;
	
	public var tileGrid(default, null): Array<Array<PlatformTile>>;
	public var allTiles(default, null): Array<PlatformTile>;
	
	public var isGameStart: Bool;
	public var isGameOver(default, null): Bool;
	public var didWin(default, null): Bool;
	
	private var tileTextures: Map<Int, Texture>;
	private var obstacleTextures: Map<Int, Texture>;
	private var doorTextures: Map<Int, Texture>;
	
	private var levelEntity: Entity;
	
	private var bgEntity: Entity;
	private var blocksEntity: Entity;
	private var obstaclesEntity: Entity;
	private var doorsEntity: Entity;
	
	private var heroEntity: Entity;
	private var platformHero: PlatformHero;
	private var heroControl: HeroControl;
	
	private var layerEntity: Entity;
	
	private var roomDataJson: RoomFormat;
	private var platformDisposer: Disposer;
	
	private static inline var ROOM_DATA_PATH: String = "roomdata/RoomData_";
	private static inline var ROOM_DATA_EXT: String = ".json";
	
	private static inline var ROOM_MAX: Int = 5;
	
	public static var sharedInstance(default, null): PlatformMain;
	
	public function new(gameAsset:AssetPack, streamingAsset: AssetPack) {
		super(gameAsset, null);
		
		this.streamingAsset = streamingAsset;
		sharedInstance = this;
		
		curRoomIndx = 1;
		
		tileTextures = new Map<Int, Texture>();
		obstacleTextures = new Map<Int, Texture>();
		doorTextures = new Map<Int, Texture>();
		
		tileGrid = new Array<Array<PlatformTile>>();
		allTiles = new Array<PlatformTile>();
		
		isGameStart = false;
		isGameOver = false;
		didWin = false;
		
		levelEntity = new Entity();
		layerEntity = new Entity();
		
		bgEntity = new Entity();
		blocksEntity = new Entity();
		obstaclesEntity = new Entity();
		doorsEntity = new Entity();
		
		heroEntity = new Entity();
		
		initTextures();
	}
	
	public function initTextures(): Void {
		tileTextures = new Map<Int, Texture>();
		
		var tileTexture: Texture = gameAsset.getTexture(AssetName.ASSET_TILES);
		var tiles: Array<SubTexture> = tileTexture.split(
			Std.int(tileTexture.width / GameConstants.TILE_WIDTH),
			Std.int(tileTexture.height / GameConstants.TILE_HEIGHT)
		);
		
		for (i in 0...tiles.length) {
			tileTextures.set(i + 1, tiles[i]);
		}
		
		obstacleTextures = new Map<Int, Texture>();
		obstacleTextures.set(1, gameAsset.getTexture(AssetName.ASSET_SPIKE_UP));
		obstacleTextures.set(2, gameAsset.getTexture(AssetName.ASSET_SPIKE_DOWN));
		
		doorTextures = new Map<Int, Texture>();
		doorTextures.set(1, gameAsset.getTexture(AssetName.ASSET_DOOR_CLOSE));
		doorTextures.set(2, gameAsset.getTexture(AssetName.ASSET_DOOR_OPEN));
	}
	
	public function readRoomData(roomIndx: Int = 1): Void {
		if (roomIndx == 0 || roomIndx > ROOM_MAX)
			return;
		
		Utils.consoleLog("Reading room data " + roomIndx);
		
		var roomFile: File = streamingAsset.getFile(ROOM_DATA_PATH + Std.int(roomIndx) + ROOM_DATA_EXT);
		roomDataJson = Json.parse(roomFile.toString());
		//roomFile.dispose();
		
		curRoomIndx = roomIndx;
	}
	
	public function loadRoom(roomIndx: Int = 1): Void {			
		Utils.consoleLog("Loading room " + roomIndx);
		
		resetTiles();
		
		readRoomData(roomIndx);
		createRoomBackground();
		createRoomBlocks();
		createRoomObstacles();
		createRoomDoors();
		setTileLayer();
		drawLevelTiles();
		
		createPlatformHero();
		showScreenCurtain();
	}
	
	public function loadPrevRoom(): Void {
		var curIndx: Int = curRoomIndx;
		curIndx--;
		
		if (curIndx <= 0)
			return;
			
		clearStage();
		loadRoom(curIndx);
	}
	
	public function loadNextRoom(): Void {
		var curIndx: Int = curRoomIndx;
		curIndx++;
		
		if (curIndx > ROOM_MAX) {
			Utils.consoleLog("WIN!");
			onGameEnd(true);
			return;
		}
		
		clearStage();
		loadRoom(curIndx);
	}
	
	public function createPlatformHero(): Void {
		var doorIn: PlatformTile = getTileOfType(TileType.DOOR_IN);
		if (doorIn == null) {
			Utils.consoleLog("Door In not specified!");
			return;
		}
		
		heroEntity = new Entity();
		platformHero = new PlatformHero(gameAsset);
		platformHero.setXY(doorIn.x._, doorIn.y._);
		platformHero.setSize(GameConstants.TILE_WIDTH, GameConstants.TILE_HEIGHT);
		platformHero.setColliderOffset(13, 17);
		heroEntity.add(platformHero);
		
		heroControl = new HeroControl();
		heroEntity.add(heroControl);
	
		owner.addChild(heroEntity);
	}
	
	public function createRoomTiles(): Void {
		tileGrid = new Array<Array<PlatformTile>>();
		
		for (ii in 0...GameConstants.GRID_ROWS) {
			var tileArray: Array<PlatformTile> = new Array<PlatformTile>();
			for (jj in 0...GameConstants.GRID_COLS) {
				var tile: PlatformTile = new PlatformTile();
				tile.setSize(GameConstants.TILE_WIDTH, GameConstants.TILE_HEIGHT);
				tile.setColliderOffset(tile.getNaturalWidth() / 2, tile.getNaturalHeight() / 2);
				
				tile.setXY(
					ii * tile.getNaturalWidth() + (GameConstants.TILE_WIDTH / 2),
					jj * tile.getNaturalHeight() + (GameConstants.TILE_HEIGHT / 2)
				);
				
				tileArray.push(tile);
			}
			tileGrid.push(tileArray);
		}
	}
	
	public function createRoomBackground(): Void {
		if (tileGrid == null)
			return;
			
		bgEntity = new Entity();
		var bgData: Array<Array<Int>> = roomDataJson.Background_Data;
		for (ii in 0...bgData.length) {
			for (jj in 0 ...bgData[ii].length) {
				var value: Int = bgData[jj][ii];
				if (value == 0)
					continue;
					
				var tileTexture: Texture = tileTextures.get(value);
				var tile: PlatformTile = new PlatformTile(tileTexture);
				tile.setXY(tileGrid[ii][jj].x._, tileGrid[ii][jj].y._);
				bgEntity.addChild(new Entity().add(tile));
				
				allTiles.push(tile);
			}
		}
		
		levelEntity.addChild(bgEntity);
	}
	
	public function createRoomBlocks(): Void {
		if (tileGrid == null)
			return;
			
		blocksEntity = new Entity();
		var blocksData: Array<Array<Int>> = roomDataJson.Block_Data;
		for (ii in 0...blocksData.length) {
			for (jj in 0...blocksData[ii].length) {
				var value: Int = blocksData[jj][ii];
				if (value == 0)
					continue;
					
				var tileTexture: Texture = tileTextures.get(value);
				var tile: PlatformTile = tileGrid[ii][jj];
				tile.setTexture(tileTexture);
				tile.setTileType(TileType.BLOCK);
				blocksEntity.addChild(new Entity().add(tile));
				
				allTiles.push(tile);
			}
		}
		
		levelEntity.addChild(blocksEntity);
	}
	
	public function createRoomObstacles(): Void {
		if (tileGrid == null)
			return;
			
		obstaclesEntity = new Entity();
		var obsData: Array<Array<Int>> = roomDataJson.Obstacle_Data;
		for (ii in 0...obsData.length) {
			for (jj in 0...obsData[ii].length) {
				var value: Int = obsData[jj][ii];
				if (value == 0)
					continue;
				
				var tileTexture: Texture = obstacleTextures.get(value);
				var tile: PlatformTile = tileGrid[ii][jj];
				tile.setTexture(tileTexture);
				if (value == 1) { tile.setTileType(TileType.SPIKE_UP); }
				else if (value == 2) { tile.setTileType(TileType.SPIKE_DOWN); }
				obstaclesEntity.addChild(new Entity().add(tile));
				
				allTiles.push(tile);
			}
		}
		
		levelEntity.addChild(obstaclesEntity);
	}
	
	public function createRoomDoors(): Void {
		if (tileGrid == null)
			return;
			
		doorsEntity = new Entity();
		var doorData: Array<Array<Int>> = roomDataJson.Door_Data;
		for (ii in 0...doorData.length) {
			for (jj in 0...doorData[ii].length) {
				var value: Int = doorData[jj][ii];
				if (value == 0)
					continue;
					
				var tileTexture: Texture = doorTextures.get(value);
				var tile: PlatformTile = tileGrid[ii][jj];
				tile.setTexture(tileTexture);
				if (value == 1) { tile.setTileType(TileType.DOOR_IN); }
				else if (value == 2) { tile.setTileType(TileType.DOOR_OUT); }
				doorsEntity.addChild(new Entity().add(tile));
				
				allTiles.push(tile);
			}
		}
		
		levelEntity.addChild(doorsEntity);
	}
	
	public function setTileLayer(): Void {
		if (tileGrid == null)
			return;
			
		var layerData: Array<Array<Int>> = roomDataJson.Layer_Data;
		for (ii in 0...layerData.length) {
			for (jj in 0...layerData[ii].length) {
				var value: Int = layerData[jj][ii];
				if (value == 0)
					continue;
					
				var tile: PlatformTile = tileGrid[ii][jj];
				tile.setLayer(value);
			}
		}
	}
	
	public function drawLevelTiles(): Void {
		owner.addChild(levelEntity);
	}
	
	public function clearStage(): Void {
		Utils.consoleLog("Clearing stage [count:" + allTiles.length + "]");
		allTiles = new Array<PlatformTile>();
		
		owner.removeChild(levelEntity);
		levelEntity.dispose();
		
		owner.removeChild(heroEntity);
		heroEntity.dispose();
		
		owner.removeChild(layerEntity);
		layerEntity.dispose();
	}
	
	public function resetTiles(): Void {
		for (ii in 0...tileGrid.length) {
			for (jj in 0...tileGrid[ii].length) {
				var tile: PlatformTile = tileGrid[ii][jj];
				tile.reset();
				tile.setSize(GameConstants.TILE_WIDTH, GameConstants.TILE_HEIGHT);
			}
		}
	}
	
	public function getTileOfType(type: TileType): PlatformTile {
		for (tile in allTiles) {
			if (tile.tileType == type) {
				return tile;
			}
		}
		
		return null;
	}
	
	public function onGameEnd(win: Bool): Void {
		didWin = win;
		SceneManager.showGameOverScreen();
	}
	
	public function playHeroDeathAnim(): Void {
		isGameOver = true;
		platformHero.setDeathPose();
		heroControl.dispose();
		
		var heroAnim: Script = new Script();
		heroAnim.run(new Sequence([
			new AnimateTo(platformHero.y, platformHero.y._ - 30, 0.5, Ease.sineOut),
			new AnimateTo(platformHero.y, System.stage.height + platformHero.getNaturalHeight(), 0.5, Ease.sineIn),
			new CallFunction(function() {
				onGameEnd(false);
				owner.removeChild(new Entity().add(heroAnim));
				heroAnim.dispose();
			})
		]));
		owner.addChild(new Entity().add(heroAnim));
	}
	
	public function showScreenCurtain(): Void {
		var curtain: FillSprite = new FillSprite(0x000000, System.stage.width, System.stage.height);
		owner.addChild(new Entity().add(curtain));
		
		isGameStart = false;
		var curtainScript: Script = new Script();
		curtainScript.run(new Sequence([
			new AnimateTo(curtain.alpha, 0, 0.5),
			new CallFunction(function() {
				owner.removeChild(new Entity().add(curtain));
				curtain.dispose();
				
				owner.removeChild(new Entity().add(curtainScript));
				curtainScript.dispose();
				
				if (curRoomIndx == 1) {
					SceneManager.showControlsScreen();
				}
				else {
					isGameStart = true;
				}
			})
		]));
		owner.addChild(new Entity().add(curtainScript));
	}
	
	public function showTileLayers(): Void {
		layerEntity = new Entity();
		
		for (ii in 0...tileGrid.length) {
			for (jj in 0...tileGrid[ii].length) {
				var layerText: TextSprite = new TextSprite(new Font(gameAsset, FontName.FONT_ARIAL_20), tileGrid[ii][jj].tileLayer + "");
				layerText.centerAnchor();
				layerText.setXY(tileGrid[ii][jj].x._, tileGrid[ii][jj].y._);
				layerEntity.addChild(new Entity().add(layerText));
			}
		}
		
		owner.addChild(layerEntity);
	}
	
	override public function onAdded() {
		super.onAdded();
		
		platformDisposer = owner.get(Disposer);
		if (platformDisposer == null) {
			owner.add(platformDisposer = new Disposer());
		}
		
		createRoomTiles();
		loadRoom(curRoomIndx);		
	}
	
	override public function onStart() {
		super.onStart();
		
		platformDisposer.add(System.keyboard.down.connect(function(event: KeyboardEvent) {
			if (event.key == Key.M) {
				
			}
			
			if (event.key == Key.Number1) {
				clearStage();
				loadRoom(1);
			}
			if (event.key == Key.Number2) {
				clearStage();
				loadRoom(2);
			}
			if (event.key == Key.Number3) {
				clearStage();
				loadRoom(3);
			}
			if (event.key == Key.Number4) {
				clearStage();
				loadRoom(4);
			}
			if (event.key == Key.Number5) {
				clearStage();
				loadRoom(5);
			}
			if (event.key == Key.F2) {
				loadPrevRoom();
			}
			if (event.key == Key.F3) {
				loadNextRoom();
			}
			if (event.key == Key.F4) {
				clearStage();
				resetTiles();
			}
			if (event.key == Key.F5) {
				showTileLayers();
			}
		}));
	}
}