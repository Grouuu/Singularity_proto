package ;

import com.grouuu.entities.Hero;
import com.grouuu.entities.Planet;
import com.grouuu.Entity;
import com.grouuu.Vector2D;
import h2d.Bitmap;
import h2d.Graphics;
import h2d.Layers;
import h2d.Tile;
import hxd.App;
import hxd.Key;
import hxd.Res;

/**
 * ...
 * @author Grouuu
 */

typedef NextStep =
{
	var position:Vector2D;
	var velocity:Vector2D;
	var positionHit:Vector2D;
}

class Main extends App
{
	static public var instance:Main;
	
	var layer_world:Layers;
	
	var listEntities:Array<Entity> = [];
	var ent_hero:Hero;
	var ent_planet:Planet;
	var ent_planet2:Planet;
	
	var img_bg:Bitmap;
	var img_path:Graphics;
	
	// INIT ///////////////////////////////////////////////////////////////////////////////////////
	
	static function main()
	{
		#if js
			Res.initEmbed( { compressSounds: true } );
		#end
		
		instance = new Main();
	}
	
	override function init():Void
	{
		layer_world = new Layers(s2d);
		
		// background ---------------------------
		
		img_bg = new Bitmap(Tile.fromColor(0x000000, s2d.width, s2d.height), layer_world);
		
		// planet -------------------------------
		
		ent_planet = new Planet
		(
			new Bitmap(Res.spritesheet.toTile(), layer_world),
			500, 500
		);
		
		ent_planet.crop(0, 0);
		ent_planet.resize(200, 200);
		ent_planet.center();
		ent_planet.mass = 2;
		ent_planet.solidRadius = 80;
		
		ent_planet2 = new Planet
		(
			new Bitmap(Res.spritesheet.toTile(), layer_world),
			700, 150
		);
		
		ent_planet2.crop(0, 0);
		ent_planet2.resize(200, 200);
		ent_planet2.center();
		ent_planet2.mass = 2;
		ent_planet2.solidRadius = 80;
		
		// hero ---------------------------------
		
		ent_hero = new Hero
		(
			new Bitmap(Tile.fromColor(0xFFFFFF, 32, 32), s2d),
			s2d.width >> 1, s2d.width >> 1
		);
		
		ent_hero.decalX = ent_hero.getX();
		ent_hero.decalY = ent_hero.getY();
		ent_hero.layerWorld = layer_world;
		ent_hero.center();
		ent_hero.mass = 10;
		ent_hero.vec_vel = new Vector2D(15, -6); // TEST
		
		// entities -----------------------------
		
		//listEntities.push(ent_hero);
		listEntities.push(ent_planet);
		listEntities.push(ent_planet2);
		
		// path ---------------------------------
		
		img_path = new Graphics(s2d);
		
		layer_world.add(img_path, 0);
	}
	
	// UPDATE /////////////////////////////////////////////////////////////////////////////////////
	
	var rotKeyDown:Int = 0;
	var movKeyDown:Int = 0;
	var isCrashed:Bool = false;
	
	var firstInc:Int = 0; // TEST
	var isFirst = true; // TEST
	
