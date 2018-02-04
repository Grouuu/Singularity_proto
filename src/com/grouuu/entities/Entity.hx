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
	
	/*public function center():Void
	{
		bmp.tile.dx = -bmp.tile.width >> 1;
		bmp.tile.dy = -bmp.tile.height >> 1;
	}*/
	
	/*public function crop(tileX:Int, tileY:Int):Void
	{
		bmp.tile.setSize(tileX * 32 + 32, tileY * 32 + 32);
	}*/
	
	/*public function scale(scale:Float):Void
	{
		bmp.setScale(scale);
	}*/
	
	// TODO : vaut mieux resize le bitmap ou le tile ? attention en centrage
	/*public function scaleToSize(w:Int, h:Int):Void
	{
		bmp.tile.scaleToSize(w, h);
	}*/
	
	/*public function resize(w:Int, h:Int):Void
	{
		bmp.scaleX = w * bmp.scaleX / bmp.getSize().width;
		bmp.scaleY = h * bmp.scaleY / bmp.getSize().height;
	}*/
	
	/*public function move(x:Float, y:Float):Void
	{
		bmp.x = x;
		bmp.y = y;
	}*/
	
	// INFO ///////////////////////////////////////////////////////////////////////////////////////

	/*public function distanceTo(other:Entity):Float
	{
		var dx = x - other.x;
		var dy = y - other.y;
		
		return Math.sqrt(dx * dx + dy * dy);
	}*/
	
	//public function get_x():Float					return bmp.x;
	//public function set_x(value:Float):Float		return bmp.x = value;
	//public function get_y():Float					return bmp.y;
	//public function set_y(value:Float):Float		return bmp.y = value;
}