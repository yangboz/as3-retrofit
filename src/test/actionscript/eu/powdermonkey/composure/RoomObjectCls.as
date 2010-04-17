package eu.powdermonkey.composure
{
	public class RoomObjectCls implements RoomObject
	{
		public function RoomObjectCls()
		{
		}
		
		private var _room:Room
		public function get room():Room { return _room }
		
		public function enteredRoom(room:Room):void
		{
			_room = room
		}
	}
}