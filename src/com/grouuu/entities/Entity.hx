package com.grouuu.entities;

import h2d.Anim;
import h2d.Bitmap;
import h2d.Layers;

/**
 * ...
 * @author Grouuu
 */
class Entity
{
	public var x:Float = 0.0;
	public var y:Float = 0.0;
	public var parent:Layers;
	
	public var anim:Anim;
	
	public function new(?x:Float = 0.0, ?y:Float = 0.0, parent:Layers)
	{
		this.x = x;
		this.y = y;
		this.parent = parent;
	}
	
	// UPDATE /////////////////////////////////////////////////////////////////////////////////////
	
	public function update(dt:Float):Void
	{
		if (anim != null)
		{
			anim.x = x;
			anim.y = y;
		}
	}
	
	// ANIM ///////////////////////////////////////////////////////////////////////////////////////
	
	public function animate(tiles, speed:Float):Void
	{
		if (anim != null)
			anim.remove(); // TODO : trash for GC
		
		anim = new Anim(tiles, speed, parent);
	}
	
	// TRANSFORM //////////////////////////////////////////////////////////////////////////////////
	
	public function rotation(increment:Float):Void // value in degree
	{
		anim.rotation += increment * Math.PI / 180;
	}
}