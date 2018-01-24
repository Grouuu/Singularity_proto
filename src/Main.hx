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
		ent_planet.mass = 200;
		//ent_planet.radiusMin = 200;
		//ent_planet.solidRadius = 100;
		
		ent_planet2 = new Planet
		(
			new Bitmap(Res.spritesheet.toTile(), layer_world),
			700, 150
		);
		
		ent_planet2.crop(0, 0);
		ent_planet2.resize(200, 200);
		ent_planet2.center();
		ent_planet2.mass = 200;
		//ent_planet2.radiusMin = 200;
		//ent_planet2.solidRadius = 100;
		
		// hero ---------------------------------
		
		ent_hero = new Hero
		(
			new Bitmap(Tile.fromColor(0xFFFFFF, 32, 32), s2d),
			s2d.width >> 1, s2d.height >> 1
		);
		
		ent_hero.layerWorld = layer_world;
		ent_hero.center();
		ent_hero.rotation(90);
		ent_hero.mass = 10;
		ent_hero.vec_vel = new Vector2D(0, 0);
		
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
	
	var nbSegment:Int = 500;
	var longSegment:Int = 3;
	
	override function update(dt:Float):Void
	{
		// dt = temps en millisecond entre deux frames ?
		
		//trace(dt);
		
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
		
		//ent_hero.angle = 0.0;
		
		/*var p:Array<PathSegment> = getPath();
		
		img_path.clear();
		
		var i:Int = 1;
		
		while (i < p.length)
		{
			img_path.lineStyle(5, 0xFF0000, 1 - (1 / nbSegment) * i);
			img_path.moveTo(p[i - 1].x, p[i - 1].y);
			img_path.lineTo(p[i].x, p[i].y);
			i++;
		}*/
		
		// move ---------------------------------
		
		/*if (p[0] != null)
		{
			layer_world.x -= p[0].velocity.x;
			layer_world.y -= p[0].velocity.y;
			
			ent_hero.vec_vel = p[0].velocity;
		}*/
		
		// TODO : le hero ne suit pas la ligne (soucis de vel, comme elle est reset à chaque frame ?)
		// le déplacement du héros ne suit peut-être pas le step du path (là il va beaucoup trop vite)
		// de plus la vitesse doit pouvoir être modifiée par le joueur
		
		//else
			//trace("CRASH");
		
		//var move:Vector2D = getPosition(layer_world.x, layer_world.y, 90, 5, new Vector2D(0, 0), dt);
		
		//layer_world.x -= move.x;
		//layer_world.y -= move.y;
		
		//trace(layer_world.x, layer_world.y);
		
		//var dir:Vector2D = new Vector2D(0, 0);
		
		// --------------------------------------
		
		if (false)
		{
			var angle:Float = 0; 							// remplacer par value Hero
			var vel:Vector2D = new Vector2D(250, 0); 		// remplacer par value Hero
			
			var pos:Vector2D = getSimplePosition(ent_hero.getWorldX(), ent_hero.getWorldY(), angle, vel, 1);
			
			vel.reset();
			
			var acc:Vector2D = new Vector2D(0, 0);
			
			addGravity(pos, acc, vel, ent_planet.getX(), ent_planet.getY(), ent_hero.mass, ent_planet2.mass);
			addGravity(pos, acc, vel, ent_planet2.getX(), ent_planet2.getY(), ent_hero.mass, ent_planet2.mass);
			
			angle = vel.angle();
			
			// NOTE : angle, acc et vel ont été update et sont donc réutilisable pour ajouter d'autres influences
		}
		
		// --------------------------------------
		
		img_path.clear();
		
		var i:Int = 1;
		
		var a:Float = 0; // angle
		var acc:Vector2D;
		var v:Vector2D = new Vector2D(10, 0);
		var p:Vector2D;
		var px:Float = ent_hero.getWorldX();
		var py:Float = ent_hero.getWorldY();
		var phm:Float = ent_hero.mass;
		var pl1x:Float = ent_planet.getX();
		var pl1y:Float = ent_planet.getY();
		var pl1m:Float = ent_planet.mass;
		var pl2x:Float = ent_planet2.getX();
		var pl2y:Float = ent_planet2.getY();
		var pl2m:Float = ent_planet2.mass;
		
		var oldX:Float = px;
		var oldY:Float = py;
		
		while (i < 20)
		{
			p = getSimplePosition(px, py, a, v, 1);
			
			v.reset();
			
			acc = new Vector2D(0, 0);
			
			addGravity(p, acc, v, pl1x, pl1y, phm, pl1m);
			addGravity(p, acc, v, pl2x, pl2y, phm, pl2m);
			
			a = v.angle();
			
			px = p.x;
			py = p.y;
			
			if (isFirst)
				trace(p);
			
			img_path.lineStyle(5, 0xFF0000, 1 - (1 / nbSegment) * i);
			img_path.moveTo(oldX, oldY);
			img_path.lineTo(px, py);
			
			oldX = px;
			oldY = py;
			
			i++;
		}
		
		// --------------------------------------
		
		
		if (firstInc > -1)
		{
			firstInc++;
			isFirst = false;
		}
	}
	
	public function getSimplePosition(x:Float, y:Float, angle:Float, vel:Vector2D, dt:Float):Vector2D
	{
		// x : position actuelle en x
		// y : position actuelle en y
		// speed : vitesse de déplacement en pixel/frame
		// angle : angle du mouvement en radian
		// vel : vecteur de vélocité
		// dt : variation du temps entre chaque frame (1 si parfait)
		
		var pos:Vector2D = new Vector2D(x, y); // position actuelle
		
		// interpolation linéaire (speed en pixel/frame)
		var projX:Float = vel.x * Math.cos(angle);
		var projY:Float = vel.y * Math.sin(angle);
		
		pos.x += projX * dt;
		pos.y += projY * dt;
		
		//pos.add(vel); // ? pas redondant d'ajouter speed PUIS vel ? est-ce que la vel n'est pas déjà speed ? si oui, comment modifier la vitesse en jeu, en jouant sur cette vel ?
		
		return pos;
	}
	
	public function addGravity(pos:Vector2D, acc:Vector2D, vel:Vector2D, entX:Float, entY:Float, m:Float, M:Float):Void
	{
		// pos : position sans influence du point
		// acc : vecteur d'accélération précédent
		// vel : vélocité précédente
		// entX/entY : position du corps influent
		// m : masse du point
		// M : masse du corps influent
		
		var K:Float = 500;
		
		var toCenter:Vector2D = new Vector2D(entX, entY);
		toCenter.minus(pos);
		
		var centerMagnitude:Float = toCenter.magnitude();
		var centerDirection:Float = toCenter.angle();
		
		var magnitude:Float = (K * m * M) / (centerMagnitude * centerMagnitude); // F = K * m * M / r²
		
		// TODO : mettre un cap à cette magnitude ?
		
		var forceX:Float = magnitude * Math.cos(centerDirection);
		var forceY:Float = magnitude * Math.sin(centerDirection);
		
		acc = new Vector2D(forceX, forceY); // a = F/m
		acc.multiply(1 / m);
		
		vel.add(acc);
		
		pos.add(vel);
	}
	
	var firstInc:Int = 0; // TEST
	var isFirst = true; // TEST
	
	
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