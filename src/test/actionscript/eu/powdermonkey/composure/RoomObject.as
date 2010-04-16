package eu.powdermonkey.composure
{
	public class RoomObject
	{
		public function RoomObject()
		{
		}
		
		private var _room:Object
	
		public function enteredRoom(room:Object):void
		{
			_room = room
		}
	}
}