package eu.powdermonkey.composure
{
	import flash.utils.describeType;
	
	public class ComposeTwoObjects
	{
		
		[Before]
		public function setup():void
		{
			
		}
		
		[After]
		public function tearDown():void
		{
			
		}
		
		[Test]
		public function compose():void
		{
			injectMethods(User, new RoomObject())
			
			var user:Object = new User()
			trace(user.enteredRoom({id:"room"}))
			var userType:XML = describeType(user)
			trace(userType)
			
			var roomObjectType:XML = describeType(RoomObject)
//			trace(roomObjectType)
		}
		
		private function injectMethods(clazz:Class, mixin:Object):void
		{
			var type:XML = describeType(mixin)
			
			for each (var prop:XML in type.factory.method)
			{
				var propName:String = prop.@name
				trace('injecting:', propName, ' => ', mixin[propName])
				clazz.prototype[propName] = mixin[propName] 
			}
		}
	}
}