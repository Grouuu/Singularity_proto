package ;

import com.grouuu.entities.Hero;
import com.grouuu.entities.Planet;
import com.grouuu.Entity;
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
		
		// hero ---------------------------------
		
		ent_hero = new Hero
		(
			new Bitmap(Tile.fromColor(0xFFFFFF, 32, 32), s2d),
			s2d.width >> 1, s2d.height >> 1
		);
		
		ent_hero.layerWorld = layer_world;
		ent_hero.center();
		ent_hero.rotation(45);
		
		// entities -----------------------------
		
		listEntities.push(ent_hero);
		listEntities.push(ent_planet);
		
		// path ---------------------------------
		
		// TODO : path
		//var curve:Spiro
		// https://github.com/nanjizal/hxSpiroKhaG2/tree/master/Source/spiroHelpers
		// https://github.com/nanjizal/hxSpiro
		
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
		
		var p:Array<Int> = path.getPath();
		
		img_path.clear();
		img_path.lineStyle(5, 0xFF0000);
		
		img_path.moveTo(ent_hero.getWorldX(), ent_hero.getWorldY());
		
		var i:Int = 0;
		
		while (i < p.length)
		{
			img_path.lineTo(p[i], p[++i]);
			i++;
		}
	}
}