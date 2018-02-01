package com.grouuu;

/**
 * ...
 * @author Grouuu
 */

// https://code.tutsplus.com/tutorials/gravity-in-action--active-8915
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
	
	public function rotate(rad:Float):Vector2D
	{
		x = x * Math.cos(rad) - y * Math.sin(rad);
		y = x * Math.sin(rad) + y * Math.cos(rad);
		
		return this;
	}
	
	public function normalize():Vector2D
	{
		return clone().multiply(1 / magnitude());
	}
	
	public function minus(vector:Vector2D):Vector2D
	{
		x -= vector.x;
		y -= vector.y;
		
		return this;
	}
	
	public function add(vector:Vector2D):Vector2D
	{
		x += vector.x;
		y += vector.y;
		
		return this;
	}
	
	public function multiply(scalar:Float):Vector2D
	{
		x *= scalar;
		y *= scalar;
		
		return this;
	}
	
	public function reset():Vector2D
	{
		x = 0.0;
		y = 0.0;
		
		return this;
	}
	
	public function clone():Vector2D
	{
		return new Vector2D(x, y);
	}
}