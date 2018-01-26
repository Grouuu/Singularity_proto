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
		layer_world.x = s2d.width >> 1;
		layer_world.y = s2d.height >> 1;
		
		// background ---------------------------
		
		img_bg = new Bitmap(Tile.fromColor(0x000000, s2d.width, s2d.height), layer_world);
		
		// planet -------------------------------
		
		ent_planet = new Planet
		(
			new Bitmap(Res.spritesheet.toTile(), layer_world),
			100, 200
		);
		
		ent_planet.crop(0, 0);
		ent_planet.resize(200, 200);
		ent_planet.center();
		ent_planet.mass = 20;
		ent_planet.solidRadius = 100;
		
		ent_planet2 = new Planet
		(
			new Bitmap(Res.spritesheet.toTile(), layer_world),
			300, -150
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
			layer_world.x, layer_world.y
		);
		
		ent_hero.decalX = layer_world.x;
		ent_hero.decalY = layer_world.y;
		ent_hero.layerWorld = layer_world;
		ent_hero.center();
		//ent_hero.rotation(90);
		ent_hero.mass = 10;
		ent_hero.vec_vel = new Vector2D(0, 0);
		
		// entities -----------------------------
		
		//listEntities.push(ent_hero);
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
	var crashed:Bool = false;
	
	//var nbSegment:Int = 500;
	//var longSegment:Int = 3;
	
	override function update(dt:Float):Void
	{
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
		
		// TODO : hum, le soucis c'est que chaque "mesure" doit être de distance en distance, et non de vélocité en vélocité
		// que ce soir pour le path que pour le héros
		
		// move ---------------------------------
		
		if (!crashed)
		{
			var hero_v:Vector2D = ent_hero.vec_vel;			// velocity
			var hero_px:Float = ent_hero.getWorldX();		// position X
			var hero_py:Float = ent_hero.getWorldY();		// position Y
			var hero_phm:Float = ent_hero.mass;				// mass
			
			var pos:Vector2D = new Vector2D(hero_px, hero_py);
			//var pos:Vector2D = getSimplePosition(hero_px, hero_py, hero_v.angle(), hero_v, dt);
			
			for (ent in listEntities)
			{
				if (ent != ent_hero)
					addGravity(pos, hero_v, ent.getX(), ent.getY(), hero_phm, ent.mass);
			}
			
			//pos.add(hero_v);
			
			layer_world.x -= hero_v.x * dt;
			layer_world.y -= hero_v.y * dt;
			
			for (ent in listEntities)
			{
				if (ent != ent_hero)
				{
					var dx:Float = ent_hero.getWorldX() - ent.getX();
					var dy:Float = ent_hero.getWorldY() - ent.getY();
					var dist:Float = Math.sqrt(dx * dx + dy * dy);
					
					if (dist <= ent.solidRadius)
					{
						crashed = true;
						break;
					}
				}
			}
		}
		
		// path ---------------------------------
		
		// TEST
		ent_hero.vec_vel = new Vector2D(0.5, 0);
		//
		
		// TODO : calculer le nbSegment mais par rapport à une distance min/max ? tant que le tracé reste + ou - dans l'écran hein
		
		img_path.clear();
		
		var nbSegment:Int = 500;
		var i:Int = 1;
		
		var v:Vector2D = ent_hero.vec_vel;		// hero velocity
		var px:Float = ent_hero.getWorldX();	// hero position X
		var py:Float = ent_hero.getWorldY();	// hero position Y
		var phm:Float = ent_hero.mass;			// hero mass
		
		var pl1x:Float = ent_planet.getX();
		var pl1y:Float = ent_planet.getY();
		var pl1m:Float = ent_planet.mass;
		var pl2x:Float = ent_planet2.getX();
		var pl2y:Float = ent_planet2.getY();
		var pl2m:Float = ent_planet2.mass;
		
		var p:Vector2D; 	// position
		var dev:Vector2D;	// deviation
		
		var newVel:Vector2D = v.clone();
		//var newAngle:Float = newVel.angle();
		
		var oldX:Float = px;
		var oldY:Float = py;
		
		var isCrashed:Bool = false;
		
		while (i <= nbSegment)
		{
			//p = getSimplePosition(px, py, newAngle, newVel, 1);
			p = new Vector2D(px, py);
			//p.add(newVel);
			
			//dev = new Vector2D();
			
			//addGravity(p, dev, pl1x, pl1y, phm, pl1m);
			addGravity(p, newVel, pl1x, pl1y, phm, pl1m);
			//addGravity(p, dev, pl2x, pl2y, phm, pl2m);
			addGravity(p, newVel, pl2x, pl2y, phm, pl2m);
			
			//newVel.add(dev);
			//newAngle = newVel.angle();
			
			p.add(newVel);
			
			px = p.x;
			py = p.y;
			
			img_path.lineStyle(5, 0xFF0000, 1 - (1 / nbSegment) * i);
			img_path.moveTo(oldX, oldY);
			img_path.lineTo(px, py);
			
			var j:Int = 0;
			
			for (ent in listEntities)
			{
				if (ent != ent_hero)
				{
					var dx:Float = px - ent.getX();
					var dy:Float = py - ent.getY();
					var dist:Float = Math.sqrt(dx * dx + dy * dy);
					
					if (dist <= ent.solidRadius)
					{
						isCrashed = true;
						break;
					}
				}
			}
			
			oldX = px;
			oldY = py;
			
			if (isCrashed)
				break;
			
			i++;
		}
		
		/*var hero_v:Vector2D = ent_hero.vec_vel;			// velocity
		var hero_px:Float = ent_hero.getWorldX();		// position X
		var hero_py:Float = ent_hero.getWorldY();		// position Y
		var hero_phm:Float = ent_hero.mass;				// mass
		
		//var pos:Vector2D = new Vector2D(hero_px, hero_py);
		//pos.add(hero_v);
		
		//layer_world.x -= pos.x * dt;
		//layer_world.y -= pos.y * dt;
		
		layer_world.x -= hero_v.x * dt;
		layer_world.y -= hero_v.y * dt;
		
		if (isFirst)
			trace(hero_px, hero_py, layer_world.x, layer_world.y, hero_v, dt);*/
		
		/*for (ent in listEntities)
		{
			if (ent != ent_hero)
				addGravity(pos, new Vector2D(), ent_hero.vec_vel, ent.getX(), ent.getY(), ent_hero.mass, ent.mass);
		}*/
		
		//ent_hero.vec_vel.multiply(dt);
		
		// --------------------------------------
		
		firstInc++;
		
		if (firstInc > 20)
			isFirst = false;
	}
	
	var firstInc:Int = 0; // TEST
	var isFirst = true; // TEST
	
	public function getSimplePosition(x:Float, y:Float, angle:Float, vel:Vector2D, dt:Float = 1):Vector2D
	{
		// x   			position actuelle en x
		// y   			position actuelle en y
		// angle   		angle du mouvement en radian
		// vel   		vecteur de vélocité
		// dt   		variation du temps entre chaque frame (1 si parfait)
		
		var pos:Vector2D = new Vector2D(x, y); // position actuelle
		
		//var dirX:Int = (vel.x < 0)? -1 : 1;
		//var dirY:Int = (vel.y < 0)? -1 : 1;
		
		// projection linéaire
		//var projX:Float = vel.x * Math.cos(angle) * dirX;
		//var projY:Float = vel.y * Math.sin(angle) * dirY;
		
		pos.add(vel);
		
		//pos.x += projX * dt;
		//pos.y += projY * dt;
		
		return pos;
	}
	
	public function addGravity(pos:Vector2D, vel:Vector2D, entX:Float, entY:Float, m:Float, M:Float):Void
	{
		// pos   		position sans influence du point
		// vel   		vélocité précédente
		// entX/entY	position du corps influent
		// m   			masse du point
		// M   			masse du corps influent
		
		var K:Float = 500;
		
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
		
		vel.add(acc);
		
		pos.add(vel);
	}
	
	
	/*var vec_disp:Vector2D = new Vector2D(posX, posY);
	
	var vec_center:Vector2D = new Vector2D(entX, entY);
	vec_center.minus(vec_disp);
	
	var magnitude:Float = gravity / (vec_center.magnitude() * vec_center.magnitude());
	
	var direction:Float = vec_center.angle();
	var forceX:Float = magnitude * Math.cos(direction);
	var forceY:Float = magnitude * Math.sin(direction);
	
	var vec_acc:Vector2D = new Vector2D(forceX, forceY);
	vec_acc.multiply(1 / ent_hero.mass);
	
	vec_vel.add(vec_acc);
	
	dev.add(vec_vel);*/
	
	// x, y = position actuelle du héro
	// angle = rad (0 = vers les X positifs)
	// speed = pixel/frame
	
	// calcul le déplacement sans influence
	
	/*angle = angle * Math.PI / 180; // degree -> rad
	
	var pX:Float = 0.0;
	var pY:Float = 0.0;
	
	if (angle != 0)
	{
		pX = speed * Math.sin(angle) * dt;
		pY = speed * Math.cos(angle) * dt;
	}
	else
	{
		pX = speed * dt;
		pY = 0;
	}
	
	if (isFirst)
		trace(angle, pX, pY);
	
	var vDisp:Vector2D = new Vector2D(pX, pY); // displacement
	
	return vDisp;*/
	
	/*public function getPath():Array<PathSegment>
	{
		var path:Array<PathSegment> = [];
		
		var posX:Float = ent_hero.getWorldX();
		var posY:Float = ent_hero.getWorldY();
		var rotation:Float = ent_hero.getRotation();
		
		//var vec_vel:Vector2D = new Vector2D(0, 0);
		var vec_vel:Vector2D = ent_hero.vec_vel;
		
		var crashed:Bool = false;
		
		for (i in 0...nbSegment)
		{
			// https://code.tutsplus.com/tutorials/gravity-in-action--active-8915
			
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
					
					var vec_acc:Vector2D = new Vector2D(forceX, forceY);
					vec_acc.multiply(1 / ent_hero.mass);
					
					vec_vel.add(vec_acc);
					
					dev.add(vec_vel);
				}
			}
			
			posX += dev.x;
			posY += dev.y;
			
			for (ent in listEntities)
			{
				if (ent.solidRadius > 0.0)
				{
					var entX:Float = ent.getX();
					var entY:Float = ent.getY();
					
					var dx:Float = posX - entX;
					var dy:Float = posY - entY;
					
					var dist:Float = Math.sqrt(dx * dx + dy * dy);
					
					if (isFirst)
						trace(dist, ent.solidRadius);
					
					if (dist < ent.solidRadius)
						crashed = true;
				}
			}
			// TODO : tester si collision avec un corps dur, si oui couper la liste ici
			
			if (!crashed)
				path.push( { x: posX, y: posY, velocity: dev.clone() } );
			else
				break;
		}
		
		isFirst = false; // TEST
		
		return path;
	}*/
}