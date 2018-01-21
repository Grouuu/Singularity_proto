package com.grouuu ;

import com.grouuu.Entity;

/**
 * ...
 * @author Grouuu
 */
class Sphere extends Entity
{
	public var radiusMin:Float = 0.0;
	public var radiusMax:Float = 0.0;
	
	public function isHit(other:Entity):Bool
	{
		var dist:Float = distanceFrom(other);
		
		return (dist <= radiusMin && dist >= radiusMax && radiusMax > 0.0);
	}
}