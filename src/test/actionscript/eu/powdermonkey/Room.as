package eu.powdermonkey
{
	public class Room
	{
		private var _name:String
		public function get name():String { return _name }
		
		public function Room(name:String)
		{
			_name = name
		}
		
		public function toString():String
		{
			return '[Room name:'+_name+']'
		}
	}
}