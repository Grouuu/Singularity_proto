package ;

import com.grouuu.Data;
import com.grouuu.entities.Hero;
import com.grouuu.entities.Planet;
import com.grouuu.entities.Entity;
import com.grouuu.Vector2D;
import com.grouuu.entities.Solid;
import h2d.Bitmap;
import h2d.Graphics;
import h2d.Layers;
import h2d.Tile;
import h2d.TileGroup;
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
	
	var sheet:Tile;
	
	var layer_world:Layers;
	
	var listEntities:Array<Entity> = [];
	var listSolid:Array<Solid> = [];
	
	var hero:Hero;
	//var ent_planet:Planet;
	//var ent_planet2:Planet;
	
	var img_bg:Bitmap;
	var img_path:Graphics;
	
	var firstInc:Int = 0; // TEST
	var isFirst = true; // TEST
	
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
		// spritesheet --------------------------
		
		sheet = Res.spritesheet.toTile();
		
		// data ---------------------------------
		
		Data.load(hxd.Res.db.entry.getText());
		
		// background ---------------------------
		
		img_bg = new Bitmap(Tile.fromColor(0x000000, s2d.width, s2d.height), s2d);
		
		// layers -------------------------------
		
		layer_world = new Layers(s2d);
		
		// path ---------------------------------
		
		img_path = new Graphics(layer_world);
		
		// hero ---------------------------------
		
		hero = new Hero(s2d.width >> 1, s2d.height >> 1, layer_world);
		hero.mass = 10;
		hero.velocity = new Vector2D(2, 0);
		
		hero.animate([getTile(0, 0, 64, 64), getTile(64, 0, 64, 64)], 2);
		
		listSolid.push(hero);
		
		// test ---------------------------------
		
		initLevel(0);
	}
	
	public function initLevel(num:Int):Void
	{
		var level = Data.levels.all[num];
		var levelEntities = level.listLayers;
		
		// NOTE : TileGroup
		
		for (lvlEnt in levelEntities)
		{
			var x:Int = lvlEnt.x;
			var y:Int = lvlEnt.y;
			var ref = Data.entities.get(lvlEnt.ref.id);
			var tile = ref.tile;
			
			var s:Int = 32;
			var t:Tile = getTile(tile.x * s, tile.y * s, tile.width * s, tile.height * s);
			
			var ent:Solid = new Solid(x * s, y * s, layer_world);
			ent.mass = 2;
			ent.solidRadius = 2;
			
			ent.animate([t], 0);
			
			listSolid.push(ent);
		}
	}
	
	// FACTORIES //////////////////////////////////////////////////////////////////////////////////
	
	public function getTile(x:Int, y:Int, w:Int, h:Int):Tile
	{
		return sheet.sub(x, y, w, h, -w >> 1, -h >> 1);
	}
	
	// UPDATE /////////////////////////////////////////////////////////////////////////////////////
	
	var rotKeyDown:Int = 0;
	var movKeyDown:Int = 0;
	var isCrashed:Bool = false;
	
	override function update(dt:Float):Void
	{
		// key ----------------------------------
		
		var incRot:Float = 10 * Math.PI / 180;
		var incSpeed:Float = 0.1; // percent ?
		
		// rotation
		
		if (Key.isPressed(Key.RIGHT))
			hero.velocity.rotate(incRot);
		else if (Key.isPressed(Key.LEFT))
			hero.velocity.rotate( -incRot);
		
		// speed
		
		if (Key.isPressed(Key.UP))
			hero.velocity.multiply(1 + incSpeed);
		else if (Key.isPressed(Key.DOWN))
			hero.velocity.multiply(1 - incSpeed);
		
		// position -----------------------------
		
		if (!isCrashed)
		{
			var nextStep:NextStep;
			
			// move -----------------------------
			
			var heroX:Float = hero.x;
			var heroY:Float = hero.y;
			var heroVel:Vector2D = hero.velocity;
			
			nextStep = getNextPosition(heroX, heroY, heroVel);
			
			if (nextStep.positionHit == null)
			{
				nextStep.velocity.multiply(dt);
				
				layer_world.x -= nextStep.velocity.x;
				layer_world.y -= nextStep.velocity.y;
				
				hero.velocity = nextStep.velocity;
				
				// path -----------------------------
				
				img_path.clear();
				
				var nbSegment:Int = 100;
				
				var nextX:Float = heroX;
				var nextY:Float = heroY;
				var nextVel:Vector2D = hero.velocity.clone();
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
			}
			else
			{
				isCrashed = true;
				
				layer_world.x -= -nextStep.positionHit.x;
				layer_world.y -= -nextStep.positionHit.y;
			}
		}
		
		// update -------------------------------
		
		for (ent in listSolid)
			ent.update(dt);
		
		// TEST ---------------------------------
		
		firstInc++;
		
		if (firstInc > 20)
			isFirst = false;
	}
	
	public function getNextPosition(currentX:Float, currentY:Float, currentVel:Vector2D):NextStep
	{
		var pos:Vector2D = new Vector2D(currentX, currentY);
		var vel:Vector2D = currentVel.clone();
		var m:Float = hero.mass;
		var K:Float = 500;
		var capEnt:Float = 5;
		var capMove:Float = 5;
		
		var devVel:Vector2D = new Vector2D();
		var posHit:Vector2D = null;
		
		for (ent in listSolid)
		{
			if (ent != hero)
			{
				var entX:Float = ent.x;
				var entY:Float = ent.y;
				var M:Float = ent.mass;
				
				var toCenter:Vector2D = new Vector2D(entX, entY);
				toCenter.minus(pos);
				
				var centerMagnitude:Float = toCenter.magnitude();
				var centerDirection:Float = toCenter.angle();
				
				var magnitude:Float = centerMagnitude > 0 ? (K * m * M) / (centerMagnitude * centerMagnitude) : 0; // F = K * m * M / r²
				
				var forceX:Float = magnitude * Math.cos(centerDirection);
				var forceY:Float = magnitude * Math.sin(centerDirection);
				
				var acc:Vector2D = new Vector2D(forceX, forceY); // a = F/m
				acc.multiply(1 / m); // NOTE : attention aux masses de 0 : 1/0 = NaN
				
				devVel.add(acc);
				
				if (centerMagnitude <= ent.solidRadius)
				{
					posHit = toCenter.normalize().multiply(ent.solidRadius / centerMagnitude);
					break;
				}
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