package eu.powdermonkey.composure
{
	import flash.utils.Dictionary;
	
	public class MixinRepository extends ClassRepository
	{
		private var mixinGenerator:MixinGenerator = new MixinGenerator()
		
		public function prepare(base:Class, mixins:Object):PreperationSignals
		{
			return prepareClasses([base], mixinGenerator)
		}
		
		public function create(cls:Class, args:Object=null):*
		{
			return new Object()
		}
	}
}