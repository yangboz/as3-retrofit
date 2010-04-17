package eu.powdermonkey.composure
{
	import flash.utils.describeType;
	
	public class Main
	{
		public function Main()
		{
//			var mixinRepo:MixinRepository = new MixinRepository()
//			mixinRepo.prepare(Person, {RoomObject:RoomObjectCls, Moveable:MoveableCls})
			
			var valueClassRepo:ValueClassRepository = new ValueClassRepository()
			valueClassRepo.prepare([Person]).completed.add(function ():void {
				testMixin(valueClassRepo)
			})
			
//			var mixinFactory:MixinFactory = new MixinFactory()
//			mixinFactory.prepare([Person]).addEventListener(
//        		Event.COMPLETE, 
//				function (event:Event):void {
//					testMixin(mixinFactory)
//				}
//			);
		}
		
		private function testMixin(valueClassRepo:ValueClassRepository):void
		{
			trace('textMixin')			
			var person:Person = valueClassRepo.create(Person, {name:'brian', age:28, id:'0'})
			var type:XML = describeType(person)
			trace(type)
			
			trace('person.id:', person.id)
			trace('person.name:', person.name)
			trace('person.age:', person.age)
		}
	}
}