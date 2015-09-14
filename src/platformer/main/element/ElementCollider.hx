package platformer.main.element;

import flambe.math.Point;

import platformer.main.element.GameElement;
import platformer.pxlSq.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class ElementCollider extends GameElement
{
	public var colliderOffset(default, null): Point;
	public var colliderMin(default, null): Point;
	public var colliderMax(default, null): Point;
	
	private static inline var COLLIDER_PRECISION: Float = 0.9;
	
	public function new() {
		super();
		
		this.colliderOffset = new Point();
		this.colliderMin = new Point();
		this.colliderMax = new Point();
	}
	
	public function SetColliderOffset(offsetX: Float, offsetY: Float): Void {
		this.colliderOffset = new Point(offsetX, offsetY);
	}
	
	override public function onAdded() {
		super.onAdded();
		
		var offsetX: Float = GetNaturalWidth() / 2;
		var offsetY: Float = GetNaturalHeight() / 2;
		colliderOffset = new Point(offsetX, offsetY);
	}
	
	public function HasCollided(other: ElementCollider): Bool {
		var xHasNotCollided: Bool = 
			colliderMin.x > other.colliderMax.x ||
			colliderMax.x < other.colliderMin.x;

		var yHasNotCollided: Bool =
			colliderMin.y > other.colliderMax.y ||
			colliderMax.y < other.colliderMin.y;
			
		//var xHasNotCollided: Bool =
			//x._ - colliderOffset.x >
			//other.x._ + other.colliderOffset.x ||
			//x._ + colliderOffset.x <
			//other.x._ - other.colliderMax.x;
			//
		//var yHasNotCollided: Bool =
			//y._ - colliderOffset.y >
			//other.y._ + other.colliderOffset.y ||
			//y._ + colliderOffset.y <
			//other.y._ - other.colliderMax.y;
			
		if (xHasNotCollided || yHasNotCollided)
			return false;
		
		return true;
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		
		colliderMin = new Point(x._ - colliderOffset.x * COLLIDER_PRECISION, y._ - colliderOffset.y * COLLIDER_PRECISION);
		colliderMax = new Point(x._ + colliderOffset.x * COLLIDER_PRECISION, y._ + colliderOffset.y * COLLIDER_PRECISION);
	}
	
	public function ColliderOffsetToString(): String {
		return "Collider Offset [" + this.colliderOffset.x + "," + this.colliderOffset.y + "]";
	}
	
	public function ColliderMinToString(): String {
		return "Collider Min [" + this.colliderMin.x + "," + this.colliderMin.y + "]";
	}
	
	public function ColliderMaxToString(): String {
		return "Collider Max [" + this.colliderMax.x + "," + this.colliderMax.y + "]";
	}
}