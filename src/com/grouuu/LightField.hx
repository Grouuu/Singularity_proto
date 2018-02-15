package com.grouuu;
import com.grouuu.LightField.Segment;

/**
 * ...
 * @author Damien Desjardin
 */

typedef Segment =
{
	
}

class LightField
{
	// https://www.redblobgames.com/articles/visibility/
	
	var listSegments:Array<Segment> = [];

	public function new() 
	{
		
	}
	
	public function setMap():Void
	{
		this.listSegments = listSegments;
		
		
	}
}