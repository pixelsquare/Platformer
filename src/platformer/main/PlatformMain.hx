package platformer.main;

import flambe.asset.AssetPack;
import flambe.asset.File;
import flambe.Component;
import flambe.display.ImageSprite;
import flambe.display.Texture;
import flambe.Entity;
import flambe.input.KeyboardEvent;
import platformer.format.TileFormat;
import haxe.Json;
import flambe.util.Arrays;
import platformer.main.hero.PlatformHero;
import platformer.main.hero.PlatformHero;
import platformer.main.hero.PlatformHeroCollision;
import platformer.main.hero.PlatformHeroControl;
import platformer.main.tile.PlatformBlock;
import platformer.main.tile.PlatformDoor;
import platformer.main.tile.PlatformObstacle;
import flambe.System;
import flambe.input.Key;

import platformer.pxlSq.Utils;
import platformer.core.DataManager;
import platformer.main.tile.utils.TileType;
import platformer.format.RoomFormat;
import platformer.main.tile.PlatformTile;
import platformer.name.AssetName;
import platformer.main.utils.GameConstants;

/**
 * ...
 * @author Anthony Ganzon
 */
class PlatformMain extends Component
{
	public var dataManager(default, null): DataManager;
	public var streamingAsset(default, null): AssetPack;
	
	public var currentRoom(default, null): Int;
	public var tileList(default, null): Map<TileType, Texture>;
	public var tileGrid(default, null): Array<Array<PlatformTile>>;
	
	public var heroEntity(default, null): Entity;
	
	private var allTiles: Array<PlatformTile>;
	
	private var gameAsset: AssetPack;
	private var roomDataJson: RoomFormat;
	
	private var doorIn: PlatformTile;
	private var doorOut: PlatformTile;
	
	private static inline var ROOM_MAX: Int = 5;
	
	private static inline var TILE_DATA_PATH: String = "tiledata/TileData";
	private static inline var ROOM_DATA_PATH: String = "roomdata/RoomData_";
	private static inline var DATA_EXT: String = ".json";
	
	public function new(dataManager: DataManager, streamingAsset: AssetPack) {
		this.dataManager = dataManager;
		this.streamingAsset = streamingAsset;
		
		this.currentRoom = 1;
		this.tileList = new Map<TileType, Texture>();
		this.tileGrid = new Array<Array<PlatformTile>>();
		
		this.allTiles = new Array<PlatformTile>();
		this.gameAsset = dataManager.gameAsset;
		
		InitTileTypes();
		LoadRoomData(currentRoom);
	}
	
	public function InitTileTypes(): Void {
		tileList = new Map<TileType, Texture>();
		
		var tileTexture: Texture = gameAsset.getTexture(AssetName.ASSET_TILES);
		var tileDataFile: File = streamingAsset.getFile(TILE_DATA_PATH + DATA_EXT);
		var tileDataJson: TileFormat = Json.parse(tileDataFile.toString());
		var tileData: Array<Array<Int>> = tileDataJson.TILE_DATA;
		
		for (i in 0...tileData.length) {
			var tileType: TileType = Type.allEnums(TileType)[i + 1];
			tileList.set(
				tileType,
				tileTexture.subTexture(tileData[i][0], tileData[i][1], tileData[i][2], tileData[i][3])
			);
		}
		
		tileList.set(TileType.SPIKE_UP, gameAsset.getTexture(AssetName.ASSET_SPIKE_UP));
		tileList.set(TileType.SPIKE_DOWN, gameAsset.getTexture(AssetName.ASSET_SPIKE_DOWN));
		tileList.set(TileType.DOOR_IN, gameAsset.getTexture(AssetName.ASSET_DOOR_CLOSE));
		tileList.set(TileType.DOOR_OUT, gameAsset.getTexture(AssetName.ASSET_DOOR_OPEN));
	}
	
	public function LoadRoomData(roomIndx: Int = 1): Void {
		if (roomIndx == 0 || roomIndx > ROOM_MAX)
			return;
		
		currentRoom = roomIndx;
		var roomFile: File = streamingAsset.getFile(ROOM_DATA_PATH + Std.string(currentRoom) + DATA_EXT);
		roomDataJson = Json.parse(roomFile.toString());
	}
	
	public function LoadPrevRoom(): Void {
		var curRoomIndx: Int = currentRoom;
		curRoomIndx--;
		
		if (curRoomIndx <= 0)
			return;
		
		ClearStage();
		LoadRoom(curRoomIndx);
	}
	
	public function LoadNextRoom(): Void {
		var curRoomIndx: Int = currentRoom;
		curRoomIndx++;
		
		if (curRoomIndx > ROOM_MAX)
			return;
	
		ClearStage();
		LoadRoom(curRoomIndx);
	}
	
	public function LoadRoom(roomIndx: Int = 1): Void {
		if (allTiles.length > 0)
			return;
		
		//Utils.ConsoleLog(roomIndx);
		LoadRoomData(roomIndx);
		CreateRoomBackground();
		CreateRoomBlocks();
		CreateRoomObstacles();
		CreateRoomDoors();
		SetBlockLayer();
		
		CreatePlatformHero();
	}
	
