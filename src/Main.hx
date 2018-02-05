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
	
	static private inline var TILE_SIZE:Int = 64;
	
	var sheet:Tile;
	
	var layer_world:Layers;
	
	var listEntities:Array<Entity> = [];
	var listSolid:Array<Solid> = [];
	
	var hero:Hero;
	
	var img_bg:Bitmap;
	var img_path:Graphics;
	
	var firstInc:Int = 0; // TEST
	var isFirst = true; // TEST
	
	/*
	 * TODO :
	 * • passer le héros au dessus des entities solides
	 * • mettre le héros dans liste entities
	 * • mettre en base une liste de tile au lieu d'une seule (pour anim)
	 * • dans db.entities, mettre toutes les animation du héros
	 * • tester avec trou noir
	 * • gérer les couches gazeuses
	 * • gérer les props du héros (vie, oxygène, ...)
	 * • afficher et update les props du héros
	 * • afficher des étoiles dans le bg (+ parallaxe)
	 * • améliorer les inputs (rotation + acc/decélération)
	 * • anim rotation du héros
	 * • anim acc/décélération
	 * • trouver nuancier de couleur
	 * • tester si champ d'astéroides (beaucoup de test gravité/hit etc.) est trop lourd ou non
	*/
	
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
		
		hero.animate([getTile(0, 0, 1, 1), getTile(1, 0, 1, 1)], 2);
		
		listSolid.push(hero);
		
		// test ---------------------------------
		
		initLevel(0);
	}
	
	public function initLevel(num:Int):Void
	{
		var level = Data.levels.all[num];
		var levelEntities = level.layerSolid;
		
		// NOTE : TileGroup
		
		for (lvlEnt in levelEntities)
		{
			var x:Int = lvlEnt.x;
			var y:Int = lvlEnt.y;
			var ref = Data.entities.get(lvlEnt.ref.id);
			var tileData = ref.tile;
			
			var t:Tile = getTile(tileData.x, tileData.y, tileData.width, tileData.height);
			
			var ent:Solid = new Solid(x * TILE_SIZE, y * TILE_SIZE, layer_world);
			ent.mass = ref.mass;
			ent.radiusSolid = ref.radiusSolid;
			ent.radiusGas = ref.radiusGas;
			
			// TODO : ajouter velocity/size/rotation/... (et comment les customs depuis level pour override les props des entities)
			
			ent.animate([t], 0);
			
			listSolid.push(ent);
		}
	}
	
	// FACTORIES //////////////////////////////////////////////////////////////////////////////////
	
	public function getTile(x:Int, y:Int, w:Int, h:Int):Tile
	{
		return sheet.sub(x * TILE_SIZE, y * TILE_SIZE, w * TILE_SIZE, h * TILE_SIZE, -(w * TILE_SIZE) >> 1, -(h * TILE_SIZE) >> 1);
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
			if (ent != hero && ent.mass > 0) // mass == 0 : divided by 0 (error)
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
				acc.multiply(1 / m);
				
				devVel.add(acc);
				
				if (centerMagnitude <= ent.radiusSolid)
				{
					posHit = toCenter.normalize().multiply(ent.radiusSolid / centerMagnitude);
					break;
				}
			}
		}
		
		vel.add(devVel);
		
		// TODO : sans cap, le déplacement augmente bc trop (normal ?)
		
		if (vel.magnitude() > capMove)
			vel = vel.normalize().multiply(capMove);
		
		pos.add(vel);
		
		return { position: pos, velocity: vel, positionHit: posHit };
	}
}