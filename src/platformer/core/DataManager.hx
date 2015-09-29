package platformer.core;

import flambe.asset.AssetPack;
import flambe.Component;
import flambe.Disposer;
import flambe.subsystem.StorageSystem;

/**
 * ...
 * @author Anthony Ganzon
 */
class DataManager extends Component
{
	public var gameAsset(default, null): AssetPack;
	public var gameStorage(default, null): StorageSystem;
	
	public function new(gameAsset: AssetPack, gameStorage: StorageSystem) {		
		this.gameAsset = gameAsset;
		this.gameStorage = gameStorage;
	}
}