	public function CreatePlatformHero(): Void {
		if (doorIn == null) {
			Utils.ConsoleLog("Door IN not specified!");
			return;
		}
		
		heroEntity = new Entity();
		
		var platformHero: PlatformHero = new PlatformHero(gameAsset);
		platformHero.SetParent(owner);
		platformHero.SetXY(doorIn.x._, doorIn.y._);
		heroEntity.add(platformHero);
		
		var platformHeroControl: PlatformHeroControl = new PlatformHeroControl();
		heroEntity.add(platformHeroControl);
		
		var platformHeroCollision: PlatformHeroCollision = new PlatformHeroCollision();
		heroEntity.add(platformHeroCollision);
		
		owner.addChild(heroEntity);
	}
	
	public function CreateRoomTiles(): Void {
		tileGrid = new Array<Array<PlatformTile>>();
		
		for (ii in 0...GameConstants.GRID_ROWS) {
			var tileArray: Array<PlatformTile> = new Array<PlatformTile>();
			for (jj in 0...GameConstants.GRID_COLS) {
				var tile: PlatformTile = new PlatformTile(null);
				tile.SetGridID(ii, jj);
				tile.SetSize(GameConstants.TILE_WIDTH, GameConstants.TILE_HEIGHT);	
				
				tile.SetXY(
					ii * tile.GetNaturalWidth() + (GameConstants.TILE_WIDTH / 2),
					jj * tile.GetNaturalHeight() + (GameConstants.TILE_HEIGHT / 2)
				);
				
				//owner.addChild(new Entity().add(tile));
				tileArray.push(tile);
			}
			tileGrid.push(tileArray);
		}
	}
	
	public function CreateRoomBackground(): Void {
		var backgroundData: Array<Array<Int>> = roomDataJson.Background_Data;
		
		for (ii in 0...backgroundData.length) {
			for (jj in 0...backgroundData[ii].length) {
				var backgroundDataVal: Int = backgroundData[jj][ii];
				
				if (backgroundDataVal == 0)
					continue;
					
				var backgroundTileType: TileType = GetTileType(backgroundDataVal);
				var backgroundTexture: Texture = tileList.get(backgroundTileType);
				var backgroundTile: PlatformBlock = new PlatformBlock(backgroundTexture);
				backgroundTile.SetGridID(ii, jj);
				backgroundTile.SetSize(GameConstants.TILE_WIDTH, GameConstants.TILE_HEIGHT);
				backgroundTile.SetTileType(backgroundTileType);
				
				backgroundTile.SetXY(
					ii * backgroundTile.GetNaturalWidth() + (GameConstants.TILE_WIDTH / 2),
					jj * backgroundTile.GetNaturalHeight() + (GameConstants.TILE_HEIGHT / 2)
				);
				
				tileGrid[ii][jj] = backgroundTile;
				owner.addChild(new Entity().add(tileGrid[ii][jj]));
				allTiles.push(backgroundTile);
			}
		}
	}
	
	public function CreateRoomBlocks(): Void {
		var roomData: Array<Array<Int>> = roomDataJson.Block_Data;
		
		for (ii in 0...roomData.length) {
			for (jj in 0...roomData[ii].length) {
				var roomDataVal: Int = roomData[jj][ii];
				
				if (roomDataVal == 0)
					continue;
				
				var blockTileType: TileType = GetTileType(roomDataVal);
				var blockTexture: Texture = tileList.get(blockTileType);
				var blockTile: PlatformBlock = new PlatformBlock(blockTexture);
				blockTile.SetGridID(ii, jj);
				blockTile.SetSize(GameConstants.TILE_WIDTH, GameConstants.TILE_HEIGHT);					
				blockTile.SetTileType(blockTileType);
				
				blockTile.SetXY(
					ii * blockTile.GetNaturalWidth() + (GameConstants.TILE_WIDTH / 2),
					jj * blockTile.GetNaturalHeight() + (GameConstants.TILE_HEIGHT / 2)
				);
				
				tileGrid[ii][jj] = blockTile;
				owner.addChild(new Entity().add(tileGrid[ii][jj]));
				allTiles.push(blockTile);
			}
		}
	}
	
	public function CreateRoomObstacles(): Void {
		var obstacleData: Array<Array<Int>> = roomDataJson.Obstacle_Data;
		
		for (ii in 0...obstacleData.length) {
			for (jj in 0...obstacleData[ii].length) {
				var obstacleDataVal: Int = obstacleData[jj][ii];
				
				if (obstacleDataVal == 0)
					continue;
					
				var obstacleTileType: TileType = GetObstacleTileType(obstacleDataVal);
				var obstacleTexture: Texture = GetObstacleTexture(obstacleDataVal);
				var obstacleTile: PlatformObstacle = new PlatformObstacle(obstacleTexture);
				obstacleTile.SetGridID(ii, jj);
				obstacleTile.SetSize(GameConstants.TILE_WIDTH, GameConstants.TILE_HEIGHT);
				obstacleTile.SetTileType(obstacleTileType);
				
				obstacleTile.SetXY(
					ii * obstacleTile.GetNaturalWidth() + (GameConstants.TILE_WIDTH / 2),
					jj * obstacleTile.GetNaturalHeight() + (GameConstants.TILE_HEIGHT / 2)
				);
				
				tileGrid[ii][jj] = obstacleTile;
				owner.addChild(new Entity().add(tileGrid[ii][jj]));
				allTiles.push(obstacleTile);
			}
		}
	}
	
