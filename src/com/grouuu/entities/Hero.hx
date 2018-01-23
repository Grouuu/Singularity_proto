package com.grouuu.entities;

import com.grouuu.Entity;
import com.grouuu.Vector2D;
import h2d.Layers;

/**
 * ...
 * @author Grouuu
 */
class Hero extends Entity
{
	public var layerWorld:Layers;
	
	public var fuel(default, null):Float;
	public var heat(default, null):Float;
	public var energy(default, null):Float;
	public var radiation(default, null):Float;
	public var speed(default, null):Float;
	public var oxygene(default, null):Float;
	public var armor(default, null):Float;
	
	public var incRotation(default, null):Float = 2.0;
	
	public var vec_vel:Vector2D;
	public var mass:Float = 10.0;
	
	override public function update(dt:Float):Void 
	{
		super.update(dt);
	}
	
	public function changeFuel(value:Float):Float		{ fuel = value; return fuel; }
	public function changeHeat(value:Float):Float		{ heat = value; return heat; }
	public function changeEnergy(value:Float):Float		{ energy = value; return energy; }
	public function changeRadiation(value:Float):Float	{ radiation = value; return radiation; }
	//public function changeGravity(value:Float):Float	{ gravity = value; return gravity; }
	public function changeSpeed(value:Float):Float		{ speed = value; return speed; }
	public function changeOxygene(value:Float):Float	{ oxygene = value; return oxygene; }
	public function changeArmor(value:Float):Float		{ armor = value; return armor; }
	
	public function isAlive():Bool
	{
		return true;
	}
	
	// POSITION ///////////////////////////////////////////////////////////////////////////////////
	
	public function getWorldX():Float
	{
		return getX() - layerWorld.x;
	}
	
	public function getWorldY():Float
	{
		return getY() - layerWorld.y;
	}
	
	public function getRotation():Float
	{
		return bmp.rotation; // in rad
		//return bmp.rotation * 180 / Math.PI; // in degree
	}

	override public function distanceFrom(other:Entity):Float
	{
		throw "Don't use this method, use instead distanceFromWorld";
		
		return 0.0;
	}
	
	public function distanceFromWorld(other:Entity):Float
	{
		var dx:Float = getWorldX() - other.getX();
		var dy:Float = getWorldY() - other.getY();
		
		return Math.sqrt(dx * dx + dy * dy);
	}
	
	public function angleFromWorld(other:Entity):Float
	{
		var dx = other.getX() - getWorldX();
		var dy = other.getY() - getWorldY();
		
		return Math.atan2(dy, dx);
	}
}