	override function update(dt:Float):Void
	{
		// key ----------------------------------
		
		var incRot:Float = 10 * Math.PI / 180;
		var incSpeed:Float = 0.1; // percent ?
		
		// rotation
		
		if (Key.isPressed(Key.RIGHT))
			ent_hero.vec_vel.rotate(incRot);
		else if (Key.isPressed(Key.LEFT))
			ent_hero.vec_vel.rotate( -incRot);
		
		// speed
		
		if (Key.isPressed(Key.UP))
			ent_hero.vec_vel.multiply(1 + incSpeed);
		else if (Key.isPressed(Key.DOWN))
			ent_hero.vec_vel.multiply(1 - incSpeed);
		
		// position -----------------------------
		
		if (!isCrashed)
		{
			var nextStep:NextStep;
			
			// move -----------------------------
			
			var heroX:Float = ent_hero.getWorldX();
			var heroY:Float = ent_hero.getWorldY();
			var heroVel:Vector2D = ent_hero.vec_vel;
			
			nextStep = getNextPosition(heroX, heroY, heroVel);
			
			if (nextStep.positionHit == null)
			{
				nextStep.velocity.multiply(dt);
				
				layer_world.x -= nextStep.velocity.x;
				layer_world.y -= nextStep.velocity.y;
				
				ent_hero.vec_vel = nextStep.velocity;
				
				// path -----------------------------
				
				img_path.clear();
				
				var nbSegment:Int = 100;
				
				var nextX:Float = ent_hero.getWorldX();
				var nextY:Float = ent_hero.getWorldY();
				var nextVel:Vector2D = ent_hero.vec_vel.clone();
				var oldX:Float = nextX;
				var oldY:Float = nextY;
				
				for (i in 0...nbSegment)
				{
					nextStep = getNextPosition(nextX, nextY, nextVel);
					
					nextX = nextStep.position.x;
					nextY = nextStep.position.y;
					nextVel = nextStep.velocity;
					
					if (nextStep.positionHit != null)
					{
						nextX = oldX + nextStep.positionHit.x;
						nextY = oldY + nextStep.positionHit.y;
					}
					
					img_path.lineStyle(5, 0xFF0000, 1 - (1 / nbSegment) * i);
					img_path.moveTo(oldX, oldY);
					img_path.lineTo(nextX, nextY);
					
					oldX = nextX;
					oldY = nextY;
					
					if (nextStep.positionHit != null)
						break;
				}
				
				if (isFirst)
					trace(layer_world.x, layer_world.y);
			}
			else
			{
				isCrashed = true;
				
				layer_world.x -= -nextStep.positionHit.x;
				layer_world.y -= -nextStep.positionHit.y;
			}
		}
		
		// --------------------------------------
		
		firstInc++;
		
		if (firstInc > 20)
			isFirst = false;
	}
	
	public function getNextPosition(currentX:Float, currentY:Float, currentVel:Vector2D):NextStep
	{
		var pos:Vector2D = new Vector2D(currentX, currentY);
		var vel:Vector2D = currentVel.clone();
		var m:Float = ent_hero.mass;
		var K:Float = 500;
		var capEnt:Float = 5;
		var capMove:Float = 5;
		
		var devVel:Vector2D = new Vector2D();
		var posHit:Vector2D = null;
		
		for (ent in listEntities)
		{
			var entX:Float = ent.getX();
			var entY:Float = ent.getY();
			var M:Float = ent.mass;
			
			var toCenter:Vector2D = new Vector2D(entX, entY);
			toCenter.minus(pos);
			
			var centerMagnitude:Float = toCenter.magnitude();
			var centerDirection:Float = toCenter.angle();
			
			var magnitude:Float = (K * m * M) / (centerMagnitude * centerMagnitude); // F = K * m * M / r²
			
			var forceX:Float = magnitude * Math.cos(centerDirection);
			var forceY:Float = magnitude * Math.sin(centerDirection);
			
			var acc:Vector2D = new Vector2D(forceX, forceY); // a = F/m
			acc.multiply(1 / m);
			
			devVel.add(acc);
			
			if (centerMagnitude <= ent.solidRadius)
			{
				posHit = toCenter.normalize().multiply(ent.solidRadius / centerMagnitude);
				break;
			}
		}
		
		vel.add(devVel);
		
		// TODO : j'ai trop besoin de cap les magnitude, je trouve ça pas normal
		// voir pourquoi l'accélération est si importante
		
		while (vel.magnitude() > capMove)
			vel = vel.normalize().multiply(capMove);
		
		pos.add(vel);
		
		return { position: pos, velocity: vel, positionHit: posHit };
	}
}