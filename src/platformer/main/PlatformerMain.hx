package platformer.main;

import flambe.asset.File;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.display.ImageSprite;
import flambe.display.Texture;
import flambe.Entity;
import flambe.input.KeyboardEvent;
import flambe.math.Rectangle;
import flambe.swf.Format;
import flambe.util.Promise;
import platformer.core.DataManager;
import platformer.main.tile.PlatformBlock;
import platformer.main.tile.PlatformDoor;
import platformer.main.tile.PlatformObstacle;
import platformer.main.tile.PlatformTile;
import platformer.main.utils.RoomFormat;
import platformer.main.utils.TileDataType;
import platformer.main.utils.TileFormat;
import platformer.name.AssetName;
import flambe.System;
import platformer.pxlSq.Utils;
import haxe.Json;
import flambe.util.Arrays;
import flambe.display.SubTexture;
import platformer.main.utils.TileType;
import flambe.util.Maps;
import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import platformer.core.SceneManager;
import platformer.screen.PreloadScreen;
import platformer.name.RoomDataName;
import platformer.main.utils.GameConstants;
import flambe.math.FMath;
import flambe.util.Strings;
import flambe.input.Key;

/**
 * ...
 * @author Anthony Ganzon
 */
class PlatformerMain extends Component
{
	public var dataManager(default, null): DataManager;
	public var streamingPack(default, null): AssetPack;
	
	public var curRoomIndx(default, null): Int;
	public var tiles(default, null): Map<TileType, Texture>;
	
	private var roomFormat: RoomFormat;
	private var gameAsset: AssetPack;
	private var gameTiles: Array<Array<PlatformTile>>;
	
	private static inline var STREAMING_PATH: String = "streamingassets";
	private static inline var ROOM_DATA_PATH: String = "roomdata/RoomData_";
	private static inline var ROOM_DATA_EXT: String = ".json";

	public function new(dataManager: DataManager) {
		this.dataManager = dataManager;
		this.gameAsset = dataManager.gameAsset;
		
		curRoomIndx = 1;
		tiles = new Map<TileType, Texture>();
		gameTiles = new Array<Array<PlatformTile>>();
		
		LoadData();
	}
	
	public function InitTiles(): Void {
		if (streamingPack == null || gameAsset == null)
			return;
			
		var tileTexture: Texture = gameAsset.getTexture(AssetName.ASSET_TILES);
			
		var file: File = streamingPack.getFile("tiledata/TileData.json");
		var tileJson: TileFormat = Json.parse(file.toString());
		
		for (i in 0...tileJson.TILE_DATA.length) {
			tiles.set(Type.allEnums(TileType)[i + 1], tileTexture.subTexture(
				tileJson.TILE_DATA[i][0],
				tileJson.TILE_DATA[i][1],
				tileJson.TILE_DATA[i][2],
				tileJson.TILE_DATA[i][3]
			));
		}
		
		tiles.set(TileType.SPIKE_UP, gameAsset.getTexture(AssetName.ASSET_SPIKE_UP));
		tiles.set(TileType.SPIKE_DOWN, gameAsset.getTexture(AssetName.ASSET_SPIKE_DOWN));
		tiles.set(TileType.DOOR_IN, gameAsset.getTexture(AssetName.ASSET_DOOR_CLOSE));
		tiles.set(TileType.DOOR_OUT, gameAsset.getTexture(AssetName.ASSET_DOOR_OPEN));
		
		tiles.set(TileType.BLOCK_120x120, tileTexture.subTexture(0, 0, 120, 120));
		tiles.set(TileType.BLOCK_1_80x80, tileTexture.subTexture(120, 0, 80, 80));
		tiles.set(TileType.BLOCK_2_80x80, tileTexture.subTexture(200, 0, 80, 80));
		tiles.set(TileType.BLOCK_120x40, tileTexture.subTexture(121, 81, 120, 40));
		tiles.set(TileType.BLOCK_40x120, tileTexture.subTexture(280, 0, 40, 120));
		tiles.set(TileType.BLOCK_40x80, tileTexture.subTexture(280, 0, 40, 80));
	}
	
