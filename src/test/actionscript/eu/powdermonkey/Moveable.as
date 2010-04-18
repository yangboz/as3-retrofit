package eu.powdermonkey
{
	import flash.geom.Point;
	
	public interface Moveable
	{
		function move(location:Point):void
		function get location():Point
	}
}