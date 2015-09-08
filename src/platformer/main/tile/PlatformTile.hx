package platformer.main.tile;

import flambe.animation.AnimatedFloat;
import flambe.display.ImageSprite;
import flambe.display.Texture;
import platformer.main.tile.utils.TileDataType;

import platformer.main.tile.utils.TileType;
import platformer.main.element.GameElement;
import platformer.main.utils.IGrid;
import platformer.pxlSq.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class PlatformTile extends GameElement implements IGrid
{
	public var idx(default, null): Int;
	public var idy(default, null): Int;
	
	public var width(default, null): AnimatedFloat;
	public var height(default, null): AnimatedFloat;
	
	public var tileType(default, null): TileType;
	public var tileLayer(default, null): Int;
	
	private var tileTexture: Texture;
	private var tileImage: ImageSprite;
	
	public function new(texture: Texture) {
		this.width = new AnimatedFloat(0.0);
		this.height = new AnimatedFloat(0.0);
		this.tileType = TileType.NONE;
		this.tileTexture = texture;
		
		super();
	}
	
	public function SetSize(width: Float, height: Float): Void {
		this.width._ = width;
		this.height._ = height;
	}
	
	public function SetTileType(tileType: TileType): Void {
		this.tileType = tileType;
	}
	
	public function SetTileLayer(layer: Int): Void {
		this.tileLayer = layer;
	}
	
	public function GetTileDataType(): TileDataType {
		return TileDataType.NONE;
	}
	
	override public function Init(): Void {
		super.Init();
		
		if (tileTexture == null)
			return;
		
		tileImage = new ImageSprite(tileTexture);
		tileImage.centerAnchor();
	}
	
	override public function Draw(): Void {
		super.Draw();
		
		if (tileTexture == null || tileImage == null)
			return;
			
		AddToEntity(tileImage);
	}
	
	override public function GetNaturalWidth(): Float {
		return (tileImage != null) ? tileImage.getNaturalWidth() : width._;
	}
	
	override public function GetNaturalHeight(): Float {
		return (tileImage != null) ? tileImage.getNaturalHeight() : height._;
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		
		if (tileImage != null) {
			tileImage.setAlpha(alpha._);
			tileImage.setXY(x._, y._);
			tileImage.setScale(scale._);
			tileImage.setScaleXY(scaleX._, scaleY._);
		}
	}
	
	/* INTERFACE platformer.main.utils.IGrid */
	
	public function SetGridID(idx:Int, idy:Int, updatePosition:Bool = false): Void {
		this.idx = idx;
		this.idy = idy;
	}
	
	public function GridIDToString(): String {
		return "Grid [" + this.idx + "," + this.idy + "]";
	}
}