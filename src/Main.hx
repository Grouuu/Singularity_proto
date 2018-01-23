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

class Main extends App
{
	static public var instance:Main;
	
	var layer_world:Layers;
	
	var listEntities:Array<Entity> = [];
	var ent_hero:Hero;
	var ent_planet:Planet;
	
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
			500, 400
		);
		
		ent_planet.crop(0, 0);
		ent_planet.resize(200, 200);
		ent_planet.center();
		ent_planet.radiusMin = 200;
		ent_planet.gravity = 2500;
		
		var ent_planet2 = new Planet
		(
			new Bitmap(Res.spritesheet.toTile(), layer_world),
			700, 250
		);
		
		ent_planet2.crop(0, 0);
		ent_planet2.resize(200, 200);
		ent_planet2.center();
		ent_planet2.radiusMin = 200;
		ent_planet2.gravity = 12500;
		
		// hero ---------------------------------
		
		ent_hero = new Hero
		(
			new Bitmap(Tile.fromColor(0xFFFFFF, 32, 32), s2d),
			s2d.width >> 1, s2d.height >> 1
		);
		
		ent_hero.layerWorld = layer_world;
		ent_hero.center();
		ent_hero.rotation(90);
		ent_hero.vec_disp = new Vector2D(ent_hero.getWorldX(), ent_hero.getWorldY());
		ent_hero.vec_vel = new Vector2D(0, 0);
		ent_hero.vec_acc = new Vector2D(0, 0);
		
		// entities -----------------------------
		
		listEntities.push(ent_hero);
		listEntities.push(ent_planet);
		listEntities.push(ent_planet2);
		
		// path ---------------------------------
		
		img_path = new Graphics(s2d);
		img_path.lineStyle(5, 0xFF0000);
		
		layer_world.add(img_path, 0);
	}
	
	// UPDATE /////////////////////////////////////////////////////////////////////////////////////
	
	var rotKeyDown:Int = 0;
	var movKeyDown:Int = 0;
	
	override function update(dt:Float):Void
	{
		// move ---------------------------------
		
		if (Key.isDown(Key.UP) && movKeyDown != Key.DOWN)
		{
			movKeyDown = Key.UP;
			layer_world.y += 5;
		}
		else if (Key.isDown(Key.DOWN) && movKeyDown != Key.UP)
		{
			movKeyDown = Key.DOWN;
			layer_world.y -= 5;
		}
		else
			movKeyDown = 0;
		
		// hero ---------------------------------
		
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
		
		// path ---------------------------------
		
		var p:Array<Float> = getPath();
		
		img_path.clear();
		img_path.lineStyle(5, 0xFF0000);
		
		img_path.moveTo(p[0], p[1]);
		
		var i:Int = 2;
		
		while (i < p.length)
		{
			img_path.lineTo(p[i], p[++i]);
			i++;
		}
	}
	
	var isFirst = true; // TEST
	
	public function getPath():Array<Float>
	{
		// https://stackoverflow.com/questions/7205832/as3-function-for-extrapolating-points-on-a-spline-curve-or-hermite-curve-similar
		// https://stackoverflow.com/questions/10445650/coords-interpolation
		// https://code.tutsplus.com/tutorials/gravity-in-action--active-8915
		
		var path:Array<Float> = [];
		
		var nbSegment:Int = 100;
		var longSegment:Int = 3;
		
		var posX:Float = ent_hero.getWorldX();
		var posY:Float = ent_hero.getWorldY();
		var rotation:Float = ent_hero.getRotation();
		
		path[0] = posX;
		path[1] = posY;
		
		var vec_vel:Vector2D = ent_hero.vec_vel.clone();
		var vec_acc:Vector2D = ent_hero.vec_acc.clone();
		
		for (i in 0...nbSegment)
		{
			// linear position
			posX += longSegment * Math.sin(rotation);
			posY += longSegment * Math.cos(rotation);
			
			var dev:Vector2D = new Vector2D(0, 0); // total deviation
			
			// add gravity effect
			for (ent in listEntities)
			{
				var gravity:Float = ent.gravity;
				
				if (gravity > 0.0)
				{
					var entX:Float = ent.getX();
					var entY:Float = ent.getY();
					
					var vec_disp:Vector2D = new Vector2D(posX, posY);
					
					var vec_center:Vector2D = new Vector2D(entX, entY);
					vec_center.minus(vec_disp);
					
					var magnitude:Float = gravity / (vec_center.magnitude() * vec_center.magnitude());
					var direction:Float = vec_center.angle();
					var forceX:Float = magnitude * Math.cos(direction);
					var forceY:Float = magnitude * Math.sin(direction);
					
					vec_acc = new Vector2D(forceX, forceY);
					vec_acc.multiply(1 / ent_hero.mass);
					vec_vel.add(vec_acc);
					
					dev.add(vec_vel);
					
					if (isFirst)
						trace(vec_acc);
				}
			}
			
			posX += dev.x;
			posY += dev.y;
			
			path.push(posX);
			path.push(posY);
		}
		
		isFirst = false;
		
		return path;
	}
}