	public function CreateRoomDoors(): Void {
		var doorData: Array<Array<Int>> = roomDataJson.Door_Data;
		
		for (ii in 0...doorData.length) {
			for (jj in 0...doorData[ii].length) {
				var doorDataVal: Int = doorData[jj][ii];
				
				if (doorDataVal == 0)
					continue;
			
				var doorTileType: TileType = GetDoorTileType(doorDataVal);
				var doorTexture: Texture = GetDoorTexture(doorDataVal);
				var doorTile: PlatformDoor = new PlatformDoor(doorTexture);
				doorTile.SetGridID(ii, jj);
				doorTile.SetSize(GameConstants.TILE_WIDTH, GameConstants.TILE_HEIGHT);				
				doorTile.SetTileType(doorTileType);
				
				doorTile.SetXY(
					ii * doorTile.GetNaturalWidth() + (GameConstants.TILE_WIDTH / 2),
					jj * doorTile.GetNaturalHeight() + (GameConstants.TILE_HEIGHT / 2)
				);
				
				if (doorDataVal == 1) {
					doorIn = doorTile;
				}
				
				if (doorDataVal == 2) {
					doorOut = doorTile;
				}
				
				tileGrid[ii][jj] = doorTile;
				owner.addChild(new Entity().add(tileGrid[ii][jj]));
				allTiles.push(doorTile);
			}
		}
	}
	
	public function SetBlockLayer(): Void {
		var layerData: Array<Array<Int>> = roomDataJson.Layer_Data;
		
		for (ii in 0...tileGrid.length) {
			for (jj in 0...tileGrid[ii].length) {
				var layer: Int = layerData[jj][ii];
				var blockTile: PlatformTile = tileGrid[ii][jj];
				if (blockTile != null) {
					blockTile.SetTileLayer(layer);
				}
			}
		}
	}
	
	public function GetTileType(indx: Int): TileType {
		return Type.allEnums(TileType)[indx];
	}
	
	public function GetDoorTexture(indx: Int): Texture {
		var result: Texture = null;
		
		if (indx == 1) {
			result = gameAsset.getTexture(AssetName.ASSET_DOOR_CLOSE);
		}
		else if (indx == 2) {
			result = gameAsset.getTexture(AssetName.ASSET_DOOR_OPEN);
		}
		
		return result;
	}
	
	public function GetDoorTileType(indx: Int): TileType {
		var doorType: TileType = TileType.NONE;
		
		if (indx == 1) {
			doorType = TileType.DOOR_IN;
		}
		else if (indx == 2) {
			doorType = TileType.DOOR_OUT;
		}
		
		return doorType;
	}
	
	public function GetObstacleTexture(indx: Int): Texture {
		var result: Texture = null;
		
		if (indx == 1) {
			result = gameAsset.getTexture(AssetName.ASSET_SPIKE_UP);
		}
		else if (indx == 2) {
			result = gameAsset.getTexture(AssetName.ASSET_SPIKE_DOWN);
		}
		
		return result;
	}
	
	public function GetObstacleTileType(indx: Int): TileType {
		var obstacleType: TileType = TileType.NONE;
		
		if (indx == 1) {
			obstacleType = TileType.SPIKE_UP;
		}
		else if (indx == 2) {
			obstacleType == TileType.SPIKE_DOWN;
		}
		
		return obstacleType;
	}
	
	public function ClearStage(): Void {		
		for (tile in allTiles) {
			if (tile != null) {
				tile.dispose();
			}
		}
		
		allTiles = new Array<PlatformTile>();
		roomDataJson = null;
	}
	
	override public function onAdded() {
		super.onAdded();
		
		CreateRoomTiles();
		LoadRoom(currentRoom);
		
		//System.keyboard.down.connect(function(event: KeyboardEvent) {
			//if (event.key == Key.Number1) {
				//LoadRoom(1);
			//}
			//if (event.key == Key.Number2) {
				//LoadRoom(2);
			//}
			//if (event.key == Key.Number3) {
				//LoadRoom(3);
			//}
			//if (event.key == Key.Number4) {
				//LoadRoom(4);
			//}
			//if (event.key == Key.Number5) {
				//LoadRoom(5);
			//}
			//if (event.key == Key.F1) {
				//LoadPrevRoom();
			//}
			//if (event.key == Key.F2) {
				//LoadNextRoom();
			//}
			//if (event.key == Key.Space) {
				//ClearStage();
			//}
		//});
	}
}