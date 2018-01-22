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
		ent_planet.gravity = 500;
		
		// hero ---------------------------------
		
		ent_hero = new Hero
		(
			new Bitmap(Tile.fromColor(0xFFFFFF, 32, 32), s2d),
			s2d.width >> 1, s2d.height >> 1
		);
		
		ent_hero.layerWorld = layer_world;
		ent_hero.center();
		ent_hero.rotation(90);
		
		// entities -----------------------------
		
		listEntities.push(ent_hero);
		listEntities.push(ent_planet);
		
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
		
		for (i in 0...nbSegment)
		{
			// linear position
			posX += longSegment * Math.sin(rotation);
			posY += longSegment * Math.cos(rotation);
			
			var devX:Float = 0.0;
			var devY:Float = 0.0;
			
			// add gravity effect
			for (ent in listEntities)
			{
				var gravity:Float = ent.gravity;
				
				if (gravity > 0.0)
				{
					var entX:Float = ent.getX();
					var entY:Float = ent.getY();
					
					var dx:Float = posX - entX;
					var dy:Float = posY - entY;
					var dist:Float = Math.sqrt(dx * dx + dy * dy);
					var angle:Float = Math.atan2(posY - entY, posX - entX);
					var force:Float = 1 / dist * 100;
					
					var dirX:Int = posX < entX ? 1 : -1;
					var dirY:Int = posY < entY ? 1 : -1;
					
					// TODO : le rapport de force doit être plus carré que ça (là ça arrive à "repousser" déjà...)
					
					devX += dirX * force * Math.sin(angle);
					devY += dirY * force * Math.cos(angle);
					//devX += force * Math.sin(angle);
					//devY += force * Math.cos(angle);
					
					if (isFirst)
					{
						//trace(entX, entY, dist, angle, force, devX, devY);
						trace(force, dist, devX, devY);
					}
				}
			}
			
			posX += devX;
			posY += devY;
			
			path.push(posX);
			path.push(posY);
		}
		
		isFirst = false;
		
		/*img_path.clear();
		img_path.lineStyle(5, 0xFF0000);
		img_path.moveTo(ent_hero.getWorldX(), ent_hero.getWorldY());
		img_path.lineTo(ent_planet.getX(), ent_planet.getY());*/
		
		return path;
		
		// TODO :
		// • loop sur les entités
		// • décaler le point suivant de la distance de base puis appliquer les effets des gravités des autres entités et déplacer ce point
		// • selon la vitesse, changer ? la distance de base ? le nombre de point ?
	}
}