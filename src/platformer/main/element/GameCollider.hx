package platformer.main.element;

import flambe.math.Point;

/**
 * ...
 * @author Anthony Ganzon
 */
class GameCollider extends GameElement
{
	public var colliderOffset(default, null): Point;
	public var colliderMin(default, null): Point;
	public var colliderMax(default, null): Point;
	
	public function new() {
		super();
		
		colliderOffset = new Point();
		colliderMin = new Point();
		colliderMax = new Point();
	}
	
	public function setColliderOffset(offsetX: Float, offsetY: Float): Void {
		colliderOffset.x = offsetX;
		colliderOffset.y = offsetY;
		updateCollider();
	}
	
	public function updateCollider(): Void {
		colliderMin.x = x._ - colliderOffset.x;
		colliderMin.y = y._ - colliderOffset.y;
		
		colliderMax.x = x._ + colliderOffset.x;
		colliderMax.y = y._ + colliderOffset.y;
	}
	
	public function intersect(other: GameCollider): Bool { 
		var xHasNotCollided: Bool =
			colliderMin.x > other.colliderMax.x ||
			colliderMax.x < other.colliderMin.x;
			
		var yHasNotCollided: Bool =
			colliderMin.y > other.colliderMax.y ||
			colliderMax.y < other.colliderMin.y;
			
		if (xHasNotCollided || yHasNotCollided)
			return false;
			
		return true;
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		updateCollider();
	}
	
	public function colliderOffsetToString(): String {
		return "Collider Offset [" + this.colliderOffset.x + "," + this.colliderOffset.y + "]";
	}
	
	public function colliderMinToString(): String {
		return "Collider Min [" + this.colliderMin.x + "," + this.colliderMin.y + "]";
	}
	
	public function colliderMaxToString(): String {
		return "Collider Max [" + this.colliderMax.x + "," + this.colliderMax.y + "]";
	}
}