package com.grouuu;

/**
 * ...
 * @author Grouuu
 */

// https://code.tutsplus.com/tutorials/gravity-in-action--active-8915
// https://code.tutsplus.com/tutorials/euclidean-vectors-in-flash--active-8192
// http://www.al.lu/physics/premiere/robinet/cinematique.pdf
class Vector2D
{
	public var x:Float = 0.0;
	public var y:Float = 0.0;
	
	public function new(x:Float = 0, y:Float = 0):Void
	{
		this.x = x;
		this.y = y;
	}
	
	public function magnitude():Float
	{
		return Math.sqrt(x * x + y * y);
	}
	
	public function angle():Float
	{
		return Math.atan2(y, x);
	}
	
	public function direction():Vector2D
	{
		return new Vector2D(x / magnitude(), y / magnitude());
	}
	
	public function minus(vector:Vector2D):Void
	{
		x -= vector.x;
		y -= vector.y;
	}
	
	public function add(vector:Vector2D):Void
	{
		x += vector.x;
		y += vector.y;
	}
	
	public function multiply(scalar:Float):Void
	{
		x *= scalar;
		y *= scalar;
	}
	
	public function reset():Void
	{
		x = 0.0;
		y = 0.0;
	}
	
	public function clone():Vector2D
	{
		return new Vector2D(x, y);
	}
}