package com.grouuu.entities;

import com.grouuu.entities.Entity;
import com.grouuu.Vector2D;
import h2d.Bitmap;
import h2d.Layers;

/**
 * ...
 * @author Grouuu
 */
class Hero extends Solid
{
	public var velocity:Vector2D = new Vector2D();
	
	private var decalX:Float = 0.0;
	private var decalY:Float = 0.0;
	
	//public var fuel(default, null):Float;
	//public var heat(default, null):Float;
	//public var energy(default, null):Float;
	//public var radiation(default, null):Float;
	//public var speed(default, null):Float;
	//public var oxygene(default, null):Float;
	//public var armor(default, null):Float;
	
	public function new(x:Float, y:Float, parent:Layers)
	{
		decalX = x;
		decalY = y;
		
		super(x, y, parent);
	}
	
	override public function update(dt:Float):Void 
	{
		x = -parent.x + decalX;
		y = -parent.y + decalY;
		
		super.update(dt);
	}
}