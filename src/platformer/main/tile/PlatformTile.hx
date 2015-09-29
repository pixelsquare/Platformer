package platformer.main.tile;

import flambe.animation.AnimatedFloat;
import flambe.display.ImageSprite;
import flambe.display.Texture;
import platformer.main.element.GameCollider;
import platformer.main.element.GameElement;
import platformer.main.tile.utils.TileType;

/**
 * ...
 * @author Anthony Ganzon
 */
class PlatformTile extends GameCollider
{
	public var width(default, null): AnimatedFloat;
	public var height(default, null): AnimatedFloat;
	
	public var tileType(default, null): TileType;
	public var tileLayer(default, null): Int;
	
	private var tileTexture: Texture;
	private var tileImage: ImageSprite;
	
	public function new(?texture: Texture, ?type: TileType) {
		tileTexture = texture;
		tileType = type;
		
		super();
		
		width = new AnimatedFloat(0);
		height = new AnimatedFloat(0);
		
		tileLayer = 0;
	}
	
	override public function init():Void {
		super.init();
		
		if (tileTexture == null)
			return;
			
		tileImage = new ImageSprite(tileTexture);
		tileImage.centerAnchor();
	}
	
	override public function draw():Void {
		super.draw();
		
		if (tileTexture == null)
			return;
			
		addToEntity(tileImage);
	}
	
	public function reset(): Void {
		tileTexture = null;
		tileImage = null;
		tileType = TileType.NONE;
		tileLayer = 0;
	}
	
	public function setLayer(layer: Int): Void {
		this.tileLayer = layer;
	}
	
	public function setSize(width: Float, height: Float): Void {
		this.width._ = width;
		this.height._ = height;
	}
	
	public function setTexture(texture: Texture): Void {
		this.tileTexture = texture;
	}
	
	public function setTileType(tileType: TileType): Void {
		this.tileType = tileType;
	}
	
	override public function setVisibility(visible:Bool): GameElement {
		tileImage.visible = visible;
		return super.setVisibility(visible);
	}
	
	override public function getNaturalWidth():Float {
		return tileImage != null ? tileImage.getNaturalWidth() : width._;
	}
	
	override public function getNaturalHeight():Float {
		return tileImage != null ? tileImage.getNaturalHeight() : height._;
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		
		if (tileImage != null) {
			tileImage.setAlpha(alpha._);
			tileImage.setXY(x._, y._);
			tileImage.setScale(scale._);
			tileImage.setScaleXY(scaleX._, scaleY._);
			tileImage.setRotation(rotation._);
		}
	}
	
	override public function dispose() {
		super.dispose();
		
		if(tileImage != null)
			tileImage.dispose();
			
		//if(tileTexture != null)
			//tileTexture.dispose();
	}
}