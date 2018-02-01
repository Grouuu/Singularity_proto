package com.grouuu.entities;

import com.grouuu.Entity;
import com.grouuu.Vector2D;
import h2d.Layers;

/**
 * ...
 * @author Grouuu
 */
class Hero extends Solid
{
	public var layerWorld:Layers;
	
	public var worldX(get, null):Float = 0.0;
	public var worldY(get, null):Float = 0.0;
	public var velocity:Vector2D = new Vector2D();
	
	//public var fuel(default, null):Float;
	//public var heat(default, null):Float;
	//public var energy(default, null):Float;
	//public var radiation(default, null):Float;
	//public var speed(default, null):Float;
	//public var oxygene(default, null):Float;
	//public var armor(default, null):Float;
	
	override public function update(dt:Float):Void 
	{
		super.update(dt);
	}
	
	// INFO ///////////////////////////////////////////////////////////////////////////////////////
	
	override public function distanceTo(other:Entity):Float
	{
		throw "Don't use this method, use instead distanceFromWorld";
		
		return 0.0;
	}
	
	public function get_worldX():Float		return -layerWorld.x + x;
	public function get_worldY():Float		return -layerWorld.y + y;
}