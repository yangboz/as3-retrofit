package eu.powdermonkey
{
	import flash.geom.Point;

	public class MoveableCls implements Moveable
	{
		private var _location:Point = new Point() 
		public function get location():Point { return _location }
		
		public function move(location:Point):void
		{
			_location = location.clone()
		}
	}
}