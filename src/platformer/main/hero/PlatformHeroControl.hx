package platformer.main.hero;

import flambe.Component;
import flambe.display.Sprite;
import flambe.input.KeyboardEvent;
import flambe.math.Point;
import flambe.System;
import flambe.input.Key;
import platformer.main.PlatformerMain;
import platformer.main.utils.HeroControlDirection;
import platformer.pxlSq.Utils;
import platformer.main.utils.GameConstants;
import platformer.main.tile.PlatformTile;
import platformer.main.utils.TileDataType;
import flambe.swf.MoviePlayer;
import flambe.math.FMath;

/**
 * ...
 * @author Anthony Ganzon
 */
class PlatformHeroControl extends Component
{
	public var isRunning(default, null): Bool;
	
	private var heroSprite: PlatformHero;
	private var heroDirection: HeroControlDirection;
	
	private var platformMain: PlatformerMain;
	private var tileGrid: Array<Array<PlatformTile>>;
	
	private var gravity: Float = -9.8;
	private var acceleration: Point = new Point();
	private var velocity: Point = new Point();
	
	private var jump: Float = 200;
	private var onAir: Bool;
	
	private var isGrounded: Bool;
	
	public function new (platformMain: PlatformerMain) { 
		this.platformMain = platformMain;
		this.tileGrid = platformMain.tileGrid;
		acceleration = new Point(0, (gravity * 500));
	}
	
	override public function onAdded() {
		super.onAdded();
		heroSprite = owner.get(PlatformHero);
		
		System.keyboard.down.connect(function(event: KeyboardEvent) {
			if (event.key == Key.W) {
				heroDirection = HeroControlDirection.UP;
			}
			
			if (event.key == Key.A) {
				heroDirection = HeroControlDirection.LEFT;
			}
			
			if (event.key == Key.S) {
				heroDirection = HeroControlDirection.DOWN;
			}
			
			if (event.key == Key.D) {
				heroDirection = HeroControlDirection.RIGHT;
			}
			
			if (event.key == Key.Space) {
				if (!isGrounded)
					return;
				
				//velocity = new Point(0, -900);
				isGrounded = false;
				onAir = true;
			}
		});
		
		System.keyboard.up.connect(function(event: KeyboardEvent) {
			var hasAnyKeyDown: Bool = System.keyboard.isDown(Key.W) || System.keyboard.isDown(Key.A) ||
				System.keyboard.isDown(Key.S) || System.keyboard.isDown(Key.D);

			if (!hasAnyKeyDown)	{
				heroDirection = HeroControlDirection.NONE;
			}
			
			if (event.key == Key.Space && onAir) {
				onAir = false;
				jump = 200;
			}
		});
	}
	
	override public function onUpdate(dt:Float) {
		super.onUpdate(dt);
		
		isRunning = false;
		isGrounded = false;
		
		if (onAir) {
			jump += 150;
			velocity = new Point(0, -jump);
			if (jump >= 700) {
				onAir = false;
				jump = 200;
			}
		}
		
		velocity.x += (acceleration.x * 0.2) * dt;
		heroSprite.x._ += (velocity.x * 0.2) * dt;
		
		if(!isGrounded) {
			velocity.y -= (acceleration.y * 0.2) * dt;		
			heroSprite.y._ += (velocity.y * 0.2) * dt;
		}
		
		//if (heroDirection == HeroControlDirection.UP) {
			//heroSprite.y._ -= GameConstants.HERO_SPEED * dt;
		//}
		if (heroDirection == HeroControlDirection.LEFT) {
			heroSprite.x._ -= GameConstants.HERO_SPEED * dt;
			heroSprite.scaleX._ = -1;
			isRunning = true;
		}
		//if (heroDirection == HeroControlDirection.DOWN) {
			//heroSprite.y._ += GameConstants.HERO_SPEED * dt;
		//}
		if (heroDirection == HeroControlDirection.RIGHT) {
			heroSprite.x._ += GameConstants.HERO_SPEED * dt;
			heroSprite.scaleX._ = 1;
			isRunning = true;
		}
		
		var baseRow = Math.floor(heroSprite.x._ / GameConstants.TILE_WIDTH);
		var baseCol = Math.floor(heroSprite.y._ / GameConstants.TILE_HEIGHT);
		var rowOverlap = heroSprite.x._ % GameConstants.TILE_WIDTH;
		var colOverlap = heroSprite.y._ % GameConstants.TILE_HEIGHT;
		
		//Utils.ConsoleLog(baseCol + " " + baseRow + " " + colOverlap + " " + rowOverlap);
		//var tileGrid: Array<Array<PlatformTile>> = platformMain.tileGrid;
		//if ((tileGrid[baseRow][baseCol + 1] && !tileGrid[baseRow][baseCol]) || (tileGrid[baseRow + 1][baseCol + 1] && !tileGrid[baseRow + 1][baseCol] && rowOverlap)) {
			//heroSprite.x._ = baseCol * GameConstants.TILE_WIDTH;
		//}
		
		//if (heroDirection == HeroControlDirection.RIGHT) {
			//Utils.ConsoleLog(baseRow + " " + baseCol + " " + rowOverlap + " " + colOverlap + " " + tileGrid[baseRow + 1][baseCol].GetTileDataType());
			if (tileGrid[baseRow + 1][baseCol].GetTileDataType() != TileDataType.NONE && heroSprite.x._ >= (baseRow * GameConstants.TILE_WIDTH) + 20) {
				heroSprite.x._ = (baseRow * GameConstants.TILE_WIDTH) + 20;
			}
		//}
		
		//if (heroDirection == HeroControlDirection.LEFT) {
			if (tileGrid[baseRow - 1][baseCol].GetTileDataType() != TileDataType.NONE && heroSprite.x._ <= ((baseRow + 1) * GameConstants.TILE_WIDTH) - 20) {
				heroSprite.x._ = ((baseRow + 1) * GameConstants.TILE_WIDTH) - 20;
			}
		//}
		
		//if (heroDirection == HeroControlDirection.UP) {
			if (tileGrid[baseRow][baseCol - 1].GetTileDataType() != TileDataType.NONE && heroSprite.y._ <= ((baseCol + 1) * GameConstants.TILE_HEIGHT) - 20) {
				heroSprite.y._ = ((baseCol + 1) * GameConstants.TILE_HEIGHT) - 20;
			}
		//}
		
		//if (heroDirection == HeroControlDirection.DOWN) {
			if (tileGrid[baseRow][baseCol + 1].GetTileDataType() != TileDataType.NONE && heroSprite.y._ >= (baseCol * GameConstants.TILE_HEIGHT) + 20) {
				heroSprite.y._ = (baseCol * GameConstants.TILE_HEIGHT) + 20;
				velocity.y = 0;
				isGrounded = true;
			}
		//}
		
		var moviePlayer: MoviePlayer = owner.firstChild.get(MoviePlayer);
		if (moviePlayer != null) {
			if(moviePlayer.looping) {
				moviePlayer.loop(isRunning ? "hero_dash" : "hero_idle", false);
			}
		}
	}
}