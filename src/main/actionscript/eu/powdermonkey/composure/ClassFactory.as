package eu.powdermonkey.composure
{
	import flash.utils.Dictionary;
	
	public class ClassFactory
	{
		private var prepared:Dictionary = new Dictionary()
		
		public function ClassFactory()
		{
		}
		
		public function prepare(classes:Array, applicationDomain:ApplicationDomain = null):PreperationSignals
		{
			applicationDomain = applicationDomain || new ApplicationDomain(ApplicationDomain.currentDomain)
			
			classes = classes.filter(typeAlreadyPreparedFilter)
			
			if (classes.length == 0) 
			{
				return new PreperationSignals()
			}
			
			var dynamicClasses:Array = new Array()
			var layoutBuilder:IByteCodeLayoutBuilder = new ByteCodeLayoutBuilder()
			var generatedNames:Dictionary = new Dictionary()
			
			for each(var cls:Class in classes)
			{
				var type:Type = Type.getType(cls)
				
				if (type.isGeneric || type.isGenericTypeDefinition)
				{
					throw new IllegalOperationError("Generic types (Vector) are not supported. (feature request #2599097)")
				}
				
				if (type.qname.ns.kind != NamespaceKind.PACKAGE_NAMESPACE)
				{
					throw new IllegalOperationError("Private (package) classes are not supported. (feature request #2549289)")
				}
				
				var qname:QualifiedName = generateQName(type)
				generatedNames[cls] = qname

				var dynamicClass:DynamicClass = valueClassGenerator.createFromInterface(qname, type)
				layoutBuilder.registerType(dynamicClass);
			}
			
			layoutBuilder.registerType(Type.getType(IProxyListener));
			
			var layout:IByteCodeLayout = layoutBuilder.createLayout();
			
			var loader:Loader = createSwf(layout, applicationDomain);
			_loaders.push(loader);			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, swfLoadedHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, swfErrorHandler);
			loader.contentLoaderInfo.addEventListener(ErrorEvent.ERROR, swfErrorHandler);
			
			var signals:PreperationSignals = new PreperationSignals()
			return signals
			
			function swfErrorHandler(error:ErrorEvent):void
			{
				signals.error.dispatch(error.text)
			}
			
			function swfLoadedHandler(event:Event):void
			{
				for each(var cls:Class in classes)
				{
					var qname:QualifiedName = generatedNames[cls]
					var fullName:String = qname.ns.name.concat('::', qname.name)
					var generatedClass:Class = loader.contentLoaderInfo.applicationDomain.getDefinition(fullName) as Class
					Type.getType(generatedClass)
					prepared[cls] = generatedClass;
				}
				
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, swfLoadedHandler);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, swfErrorHandler);
				loader.contentLoaderInfo.removeEventListener(ErrorEvent.ERROR, swfErrorHandler);
				
				signals.completed.dispatch()
			}
		}
		
		private function typeAlreadyPreparedFilter(cls:Class, index:int, array:Array):Boolean
		{
			return (cls in prepared == false)
		}
	}
}