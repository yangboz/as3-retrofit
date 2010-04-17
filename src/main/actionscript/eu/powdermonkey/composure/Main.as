package eu.powdermonkey.composure
{
	import flash.geom.Point;
	import flash.utils.describeType;
	
	public class Main
	{
		private var mixinRepo:MixinRepository = new MixinRepository()
		
		private var valueClassRepo:ValueClassRepository = new ValueClassRepository()
		
		public function Main()
		{
			mixinRepo.prepare(Person, {RoomObject:RoomObjectCls, Moveable:MoveableCls}).completed.add(testMixinClass)
			valueClassRepo.prepare([ServerMessage]).completed.add(testValueClass)
		}
		
		private function testMixinClass():void
		{
//			var person:Person = mixinRepo.create(Person)
//			var room:Room = new Room()
//			person.enteredRoom(room)
//			person.move(new Point())
		}
		
		private function testValueClass():void
		{
			var serverMessage:ServerMessage = valueClassRepo.create(ServerMessage, {data:'brian', timestamp:28, id:'0'})
			var type:XML = describeType(serverMessage)
			trace(type)
			
			trace('serverMessage.id:', serverMessage.id)
			trace('serverMessage.data:', serverMessage.data)
			trace('serverMessage.timestamp:', serverMessage.timestamp)
		}
	}
}