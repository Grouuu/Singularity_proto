package com.grouuu;

import com.grouuu.entities.Hero;

/**
 * ...
 * @author Grouuu
 */
class HeroPath
{
	public var hero(default, null):Hero;
	
	public function new(hero:Hero) 
	{
		this.hero = hero;
	}
	
	public function getPath(entities:Array<Entity>):Array<Int>
	{
		// TODO
		
		return [450, 300, 450, 350];
	}
}