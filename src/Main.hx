package ;

import com.grouuu.Data;
import com.grouuu.Vector2D;
import com.grouuu.entities.Entity;
import com.grouuu.entities.Hero;
import com.grouuu.entities.Solid;
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

typedef Star =
{
	var x:Int;
	var y:Int;
	var radius:Int;
	var power:Int;
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
	var star:Star;
	
	var img_bg:Bitmap;
	var img_path:Graphics;
	var img_light:Graphics;
	
	var firstInc:Int = 0; // TEST
	var isFirst = true; // TEST
	
	// https://github.com/HeapsIO/heaps
	// https://gitter.im/heapsio/Lobby
	
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
	
	// PointLight pour shader mais s3d alors ?
	// class Atlas pour gérer les tiles ?
	// class Sprite pour gérer mes groupes d'entités ? (Et TileGroup alors ?)
	// SceneInspector avec castleDB pour changer des valeur en live ?
	// h2d.comp = composants obsolète, utiliser castle plutôt
	// h2d.Flow
	
	// INIT ///////////////////////////////////////////////////////////////////////////////////////
	
	static function main()
	{
		Res.initEmbed();
		
		instance = new Main();
	}
	
	override function init():Void
	{
		// spritesheet --------------------------
		
		sheet = Res.spritesheet.toTile();
		
		// data ---------------------------------
		
		Data.load(hxd.Res.db.entry.getText());
		
		// background ---------------------------
		
		img_bg = new Bitmap(Tile.fromColor(0x1A1A2E, s2d.width, s2d.height), s2d);
		
		// light --------------------------------
		
		/*img_light = new Graphics(s2d);
		img_light.x = -256;
		img_light.y = -256;*/
		
		// layers -------------------------------
		
		layer_world = new Layers(s2d);
		
		// path ---------------------------------
		
		img_path = new Graphics(layer_world);
		
		// hero ---------------------------------
		
		hero = new Hero(s2d.width >> 1, s2d.height >> 1, layer_world);
		hero.mass = 10;
		hero.velocity = new Vector2D(0, 0);
		
		hero.animate([getTile(0, 0, 1, 1), getTile(1, 0, 1, 1)], 2);
		
		listSolid.push(hero);
		
		// test ---------------------------------
		
		img_light = new Graphics(s2d);
		img_light.x = -256;
		img_light.y = -256;
		
		initLevel(0);
	}
	
	public function initLevel(num:Int):Void
	{
		star = { x: 1000, y: - 1000, radius: 300, power: 10 };
		
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
	
	// LIGHT FIELD ////////////////////////////////////////////////////////////////////////////////
	
	public function updateLight():Void
	{
		img_light.clear();
		
		var color:UInt = 0x000033;
		
		//img_light.beginFill(color);
		
		// TODO
		// calculer le point d'intersection des deux tangentes
		// si il est dans le screen, faire un triangle
		// sinon, dessiner un quadrilatère (si les deux tangentes touchent le même bord, ou un pentagone (si elles touchent deux bords différents - avec un coin)
		
		for (ent in listSolid)
		{
			if (ent != hero && ent.x > -256 && ent.x < s2d.width + 256 && ent.y > -256 && ent.y < s2d.height + 256)
			{
				var entX:Float = ent.x;
				var entY:Float = ent.y;
				var radius:Int = ent.radiusSolid;
				
				var angle:Float = Math.atan2(entY - star.y, entX - star.x);
				
				// point2.x + Math.cos(ang - Math.PI / 2) * radius2
				// point2.y + Math.sin(ang - Math.PI/2)* radius2
				
				var posX:Float = entX + Math.cos(angle + Math.PI / 2) * radius + 256;
				var posY:Float = entY + Math.sin(angle + Math.PI / 2) * radius + 256;
				
				var originX:Float = posX;
				var originY:Float = posY;
				
				img_light.lineStyle(5, 0xFF0000);
				
				img_light.moveTo(posX, posY);
				
				posX = entX + Math.cos(angle - Math.PI / 2) * radius + 256;
				posY = entY + Math.sin(angle - Math.PI / 2) * radius + 256;
				
				img_light.lineTo(posX, posY);
				
				var intersecX:Float = 
				
				//var ang
			}
		}
		
		img_light.endFill();
	}
	
	/*
	 * TODO
	 * • tracer une ligne du centre de la source vers l'entité
	 * • calculer la perpendiculaire, de longueur solidRadius
	 * • tracer le quadrilatère qui est formé de deux extrémités de l'entité et le bord du level
	 * • remplir ces quadrilatère avec la couleur "ombre"
	 * • calculer une fois les ombres pour les entités statiques
	 * • calculer à chaque frame les ombres pour les entités mobiles
	 * • ajouter les deux jeux d'ombres à la scène
	 * • détecter quand le héros est hors des ombres
	 * 		- en détectant si le héros est sur une ombre ou non (test hitbox, ou pixel) -> implique de pouvoir tester l'image des ombres
	 * 		- en raycastant le héros depuis la source (permet un jeu de lumière en shader ?)
	 * 
	 * NOTE
	 * • ne marche que pour des entités rondes
	 * 
	 * WARNING
	 * • ne pas faire un bitmap unique géant, ça prendrais trop de RAM
	*/
	
	// https://haxe.org/blog/nicolas-about-haxe-episode-2/
	// http://old.haxe.org/manual/hxsl
	// http://ncannasse.fr/blog/announcing_hxsl
	// http://ncase.me/sight-and-light/
	// https://github.com/ncase/sight-and-light/blob/gh-pages/draft6.html
	// http://www.catalinzima.com/2010/07/my-technique-for-the-shader-based-dynamic-2d-shadows/
	// https://github.com/mattdesl/lwjgl-basics/wiki/2D-Pixel-Perfect-Shadows
	
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
		
		updateLight();
		
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
		
		//vel.add(devVel); // TEST : désactivé pour test
		
		// TODO : sans cap, le déplacement augmente bc trop (normal ?)
		
		if (vel.magnitude() > capMove)
			vel = vel.normalize().multiply(capMove);
		
		pos.add(vel);
		
		return { position: pos, velocity: vel, positionHit: posHit };
	}
}