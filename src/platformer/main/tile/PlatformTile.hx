package platformer.main.tile;

import flambe.display.ImageSprite;
import flambe.display.Texture;
import platformer.main.element.GameElement;
import platformer.main.utils.IGrid;
import platformer.main.utils.TileDataType;
import platformer.pxlSq.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class PlatformTile extends GameElement implements IGrid
{
	public var idx(default, null): Int;
	public var idy(default, null): Int;
	
	private var tileTexture: Texture;
	private var tileImage: ImageSprite;
	
	public function new(texture: Texture) {
		this.tileTexture = texture;
		super();
	}
	
	override public function Init():Void {
		super.Init();
		
		tileImage = new ImageSprite(tileTexture);
		tileImage.centerAnchor();
	}
	
	override public function Draw():Void {
		super.Draw();

		AddToEntity(tileImage);
	}
	
	override public function GetNaturalWidth(): Float {
		return tileImage.getNaturalWidth();
	}
	
	override public function GetNaturalHeight(): Float {
		return tileImage.getNaturalHeight();
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
	
	public function GetTileDataType(): TileDataType {
		return TileDataType.NONE;
	}
	
	public function SetGridID(idx: Int, idy: Int, updatePosition: Bool = false): Void {
		this.idx = idx;
		this.idy = idy;
	}
	
	public function GridIDToString(): String {
		return "Grid [" + this.idx + "," + this.idy + "]";
	}
}