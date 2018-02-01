package com.grouuu;

import h2d.Bitmap;

/**
 * ...
 * @author Grouuu
 */
class Entity
{
	@:isVar public var x(get, set):Float = 0.0;
	@:isVar public var y(get, set):Float = 0.0;
	
	private var bmp:Bitmap;
	
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
	
	// TODO : vaut mieux resize le bitmap ou le tile ? attention en centrage
	/*public function scaleToSize(w:Int, h:Int):Void
	{
		bmp.tile.scaleToSize(w, h);
	}*/
	
	public function resize(w:Int, h:Int):Void
	{
		bmp.scaleX = w * bmp.scaleX / bmp.getSize().width;
		bmp.scaleY = h * bmp.scaleY / bmp.getSize().height;
	}
	
	public function move(x:Float, y:Float):Void
	{
		bmp.x = x;
		bmp.y = y;
	}
	
	public function rotation(increment:Float):Void // value in degree
	{
		bmp.rotation += increment * Math.PI / 180;
	}
	
	// INFO ///////////////////////////////////////////////////////////////////////////////////////

	public function distanceTo(other:Entity):Float
	{
		var dx = x - other.x;
		var dy = y - other.y;
		
		return Math.sqrt(dx * dx + dy * dy);
	}
	
	public function get_x():Float					return bmp.x;
	public function set_x(value:Float):Float		return bmp.x = value;
	public function get_y():Float					return bmp.y;
	public function set_y(value:Float):Float		return bmp.y = value;
}