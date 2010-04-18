package eu.powdermonkey.composure
{
	import eu.powdermonkey.*;
	
	import flash.geom.Point;
	import flash.utils.describeType;
	
	public class Main
	{
		private var mixinRepo:MixinRepository = new MixinRepository()
		
		private var valueClassRepo:ValueClassRepository = new ValueClassRepository()
		
		public function Main()
		{
			with(mixinRepo)
			{
				defineMixin(RoomObject, RoomObjectCls)
				defineMixin(Moveable, MoveableCls)
				defineMixin(ItemContainer, ItemContainerImpl)
				defineBase(Person)
				defineBase(Desk)
				defineBase(Item)
				prepare().completed.add(testMixins)
			}
			
			valueClassRepo.prepare([ServerMessage]).completed.add(testValueClass)
		}
		
		private function testMixins():void
		{
			testDesk()
//			testPerson()
		}
				
		private function testDesk():void
		{
			var room:Room = new Room('lobby')
			var desk:Desk = mixinRepo.create(Desk)
			var apple:Item = mixinRepo.create(Item)
			desk.joinRoom(room)
			desk.addItem(apple)
			trace('desk in room:', desk.room, desk.items)
		}
		
		private function testPerson():void
		{
			var person:Person = mixinRepo.create(Person)
//			var type:XML = describeType(Person)
//			trace(type)
			trace('person:', person)
			var roomA:Room = new Room('roomA')
			var roomB:Room = new Room('roomB')
			
			person.joinRoom(roomA)
			trace('person.room:', person.room)
			
			person.enteredTwoRooms(roomB, roomA)
			trace('person.room:', person.room)
			
			person.room = roomA
			trace('person.room:', person.room)
			
			trace('person.getRoomName(roomA):', person.getRoomName(roomA))
			
			person.move(new Point())
			trace('person.location:', person.location)
		}
		
		private function testValueClass():void
		{
			var serverMessage:ServerMessage = valueClassRepo.create(ServerMessage, {data:'brian', timestamp:28, id:'0'})
			var type:XML = describeType(serverMessage)
//			trace(type)
//			trace('serverMessage.id:', serverMessage.id)
//			trace('serverMessage.data:', serverMessage.data)
//			trace('serverMessage.timestamp:', serverMessage.timestamp)
//			trace('serverMessage.toString:', serverMessage)
		}
	}
}