	public function LoadData(): Void {
		var promise: Promise<AssetPack> = System.loadAssetPack(Manifest.fromAssets(STREAMING_PATH));
		promise.get(function(assetPack: AssetPack) {
			streamingPack = assetPack;
			OnDataLoaded();
		});
		//SceneManager.ShowScreen(new PreloadScreen(dataManager.gameAsset, promise));
	}
	
	public function OnDataLoaded(): Void {
		InitTiles();
		LoadRoomData();
	}
	
	public function LoadRoomData(indx: Int = 1): Void {
		curRoomIndx = indx;
		ClearStage();
		LoadRoom();
		CreateRoom();
	}
	
	public function LoadRoom(): Void {
		if (streamingPack == null)
			return;
		
		var file: File = streamingPack.getFile(ROOM_DATA_PATH + Std.string(curRoomIndx) + ROOM_DATA_EXT);
		roomFormat = Json.parse(file.toString());
	}
	
	public function CreateRoom(): Void {
		var roomData: Array<Array<Int>> = roomFormat.RoomData;
		
		for (ii in 0...roomData.length) {
			var tileArray: Array<PlatformTile> = new Array<PlatformTile>();
			for (jj in 0...roomData[ii].length) {
					
				var roomDataVal: Int = roomData[jj][ii];
				
				var indx: Int = Std.int(Math.abs(roomDataVal));
				var tileTexture: Texture = tiles.get(Type.allEnums(TileType)[indx]);
				var tile: PlatformTile = null;
				
				if(roomData[jj][ii] > 0) {
					if (Type.allEnums(TileType)[roomDataVal] == TileType.SPIKE_UP || Type.allEnums(TileType)[roomDataVal] == TileType.SPIKE_DOWN) {
						tile = new PlatformObstacle(tileTexture);
					}
					else if (Type.allEnums(TileType)[roomDataVal] == TileType.DOOR_IN || Type.allEnums(TileType)[roomDataVal] == TileType.DOOR_OUT) {
						tile = new PlatformDoor(tileTexture);
					}
					else {
						tile = new PlatformBlock(tileTexture);
					}
					
					tile.SetGridID(ii, jj);
					
					var wLen: Float = tile.GetNaturalWidth() / GameConstants.TILE_WIDTH;
					var hLen: Float = tile.GetNaturalHeight() / GameConstants.TILE_HEIGHT;
					
					var isWLenOdd: Bool = wLen % 2 == 1;
					var isHLenOdd: Bool = hLen % 2 == 1;
					
					// Determine whether the width and height of the tile is odd or even
					// if it's odd, place the anchor point to the middle center
					// If it's even, place the anchor point to the upper right corner
					if (isWLenOdd && isHLenOdd) {
						tile.SetXY(
							ii * GameConstants.TILE_WIDTH + (GameConstants.TILE_WIDTH / 2), 
							jj * GameConstants.TILE_HEIGHT + (GameConstants.TILE_HEIGHT / 2)
							
						);
					}
					else {
						tile.SetXY(
							ii * GameConstants.TILE_WIDTH + (tile.GetNaturalWidth() / 2), 
							jj * GameConstants.TILE_HEIGHT + (tile.GetNaturalHeight() / 2)
						);
					}
					
					var append: Bool = roomData[jj][ii] > 0;
					owner.addChild(new Entity().add(tile), append);
				}
				
				tileArray.push(tile);
			}
			
			gameTiles.push(tileArray);
		}
	}
	
	public function ClearStage(): Void {
		for (i in 0...gameTiles.length) {
			for (tile in gameTiles[i]) {
				if (tile == null)
					continue;
			
				tile.dispose();
			}
		}
	}
	
	override public function onStart() {
		super.onStart();
		
		System.keyboard.down.connect(function(event: KeyboardEvent) {
			if (event.key == Key.Number1) {
				LoadRoomData(1);
			}
			if (event.key == Key.Number2) {
				LoadRoomData(2);
			}
			if (event.key == Key.Number3) {
				LoadRoomData(3);
			}
			if (event.key == Key.Number4) {
				LoadRoomData(4);
			}
			if (event.key == Key.Number5) {
				LoadRoomData(5);
			}
		});
	}
}