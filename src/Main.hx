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

typedef PathSegment =
{
	var x:Float;
	var y:Float;
	var velocity:Vector2D;
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
		ent_planet.mass = 20;
		ent_planet.solidRadius = 100;
		
		ent_planet2 = new Planet
		(
			new Bitmap(Res.spritesheet.toTile(), layer_world),
			700, 150
		);
		
		ent_planet2.crop(0, 0);
		ent_planet2.resize(200, 200);
		ent_planet2.center();
		ent_planet2.mass = 20;
		ent_planet2.solidRadius = 100;
		
		// hero ---------------------------------
		
		ent_hero = new Hero
		(
			new Bitmap(Tile.fromColor(0xFFFFFF, 32, 32), s2d),
			s2d.width >> 1, s2d.width >> 1
		);
		
		ent_hero.layerWorld = layer_world;
		ent_hero.center();
		ent_hero.mass = 10;
		ent_hero.vec_vel = new Vector2D(0.1, -0.2); // TEST
		
		// entities -----------------------------
		
		//listEntities.push(ent_hero);
		listEntities.push(ent_planet);
		listEntities.push(ent_planet2);
		
		// path ---------------------------------
		
		img_path = new Graphics(s2d);
		//img_path.lineStyle(5, 0xFF0000);
		//img_path.x = layer_world.x;
		//img_path.y = layer_world.y;
		
		layer_world.add(img_path, 0);
	}
	
	// UPDATE /////////////////////////////////////////////////////////////////////////////////////
	
	var rotKeyDown:Int = 0;
	var movKeyDown:Int = 0;
	var crashed:Bool = false;
	
	//var nbSegment:Int = 500;
	//var longSegment:Int = 3;
	
	override function update(dt:Float):Void
	{
		// key ----------------------------------
		
		if (Key.isDown(Key.RIGHT) && rotKeyDown != Key.LEFT)
		{
			rotKeyDown = Key.RIGHT;
			ent_hero.rotation(ent_hero.incRotation * dt);
		}
		else if (Key.isDown(Key.LEFT) && rotKeyDown != Key.RIGHT)
		{
			rotKeyDown = Key.LEFT;
			ent_hero.rotation(-ent_hero.incRotation * dt);
		}
		else
			rotKeyDown = 0;
		
		// position -----------------------------
		
		if (!crashed)
		{
			var nextStep:Array<Vector2D>;
			
			// move -----------------------------
			
			var heroX:Float = ent_hero.getWorldX();
			var heroY:Float = ent_hero.getWorldY();
			var heroVel:Vector2D = ent_hero.vec_vel;
			
			nextStep = getNextPosition(heroX, heroY, heroVel, dt);
			
			layer_world.x -= nextStep[1].x;
			layer_world.y -= nextStep[1].y;
			
			heroVel = nextStep[1];
			heroVel.multiply(dt);
			
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
				nextStep = getNextPosition(nextX, nextY, nextVel, 1);
				
				nextX = nextStep[0].x;
				nextY = nextStep[0].y;
				nextVel = nextStep[1];
				
				img_path.lineStyle(5, 0xFF0000, 1 - (1 / nbSegment) * i);
				img_path.moveTo(oldX, oldY);
				img_path.lineTo(nextX, nextY);
				
				oldX = nextX;
				oldY = nextY;
			}
		}
		
		// --------------------------------------
		
		firstInc++;
		
		if (firstInc > 20)
			isFirst = false;
	}
	
	public function getNextPosition(currentX:Float, currentY:Float, currentVel:Vector2D, dt:Float):Array<Vector2D>
	{
		var pos:Vector2D = new Vector2D(currentX, currentY);
		var m:Float = ent_hero.mass;
		var K:Float = 500;
		
		var devVel:Vector2D = new Vector2D();
		
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
			
			// TODO : mettre un cap à cette magnitude ?
			
			var forceX:Float = magnitude * Math.cos(centerDirection);
			var forceY:Float = magnitude * Math.sin(centerDirection);
			
			var acc:Vector2D = new Vector2D(forceX, forceY); // a = F/m
			acc.multiply(1 / m);
			
			devVel.add(acc);
		}
		
		var vel:Vector2D = currentVel.clone();
		vel.multiply(dt);
		vel.add(devVel);
		
		pos.add(vel);
		
		return [pos, vel];
	}
	
	var firstInc:Int = 0; // TEST
	var isFirst = true; // TEST
}