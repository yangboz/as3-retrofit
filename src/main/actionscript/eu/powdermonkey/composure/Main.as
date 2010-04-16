package eu.powdermonkey.composure
{
	import flash.events.Event;
	import flash.utils.describeType;
	
	public class Main
	{
		public function Main()
		{
//			var mockRepository : MockRepository = new MockRepository();
//			mockRepository.prepare([IProductRepository]).addEventListener(
//        		Event.COMPLETE, 
//				function (event:Event):void {
//					testMock(mockRepository)
//				}
//			);
			
			var mixinFactory:MixinFactory = new MixinFactory()
			mixinFactory.prepare([Person]).addEventListener(
        		Event.COMPLETE, 
				function (event:Event):void {
					testMixin(mixinFactory)
				}
			);
		}
		
		private function testMixin(mixinFactory:MixinFactory):void
		{
			var person:Person = mixinFactory.mush(Person, 'brian', 28, '0');
			var type:XML = describeType(person)
			trace(type)
			
			trace('person.id:', person.id)
			trace('person.name:', person.name)
			trace('person.age:', person.age)
		}
		
//		private function testMock(mockRepository:MockRepository):void
//		{
//			var product5 : Product = new Product("Steak");
//			var product20 : Product = new Product("Chicken");
//			
//			var productRepository : IProductRepository = IProductRepository(mockRepository.createStub(IProductRepository));
//			
//			var type:XML = describeType(productRepository)
//			
//			trace(type)
//			
//			SetupResult.forCall(productRepository.getProduct(5)).returnValue(product5);
//			SetupResult.forCall(productRepository.getProduct(20)).returnValue(product20);
//			SetupResult.forCall(productRepository.getProduct(50)).throwError(new Error("Invalid product"));
//			
//			mockRepository.replay(productRepository);
//			
//			// Throws an Error "Invalid product"
////			var returnProduct1 : Product = productRepository.getProduct(50);
//			
//			// Returns product "Chicken"
//			var returnProduct2 : Product = productRepository.getProduct(20);
//			
//			// Returns product "Steak"
//			var returnProduct3 : Product = productRepository.getProduct(5);
//			
//			// Returns null (because it's a stub)
//			var returnProduct4 : Product = productRepository.getProduct(30);
//		}
	}
}