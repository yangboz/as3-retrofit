package eu.powdermonkey.composure
{
	public class RoomObjectCls implements RoomObject
	{
		public function RoomObjectCls()
		{
		}
		
		private var _room:Object
	
		public function enteredRoom(room:Room):void
		{
			_room = room
		}
	}
}