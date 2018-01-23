package com.grouuu;

import format.swf.Data.FontLayoutData;
import h2d.Bitmap;
import h2d.Tile;

/**
 * ...
 * @author Grouuu
 */
class Entity
{
	public var bmp:Bitmap;
	
	public var isMovable:Bool = false;
	
	public var gravity:Float = 0.0;
	public var solidRadius:Float = 0.0;
	
	public function new(bmp:Bitmap, ?x:Float = 0.0, ?y:Float = 0.0)
	{
		bmp.x = x;
		bmp.y = y;
		
		this.bmp = bmp;
	}
	
	// UPDATE /////////////////////////////////////////////////////////////////////////////////////
	
	public function update(dt:Float):Void
	{
		
	}
	
	// TRANSFORM //////////////////////////////////////////////////////////////////////////////////
	
	public function center():Void
	{
		bmp.tile.dx = -bmp.tile.width >> 1;
		bmp.tile.dy = -bmp.tile.height >> 1;
	}
	
	public function crop(tileX:Int, tileY:Int):Void
	{
		bmp.tile.setSize(tileX * 32 + 32, tileY * 32 + 32);
	}
	
	public function scale(scale:Float):Void
	{
		bmp.setScale(scale);
	}
	
	public function resize(w:Int, h:Int):Void
	{
		bmp.scaleX = w * bmp.scaleX / bmp.getSize().width;
		bmp.scaleY = h * bmp.scaleY / bmp.getSize().height;
	}
	
	public function move(x:Float, y:Float):Void
	{
		if (isMovable)
		{
			bmp.x = x;
			bmp.y = y;
		}
	}
	
	public function rotation(increment:Float):Void // value in degree
	{
		bmp.rotation += increment * Math.PI / 180;
	}
	
	// POSITION ///////////////////////////////////////////////////////////////////////////////////

	public function distanceFrom(other:Entity):Float
	{
		var dx = getX() - other.getX();
		var dy = getY() - other.getY();
		
		return Math.sqrt(dx * dx + dy * dy);
	}
	
	// GETTER / SETTER ////////////////////////////////////////////////////////////////////////////
	
	public function getX():Float	return bmp.x;
	public function getY():Float	return bmp.y;
}